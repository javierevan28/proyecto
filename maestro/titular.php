<?php
// maestro/titular.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/ProfesorModel.php';
require_once __DIR__ . '/../models/UserModel.php';
require_once __DIR__ . '/../models/CicloModel.php';
require_once __DIR__ . '/../models/PeriodoAperturaModel.php';
require_once __DIR__ . '/../models/TitularModel.php';
requireRol([4]);

$db            = getConexion();
$profModelo    = new ProfesorModel($db, new UserModel($db));
$cicloModelo   = new CicloModel($db);
$periodoModelo = new PeriodoAperturaModel($db);
$titularModelo = new TitularModel($db);

$profesor = $profModelo->obtenerPorUserId((int)$_SESSION['user_id']);
if (!$profesor) { header('Location: /proyecto/login.php'); exit; }

$cicloActivo    = $cicloModelo->obtenerActivo();
$periodoAbierto = $cicloActivo
    ? $periodoModelo->obtenerAbierto((int)$cicloActivo['id'])
    : null;

if (!$cicloActivo || !$periodoAbierto) {
    header('Location: dashboard.php');
    exit;
}

$gruposTitular = $titularModelo->obtenerGruposTitular(
    (int)$profesor['id'],
    (int)$cicloActivo['id']
);

if (empty($gruposTitular)) {
    header('Location: dashboard.php');
    exit;
}

$seccion = trim($_GET['seccion'] ?? $gruposTitular[0]['seccion']);
$grado   = (int)($_GET['grado']  ?? $gruposTitular[0]['grado']);
$grupo   = trim($_GET['grupo']   ?? $gruposTitular[0]['grupo']);
$periodo = (int)$periodoAbierto['periodo'];

$tieneAcceso = false;
foreach ($gruposTitular as $g) {
    if ($g['seccion'] === $seccion && (int)$g['grado'] === $grado && $g['grupo'] === $grupo) {
        $tieneAcceso = true;
        break;
    }
}
if (!$tieneAcceso) {
    header('Location: dashboard.php');
    exit;
}

$esSecundaria = $seccion === 'secundaria';
$resultado    = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $resultado = $titularModelo->guardarCalificacionesTitular(
        (int)$cicloActivo['id'],
        $periodo,
        (int)$profesor['id'],
        $seccion,
        $_POST['datos'] ?? []
    );
}

$alumnos = $titularModelo->obtenerAlumnosConCalTitular(
    (int)$cicloActivo['id'], $seccion, $grado, $grupo, $periodo
);

$pageTitle = 'Titular — ' . ucfirst($seccion) . ' ' . $grado . '° ' . $grupo;
$backLabel = '← Mi panel';
$backLink  = 'dashboard.php';
include __DIR__ . '/../includes/header.php';
?>

