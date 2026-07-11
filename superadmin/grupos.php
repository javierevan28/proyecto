<?php
// superadmin/grupos.php

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
requireRol([1]);

$db = getConexion();

$resultado = null;
$editando = null;
$accion = $_GET['accion'] ?? '';
$editId = (int)($_GET['id'] ?? 0);

$secciones = ['maternal', 'preescolar', 'primaria', 'secundaria'];
$gradosPorSeccion = [
    'maternal'   => [1, 2, 3],
    'preescolar' => [1, 2, 3],
    'primaria'   => [1, 2, 3, 4, 5, 6],
    'secundaria' => [1, 2, 3]
];

$seccionActual = $_GET['seccion'] ?? 'primaria';
$gradoActual = (int)($_GET['grado'] ?? 1);

// ============================================================
// FUNCIONES
// ============================================================

function listarGruposPorGrado(mysqli $db, string $seccion, int $grado, bool $soloActivos = true): array {
    $sql = "SELECT id, seccion, grado, nombre, activo 
            FROM grupos_catalogo 
            WHERE seccion = ? AND grado = ?";
    if ($soloActivos) {
        $sql .= " AND activo = 1";
    }
    $sql .= " ORDER BY nombre ASC";
    
    $stmt = $db->prepare($sql);
    $stmt->bind_param('si', $seccion, $grado);
    $stmt->execute();
    return $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
}

function obtenerGrupoPorId(mysqli $db, int $id): ?array {
    $stmt = $db->prepare("SELECT id, seccion, grado, nombre, activo FROM grupos_catalogo WHERE id = ? LIMIT 1");
    $stmt->bind_param('i', $id);
    $stmt->execute();
    $res = $stmt->get_result();
    return $res->num_rows > 0 ? $res->fetch_assoc() : null;
}

function crearGrupo(mysqli $db, array $datos): array {
    $seccion = $datos['seccion'] ?? '';
    $grado = (int)($datos['grado'] ?? 0);
    $nombre = trim($datos['nombre'] ?? '');
    
    if ($seccion === '') return ['error' => 'La sección es obligatoria'];
    if ($grado <= 0) return ['error' => 'El grado es obligatorio'];
    if ($nombre === '') return ['error' => 'El nombre del grupo es obligatorio'];
    if (strlen($nombre) > 10) return ['error' => 'El nombre no puede superar 10 caracteres'];
    
    $stmt = $db->prepare("SELECT id FROM grupos_catalogo WHERE seccion = ? AND grado = ? AND nombre = ? LIMIT 1");
    $stmt->bind_param('sis', $seccion, $grado, $nombre);
    $stmt->execute();
    if ($stmt->get_result()->num_rows > 0) {
        return ['error' => "Ya existe el grupo '$nombre' en " . ucfirst($seccion) . " grado $grado"];
    }
    
    $stmt = $db->prepare("INSERT INTO grupos_catalogo (seccion, grado, nombre, activo) VALUES (?, ?, ?, 1)");
    $stmt->bind_param('sis', $seccion, $grado, $nombre);
    
    if ($stmt->execute()) {
        return ['success' => true, 'id' => (int)$db->insert_id];
    }
    return ['error' => 'Error al guardar: ' . $stmt->error];
}

function editarGrupo(mysqli $db, int $id, array $datos): array {
    $nombre = trim($datos['nombre'] ?? '');
    
    if ($nombre === '') return ['error' => 'El nombre del grupo es obligatorio'];
    if (strlen($nombre) > 10) return ['error' => 'El nombre no puede superar 10 caracteres'];
    
    $stmt = $db->prepare("UPDATE grupos_catalogo SET nombre = ? WHERE id = ?");
    $stmt->bind_param('si', $nombre, $id);
    
    if ($stmt->execute()) {
        return ['success' => true];
    }
    return ['error' => 'Error al actualizar: ' . $stmt->error];
}

function activarGrupo(mysqli $db, int $id): array {
    $stmt = $db->prepare("UPDATE grupos_catalogo SET activo = 1 WHERE id = ?");
    $stmt->bind_param('i', $id);
    
    if ($stmt->execute()) {
        return ['success' => true];
    }
    return ['error' => 'Error al activar'];
}

