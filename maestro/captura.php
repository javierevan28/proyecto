<?php
// maestro/captura.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/ProfesorModel.php';
require_once __DIR__ . '/../models/UserModel.php';
require_once __DIR__ . '/../models/CicloModel.php';
require_once __DIR__ . '/../models/PeriodoAperturaModel.php';
require_once __DIR__ . '/../models/CalificacionModel.php';
requireRol([4]);

$db            = getConexion();
$profModelo    = new ProfesorModel($db, new UserModel($db));
$cicloModelo   = new CicloModel($db);
$periodoModelo = new PeriodoAperturaModel($db);
$calModelo     = new CalificacionModel($db);

$profesor = $profModelo->obtenerPorUserId((int)$_SESSION['user_id']);
if (!$profesor) {
    header('Location: /proyecto/login.php');
    exit;
}

$cicloActivo    = $cicloModelo->obtenerActivo();
$periodoAbierto = $cicloActivo ? $periodoModelo->obtenerAbierto((int)$cicloActivo['id']) : null;

if (!$cicloActivo || !$periodoAbierto) {
    header('Location: dashboard.php');
    exit;
}

$seccion = trim($_GET['seccion'] ?? '');
$grado   = (int)($_GET['grado']  ?? 0);
$grupo   = trim($_GET['grupo']   ?? '');
$periodo = (int)$periodoAbierto['periodo'];

if (!$seccion || !$grado || !$grupo) {
    header('Location: dashboard.php');
    exit;
}

// Verificar que el profesor tiene acceso a este grupo
$grupos      = $calModelo->obtenerGruposDeProfesor((int)$profesor['id'], (int)$cicloActivo['id']);
$tieneAcceso = false;
foreach ($grupos as $g) {
    if ($g['seccion'] === $seccion && (int)$g['grado'] === $grado && $g['grupo'] === $grupo) {
        $tieneAcceso = true;
        break;
    }
}
if (!$tieneAcceso) {
    header('Location: dashboard.php');
    exit;
}

// Materias del profesor en este grupo (incluye es_ausencias, es_disciplina)
$materias = $calModelo->obtenerMateriasDeProfesor(
    (int)$profesor['id'], (int)$cicloActivo['id'], $seccion, $grado, $grupo
);

$resultado     = null;
$materiaActual = null;
$asignacionId  = (int)($_GET['asignacion_id'] ?? $_POST['asignacion_id'] ?? 0);

if ($asignacionId > 0) {
    foreach ($materias as $m) {
        if ((int)$m['asignacion_id'] === $asignacionId) {
            $materiaActual = $m;
            break;
        }
    }
}

// ── POST ───────────────────────────────────────────────────────
if ($_SERVER['REQUEST_METHOD'] === 'POST' && $materiaActual) {
    if (!empty($materiaActual['es_ausencias'])) {
        $resultado = $calModelo->guardarAusencias(
            (int)$cicloActivo['id'], $periodo, (int)$profesor['id'],
            $_POST['dias'] ?? []
        );
    } else {
        $resultado = $calModelo->guardarCalificacionesPorAspecto(
            $asignacionId, $periodo, (int)$profesor['id'],
            $_POST['cal_aspectos'] ?? []
        );
    }
}

// ── GET / preparar datos ───────────────────────────────────────
$alumnos     = [];
$aspectos    = [];
$esAusencias = false;

if ($materiaActual) {
    if (!empty($materiaActual['es_ausencias'])) {
        // Solo lista de alumnos + número de días — sin aspectos
        $alumnos     = $calModelo->obtenerAusencias(
            (int)$cicloActivo['id'], $periodo, $seccion, $grado, $grupo
        );
        $esAusencias = true;
    } else {
        $data     = $calModelo->obtenerAlumnosConCalificacionesPorAspecto(
            $asignacionId, $seccion, $grado, $grupo, $periodo
        );
        $aspectos = $data['aspectos'];
        $alumnos  = $data['alumnos'];
    }
}

