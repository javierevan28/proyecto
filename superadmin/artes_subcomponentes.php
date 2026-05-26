<?php
// superadmin/artes_subcomponentes.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/ArteSubcomponenteModel.php';
requireRol([1]);

$db     = getConexion();
$modelo = new ArteSubcomponenteModel($db);

$resultado = null;
$editando  = null;
$accion    = $_GET['accion'] ?? '';
$editId    = (int)($_GET['id'] ?? 0);

// ── Acciones GET ──────────────────────────────────────────────
if ($accion === 'desactivar' && $editId > 0) {
    $resultado = $modelo->toggleActivo($editId, 0);
    $msg = isset($resultado['success']) ? 'desactivado' : 'error';
    header('Location: artes_subcomponentes.php?msg=' . $msg . '&detalle=' . urlencode($resultado['error'] ?? ''));
    exit;
}

if ($accion === 'activar' && $editId > 0) {
    $resultado = $modelo->toggleActivo($editId, 1);
    $msg = isset($resultado['success']) ? 'activado' : 'error';
    header('Location: artes_subcomponentes.php?msg=' . $msg . '&detalle=' . urlencode($resultado['error'] ?? ''));
    exit;
}

if ($accion === 'editar' && $editId > 0) {
    $editando = $modelo->obtenerPorId($editId);
}

// ── Acciones POST ─────────────────────────────────────────────
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $postId    = (int)($_POST['id'] ?? 0);
    $resultado = $postId > 0
        ? $modelo->editar($postId, $_POST)
        : $modelo->crear($_POST);

    if (isset($resultado['success'])) {
        $editando = null;
    }
}

$msgRedir  = $_GET['msg']     ?? '';
$msgDetall = $_GET['detalle'] ?? '';
$subcomps  = $modelo->listarTodos();

$pageTitle = 'Superadmin › Subcomponentes de Artes';
$backLink  = 'dashboard.php';
$scripts   = ['/proyecto/js/modal.js'];
include __DIR__ . '/../includes/header.php';
?>

<!-- Modal de confirmación -->
<div class="modal-overlay" id="modalOverlay" role="dialog" aria-modal="true" aria-labelledby="modalTitle" hidden>
  <div class="modal">
    <h3 class="modal__title" id="modalTitle"></h3>
    <p  class="modal__body"  id="modalBody"></p>
    <div class="modal__actions">
      <a      class="btn modal__confirm" id="modalConfirm" href="#">Confirmar</a>
      <button class="btn modal__cancel"  id="modalCancel"  type="button">Cancelar</button>
    </div>
  </div>
</div>

<main class="container">

  <!-- ── Mensajes ──────────────────────────────────────────────── -->
  <?php if ($resultado): ?>
    <?php if (isset($resultado['success'])): ?>
      <p class="alert alert--success" role="status">✅ Operación realizada correctamente.</p>
    <?php else: ?>
      <p class="alert alert--error"   role="alert">⚠️ <?= htmlspecialchars($resultado['error']) ?></p>
    <?php endif; ?>
  <?php endif; ?>

  <?php if ($msgRedir === 'activado'): ?>
    <p class="alert alert--success" role="status">✅ Subcomponente activado.</p>
  <?php elseif ($msgRedir === 'desactivado'): ?>
    <p class="alert alert--success" role="status">✅ Subcomponente desactivado.</p>
  <?php elseif ($msgRedir === 'error'): ?>
    <p class="alert alert--error"   role="alert">⚠️ <?= htmlspecialchars($msgDetall) ?></p>
  <?php endif; ?>

  <div style="display:grid; grid-template-columns:1fr 1.6fr; gap:1.5rem; align-items:start;">

    <!-- ── Formulario ────────────────────────────────────────── -->
    <section class="card">
      <h2 class="section-title">
        <?= $editando ? '✏️ Editar subcomponente' : '➕ Nuevo subcomponente de Artes' ?>
      </h2>

      <form method="POST" novalidate>
        <?php if ($editando): ?>
          <input type="hidden" name="id" value="<?= $editando['id'] ?>">
        <?php endif; ?>

        <div class="form-group">
          <label for="nombre">Nombre *</label>
          <input
            type="text" id="nombre" name="nombre"
            value="<?= htmlspecialchars($editando['nombre'] ?? ($_POST['nombre'] ?? '')) ?>"
            placeholder="ej. Danza" required maxlength="100"
          >
        </div>

        <div class="form-group">
          <label for="orden">Orden en la boleta *</label>
          <input
            type="number" id="orden" name="orden" min="0"
            value="<?= htmlspecialchars((string)($editando['orden'] ?? ($_POST['orden'] ?? '0'))) ?>"
            required
          >
          <span class="form-hint">Número menor aparece primero en la boleta</span>
        </div>

        <div style="display:flex; gap:.6rem; flex-wrap:wrap;">
          <button class="btn" type="submit">
            <?= $editando ? 'Guardar cambios' : 'Crear subcomponente' ?>
          </button>
          <?php if ($editando): ?>
            <a class="btn btn--muted" href="artes_subcomponentes.php">Cancelar</a>
          <?php endif; ?>
        </div>
      </form>
    </section>

    <!-- ── Listado ───────────────────────────────────────────── -->
    <section>
      <h2 class="section-title">Subcomponentes (<?= count($subcomps) ?>)</h2>

      <?php if (empty($subcomps)): ?>
        <p class="empty-state">Aún no hay subcomponentes registrados.</p>
      <?php else: ?>
        <table class="data-table">
          <thead>
            <tr>
              <th>Orden</th>
              <th>Nombre</th>
              <th>Estado</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <?php foreach ($subcomps as $s): ?>
              <?php
                $esActivo   = (int)$s['activo'] === 1;
                $nombreSafe = htmlspecialchars($s['nombre']);
                $urlActivar = 'artes_subcomponentes.php?accion=activar&id='    . $s['id'];
                $urlDesact  = 'artes_subcomponentes.php?accion=desactivar&id=' . $s['id'];
                $urlEditar  = 'artes_subcomponentes.php?accion=editar&id='     . $s['id'];
              ?>
              <tr>
                <td><?= $s['orden'] ?></td>
                <td><strong><?= $nombreSafe ?></strong></td>
                <td>
                  <?php if ($esActivo): ?>
                    <span class="badge badge--active">Activo</span>
                  <?php else: ?>
                    <span class="badge badge--warn">Inactivo</span>
                  <?php endif; ?>
                </td>
                <td>
                  <div class="table-actions">

                    <a class="btn btn--sm btn--accent" href="<?= $urlEditar ?>">
                      Editar
                    </a>

                    <?php if ($esActivo): ?>
                      <button
                        class="btn btn--sm btn--danger js-modal-trigger"
                        type="button"
                        data-href="<?= $urlDesact ?>"
                        data-title="Desactivar subcomponente"
                        data-body="¿Confirmas desactivar &quot;<?= $nombreSafe ?>&quot;?">
                        Desactivar
                      </button>
                    <?php else: ?>
                      <button
                        class="btn btn--sm btn--success js-modal-trigger"
                        type="button"
                        data-href="<?= $urlActivar ?>"
                        data-title="Activar subcomponente"
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
      <?php endif; ?>
    </section>

  </div><!-- /.grid -->
</main>

<?php include __DIR__ . '/../includes/footer.php'; ?>