<?php
// superadmin/lista_padres.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/UserModel.php';
require_once __DIR__ . '/../models/PadreModel.php';
requireRol([1]);

$db         = getConexion();
$padreModel = new PadreModel($db, new UserModel($db));

// ============================================
// MANEJAR PETICIÓN AJAX
// ============================================
if (isset($_GET['ajax']) && $_GET['ajax'] == 1) {
    header('Content-Type: application/json');
    
    $accion = $_GET['accion'] ?? '';
    $id     = (int)($_GET['id'] ?? 0);
    
    // Activar / desactivar
    if ($accion === 'activar' || $accion === 'desactivar') {
        if ($id <= 0) {
            echo json_encode(['success' => false, 'message' => 'ID de padre/tutor inválido']);
            exit;
        }
        
        $nuevoEstado = ($accion === 'activar') ? 1 : 0;
        $resultado = $padreModel->toggleActivo($id, $nuevoEstado);
        
        if (isset($resultado['success'])) {
            echo json_encode([
                'success' => true, 
                'message' => $accion === 'activar' ? 'Padre/Tutor activado correctamente' : 'Padre/Tutor desactivado correctamente',
                'activo' => $nuevoEstado
            ]);
        } else {
            echo json_encode([
                'success' => false, 
                'message' => $resultado['error'] ?? 'Error al actualizar el padre/tutor'
            ]);
        }
        exit;
    }
    
    // Obtener datos de un padre/tutor para editar
    if ($accion === 'get') {
        if ($id <= 0) {
            echo json_encode(['success' => false, 'message' => 'ID de padre/tutor inválido']);
            exit;
        }
        
        $stmt = $db->prepare("
            SELECT p.*, u.username, u.activo as user_activo
            FROM padres p 
            JOIN users u ON u.id = p.user_id 
            WHERE p.id = ?
        ");
        $stmt->bind_param('i', $id);
        $stmt->execute();
        $result = $stmt->get_result();
        $padre = $result->fetch_assoc();
        
        if (!$padre) {
            echo json_encode(['success' => false, 'message' => 'Padre/Tutor no encontrado']);
            exit;
        }
        
        echo json_encode(['success' => true, 'data' => $padre]);
        exit;
    }
    
    echo json_encode(['success' => false, 'message' => 'Acción no válida']);
    exit;
}

// ============================================
// PROCESAR ACTUALIZACIÓN POR POST
// ============================================
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'update') {
    header('Content-Type: application/json');
    
    $id = (int)($_POST['id'] ?? 0);
    if ($id <= 0) {
        echo json_encode(['success' => false, 'message' => 'ID de padre/tutor inválido']);
        exit;
    }
    
    $nombre = trim($_POST['nombre'] ?? '');
    $apellido_paterno = trim($_POST['apellido_paterno'] ?? '');
    $apellido_materno = trim($_POST['apellido_materno'] ?? '');
    $genero = $_POST['genero'] ?? '';
    $telefono = trim($_POST['telefono'] ?? '');
    $telefono_emergencia = trim($_POST['telefono_emergencia'] ?? '');
    $correo = trim($_POST['correo'] ?? '');
    $curp = strtoupper(trim($_POST['curp'] ?? ''));
    
    // Validaciones
    if (empty($nombre)) {
        echo json_encode(['success' => false, 'message' => 'El nombre es obligatorio']);
        exit;
    }
    if (empty($apellido_paterno)) {
        echo json_encode(['success' => false, 'message' => 'El apellido paterno es obligatorio']);
        exit;
    }
    if (empty($genero) || !in_array($genero, ['masculino', 'femenino', 'otro'])) {
        echo json_encode(['success' => false, 'message' => 'Género inválido']);
        exit;
    }
    if (empty($telefono)) {
        echo json_encode(['success' => false, 'message' => 'El teléfono es obligatorio']);
        exit;
    }
    if (!empty($curp) && strlen($curp) !== 18) {
        echo json_encode(['success' => false, 'message' => 'El CURP debe tener 18 caracteres']);
        exit;
    }
    
    // Verificar CURP única (excepto este registro)
    if (!empty($curp)) {
        $stmt = $db->prepare("SELECT id FROM padres WHERE curp = ? AND id != ?");
        $stmt->bind_param('si', $curp, $id);
        $stmt->execute();
        if ($stmt->get_result()->num_rows > 0) {
            echo json_encode(['success' => false, 'message' => 'El CURP ya está registrado por otro padre/tutor']);
            exit;
        }
    }
    
    // Actualizar padre
    $sql = "
        UPDATE padres SET
            nombre = ?,
            apellido_paterno = ?,
            apellido_materno = ?,
            genero = ?,
            telefono = ?,
            telefono_emergencia = ?,
            correo = ?,
            curp = ?
        WHERE id = ?
    ";
    
    $stmt = $db->prepare($sql);
    $stmt->bind_param(
        'ssssssssi',
        $nombre,
        $apellido_paterno,
        $apellido_materno,
        $genero,
        $telefono,
        $telefono_emergencia,
        $correo,
        $curp,
        $id
    );
    
    if ($stmt->execute()) {
        echo json_encode(['success' => true, 'message' => 'Padre/Tutor actualizado correctamente']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Error al actualizar: ' . $stmt->error]);
    }
    exit;
}

// ============================================
// ELIMINAR (BAJA LÓGICA)
// ============================================
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'delete') {
    header('Content-Type: application/json');
    
    $id = (int)($_POST['id'] ?? 0);
    if ($id <= 0) {
        echo json_encode(['success' => false, 'message' => 'ID de padre/tutor inválido']);
        exit;
    }
    
    // Verificar si tiene alumnos asociados
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM padre_alumno WHERE padre_id = ?");
    $stmt->bind_param('i', $id);
    $stmt->execute();
    $result = $stmt->get_result();
    $row = $result->fetch_assoc();
    
    if ($row['total'] > 0) {
        echo json_encode([
            'success' => false, 
            'message' => "No se puede eliminar. Este padre/tutor tiene {$row['total']} alumno(s) asociado(s). Primero reasigna o elimina los alumnos."
        ]);
        exit;
    }
    
    // Desactivar user y padre
    $db->begin_transaction();
    
    try {
        // Obtener user_id
        $stmt = $db->prepare("SELECT user_id FROM padres WHERE id = ?");
        $stmt->bind_param('i', $id);
        $stmt->execute();
        $result = $stmt->get_result();
        $padre = $result->fetch_assoc();
        
        if ($padre) {
            // Desactivar user
            $stmt = $db->prepare("UPDATE users SET activo = 0 WHERE id = ?");
            $stmt->bind_param('i', $padre['user_id']);
            $stmt->execute();
        }
        
        // Desactivar padre (baja lógica)
        $stmt = $db->prepare("UPDATE padres SET activo = 0 WHERE id = ?");
        $stmt->bind_param('i', $id);
        $stmt->execute();
        
        $db->commit();
        echo json_encode(['success' => true, 'message' => 'Padre/Tutor eliminado correctamente']);
    } catch (Exception $e) {
        $db->rollback();
        echo json_encode(['success' => false, 'message' => 'Error al eliminar: ' . $e->getMessage()]);
    }
    exit;
}

