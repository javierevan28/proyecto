<?php
// superadmin/grados_materias.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/MateriaModel.php';
require_once __DIR__ . '/../models/CampoFormativoModel.php';
requireRol([1]);

$db = getConexion();
$materiaModelo = new MateriaModel($db);
$campoModelo = new CampoFormativoModel($db);

$mensaje = null;
$error = null;

// Procesar guardar
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['guardar'])) {
    $seccion = $_POST['seccion'];
    $grado = (int)$_POST['grado'];
    $materiasSeleccionadas = $_POST['materias'] ?? [];
    $ordenes = $_POST['orden'] ?? [];
    $camposFormativos = $_POST['campo_formativo'] ?? [];
    
    // ============================================================
    // 1. Obtener materias que estaban asignadas ANTES
    // ============================================================
    $stmtOld = $db->prepare("SELECT materia_id FROM grados_materias WHERE seccion = ? AND grado = ?");
    $stmtOld->bind_param('si', $seccion, $grado);
    $stmtOld->execute();
    $materiasViejas = $stmtOld->get_result()->fetch_all(MYSQLI_ASSOC);
    $materiasViejasIds = array_column($materiasViejas, 'materia_id');
    
    // ============================================================
    // 2. Materias que fueron DESMARCADAS (ya no están seleccionadas)
    // ============================================================
    $materiasEliminadas = array_diff($materiasViejasIds, $materiasSeleccionadas);
    
    // ============================================================
    // 3. SI SE DESMARCA UNA MATERIA, ELIMINAR TODAS SUS ASIGNACIONES DE GRUPOS
    // ============================================================
    if (!empty($materiasEliminadas)) {
        $placeholders = implode(',', array_fill(0, count($materiasEliminadas), '?'));
        
        // Eliminar asignacion_maestros
        $sql1 = "DELETE FROM asignacion_maestros WHERE asignacion_id IN (
            SELECT id FROM asignaciones 
            WHERE seccion = ? AND grado = ? AND materia_id IN ($placeholders)
        )";
        $stmt1 = $db->prepare($sql1);
        $types = 'si' . str_repeat('i', count($materiasEliminadas));
        $params = array_merge([$seccion, $grado], $materiasEliminadas);
        $stmt1->bind_param($types, ...$params);
        $stmt1->execute();
        
        // Eliminar asignacion_artes
        $sql2 = "DELETE FROM asignacion_artes WHERE asignacion_id IN (
            SELECT id FROM asignaciones 
            WHERE seccion = ? AND grado = ? AND materia_id IN ($placeholders)
        )";
        $stmt2 = $db->prepare($sql2);
        $stmt2->bind_param($types, ...$params);
        $stmt2->execute();
        
        // Eliminar asignacion_ingles_aspectos
        $sql3 = "DELETE FROM asignacion_ingles_aspectos WHERE asignacion_id IN (
            SELECT id FROM asignaciones 
            WHERE seccion = ? AND grado = ? AND materia_id IN ($placeholders)
        )";
        $stmt3 = $db->prepare($sql3);
        $stmt3->bind_param($types, ...$params);
        $stmt3->execute();
        
        // Eliminar asignaciones
        $sql4 = "DELETE FROM asignaciones WHERE seccion = ? AND grado = ? AND materia_id IN ($placeholders)";
        $stmt4 = $db->prepare($sql4);
        $stmt4->bind_param($types, ...$params);
        $stmt4->execute();
    }
    
    // ============================================================
    // 4. Eliminar asignaciones existentes de este grado en grados_materias
    // ============================================================
    $stmtDel = $db->prepare("DELETE FROM grados_materias WHERE seccion = ? AND grado = ?");
    $stmtDel->bind_param('si', $seccion, $grado);
    $stmtDel->execute();
    
    // ============================================================
    // 5. Insertar nuevas materias seleccionadas
    // ============================================================
    foreach ($materiasSeleccionadas as $materiaId) {
        $orden = isset($ordenes[$materiaId]) ? (int)$ordenes[$materiaId] : 0;
        $campoId = isset($camposFormativos[$materiaId]) && !empty($camposFormativos[$materiaId]) 
            ? (int)$camposFormativos[$materiaId] 
            : null;
        
        $stmtIns = $db->prepare("INSERT INTO grados_materias (seccion, grado, materia_id, campo_formativo_id, orden) VALUES (?, ?, ?, ?, ?)");
        $stmtIns->bind_param('siiii', $seccion, $grado, $materiaId, $campoId, $orden);
        $stmtIns->execute();
    }
    
    $mensaje = "Materias asignadas correctamente al grado.";
    if (!empty($materiasEliminadas)) {
        $mensaje .= " Se eliminaron " . count($materiasEliminadas) . " materia(s) y sus asignaciones de grupos.";
    }
}

