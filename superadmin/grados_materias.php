<?php
// superadmin/grados_materias.php

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/MateriaModel.php';
require_once __DIR__ . '/../models/CampoFormativoModel.php';
require_once __DIR__ . '/../models/GrupoModel.php';
require_once __DIR__ . '/../models/ConfigAspectosModel.php';
requireRol([1]);

$db            = getConexion();
$materiaModelo = new MateriaModel($db);
$campoModelo   = new CampoFormativoModel($db);
$grupoModelo   = new GrupoModel($db);
$configAspectos = new ConfigAspectosModel($db);

$mensaje = null;
$error   = null;

function getCicloActivo(mysqli $db): ?int {
    $res   = $db->query("SELECT id FROM ciclos_escolares WHERE activo = 1 LIMIT 1");
    $ciclo = $res->fetch_assoc();
    return $ciclo ? (int)$ciclo['id'] : null;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['guardar'])) {
    $seccion             = $_POST['seccion'];
    $grado               = (int)$_POST['grado'];
    $materiasSeleccionadas = array_map('intval', $_POST['materias'] ?? []);
    $ordenes             = $_POST['orden']           ?? [];
    $camposFormativos    = $_POST['campo_formativo'] ?? [];

    $ciclo_activo_id = getCicloActivo($db);

    if (!$ciclo_activo_id) {
        $error = "No hay un ciclo escolar activo. Por favor, activa un ciclo primero.";
    } else {
        $grupos = $grupoModelo->listarNombresPorSeccion($seccion);
        if (empty($grupos)) {
            $grupos = ['A', 'B', 'C', 'D'];
        }
        
        $stmtOld = $db->prepare("SELECT materia_id FROM grados_materias WHERE seccion = ? AND grado = ?");
        $stmtOld->bind_param('si', $seccion, $grado);
        $stmtOld->execute();
        $materiasViejasIds = array_column($stmtOld->get_result()->fetch_all(MYSQLI_ASSOC), 'materia_id');

        $materiasEliminadas = array_diff($materiasViejasIds, $materiasSeleccionadas);

        if (!empty($materiasEliminadas)) {
            $ph    = implode(',', array_fill(0, count($materiasEliminadas), '?'));
            $types = 'si' . str_repeat('i', count($materiasEliminadas));
            $params = array_merge([$seccion, $grado], array_values($materiasEliminadas));

            $subSQL = "SELECT id FROM asignaciones WHERE seccion = ? AND grado = ? AND materia_id IN ($ph)";

            foreach ([
                "DELETE FROM asignacion_maestros WHERE asignacion_id IN ($subSQL)",
                "DELETE FROM asignacion_artes WHERE asignacion_id IN ($subSQL)",
                "DELETE FROM asignacion_ingles_aspectos WHERE asignacion_id IN ($subSQL)",
                "DELETE FROM asignacion_disciplina_aspectos WHERE asignacion_id IN ($subSQL)",
                "DELETE FROM asignacion_aspectos WHERE asignacion_id IN ($subSQL)",
                "DELETE FROM asignaciones WHERE seccion = ? AND grado = ? AND materia_id IN ($ph)",
            ] as $sql) {
                $s = $db->prepare($sql);
                $s->bind_param($types, ...$params);
                $s->execute();
            }
        }

        $stmtDel = $db->prepare("DELETE FROM grados_materias WHERE seccion = ? AND grado = ?");
        $stmtDel->bind_param('si', $seccion, $grado);
        $stmtDel->execute();

        foreach ($materiasSeleccionadas as $materiaId) {
            $orden   = isset($ordenes[$materiaId]) ? (int)$ordenes[$materiaId] : 0;
            $campoId = isset($camposFormativos[$materiaId]) && $camposFormativos[$materiaId] !== ''
                       ? (int)$camposFormativos[$materiaId]
                       : null;

            $stmtIns = $db->prepare("
                INSERT INTO grados_materias (seccion, grado, materia_id, campo_formativo_id, orden)
                VALUES (?, ?, ?, ?, ?)
            ");
            $stmtIns->bind_param('siiii', $seccion, $grado, $materiaId, $campoId, $orden);
            $stmtIns->execute();

            $stmtInfo = $db->prepare("
                SELECT es_ingles, es_artes, es_higiene, es_disciplina, es_ausencias
                FROM materias WHERE id = ?
            ");
            $stmtInfo->bind_param('i', $materiaId);
            $stmtInfo->execute();
            $mat = $stmtInfo->get_result()->fetch_assoc();

            foreach ($grupos as $grupo) {
                $stmtChk = $db->prepare("
                    SELECT id FROM asignaciones
                    WHERE ciclo_id = ? AND materia_id = ? AND seccion = ? AND grado = ? AND grupo = ?
                ");
                $stmtChk->bind_param('iisis', $ciclo_activo_id, $materiaId, $seccion, $grado, $grupo);
                $stmtChk->execute();

                if ($stmtChk->get_result()->num_rows === 0) {
                    $stmtAsig = $db->prepare("
                        INSERT INTO asignaciones
                            (ciclo_id, materia_id, campo_formativo_id, seccion, grado, grupo, orden, activo)
                        VALUES (?, ?, ?, ?, ?, ?, ?, 1)
                    ");
                    $stmtAsig->bind_param('iiisisi', $ciclo_activo_id, $materiaId, $campoId, $seccion, $grado, $grupo, $orden);
                    $stmtAsig->execute();
                    $nuevaAsignacionId = (int)$db->insert_id;

                    if (!$mat['es_ausencias']) {
                        $configAspectos->insertarAspectosEstandar($nuevaAsignacionId, $seccion, $grado);
                    }
                }
            }
        }

        $mensaje = "Materias asignadas correctamente al grado " . $grado . "° de " . ucfirst($seccion) . ".";
        if (!empty($materiasEliminadas)) {
            $mensaje .= " Se eliminaron " . count($materiasEliminadas) . " materia(s) y sus asignaciones.";
        }
    }
}

$secciones = ['maternal', 'preescolar', 'primaria', 'secundaria'];
$seccionActual = $_GET['seccion'] ?? 'primaria';

if ($seccionActual === 'secundaria') {
    $grados = [1, 2, 3];
} else {
    $grados = [1, 2, 3, 4, 5, 6];
}

$gradoActual = (int)($_GET['grado'] ?? 1);
$tabActual = $_GET['tab'] ?? 'base';

$todasMaterias = $materiaModelo->listarActivas();
$camposDisponibles = $campoModelo->listarActivos();

// ============================================================
// AGRUPAR MATERIAS POR TIPO (forzando inglés y artes)
// ============================================================
$materiasPorGrupo = [
    'base' => [],
    'ciencias' => [],
    'ingles' => [],
    'artes' => [],
    'cocurriculares' => [],
    'higiene' => [],
    'disciplina' => [],
    'ausencias' => []
];

foreach ($todasMaterias as $materia) {
    if ($materia['es_ingles']) {
        $materiasPorGrupo['ingles'][] = $materia;
    } elseif ($materia['es_artes']) {
        $materiasPorGrupo['artes'][] = $materia;
    } elseif ($materia['es_higiene']) {
        $materiasPorGrupo['higiene'][] = $materia;
    } elseif ($materia['es_disciplina']) {
        $materiasPorGrupo['disciplina'][] = $materia;
    } elseif ($materia['es_ausencias']) {
        $materiasPorGrupo['ausencias'][] = $materia;
    } else {
        $grupoVisual = $materia['grupo_visual'] ?? 'base';
        if (!isset($materiasPorGrupo[$grupoVisual])) {
            $grupoVisual = 'base';
        }
        $materiasPorGrupo[$grupoVisual][] = $materia;
    }
}

// Eliminar grupos vacíos
foreach ($materiasPorGrupo as $key => $value) {
    if (empty($value)) {
        unset($materiasPorGrupo[$key]);
    }
}

$etiquetasGrupo = [
    'base' => '📘 Materias Base',
    'ciencias' => '🔬 Ciencias',
    'ingles' => '🌐 Inglés',
    'artes' => '🎨 Artes',
    'cocurriculares' => '🏃 Cocurriculares',
    'higiene' => '🧼 Higiene',
    'disciplina' => '⚠️ Disciplina',
    'ausencias' => '📅 Ausencias',
];

$stmtAsig = $db->prepare("
    SELECT gm.materia_id, gm.orden, gm.campo_formativo_id,
           m.nombre, m.es_ingles, m.es_artes, m.es_higiene,
           m.es_disciplina, m.es_ausencias, m.grupo_visual,
           cf.nombre AS campo_formativo_nombre
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
$scripts = ['/proyecto/js/modal.js'];
include __DIR__ . '/../includes/header.php';

function renderMateriaItem(array $m, array $materiasAsignadasIds, array $materiasAsignadas, array $camposDisponibles, string $clase): void {
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
    $id = (int)$m['id'];
    $safe = htmlspecialchars($m['nombre']);
    ?>
    <div class="materia-item">
        <div class="materia-info">
            <input type="checkbox" name="materias[]" value="<?= $id ?>"
                   id="m_<?= $id ?>" class="<?= htmlspecialchars($clase) ?>"
                   <?= $checked ? 'checked' : '' ?>>
            <label for="m_<?= $id ?>" class="materia-nombre"><?= $safe ?></label>
        </div>
        <select name="campo_formativo[<?= $id ?>]" class="campo-select">
            <option value="">Sin campo formativo</option>
            <?php foreach ($camposDisponibles as $cf): ?>
                <option value="<?= $cf['id'] ?>" <?= $campoActual == $cf['id'] ? 'selected' : '' ?>>
                    <?= htmlspecialchars($cf['nombre']) ?>
                </option>
            <?php endforeach; ?>
        </select>
        <input type="number" name="orden[<?= $id ?>]" value="<?= $ordenActual ?>"
               class="orden-input" placeholder="Ord" min="0">
    </div>
    <?php
}
?>

<style>
.tabs { display:flex; gap:.5rem; margin-bottom:1.5rem; border-bottom:1px solid var(--color-border); padding-bottom:.5rem; flex-wrap:wrap; }
.tab-btn { background:none; border:none; padding:.5rem 1rem; font-size:.85rem; cursor:pointer; border-radius:var(--radius-sm); transition:all .15s; color:var(--color-muted); }
.tab-btn:hover { background:#f1f5f9; }
.tab-btn.active { background:var(--color-primary); color:white; }
.tab-pane { display:none; }
.tab-pane.active { display:block; }
.materias-grid { display:grid; grid-template-columns:repeat(auto-fill, minmax(380px, 1fr)); gap:.5rem; margin-bottom:1.5rem; max-height:500px; overflow-y:auto; padding:.5rem; border:1px solid var(--color-border); border-radius:var(--radius-sm); background:#fafafa; }
.materia-item { display:flex; align-items:center; gap:.5rem; padding:.5rem; background:white; border-radius:var(--radius-sm); border:1px solid var(--color-border); flex-wrap:wrap; }
.materia-info { display:flex; align-items:center; gap:.5rem; flex:2; min-width:180px; }
.materia-item input[type="checkbox"] { width:18px; height:18px; cursor:pointer; accent-color:var(--color-primary); flex-shrink:0; }
.materia-nombre { font-size:.85rem; font-weight:500; flex:1; }
.materia-item select { width:160px; padding:.3rem; font-size:.75rem; border:1px solid #ccd3db; border-radius:4px; background:white; }
.orden-input { width:60px; padding:.3rem; text-align:center; border:1px solid #ccd3db; border-radius:4px; font-size:.75rem; }
.select-all { margin-bottom:.5rem; padding:.3rem .5rem; background:#f1f5f9; border-radius:var(--radius-sm); display:inline-block; }
.select-all label { font-size:.75rem; cursor:pointer; }
.data-table thead th { text-align:left; }
.data-table tbody td { text-align:left; vertical-align:middle; }
.data-table tbody td:first-child { text-align:center; font-weight:700; background:var(--color-primary); color:#fff; width:80px; }
</style>

<main class="container">
    <div class="card">
        <h2 class="section-title">📚 Asignar materias por grado</h2>
        <p class="form-hint">Define qué materias se imparten en cada grado y sección.</p>

        <?php if ($mensaje): ?>
            <p class="alert alert--success">✅ <?= htmlspecialchars($mensaje) ?></p>
        <?php endif; ?>
        <?php if ($error): ?>
            <p class="alert alert--error">⚠️ <?= htmlspecialchars($error) ?></p>
        <?php endif; ?>

        <form method="GET" style="margin-bottom:1.5rem;">
            <div style="display:flex; gap:1rem; align-items:center; flex-wrap:wrap;">
                <div class="form-group" style="margin-bottom:0;">
                    <label for="seccion">Sección</label>
                    <select name="seccion" id="seccion" onchange="this.form.submit()">
                        <?php foreach ($secciones as $sec): ?>
                            <option value="<?= $sec ?>" <?= $seccionActual === $sec ? 'selected' : '' ?>>
                                <?= ucfirst($sec) ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="form-group" style="margin-bottom:0;">
                    <label for="grado">Grado</label>
                    <select name="grado" id="grado" onchange="this.form.submit()">
                        <?php foreach ($grados as $g): ?>
                            <option value="<?= $g ?>" <?= $gradoActual === $g ? 'selected' : '' ?>>
                                <?= $g ?>°
                            </option>
                        <?php endforeach; ?>
                    </select>
                </div>
            </div>
        </form>

        <form method="POST">
            <input type="hidden" name="seccion" value="<?= $seccionActual ?>">
            <input type="hidden" name="grado" value="<?= $gradoActual ?>">

            <div class="tabs">
                <?php foreach ($materiasPorGrupo as $grupoKey => $materiasLista): 
                    $etiqueta = $etiquetasGrupo[$grupoKey] ?? ucfirst($grupoKey);
                ?>
                    <button type="button" class="tab-btn <?= $tabActual === $grupoKey ? 'active' : '' ?>"
                            data-tab="<?= $grupoKey ?>"><?= $etiqueta ?></button>
                <?php endforeach; ?>
            </div>

            <?php foreach ($materiasPorGrupo as $grupoKey => $materiasLista): ?>
                <div id="tab-<?= $grupoKey ?>" class="tab-pane <?= $tabActual === $grupoKey ? 'active' : '' ?>">
                    <div class="select-all">
                        <input type="checkbox" id="sa-<?= $grupoKey ?>"
                               onchange="toggleAll('<?= $grupoKey ?>', this.checked)">
                        <label for="sa-<?= $grupoKey ?>">Seleccionar todas</label>
                    </div>
                    <div class="materias-grid" id="grid-<?= $grupoKey ?>">
                        <?php foreach ($materiasLista as $m):
                            renderMateriaItem($m, $materiasAsignadasIds, $materiasAsignadas, $camposDisponibles, 'cb-' . $grupoKey);
                        endforeach; ?>
                    </div>
                </div>
            <?php endforeach; ?>

            <button type="submit" name="guardar" class="btn">💾 Guardar asignación</button>
        </form>

        <hr style="margin:2rem 0;">

        <h3>Materias asignadas a <?= ucfirst($seccionActual) ?> <?= $gradoActual ?>°</h3>
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
                    <?php foreach ($materiasAsignadas as $ma):
                        $tipo = '<span class="badge">Base</span>';
                        if ((int)$ma['es_ingles']) $tipo = '<span class="badge">Inglés</span>';
                        elseif ((int)$ma['es_artes']) $tipo = '<span class="badge">Artes</span>';
                        elseif ((int)$ma['es_higiene']) $tipo = '<span class="badge">Higiene</span>';
                        elseif ((int)($ma['es_disciplina'] ?? 0)) $tipo = '<span class="badge badge--warn">Disciplina</span>';
                        elseif ((int)($ma['es_ausencias'] ?? 0)) $tipo = '<span class="badge badge--warn">Ausencias</span>';
                    ?>
                        <tr>
                            <td><?= $ma['orden'] ?></td>
                            <td><strong><?= htmlspecialchars($ma['nombre']) ?></strong></td>
                            <td><?= htmlspecialchars($ma['campo_formativo_nombre'] ?? '—') ?></td>
                            <td><?= $tipo ?></td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        <?php endif; ?>
    </div>
</main>

<script>
function toggleAll(gridId, checked) {
    document.querySelectorAll(`#grid-${gridId} input[type="checkbox"]`)
            .forEach(cb => cb.checked = checked);
}

document.querySelectorAll('.tab-btn').forEach(btn => {
    btn.addEventListener('click', function () {
        const tabId = this.dataset.tab;
        const url = new URL(window.location.href);
        url.searchParams.set('tab', tabId);
        window.history.pushState({}, '', url);
        document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
        this.classList.add('active');
        document.querySelectorAll('.tab-pane').forEach(p => p.classList.remove('active'));
        document.getElementById(`tab-${tabId}`).classList.add('active');
    });
});
</script>

<?php include __DIR__ . '/../includes/footer.php'; ?>