// ============================================
// PÁGINA PRINCIPAL
// ============================================
$padres = $padreModel->listarTodos();
$generosList = ['masculino' => 'Masculino', 'femenino' => 'Femenino', 'otro' => 'Otro'];

$pageTitle = 'Superadmin › Padres / Tutores';
$backLink  = 'dashboard.php';
include __DIR__ . '/../includes/header.php';
?>

<style>
    .toast-container {
        position: fixed;
        top: 20px;
        right: 20px;
        z-index: 99999;
        display: flex;
        flex-direction: column;
        gap: 10px;
        max-width: 400px;
        width: 100%;
    }

    .toast {
        padding: 16px 20px;
        border-radius: 8px;
        color: white;
        font-weight: 500;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        animation: slideInRight 0.3s ease;
        display: flex;
        align-items: center;
        gap: 10px;
        font-size: 0.95rem;
    }

    .toast-success {
        background: #059669;
        border-left: 4px solid #34d399;
    }

    .toast-error {
        background: #dc2626;
        border-left: 4px solid #f87171;
    }

    .toast-info {
        background: #2563eb;
        border-left: 4px solid #60a5fa;
    }

    .toast-warning {
        background: #d97706;
        border-left: 4px solid #fbbf24;
    }

    .toast-icon {
        font-size: 1.2rem;
        flex-shrink: 0;
    }

    .toast-message {
        flex: 1;
    }

    .toast-close {
        background: none;
        border: none;
        color: rgba(255,255,255,0.8);
        cursor: pointer;
        font-size: 1.2rem;
        padding: 0 4px;
        transition: color 0.2s;
    }

    .toast-close:hover {
        color: white;
    }

    @keyframes slideInRight {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }

    @keyframes slideOutRight {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(100%);
            opacity: 0;
        }
    }

    .toast-out {
        animation: slideOutRight 0.3s ease forwards;
    }

    /* Modal */
    .modal-overlay {
        display: none;
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0,0,0,0.5);
        z-index: 9999;
        justify-content: center;
        align-items: center;
    }

    .modal-overlay.active {
        display: flex;
    }

    .modal-content {
        background: white;
        border-radius: 12px;
        padding: 2rem;
        max-width: 700px;
        width: 95%;
        max-height: 90vh;
        overflow-y: auto;
        box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        position: relative;
    }

    .modal-close {
        position: absolute;
        top: 12px;
        right: 16px;
        background: none;
        border: none;
        font-size: 1.5rem;
        cursor: pointer;
        color: #64748b;
        transition: color 0.2s;
    }

    .modal-close:hover {
        color: #0f172a;
    }

    .modal-title {
        font-size: 1.25rem;
        font-weight: 600;
        margin-bottom: 1.5rem;
        color: var(--color-primary);
    }

    .modal-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 1rem;
    }

    .modal-field {
        display: flex;
        flex-direction: column;
        gap: 4px;
    }

    .modal-field.full-width {
        grid-column: 1 / -1;
    }

    .modal-field label {
        font-size: 0.75rem;
        font-weight: 600;
        color: var(--color-muted);
        text-transform: uppercase;
        letter-spacing: 0.3px;
    }

    .modal-field input,
    .modal-field select {
        padding: 0.5rem 0.75rem;
        border: 1px solid var(--color-border);
        border-radius: var(--radius-sm);
        font-size: 0.9rem;
        font-family: var(--font);
        background: var(--color-surface);
        transition: border-color 0.2s;
    }

    .modal-field input:focus,
    .modal-field select:focus {
        outline: none;
        border-color: var(--color-accent);
        box-shadow: 0 0 0 3px rgba(59,130,246,0.15);
    }

    .modal-actions {
        display: flex;
        gap: 0.75rem;
        margin-top: 1.5rem;
        justify-content: flex-end;
        border-top: 1px solid var(--color-border);
        padding-top: 1.5rem;
    }

    .btn-modal-save {
        background: var(--color-accent);
        color: white;
        padding: 0.6rem 1.5rem;
        border: none;
        border-radius: var(--radius-sm);
        cursor: pointer;
        font-weight: 500;
        font-family: var(--font);
        transition: background 0.2s;
    }

    .btn-modal-save:hover {
        background: #2563eb;
    }

    .btn-modal-cancel {
        background: #e2e8f0;
        color: #475569;
        padding: 0.6rem 1.5rem;
        border: none;
        border-radius: var(--radius-sm);
        cursor: pointer;
        font-weight: 500;
        font-family: var(--font);
        transition: background 0.2s;
    }

    .btn-modal-cancel:hover {
        background: #cbd5e1;
    }

    .btn-modal-danger {
        background: #dc2626;
        color: white;
        padding: 0.6rem 1.5rem;
        border: none;
        border-radius: var(--radius-sm);
        cursor: pointer;
        font-weight: 500;
        font-family: var(--font);
        transition: background 0.2s;
    }

    .btn-modal-danger:hover {
        background: #b91c1c;
    }

    .btn-modal-danger:disabled {
        opacity: 0.6;
        cursor: not-allowed;
    }

    /* Modal de confirmación simple */
    .modal-confirm {
        background: white;
        border-radius: 12px;
        padding: 2rem;
        max-width: 450px;
        width: 95%;
        box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        position: relative;
    }

    .modal-confirm__title {
        font-size: 1.2rem;
        font-weight: 600;
        margin-bottom: 0.5rem;
    }

    .modal-confirm__title.title-danger {
        color: #dc2626;
    }

    .modal-confirm__title.title-success {
        color: #059669;
    }

    .modal-confirm__body {
        color: #475569;
        margin-bottom: 1.5rem;
        line-height: 1.6;
    }

    .modal-confirm__actions {
        display: flex;
        gap: 0.75rem;
        justify-content: flex-end;
        border-top: 1px solid var(--color-border);
        padding-top: 1.5rem;
    }

    .badge--success {
        background: #d1fae5;
        color: #065f46;
    }

    .badge--warn {
        background: #fee2e2;
        color: #991b1b;
    }

    .badge--inactive {
        background: #f1f5f9;
        color: #475569;
    }

    .btn-action {
        padding: 4px 8px;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        font-size: 0.7rem;
        font-weight: 500;
        transition: all 0.2s;
        font-family: var(--font);
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 3px;
    }

    .btn-edit {
        background: #dbeafe;
        color: #1e40af;
    }

    .btn-edit:hover {
        background: #bfdbfe;
    }

    .btn-deactivate {
        background: #fee2e2;
        color: #991b1b;
    }

    .btn-deactivate:hover {
        background: #fecaca;
    }

    .btn-activate {
        background: #d1fae5;
        color: #065f46;
    }

    .btn-activate:hover {
        background: #a7f3d0;
    }

    .btn-delete {
        background: #fef3c7;
        color: #92400e;
    }

    .btn-delete:hover {
        background: #fde68a;
    }

    .table-actions {
        display: flex;
        gap: 4px;
        flex-wrap: wrap;
        justify-content: center;
    }

    @media (max-width: 600px) {
        .modal-grid {
            grid-template-columns: 1fr;
        }
        .toast-container {
            max-width: 90%;
            right: 5%;
            top: 10px;
        }
    }
