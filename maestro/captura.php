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

// Verificar acceso al grupo
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

// ── POST: guardar calificaciones ──────────────────────────────
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
        $datos    = $calModelo->obtenerAlumnosIngles($asignacionId, $seccion, $grado, $grupo, $periodo);
        $alumnos  = $datos['alumnos'];
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

  <div class="ciclo-banner" style="margin-bottom:1.5rem;">
    <span class="ciclo-banner__label">
      📅 <?= htmlspecialchars($cicloActivo['nombre']) ?>
      &nbsp;|&nbsp; Periodo <?= $periodo ?>
      &nbsp;|&nbsp; Trimestre <?= (int)ceil($periodo / 2) ?>
      &nbsp;|&nbsp; <?= ucfirst($seccion) ?> <?= $grado ?>° <?= $grupo ?>
    </span>
  </div>

  <!-- Mensajes de guardado en pantalla -->
  <?php if ($resultado): ?>
    <?php if (isset($resultado['success'])): ?>
      <p class="alert alert--success" role="status">✅ Calificaciones guardadas correctamente.</p>
    <?php else: ?>
      <p class="alert alert--error" role="alert">⚠️ <?= htmlspecialchars($resultado['error']) ?></p>
    <?php endif; ?>
  <?php endif; ?>

  <!-- Mensajes de importación desde Excel -->
  <?php if (($_GET['msg'] ?? '') === 'importado'): ?>
    <p class="alert alert--success" role="status">✅ Calificaciones importadas correctamente desde Excel.</p>
  <?php elseif (($_GET['msg'] ?? '') === 'error'): ?>
    <p class="alert alert--error" role="alert">⚠️ <?= htmlspecialchars($_GET['detalle'] ?? 'Error al importar') ?></p>
  <?php endif; ?>

  <div style="display:grid; grid-template-columns:200px 1fr; gap:1.5rem; align-items:start;">

    <!-- ── Menú de materias ───────────────────────────────────── -->
    <section class="card" style="padding:1rem;">
      <h3 style="font-size:.9rem; color:var(--color-primary); margin-bottom:.8rem;">Mis materias</h3>
      <nav style="display:flex; flex-direction:column; gap:.4rem;">
        <?php foreach ($materias as $m): ?>
          <?php $activa = (int)$m['asignacion_id'] === $asignacionId; ?>
          <a href="captura.php?seccion=<?= $seccion ?>&grado=<?= $grado ?>&grupo=<?= $grupo ?>&asignacion_id=<?= $m['asignacion_id'] ?>"
             style="padding:.5rem .75rem; border-radius:var(--radius-sm); font-size:.85rem; text-decoration:none;
                    background:<?= $activa ? 'var(--color-primary)' : '#f1f5f9' ?>;
                    color:<?= $activa ? '#fff' : 'var(--color-text)' ?>;">
            <?= htmlspecialchars($m['materia_nombre']) ?>
            <?php if ((int)$m['es_titular']): ?>
              <span style="font-size:.7rem; opacity:.8;">(Titular)</span>
            <?php endif; ?>
          </a>
        <?php endforeach; ?>
      </nav>
    </section>

    <!-- ── Tabla de captura ──────────────────────────────────── -->
    <section>
      <?php if (!$materiaActual): ?>
        <p class="empty-state">Selecciona una materia para capturar calificaciones.</p>

      <?php elseif (empty($alumnos)): ?>
        <p class="empty-state">No hay alumnos registrados en este grupo.</p>

      <?php else: ?>
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1rem;">
          <h2 class="section-title" style="margin:0;">
            <?= htmlspecialchars($materiaActual['materia_nombre']) ?>
            — <?= count($alumnos) ?> alumnos
          </h2>
          <a class="btn btn--sm btn--accent"
             href="exportar_excel.php?asignacion_id=<?= $asignacionId ?>&seccion=<?= $seccion ?>&grado=<?= $grado ?>&grupo=<?= $grupo ?>&periodo=<?= $periodo ?>&es_ingles=<?= $materiaActual['es_ingles'] ?>">
            ⬇ Descargar Excel
          </a>
        </div>

        <form method="POST">
          <input type="hidden" name="asignacion_id" value="<?= $asignacionId ?>">

          <?php if ((int)$materiaActual['es_ingles'] && !empty($aspectos)): ?>
            <div style="overflow-x:auto;">
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
                                 style="width:55px; padding:.3rem; border:1px solid #ccd3db; border-radius:4px; font-size:.85rem; text-align:center;">
                        </td>
                      <?php endforeach; ?>
                      <td><strong><?= $promedio ?></strong></td>
                    </tr>
                  <?php endforeach; ?>
                </tbody>
              </table>
            </div>

          <?php else: ?>
            <table class="data-table">
              <thead>
                <tr>
                  <th>#</th>
                  <th>Alumno</th>
                  <th>Matrícula</th>
                  <th style="width:100px;">Calificación</th>
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
                             style="width:70px; padding:.3rem; border:1px solid #ccd3db; border-radius:4px; font-size:.9rem; text-align:center;">
                    </td>
                  </tr>
                <?php endforeach; ?>
              </tbody>
            </table>
          <?php endif; ?>

          <button class="btn" type="submit" style="margin-top:1rem;">
            💾 Guardar calificaciones
          </button>
        </form>

        <!-- Subir Excel -->
        <div style="margin-top:1rem; padding:1rem; background:#f8fafc; border-radius:var(--radius-sm); border:1px solid var(--color-border);">
          <p style="font-size:.85rem; color:var(--color-muted); margin-bottom:.5rem;">
            También puedes llenar el Excel descargado y subirlo aquí:
          </p>
          <form method="POST" action="importar_excel.php" enctype="multipart/form-data">
            <input type="hidden" name="asignacion_id" value="<?= $asignacionId ?>">
            <input type="hidden" name="periodo"       value="<?= $periodo ?>">
            <input type="hidden" name="es_ingles"     value="<?= $materiaActual['es_ingles'] ?>">
            <div style="display:flex; gap:.6rem; align-items:center; flex-wrap:wrap;">
              <input type="file" name="archivo_excel" accept=".xlsx,.xls" style="font-size:.85rem;">
              <button class="btn btn--sm btn--success" type="submit">⬆ Subir Excel</button>
            </div>
          </form>
        </div>

      <?php endif; ?>
    </section>

  </div>
</main>

<?php include __DIR__ . '/../includes/footer.php'; ?>