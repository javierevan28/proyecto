<?php
// padre/boleta_pdf.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/UserModel.php';
require_once __DIR__ . '/../models/PadreModel.php';
require_once __DIR__ . '/../models/AlumnoModel.php';
require_once __DIR__ . '/../models/CicloModel.php';
require_once __DIR__ . '/../models/BoletaModel.php';
require_once __DIR__ . '/../vendor/autoload.php';
requireRol([2]);

use Dompdf\Dompdf;
use Dompdf\Options;

$db          = getConexion();
$padreModel  = new PadreModel($db, new UserModel($db));
$alumnoModel = new AlumnoModel($db, new UserModel($db));
$cicloModelo = new CicloModel($db);
$boletaModel = new BoletaModel($db);

$padre = $padreModel->obtenerPorUserId((int)$_SESSION['user_id']);
if (!$padre) { header('Location: /proyecto/login.php'); exit; }

$cicloActivo = $cicloModelo->obtenerActivo();
$alumnoId    = (int)($_GET['alumno_id'] ?? 0);
$tipo        = $_GET['tipo'] ?? 'espanol'; // espanol | ingles

// Verificar que el alumno es hijo del padre
$hijos = $alumnoModel->obtenerPorPadreId((int)$padre['id']);
$alumnoValido = false;
foreach ($hijos as $h) {
    if ((int)$h['id'] === $alumnoId) { $alumnoValido = true; break; }
}

if (!$alumnoValido || !$cicloActivo) {
    header('Location: mis_hijos.php');
    exit;
}

$boleta  = $boletaModel->obtenerBoleta($alumnoId, (int)$cicloActivo['id']);
$alumno  = $boleta['alumno']   ?? [];
$porCampo = $boleta['porCampo'] ?? [];
$periodosAbiertos = $boleta['periodosAbiertos'] ?? [];

// Para boleta de inglés
$asignacionInglesId = null;
foreach ($boleta['materias'] ?? [] as $m) {
    if ((int)$m['es_ingles']) {
        $asignacionInglesId = (int)$m['asignacion_id'];
        break;
    }
}
$boletaIngles = ($tipo === 'ingles' && $asignacionInglesId)
    ? $boletaModel->obtenerBoletaIngles($alumnoId, (int)$cicloActivo['id'], $asignacionInglesId)
    : null;