</style>

<main class="container">
    <div id="toastContainer" class="toast-container"></div>

    <div class="card">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
            <h2 class="section-title" style="margin-bottom: 0;">
                👨‍👩‍👧 Padres / Tutores Registrados (<?= count($padres) ?>)
            </h2>
            <a href="alta_padre.php" class="btn btn--accent">➕ Nuevo Padre/Tutor</a>
        </div>

        <?php if (empty($padres)): ?>
            <p class="empty-state">📭 Aún no hay padres/tutores registrados.</p>
        <?php else: ?>
            <div class="table-responsive">
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
                            <th>Registrado</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($padres as $i => $p): ?>
                            <?php
                            $esActivo    = (int)($p['activo'] ?? 1) === 1;
                            $nombreSafe  = htmlspecialchars($p['apellido_paterno'] . ' ' . ($p['apellido_materno'] ?? '') . ', ' . $p['nombre']);
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
                                <td><?= date('d/m/Y', strtotime($p['creado_en'])) ?></td>
                                <td>
                                    <div class="table-actions">
                                        <button class="btn-action btn-edit" onclick="editarPadre(<?= $p['id'] ?>)">
                                            Editar
                                        </button>
                                        <?php if ($esActivo): ?>
                                            <button class="btn-action btn-deactivate" onclick="abrirModalConfirmacion(<?= $p['id'] ?>, 'desactivar', '<?= $nombreSafe ?>')">
                                                Baja
                                            </button>
                                        <?php else: ?>
                                            <button class="btn-action btn-activate" onclick="abrirModalConfirmacion(<?= $p['id'] ?>, 'activar', '<?= $nombreSafe ?>')">
                                                Activar
                                            </button>
                                        <?php endif; ?>
                                        <button class="btn-action btn-delete" onclick="abrirModalEliminar(<?= $p['id'] ?>, '<?= $nombreSafe ?>')">
                                            Eliminar
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        <?php endif; ?>
    </div>