// Obtener datos para la vista
$secciones = ['maternal', 'preescolar', 'primaria', 'secundaria'];
$grados = [1, 2, 3, 4, 5, 6];

// Obtener TODAS las materias activas
$todasMaterias = $materiaModelo->listarActivas();
$camposDisponibles = $campoModelo->listarActivos();

// Separar materias por tipo
$materiasBase = [];
$materiasIngles = [];
$materiasArtes = [];
$materiasCocurriculares = [];
$materiasHigiene = [];

foreach ($todasMaterias as $m) {
    if ((int)$m['es_ingles'] === 1) {
        $materiasIngles[] = $m;
    } elseif ((int)$m['es_artes'] === 1) {
        $materiasArtes[] = $m;
    } elseif ((int)$m['es_higiene'] === 1) {
        $materiasHigiene[] = $m;
    } else {
        $cocurriculares = ['Educación Física', 'Tecnología', 'Francés'];
        if (in_array($m['nombre'], $cocurriculares)) {
            $materiasCocurriculares[] = $m;
        } else {
            $materiasBase[] = $m;
        }
    }
}

$seccionActual = $_GET['seccion'] ?? 'primaria';
$gradoActual = (int)($_GET['grado'] ?? 1);
$tabActual = $_GET['tab'] ?? 'base';

// Obtener materias ya asignadas a este grado
$stmtAsig = $db->prepare("
    SELECT gm.materia_id, gm.orden, gm.campo_formativo_id,
           m.nombre, m.es_ingles, m.es_artes, m.es_higiene,
           cf.nombre as campo_formativo_nombre
    FROM grados_materias gm
    JOIN materias m ON m.id = gm.materia_id
    LEFT JOIN campos_formativos cf ON cf.id = COALESCE(gm.campo_formativo_id, m.campo_formativo_id)
    WHERE gm.seccion = ? AND gm.grado = ?
    ORDER BY gm.orden ASC
");
$stmtAsig->bind_param('si', $seccionActual, $gradoActual);
$stmtAsig->execute();
$materiasAsignadas = $stmtAsig->get_result()->fetch_all(MYSQLI_ASSOC);
$materiasAsignadasIds = array_column($materiasAsignadas, 'materia_id');

$pageTitle = 'Superadmin › Asignar materias por grado';
$backLink = 'dashboard.php';
include __DIR__ . '/../includes/header.php';
?>

<style>
    .tabs {
        display: flex;
        gap: 0.5rem;
        margin-bottom: 1.5rem;
        border-bottom: 1px solid var(--color-border);
        padding-bottom: 0.5rem;
        flex-wrap: wrap;
    }
    .tab-btn {
        background: none;
        border: none;
        padding: 0.5rem 1rem;
        font-size: 0.85rem;
        cursor: pointer;
        border-radius: var(--radius-sm);
        transition: all 0.15s;
        color: var(--color-muted);
    }
    .tab-btn:hover {
        background: #f1f5f9;
    }
    .tab-btn.active {
        background: var(--color-primary);
        color: white;
    }
    .tab-pane {
        display: none;
    }
    .tab-pane.active {
        display: block;
    }
    .materias-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
        gap: 0.5rem;
        margin-bottom: 1.5rem;
        max-height: 500px;
        overflow-y: auto;
        padding: 0.5rem;
        border: 1px solid var(--color-border);
        border-radius: var(--radius-sm);
        background: #fafafa;
    }
    .materia-item {
        display: flex;
        align-items: center;
        gap: 0.5rem;
        padding: 0.5rem;
        background: white;
        border-radius: var(--radius-sm);
        border: 1px solid var(--color-border);
        flex-wrap: wrap;
    }
    .materia-item .materia-info {
        display: flex;
        align-items: center;
        gap: 0.5rem;
        flex: 2;
        min-width: 180px;
    }
    .materia-item input[type="checkbox"] {
        width: 18px;
        height: 18px;
        cursor: pointer;
        accent-color: var(--color-primary);
        flex-shrink: 0;
    }
    .materia-item .materia-nombre {
        font-size: 0.85rem;
        font-weight: 500;
        flex: 1;
    }
    .materia-item select {
        width: 160px;
        padding: 0.3rem;
        font-size: 0.75rem;
        border: 1px solid #ccd3db;
        border-radius: 4px;
        background: white;
    }
    .materia-item .orden-input {
        width: 60px;
        padding: 0.3rem;
        text-align: center;
        border: 1px solid #ccd3db;
        border-radius: 4px;
        font-size: 0.75rem;
    }
    .badge-mini {
        font-size: 0.6rem;
        padding: 0.1rem 0.3rem;
        margin-left: 0.3rem;
    }
    .select-all {
        margin-bottom: 0.5rem;
        padding: 0.3rem 0.5rem;
        background: #f1f5f9;
        border-radius: var(--radius-sm);
        display: inline-block;
    }
    .select-all label {
        font-size: 0.75rem;
        cursor: pointer;
    }
    .campo-select {
        font-size: 0.75rem;
    }
    .btn {
        margin-top: 1rem;
    }
    .data-table thead th {
        text-align: left;
    }
    .data-table tbody td {
        text-align: left;
        vertical-align: middle;
    }
    .data-table tbody td:first-child {
        text-align: center;
        font-weight: 700;
        background: var(--color-primary);
        color: #fff;
        width: 80px;
    }
    .data-table tbody tr:last-child td:first-child {
        border-bottom-left-radius: var(--radius-sm);
    }
