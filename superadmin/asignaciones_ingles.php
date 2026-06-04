<?php
// superadmin/asignaciones_ingles.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/AsignacionModel.php';
require_once __DIR__ . '/../models/CicloModel.php';
require_once __DIR__ . '/../models/MateriaModel.php';
require_once __DIR__ . '/../models/CampoFormativoModel.php';
require_once __DIR__ . '/../models/ProfesorModel.php';
require_once __DIR__ . '/../models/ArteSubcomponenteModel.php';
require_once __DIR__ . '/../models/UserModel.php';
requireRol([1]);

$db            = getConexion();
$asigModelo    = new AsignacionModel($db);
$cicloModelo   = new CicloModel($db);
$materiaModelo = new MateriaModel($db);
$campoModelo   = new CampoFormativoModel($db);
$profModelo    = new ProfesorModel($db, new UserModel($db));
$artesModelo   = new ArteSubcomponenteModel($db);

$resultado = null;
$accion    = $_GET['accion'] ?? '';
$editId    = (int)($_GET['id'] ?? 0);

if ($accion === 'desactivar' && $editId > 0) {
    $resultado = $asigModelo->toggleActivo($editId, 0);
    $msg = isset($resultado['success']) ? 'desactivado' : 'error';
    header('Location: asignaciones_ingles.php?msg=' . $msg . '&detalle=' . urlencode($resultado['error'] ?? ''));
    exit;
}

if ($accion === 'activar' && $editId > 0) {
    $resultado = $asigModelo->toggleActivo($editId, 1);
    $msg = isset($resultado['success']) ? 'activado' : 'error';
    header('Location: asignaciones_ingles.php?msg=' . $msg . '&detalle=' . urlencode($resultado['error'] ?? ''));
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $resultado = $asigModelo->crearLote($_POST);
}

$msgRedir  = $_GET['msg']     ?? '';
$msgDetall = $_GET['detalle'] ?? '';

$cicloActivo = $cicloModelo->obtenerActivo();

// Obtener SOLO las materias de Inglés que están asignadas a este grado en grados_materias
$seccionSeleccionada = $_GET['seccion'] ?? '';
$gradoSeleccionado = $_GET['grado'] ?? '';
$grupoSeleccionado = $_GET['grupo'] ?? '';
$materiasForm = [];