</main>

<!-- Modal Editar -->
<div id="editModal" class="modal-overlay">
    <div class="modal-content">
        <button class="modal-close" onclick="cerrarEditModal()">&times;</button>
        <h3 class="modal-title">✏️ Editar Padre/Tutor</h3>
        <form id="editForm">
            <input type="hidden" id="editId" name="id">
            
            <div class="modal-grid">
                <div class="modal-field">
                    <label>Nombre(s) *</label>
                    <input type="text" id="editNombre" name="nombre" required placeholder="Nombre(s)">
                </div>
                <div class="modal-field">
                    <label>Apellido Paterno *</label>
                    <input type="text" id="editApellidoPaterno" name="apellido_paterno" required placeholder="Apellido paterno">
                </div>
                <div class="modal-field">
                    <label>Apellido Materno</label>
                    <input type="text" id="editApellidoMaterno" name="apellido_materno" placeholder="Apellido materno">
                </div>
                <div class="modal-field">
                    <label>Género *</label>
                    <select id="editGenero" name="genero" required>
                        <?php foreach ($generosList as $val => $label): ?>
                            <option value="<?= $val ?>"><?= $label ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="modal-field">
                    <label>Teléfono *</label>
                    <input type="text" id="editTelefono" name="telefono" required placeholder="Teléfono">
                </div>
                <div class="modal-field">
                    <label>Teléfono Emergencia</label>
                    <input type="text" id="editTelefonoEmergencia" name="telefono_emergencia" placeholder="Teléfono de emergencia">
                </div>
                <div class="modal-field">
                    <label>Correo</label>
                    <input type="email" id="editCorreo" name="correo" placeholder="correo@ejemplo.com">
                </div>
                <div class="modal-field full-width">
                    <label>CURP</label>
                    <input type="text" id="editCurp" name="curp" maxlength="18" placeholder="18 caracteres" style="text-transform: uppercase;">
                </div>
            </div>
            
            <div class="modal-actions">
                <button type="button" class="btn-modal-cancel" onclick="cerrarEditModal()">Cancelar</button>
                <button type="submit" class="btn-modal-save">💾 Guardar Cambios</button>
            </div>
        </form>
    </div>
