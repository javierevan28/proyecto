<?php
// superadmin/gestion_usuarios_permisos.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/UserModel.php';
requireRol([1]);

$db = getConexion();
$userModel = new UserModel($db);

$mensaje = null;
$error = null;

// Procesar cambio de rol
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['cambiar_rol'])) {
    $userId = (int)$_POST['user_id'];
    $nuevoRol = (int)$_POST['nuevo_rol'];
    
    $stmt = $db->prepare("UPDATE users SET rol_id = ? WHERE id = ?");
    $stmt->bind_param('ii', $nuevoRol, $userId);
    if ($stmt->execute()) {
        $mensaje = "Rol de usuario actualizado correctamente.";
    } else {
        $error = "Error al actualizar rol.";
    }
}

// Procesar asignación de permisos por sección
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['guardar_permisos'])) {
    $userId = (int)$_POST['user_id'];
    $secciones = $_POST['secciones'] ?? [];
    
    // Eliminar permisos existentes
    $stmtDel = $db->prepare("DELETE FROM usuarios_permisos WHERE user_id = ?");
    $stmtDel->bind_param('i', $userId);
    $stmtDel->execute();
    
    // Insertar nuevos permisos
    $stmtIns = $db->prepare("INSERT INTO usuarios_permisos (user_id, seccion, materia_id) VALUES (?, ?, ?)");
    foreach ($secciones as $seccion => $materias) {
        foreach ($materias as $materiaId) {
            $stmtIns->bind_param('isi', $userId, $seccion, $materiaId);
            $stmtIns->execute();
        }
    }
    
    $mensaje = "Permisos guardados correctamente.";
}

// Obtener usuarios con sus roles
$usuarios = $db->query("
    SELECT u.id, u.username, u.rol_id, r.nombre as rol_nombre
    FROM users u
    JOIN roles r ON r.id = u.rol_id
    WHERE u.id != 1
    ORDER BY u.id
")->fetch_all(MYSQLI_ASSOC);

// Obtener roles disponibles
$roles = $db->query("SELECT * FROM roles ORDER BY id")->fetch_all(MYSQLI_ASSOC);

// Obtener materias por sección para permisos
$materiasPorSeccion = [];
$seccionesList = ['maternal', 'preescolar', 'primaria', 'secundaria'];
foreach ($seccionesList as $sec) {
    $stmt = $db->prepare("
        SELECT m.id, m.nombre 
        FROM materias m
        WHERE m.activo = 1
        ORDER BY m.nombre
    ");
    $stmt->execute();
    $materiasPorSeccion[$sec] = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
}

$pageTitle = 'Superadmin › Gestionar usuarios y permisos';
$backLink = 'dashboard.php';
include __DIR__ . '/../includes/header.php';
?>

<style>
.usuario-card {
    background: #f8fafc;
    border: 1px solid var(--color-border);
    border-radius: var(--radius);
    padding: 1rem;
    margin-bottom: 1rem;
}
.usuario-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1rem;
    padding-bottom: 0.5rem;
    border-bottom: 1px solid var(--color-border);
}
.permisos-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    gap: 0.5rem;
    margin-top: 0.5rem;
}
.permiso-item {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    font-size: 0.8rem;
}
</style>

<main class="container">
    <div class="card">
        <h2 class="section-title">👥 Gestionar usuarios y permisos</h2>
        <p class="form-hint">Administra roles y permisos de coordinadores y directores.</p>

        <?php if ($mensaje): ?>
            <p class="alert alert--success">✅ <?= htmlspecialchars($mensaje) ?></p>
        <?php endif; ?>
        <?php if ($error): ?>
            <p class="alert alert--error">⚠️ <?= htmlspecialchars($error) ?></p>
        <?php endif; ?>

        <?php foreach ($usuarios as $usuario): ?>
            <div class="usuario-card">
                <div class="usuario-header">
                    <div>
                        <strong><?= htmlspecialchars($usuario['username']) ?></strong>
                        <span class="badge"><?= htmlspecialchars($usuario['rol_nombre']) ?></span>
                    </div>
                    <form method="POST" style="display: inline;">
                        <input type="hidden" name="user_id" value="<?= $usuario['id'] ?>">
                        <select name="nuevo_rol" onchange="this.form.submit()">
                            <?php foreach ($roles as $rol): ?>
                                <option value="<?= $rol['id'] ?>" <?= $usuario['rol_id'] == $rol['id'] ? 'selected' : '' ?>>
                                    <?= htmlspecialchars($rol['nombre']) ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                        <button type="submit" name="cambiar_rol" class="btn btn--sm btn--accent">Cambiar rol</button>
                    </form>
                </div>
                
                <?php if ($usuario['rol_id'] != 1 && $usuario['rol_id'] != 4): ?>
                    <form method="POST">
                        <input type="hidden" name="user_id" value="<?= $usuario['id'] ?>">
                        <h4 style="margin: 0.5rem 0;">Permisos por sección:</h4>
                        
                        <?php foreach ($seccionesList as $sec): ?>
                            <div style="margin-bottom: 1rem;">
                                <label style="font-weight: 600;"><?= ucfirst($sec) ?></label>
                                <div class="permisos-grid">
                                    <?php foreach ($materiasPorSeccion[$sec] as $materia): ?>
                                        <?php
                                        // Verificar si tiene permiso
                                        $stmtCheck = $db->prepare("
                                            SELECT id FROM usuarios_permisos 
                                            WHERE user_id = ? AND seccion = ? AND materia_id = ?
                                        ");
                                        $stmtCheck->bind_param('isi', $usuario['id'], $sec, $materia['id']);
                                        $stmtCheck->execute();
                                        $hasPermiso = $stmtCheck->get_result()->num_rows > 0;
                                        ?>
                                        <div class="permiso-item">
                                            <input type="checkbox" name="secciones[<?= $sec ?>][]" value="<?= $materia['id'] ?>" <?= $hasPermiso ? 'checked' : '' ?>>
                                            <label><?= htmlspecialchars($materia['nombre']) ?></label>
                                        </div>
                                    <?php endforeach; ?>
                                </div>
                            </div>
                        <?php endforeach; ?>
                        
                        <button type="submit" name="guardar_permisos" class="btn btn--sm btn--success">Guardar permisos</button>
                    </form>
                <?php endif; ?>
            </div>
        <?php endforeach; ?>
        
        <div class="alert alert--info" style="margin-top: 1rem;">
            <strong>📌 Nota:</strong> Los superadministradores (rol 1) y profesores (rol 4) tienen acceso completo. Los coordinadores y directores requieren permisos específicos.
        </div>
    </div>
</main>

<?php include __DIR__ . '/../includes/footer.php(); ?>