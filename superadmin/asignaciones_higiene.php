<?php
// superadmin/asignaciones_higiene.php
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
    header('Location: asignaciones_higiene.php?msg=' . $msg . '&detalle=' . urlencode($resultado['error'] ?? ''));
    exit;
}

if ($accion === 'activar' && $editId > 0) {
    $resultado = $asigModelo->toggleActivo($editId, 1);
    $msg = isset($resultado['success']) ? 'activado' : 'error';
    header('Location: asignaciones_higiene.php?msg=' . $msg . '&detalle=' . urlencode($resultado['error'] ?? ''));
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $resultado = $asigModelo->crearLote($_POST);
}

$msgRedir  = $_GET['msg']     ?? '';
$msgDetall = $_GET['detalle'] ?? '';

$cicloActivo = $cicloModelo->obtenerActivo();

// FILTRAR materias disponibles: solo Higiene
$todasMaterias = $materiaModelo->listarActivas();
$materiasForm = array_filter($todasMaterias, function($m) {
    return (int)$m['es_higiene'] === 1;
});
$materiasForm = array_values($materiasForm);

$campos         = $campoModelo->listarActivos();
$subcomps       = $artesModelo->listarActivos();
$titulares      = $profModelo->listarActivosPorTipo('titular');
$frances        = $profModelo->listarActivosPorTipo('frances');
$cocurriculares = $profModelo->listarActivosPorTipo('cocurricular');

// Obtener TODAS las asignaciones y filtrar para mostrar solo Higiene
$todasAsignaciones = $cicloActivo
    ? $asigModelo->listarPorCicloAgrupado((int)$cicloActivo['id'])
    : [];

$asignaciones = [];
foreach ($todasAsignaciones as $key => $grupo) {
    $grupoFiltrado = [];
    foreach ($grupo as $asignacion) {
        if ((int)$asignacion['es_higiene'] === 1) {
            $grupoFiltrado[] = $asignacion;
        }
    }
    if (!empty($grupoFiltrado)) {
        $asignaciones[$key] = $grupoFiltrado;
    }
}

$jsonMaterias       = json_encode($materiasForm);
$jsonCampos         = json_encode($campos);
$jsonSubcomps       = json_encode($subcomps);
$jsonTitulares      = json_encode($titulares);
$jsonFrances        = json_encode($frances);
$jsonCocurriculares = json_encode($cocurriculares);

$pageTitle = 'Superadmin › Asignaciones - Higiene (solo secundaria)';
$backLink  = 'dashboard.php';
$scripts   = ['/proyecto/js/modal.js', '/proyecto/js/asignaciones.js'];
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

    <section class="card">
      <h2 class="section-title">➕ Nueva asignación - Higiene</h2>
      <p style="font-size:.82rem; color:var(--color-muted); margin-bottom:1rem;">
        Ciclo: <strong><?= htmlspecialchars($cicloActivo['nombre']) ?></strong>
      </p>
      <p class="alert alert--info">⚠️ Higiene solo aplica para <strong>secundaria</strong></p>

      <form method="POST" id="form-asignacion" novalidate>
        <input type="hidden" name="ciclo_id" value="<?= $cicloActivo['id'] ?>">

        <div class="form-group">
          <label for="seccion">Sección *</label>
          <select id="seccion" name="seccion" required>
            <option value="">Selecciona…</option>
            <option value="secundaria">Secundaria</option>
          </select>
        </div>

        <div class="form-group">
          <label for="grado">Grado *</label>
          <select id="grado" name="grado" required>
            <option value="">Selecciona…</option>
            <?php for ($i = 1; $i <= 6; $i++): ?>
              <option value="<?= $i ?>"><?= $i ?>°</option>
            <?php endfor; ?>
          </select>
        </div>

        <div class="form-group">
          <label for="grupo">Grupo *</label>
          <select id="grupo" name="grupo" required>
            <option value="">Selecciona…</option>
            <?php foreach (['A','B','C','D'] as $grp): ?>
              <option value="<?= $grp ?>"><?= $grp ?></option>
            <?php endforeach; ?>
          </select>
        </div>

        <div id="wrap-materias" hidden>
          <hr style="margin:1rem 0; border-color:var(--color-border);">
          <p style="font-size:.85rem; color:var(--color-muted); margin-bottom:.8rem;">
            Selecciona las materias y asigna un maestro a cada una:
          </p>
          <div id="lista-materias"></div>
        </div>

        <button class="btn" type="submit" id="btn-guardar" hidden>
          Guardar asignaciones
        </button>
      </form>
    </section>

    <section>
      <h2 class="section-title">
        Asignaciones — <?= htmlspecialchars($cicloActivo['nombre']) ?>
      </h2>

      <?php if (empty($asignaciones)): ?>
        <p class="empty-state">Aún no hay asignaciones de Higiene para este ciclo.</p>
      <?php else: ?>

        <?php foreach ($asignaciones as $key => $grupo): ?>
          <?php
            $primera = $grupo[0];
            $label   = ucfirst($primera['seccion']) . ' — ' .
                       $primera['grado'] . '° ' . $primera['grupo'];
          ?>
          <div style="margin-bottom:1.5rem;">
            <h3 style="font-size:.95rem; color:var(--color-primary); margin-bottom:.5rem;">
              📚 <?= $label ?>
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
                    $urlActivar = 'asignaciones_higiene.php?accion=activar&id='    . $a['id'];
                    $urlDesact  = 'asignaciones_higiene.php?accion=desactivar&id=' . $a['id'];
                  ?>
                  <tr>
                    <td>
                      <strong><?= $nombreSafe ?></strong>
                      <span class="badge badge--warn">Higiene</span>
                      <?php if ((int)($a['hay_titular'] ?? 0)): ?>
                        <span class="badge badge--active">Titular</span>
                      <?php endif; ?>
                    </td>
                    <td>
                      <?= $a['campo_formativo_nombre']
                          ? htmlspecialchars($a['campo_formativo_nombre'])
                          : '<span style="color:var(--color-placeholder)">—</span>'
                      ?>
                    </td>
                    <td style="font-size:.8rem;">
                      <?= $a['maestros']
                          ? htmlspecialchars($a['maestros'])
                          : '<span style="color:var(--color-placeholder)">Sin asignar</span>'
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
                          <button class="btn btn--sm btn--danger js-modal-trigger" data-href="<?= $urlDesact ?>" data-title="Desactivar" data-body="¿Desactivar <?= $nombreSafe ?>?">Desactivar</button>
                        <?php else: ?>
                          <button class="btn btn--sm btn--success js-modal-trigger" data-href="<?= $urlActivar ?>" data-title="Activar" data-body="¿Activar <?= $nombreSafe ?>?">Activar</button>
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
    </section>

  </div>
  <?php endif; ?>
</main>

<script>
const MATERIAS       = <?= $jsonMaterias ?>;
const CAMPOS         = <?= $jsonCampos ?>;
const SUBCOMPS       = <?= $jsonSubcomps ?>;
const TITULARES      = <?= $jsonTitulares ?>;
const FRANCES        = <?= $jsonFrances ?>;
const COCURRICULARES = <?= $jsonCocurriculares ?>;
</script>

<?php include __DIR__ . '/../includes/footer.php'; ?>