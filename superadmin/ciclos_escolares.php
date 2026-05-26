<?php
// superadmin/ciclos_escolares.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/CicloModel.php';
requireRol([1]);

$db         = getConexion();
$cicloModel = new CicloModel($db);

$resultado  = null;
$editando   = null;
$accion     = $_GET['accion'] ?? '';
$editId     = (int)($_GET['id'] ?? 0);

// ── Acciones GET (activar, eliminar, cargar edición) ──────────
if ($accion === 'activar' && $editId > 0) {
    $resultado = $cicloModel->activar($editId);
    $msg = isset($resultado['success']) ? 'activado' : 'error';
    header('Location: ciclos_escolares.php?msg=' . $msg . '&detalle=' . urlencode($resultado['error'] ?? ''));
    exit;
}

if ($accion === 'eliminar' && $editId > 0) {
    $resultado = $cicloModel->eliminar($editId);
    $msg = isset($resultado['success']) ? 'eliminado' : 'error';
    header('Location: ciclos_escolares.php?msg=' . $msg . '&detalle=' . urlencode($resultado['error'] ?? ''));
    exit;
}

if ($accion === 'editar' && $editId > 0) {
    $editando = $cicloModel->obtenerPorId($editId);
}

// ── Acciones POST (crear / guardar edición) ───────────────────
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $postId = (int)($_POST['id'] ?? 0);
    $resultado = $postId > 0
        ? $cicloModel->editar($postId, $_POST)
        : $cicloModel->crear($_POST);

    if (isset($resultado['success'])) {
        $editando = null;
    }
}

// Mensajes de redirección
$msgRedir  = $_GET['msg']     ?? '';
$msgDetall = $_GET['detalle'] ?? '';

// Lista actualizada
$ciclos = $cicloModel->listarTodos();

$pageTitle = 'Superadmin › Ciclos Escolares';
$backLink  = 'dashboard.php';
include __DIR__ . '/../includes/header.php';
?>

<!-- ══════════════════════════════════════════════════════════
     MODAL DE CONFIRMACIÓN
     Se muestra al hacer clic en Activar o Eliminar.
     data-href recibe la URL de acción; JS la asigna al botón Confirmar.
     ══════════════════════════════════════════════════════════ -->
<div class="modal-overlay" id="modalOverlay" role="dialog" aria-modal="true" aria-labelledby="modalTitle" hidden>
  <div class="modal">
    <h3 class="modal__title" id="modalTitle"></h3>
    <p  class="modal__body"  id="modalBody"></p>
    <div class="modal__actions">
      <a class="btn modal__confirm" id="modalConfirm" href="#">Confirmar</a>
      <button class="btn modal__cancel" id="modalCancel" type="button">Cancelar</button>
    </div>
  </div>
</div>

