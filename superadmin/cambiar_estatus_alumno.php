<?php
// superadmin/cambiar_estatus_alumno.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/UserModel.php';
require_once __DIR__ . '/../models/AlumnoModel.php';
requireRol([1]);

$db = getConexion();
$userModel = new UserModel($db);
$alumnoModel = new AlumnoModel($db, $userModel);

$alumnoId = (int)($_GET['id'] ?? 0);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $nuevoEstatus = $_POST['estatus'] ?? '';
    $resultado = $alumnoModel->cambiarEstatus($alumnoId, $nuevoEstatus);
    $msg = isset($resultado['success']) ? 'success' : 'error';
    $detalle = $resultado['mensaje'] ?? $resultado['error'] ?? '';
    header("Location: lista_alumnos.php?msg=$msg&detalle=" . urlencode($detalle));
    exit;
}

$alumno = $alumnoModel->obtenerPorId($alumnoId);
if (!$alumno) {
    header('Location: lista_alumnos.php?msg=error&detalle=Alumno no encontrado');
    exit;
}

$pageTitle = 'Cambiar estatus de alumno';
$backLink = 'lista_alumnos.php';
include __DIR__ . '/../includes/header.php';
?>

<main class="container container--sm">
    <div class="card">
        <h2 class="section-title">Cambiar estatus de alumno</h2>
        <p><strong><?= htmlspecialchars($alumno['nombre'] . ' ' . $alumno['apellido_paterno'] . ' ' . ($alumno['apellido_materno'] ?? '')) ?></strong></p>
        <p>Matrícula: <?= htmlspecialchars($alumno['matricula'] ?? '—') ?></p>
        <p>Estatus actual: 
            <?php
                $estatusActual = $alumno['estatus'] ?? 'regular';
                $badgeClass = match($estatusActual) {
                    'nuevo_ingreso' => 'badge--success',
                    'reinscripcion' => 'badge--accent',
                    'regular' => 'badge--active',
                    'baja' => 'badge--warn',
                    default => ''
                };
                $estatusTexto = match($estatusActual) {
                    'nuevo_ingreso' => '🆕 Nuevo Ingreso',
                    'reinscripcion' => '🔄 Reinscripción',
                    'regular' => '✅ Regular',
                    'baja' => '❌ Baja',
                    default => ucfirst($estatusActual)
                };
            ?>
            <span class="badge <?= $badgeClass ?>"><?= $estatusTexto ?></span>
        </p>
        
        <form method="POST">
            <input type="hidden" name="id" value="<?= $alumnoId ?>">
            <div class="form-group">
                <label for="estatus">Nuevo estatus</label>
                <select name="estatus" id="estatus" required>
                    <option value="">Selecciona...</option>
                    <option value="nuevo_ingreso" <?= $estatusActual === 'nuevo_ingreso' ? 'disabled' : '' ?>>🆕 Nuevo Ingreso</option>
                    <option value="reinscripcion" <?= $estatusActual === 'reinscripcion' ? 'disabled' : '' ?>>🔄 Reinscripción</option>
                    <option value="regular" <?= $estatusActual === 'regular' ? 'disabled' : '' ?>>✅ Regular</option>
                    <option value="baja" <?= $estatusActual === 'baja' ? 'disabled' : '' ?>>❌ Baja</option>
                </select>
            </div>
            <div style="display: flex; gap: 1rem;">
                <button type="submit" class="btn">Guardar cambio</button>
                <a href="lista_alumnos.php" class="btn btn--muted">Cancelar</a>
            </div>
        </form>
    </div>
</main>

<?php include __DIR__ . '/../includes/footer.php'; ?>