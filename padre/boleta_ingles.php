<?php
// padre/boleta_ingles.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/UserModel.php';
require_once __DIR__ . '/../models/PadreModel.php';
require_once __DIR__ . '/../models/AlumnoModel.php';
require_once __DIR__ . '/../models/CicloModel.php';
require_once __DIR__ . '/../models/BoletaModel.php';
requireRol([2]);

$db          = getConexion();
$padreModel  = new PadreModel($db, new UserModel($db));
$alumnoModel = new AlumnoModel($db, new UserModel($db));
$cicloModelo = new CicloModel($db);
$boletaModel = new BoletaModel($db);

$padre = $padreModel->obtenerPorUserId((int)$_SESSION['user_id']);
if (!$padre) { header('Location: /proyecto/login.php'); exit; }

$cicloActivo = $cicloModelo->obtenerActivo();
$alumnoId    = (int)($_GET['alumno_id'] ?? 0);

$hijos = $alumnoModel->obtenerPorPadreId((int)$padre['id']);
$alumnoValido = false;
foreach ($hijos as $h) {
    if ((int)$h['id'] === $alumnoId) { $alumnoValido = true; break; }
}

if (!$alumnoValido || !$cicloActivo) {
    header('Location: mis_hijos.php');
    exit;
}

$boleta = $boletaModel->obtenerBoleta($alumnoId, (int)$cicloActivo['id']);

$alumno    = $boleta['alumno']   ?? [];
$materiasIngles = $boleta['materiasIngles'] ?? [];
$periodosAbiertos = $boleta['periodosAbiertos'] ?? [];

$pageTitle = 'Boleta de Inglés — ' . ($alumno['nombre'] ?? '');
$backLink  = 'mis_hijos.php';
$backLabel = '← Mis hijos';
include __DIR__ . '/../includes/header.php';
?>

<main class="container">

  <?php if (empty($alumno)): ?>
    <p class="empty-state">No se encontró información del alumno.</p>
  <?php else: ?>

  <div class="card" style="margin-bottom:1.5rem;">
    <div style="display:flex; justify-content:space-between; align-items:start; flex-wrap:wrap; gap:1rem;">
      <div>
        <h2 style="color:var(--color-primary); font-size:1.2rem; margin-bottom:.3rem;">
          🌐 Boletín de Inglés
        </h2>
        <p class="form-hint">
          Alumno: <strong><?= htmlspecialchars($alumno['nombre'] . ' ' . $alumno['apellido_paterno'] . ' ' . ($alumno['apellido_materno'] ?? '')) ?></strong>
          &nbsp;|&nbsp;
          <?= ucfirst($alumno['seccion']) ?> — <?= $alumno['grado'] ?>° <?= $alumno['grupo'] ?>
          &nbsp;|&nbsp;
          Ciclo: <strong><?= htmlspecialchars($cicloActivo['nombre']) ?></strong>
        </p>
      </div>
      <div>
        <a class="btn btn--sm btn--accent"
           href="boleta_pdf.php?alumno_id=<?= $alumnoId ?>&tipo=ingles"
           target="_blank">
          ⬇ PDF Inglés
        </a>
      </div>
    </div>
  </div>

  <?php if (empty($materiasIngles)): ?>
    <div class="card">
      <p class="empty-state">No hay materias de Inglés asignadas para este grado.</p>
    </div>
  <?php else: ?>
    <section class="card">
      <h3 class="section-title" style="margin-bottom:1rem;">📋 Habilidades de Inglés</h3>

      <div style="overflow-x:auto;">
        <table class="data-table">
          <thead>
            <tr>
              <th rowspan="2">Habilidad</th>
              <th colspan="6">Periodos</th>
              <th colspan="3">Trimestres</th>
            </tr>
            <tr>
              <?php for ($p = 1; $p <= 6; $p++): ?>
                <th style="text-align:center; min-width:45px;">P<?= $p ?></th>
              <?php endfor; ?>
              <th style="text-align:center;">T1</th>
              <th style="text-align:center;">T2</th>
              <th style="text-align:center;">T3</th>
            </tr>
          </thead>
          <tbody>
            <?php foreach ($materiasIngles as $materia): ?>
              <?php
                $t1 = null;
                $t2 = null;
                $t3 = null;
                $p1 = $materia['calificaciones'][1] ?? null;
                $p2 = $materia['calificaciones'][2] ?? null;
                $p3 = $materia['calificaciones'][3] ?? null;
                $p4 = $materia['calificaciones'][4] ?? null;
                $p5 = $materia['calificaciones'][5] ?? null;
                $p6 = $materia['calificaciones'][6] ?? null;
                
                if ($p1 !== null && $p2 !== null) $t1 = round(($p1 + $p2) / 2);
                elseif ($p1 !== null) $t1 = $p1;
                elseif ($p2 !== null) $t1 = $p2;
                
                if ($p3 !== null && $p4 !== null) $t2 = round(($p3 + $p4) / 2);
                elseif ($p3 !== null) $t2 = $p3;
                elseif ($p4 !== null) $t2 = $p4;
                
                if ($p5 !== null && $p6 !== null) $t3 = round(($p5 + $p6) / 2);
                elseif ($p5 !== null) $t3 = $p5;
                elseif ($p6 !== null) $t3 = $p6;
              ?>
              <tr>
                <td style="font-weight:600;"><?= htmlspecialchars($materia['materia_nombre']) ?></td>
                <?php for ($p = 1; $p <= 6; $p++): 
                  $cal = $materia['calificaciones'][$p] ?? null;
                ?>
                  <td style="text-align:center; <?= ($cal !== null && $cal < 6) ? 'color:#991b1b; font-weight:600;' : '' ?>">
                    <?= $cal ?? (in_array($p, $periodosAbiertos) ? '—' : '') ?>
                  </td>
                <?php endfor; ?>
                <td style="text-align:center; font-weight:600; background:#f8fafc;"><?= $t1 ?? '—' ?></td>
                <td style="text-align:center; font-weight:600; background:#f8fafc;"><?= $t2 ?? '—' ?></td>
                <td style="text-align:center; font-weight:600; background:#f8fafc;"><?= $t3 ?? '—' ?></td>
              </tr>
            <?php endforeach; ?>
          </tbody>
        </table>
      </div>
    </section>
  <?php endif; ?>

  <?php endif; ?>
</main>

<?php include __DIR__ . '/../includes/footer.php'; ?>