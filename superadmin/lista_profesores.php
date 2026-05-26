<?php
// superadmin/lista_profesores.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/UserModel.php';
require_once __DIR__ . '/../models/ProfesorModel.php';
requireRol([1]);

$db            = getConexion();
$profesorModel = new ProfesorModel($db, new UserModel($db));

$resultado = null;

// Activar / desactivar profesor
$accion = $_GET['accion'] ?? '';
$id     = (int)($_GET['id'] ?? 0);

if ($accion === 'desactivar' && $id > 0) {
    $resultado = $profesorModel->toggleActivo($id, 0);
    header('Location: lista_profesores.php?msg=' . (isset($resultado['success']) ? 'desactivado' : 'error'));
    exit;
}

if ($accion === 'activar' && $id > 0) {
    $resultado = $profesorModel->toggleActivo($id, 1);
    header('Location: lista_profesores.php?msg=' . (isset($resultado['success']) ? 'activado' : 'error'));
    exit;
}

$msg       = $_GET['msg'] ?? '';
$profesores = $profesorModel->listarTodos();

$pageTitle = 'Superadmin › Profesores';
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

  <!-- Mensajes de estado -->
  <?php if ($msg === 'activado'): ?>
    <p class="alert alert--success" role="status">✅ Profesor activado correctamente.</p>
  <?php elseif ($msg === 'desactivado'): ?>
    <p class="alert alert--success" role="status">✅ Profesor desactivado correctamente.</p>
  <?php elseif ($msg === 'error'): ?>
    <p class="alert alert--error" role="alert">⚠️ Ocurrió un error al actualizar el profesor.</p>
  <?php endif; ?>

  <h2 class="section-title">
    Profesores registrados (<?= count($profesores) ?>)
  </h2>

  <?php if (empty($profesores)): ?>
    <p class="empty-state">Aún no hay profesores registrados.</p>
  <?php else: ?>
    <table class="data-table">
      <thead>
        <tr>
          <th>#</th>
          <th>Nombre completo</th>
          <th>Usuario</th>
          <th>Teléfono</th>
          <th>Correo</th>
          <th>Género</th>
          <th>Estado</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <?php foreach ($profesores as $i => $p): ?>
          <?php
            $esActivo    = (int)$p['activo'] === 1;
            $nombreSafe  = htmlspecialchars($p['apellido_paterno'] . ' ' . ($p['apellido_materno'] ?? '') . ', ' . $p['nombre']);
            $urlActivar  = 'lista_profesores.php?accion=activar&id='    . $p['id'];
            $urlDesact   = 'lista_profesores.php?accion=desactivar&id=' . $p['id'];
          ?>
          <tr>
            <td><?= $i + 1 ?></td>
            <td><?= htmlspecialchars($p['apellido_paterno'] . ' ' . ($p['apellido_materno'] ?? '') . ', ' . $p['nombre']) ?></td>
            <td><span class="badge"><?= htmlspecialchars($p['username']) ?></span></td>
            <td><?= htmlspecialchars($p['telefono'] ?? '—') ?></td>
            <td><?= htmlspecialchars($p['correo']   ?? '—') ?></td>
            <td><?= ucfirst($p['genero']) ?></td>
            <td>
              <?php if ($esActivo): ?>
                <span class="badge badge--active">Activo</span>
              <?php else: ?>
                <span class="badge badge--warn">Inactivo</span>
              <?php endif; ?>
            </td>
            <td>
              <div class="table-actions">
                <?php if ($esActivo): ?>
                  <button
                    class="btn btn--sm btn--danger js-modal-trigger"
                    type="button"
                    data-href="<?= $urlDesact ?>"
                    data-title="Desactivar profesor"
                    data-body="¿Confirmas desactivar a &quot;<?= $nombreSafe ?>&quot;? No podrá iniciar sesión.">
                    Desactivar
                  </button>
                <?php else: ?>
                  <button
                    class="btn btn--sm btn--success js-modal-trigger"
                    type="button"
                    data-href="<?= $urlActivar ?>"
                    data-title="Activar profesor"
                    data-body="¿Confirmas activar a &quot;<?= $nombreSafe ?>&quot;?">
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

</main>

<?php include __DIR__ . '/../includes/footer.php'; ?>