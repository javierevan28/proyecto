<?php
// superadmin/ingles_aspectos.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
requireRol([1]);

$db = getConexion();
$mensaje = null;
$error = null;

// Procesar guardar
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['guardar'])) {
    $seccion = $_POST['seccion'];
    $grado = (int)$_POST['grado'];
    $aspectosSeleccionados = $_POST['aspectos'] ?? [];
    $ordenes = $_POST['orden'] ?? [];
    
    // Eliminar aspectos existentes de este grado
    $stmtDel = $db->prepare("DELETE FROM asignacion_ingles_aspectos WHERE seccion = ? AND grado = ? AND asignacion_id IS NULL");
    $stmtDel->bind_param('si', $seccion, $grado);
    $stmtDel->execute();
    
    // Insertar nuevos aspectos
    foreach ($aspectosSeleccionados as $aspectoId) {
        $orden = isset($ordenes[$aspectoId]) ? (int)$ordenes[$aspectoId] : 0;
        $nombre = '';
        
        // Obtener nombre del aspecto según su ID
        switch($aspectoId) {
            case 1: $nombre = 'Listening'; break;
            case 2: $nombre = 'Speaking'; break;
            case 3: $nombre = 'Reading'; break;
            case 4: $nombre = 'Writing'; break;
            case 5: $nombre = 'Vocabulary'; break;
            case 6: $nombre = 'Grammar'; break;
            case 7: $nombre = 'Spelling'; break;
            case 8: $nombre = 'Science'; break;
        }
        
        $stmtIns = $db->prepare("INSERT INTO asignacion_ingles_aspectos (seccion, grado, nombre, orden) VALUES (?, ?, ?, ?)");
        $stmtIns->bind_param('sisi', $seccion, $grado, $nombre, $orden);
        $stmtIns->execute();
    }
    
    $mensaje = "Aspectos de Inglés asignados correctamente al grado.";
}

// Obtener datos para la vista
$secciones = ['maternal', 'preescolar', 'primaria', 'secundaria'];
$grados = [1, 2, 3, 4, 5, 6];

$seccionActual = $_GET['seccion'] ?? 'primaria';
$gradoActual = (int)($_GET['grado'] ?? 1);

// Lista de todos los aspectos posibles
$todosAspectos = [
    ['id' => 1, 'nombre' => 'Listening'],
    ['id' => 2, 'nombre' => 'Speaking'],
    ['id' => 3, 'nombre' => 'Reading'],
    ['id' => 4, 'nombre' => 'Writing'],
    ['id' => 5, 'nombre' => 'Vocabulary'],
    ['id' => 6, 'nombre' => 'Grammar'],
    ['id' => 7, 'nombre' => 'Spelling'],
    ['id' => 8, 'nombre' => 'Science'],
];

// Obtener aspectos ya asignados a este grado
$stmtAsig = $db->prepare("
    SELECT nombre, orden FROM asignacion_ingles_aspectos 
    WHERE seccion = ? AND grado = ? AND asignacion_id IS NULL
    ORDER BY orden ASC
");
$stmtAsig->bind_param('si', $seccionActual, $gradoActual);
$stmtAsig->execute();
$aspectosAsignados = $stmtAsig->get_result()->fetch_all(MYSQLI_ASSOC);
$aspectosAsignadosNombres = array_column($aspectosAsignados, 'nombre');

$pageTitle = 'Superadmin › Asignar aspectos de Inglés por grado';
$backLink = 'dashboard.php';
include __DIR__ . '/../includes/header.php';
?>

<main class="container">
    <div class="card">
        <h2 class="section-title">🌐 Asignar aspectos de Inglés por grado</h2>
        <p class="form-hint">Define qué habilidades de Inglés (Listening, Speaking, etc.) se evalúan en cada grado.</p>

        <?php if ($mensaje): ?>
            <p class="alert alert--success">✅ <?= $mensaje ?></p>
        <?php endif; ?>
        <?php if ($error): ?>
            <p class="alert alert--error">⚠️ <?= $error ?></p>
        <?php endif; ?>

        <!-- Selector de sección y grado -->
        <form method="GET" style="margin-bottom: 1.5rem;">
            <div style="display: flex; gap: 1rem; align-items: center; flex-wrap: wrap;">
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
                        <?php foreach ($grados as $g): ?>
                            <option value="<?= $g ?>" <?= $gradoActual === $g ? 'selected' : '' ?>><?= $g ?>°</option>
                        <?php endforeach; ?>
                    </select>
                </div>
            </div>
        </form>

        <!-- Formulario de asignación -->
        <form method="POST">
            <input type="hidden" name="seccion" value="<?= $seccionActual ?>">
            <input type="hidden" name="grado" value="<?= $gradoActual ?>">
            
            <h3 style="margin-bottom: 1rem;">Aspectos de Inglés para <?= ucfirst($seccionActual) ?> <?= $gradoActual ?>°</h3>
            
            <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 0.5rem; margin-bottom: 1.5rem;">
                <?php foreach ($todosAspectos as $asp): ?>
                    <?php
                    $checked = in_array($asp['nombre'], $aspectosAsignadosNombres);
                    $ordenActual = '';
                    foreach ($aspectosAsignados as $aa) {
                        if ($aa['nombre'] == $asp['nombre']) {
                            $ordenActual = $aa['orden'];
                            break;
                        }
                    }
                    ?>
                    <div style="display: flex; align-items: center; gap: 0.5rem; padding: 0.3rem; background: #f8fafc; border-radius: 4px;">
                        <input type="checkbox" name="aspectos[]" value="<?= $asp['id'] ?>" id="aspecto_<?= $asp['id'] ?>" <?= $checked ? 'checked' : '' ?>>
                        <label for="aspecto_<?= $asp['id'] ?>" style="flex: 1;"><?= htmlspecialchars($asp['nombre']) ?></label>
                        <?php if ($checked): ?>
                            <input type="number" name="orden[<?= $asp['id'] ?>]" value="<?= $ordenActual ?>" style="width: 50px; padding: 0.2rem; text-align: center;" placeholder="orden">
                        <?php endif; ?>
                    </div>
                <?php endforeach; ?>
            </div>
            
            <button type="submit" name="guardar" class="btn">💾 Guardar asignación</button>
        </form>
        
        <hr style="margin: 2rem 0;">
        
        <h3>Aspectos actualmente asignados a <?= ucfirst($seccionActual) ?> <?= $gradoActual ?>°</h3>
        <?php if (empty($aspectosAsignados)): ?>
            <p class="empty-state">No hay aspectos de Inglés asignados a este grado.</p>
        <?php else: ?>
            <table class="data-table">
                <thead>
                    <tr><th>Orden</th><th>Aspecto</th></tr>
                </thead>
                <tbody>
                    <?php foreach ($aspectosAsignados as $aa): ?>
                        <tr>
                            <td><?= $aa['orden'] ?></td>
                            <td><strong><?= htmlspecialchars($aa['nombre']) ?></strong></td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        <?php endif; ?>
    </div>
</main>

<?php include __DIR__ . '/../includes/footer.php'; ?>