<main class="container">

  <!-- ── Mensajes de estado ──────────────────────────────────── -->
  <?php if ($resultado): ?>
    <?php if (isset($resultado['success'])): ?>
      <p class="alert alert--success" role="status">✅ Operación realizada correctamente.</p>
    <?php else: ?>
      <p class="alert alert--error"   role="alert">⚠️ <?= htmlspecialchars($resultado['error']) ?></p>
    <?php endif; ?>
  <?php endif; ?>

  <?php if ($msgRedir === 'activado'): ?>
    <p class="alert alert--success" role="status">✅ Ciclo activado correctamente.</p>
  <?php elseif ($msgRedir === 'eliminado'): ?>
    <p class="alert alert--success" role="status">✅ Ciclo eliminado correctamente.</p>
  <?php elseif ($msgRedir === 'error'): ?>
    <p class="alert alert--error"   role="alert">⚠️ <?= htmlspecialchars($msgDetall) ?></p>
  <?php endif; ?>

  <div style="display:grid; grid-template-columns:1fr 1.6fr; gap:1.5rem; align-items:start;">

    <!-- ── Formulario crear / editar ─────────────────────────── -->
    <section class="card">
      <h2 class="section-title">
        <?= $editando ? '✏️ Editar ciclo' : '➕ Nuevo ciclo escolar' ?>
      </h2>

      <form method="POST" novalidate>
        <?php if ($editando): ?>
          <input type="hidden" name="id" value="<?= $editando['id'] ?>">
        <?php endif; ?>

        <div class="form-group">
          <label for="nombre">Nombre del ciclo *</label>
          <input
            type="text" id="nombre" name="nombre"
            value="<?= htmlspecialchars($editando['nombre'] ?? ($_POST['nombre'] ?? '')) ?>"
            placeholder="ej. 2025-2026" required maxlength="30"
          >
          <span class="form-hint">Máximo 30 caracteres</span>
        </div>

        <div class="form-group">
          <label for="fecha_inicio">Fecha de inicio *</label>
          <input
            type="date" id="fecha_inicio" name="fecha_inicio"
            value="<?= htmlspecialchars($editando['fecha_inicio'] ?? ($_POST['fecha_inicio'] ?? '')) ?>"
            required
          >
        </div>

        <div class="form-group">
          <label for="fecha_fin">Fecha de fin *</label>
          <input
            type="date" id="fecha_fin" name="fecha_fin"
            value="<?= htmlspecialchars($editando['fecha_fin'] ?? ($_POST['fecha_fin'] ?? '')) ?>"
            required
          >
        </div>

        <div style="display:flex; gap:.6rem; flex-wrap:wrap;">
          <button class="btn" type="submit">
            <?= $editando ? 'Guardar cambios' : 'Crear ciclo' ?>
          </button>

          <?php if ($editando): ?>
            <a class="btn" href="ciclos_escolares.php"
               style="background:var(--color-muted);">
              Cancelar
            </a>
          <?php endif; ?>
        </div>
      </form>
    </section>

    <!-- ── Listado de ciclos ──────────────────────────────────── -->
    <section>
      <h2 class="section-title">Ciclos registrados (<?= count($ciclos) ?>)</h2>

      <?php if (empty($ciclos)): ?>
        <p class="empty-state">Aún no hay ciclos escolares registrados.</p>

      <?php else: ?>
        <table class="data-table">
          <thead>
            <tr>
              <th>Nombre</th>
              <th>Inicio</th>
              <th>Fin</th>
              <th>Estado</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <?php foreach ($ciclos as $c): ?>
              <?php
                $esActivo   = (int)$c['activo'] === 1;
                $nombreSafe = htmlspecialchars($c['nombre']);
                $urlActivar = 'ciclos_escolares.php?accion=activar&id=' . $c['id'];
                $urlEliminar= 'ciclos_escolares.php?accion=eliminar&id=' . $c['id'];
                $urlEditar  = 'ciclos_escolares.php?accion=editar&id='   . $c['id'];
              ?>
              <tr>
                <td><strong><?= $nombreSafe ?></strong></td>
                <td><?= date('d/m/Y', strtotime($c['fecha_inicio'])) ?></td>
                <td><?= date('d/m/Y', strtotime($c['fecha_fin']))    ?></td>
                <td>
                  <?php if ($esActivo): ?>
                    <span class="badge badge--active">✅ Activo</span>
                  <?php else: ?>
                    <span class="badge badge--warn">Inactivo</span>
                  <?php endif; ?>
                </td>
                <td>
                  <div class="table-actions">

                    <!-- Activar (solo si no está activo) -->
                    <?php if (!$esActivo): ?>
                      <button
                        class="btn btn--sm btn--success js-modal-trigger"
                        type="button"
                        data-href="<?= $urlActivar ?>"
                        data-title="Activar ciclo"
                        data-body="¿Confirmas activar el ciclo &quot;<?= $nombreSafe ?>&quot;? El ciclo actual quedará inactivo."
                      >
                        Activar
                      </button>
                    <?php endif; ?>

                    <!-- Editar -->
                    <a class="btn btn--sm btn--accent" href="<?= $urlEditar ?>">
                      Editar
                    </a>

                    <!-- Eliminar -->
                    <?php if ($esActivo): ?>
                      <!-- Deshabilitado visualmente si está activo -->
                      <span
                        class="btn btn--sm btn--disabled"
                        title="No puedes eliminar el ciclo activo">
                        Eliminar
                      </span>
                    <?php else: ?>
                      <button
                        class="btn btn--sm btn--danger js-modal-trigger"
                        type="button"
                        data-href="<?= $urlEliminar ?>"
                        data-title="Eliminar ciclo"
                        data-body="¿Confirmas eliminar el ciclo &quot;<?= $nombreSafe ?>&quot;? Esta acción no se puede deshacer."
                      >
                        Eliminar
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

