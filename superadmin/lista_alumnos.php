<?php
// superadmin/lista_alumnos.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/UserModel.php';
require_once __DIR__ . '/../models/AlumnoModel.php';
requireRol([1]);

$db = getConexion();

// ============================================
// MANEJAR PETICIÓN AJAX (búsqueda de alumnos)
// ============================================
if (isset($_GET['ajax']) && $_GET['ajax'] == 1) {
    header('Content-Type: application/json');
    
    $busqueda = $_GET['q'] ?? '';
    $limit = 10;
    
    if (strlen($busqueda) < 1) {
        echo json_encode([]);
        exit;
    }
    
    $sql = "
        SELECT 
            a.id,
            a.matricula,
            a.apellido_paterno,
            a.apellido_materno,
            a.nombre,
            a.grado,
            a.grupo,
            a.seccion,
            a.estatus,
            CONCAT(a.apellido_paterno, ' ', IFNULL(a.apellido_materno, ''), ' ', a.nombre) as nombre_completo
        FROM alumnos a
        WHERE a.activo = 1 
        AND (
            a.apellido_paterno LIKE ? 
            OR a.apellido_materno LIKE ? 
            OR a.nombre LIKE ? 
            OR a.matricula LIKE ?
            OR CONCAT(a.apellido_paterno, ' ', a.nombre) LIKE ?
        )
        ORDER BY 
            CASE 
                WHEN a.apellido_paterno LIKE ? THEN 1
                WHEN a.nombre LIKE ? THEN 2
                ELSE 3
            END,
            a.apellido_paterno, a.nombre
        LIMIT ?
    ";
    
    $like = "%{$busqueda}%";
    $stmt = $db->prepare($sql);
    $stmt->bind_param('ssssssssi', $like, $like, $like, $like, $like, $like, $like, $limit);
    $stmt->execute();
    $result = $stmt->get_result();
    $alumnos = $result->fetch_all(MYSQLI_ASSOC);
    
    echo json_encode($alumnos);
    exit;
}

// ============================================
// PROCESAMIENTO NORMAL DE LA PÁGINA
// ============================================

// Obtener filtros de la URL
$filters = [
    'busqueda' => $_GET['busqueda'] ?? '',
    'genero' => $_GET['genero'] ?? '',
    'seccion' => $_GET['seccion'] ?? '',
    'grado' => $_GET['grado'] ?? '',
    'grupo' => $_GET['grupo'] ?? '',
    'fecha_ingreso' => $_GET['fecha_ingreso'] ?? '',
    'estatus' => $_GET['estatus'] ?? '',
    'beca_interna' => $_GET['beca_interna'] ?? '',
    'beca_externa' => $_GET['beca_externa'] ?? '',
];

// Construir consulta SQL
$sql = "
    SELECT 
        a.id,
        a.matricula,
        a.apellido_paterno,
        a.apellido_materno,
        a.nombre,
        a.genero,
        a.fecha_nacimiento,
        a.fecha_ingreso,
        a.curp,
        a.estatus,
        a.seccion,
        a.grado,
        a.grupo,
        a.beca_interna,
        a.beca_externa,
        a.activo,
        p.nombre as padre_nombre,
        p.apellido_paterno as padre_apellido_paterno,
        p.apellido_materno as padre_apellido_materno,
        p.correo as padre_correo,
        p.telefono as padre_telefono
    FROM alumnos a
    LEFT JOIN padre_alumno pa ON pa.alumno_id = a.id
    LEFT JOIN padres p ON p.id = pa.padre_id
    WHERE 1=1
";

$params = [];
$types = "";

// Búsqueda en tiempo real
if (!empty($filters['busqueda'])) {
    $sql .= " AND (a.matricula LIKE ? OR a.apellido_paterno LIKE ? OR a.apellido_materno LIKE ? OR a.nombre LIKE ? OR CONCAT(a.apellido_paterno, ' ', a.nombre) LIKE ?)";
    $like = "%{$filters['busqueda']}%";
    $params[] = $like;
    $params[] = $like;
    $params[] = $like;
    $params[] = $like;
    $params[] = $like;
    $types .= "sssss";
}

// Filtro de género
if (!empty($filters['genero'])) {
    $sql .= " AND a.genero = ?";
    $params[] = $filters['genero'];
    $types .= "s";
}

// Filtro de sección
if (!empty($filters['seccion'])) {
    $sql .= " AND a.seccion = ?";
    $params[] = $filters['seccion'];
    $types .= "s";
}

// Filtro de grado
if (!empty($filters['grado'])) {
    $sql .= " AND a.grado = ?";
    $params[] = (int)$filters['grado'];
    $types .= "i";
}

// Filtro de grupo
if (!empty($filters['grupo'])) {
    $sql .= " AND a.grupo = ?";
    $params[] = $filters['grupo'];
    $types .= "s";
}

// Filtro de fecha de ingreso
if (!empty($filters['fecha_ingreso'])) {
    $sql .= " AND a.fecha_ingreso = ?";
    $params[] = $filters['fecha_ingreso'];
    $types .= "s";
}