$pageTitle = 'Captura — ' . ucfirst($seccion) . ' ' . $grado . '° ' . $grupo;
$backLabel  = '← Mis grupos';
$backLink   = 'dashboard.php';
include __DIR__ . '/../includes/header.php';
?>

<style>
.table-aspectos { width:100%; border-collapse:collapse; font-size:0.7rem; min-width:700px; }
.table-aspectos th,
.table-aspectos td { border:1px solid #e2e8f0; padding:0.4rem 0.3rem; text-align:center; vertical-align:middle; }
.table-aspectos th { background:#1e3a5f; color:white; font-weight:600; }
.table-aspectos .alumno-nombre { text-align:left; }
.cal-input { width:55px; padding:0.2rem; text-align:center; border:1px solid #ccd3db; border-radius:4px; font-size:0.7rem; }
.aus-input { width:70px; padding:0.3rem; text-align:center; border:1px solid #ccd3db; border-radius:4px; font-size:0.85rem; }
.promedio-cell { background:#d1fae5; font-weight:bold; color:#065f46; }
.table-responsive { overflow-x:auto; margin-bottom:1rem; }
.captura-layout { display:flex; gap:1rem; }
.materias-sidebar { width:280px; flex-shrink:0; }
.captura-main { flex:1; min-width:0; }
.data-table { width:100%; border-collapse:collapse; }
.data-table th,
.data-table td { border:1px solid #e2e8f0; padding:0.5rem 0.6rem; text-align:left; }
.data-table th { background:#1e3a5f; color:white; font-weight:600; }
.data-table td:last-child { text-align:center; }
@media (max-width:768px) {
    .captura-layout { flex-direction:column; }
    .materias-sidebar { width:100%; }
    .table-aspectos { min-width:600px; }
}
</style>

<main class="container">

  <div class="ciclo-banner">
    <span class="ciclo-banner__label">
      📅 <?= htmlspecialchars($cicloActivo['nombre']) ?>
      &nbsp;|&nbsp; Periodo <?= $periodo ?>
      &nbsp;|&nbsp; Trimestre <?= (int)ceil($periodo / 2) ?>
      &nbsp;|&nbsp; <?= ucfirst($seccion) ?> <?= $grado ?>° <?= $grupo ?>
    </span>
  </div>

  <?php if ($resultado): ?>
    <p class="alert alert--<?= isset($resultado['success']) ? 'success' : 'error' ?>">
      <?= isset($resultado['success'])
          ? '✅ Guardado correctamente.'
          : '⚠️ ' . htmlspecialchars($resultado['error']) ?>
    </p>
  <?php endif; ?>

  <div class="captura-layout">

    <!-- ── Sidebar materias ── -->
    <aside class="materias-sidebar">
      <div class="card">
        <h3 class="section-title" style="font-size:1rem;">Mis materias</h3>
        <nav class="materias-nav">
          <?php foreach ($materias as $m): ?>
            <a href="captura.php?seccion=<?= $seccion ?>&grado=<?= $grado ?>&grupo=<?= $grupo ?>&asignacion_id=<?= $m['asignacion_id'] ?>"
               class="materia-nav-link <?= ((int)$m['asignacion_id'] === $asignacionId) ? 'active' : '' ?>">
              <?= htmlspecialchars($m['materia_nombre']) ?>
              <?php if (!empty($m['es_titular'])): ?>
                <span class="badge badge--active">Titular</span>
              <?php endif; ?>
            </a>
          <?php endforeach; ?>
        </nav>
      </div>
    </aside>

    <!-- ── Área principal ── -->
    <section class="captura-main">

      <?php if (!$materiaActual): ?>
        <div class="card">
          <p class="empty-state">Selecciona una materia del menú para capturar calificaciones.</p>
        </div>

      <?php elseif ($esAusencias): ?>
        <!-- ──────────────── AUSENCIAS ──────────────── -->
        <div class="card">
          <h2 class="section-title">
            <?= htmlspecialchars($materiaActual['materia_nombre']) ?>
            <span class="badge"><?= count($alumnos) ?> alumnos</span>
          </h2>

          <form method="POST">
            <input type="hidden" name="asignacion_id" value="<?= $asignacionId ?>">
            <table class="data-table">
              <thead>
                <tr>
                  <th>#</th>
                  <th>Alumno</th>
                  <th style="text-align:center;">Días de ausencia</th>
                </tr>
              </thead>
              <tbody>
                <?php $c = 1; foreach ($alumnos as $al): ?>
                <tr>
                  <td><?= $c++ ?></td>
                  <td><?= htmlspecialchars($al['apellido_paterno'] . ' ' . ($al['apellido_materno'] ?? '') . ', ' . $al['nombre']) ?></td>
                  <td>
                    <input type="number"
                           name="dias[<?= $al['alumno_id'] ?>]"
                           value="<?= (int)$al['dias'] ?>"
                           min="0" max="31"
                           class="aus-input">
                  </td>
                </tr>
                <?php endforeach; ?>
              </tbody>
            </table>
            <div style="margin-top:1rem;">
              <button type="submit" class="btn">💾 Guardar ausencias</button>
            </div>
          </form>
        </div>

      <?php elseif (empty($alumnos)): ?>
        <div class="card">
          <p class="empty-state">No hay alumnos registrados en este grupo.</p>
        </div>

      <?php else: ?>
        <!-- ──────────────── CALIFICACIONES (normal / disciplina) ──────────────── -->
        <div class="card">
          <h2 class="section-title" style="margin:0 0 1rem;">
            <?= htmlspecialchars($materiaActual['materia_nombre']) ?>
            <span class="badge"><?= count($alumnos) ?> alumnos</span>
          </h2>

          <form method="POST">
            <input type="hidden" name="asignacion_id" value="<?= $asignacionId ?>">
            <div class="table-responsive">
              <table class="table-aspectos">
                <thead>
                  <tr>
                    <th rowspan="2">#</th>
                    <th rowspan="2">Alumno</th>
                    <th colspan="<?= count($aspectos) ?>">Aspectos</th>
                    <th rowspan="2">Promedio</th>
                  </tr>
                  <tr>
                    <?php foreach ($aspectos as $asp): ?>
                      <th>
                        <?= htmlspecialchars($asp['nombre']) ?>
                        <?php if (isset($asp['porcentaje'])): ?>
                          <br><small><?= $asp['porcentaje'] ?>%</small>
                        <?php endif; ?>
                      </th>
                    <?php endforeach; ?>
                  </tr>
                </thead>
                <tbody>
                  <?php $counter = 1; foreach ($alumnos as $al): ?>
                  <tr>
                    <td><?= $counter++ ?></td>
                    <td class="alumno-nombre"><?= htmlspecialchars($al['apellido_paterno'] . ' ' . ($al['apellido_materno'] ?? '') . ', ' . $al['nombre']) ?></td>
                    <?php foreach ($aspectos as $asp): ?>
                    <td>
                      <input type="number"
                             name="cal_aspectos[<?= $al['alumno_id'] ?>][<?= $asp['id'] ?>]"
                             value="<?= $al['aspectos'][$asp['id']] ?? '' ?>"
                             min="0" max="10" step="0.1"
                             class="cal-input">
                    </td>
                    <?php endforeach; ?>
                    <td class="promedio-cell"><strong><?= $al['promedio'] ?? '—' ?></strong></td>
                  </tr>
                  <?php endforeach; ?>
                </tbody>
              </table>
            </div>
            <div style="margin-top:1rem;">
              <button type="submit" class="btn">💾 Guardar calificaciones</button>
            </div>
          </form>
        </div>
      <?php endif; ?>

    </section>
  </div>
</main>

<?php include __DIR__ . '/../includes/footer.php'; ?>