<!-- ══════════════════════════════════════════════════════════
     ESTILOS DEL MODAL (scoped aquí, no tocan style.css global)
     ══════════════════════════════════════════════════════════ -->
<style>
/* Overlay oscuro que cubre toda la pantalla */
.modal-overlay {
  position: fixed;
  inset: 0;                          /* top/right/bottom/left = 0 */
  background: rgba(0, 0, 0, .45);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

/* hidden nativo oculta el overlay por defecto */
.modal-overlay[hidden] { display: none; }

/* Caja del modal */
.modal {
  background: var(--color-surface);
  border-radius: var(--radius);
  box-shadow: var(--shadow-lg);
  padding: 2rem 1.75rem;
  width: 100%;
  max-width: 400px;
  animation: modalIn .15s ease;
}

@keyframes modalIn {
  from { transform: translateY(-12px); opacity: 0; }
  to   { transform: translateY(0);     opacity: 1; }
}

.modal__title {
  font-size: 1.1rem;
  color: var(--color-primary);
  margin-bottom: .6rem;
}

.modal__body {
  font-size: .9rem;
  color: var(--color-muted);
  margin-bottom: 1.4rem;
  line-height: 1.5;
}

.modal__actions {
  display: flex;
  gap: .6rem;
  justify-content: flex-end;
}

/* Variantes de botón pequeño para la tabla */
.btn--sm      { padding: .32rem .7rem; font-size: .78rem; margin-top: 0; }
.btn--success { background: #065f46; }
.btn--success:hover { background: #047857; }
.btn--accent  { background: var(--color-accent); }
.btn--accent:hover  { background: #2563eb; }
.btn--danger  { background: #991b1b; }
.btn--danger:hover  { background: #7f1d1d; }
.btn--disabled {
  background: var(--color-placeholder);
  cursor: not-allowed;
  opacity: .7;
}

/* Cancelar con apariencia secundaria */
.modal__cancel {
  background: var(--color-muted);
}
.modal__cancel:hover {
  background: #475569;
}

/* Contenedor flex de los botones en cada fila de la tabla */
.table-actions {
  display: flex;
  gap: .4rem;
  flex-wrap: wrap;
}

/* Badge activo en verde */
.badge--active {
  background: #d1fae5;
  color: #065f46;
}
</style>

<!-- ══════════════════════════════════════════════════════════
     JS DEL MODAL — sin librerías externas
     ══════════════════════════════════════════════════════════ -->
<script>
(function () {
  const overlay  = document.getElementById('modalOverlay');
  const title    = document.getElementById('modalTitle');
  const body     = document.getElementById('modalBody');
  const confirm  = document.getElementById('modalConfirm');
  const cancel   = document.getElementById('modalCancel');

  // Abre el modal con los datos del botón pulsado
  function openModal(trigger) {
    title.textContent = trigger.dataset.title;
    body.innerHTML    = trigger.dataset.body;   // innerHTML para las comillas HTML
    confirm.href      = trigger.dataset.href;
    overlay.removeAttribute('hidden');
    cancel.focus();                             // accesibilidad: foco en Cancelar
  }

  // Cierra el modal
  function closeModal() {
    overlay.setAttribute('hidden', '');
    confirm.href = '#';
  }

  // Clic en cualquier botón con clase .js-modal-trigger
  document.addEventListener('click', function (e) {
    const trigger = e.target.closest('.js-modal-trigger');
    if (trigger) openModal(trigger);
  });

  // Cerrar con el botón Cancelar
  cancel.addEventListener('click', closeModal);

  // Cerrar al hacer clic fuera del modal (en el overlay)
  overlay.addEventListener('click', function (e) {
    if (e.target === overlay) closeModal();
  });

  // Cerrar con la tecla Escape
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') closeModal();
  });
})();
</script>