function desactivarGrupo(mysqli $db, int $id): array {
    $grupo = obtenerGrupoPorId($db, $id);
    if (!$grupo) {
        return ['error' => 'Grupo no encontrado'];
    }
    
    $stmt = $db->prepare("SELECT COUNT(*) AS total FROM asignaciones WHERE seccion = ? AND grado = ? AND grupo = ? AND activo = 1");
    $stmt->bind_param('sis', $grupo['seccion'], $grupo['grado'], $grupo['nombre']);
    $stmt->execute();
    $total = (int)$stmt->get_result()->fetch_assoc()['total'];
    
    if ($total > 0) {
        return ['error' => "No puedes desactivar, tiene $total asignaciones activas"];
    }
    
    $stmt = $db->prepare("UPDATE grupos_catalogo SET activo = 0 WHERE id = ?");
    $stmt->bind_param('i', $id);
    
    if ($stmt->execute()) {
        return ['success' => true];
    }
    return ['error' => 'Error al desactivar'];
}

function eliminarGrupo(mysqli $db, int $id): array {
    $grupo = obtenerGrupoPorId($db, $id);
    if (!$grupo) {
        return ['error' => 'Grupo no encontrado'];
    }
    
    $stmt = $db->prepare("SELECT COUNT(*) AS total FROM asignaciones WHERE seccion = ? AND grado = ? AND grupo = ?");
    $stmt->bind_param('sis', $grupo['seccion'], $grupo['grado'], $grupo['nombre']);
    $stmt->execute();
    $total = (int)$stmt->get_result()->fetch_assoc()['total'];
    
    if ($total > 0) {
        return ['error' => "No puedes eliminar, tiene $total asignaciones"];
    }
    
    $stmt = $db->prepare("DELETE FROM grupos_catalogo WHERE id = ?");
    $stmt->bind_param('i', $id);
    
    if ($stmt->execute()) {
        return ['success' => true];
    }
    return ['error' => 'Error al eliminar'];
}

// ============================================================
// ACCIONES GET
// ============================================================
if ($accion === 'activar' && $editId > 0) {
    $resultado = activarGrupo($db, $editId);
    $msg = isset($resultado['success']) ? 'activado' : 'error';
    header("Location: grupos.php?seccion={$seccionActual}&grado={$gradoActual}&msg={$msg}&detalle=" . urlencode($resultado['error'] ?? ''));
    exit;
}

if ($accion === 'desactivar' && $editId > 0) {
    $resultado = desactivarGrupo($db, $editId);
    $msg = isset($resultado['success']) ? 'desactivado' : 'error';
    header("Location: grupos.php?seccion={$seccionActual}&grado={$gradoActual}&msg={$msg}&detalle=" . urlencode($resultado['error'] ?? ''));
    exit;
}

if ($accion === 'eliminar' && $editId > 0) {
    $resultado = eliminarGrupo($db, $editId);
    $msg = isset($resultado['success']) ? 'eliminado' : 'error';
    header("Location: grupos.php?seccion={$seccionActual}&grado={$gradoActual}&msg={$msg}&detalle=" . urlencode($resultado['error'] ?? ''));
    exit;
}

if ($accion === 'editar' && $editId > 0) {
    $editando = obtenerGrupoPorId($db, $editId);
    if ($editando) {
        $seccionActual = $editando['seccion'];
        $gradoActual = $editando['grado'];
    }
}

// ============================================================
// ACCIONES POST
// ============================================================
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $postId = (int)($_POST['id'] ?? 0);
    
    if ($postId > 0) {
        $resultado = editarGrupo($db, $postId, $_POST);
    } else {
        $_POST['seccion'] = $seccionActual;
        $_POST['grado'] = $gradoActual;
        $resultado = crearGrupo($db, $_POST);
    }
    
    if (isset($resultado['success'])) {
        header("Location: grupos.php?seccion={$seccionActual}&grado={$gradoActual}&msg=success");
        exit;
    }
}

$msgRedir = $_GET['msg'] ?? '';
$msgDetall = $_GET['detalle'] ?? '';
$gruposActuales = listarGruposPorGrado($db, $seccionActual, $gradoActual, false);

$pageTitle = 'Superadmin › Grupos';
$backLink = 'dashboard.php';
include __DIR__ . '/../includes/header.php';
?>