if ($seccionSeleccionada && $gradoSeleccionado) {
    $stmt = $db->prepare("
        SELECT m.id, m.nombre, m.campo_formativo_id
        FROM grados_materias gm
        JOIN materias m ON m.id = gm.materia_id
        WHERE gm.seccion = ? AND gm.grado = ? AND m.es_ingles = 1
        ORDER BY gm.orden ASC
    ");
    $stmt->bind_param('si', $seccionSeleccionada, $gradoSeleccionado);
    $stmt->execute();
    $materiasForm = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
}

$campos         = $campoModelo->listarActivos();
$subcomps       = $artesModelo->listarActivos();
$titulares      = $profModelo->listarActivosPorTipo('titular');
$frances        = $profModelo->listarActivosPorTipo('frances');
$cocurriculares = $profModelo->listarActivosPorTipo('cocurricular');

$todasAsignaciones = $cicloActivo
    ? $asigModelo->listarPorCicloAgrupado((int)$cicloActivo['id'])
    : [];

$asignaciones = [];
foreach ($todasAsignaciones as $key => $grupo) {
    $grupoFiltrado = [];
    foreach ($grupo as $asignacion) {
        if ((int)$asignacion['es_ingles'] === 1) {
            $grupoFiltrado[] = $asignacion;
        }
    }
    if (!empty($grupoFiltrado)) {
        $asignaciones[$key] = $grupoFiltrado;
    }
}

$pageTitle = 'Superadmin › Asignaciones - Inglés';
$backLink  = 'dashboard.php';
$scripts   = ['/proyecto/js/modal.js'];
include __DIR__ . '/../includes/header.php';
?>

<div class="modal-overlay" id="modalOverlay" role="dialog" aria-modal="true" aria-labelledby="modalTitle" hidden>
  <div class="modal">
    <h3 class="modal__title" id="modalTitle"></h3>
    <p class="modal__body" id="modalBody"></p>
    <div class="modal__actions">
      <a class="btn modal__confirm" id="modalConfirm" href="#">Confirmar</a>
      <button class="btn modal__cancel" id="modalCancel" type="button">Cancelar</button>
    </div>
  </div>
</div>

<main class="container">

  <?php if ($resultado): ?>
    <?php if (isset($resultado['success'])): ?>
      <p class="alert alert--success">
        ✅ <?= $resultado['creadas'] ?> asignación(es) creada(s).
        <?= ($resultado['omitidas'] ?? 0) > 0 ? ($resultado['omitidas'] ?? 0) . ' ya existían y se actualizaron.' : '' ?>
      </p>
    <?php else: ?>
      <p class="alert alert--error">⚠️ <?= htmlspecialchars($resultado['error']) ?></p>
    <?php endif; ?>
  <?php endif; ?>

  <?php if ($msgRedir === 'activado'): ?>
    <p class="alert alert--success">✅ Asignación activada.</p>
  <?php elseif ($msgRedir === 'desactivado'): ?>
    <p class="alert alert--success">✅ Asignación desactivada.</p>
  <?php elseif ($msgRedir === 'error'): ?>
    <p class="alert alert--error">⚠️ <?= htmlspecialchars($msgDetall) ?></p>
  <?php endif; ?>

  <?php if (!$cicloActivo): ?>
    <p class="alert alert--error">
      ⚠️ No hay un ciclo escolar activo.
      <a href="ciclos_escolares.php">Configura uno primero</a>.
    </p>
  <?php else: ?>

  <div style="display:grid; grid-template-columns:1fr 1.8fr; gap:1.5rem; align-items:start;">

    <div class="card">
      <h2 class="section-title">➕ Nueva asignación - Inglés</h2>
      <p class="form-hint" style="margin-bottom:1rem;">
        Ciclo: <strong><?= htmlspecialchars($cicloActivo['nombre']) ?></strong>
      </p>

      <form method="GET" id="form-filtros" style="margin-bottom: 1rem;">
        <div class="form-group">
          <label for="seccion">Sección *</label>
          <select id="seccion" name="seccion" required onchange="this.form.submit()">
            <option value="">Selecciona…</option>
            <?php foreach (['maternal','preescolar','primaria','secundaria'] as $sec): ?>
              <option value="<?= $sec ?>" <?= $seccionSeleccionada === $sec ? 'selected' : '' ?>><?= ucfirst($sec) ?></option>
            <?php endforeach; ?>
          </select>
        </div>

        <div class="form-group">
          <label for="grado">Grado *</label>
          <select id="grado" name="grado" required onchange="this.form.submit()">
            <option value="">Selecciona…</option>
            <?php for ($i = 1; $i <= 6; $i++): ?>
              <option value="<?= $i ?>" <?= $gradoSeleccionado == $i ? 'selected' : '' ?>><?= $i ?>°</option>
            <?php endfor; ?>
          </select>
        </div>

        <div class="form-group">
          <label for="grupo">Grupo *</label>
          <select id="grupo" name="grupo" required onchange="this.form.submit()">
            <option value="">Selecciona…</option>
            <?php foreach (['A','B','C','D'] as $grp): ?>
              <option value="<?= $grp ?>" <?= $grupoSeleccionado === $grp ? 'selected' : '' ?>><?= $grp ?></option>
            <?php endforeach; ?>
          </select>
        </div>
      </form>

      <?php if ($seccionSeleccionada && $gradoSeleccionado && $grupoSeleccionado): ?>
        <form method="POST" id="form-asignacion" novalidate>
          <input type="hidden" name="ciclo_id" value="<?= $cicloActivo['id'] ?>">
          <input type="hidden" name="seccion" value="<?= $seccionSeleccionada ?>">
          <input type="hidden" name="grado" value="<?= $gradoSeleccionado ?>">
          <input type="hidden" name="grupo" value="<?= $grupoSeleccionado ?>">

          <hr class="separator">
          <p class="form-hint" style="margin-bottom:.8rem;">
            Selecciona las materias y asigna un maestro a cada una:
          </p>
          
          <?php if (empty($materiasForm)): ?>
            <p class="alert alert--warn">No hay materias de Inglés asignadas a este grado. Ve a "Materias por grado" y asigna materias de Inglés primero.</p>
          <?php else: ?>
            <?php foreach ($materiasForm as $m): ?>
              <div class="materia-bloque">
                <div class="materia-header">
                  <strong><?= htmlspecialchars($m['nombre']) ?></strong>
                  <span class="badge">Inglés</span>
                </div>
                <div class="form-group">
                  <label class="form-hint">Maestro asignado</label>
                  <select name="materia[<?= $m['id'] ?>][profesor_id]" class="form-control">
                    <option value="">Seleccionar maestro...</option>
                    <?php foreach ($titulares as $p): ?>
                      <option value="<?= $p['id'] ?>"><?= htmlspecialchars($p['apellido_paterno'] . ' ' . ($p['apellido_materno'] ?? '') . ', ' . $p['nombre']) ?></option>
                    <?php endforeach; ?>
                  </select>
                </div>
                <div class="check-option">
                  <input type="checkbox" name="materia[<?= $m['id'] ?>][es_titular]" value="1" id="titular_<?= $m['id'] ?>">
                  <label for="titular_<?= $m['id'] ?>">Es titular de este grupo</label>
                </div>
                <input type="hidden" name="materia[<?= $m['id'] ?>][campo_formativo_id]" value="<?= $m['campo_formativo_id'] ?? '' ?>">
                <input type="hidden" name="materia[<?= $m['id'] ?>][orden]" value="0">
              </div>
            <?php endforeach; ?>
            <button class="btn" type="submit">Guardar asignaciones</button>
          <?php endif; ?>
        </form>
      <?php endif; ?>
    </div>

    <div>
      <h2 class="section-title">
        Asignaciones — <?= htmlspecialchars($cicloActivo['nombre']) ?>
      </h2>

      <?php if (empty($asignaciones)): ?>
        <p class="empty-state">Aún no hay asignaciones de Inglés para este ciclo.</p>
      <?php else: ?>
        <?php foreach ($asignaciones as $key => $grupo): ?>
          <?php $primera = $grupo[0]; ?>
          <div style="margin-bottom:1.5rem;">
            <h3 style="font-size:.95rem; color:var(--color-primary); margin-bottom:.5rem;">
              📚 <?= ucfirst($primera['seccion']) ?> — <?= $primera['grado'] ?>° <?= $primera['grupo'] ?>
            </h3>
            <table class="data-table">
              <thead>
                <tr>
                  <th>Materia</th>
                  <th>Campo formativo</th>
                  <th>Maestro(s)</th>
                  <th>Estado</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <?php foreach ($grupo as $a): ?>
                  <?php
                    $esActivo   = (int)$a['activo'] === 1;
                    $nombreSafe = htmlspecialchars($a['materia_nombre']);
                    $urlActivar = 'asignaciones_ingles.php?accion=activar&id=' . $a['id'];
                    $urlDesact  = 'asignaciones_ingles.php?accion=desactivar&id=' . $a['id'];
                  ?>
                  <tr>
                    <td>
                      <strong><?= $nombreSafe ?></strong>
                      <span class="badge">Inglés</span>
                      <?php if ((int)($a['hay_titular'] ?? 0)): ?>
                        <span class="badge badge--active">Titular</span>
                      <?php endif; ?>
                    </td>
                    <td>
                      <?= $a['campo_formativo_nombre']
                          ? htmlspecialchars($a['campo_formativo_nombre'])
                          : '<span class="form-hint">—</span>'
                      ?>
                    </td>
                    <td style="font-size:.8rem;">
                      <?= $a['maestros']
                          ? htmlspecialchars($a['maestros'])
                          : '<span class="form-hint">Sin asignar</span>'
                      ?>
                    </td>
                    <td style="text-align:center;">
                      <?php if ($esActivo): ?>
                        <span class="badge badge--active">Activo</span>
                      <?php else: ?>
                        <span class="badge badge--warn">Inactivo</span>
                      <?php endif; ?>
                    </td>
                    <td style="text-align:center;">
                      <div class="table-actions">
                        <?php if ($esActivo): ?>
                          <button class="btn btn--sm btn--danger js-modal-trigger"
                                  data-href="<?= $urlDesact ?>"
                                  data-title="Desactivar asignación"
                                  data-body="¿Confirmas desactivar &quot;<?= $nombreSafe ?>&quot;?">
                            Desactivar
                          </button>
                        <?php else: ?>
                          <button class="btn btn--sm btn--success js-modal-trigger"
                                  data-href="<?= $urlActivar ?>"
                                  data-title="Activar asignación"
                                  data-body="¿Confirmas activar &quot;<?= $nombreSafe ?>&quot;?">
                            Activar
                          </button>
                        <?php endif; ?>
                      </div>
                    </td>
                  </tr>
                <?php endforeach; ?>
              </tbody>
            </table>
          </div>
        <?php endforeach; ?>
      <?php endif; ?>
    </div>

  </div>
  <?php endif; ?>
</main>

<?php include __DIR__ . '/../includes/footer.php'; ?>