// Filtro de estatus
if (!empty($filters['estatus'])) {
    $sql .= " AND a.estatus = ?";
    $params[] = $filters['estatus'];
    $types .= "s";
}

// Filtro de beca interna
if ($filters['beca_interna'] !== '') {
    $sql .= " AND a.beca_interna >= ?";
    $params[] = (float)$filters['beca_interna'];
    $types .= "d";
}

// Filtro de beca externa
if ($filters['beca_externa'] !== '') {
    $sql .= " AND a.beca_externa >= ?";
    $params[] = (float)$filters['beca_externa'];
    $types .= "d";
}

$sql .= " ORDER BY a.apellido_paterno, a.apellido_materno, a.nombre";

$stmt = $db->prepare($sql);
if (!empty($params)) {
    $stmt->bind_param($types, ...$params);
}
$stmt->execute();
$alumnos = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);

$estatusList = ['nuevo_ingreso' => '🆕 Nuevo Ingreso', 'reinscripcion' => '🔄 Reinscripción', 'regular' => 'Regular', 'baja' => 'Baja'];
$generosList = ['masculino' => 'Masculino', 'femenino' => 'Femenino', 'otro' => 'Otro'];
$seccionesList = ['maternal' => 'Maternal', 'preescolar' => 'Preescolar', 'primaria' => 'Primaria', 'secundaria' => 'Secundaria'];
$gradosList = [1, 2, 3, 4, 5, 6];
$gruposList = ['A', 'B', 'C', 'D'];

$pageTitle = 'Superadmin › Lista de Alumnos';
$backLink = 'dashboard.php';
include __DIR__ . '/../includes/header.php';
?>

