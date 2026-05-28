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

use Mpdf\Mpdf;

$db          = getConexion();
$padreModel  = new PadreModel($db, new UserModel($db));
$alumnoModel = new AlumnoModel($db, new UserModel($db));
$cicloModelo = new CicloModel($db);
$boletaModel = new BoletaModel($db);

$padre = $padreModel->obtenerPorUserId((int)$_SESSION['user_id']);
if (!$padre) { header('Location: /proyecto/login.php'); exit; }

$cicloActivo = $cicloModelo->obtenerActivo();
$alumnoId    = (int)($_GET['alumno_id'] ?? 0);
$tipo        = $_GET['tipo'] ?? 'espanol';

$hijos = $alumnoModel->obtenerPorPadreId((int)$padre['id']);
$alumnoValido = false;
foreach ($hijos as $h) {
    if ((int)$h['id'] === $alumnoId) { $alumnoValido = true; break; }
}

if (!$alumnoValido || !$cicloActivo) {
    header('Location: mis_hijos.php');
    exit;
}

$boleta           = $boletaModel->obtenerBoleta($alumnoId, (int)$cicloActivo['id']);
$alumno           = $boleta['alumno']           ?? [];
$porCampo         = $boleta['porCampo']         ?? [];
$periodosAbiertos = $boleta['periodosAbiertos'] ?? [];

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

