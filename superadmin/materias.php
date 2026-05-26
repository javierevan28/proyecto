<?php
// superadmin/materias.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/MateriaModel.php';
require_once __DIR__ . '/../models/CampoFormativoModel.php';
requireRol([1]);

$db             = getConexion();
$modelo         = new MateriaModel($db);
$campoModelo    = new CampoFormativoModel($db);

$resultado = null;
$editando  = null;
$accion    = $_GET['accion'] ?? '';
$editId    = (int)($_GET['id'] ?? 0);

// ── Acciones GET ──────────────────────────────────────────────
if ($accion === 'desactivar' && $editId > 0) {
    $resultado = $modelo->toggleActivo($editId, 0);
    $msg = isset($resultado['success']) ? 'desactivado' : 'error';
    header('Location: materias.php?msg=' . $msg . '&detalle=' . urlencode($resultado['error'] ?? ''));
    exit;
}

if ($accion === 'activar' && $editId > 0) {
    $resultado = $modelo->toggleActivo($editId, 1);
    $msg = isset($resultado['success']) ? 'activado' : 'error';
    header('Location: materias.php?msg=' . $msg . '&detalle=' . urlencode($resultado['error'] ?? ''));
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
$materias  = $modelo->listarTodos();
$campos    = $campoModelo->listarActivos(); // para el select

$pageTitle = 'Superadmin › Materias';
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
    <p class="alert alert--success" role="status">✅ Materia activada.</p>
  <?php elseif ($msgRedir === 'desactivado'): ?>
    <p class="alert alert--success" role="status">✅ Materia desactivada.</p>
  <?php elseif ($msgRedir === 'error'): ?>
    <p class="alert alert--error"   role="alert">⚠️ <?= htmlspecialchars($msgDetall) ?></p>
  <?php endif; ?>

  <div style="display:grid; grid-template-columns:1fr 1.6fr; gap:1.5rem; align-items:start;">

    <!-- ── Formulario ────────────────────────────────────────── -->
    <section class="card">
      <h2 class="section-title">
        <?= $editando ? '✏️ Editar materia' : '➕ Nueva materia' ?>
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
            placeholder="ej. Español" required maxlength="80"
          >
        </div>

        <!-- Campo formativo por defecto -->
        <div class="form-group">
          <label for="campo_formativo_id">Campo formativo (por defecto)</label>
          <select id="campo_formativo_id" name="campo_formativo_id">
            <option value="">Sin campo formativo</option>
            <?php foreach ($campos as $cf): ?>
              <?php
                $selVal = (int)($editando['campo_formativo_id']
                    ?? ($_POST['campo_formativo_id'] ?? 0));
              ?>
              <option value="<?= $cf['id'] ?>"
                <?= $selVal === (int)$cf['id'] ? 'selected' : '' ?>>
                <?= htmlspecialchars($cf['nombre']) ?>
              </option>
            <?php endforeach; ?>
          </select>
          <span class="form-hint">Se puede cambiar al hacer una asignación específica</span>
        </div>

        <!-- Tipo especial -->
        <div class="form-group">
          <label>Tipo especial</label>

          <div class="check-option">
            <input
              type="checkbox" id="es_ingles" name="es_ingles" value="1"
              <?= ($editando['es_ingles'] ?? ($_POST['es_ingles'] ?? 0)) ? 'checked' : '' ?>
              onchange="soloUno(this)"
            >
            <label for="es_ingles">Es materia de <strong>Inglés</strong> (tiene aspectos propios)</label>
          </div>

          <div class="check-option">
            <input
              type="checkbox" id="es_artes" name="es_artes" value="1"
              <?= ($editando['es_artes'] ?? ($_POST['es_artes'] ?? 0)) ? 'checked' : '' ?>
              onchange="soloUno(this)"
            >
            <label for="es_artes">Es materia de <strong>Artes</strong> (tiene subcomponentes)</label>
          </div>

          <div class="check-option">
            <input
              type="checkbox" id="es_higiene" name="es_higiene" value="1"
              <?= ($editando['es_higiene'] ?? ($_POST['es_higiene'] ?? 0)) ? 'checked' : '' ?>
              onchange="soloUno(this)"
            >
            <label for="es_higiene">Es <strong>Higiene</strong> (solo secundaria, sin campo formativo)</label>
          </div>

          <span class="form-hint">Deja todo sin marcar si es una materia normal</span>
        </div>

        <div style="display:flex; gap:.6rem; flex-wrap:wrap;">
          <button class="btn" type="submit">
            <?= $editando ? 'Guardar cambios' : 'Crear materia' ?>
          </button>
          <?php if ($editando): ?>
            <a class="btn btn--muted" href="materias.php">Cancelar</a>
          <?php endif; ?>
        </div>
      </form>
    </section>

    <!-- ── Listado ───────────────────────────────────────────── -->
    <section>
      <h2 class="section-title">Materias (<?= count($materias) ?>)</h2>

      <?php if (empty($materias)): ?>
        <p class="empty-state">Aún no hay materias registradas.</p>
      <?php else: ?>
        <table class="data-table">
          <thead>
            <tr>
              <th>Nombre</th>
              <th>Campo formativo</th>
              <th>Tipo</th>
              <th>Estado</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <?php foreach ($materias as $m): ?>
              <?php
                $esActivo   = (int)$m['activo'] === 1;
                $nombreSafe = htmlspecialchars($m['nombre']);
                $urlActivar = 'materias.php?accion=activar&id='    . $m['id'];
                $urlDesact  = 'materias.php?accion=desactivar&id=' . $m['id'];
                $urlEditar  = 'materias.php?accion=editar&id='     . $m['id'];

                if ((int)$m['es_ingles'])      $tipo = '<span class="badge">Inglés</span>';
                elseif ((int)$m['es_artes'])   $tipo = '<span class="badge">Artes</span>';
                elseif ((int)$m['es_higiene']) $tipo = '<span class="badge badge--warn">Higiene</span>';
                else                           $tipo = '<span class="badge" style="background:#f1f5f9;color:#64748b;">Normal</span>';
              ?>
              <tr>
                <td><strong><?= $nombreSafe ?></strong></td>
                <td>
                  <?= $m['campo_formativo_nombre']
                      ? htmlspecialchars($m['campo_formativo_nombre'])
                      : '<span style="color:var(--color-placeholder)">—</span>'
                  ?>
                </td>
                <td><?= $tipo ?></td>
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
                        data-title="Desactivar materia"
                        data-body="¿Confirmas desactivar &quot;<?= $nombreSafe ?>&quot;?">
                        Desactivar
                      </button>
                    <?php else: ?>
                      <button
                        class="btn btn--sm btn--success js-modal-trigger"
                        type="button"
                        data-href="<?= $urlActivar ?>"
                        data-title="Activar materia"
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