<main class="container">

  <div class="ciclo-banner" style="margin-bottom:1.5rem;">
    <span class="ciclo-banner__label">
      📅 <?= htmlspecialchars($cicloActivo['nombre']) ?>
      &nbsp;|&nbsp; Periodo <?= $periodo ?>
      &nbsp;|&nbsp; Trimestre <?= (int)ceil($periodo / 2) ?>
      &nbsp;|&nbsp; <?= ucfirst($seccion) ?> <?= $grado ?>° <?= $grupo ?>
      &nbsp;|&nbsp; <strong>Titular</strong>
    </span>
  </div>

  <?php if ($resultado): ?>
    <?php if (isset($resultado['success'])): ?>
      <p class="alert alert--success" role="status">✅ Datos guardados correctamente.</p>
    <?php else: ?>
      <p class="alert alert--error" role="alert">⚠️ <?= htmlspecialchars($resultado['error']) ?></p>
    <?php endif; ?>
  <?php endif; ?>

  <?php if (count($gruposTitular) > 1): ?>
    <div style="margin-bottom:1rem; display:flex; gap:0.5rem; flex-wrap:wrap;">
      <?php foreach ($gruposTitular as $g): ?>
        <?php $activo = $g['seccion'] === $seccion && (int)$g['grado'] === $grado && $g['grupo'] === $grupo; ?>
        <a href="titular.php?seccion=<?= $g['seccion'] ?>&grado=<?= $g['grado'] ?>&grupo=<?= $g['grupo'] ?>"
           class="btn btn--sm <?= $activo ? 'btn--accent' : '' ?>"
           style="<?= !$activo ? 'background:#e2e8f0;color:#334155;' : '' ?>">
          <?= ucfirst($g['seccion']) ?> <?= $g['grado'] ?>° <?= $g['grupo'] ?>
        </a>
      <?php endforeach; ?>
    </div>
  <?php endif; ?>

  <section>
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1rem;">
      <h2 class="section-title" style="margin:0;">
        Captura de datos — <?= count($alumnos) ?> alumnos
      </h2>
      <div class="form-hint">
        Periodo <?= $periodo ?> | Trimestre <?= (int)ceil($periodo / 2) ?>
      </div>
    </div>

    <?php if (empty($alumnos)): ?>
      <p class="empty-state">No hay alumnos en este grupo.</p>
    <?php else: ?>

      <form method="POST">
        <div style="overflow-x:auto;">
          <table class="data-table">
            <thead>
              <tr>
                <th rowspan="2">#</th>
                <th rowspan="2" style="text-align:left;">Alumno</th>
                <th colspan="2">Evaluación del titular</th>
                <?php if ($esSecundaria): ?>
                  <th rowspan="2">Higiene</th>
                <?php endif; ?>
              </tr>
              <tr>
                <th>Socioemocional<br><small>0-10</small></th>
                <th>Ausencias<br><small>días del periodo</small></th>
                <th>Disciplina<br><small>0-10</small></th>
              </tr>
            </thead>
            <tbody>
              <?php foreach ($alumnos as $i => $al): ?>
                <tr>
                  <td style="text-align:center;"><?= $i + 1 ?></td>
                  <td style="text-align:left;">
                    <strong><?= htmlspecialchars(
                      $al['apellido_paterno'] . ' ' .
                      ($al['apellido_materno'] ?? '') . ', ' .
                      $al['nombre']
                    ) ?></strong>
                    <br><small class="form-hint"><?= htmlspecialchars($al['matricula'] ?? '') ?></small>
                  </td>
                  <td style="text-align:center;">
                    <input type="number"
                           name="datos[<?= $al['alumno_id'] ?>][socioemocional]"
                           value="<?= $al['socioemocional'] ?? '' ?>"
                           min="0" max="10" step="1"
                           style="width:70px; padding:0.4rem; border:1px solid #ccd3db; border-radius:4px; text-align:center;">
                  </td>
                  <td style="text-align:center; background:#fffbeb;">
                    <input type="number"
                           name="datos[<?= $al['alumno_id'] ?>][ausencias]"
                           value="<?= $al['ausencias'] ?? '' ?>"
                           min="0" max="31" step="1"
                           style="width:80px; padding:0.4rem; border:1px solid #ccd3db; border-radius:4px; text-align:center; background:#fff3e0;">
                    <div class="form-hint" style="color:#92400e;">total ausencias del periodo</div>
                  </td>
                  <td style="text-align:center;">
                    <input type="number"
                           name="datos[<?= $al['alumno_id'] ?>][disciplina]"
                           value="<?= $al['disciplina'] ?? '' ?>"
                           min="0" max="10" step="1"
                           style="width:70px; padding:0.4rem; border:1px solid #ccd3db; border-radius:4px; text-align:center;">
                  </td>
                  <?php if ($esSecundaria): ?>
                    <td style="text-align:center;">
                      <input type="number"
                             name="datos[<?= $al['alumno_id'] ?>][higiene]"
                             value="<?= $al['higiene'] ?? '' ?>"
                             min="0" max="10" step="1"
                             style="width:70px; padding:0.4rem; border:1px solid #ccd3db; border-radius:4px; text-align:center;">
                    </td>
                  <?php endif; ?>
                </tr>
              <?php endforeach; ?>
            </tbody>
          </table>
        </div>

        <div style="display:flex; gap:1rem; margin-top:1.5rem; justify-content:space-between; align-items:center;">
          <button class="btn" type="submit">💾 Guardar datos</button>
          <div class="form-hint">⚠️ Ausencias = total de días que faltó el alumno en este periodo</div>
        </div>
      </form>

    <?php endif; ?>
  </section>

  <div class="alert alert--info" style="margin-top:2rem;">
    <strong>📌 Leyenda:</strong><br>
    • <strong>Socioemocional</strong> - Calificación 0-10 sobre desarrollo socioemocional<br>
    • <strong>Ausencias</strong> - Número TOTAL de días que el alumno faltó en este periodo (máx 31)<br>
    • <strong>Disciplina</strong> - Calificación 0-10 sobre comportamiento en el aula<br>
    <?php if ($esSecundaria): ?>
    • <strong>Higiene</strong> - Calificación 0-10 sobre hábitos de higiene (solo secundaria)<br>
    <?php endif; ?>
    • Los datos se acumulan por periodo. Al final del ciclo se suman las ausencias.
  </div>

</main>

<?php include __DIR__ . '/../includes/footer.php'; ?>