</div>

<!-- Modal Confirmación (Activar/Desactivar) -->
<div class="modal-overlay" id="confirmModal">
    <div class="modal-confirm">
        <h3 class="modal-confirm__title" id="confirmTitle"></h3>
        <p class="modal-confirm__body" id="confirmBody"></p>
        <div class="modal-confirm__actions">
            <button class="btn-modal-danger" id="confirmBtn">Confirmar</button>
            <button class="btn-modal-cancel" id="confirmCancel">Cancelar</button>
        </div>
    </div>
</div>

<!-- Modal Eliminar -->
<div class="modal-overlay" id="deleteModal">
    <div class="modal-confirm">
        <h3 class="modal-confirm__title title-danger" id="deleteTitle">🗑️ Eliminar Padre/Tutor</h3>
        <p class="modal-confirm__body" id="deleteBody"></p>
        <div class="modal-confirm__actions">
            <button class="btn-modal-danger" id="deleteBtn">🗑️ Eliminar</button>
            <button class="btn-modal-cancel" id="deleteCancel">Cancelar</button>
        </div>
    </div>
</div>

<script>
// ============================================================
// SISTEMA DE NOTIFICACIONES TOAST
// ============================================================
function showToast(message, type = 'success', duration = 3000) {
    const container = document.getElementById('toastContainer');
    
    const icons = {
        success: '✅',
        error: '❌',
        info: 'ℹ️',
        warning: '⚠️'
    };
    
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.innerHTML = `
        <span class="toast-icon">${icons[type] || '📌'}</span>
        <span class="toast-message">${message}</span>
        <button class="toast-close" onclick="this.parentElement.remove()">&times;</button>
    `;
    
    container.appendChild(toast);
    
    setTimeout(() => {
        if (toast.parentElement) {
            toast.classList.add('toast-out');
            setTimeout(() => {
                if (toast.parentElement) {
                    toast.remove();
                }
            }, 300);
        }
    }, duration);
}

