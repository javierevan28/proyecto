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

// Función para obtener aspectos de inglés según el grado (NO según asignación)
function obtenerAspectosInglesPorGrado($db, $seccion, $grado) {
    $stmt = $db->prepare("
        SELECT id, nombre, orden FROM asignacion_ingles_aspectos 
        WHERE seccion = ? AND grado = ? AND asignacion_id IS NULL
        ORDER BY orden ASC
    ");
    $stmt->bind_param('si', $seccion, $grado);
    $stmt->execute();
    $result = $stmt->get_result();
    $aspectos = [];
    while ($row = $result->fetch_assoc()) {
        $aspectos[] = $row;
    }
    return $aspectos;
}

// Función para obtener alumnos con calificaciones de inglés por aspecto
function obtenerAlumnosInglesPorGrado($db, $asignacionId, $seccion, $grado, $grupo, $periodo, $aspectos) {
    // Obtener alumnos del grupo
    $stmtAl = $db->prepare("
        SELECT al.id AS alumno_id,
               al.nombre, al.apellido_paterno, al.apellido_materno,
               al.matricula
        FROM alumnos al
        WHERE al.seccion = ? AND al.grado = ? AND al.grupo = ? AND al.activo = 1
        ORDER BY al.apellido_paterno, al.apellido_materno, al.nombre
    ");
    $stmtAl->bind_param('sis', $seccion, $grado, $grupo);
    $stmtAl->execute();
    $alumnos = $stmtAl->get_result()->fetch_all(MYSQLI_ASSOC);
    
    // Para cada alumno obtener sus calificaciones por aspecto
    foreach ($alumnos as &$alumno) {
        $alumno['aspectos'] = [];
        foreach ($aspectos as $asp) {
            $stmtC = $db->prepare("
                SELECT calificacion FROM calificaciones_ingles
                WHERE alumno_id = ? AND aspecto_id = ? AND periodo = ?
                LIMIT 1
            ");
            $stmtC->bind_param('iii', $alumno['alumno_id'], $asp['id'], $periodo);
            $stmtC->execute();
            $resC = $stmtC->get_result()->fetch_assoc();
            $alumno['aspectos'][$asp['id']] = $resC['calificacion'] ?? null;
        }
    }
    
    return ['aspectos' => $aspectos, 'alumnos' => $alumnos];
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && $materiaActual) {
    if ((int)$materiaActual['es_ingles']) {
        $resultado = $calModelo->guardarCalificacionesIngles(
            $periodo, (int)$profesor['id'], $_POST['cal_ingles'] ?? []
        );
    } else {
        $resultado = $calModelo->guardarCalificaciones(
            $asignacionId, $periodo, (int)$profesor['id'], $_POST['cal'] ?? []
        );
    }
}

$alumnos  = [];
$aspectos = [];

if ($materiaActual) {
    if ((int)$materiaActual['es_ingles']) {
        // Obtener aspectos según el GRADO (no según asignación)
        $aspectos = obtenerAspectosInglesPorGrado($db, $seccion, $grado);
        $datos = obtenerAlumnosInglesPorGrado($db, $asignacionId, $seccion, $grado, $grupo, $periodo, $aspectos);
        $alumnos = $datos['alumnos'];
        $aspectos = $datos['aspectos'];
    } else {
        $alumnos = $calModelo->obtenerAlumnosConCalificacion($asignacionId, $seccion, $grado, $grupo, $periodo);
    }
}

$pageTitle = 'Captura — ' . ucfirst($seccion) . ' ' . $grado . '° ' . $grupo;
$backLabel = '← Mis grupos';
$backLink  = 'dashboard.php';
include __DIR__ . '/../includes/header.php';
?>

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

  <?php if (($_GET['msg'] ?? '') === 'importado'): ?>
    <p class="alert alert--success">✅ Calificaciones importadas correctamente desde Excel.</p>
  <?php elseif (($_GET['msg'] ?? '') === 'error'): ?>
    <p class="alert alert--error">⚠️ <?= htmlspecialchars($_GET['detalle'] ?? 'Error al importar') ?></p>
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
            <a class="btn btn--sm btn--accent"
               href="exportar_excel.php?asignacion_id=<?= $asignacionId ?>&seccion=<?= $seccion ?>&grado=<?= $grado ?>&grupo=<?= $grupo ?>&periodo=<?= $periodo ?>&es_ingles=<?= $materiaActual['es_ingles'] ?>">
              ⬇ Descargar Excel
            </a>
          </div>

          <form method="POST">
            <input type="hidden" name="asignacion_id" value="<?= $asignacionId ?>">

            <?php if ((int)$materiaActual['es_ingles'] && !empty($aspectos)): ?>
              <div class="table-responsive">
                <table class="data-table">
                  <thead>
                    <tr>
                      <th>#</th>
                      <th>Alumno</th>
                      <?php foreach ($aspectos as $asp): ?>
                        <th><?= htmlspecialchars($asp['nombre']) ?></th>
                      <?php endforeach; ?>
                      <th>Promedio</th>
                    </tr>
                  </thead>
                  <tbody>
                    <?php foreach ($alumnos as $i => $al): ?>
                      <?php
                        $suma  = 0; $count = 0;
                        foreach ($aspectos as $asp) {
                            $v = $al['aspectos'][$asp['id']] ?? null;
                            if ($v !== null) { $suma += $v; $count++; }
                        }
                        $promedio = $count > 0 ? round($suma / $count, 1) : '—';
                      ?>
                      <tr>
                        <td><?= $i + 1 ?></td>
                        <td><?= htmlspecialchars($al['apellido_paterno'] . ' ' . ($al['apellido_materno'] ?? '') . ', ' . $al['nombre']) ?></td>
                        <?php foreach ($aspectos as $asp): ?>
                          <td>
                            <input type="number"
                                   name="cal_ingles[<?= $al['alumno_id'] ?>][<?= $asp['id'] ?>]"
                                   value="<?= $al['aspectos'][$asp['id']] ?? '' ?>"
                                   min="0" max="10" step="1"
                                   class="cal-input">
                          </td>
                        <?php endforeach; ?>
                        <td><strong><?= $promedio ?></strong></td>
                      </tr>
                    <?php endforeach; ?>
                  </tbody>
                </table>
              </div>

            <?php else: ?>
              <div class="table-responsive">
                <table class="data-table">
                  <thead>
                    <tr>
                      <th>#</th>
                      <th>Alumno</th>
                      <th>Matrícula</th>
                      <th>Calificación</th>
                    </tr>
                  </thead>
                  <tbody>
                    <?php foreach ($alumnos as $i => $al): ?>
                      <tr>
                        <td><?= $i + 1 ?></td>
                        <td><?= htmlspecialchars($al['apellido_paterno'] . ' ' . ($al['apellido_materno'] ?? '') . ', ' . $al['nombre']) ?></td>
                        <td><span class="badge"><?= htmlspecialchars($al['matricula'] ?? '—') ?></span></td>
                        <td>
                          <input type="number"
                                 name="cal[<?= $al['alumno_id'] ?>]"
                                 value="<?= $al['calificacion'] ?? '' ?>"
                                 min="0" max="10" step="1"
                                 class="cal-input">
                        </td>
                      </tr>
                    <?php endforeach; ?>
                  </tbody>
                </table>
              </div>
            <?php endif; ?>

            <button class="btn" type="submit">💾 Guardar calificaciones</button>
          </form>

          <div class="upload-excel">
            <p class="form-hint">También puedes llenar el Excel descargado y subirlo aquí:</p>
            <form method="POST" action="importar_excel.php" enctype="multipart/form-data">
              <input type="hidden" name="asignacion_id" value="<?= $asignacionId ?>">
              <input type="hidden" name="periodo" value="<?= $periodo ?>">
              <input type="hidden" name="es_ingles" value="<?= $materiaActual['es_ingles'] ?>">
              <div class="upload-row">
                <input type="file" name="archivo_excel" accept=".xlsx,.xls">
                <button class="btn btn--sm btn--success" type="submit">⬆ Subir Excel</button>
              </div>
            </form>
          </div>
        </div>
      <?php endif; ?>
    </section>
  </div>
</main>

<?php include __DIR__ . '/../includes/footer.php'; ?>