<style>
    .search-section {
        position: relative;
        margin-bottom: 1.5rem;
    }
    
    .search-box-large {
        display: flex;
        gap: 0.75rem;
        align-items: center;
        background: var(--color-surface);
        border: 2px solid var(--color-border);
        border-radius: 50px;
        padding: 0.25rem 0.25rem 0.25rem 1.5rem;
        transition: all 0.3s;
    }
    
    .search-box-large:focus-within {
        border-color: var(--color-accent);
        box-shadow: 0 0 0 3px rgba(59,130,246,0.15);
    }
    
    .search-box-large input {
        flex: 1;
        border: none;
        padding: 0.9rem 0;
        font-size: 1rem;
        outline: none;
        background: transparent;
        font-family: var(--font);
    }
    
    .search-box-large button {
        background: var(--color-accent);
        border: none;
        color: white;
        padding: 0.7rem 1.8rem;
        border-radius: 50px;
        cursor: pointer;
        font-weight: 500;
        transition: background 0.2s;
        font-family: var(--font);
    }
    
    .search-box-large button:hover {
        background: #2563eb;
    }
    
    .suggestions-dropdown {
        position: absolute;
        top: calc(100% + 8px);
        left: 0;
        right: 0;
        background: var(--color-surface);
        border: 1px solid var(--color-border);
        border-radius: var(--radius);
        box-shadow: var(--shadow-lg);
        max-height: 350px;
        overflow-y: auto;
        z-index: 1000;
        display: none;
    }
    
    .suggestion-item {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 0.9rem 1.2rem;
        cursor: pointer;
        border-bottom: 1px solid var(--color-border);
        transition: background 0.15s;
    }
    
    .suggestion-item:last-child {
        border-bottom: none;
    }
    
    .suggestion-item:hover {
        background: var(--color-bg);
    }
    
    .suggestion-info {
        flex: 1;
    }
    
    .suggestion-name {
        font-weight: 600;
        color: var(--color-primary);
        margin-bottom: 0.3rem;
    }
    
    .suggestion-details {
        font-size: 0.7rem;
        color: var(--color-muted);
        display: flex;
        gap: 0.75rem;
        flex-wrap: wrap;
    }
    
    .suggestion-matricula {
        font-size: 0.7rem;
        background: var(--color-badge-bg);
        padding: 0.2rem 0.5rem;
        border-radius: 12px;
        color: var(--color-badge-tx);
        font-family: monospace;
    }
    
    .highlight {
        background-color: var(--color-warn-bg);
        font-weight: bold;
    }
    
    .filters-section {
        background: var(--color-bg);
        border-radius: var(--radius);
        padding: 1rem;
        margin-bottom: 1rem;
        display: flex;
        flex-wrap: wrap;
        gap: 1rem;
        align-items: flex-end;
    }
    
    .filter-item {
        flex: 1;
        min-width: 130px;
    }
    
    .filter-item label {
        display: block;
        font-size: 0.7rem;
        font-weight: 600;
        color: var(--color-muted);
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 0.3rem;
    }
    
    .filter-item select,
    .filter-item input {
        width: 100%;
        padding: 0.5rem 0.75rem;
        border: 1px solid var(--color-border);
        border-radius: var(--radius-sm);
        font-size: 0.85rem;
        font-family: var(--font);
        background: var(--color-surface);
        transition: all 0.2s;
    }
    
    .filter-item select:focus,
    .filter-item input:focus {
        outline: none;
        border-color: var(--color-accent);
        box-shadow: 0 0 0 3px rgba(59,130,246,0.15);
    }
    
    .btn-filter {
        background: var(--color-primary);
        color: white;
        padding: 0.5rem 1.2rem;
        border: none;
        border-radius: var(--radius-sm);
        cursor: pointer;
        font-weight: 500;
        transition: background 0.2s;
        width: 100%;
        font-family: var(--font);
    }
    
    .btn-filter:hover {
        background: var(--color-primary-h);
    }
    
    .results-toolbar {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 1rem;
        flex-wrap: wrap;
        gap: 0.5rem;
    }
    
    .total-badge {
        background: var(--color-primary);
        color: white;
        padding: 0.25rem 0.75rem;
        border-radius: 20px;
        font-size: 0.8rem;
        font-weight: 600;
    }
    
    .badge-genero {
        display: inline-block;
        padding: 0.2rem 0.5rem;
        border-radius: 12px;
        font-size: 0.7rem;
        font-weight: 500;
    }
    .badge-masculino { background: #dbeafe; color: #1e3a8a; }
    .badge-femenino { background: #fce7f3; color: #9d174d; }
    .badge-otro { background: #f1f5f9; color: #475569; }
    
    .badge-seccion {
        display: inline-block;
        padding: 0.2rem 0.5rem;
        border-radius: 12px;
        font-size: 0.7rem;
        font-weight: 500;
    }
    .badge-maternal { background: #fef3c7; color: #92400e; }
    .badge-preescolar { background: #d1fae5; color: #065f46; }
    .badge-primaria { background: #dbeafe; color: #1d4ed8; }
    .badge-secundaria { background: #e0e7ff; color: #3730a3; }
    
    .beca-value {
        font-family: monospace;
        font-weight: 600;
        color: #059669;
    }
    
    .clickable-row {
        cursor: pointer;
        transition: background 0.2s;
    }
    
    .clickable-row:hover {
        background: var(--color-bg) !important;
    }
    
    .btn-clear {
        background: #fee2e2;
        color: #991b1b;
        padding: 0.5rem 1.2rem;
        border: none;
        border-radius: var(--radius-sm);
        cursor: pointer;
        font-weight: 500;
        transition: background 0.2s;
        text-decoration: none;
        display: inline-block;
        text-align: center;
        width: 100%;
        font-family: var(--font);
    }
    
    .btn-clear:hover {
        background: #fecaca;
    }

    .action-buttons {
        display: flex;
        gap: 4px;
        flex-wrap: wrap;
        justify-content: center;
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

    .status-badge {
        display: inline-block;
        padding: 0.2rem 0.6rem;
        border-radius: 12px;
        font-size: 0.7rem;
        font-weight: 600;
    }

    .status-active {
        background: #d1fae5;
        color: #065f46;
    }

    .status-inactive {
        background: #fee2e2;
        color: #991b1b;
    }

    .telefono-link {
        color: var(--color-accent);
        text-decoration: none;
        font-size: 0.75rem;
    }
    .telefono-link:hover {
        text-decoration: underline;
    }

    @media (max-width: 600px) {
        .modal-grid {
            grid-template-columns: 1fr;
        }
    }
</style>

<main class="container">
    <div class="card">
        <h2 class="section-title">📋 Alumnos Registrados</h2>
        
        <!-- Búsqueda principal con autocompletado -->
        <div class="search-section">
            <div class="search-box-large">
                <input type="text" 
                       id="busquedaInput"
                       value="<?= htmlspecialchars($filters['busqueda']) ?>"
                       placeholder="🔍 Buscar por nombre, apellido, matrícula o padre..."
                       autocomplete="off">
                <button type="button" onclick="aplicarFiltros()">Buscar</button>
                
                <div id="suggestionsDropdown" class="suggestions-dropdown"></div>
            </div>
        </div>
        
        <!-- Filtros rápidos -->
        <div class="filters-section">
            <div class="filter-item">
                <label>⚥ Género</label>
                <select id="generoFilter">
                    <option value="">Todos</option>
                    <?php foreach ($generosList as $val => $label): ?>
                        <option value="<?= $val ?>" <?= $filters['genero'] === $val ? 'selected' : '' ?>><?= $label ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            
            <div class="filter-item">
                <label>🏫 Sección</label>
                <select id="seccionFilter">
                    <option value="">Todas</option>
                    <?php foreach ($seccionesList as $val => $label): ?>
                        <option value="<?= $val ?>" <?= $filters['seccion'] === $val ? 'selected' : '' ?>><?= $label ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            
            <div class="filter-item">
                <label>🎓 Grado</label>
                <select id="gradoFilter">
                    <option value="">Todos</option>
                    <?php foreach ($gradosList as $g): ?>
                        <option value="<?= $g ?>" <?= $filters['grado'] == $g ? 'selected' : '' ?>><?= $g ?>°</option>
                    <?php endforeach; ?>
                </select>
            </div>
            
            <div class="filter-item">
                <label>🔤 Grupo</label>
                <select id="grupoFilter">
                    <option value="">Todos</option>
                    <?php foreach ($gruposList as $g): ?>
                        <option value="<?= $g ?>" <?= $filters['grupo'] === $g ? 'selected' : '' ?>><?= $g ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            
            <div class="filter-item">
                <label>📅 Fecha ingreso</label>
                <input type="date" id="fechaIngresoFilter" value="<?= htmlspecialchars($filters['fecha_ingreso']) ?>">
            </div>
            
            <div class="filter-item">
                <label>📊 Estatus</label>
                <select id="estatusFilter">
                    <option value="">Todos</option>
                    <?php foreach ($estatusList as $val => $label): ?>
                        <option value="<?= $val ?>" <?= $filters['estatus'] === $val ? 'selected' : '' ?>><?= $label ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            
            <div class="filter-item">
                <label>💰 Beca interna (≥)</label>
                <input type="number" id="becaInternaFilter" step="0.01" placeholder="Monto mínimo" value="<?= htmlspecialchars($filters['beca_interna']) ?>">
            </div>
            
            <div class="filter-item">
                <label>💵 Beca externa (≥)</label>
                <input type="number" id="becaExternaFilter" step="0.01" placeholder="Monto mínimo" value="<?= htmlspecialchars($filters['beca_externa']) ?>">
            </div>
            
            <div class="filter-item" style="flex: 0.5;">
                <button class="btn-filter" onclick="aplicarFiltros()">🔍 Aplicar</button>
            </div>
            
            <?php
            $hasFilters = false;
            foreach ($filters as $key => $value) {
                if (!empty($value) && $key !== 'page') {
                    $hasFilters = true;
                    break;
                }
            }
            if ($hasFilters): ?>
                <div class="filter-item" style="flex: 0.3;">
                    <a href="lista_alumnos.php" class="btn-clear" style="text-align: center;">🗑️ Limpiar</a>
                </div>
            <?php endif; ?>
        </div>
        
        <!-- Resultados toolbar -->
        <div class="results-toolbar">
            <div>
                <span class="total-badge">Total: <?= count($alumnos) ?> alumnos</span>
            </div>
            <a href="alta_alumno.php" class="btn btn--sm btn--accent">➕ Nuevo Alumno</a>
        </div>
        
        <!-- Tabla -->
        <div class="table-responsive">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Matrícula</th>
                        <th>Apellido paterno</th>
                        <th>Apellido materno</th>
                        <th>Nombre(s)</th>
                        <th>Género</th>
                        <th>Sección</th>
                        <th>Grado</th>
                        <th>Grupo</th>
                        <th>Estatus</th>
                        <th>Beca interna</th>
                        <th>Beca externa</th>
                        <!-- <--- NUEVAS COLUMNAS -->
                        <th>F. Nacimiento</th>
                        <th>F. Ingreso</th>
                        <th>CURP</th>
                        <th>Estado</th>
                        <th>Padre/Tutor</th>
                        <th>Teléfono</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($alumnos)): ?>
                        <tr class="empty-row">
                            <td colspan="19">
                                📭 No se encontraron alumnos<br>
                                <small>Prueba con otros criterios de búsqueda o <a href="lista_alumnos.php">limpia los filtros</a></small>
                            </td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($alumnos as $alumno): ?>
                            <?php
                            $estatusClass = match($alumno['estatus'] ?? 'regular') {
                                'nuevo_ingreso' => 'badge--success',
                                'reinscripcion' => 'badge--accent',
                                'regular' => 'badge--active',
                                'baja' => 'badge--warn',
                                default => ''
                            };
                            $estatusTexto = match($alumno['estatus'] ?? 'regular') {
                                'nuevo_ingreso' => '🆕 Nuevo Ingreso',
                                'reinscripcion' => '🔄 Reinscripción',
                                'regular' => 'Regular',
                                'baja' => 'Baja',
                                default => ucfirst($alumno['estatus'] ?? 'regular')
                            };
                            $generoClass = 'badge-genero badge-' . ($alumno['genero'] ?? 'otro');
                            $seccionClass = 'badge-seccion badge-' . ($alumno['seccion'] ?? 'primaria');
                            $seccionTexto = ucfirst($alumno['seccion'] ?? 'Primaria');
                            $nombrePadre = trim(($alumno['padre_apellido_paterno'] ?? '') . ' ' . ($alumno['padre_apellido_materno'] ?? '') . ' ' . ($alumno['padre_nombre'] ?? ''));
                            if (empty($nombrePadre)) {
                                $nombrePadre = '—';
                            }
                            $telefonoPadre = $alumno['padre_telefono'] ?? '';
                            $isActive = (int)($alumno['activo'] ?? 1) === 1;
                            ?>
                            <tr class="clickable-row" onclick="window.location.href='documentos_alumnos.php?alumno_id=<?= $alumno['id'] ?>'">
                                <td><strong><?= htmlspecialchars($alumno['matricula'] ?? '—') ?></strong></td>
                                <td><?= htmlspecialchars($alumno['apellido_paterno']) ?></td>
                                <td><?= htmlspecialchars($alumno['apellido_materno'] ?? '—') ?></td>
                                <td><?= htmlspecialchars($alumno['nombre']) ?></td>
                                <td><span class="<?= $generoClass ?>"><?= htmlspecialchars($alumno['genero']) ?></span></td>
                                <td><span class="<?= $seccionClass ?>"><?= $seccionTexto ?></span></td>
                                <td><?= $alumno['grado'] ?>°</td>
                                <td><?= $alumno['grupo'] ?></td>
                                <td><span class="badge <?= $estatusClass ?>"><?= $estatusTexto ?></span></td>
                                <td class="beca-value">$<?= number_format($alumno['beca_interna'] ?? 0, 2) ?></td>
                                <td class="beca-value">$<?= number_format($alumno['beca_externa'] ?? 0, 2) ?></td>
                                <!-- <--- NUEVAS COLUMNAS: F. Nacimiento, F. Ingreso, CURP -->
                                <td><?= date('d/m/Y', strtotime($alumno['fecha_nacimiento'])) ?></td>
                                <td><?= date('d/m/Y', strtotime($alumno['fecha_ingreso'])) ?></td>
                                <td><?= htmlspecialchars($alumno['curp'] ?? '—') ?></td>
                                <td>
                                    <span class="status-badge <?= $isActive ? 'status-active' : 'status-inactive' ?>">
                                        <?= $isActive ? 'Activo' : 'Inactivo' ?>
                                    </span>
                                </td>
                                <td><?= htmlspecialchars($nombrePadre) ?></td>
                                <td>
                                    <?php if (!empty($telefonoPadre)): ?>
                                        <a href="tel:<?= htmlspecialchars($telefonoPadre) ?>" class="telefono-link">
                                            📞 <?= htmlspecialchars($telefonoPadre) ?>
                                        </a>
                                    <?php else: ?>
                                        <span style="color: var(--color-muted);">—</span>
                                    <?php endif; ?>
                                </td>
                                <td>
                                    <div class="action-buttons" onclick="event.stopPropagation();">
                                        <button class="btn-action btn-edit" onclick="editarAlumno(<?= $alumno['id'] ?>)">
                                            Editar
                                        </button>
                                        <?php if ($isActive): ?>
                                            <button class="btn-action btn-deactivate" onclick="darDeBaja(<?= $alumno['id'] ?>, '<?= htmlspecialchars($alumno['nombre'] . ' ' . $alumno['apellido_paterno']) ?>')">
                                                Baja
                                            </button>
                                        <?php else: ?>
                                            <button class="btn-action btn-activate" onclick="reactivarAlumno(<?= $alumno['id'] ?>)">
                                                Reactivar
                                            </button>
                                        <?php endif; ?>
                                    </div>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</main>

<!-- Modal Editar -->
<div id="editModal" class="modal-overlay">
    <div class="modal-content">
        <button class="modal-close" onclick="cerrarModal()">&times;</button>
        <h3 class="modal-title">✏️ Editar Alumno</h3>
        <form id="editForm">
            <input type="hidden" id="editId" name="id">
            
            <div class="modal-grid">
                <div class="modal-field">
                    <label>Matrícula</label>
                    <input type="text" id="editMatricula" name="matricula" placeholder="Ej: CEFXXX202600001">
                </div>
                <div class="modal-field">
                    <label>Estatus</label>
                    <select id="editEstatus" name="estatus">
                        <option value="nuevo_ingreso">🆕 Nuevo Ingreso</option>
                        <option value="reinscripcion">🔄 Reinscripción</option>
                        <option value="regular">Regular</option>
                        <option value="baja">Baja</option>
                    </select>
                </div>
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
                        <option value="masculino">Masculino</option>
                        <option value="femenino">Femenino</option>
                        <option value="otro">Otro</option>
                    </select>
                </div>
                <div class="modal-field">
                    <label>Sección *</label>
                    <select id="editSeccion" name="seccion" required>
                        <option value="maternal">Maternal</option>
                        <option value="preescolar">Preescolar</option>
                        <option value="primaria">Primaria</option>
                        <option value="secundaria">Secundaria</option>
                    </select>
                </div>
                <div class="modal-field">
                    <label>Grado *</label>
                    <select id="editGrado" name="grado" required>
                        <?php for ($g = 1; $g <= 6; $g++): ?>
                            <option value="<?= $g ?>"><?= $g ?>°</option>
                        <?php endfor; ?>
                    </select>
                </div>
                <div class="modal-field">
                    <label>Grupo *</label>
                    <select id="editGrupo" name="grupo" required>
                        <?php foreach (['A','B','C','D'] as $g): ?>
                            <option value="<?= $g ?>"><?= $g ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="modal-field">
                    <label>CURP</label>
                    <input type="text" id="editCurp" name="curp" maxlength="18" placeholder="18 caracteres" style="text-transform: uppercase;">
                </div>
                <div class="modal-field">
                    <label>Fecha Nacimiento *</label>
                    <input type="date" id="editFechaNacimiento" name="fecha_nacimiento" required>
                </div>
                <div class="modal-field">
                    <label>Fecha Ingreso *</label>
                    <input type="date" id="editFechaIngreso" name="fecha_ingreso" required>
                </div>
                <div class="modal-field">
                    <label>Beca Interna ($)</label>
                    <input type="number" id="editBecaInterna" name="beca_interna" step="0.01" min="0" placeholder="0.00">
                </div>
                <div class="modal-field">
                    <label>Beca Externa ($)</label>
                    <input type="number" id="editBecaExterna" name="beca_externa" step="0.01" min="0" placeholder="0.00">
                </div>
            </div>
            
            <div class="modal-actions">
                <button type="button" class="btn-modal-cancel" onclick="cerrarModal()">Cancelar</button>
                <button type="submit" class="btn-modal-save">💾 Guardar Cambios</button>
            </div>
        </form>
    </div>
</div>

<!-- Modal Confirmación Baja -->
<div id="bajaModal" class="modal-overlay">
    <div class="modal-content" style="max-width: 450px;">
        <button class="modal-close" onclick="cerrarBajaModal()">&times;</button>
        <h3 class="modal-title" style="color: #dc2626;">⚠️ Confirmar Baja</h3>
        <p style="margin-bottom: 1.5rem; color: #475569;">
            ¿Estás seguro de que deseas dar de baja al alumno <strong id="bajaNombre"></strong>?
            <br><small>El alumno dejará de aparecer en listas activas, pero sus datos permanecerán en el sistema.</small>
        </p>
        <form id="bajaForm">
            <input type="hidden" id="bajaId" name="id">
            <div class="modal-field">
                <label>Motivo de baja (opcional)</label>
                <input type="text" id="bajaMotivo" name="motivo" placeholder="Ej: Cambio de escuela, Inasistencias, etc.">
            </div>
            <div class="modal-actions">
                <button type="button" class="btn-modal-cancel" onclick="cerrarBajaModal()">Cancelar</button>
                <button type="submit" class="btn-modal-danger">⛔ Confirmar Baja</button>
            </div>
        </form>
    </div>
</div>

<script>
let timeoutId;
let currentRequest = null;
let editingAlumnoId = null;

const busquedaInput = document.getElementById('busquedaInput');
const suggestionsDropdown = document.getElementById('suggestionsDropdown');

// ============================================================
// BÚSQUEDA CON SUGERENCIAS
// ============================================================
function buscarSugerencias() {
    const query = busquedaInput.value.trim();
    
    if (query.length < 1) {
        suggestionsDropdown.style.display = 'none';
        return;
    }
    
    if (currentRequest) {
        currentRequest.abort();
    }
    
    currentRequest = new XMLHttpRequest();
    currentRequest.open('GET', `?ajax=1&q=${encodeURIComponent(query)}`, true);
    currentRequest.onreadystatechange = function() {
        if (this.readyState === 4 && this.status === 200) {
            try {
                const alumnos = JSON.parse(this.responseText);
                mostrarSugerencias(alumnos, query);
                currentRequest = null;
            } catch(e) {
                console.error('Error:', e);
            }
        }
    };
    currentRequest.send();
}

function mostrarSugerencias(alumnos, query) {
    if (alumnos.length === 0) {
        suggestionsDropdown.style.display = 'none';
        return;
    }
    
    const regex = new RegExp(`(${query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')})`, 'gi');
    
    let html = '';
    alumnos.forEach(alumno => {
        const nombreCompleto = `${alumno.apellido_paterno} ${alumno.apellido_materno || ''} ${alumno.nombre}`.replace(/\s+/g, ' ').trim();
        const nombreResaltado = nombreCompleto.replace(regex, '<span class="highlight">$1</span>');
        
        const estatusIcon = {
            'nuevo_ingreso': '🆕',
            'reinscripcion': '🔄',
            'regular': '',
            'baja': '❌'
        }[alumno.estatus] || '📌';
        
        html += `
            <div class="suggestion-item" onclick="seleccionarSugerencia(${alumno.id})">
                <div class="suggestion-info">
                    <div class="suggestion-name">${nombreResaltado}</div>
                    <div class="suggestion-details">
                        <span>📌 ${alumno.matricula || '—'}</span>
                        <span>🎓 ${alumno.grado}° ${alumno.grupo}</span>
                        <span>🏫 ${alumno.seccion}</span>
                        <span>${estatusIcon} ${alumno.estatus?.replace('_', ' ') || 'regular'}</span>
                    </div>
                </div>
                <div class="suggestion-matricula">🔍 Ver detalles</div>
            </div>
        `;
    });
    
    suggestionsDropdown.innerHTML = html;
    suggestionsDropdown.style.display = 'block';
}

function seleccionarSugerencia(alumnoId) {
    window.location.href = `documentos_alumnos.php?alumno_id=${alumnoId}`;
}

function aplicarFiltros() {
    const params = new URLSearchParams();
    
    const busqueda = document.getElementById('busquedaInput')?.value;
    if (busqueda) params.set('busqueda', busqueda);
    
    const genero = document.getElementById('generoFilter')?.value;
    if (genero) params.set('genero', genero);
    
    const seccion = document.getElementById('seccionFilter')?.value;
    if (seccion) params.set('seccion', seccion);
    
    const grado = document.getElementById('gradoFilter')?.value;
    if (grado) params.set('grado', grado);
    
    const grupo = document.getElementById('grupoFilter')?.value;
    if (grupo) params.set('grupo', grupo);
    
    const fechaIngreso = document.getElementById('fechaIngresoFilter')?.value;
    if (fechaIngreso) params.set('fecha_ingreso', fechaIngreso);
    
    const estatus = document.getElementById('estatusFilter')?.value;
    if (estatus) params.set('estatus', estatus);
    
    const becaInterna = document.getElementById('becaInternaFilter')?.value;
    if (becaInterna !== '') params.set('beca_interna', becaInterna);
    
    const becaExterna = document.getElementById('becaExternaFilter')?.value;
    if (becaExterna !== '') params.set('beca_externa', becaExterna);
    
    window.location.href = '?' + params.toString();
}

// ============================================================
// MODAL EDITAR
// ============================================================
function editarAlumno(id) {
    const botones = document.querySelectorAll('.btn-edit');
    let boton = null;
    botones.forEach(b => {
        if (b.closest('tr').querySelector(`[onclick*="editarAlumno(${id})"]`)) {
            boton = b;
        }
    });
    
    if (boton) {
        boton.textContent = 'Cargando...';
        boton.disabled = true;
    }
    
    fetch(`api_alumno.php?action=get&id=${id}`)
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.json();
        })
        .then(data => {
            if (data.success) {
                const a = data.data;
                document.getElementById('editId').value = a.id;
                document.getElementById('editMatricula').value = a.matricula || '';
                document.getElementById('editNombre').value = a.nombre;
                document.getElementById('editApellidoPaterno').value = a.apellido_paterno;
                document.getElementById('editApellidoMaterno').value = a.apellido_materno || '';
                document.getElementById('editGenero').value = a.genero;
                document.getElementById('editSeccion').value = a.seccion;
                document.getElementById('editGrado').value = a.grado;
                document.getElementById('editGrupo').value = a.grupo;
                document.getElementById('editCurp').value = a.curp || '';
                document.getElementById('editFechaNacimiento').value = a.fecha_nacimiento;
                document.getElementById('editFechaIngreso').value = a.fecha_ingreso;
                document.getElementById('editEstatus').value = a.estatus || 'regular';
                document.getElementById('editBecaInterna').value = a.beca_interna || 0;
                document.getElementById('editBecaExterna').value = a.beca_externa || 0;
                
                document.getElementById('editModal').classList.add('active');
                editingAlumnoId = id;
            } else {
                alert('Error: ' + (data.message || 'No se pudieron cargar los datos'));
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Error al cargar los datos del alumno. Revisa la consola para más detalles.');
        })
        .finally(() => {
            if (boton) {
                boton.textContent = '✏️ Editar';
                boton.disabled = false;
            }
        });
}

// ============================================================
// FORMULARIO DE EDICIÓN
// ============================================================
document.getElementById('editForm').addEventListener('submit', function(e) {
    e.preventDefault();
    
    const nombre = document.getElementById('editNombre').value.trim();
    const apellido = document.getElementById('editApellidoPaterno').value.trim();
    const fechaNac = document.getElementById('editFechaNacimiento').value;
    const fechaIng = document.getElementById('editFechaIngreso').value;
    const genero = document.getElementById('editGenero').value;
    const seccion = document.getElementById('editSeccion').value;
    const grado = document.getElementById('editGrado').value;
    const grupo = document.getElementById('editGrupo').value;
    const curp = document.getElementById('editCurp').value.trim();
    
    if (!nombre) {
        alert('El nombre es obligatorio');
        document.getElementById('editNombre').focus();
        return;
    }
    if (!apellido) {
        alert('El apellido paterno es obligatorio');
        document.getElementById('editApellidoPaterno').focus();
        return;
    }
    if (!fechaNac) {
        alert('La fecha de nacimiento es obligatoria');
        document.getElementById('editFechaNacimiento').focus();
        return;
    }
    if (!fechaIng) {
        alert('La fecha de ingreso es obligatoria');
        document.getElementById('editFechaIngreso').focus();
        return;
    }
    if (!genero || !['masculino', 'femenino', 'otro'].includes(genero)) {
        alert('Selecciona un género válido');
        return;
    }
    if (!seccion || !['maternal', 'preescolar', 'primaria', 'secundaria'].includes(seccion)) {
        alert('Selecciona una sección válida');
        return;
    }
    if (!grado || grado < 1 || grado > 6) {
        alert('Selecciona un grado válido (1-6)');
        return;
    }
    if (!grupo || !['A', 'B', 'C', 'D'].includes(grupo)) {
        alert('Selecciona un grupo válido');
        return;
    }
    if (curp && curp.length !== 18) {
        alert('El CURP debe tener exactamente 18 caracteres');
        document.getElementById('editCurp').focus();
        return;
    }
    
    const submitBtn = this.querySelector('button[type="submit"]');
    const originalText = submitBtn.textContent;
    submitBtn.textContent = 'Guardando...';
    submitBtn.disabled = true;
    
    const formData = new FormData(this);
    formData.append('action', 'update');
    
    fetch('api_alumno.php', {
        method: 'POST',
        body: formData
    })
    .then(async response => {
        const text = await response.text();
        try {
            const data = JSON.parse(text);
            if (!response.ok) {
                throw new Error(data.message || `HTTP ${response.status}`);
            }
            return data;
        } catch (e) {
            throw new Error('Respuesta del servidor no válida');
        }
    })
    .then(data => {
        if (data.success) {
            alert('Alumno actualizado correctamente');
            cerrarModal();
            location.reload();
        } else {
            alert('Error: ' + (data.message || 'No se pudo actualizar el alumno'));
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Error al guardar: ' + error.message);
    })
    .finally(() => {
        submitBtn.textContent = originalText;
        submitBtn.disabled = false;
    });
});

// ============================================================
// MODAL BAJA / REACTIVACIÓN
// ============================================================
function darDeBaja(id, nombre) {
    document.getElementById('bajaId').value = id;
    document.getElementById('bajaNombre').textContent = nombre;
    document.getElementById('bajaMotivo').value = '';
    document.getElementById('bajaModal').classList.add('active');
}

function cerrarBajaModal() {
    document.getElementById('bajaModal').classList.remove('active');
}

document.getElementById('bajaForm').addEventListener('submit', function(e) {
    e.preventDefault();
    
    const submitBtn = this.querySelector('button[type="submit"]');
    const originalText = submitBtn.textContent;
    submitBtn.textContent = 'Procesando...';
    submitBtn.disabled = true;
    
    const formData = new FormData(this);
    formData.append('action', 'deactivate');
    
    fetch('api_alumno.php', {
        method: 'POST',
        body: formData
    })
    .then(async response => {
        const text = await response.text();
        try {
            const data = JSON.parse(text);
            if (!response.ok) {
                throw new Error(data.message || `HTTP ${response.status}`);
            }
            return data;
        } catch (e) {
            throw new Error('Respuesta no válida');
        }
    })
    .then(data => {
        if (data.success) {
            alert('Alumno dado de baja correctamente');
            cerrarBajaModal();
            location.reload();
        } else {
            alert('Error: ' + (data.message || 'No se pudo dar de baja al alumno'));
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Error al procesar la baja: ' + error.message);
    })
    .finally(() => {
        submitBtn.textContent = originalText;
        submitBtn.disabled = false;
    });
});

function reactivarAlumno(id) {
    if (!confirm('¿Estás seguro de que deseas reactivar a este alumno?')) return;
    
    const formData = new FormData();
    formData.append('action', 'activate');
    formData.append('id', id);
    
    fetch('api_alumno.php', {
        method: 'POST',
        body: formData
    })
    .then(async response => {
        const text = await response.text();
        try {
            const data = JSON.parse(text);
            if (!response.ok) {
                throw new Error(data.message || `HTTP ${response.status}`);
            }
            return data;
        } catch (e) {
            throw new Error('Respuesta no válida');
        }
    })
    .then(data => {
        if (data.success) {
            alert('Alumno reactivado correctamente');
            location.reload();
        } else {
            alert('Error: ' + (data.message || 'No se pudo reactivar al alumno'));
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Error al procesar la reactivación: ' + error.message);
    });
}

function cerrarModal() {
    document.getElementById('editModal').classList.remove('active');
    editingAlumnoId = null;
}

// ============================================================
// EVENTOS Y CIERRE DE MODALES
// ============================================================
if (busquedaInput) {
    busquedaInput.addEventListener('input', function() {
        clearTimeout(timeoutId);
        timeoutId = setTimeout(buscarSugerencias, 300);
    });
    
    busquedaInput.addEventListener('focus', function() {
        if (this.value.trim().length >= 1) {
            buscarSugerencias();
        }
    });
    
    busquedaInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            e.preventDefault();
            aplicarFiltros();
        }
    });
}

document.addEventListener('click', function(e) {
    if (!busquedaInput?.contains(e.target) && !suggestionsDropdown?.contains(e.target)) {
        suggestionsDropdown.style.display = 'none';
    }
});

document.getElementById('generoFilter')?.addEventListener('change', aplicarFiltros);
document.getElementById('seccionFilter')?.addEventListener('change', aplicarFiltros);
document.getElementById('gradoFilter')?.addEventListener('change', aplicarFiltros);
document.getElementById('grupoFilter')?.addEventListener('change', aplicarFiltros);
document.getElementById('estatusFilter')?.addEventListener('change', aplicarFiltros);
document.getElementById('fechaIngresoFilter')?.addEventListener('change', aplicarFiltros);
document.getElementById('becaInternaFilter')?.addEventListener('change', aplicarFiltros);
document.getElementById('becaExternaFilter')?.addEventListener('change', aplicarFiltros);

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        cerrarModal();
        cerrarBajaModal();
    }
});

document.getElementById('editModal')?.addEventListener('click', function(e) {
    if (e.target === this) cerrarModal();
});
document.getElementById('bajaModal')?.addEventListener('click', function(e) {
    if (e.target === this) cerrarBajaModal();
});

document.addEventListener('DOMContentLoaded', function() {
    if (busquedaInput && busquedaInput.value.trim().length >= 1) {
        buscarSugerencias();
    }
});
</script>

<?php include __DIR__ . '/../includes/footer.php'; ?>