// ============================================================
// MODAL DE CONFIRMACIÓN (ACTIVAR/DESACTIVAR)
// ============================================================
let confirmId = null;
let confirmAction = null;

function abrirModalConfirmacion(id, action, nombre) {
    confirmId = id;
    confirmAction = action;
    
    const title = document.getElementById('confirmTitle');
    const body = document.getElementById('confirmBody');
    const btn = document.getElementById('confirmBtn');
    
    if (action === 'activar') {
        title.textContent = '🔄 Activar Padre/Tutor';
        title.className = 'modal-confirm__title title-success';
        body.textContent = `¿Confirmas activar a "${nombre}"?`;
        btn.textContent = 'Activar';
        btn.className = 'btn-modal-danger confirm-activate';
        btn.style.background = '#059669';
    } else {
        title.textContent = '⛔ Desactivar Padre/Tutor';
        title.className = 'modal-confirm__title title-danger';
        body.textContent = `¿Confirmas desactivar a "${nombre}"? No podrá iniciar sesión.`;
        btn.textContent = 'Desactivar';
        btn.className = 'btn-modal-danger';
        btn.style.background = '#dc2626';
    }
    
    document.getElementById('confirmModal').classList.add('active');
}

document.getElementById('confirmBtn').addEventListener('click', function() {
    if (!confirmId || !confirmAction) return;
    
    this.disabled = true;
    this.textContent = '⏳ Procesando...';
    
    fetch(`?ajax=1&accion=${confirmAction}&id=${confirmId}`)
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                showToast(data.message, 'success');
                setTimeout(() => location.reload(), 500);
            } else {
                showToast(data.message || 'Error al procesar', 'error');
                cerrarConfirmModal();
            }
        })
        .catch(error => {
            console.error('Error:', error);
            showToast('Error al procesar la solicitud', 'error');
            cerrarConfirmModal();
        })
        .finally(() => {
            this.disabled = false;
            this.textContent = confirmAction === 'activar' ? 'Activar' : 'Desactivar';
            this.style.background = confirmAction === 'activar' ? '#059669' : '#dc2626';
        });
});

document.getElementById('confirmCancel').addEventListener('click', cerrarConfirmModal);

function cerrarConfirmModal() {
    document.getElementById('confirmModal').classList.remove('active');
    confirmId = null;
    confirmAction = null;
}

// ============================================================
// MODAL ELIMINAR
// ============================================================
let deleteId = null;

function abrirModalEliminar(id, nombre) {
    deleteId = id;
    document.getElementById('deleteBody').textContent = 
        `¿Estás seguro de que deseas eliminar a "${nombre}"?\n\n` +
        `⚠️ Solo se puede eliminar si no tiene alumnos asociados.`;
    document.getElementById('deleteModal').classList.add('active');
}

document.getElementById('deleteBtn').addEventListener('click', function() {
    if (!deleteId) return;
    
    this.disabled = true;
    this.textContent = '⏳ Eliminando...';
    
    const formData = new FormData();
    formData.append('action', 'delete');
    formData.append('id', deleteId);
    
    fetch(window.location.pathname, {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showToast(data.message, 'success');
            setTimeout(() => location.reload(), 500);
        } else {
            showToast(data.message || 'Error al eliminar', 'error');
            cerrarDeleteModal();
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showToast('Error al procesar la eliminación', 'error');
        cerrarDeleteModal();
    })
    .finally(() => {
        this.disabled = false;
        this.textContent = '🗑️ Eliminar';
    });
});

document.getElementById('deleteCancel').addEventListener('click', cerrarDeleteModal);

function cerrarDeleteModal() {
    document.getElementById('deleteModal').classList.remove('active');
    deleteId = null;
}