</style>

<main class="container">
    <div class="card">
        <h2 class="section-title">📚 Asignar materias por grado</h2>
        <p class="form-hint">Define qué materias se imparten en cada grado. Usa las pestañas para filtrar por tipo.</p>

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

        <form method="POST">
            <input type="hidden" name="seccion" value="<?= $seccionActual ?>">
            <input type="hidden" name="grado" value="<?= $gradoActual ?>">
            
            <!-- Pestañas -->
            <div class="tabs">
                <button type="button" class="tab-btn <?= $tabActual === 'base' ? 'active' : '' ?>" data-tab="base">📘 Materias Base</button>
                <button type="button" class="tab-btn <?= $tabActual === 'ingles' ? 'active' : '' ?>" data-tab="ingles">🌐 Inglés</button>
                <button type="button" class="tab-btn <?= $tabActual === 'artes' ? 'active' : '' ?>" data-tab="artes">🎨 Artes</button>
                <button type="button" class="tab-btn <?= $tabActual === 'cocurriculares' ? 'active' : '' ?>" data-tab="cocurriculares">🏃 Cocurriculares</button>
                <?php if (!empty($materiasHigiene)): ?>
                    <button type="button" class="tab-btn <?= $tabActual === 'higiene' ? 'active' : '' ?>" data-tab="higiene">🧼 Higiene</button>
                <?php endif; ?>
            </div>

            <!-- Pestaña Materias Base -->
            <div id="tab-base" class="tab-pane <?= $tabActual === 'base' ? 'active' : '' ?>">
                <div class="select-all">
                    <input type="checkbox" id="select-all-base" onchange="toggleAll('base', this.checked)">
                    <label for="select-all-base">Seleccionar todas las materias base</label>
                </div>
                <div class="materias-grid" id="grid-base">
                    <?php foreach ($materiasBase as $m): ?>
                        <?php 
                        $checked = in_array($m['id'], $materiasAsignadasIds);
                        $ordenActual = '';
                        $campoActual = $m['campo_formativo_id'] ?? '';
                        foreach ($materiasAsignadas as $ma) {
                            if ($ma['materia_id'] == $m['id']) {
                                $ordenActual = $ma['orden'];
                                $campoActual = $ma['campo_formativo_id'] ?? $m['campo_formativo_id'] ?? '';
                                break;
                            }
                        }
                        ?>
                        <div class="materia-item">
                            <div class="materia-info">
                                <input type="checkbox" name="materias[]" value="<?= $m['id'] ?>" id="base_<?= $m['id'] ?>" class="cb-base" <?= $checked ? 'checked' : '' ?>>
                                <label for="base_<?= $m['id'] ?>" class="materia-nombre"><?= htmlspecialchars($m['nombre']) ?></label>
                            </div>
                            <select name="campo_formativo[<?= $m['id'] ?>]" class="campo-select">
                                <option value="">Sin campo formativo</option>
                                <?php foreach ($camposDisponibles as $cf): ?>
                                    <option value="<?= $cf['id'] ?>" <?= $campoActual == $cf['id'] ? 'selected' : '' ?>>
                                        <?= htmlspecialchars($cf['nombre']) ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                            <input type="number" name="orden[<?= $m['id'] ?>]" value="<?= $ordenActual ?>" class="orden-input" placeholder="Ord" min="0">
                        </div>
                    <?php endforeach; ?>
                </div>
            </div>

            <!-- Pestaña Inglés -->
            <div id="tab-ingles" class="tab-pane <?= $tabActual === 'ingles' ? 'active' : '' ?>">
                <div class="select-all">
                    <input type="checkbox" id="select-all-ingles" onchange="toggleAll('ingles', this.checked)">
                    <label for="select-all-ingles">Seleccionar todas las materias de Inglés</label>
                </div>
                <div class="materias-grid" id="grid-ingles">
                    <?php foreach ($materiasIngles as $m): ?>
                        <?php 
                        $checked = in_array($m['id'], $materiasAsignadasIds);
                        $ordenActual = '';
                        $campoActual = $m['campo_formativo_id'] ?? 1;
                        foreach ($materiasAsignadas as $ma) {
                            if ($ma['materia_id'] == $m['id']) {
                                $ordenActual = $ma['orden'];
                                $campoActual = $ma['campo_formativo_id'] ?? $m['campo_formativo_id'] ?? 1;
                                break;
                            }
                        }
                        $gradoTexto = '';
                        if ($seccionActual === 'secundaria') {
                            $gradoTexto = $gradoActual . ' Sec';
                        } else {
                            $gradoTexto = $gradoActual . '°';
                        }
                        $nombreMostrar = $gradoTexto . ' - ' . $m['nombre'];
                        ?>
                        <div class="materia-item">
                            <div class="materia-info">
                                <input type="checkbox" name="materias[]" value="<?= $m['id'] ?>" id="ingles_<?= $m['id'] ?>" class="cb-ingles" <?= $checked ? 'checked' : '' ?>>
                                <label for="ingles_<?= $m['id'] ?>" class="materia-nombre">
                                    <?= htmlspecialchars($nombreMostrar) ?>
                                    <span class="badge badge-mini">Inglés</span>
                                </label>
                            </div>
                            <select name="campo_formativo[<?= $m['id'] ?>]" class="campo-select">
                                <option value="">Sin campo formativo</option>
                                <?php foreach ($camposDisponibles as $cf): ?>
                                    <option value="<?= $cf['id'] ?>" <?= $campoActual == $cf['id'] ? 'selected' : '' ?>>
                                        <?= htmlspecialchars($cf['nombre']) ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                            <input type="number" name="orden[<?= $m['id'] ?>]" value="<?= $ordenActual ?>" class="orden-input" placeholder="Ord" min="0">
                        </div>
                    <?php endforeach; ?>
                </div>
            </div>

            <!-- Pestaña Artes -->
            <div id="tab-artes" class="tab-pane <?= $tabActual === 'artes' ? 'active' : '' ?>">
                <div class="select-all">
                    <input type="checkbox" id="select-all-artes" onchange="toggleAll('artes', this.checked)">
                    <label for="select-all-artes">Seleccionar todas las materias de Artes</label>
                </div>
                <div class="materias-grid" id="grid-artes">
                    <?php foreach ($materiasArtes as $m): ?>
                        <?php 
                        $checked = in_array($m['id'], $materiasAsignadasIds);
                        $ordenActual = '';
                        $campoActual = $m['campo_formativo_id'] ?? '';
                        foreach ($materiasAsignadas as $ma) {
                            if ($ma['materia_id'] == $m['id']) {
                                $ordenActual = $ma['orden'];
                                $campoActual = $ma['campo_formativo_id'] ?? $m['campo_formativo_id'] ?? '';
                                break;
                            }
                        }
                        ?>
                        <div class="materia-item">
                            <div class="materia-info">
                                <input type="checkbox" name="materias[]" value="<?= $m['id'] ?>" id="artes_<?= $m['id'] ?>" class="cb-artes" <?= $checked ? 'checked' : '' ?>>
                                <label for="artes_<?= $m['id'] ?>" class="materia-nombre">
                                    <?= htmlspecialchars($m['nombre']) ?>
                                    <span class="badge badge-mini">Artes</span>
                                </label>
                            </div>
                            <select name="campo_formativo[<?= $m['id'] ?>]" class="campo-select">
                                <option value="">Sin campo formativo</option>
                                <?php foreach ($camposDisponibles as $cf): ?>
                                    <option value="<?= $cf['id'] ?>" <?= $campoActual == $cf['id'] ? 'selected' : '' ?>>
                                        <?= htmlspecialchars($cf['nombre']) ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                            <input type="number" name="orden[<?= $m['id'] ?>]" value="<?= $ordenActual ?>" class="orden-input" placeholder="Ord" min="0">
                        </div>
                    <?php endforeach; ?>
                </div>
            </div>

            <!-- Pestaña Cocurriculares -->
            <div id="tab-cocurriculares" class="tab-pane <?= $tabActual === 'cocurriculares' ? 'active' : '' ?>">
                <div class="select-all">
                    <input type="checkbox" id="select-all-cocurriculares" onchange="toggleAll('cocurriculares', this.checked)">
                    <label for="select-all-cocurriculares">Seleccionar todas las materias cocurriculares</label>
                </div>
                <div class="materias-grid" id="grid-cocurriculares">
                    <?php foreach ($materiasCocurriculares as $m): ?>
                        <?php 
                        $checked = in_array($m['id'], $materiasAsignadasIds);
                        $ordenActual = '';
                        $campoActual = $m['campo_formativo_id'] ?? '';
                        foreach ($materiasAsignadas as $ma) {
                            if ($ma['materia_id'] == $m['id']) {
                                $ordenActual = $ma['orden'];
                                $campoActual = $ma['campo_formativo_id'] ?? $m['campo_formativo_id'] ?? '';
                                break;
                            }
                        }
                        ?>
                        <div class="materia-item">
                            <div class="materia-info">
                                <input type="checkbox" name="materias[]" value="<?= $m['id'] ?>" id="cocurri_<?= $m['id'] ?>" class="cb-cocurriculares" <?= $checked ? 'checked' : '' ?>>
                                <label for="cocurri_<?= $m['id'] ?>" class="materia-nombre"><?= htmlspecialchars($m['nombre']) ?></label>
                            </div>
                            <select name="campo_formativo[<?= $m['id'] ?>]" class="campo-select">
                                <option value="">Sin campo formativo</option>
                                <?php foreach ($camposDisponibles as $cf): ?>
                                    <option value="<?= $cf['id'] ?>" <?= $campoActual == $cf['id'] ? 'selected' : '' ?>>
                                        <?= htmlspecialchars($cf['nombre']) ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                            <input type="number" name="orden[<?= $m['id'] ?>]" value="<?= $ordenActual ?>" class="orden-input" placeholder="Ord" min="0">
                        </div>
                    <?php endforeach; ?>
                </div>
            </div>

            <!-- Pestaña Higiene -->
            <?php if (!empty($materiasHigiene)): ?>
            <div id="tab-higiene" class="tab-pane <?= $tabActual === 'higiene' ? 'active' : '' ?>">
                <div class="select-all">
                    <input type="checkbox" id="select-all-higiene" onchange="toggleAll('higiene', this.checked)">
                    <label for="select-all-higiene">Seleccionar todas las materias de Higiene</label>
                </div>
                <div class="materias-grid" id="grid-higiene">
                    <?php foreach ($materiasHigiene as $m): ?>
                        <?php 
                        $checked = in_array($m['id'], $materiasAsignadasIds);
                        $ordenActual = '';
                        $campoActual = $m['campo_formativo_id'] ?? '';
                        foreach ($materiasAsignadas as $ma) {
                            if ($ma['materia_id'] == $m['id']) {
                                $ordenActual = $ma['orden'];
                                $campoActual = $ma['campo_formativo_id'] ?? $m['campo_formativo_id'] ?? '';
                                break;
                            }
                        }
                        ?>
                        <div class="materia-item">
                            <div class="materia-info">
                                <input type="checkbox" name="materias[]" value="<?= $m['id'] ?>" id="higiene_<?= $m['id'] ?>" class="cb-higiene" <?= $checked ? 'checked' : '' ?>>
                                <label for="higiene_<?= $m['id'] ?>" class="materia-nombre">
                                    <?= htmlspecialchars($m['nombre']) ?>
                                    <span class="badge badge-mini badge--warn">Higiene</span>
                                </label>
                            </div>
                            <select name="campo_formativo[<?= $m['id'] ?>]" class="campo-select">
                                <option value="">Sin campo formativo</option>
                                <?php foreach ($camposDisponibles as $cf): ?>
                                    <option value="<?= $cf['id'] ?>" <?= $campoActual == $cf['id'] ? 'selected' : '' ?>>
                                        <?= htmlspecialchars($cf['nombre']) ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                            <input type="number" name="orden[<?= $m['id'] ?>]" value="<?= $ordenActual ?>" class="orden-input" placeholder="Ord" min="0">
                        </div>
                    <?php endforeach; ?>
                </div>
            </div>
            <?php endif; ?>
            
            <button type="submit" name="guardar" class="btn">💾 Guardar asignación</button>
        </form>
        
        <hr style="margin: 2rem 0;">
        
        <h3>Materias actualmente asignadas a <?= ucfirst($seccionActual) ?> <?= $gradoActual ?>°</h3>
        <?php if (empty($materiasAsignadas)): ?>
            <p class="empty-state">No hay materias asignadas a este grado.</p>
        <?php else: ?>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Orden</th>
                        <th>Materia</th>
                        <th>Campo formativo</th>
                        <th>Tipo</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($materiasAsignadas as $ma): ?>
                        <?php
                        $tipoMateria = '';
                      if ((int)$ma['es_ingles']) {
    $tipoMateria = '<span class="badge">Inglés</span>';
    $nombreMostrar = $ma['nombre'];
} else {
    $tipoMateria = '<span class="badge">Base</span>';
    $nombreMostrar = $ma['nombre'];
}
                        ?>
                        <tr>
                            <td><?= $ma['orden'] ?></td>
                            <td><strong><?= htmlspecialchars($nombreMostrar) ?></strong></td>
                            <td><?= htmlspecialchars($ma['campo_formativo_nombre'] ?? '—') ?></td>
                            <td><?= $tipoMateria ?></td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        <?php endif; ?>
    </div>
</main>

<script>
function toggleAll(tab, checked) {
    const checkboxes = document.querySelectorAll(`#grid-${tab} input[type="checkbox"]`);
    checkboxes.forEach(cb => {
        cb.checked = checked;
    });
}

document.querySelectorAll('.tab-btn').forEach(btn => {
    btn.addEventListener('click', function() {
        const tabId = this.dataset.tab;
        const url = new URL(window.location.href);
        url.searchParams.set('tab', tabId);
        window.history.pushState({}, '', url);
        document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
        this.classList.add('active');
        document.querySelectorAll('.tab-pane').forEach(pane => pane.classList.remove('active'));
        document.getElementById(`tab-${tabId}`).classList.add('active');
    });
});
</script>

<?php include __DIR__ . '/../includes/footer.php'; ?>