// ── HTML del PDF ──────────────────────────────────────────────
ob_start();
?>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: sans-serif; font-size: 10px; color: #334155; }

  .header {
    background: #1e3a5f;
    color: #fff;
    padding: 8px 12px;
    margin-bottom: 8px;
  }
  .header h1 { font-size: 13px; }
  .header p  { font-size: 9px; }

  .datos {
    border: 1px solid #e2e8f0;
    padding: 5px 8px;
    margin-bottom: 8px;
    background: #f8fafc;
    font-size: 9px;
  }
  .datos strong { color: #1e3a5f; }

  .seccion-titulo {
    font-size: 10px;
    font-weight: bold;
    color: #1e3a5f;
    border-bottom: 1px solid #1e3a5f;
    padding-bottom: 2px;
    margin-bottom: 5px;
  }

  table {
    width: 100%;
    border-collapse: collapse;
    font-size: 8.5px;
    margin-bottom: 10px;
  }
  th {
    background: #1e3a5f;
    color: #fff;
    padding: 3px 4px;
    text-align: center;
    border: 1px solid #1e3a5f;
  }
  th.izq { text-align: left; }
  td {
    padding: 3px 4px;
    border: 1px solid #e2e8f0;
    text-align: center;
  }
  td.izq { text-align: left; }
  tr:nth-child(even) td { background: #f8fafc; }

  .campo-cell {
    background: #dbeafe !important;
    font-weight: bold;
    color: #1e3a5f;
    font-size: 8px;
  }
  .trim { background: #eff6ff !important; font-weight: bold; color: #1e3a5f; }
  .rep  { color: #991b1b; font-weight: bold; }

  .firmas { margin-top: 30px; width: 100%; }
  .firma  {
    display: inline-block;
    width: 30%;
    text-align: center;
    border-top: 1px solid #334155;
    padding-top: 3px;
    font-size: 8px;
    margin-right: 4%;
  }
</style>
</head>
<body>

<div class="header">
  <h1>🏫 Sistema Escolar —
    <?= $tipo === 'ingles' ? 'Boleta de Inglés' : 'Boleta de Calificaciones' ?>
  </h1>
  <p>Ciclo escolar: <?= htmlspecialchars($cicloActivo['nombre']) ?></p>
</div>

<div class="datos">
  <strong>Alumno:</strong>
  <?= htmlspecialchars($alumno['nombre'] . ' ' . $alumno['apellido_paterno'] . ' ' . ($alumno['apellido_materno'] ?? '')) ?>
  &nbsp;&nbsp;
  <strong>Matrícula:</strong> <?= htmlspecialchars($alumno['matricula'] ?? '—') ?>
  &nbsp;&nbsp;
  <strong>Grado:</strong> <?= $alumno['grado'] ?>° <?= $alumno['grupo'] ?>
  &nbsp;&nbsp;
  <strong>Sección:</strong> <?= ucfirst($alumno['seccion']) ?>
</div>

<?php if ($tipo === 'espanol'): ?>

  <p class="seccion-titulo">Calificaciones por materia</p>
  <table>
    <thead>
      <tr>
        <th class="izq" style="width:16%;">Campo formativo</th>
        <th class="izq" style="width:18%;">Materia</th>
        <th>P1</th><th>P2</th><th>P3</th><th>P4</th><th>P5</th><th>P6</th>
        <th class="trim">T1</th>
        <th class="trim">T2</th>
        <th class="trim">T3</th>
      </tr>
    </thead>
    <tbody>
      <?php foreach ($porCampo as $campo => $materias): ?>
        <?php
          $filtradas = array_values(array_filter($materias, fn($x) => !(int)$x['es_ingles']));
          if (empty($filtradas)) continue;
        ?>
        <?php foreach ($filtradas as $i => $m): ?>
          <tr>
            <?php if ($i === 0): ?>
              <td class="campo-cell izq" rowspan="<?= count($filtradas) ?>">
                <?= htmlspecialchars($campo) ?>
              </td>
            <?php endif; ?>
            <td class="izq">
              <?= htmlspecialchars($m['materia_nombre']) ?>
              <?php if (!empty($m['subcomponente'])): ?>
                <br><small style="color:#64748b;">(<?= htmlspecialchars($m['subcomponente']) ?>)</small>
              <?php endif; ?>
            </td>
            <?php for ($p = 1; $p <= 6; $p++): ?>
              <?php $cal = $m['calificaciones'][$p] ?? null; ?>
              <td class="<?= ($cal !== null && $cal < 6) ? 'rep' : '' ?>">
                <?= $cal ?? (in_array($p, $periodosAbiertos) ? '—' : '') ?>
              </td>
            <?php endfor; ?>
            <?php for ($t = 1; $t <= 3; $t++): ?>
              <?php $prom = $m['trimestres'][$t] ?? null; ?>
              <td class="trim <?= ($prom !== null && $prom < 6) ? 'rep' : '' ?>">
                <?= $prom ?? '—' ?>
              </td>
            <?php endfor; ?>
          </tr>
        <?php endforeach; ?>
      <?php endforeach; ?>
    </tbody>
  </table>

<?php elseif ($tipo === 'ingles' && $boletaIngles): ?>

  <p class="seccion-titulo">Calificaciones — Inglés</p>
  <table>
    <thead>
      <tr>
        <th class="izq" style="width:22%;">Habilidad</th>
        <th>P1</th><th>P2</th><th>P3</th><th>P4</th><th>P5</th><th>P6</th>
        <th class="trim">T1</th>
        <th class="trim">T2</th>
        <th class="trim">T3</th>
      </tr>
    </thead>
    <tbody>
      <?php foreach ($boletaIngles['aspectos'] as $asp): ?>
        <tr>
          <td class="izq"><?= htmlspecialchars($asp['nombre']) ?></td>
          <?php for ($p = 1; $p <= 6; $p++): ?>
            <?php $cal = $asp['calificaciones'][$p] ?? null; ?>
            <td class="<?= ($cal !== null && $cal < 6) ? 'rep' : '' ?>">
              <?= $cal ?? (in_array($p, $boletaIngles['periodosAbiertos']) ? '—' : '') ?>
            </td>
          <?php endfor; ?>
          <?php for ($t = 1; $t <= 3; $t++): ?>
            <?php $prom = $asp['trimestres'][$t] ?? null; ?>
            <td class="trim <?= ($prom !== null && $prom < 6) ? 'rep' : '' ?>">
              <?= $prom ?? '—' ?>
            </td>
          <?php endfor; ?>
        </tr>
      <?php endforeach; ?>
    </tbody>
  </table>

<?php endif; ?>

<div class="firmas">
  <span class="firma">Director(a)</span>
  <span class="firma">Maestro(a) Titular</span>
  <span class="firma">Padre / Tutor</span>
</div>

</body>
</html>
<?php
$html = ob_get_clean();

// Generar PDF con MPDF
$mpdf = new Mpdf([
    'mode'        => 'utf-8',
    'format'      => 'Letter',
    'orientation' => 'P',
    'margin_top'  => 10,
    'margin_bottom'=> 10,
    'margin_left' => 10,
    'margin_right'=> 10,
    'tempDir'     => sys_get_temp_dir(),
]);

$mpdf->WriteHTML($html);

$nombreArchivo = 'boleta_' . $tipo . '_' . $alumnoId . '.pdf';
$mpdf->Output($nombreArchivo, 'D'); // D = descarga
exit;