<!-- MODAL PERSONALIZADO (MISMO ESTILO QUE gestion_calificaciones.php) -->
<div id="confirmModal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:1000; align-items:center; justify-content:center;">
    <div style="background:white; border-radius:12px; padding:20px; max-width:400px; margin:auto; box-shadow:0 4px 20px rgba(0,0,0,0.2);">
        <h3 id="modalTitle" style="margin-bottom:15px; color:#dc2626;">Confirmar</h3>
        <p id="modalBody" style="margin-bottom:20px;">¿Estás seguro de realizar esta acción?</p>
        <div style="display:flex; gap:10px; justify-content:flex-end;">
            <button id="modalCancel" class="btn" style="background:#e2e8f0; color:#333;">Cancelar</button>
            <button id="modalConfirm" class="btn" style="background:#dc2626; color:white;">Confirmar</button>
        </div>
    </div>
</div>

<style>
.notificacion-flotante {
    position: fixed;
    top: 20px;
    right: 20px;
    z-index: 1100;
    padding: 1rem 1.5rem;
    border-radius: 8px;
    animation: slideIn 0.3s ease-out;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}
.notificacion-flotante.success { background: #10b981; color: white; }
.notificacion-flotante.error   { background: #ef4444; color: white; }
@keyframes slideIn {
    from { transform: translateX(100%); opacity: 0; }
    to   { transform: translateX(0);    opacity: 1; }
}
@keyframes fadeOut {
    from { opacity: 1; }
    to   { opacity: 0; }
}
.filtros-grid {
    display: flex;
    gap: 1rem;
    margin-bottom: 1.5rem;
    flex-wrap: wrap;
}
</style>

<main class="container">

  <?php if ($msgRedir === 'success'): ?>
    <p class="alert alert--success">✅ Operación realizada.</p>
  <?php elseif ($msgRedir === 'activado'): ?>
    <p class="alert alert--success">✅ Grupo activado.</p>
  <?php elseif ($msgRedir === 'desactivado'): ?>
    <p class="alert alert--success">✅ Grupo desactivado.</p>
  <?php elseif ($msgRedir === 'eliminado'): ?>
    <p class="alert alert--success">✅ Grupo eliminado.</p>
  <?php elseif ($msgRedir === 'error' && $msgDetall): ?>
    <p class="alert alert--error">⚠️ <?= htmlspecialchars($msgDetall) ?></p>
  <?php endif; ?>

  <?php if ($resultado && isset($resultado['error'])): ?>
    <p class="alert alert--error">⚠️ <?= htmlspecialchars($resultado['error']) ?></p>
  <?php endif; ?>

  <!-- Filtros -->
  <div class="card" style="margin-bottom: 1.5rem;">
    <form method="GET" class="filtros-grid">
      <div class="form-group" style="margin-bottom: 0;">
        <label for="seccion">Sección</label>
        <select name="seccion" id="seccion" onchange="this.form.submit()">
          <?php foreach ($secciones as $sec): ?>
            <option value="<?= $sec ?>" <?= $seccionActual === $sec ? 'selected' : '' ?>><?= ucfirst($sec) ?></option>
          <?php endforeach; ?>
        </select>
      </div>
      <div class="form-group" style="margin-bottom: 0;">
        <label for="grado">Grado</label>
        <select name="grado" id="grado" onchange="this.form.submit()">
          <?php foreach ($gradosPorSeccion[$seccionActual] as $g): ?>
            <option value="<?= $g ?>" <?= $gradoActual === $g ? 'selected' : '' ?>><?= $g ?>°</option>
          <?php endforeach; ?>
        </select>
      </div>
    </form>
  </div>

  <div style="display:grid; grid-template-columns:1fr 1.6fr; gap:1.5rem; align-items:start;">

    <!-- Formulario -->
    <section class="card">
      <h2 class="section-title"><?= $editando ? '✏️ Editar grupo' : '➕ Nuevo grupo' ?></h2>
      <form method="POST">
        <?php if ($editando): ?>
          <input type="hidden" name="id" value="<?= $editando['id'] ?>">
        <?php endif; ?>
        <div class="form-group">
          <label for="nombre">Nombre del grupo *</label>
          <input type="text" id="nombre" name="nombre" maxlength="10" required
                 value="<?= htmlspecialchars($editando['nombre'] ?? ($_POST['nombre'] ?? '')) ?>"
                 placeholder="ej. A, B, C, D">
        </div>
        <input type="hidden" name="seccion" value="<?= $seccionActual ?>">
        <input type="hidden" name="grado" value="<?= $gradoActual ?>">
        <button class="btn" type="submit"><?= $editando ? 'Guardar' : 'Crear' ?></button>
        <?php if ($editando): ?>
          <a class="btn btn--muted" href="grupos.php?seccion=<?= $seccionActual ?>&grado=<?= $gradoActual ?>">Cancelar</a>
        <?php endif; ?>
      </form>
    </section>

    <!-- Listado -->
    <section class="card">
      <h2 class="section-title">Grupos de <?= ucfirst($seccionActual) ?> <?= $gradoActual ?>°</h2>
      <?php if (empty($gruposActuales)): ?>
        <p class="empty-state">No hay grupos configurados.</p>
      <?php else: ?>
        <table class="data-table">
          <thead>
            <tr>
              <th>Nombre</th>
              <th>Estado</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <?php foreach ($gruposActuales as $g): 
              $esActivo = (int)$g['activo'] === 1;
              $nombreSafe = htmlspecialchars($g['nombre']);
              $urlEditar = "grupos.php?accion=editar&id={$g['id']}&seccion={$seccionActual}&grado={$gradoActual}";
              $urlActivar = "grupos.php?accion=activar&id={$g['id']}&seccion={$seccionActual}&grado={$gradoActual}";
              $urlDesactivar = "grupos.php?accion=desactivar&id={$g['id']}&seccion={$seccionActual}&grado={$gradoActual}";
              $urlEliminar = "grupos.php?accion=eliminar&id={$g['id']}&seccion={$seccionActual}&grado={$gradoActual}";
            ?>
              <tr>
                <td><strong><?= $nombreSafe ?></strong></td>
                <td>
                  <?php if ($esActivo): ?>
                    <span class="badge badge--active">Activo</span>
                  <?php else: ?>
                    <span class="badge badge--warn">Inactivo</span>
                  <?php endif; ?>
                </td>
                <td>
                  <a class="btn btn--sm" href="<?= $urlEditar ?>">Editar</a>
                  <?php if ($esActivo): ?>
                    <button type="button" class="btn btn--sm btn--warning js-modal-trigger"
                            data-href="<?= $urlDesactivar ?>"
                            data-title="Desactivar grupo"
                            data-body="¿Desactivar grupo '<?= $nombreSafe ?>' de <?= ucfirst($seccionActual) ?> <?= $gradoActual ?>°?">
                      Desactivar
                    </button>
                  <?php else: ?>
                    <button type="button" class="btn btn--sm btn--success js-modal-trigger"
                            data-href="<?= $urlActivar ?>"
                            data-title="Activar grupo"
                            data-body="¿Activar grupo '<?= $nombreSafe ?>' de <?= ucfirst($seccionActual) ?> <?= $gradoActual ?>°?">
                      Activar
                    </button>
                  <?php endif; ?>
                  <button type="button" class="btn btn--sm btn--danger js-modal-trigger"
                          data-href="<?= $urlEliminar ?>"
                          data-title="Eliminar grupo"
                          data-body="⚠️ ¿ELIMINAR grupo '<?= $nombreSafe ?>' de <?= ucfirst($seccionActual) ?> <?= $gradoActual ?>°? Esta acción no se puede deshacer.">
                    Eliminar
                  </button>
                </td>
              </tr>
            <?php endforeach; ?>
          </tbody>
        </table>
      <?php endif; ?>
    </section>
  </div>
</main>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const modal = document.getElementById('confirmModal');
    const modalTitle = document.getElementById('modalTitle');
    const modalBody = document.getElementById('modalBody');
    const modalConfirm = document.getElementById('modalConfirm');
    const modalCancel = document.getElementById('modalCancel');
    let currentHref = '';

    document.querySelectorAll('.js-modal-trigger').forEach(btn => {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            currentHref = this.dataset.href;
            modalTitle.textContent = this.dataset.title || 'Confirmar';
            modalBody.innerHTML = this.dataset.body || '¿Estás seguro?';
            modal.style.display = 'flex';
        });
    });

    modalConfirm.addEventListener('click', function() {
        if (currentHref) {
            window.location.href = currentHref;
        }
        modal.style.display = 'none';
    });

    modalCancel.addEventListener('click', function() {
        modal.style.display = 'none';
    });

    modal.addEventListener('click', function(e) {
        if (e.target === modal) modal.style.display = 'none';
    });
});
</script>

<?php include __DIR__ . '/../includes/footer.php'; ?>