// ============================================================
// MODAL EDITAR
// ============================================================
function editarPadre(id) {
    // Mostrar loading en el botón
    const botones = document.querySelectorAll('.btn-edit');
    let boton = null;
    botones.forEach(b => {
        if (b.closest('tr').querySelector(`[onclick*="editarPadre(${id})"]`)) {
            boton = b;
        }
    });
    
    if (boton) {
        boton.textContent = '⏳ Cargando...';
        boton.disabled = true;
    }
    
    fetch(`?ajax=1&accion=get&id=${id}`)
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                const p = data.data;
                document.getElementById('editId').value = p.id;
                document.getElementById('editNombre').value = p.nombre;
                document.getElementById('editApellidoPaterno').value = p.apellido_paterno;
                document.getElementById('editApellidoMaterno').value = p.apellido_materno || '';
                document.getElementById('editGenero').value = p.genero;
                document.getElementById('editTelefono').value = p.telefono || '';
                document.getElementById('editTelefonoEmergencia').value = p.telefono_emergencia || '';
                document.getElementById('editCorreo').value = p.correo || '';
                document.getElementById('editCurp').value = p.curp || '';
                
                document.getElementById('editModal').classList.add('active');
            } else {
                showToast(data.message || 'Error al cargar los datos', 'error');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            showToast('Error al cargar los datos del padre/tutor', 'error');
        })
        .finally(() => {
            if (boton) {
                boton.textContent = '✏️ Editar';
                boton.disabled = false;
            }
        });
}

document.getElementById('editForm').addEventListener('submit', function(e) {
    e.preventDefault();
    
    // Validaciones
    const nombre = document.getElementById('editNombre').value.trim();
    const apellido = document.getElementById('editApellidoPaterno').value.trim();
    const telefono = document.getElementById('editTelefono').value.trim();
    const genero = document.getElementById('editGenero').value;
    const curp = document.getElementById('editCurp').value.trim();
    
    if (!nombre) {
        showToast('El nombre es obligatorio', 'error');
        document.getElementById('editNombre').focus();
        return;
    }
    if (!apellido) {
        showToast('El apellido paterno es obligatorio', 'error');
        document.getElementById('editApellidoPaterno').focus();
        return;
    }
    if (!telefono) {
        showToast('El teléfono es obligatorio', 'error');
        document.getElementById('editTelefono').focus();
        return;
    }
    if (!genero || !['masculino', 'femenino', 'otro'].includes(genero)) {
        showToast('Selecciona un género válido', 'error');
        return;
    }
    if (curp && curp.length !== 18) {
        showToast('El CURP debe tener exactamente 18 caracteres', 'error');
        document.getElementById('editCurp').focus();
        return;
    }
    
    const submitBtn = this.querySelector('button[type="submit"]');
    const originalText = submitBtn.textContent;
    submitBtn.textContent = '⏳ Guardando...';
    submitBtn.disabled = true;
    
    const formData = new FormData(this);
    formData.append('action', 'update');
    
    fetch(window.location.pathname, {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showToast('Padre/Tutor actualizado correctamente', 'success');
            setTimeout(() => {
                cerrarEditModal();
                location.reload();
            }, 500);
        } else {
            showToast(data.message || 'Error al actualizar', 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showToast('Error al guardar los cambios', 'error');
    })
    .finally(() => {
        submitBtn.textContent = originalText;
        submitBtn.disabled = false;
    });
});

function cerrarEditModal() {
    document.getElementById('editModal').classList.remove('active');
}

// ============================================================
// EVENTOS
// ============================================================
// Cerrar modales con ESC
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        cerrarEditModal();
        cerrarConfirmModal();
        cerrarDeleteModal();
    }
});

// Cerrar modales al hacer click fuera
document.getElementById('editModal')?.addEventListener('click', function(e) {
    if (e.target === this) cerrarEditModal();
});
document.getElementById('confirmModal')?.addEventListener('click', function(e) {
    if (e.target === this) cerrarConfirmModal();
});
document.getElementById('deleteModal')?.addEventListener('click', function(e) {
    if (e.target === this) cerrarDeleteModal();
});
</script>

<?php include __DIR__ . '/../includes/footer.php'; ?>