// ── Generar HTML para el PDF ──────────────────────────────────
ob_start();
?>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    font-family: DejaVu Sans, sans-serif;
    font-size: 10px;
    color: #334155;
  }
  .boleta-header {
    background: #1e3a5f;
    color: #fff;
    padding: 10px 14px;
    margin-bottom: 10px;
    border-radius: 4px;
  }
  .boleta-header h1 { font-size: 13px; margin-bottom: 3px; }
  .boleta-header p  { font-size: 9px; opacity: .85; }
  .datos-alumno {
    display: table;
    width: 100%;
    margin-bottom: 10px;
    border: 1px solid #e2e8f0;
    border-radius: 4px;
    padding: 6px 10px;
    background: #f8fafc;
  }
  .dato { display: inline-block; margin-right: 16px; }
  .dato strong { color: #1e3a5f; }
  table {
    width: 100%;
    border-collapse: collapse;
    font-size: 9px;
    margin-bottom: 12px;
  }
  thead th {
    background: #1e3a5f;
    color: #fff;
    padding: 4px 5px;
    text-align: center;
    border: 1px solid #1e3a5f;
  }
  thead th.left { text-align: left; }
  tbody td {
    padding: 3px 5px;
    border: 1px solid #e2e8f0;
    text-align: center;
  }
  tbody td.left { text-align: left; }
  tbody tr:nth-child(even) td { background: #f8fafc; }
  .campo-cell {
    font-weight: bold;
    color: #1e3a5f;
    font-size: 8px;
    background: #dbeafe !important;
  }
  .trimestre { background: #eff6ff !important; font-weight: bold; color: #1e3a5f; }
  .reprobado { color: #991b1b; font-weight: bold; }
  .seccion-titulo {
    font-size: 11px;
    font-weight: bold;
    color: #1e3a5f;
    margin-bottom: 5px;
    border-bottom: 2px solid #1e3a5f;
    padding-bottom: 3px;
  }
  .firma-row {
    margin-top: 30px;
    display: table;
    width: 100%;
  }
  .firma {
    display: inline-block;
    width: 30%;
    text-align: center;
    border-top: 1px solid #334155;
    padding-top: 4px;
    font-size: 8px;
    margin-right: 4%;
  }
</style>
</head>
<body>

<!-- Encabezado -->
<div class="boleta-header">
  <h1>🏫 Sistema Escolar — <?= $tipo === 'ingles' ? 'Boleta de Inglés' : 'Boleta de Calificaciones' ?></h1>
  <p>Ciclo escolar: <?= htmlspecialchars($cicloActivo['nombre']) ?></p>
</div>

<!-- Datos del alumno -->
<div class="datos-alumno">
  <span class="dato"><strong>Alumno:</strong> <?= htmlspecialchars($alumno['nombre'] . ' ' . $alumno['apellido_paterno'] . ' ' . ($alumno['apellido_materno'] ?? '')) ?></span>
  <span class="dato"><strong>Matrícula:</strong> <?= htmlspecialchars($alumno['matricula'] ?? '—') ?></span>
  <span class="dato"><strong>Grado:</strong> <?= $alumno['grado'] ?>° <?= $alumno['grupo'] ?></span>
  <span class="dato"><strong>Sección:</strong> <?= ucfirst($alumno['seccion']) ?></span>
</div>

<?php if ($tipo === 'espanol'): ?>

  <!-- BOLETA ESPAÑOL -->
  <p class="seccion-titulo">Calificaciones por materia</p>
  <table>
    <thead>
      <tr>
        <th class="left" style="width:18%;">Campo formativo</th>
        <th class="left" style="width:20%;">Materia</th>
        <th>P1</th><th>P2</th><th>P3</th><th>P4</th><th>P5</th><th>P6</th>
        <th class="trimestre">T1</th>
        <th class="trimestre">T2</th>
        <th class="trimestre">T3</th>
      </tr>
    </thead>
    <tbody>
      <?php foreach ($porCampo as $campo => $materias): ?>
        <?php
          $materiasNoIngles = array_filter($materias, fn($x) => !(int)$x['es_ingles']);
          $materiasNoIngles = array_values($materiasNoIngles);
          if (empty($materiasNoIngles)) continue;
        ?>
        <?php foreach ($materiasNoIngles as $i => $m): ?>
          <tr>
            <?php if ($i === 0): ?>
              <td class="campo-cell left" rowspan="<?= count($materiasNoIngles) ?>">
                <?= htmlspecialchars($campo) ?>
              </td>
            <?php endif; ?>
            <td class="left">
              <?= htmlspecialchars($m['materia_nombre']) ?>
              <?php if (!empty($m['subcomponente'])): ?>
                <br><span style="font-size:7px;color:#64748b;">(<?= htmlspecialchars($m['subcomponente']) ?>)</span>
              <?php endif; ?>
            </td>
            <?php for ($p = 1; $p <= 6; $p++): ?>
              <?php $cal = $m['calificaciones'][$p] ?? null; ?>
              <td class="<?= ($cal !== null && $cal < 6) ? 'reprobado' : '' ?>">
                <?= $cal ?? (in_array($p, $periodosAbiertos) ? '—' : '') ?>
              </td>
            <?php endfor; ?>
            <?php for ($t = 1; $t <= 3; $t++): ?>
              <?php $prom = $m['trimestres'][$t] ?? null; ?>
              <td class="trimestre <?= ($prom !== null && $prom < 6) ? 'reprobado' : '' ?>">
                <?= $prom ?? '—' ?>
              </td>
            <?php endfor; ?>
          </tr>
        <?php endforeach; ?>
      <?php endforeach; ?>
    </tbody>
  </table>

<?php elseif ($tipo === 'ingles' && $boletaIngles): ?>

  <!-- BOLETA INGLÉS -->
  <p class="seccion-titulo">Calificaciones — Inglés</p>
  <table>
    <thead>
      <tr>
        <th class="left" style="width:25%;">Habilidad</th>
        <th>P1</th><th>P2</th><th>P3</th><th>P4</th><th>P5</th><th>P6</th>
        <th class="trimestre">T1</th>
        <th class="trimestre">T2</th>
        <th class="trimestre">T3</th>
      </tr>
    </thead>
    <tbody>
      <?php foreach ($boletaIngles['aspectos'] as $asp): ?>
        <tr>
          <td class="left"><?= htmlspecialchars($asp['nombre']) ?></td>
          <?php for ($p = 1; $p <= 6; $p++): ?>
            <?php $cal = $asp['calificaciones'][$p] ?? null; ?>
            <td class="<?= ($cal !== null && $cal < 6) ? 'reprobado' : '' ?>">
              <?= $cal ?? (in_array($p, $boletaIngles['periodosAbiertos']) ? '—' : '') ?>
            </td>
          <?php endfor; ?>
          <?php for ($t = 1; $t <= 3; $t++): ?>
            <?php $prom = $asp['trimestres'][$t] ?? null; ?>
            <td class="trimestre <?= ($prom !== null && $prom < 6) ? 'reprobado' : '' ?>">
              <?= $prom ?? '—' ?>
            </td>
          <?php endfor; ?>
        </tr>
      <?php endforeach; ?>
    </tbody>
  </table>

<?php endif; ?>

<!-- Firmas -->
<div class="firma-row">
  <span class="firma">Director(a)</span>
  <span class="firma">Maestro(a) Titular</span>
  <span class="firma">Padre / Tutor</span>
</div>

</body>
</html>
<?php
$html = ob_get_clean();

// Generar PDF con Dompdf
$options = new Options();
$options->set('defaultFont', 'DejaVu Sans');
$options->set('isRemoteEnabled', false);

$dompdf = new Dompdf($options);
$dompdf->loadHtml($html);
$dompdf->setPaper('Letter', 'portrait');
$dompdf->render();

$nombreArchivo = 'boleta_' . $tipo . '_' . $alumnoId . '_' . $cicloActivo['nombre'] . '.pdf';
$dompdf->stream($nombreArchivo, ['Attachment' => true]);
exit;