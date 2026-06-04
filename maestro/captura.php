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
$periodoAbierto = $cicloActivo
    ? $periodoModelo->obtenerAbierto((int)$cicloActivo['id'])
    : null;

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

$materias      = $calModelo->obtenerMateriasDeProfesor(
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

function obtenerAspectosPorAsignacion($db, $asignacionId) {
    $stmt = $db->prepare("
        SELECT id, nombre, porcentaje, orden
        FROM asignacion_aspectos
        WHERE asignacion_id = ? AND activo = 1
        ORDER BY orden ASC
    ");
    $stmt->bind_param('i', $asignacionId);
    $stmt->execute();
    return $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
}

function obtenerAlumnosConCalificacionesPorAspecto($db, $asignacionId, $seccion, $grado, $grupo, $periodo, $aspectos) {
    $stmtAl = $db->prepare("
        SELECT al.id AS alumno_id,
               al.nombre, al.apellido_paterno, al.apellido_materno
        FROM alumnos al
        WHERE al.seccion = ? AND al.grado = ? AND al.grupo = ? AND al.activo = 1
        ORDER BY al.apellido_paterno, al.apellido_materno, al.nombre
    ");
    $stmtAl->bind_param('sis', $seccion, $grado, $grupo);
    $stmtAl->execute();
    $alumnos = $stmtAl->get_result()->fetch_all(MYSQLI_ASSOC);
    
    foreach ($alumnos as &$alumno) {
        $alumno['aspectos'] = [];
        foreach ($aspectos as $asp) {
            $stmtC = $db->prepare("
                SELECT calificacion FROM calificaciones
                WHERE alumno_id = ? AND aspecto_id = ? AND periodo = ?
                LIMIT 1
            ");
            $stmtC->bind_param('iii', $alumno['alumno_id'], $asp['id'], $periodo);
            $stmtC->execute();
            $res = $stmtC->get_result()->fetch_assoc();
            $alumno['aspectos'][$asp['id']] = $res['calificacion'] ?? null;
        }
        $suma = 0; $peso = 0;
        foreach ($aspectos as $asp) {
            $cal = $alumno['aspectos'][$asp['id']] ?? null;
            if ($cal !== null) {
                $suma += $cal * ($asp['porcentaje'] / 100);
                $peso += $asp['porcentaje'];
            }
        }
        $alumno['promedio'] = $peso > 0 ? round($suma) : null;
    }
    
    return $alumnos;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && $materiaActual) {
    $resultado = $calModelo->guardarCalificacionesPorAspecto(
        $asignacionId, $periodo, (int)$profesor['id'], $_POST['cal_aspectos'] ?? []
    );
}

$alumnos  = [];
$aspectos = [];

if ($materiaActual) {
    $aspectos = obtenerAspectosPorAsignacion($db, $asignacionId);
    $alumnos = obtenerAlumnosConCalificacionesPorAspecto($db, $asignacionId, $seccion, $grado, $grupo, $periodo, $aspectos);
}

$pageTitle = 'Captura — ' . ucfirst($seccion) . ' ' . $grado . '° ' . $grupo;
$backLabel = '← Mis grupos';
$backLink  = 'dashboard.php';
include __DIR__ . '/../includes/header.php';
?>

<style>
.table-aspectos {
    width: 100%;
    border-collapse: collapse;
    font-size: 0.7rem;
    min-width: 700px;
}
.table-aspectos th,
.table-aspectos td {
    border: 1px solid #e2e8f0;
    padding: 0.4rem 0.3rem;
    text-align: center;
    vertical-align: middle;
}
.table-aspectos th {
    background: #1e3a5f;
    color: white;
    font-weight: 600;
}
.table-aspectos .alumno-nombre {
    text-align: left;
}
.cal-input {
    width: 55px;
    padding: 0.2rem;
    text-align: center;
    border: 1px solid #ccd3db;
    border-radius: 4px;
    font-size: 0.7rem;
}
.promedio-cell {
    background: #d1fae5;
    font-weight: bold;
    color: #065f46;
}
.table-responsive {
    overflow-x: auto;
    margin-bottom: 1rem;
}
.captura-layout {
    display: flex;
    gap: 1rem;
}
.materias-sidebar {
    width: 280px;
    flex-shrink: 0;
}
.captura-main {
    flex: 1;
    min-width: 0;
}
@media (max-width: 768px) {
    .captura-layout {
        flex-direction: column;
    }
    .materias-sidebar {
        width: 100%;
    }
    .table-aspectos {
        min-width: 600px;
    }
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
    <?php if (isset($resultado['success'])): ?>
      <p class="alert alert--success">✅ Calificaciones guardadas correctamente.</p>
    <?php else: ?>
      <p class="alert alert--error">⚠️ <?= htmlspecialchars($resultado['error']) ?></p>
    <?php endif; ?>
  <?php endif; ?>

  <div class="captura-layout">
    <aside class="materias-sidebar">
      <div class="card">
        <h3 class="section-title" style="font-size:1rem;">Mis materias</h3>
        <nav class="materias-nav">
          <?php foreach ($materias as $m): ?>
            <?php $activa = (int)$m['asignacion_id'] === $asignacionId; ?>
            <a href="captura.php?seccion=<?= $seccion ?>&grado=<?= $grado ?>&grupo=<?= $grupo ?>&asignacion_id=<?= $m['asignacion_id'] ?>"
               class="materia-nav-link <?= $activa ? 'active' : '' ?>">
              <?= htmlspecialchars($m['materia_nombre']) ?>
              <?php if ((int)$m['es_titular']): ?>
                <span class="badge badge--active">Titular</span>
              <?php endif; ?>
            </a>
          <?php endforeach; ?>
        </nav>
      </div>
    </aside>

    <section class="captura-main">
      <?php if (!$materiaActual): ?>
        <div class="card">
          <p class="empty-state">Selecciona una materia del menú para capturar calificaciones.</p>
        </div>
      <?php elseif (empty($alumnos)): ?>
        <div class="card">
          <p class="empty-state">No hay alumnos registrados en este grupo.</p>
        </div>
      <?php else: ?>
        <div class="card">
          <div class="captura-header">
            <h2 class="section-title" style="margin:0;">
              <?= htmlspecialchars($materiaActual['materia_nombre']) ?>
              <span class="badge"><?= count($alumnos) ?> alumnos</span>
            </h2>
          </div>

          <form method="POST">
            <input type="hidden" name="asignacion_id" value="<?= $asignacionId ?>">

            <div class="table-responsive">
              <table class="table-aspectos">
                <thead>
                  <tr>
                    <th rowspan="2">#</th>
                    <th rowspan="2">Alumno</th>
                    <th colspan="<?= count($aspectos) ?>">Aspectos</th>
                    <th rowspan="2">Promedio Final</th>
                  </tr>
                  <tr>
                    <?php foreach ($aspectos as $asp): ?>
                      <th>
                        <?= htmlspecialchars($asp['nombre']) ?>
                        <br><small><?= $asp['porcentaje'] ?>%</small>
                      </th>
                    <?php endforeach; ?>
                  </tr>
                </thead>
                <tbody>
                  <?php $counter = 1; ?>
                  <?php foreach ($alumnos as $al): ?>
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

            <div style="margin-top: 1rem;">
              <button class="btn" type="submit">💾 Guardar calificaciones</button>
            </div>
          </form>
        </div>
      <?php endif; ?>
    </section>
  </div>
</main>

<?php include __DIR__ . '/../includes/footer.php'; ?>