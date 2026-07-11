<?php
// superadmin/asignaciones_base.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/AsignacionModel.php';
require_once __DIR__ . '/../models/CicloModel.php';
require_once __DIR__ . '/../models/MateriaModel.php';
require_once __DIR__ . '/../models/CampoFormativoModel.php';
require_once __DIR__ . '/../models/ArteSubcomponenteModel.php';
require_once __DIR__ . '/../models/UserModel.php';
requireRol([1]);

$db         = getConexion();
$asigModelo = new AsignacionModel($db);
$cicloModelo= new CicloModel($db);

$resultado  = null;
$accion     = $_GET['accion'] ?? '';
$editId     = (int)($_GET['id'] ?? 0);
$tabActual  = $_GET['tab']    ?? 'base';

// ── Aspectos estándar ─────────────────────────────────────────
$ASPECTOS_STD = [
    ['Examen',                 50.00, 1],
    ['Tareas',                 10.00, 2],
    ['Participación',          10.00, 3],
    ['Evaluación Parcial',     10.00, 4],
    ['Proyecto',               10.00, 5],
    ['Trabajo y Exposiciones', 10.00, 6],
];

// ── Helper: insertar 6 aspectos estándar ──────────────────────
function insertarAspectos(mysqli $db, int $asigId): void {
    global $ASPECTOS_STD;
    $st = $db->prepare("
        INSERT IGNORE INTO asignacion_aspectos (asignacion_id, nombre, porcentaje, orden)
        VALUES (?, ?, ?, ?)
    ");
    foreach ($ASPECTOS_STD as [$n, $p, $o]) {
        $st->bind_param('isdi', $asigId, $n, $p, $o);
        $st->execute();
    }
}

// ── Helper: insertar aspectos de artes por subcomponente ──────
function insertarAspectosArtes(mysqli $db, int $asigId, int $subId): void {
    global $ASPECTOS_STD;
    $st = $db->prepare("
        INSERT IGNORE INTO asignacion_artes_aspectos
          (asignacion_id, subcomponente_id, nombre, porcentaje, orden)
        VALUES (?, ?, ?, ?, ?)
    ");
    foreach ($ASPECTOS_STD as [$n, $p, $o]) {
        $st->bind_param('iisdi', $asigId, $subId, $n, $p, $o);
        $st->execute();
    }
}

// ── Helper: insertar aspectos de inglés por subcomponente ─────
function insertarAspectosIngles(mysqli $db, int $asigId, int $subId): void {
    global $ASPECTOS_STD;
    $st = $db->prepare("
        INSERT IGNORE INTO asignacion_ingles_sub_aspectos
          (asignacion_id, subcomponente_id, nombre, porcentaje, orden)
        VALUES (?, ?, ?, ?, ?)
    ");
    foreach ($ASPECTOS_STD as [$n, $p, $o]) {
        $st->bind_param('iisdi', $asigId, $subId, $n, $p, $o);
        $st->execute();
    }
}

// ── Helper: crear o recuperar asignación ──────────────────────
function obtenerOCrearAsignacion(mysqli $db, int $cicloId, int $materiaId,
    string $seccion, int $grado, string $grupo): int
{
    // Buscar orden en grados_materias
    $stO = $db->prepare("
        SELECT orden, campo_formativo_id FROM grados_materias
        WHERE seccion=? AND grado=? AND materia_id=? LIMIT 1
    ");
    $stO->bind_param('sii', $seccion, $grado, $materiaId);
    $stO->execute();
    $rowO  = $stO->get_result()->fetch_assoc();
    $orden = $rowO ? (int)$rowO['orden'] : 0;

    // Campo formativo de la materia
    $stM = $db->prepare("SELECT campo_formativo_id FROM materias WHERE id=? LIMIT 1");
    $stM->bind_param('i', $materiaId);
    $stM->execute();
    $rowM   = $stM->get_result()->fetch_assoc();
    $campoId = $rowM && $rowM['campo_formativo_id'] ? (int)$rowM['campo_formativo_id'] : null;

    // ¿Ya existe?
    $stC = $db->prepare("
        SELECT id FROM asignaciones
        WHERE ciclo_id=? AND materia_id=? AND seccion=? AND grado=? AND grupo=?
        LIMIT 1
    ");
    $stC->bind_param('iisis', $cicloId, $materiaId, $seccion, $grado, $grupo);
    $stC->execute();
    $row = $stC->get_result()->fetch_assoc();
    if ($row) return (int)$row['id'];

    // Crear
    $stI = $db->prepare("
        INSERT INTO asignaciones
          (ciclo_id, materia_id, campo_formativo_id, seccion, grado, grupo, orden, activo)
        VALUES (?,?,?,?,?,?,?,1)
    ");
    $stI->bind_param('iiisisi', $cicloId, $materiaId, $campoId, $seccion, $grado, $grupo, $orden);
    $stI->execute();
    return (int)$db->insert_id;
}

// ── Acciones rápidas GET ──────────────────────────────────────
if ($accion === 'desactivar' && $editId > 0) {
    $db->query("UPDATE asignaciones SET activo=0 WHERE id=$editId");
    header("Location: asignaciones_base.php?tab=$tabActual&msg=desactivado"); exit;
}
if ($accion === 'activar' && $editId > 0) {
    $db->query("UPDATE asignaciones SET activo=1 WHERE id=$editId");
    header("Location: asignaciones_base.php?tab=$tabActual&msg=activado"); exit;
}
if ($accion === 'eliminar' && $editId > 0) {
    foreach ([
        "DELETE FROM asignacion_artes_aspectos      WHERE asignacion_id=$editId",
        "DELETE FROM asignacion_ingles_sub_aspectos WHERE asignacion_id=$editId",
        "DELETE FROM asignacion_ingles_subs          WHERE asignacion_id=$editId",
        "DELETE FROM asignacion_maestros             WHERE asignacion_id=$editId",
        "DELETE FROM asignacion_artes               WHERE asignacion_id=$editId",
        "DELETE FROM asignacion_ingles_aspectos     WHERE asignacion_id=$editId",
        "DELETE FROM asignacion_aspectos            WHERE asignacion_id=$editId",
        "DELETE FROM asignaciones                   WHERE id=$editId",
    ] as $sql) { $db->query($sql); }
    header("Location: asignaciones_base.php?tab=$tabActual&msg=eliminado"); exit;
}

// ── POST: guardar MATERIAS BASE ───────────────────────────────
if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['form_tipo'] ?? '') === 'base') {
    $cicloId    = (int)($_POST['ciclo_id'] ?? 0);
    $seccion    = trim($_POST['seccion']   ?? '');
    $grado      = (int)($_POST['grado']    ?? 0);
    $grupo      = trim($_POST['grupo']     ?? '');
    $marcadas   = array_map('intval', (array)($_POST['materias_sel'] ?? []));
    $disponibles= array_map('intval', (array)($_POST['materias_disp'] ?? []));

    $creadas = $eliminadas = 0;
    $db->begin_transaction();
    try {
        // Eliminar las desmarcadas
        $desmarcadas = array_diff($disponibles, $marcadas);
        foreach ($desmarcadas as $matId) {
            $st = $db->prepare("
                SELECT id FROM asignaciones
                WHERE ciclo_id=? AND materia_id=? AND seccion=? AND grado=? AND grupo=? LIMIT 1
            ");
            $st->bind_param('iisis', $cicloId, $matId, $seccion, $grado, $grupo);
            $st->execute();
            $row = $st->get_result()->fetch_assoc();
            if ($row) {
                $aid = (int)$row['id'];
                $db->query("DELETE FROM asignacion_maestros  WHERE asignacion_id=$aid");
                $db->query("DELETE FROM asignacion_aspectos  WHERE asignacion_id=$aid");
                $db->query("DELETE FROM asignaciones         WHERE id=$aid");
                $eliminadas++;
            }
        }
        // Crear las marcadas
        foreach ($marcadas as $matId) {
            if ($matId <= 0) continue;
            $aid = obtenerOCrearAsignacion($db, $cicloId, $matId, $seccion, $grado, $grupo);
            insertarAspectos($db, $aid);
            $creadas++;
        }
        $db->commit();
        $resultado = ['success' => true, 'creadas' => $creadas, 'eliminadas' => $eliminadas];
    } catch (Exception $e) {
        $db->rollback();
        $resultado = ['error' => $e->getMessage()];
    }
    $tabActual = 'base';
}

// ── POST: guardar ARTES ───────────────────────────────────────
if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['form_tipo'] ?? '') === 'artes') {
    $cicloId  = (int)($_POST['ciclo_id'] ?? 0);
    $seccion  = trim($_POST['seccion']   ?? '');
    $grado    = (int)($_POST['grado']    ?? 0);
    $grupo    = trim($_POST['grupo']     ?? '');
    $subsSel  = array_map('intval', (array)($_POST['subs_sel'] ?? []));
    $subsDisp = array_map('intval', (array)($_POST['subs_disp'] ?? []));

    // Obtener materia Artes
    $resA = $db->query("SELECT id FROM materias WHERE nombre='Artes' AND es_artes=1 AND activo=1 LIMIT 1");
    $rowA = $resA ? $resA->fetch_assoc() : null;

    if (!$rowA) {
        $resultado = ['error' => 'No existe la materia Artes activa en el catálogo.'];
    } else {
        $matArtesId = (int)$rowA['id'];
        $db->begin_transaction();
        try {
            $asigId = obtenerOCrearAsignacion($db, $cicloId, $matArtesId, $seccion, $grado, $grupo);

            // Desmarcar subcomponentes quitados
            $desmarcados = array_diff($subsDisp, $subsSel);
            foreach ($desmarcados as $subId) {
                $db->query("DELETE FROM asignacion_artes
                             WHERE asignacion_id=$asigId AND subcomponente_id=$subId");
                $db->query("DELETE FROM asignacion_artes_aspectos
                             WHERE asignacion_id=$asigId AND subcomponente_id=$subId");
            }

            // Agregar los seleccionados
            foreach ($subsSel as $subId) {
                if ($subId <= 0) continue;
                $stC = $db->prepare("
                    SELECT id FROM asignacion_artes
                    WHERE asignacion_id=? AND subcomponente_id=? LIMIT 1
                ");
                $stC->bind_param('ii', $asigId, $subId);
                $stC->execute();
                if ($stC->get_result()->num_rows === 0) {
                    $stI = $db->prepare("
                        INSERT INTO asignacion_artes (asignacion_id, subcomponente_id) VALUES (?,?)
                    ");
                    $stI->bind_param('ii', $asigId, $subId);
                    $stI->execute();
                }
                insertarAspectosArtes($db, $asigId, $subId);
            }

            $db->commit();
            $resultado = ['success' => true, 'creadas' => count($subsSel)];
        } catch (Exception $e) {
            $db->rollback();
            $resultado = ['error' => $e->getMessage()];
        }
    }
    $tabActual = 'artes';
}

// ── POST: guardar INGLÉS ──────────────────────────────────────
if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['form_tipo'] ?? '') === 'ingles') {
    $cicloId  = (int)($_POST['ciclo_id'] ?? 0);
    $seccion  = trim($_POST['seccion']   ?? '');
    $grado    = (int)($_POST['grado']    ?? 0);
    $grupo    = trim($_POST['grupo']     ?? '');
    $subsSel  = array_map('intval', (array)($_POST['subs_sel'] ?? []));
    $subsDisp = array_map('intval', (array)($_POST['subs_disp'] ?? []));

    $resI = $db->query("SELECT id FROM materias WHERE nombre='Inglés' AND es_ingles=0 AND activo=1 LIMIT 1");
    $rowI = $resI ? $resI->fetch_assoc() : null;

    if (!$rowI) {
        $resultado = ['error' => 'No existe la materia Inglés activa. Ejecuta la migración SQL primero.'];
    } else {
        $matIngId = (int)$rowI['id'];
        $db->begin_transaction();
        try {
            $asigId = obtenerOCrearAsignacion($db, $cicloId, $matIngId, $seccion, $grado, $grupo);

            // Desmarcar quitados
            $desmarcados = array_diff($subsDisp, $subsSel);
            foreach ($desmarcados as $subId) {
                $db->query("DELETE FROM asignacion_ingles_subs
                             WHERE asignacion_id=$asigId AND subcomponente_id=$subId");
                $db->query("DELETE FROM asignacion_ingles_sub_aspectos
                             WHERE asignacion_id=$asigId AND subcomponente_id=$subId");
            }

            // Agregar seleccionados
            foreach ($subsSel as $subId) {
                if ($subId <= 0) continue;
                $stC = $db->prepare("
                    SELECT id FROM asignacion_ingles_subs
                    WHERE asignacion_id=? AND subcomponente_id=? LIMIT 1
                ");
                $stC->bind_param('ii', $asigId, $subId);
                $stC->execute();
                if ($stC->get_result()->num_rows === 0) {
                    $stI = $db->prepare("
                        INSERT INTO asignacion_ingles_subs (asignacion_id, subcomponente_id)
                        VALUES (?,?)
                    ");
                    $stI->bind_param('ii', $asigId, $subId);
                    $stI->execute();
                }
                insertarAspectosIngles($db, $asigId, $subId);
            }

            $db->commit();
            $resultado = ['success' => true, 'creadas' => count($subsSel)];
        } catch (Exception $e) {
            $db->rollback();
            $resultado = ['error' => $e->getMessage()];
        }
    }
    $tabActual = 'ingles';
}

// ── Datos generales ───────────────────────────────────────────
$msgRedir   = $_GET['msg'] ?? '';
$cicloActivo= $cicloModelo->obtenerActivo();

$seccionSel = $_GET['seccion'] ?? '';
$gradoSel   = (int)($_GET['grado']   ?? 0);
$grupoSel   = $_GET['grupo']   ?? '';

// Subcomponentes de artes activos
$resAS = $db->query("SELECT id, nombre FROM artes_subcomponentes WHERE activo=1 ORDER BY orden ASC");
$artesSubs = $resAS ? $resAS->fetch_all(MYSQLI_ASSOC) : [];

// Subcomponentes de inglés
$resIS = $db->query("SELECT id, nombre FROM ingles_subcomponentes WHERE activo=1 ORDER BY id ASC");
$inglesSubs = $resIS ? $resIS->fetch_all(MYSQLI_ASSOC) : [];

// Todas las materias activas para el formulario base
// (excluye es_ingles=1 que son las viejas columnas sueltas, es_artes=1 se maneja en pestaña artes)
// El admin ve: normales + Inglés + Artes (estas dos tienen su pestaña propia)
$resMats = $db->query("
    SELECT m.id, m.nombre, m.es_artes, m.es_higiene, m.es_disciplina,
           m.es_ausencias, m.campo_formativo_id,
           cf.nombre AS campo_nombre
    FROM materias m
    LEFT JOIN campos_formativos cf ON cf.id = m.campo_formativo_id
    WHERE m.activo = 1 AND m.es_ingles = 0
    ORDER BY cf.orden ASC, m.nombre ASC
");
$todasMaterias = $resMats ? $resMats->fetch_all(MYSQLI_ASSOC) : [];

// Asignaciones ya existentes para el grupo seleccionado
$asignacionesActuales = [];
$subsArtesActuales    = [];
$subsInglesActuales   = [];
if ($cicloActivo && $seccionSel && $gradoSel && $grupoSel) {
    $cicloId = (int)$cicloActivo['id'];
    $stAct = $db->prepare("
        SELECT a.id, a.materia_id, m.es_artes, m.nombre AS mat_nombre
        FROM asignaciones a
        JOIN materias m ON m.id = a.materia_id
        WHERE a.ciclo_id=? AND a.seccion=? AND a.grado=? AND a.grupo=?
    ");
    $stAct->bind_param('isis', $cicloId, $seccionSel, $gradoSel, $grupoSel);
    $stAct->execute();
    $rowsAct = $stAct->get_result()->fetch_all(MYSQLI_ASSOC);
    foreach ($rowsAct as $r) {
        $asignacionesActuales[$r['materia_id']] = (int)$r['id'];
    }

    // Subs de artes activos en este grupo
    $stSA = $db->prepare("
        SELECT aa.subcomponente_id
        FROM asignacion_artes aa
        JOIN asignaciones a ON a.id = aa.asignacion_id
        JOIN materias m ON m.id = a.materia_id
        WHERE a.ciclo_id=? AND a.seccion=? AND a.grado=? AND a.grupo=? AND m.es_artes=1
    ");
    $stSA->bind_param('isis', $cicloId, $seccionSel, $gradoSel, $grupoSel);
    $stSA->execute();
    foreach ($stSA->get_result()->fetch_all(MYSQLI_ASSOC) as $r) {
        $subsArtesActuales[] = (int)$r['subcomponente_id'];
    }

    // Subs de inglés activos en este grupo
    $stSI = $db->prepare("
        SELECT ais.subcomponente_id
        FROM asignacion_ingles_subs ais
        JOIN asignaciones a ON a.id = ais.asignacion_id
        JOIN materias m ON m.id = a.materia_id
        WHERE a.ciclo_id=? AND a.seccion=? AND a.grado=? AND a.grupo=? AND m.nombre='Inglés'
    ");
    $stSI->bind_param('isis', $cicloId, $seccionSel, $gradoSel, $grupoSel);
    $stSI->execute();
    foreach ($stSI->get_result()->fetch_all(MYSQLI_ASSOC) as $r) {
        $subsInglesActuales[] = (int)$r['subcomponente_id'];
    }
}

// Listado agrupado para mostrar en la columna derecha
$todasAsignaciones = $cicloActivo
    ? $asigModelo->listarPorCicloAgrupado((int)$cicloActivo['id'])
    : [];

// Separar por tipo para cada pestaña
$listBase = $listArtes = $listIngles = [];
foreach ($todasAsignaciones as $key => $grupo) {
    $base   = array_values(array_filter($grupo,
        fn($a) => (int)$a['es_ingles']===0 && (int)$a['es_artes']===0
                  && $a['materia_nombre'] !== 'Inglés'
    ));
    $artes  = array_values(array_filter($grupo, fn($a) => (int)$a['es_artes']===1));
    $ingles = array_values(array_filter($grupo, fn($a) => $a['materia_nombre']==='Inglés'));
    if (!empty($base))   $listBase[$key]   = $base;
    if (!empty($artes))  $listArtes[$key]  = $artes;
    if (!empty($ingles)) $listIngles[$key] = $ingles;
}

$pageTitle = 'Superadmin › Asignaciones';
$backLink  = 'dashboard.php';
include __DIR__ . '/../includes/header.php';

// ── Función: renderizar tabla de listado ──────────────────────
function renderLista(array $lista, string $tab): void { ?>
    <?php if (empty($lista)): ?>
        <p class="empty-state">Sin asignaciones de este tipo en el ciclo activo.</p>
    <?php else: ?>
        <?php foreach ($lista as $grupo):
            $p = $grupo[0]; ?>
            <div class="grupo-asignaciones">
                <h3 class="grupo-titulo">
                    📚 <?= ucfirst($p['seccion']) ?> — <?= $p['grado'] ?>° <?= $p['grupo'] ?>
                </h3>
                <table class="data-table">
                    <thead><tr>
                        <th>Materia</th>
                        <th>Campo formativo</th>
                        <th>Estado</th>
                        <th>Acciones</th>
                    </tr></thead>
                    <tbody>
                    <?php foreach ($grupo as $a):
                        $activo = (int)$a['activo'] === 1;
                        $ns = htmlspecialchars($a['materia_nombre']); ?>
                        <tr>
                            <td><strong><?= $ns ?></strong></td>
                            <td><?= $a['campo_formativo_nombre']
                                ? htmlspecialchars($a['campo_formativo_nombre'])
                                : '<span class="form-hint">—</span>' ?></td>
                            <td class="estado-cell">
                                <?php if ($activo): ?>
                                    <span class="badge badge--active">Activo</span>
                                <?php else: ?>
                                    <span class="badge badge--warn">Inactivo</span>
                                <?php endif; ?>
                            </td>
                            <td class="acciones-cell">
                                <div class="table-actions">
                                    <a href="javascript:void(0)"
                                       class="btn btn--sm <?= $activo ? 'btn--warning':'btn--success' ?> action-btn"
                                       data-url="asignaciones_base.php?tab=<?= $tab ?>&accion=<?= $activo?'desactivar':'activar' ?>&id=<?= $a['id'] ?>"
                                       data-title="<?= $activo?'Desactivar':'Activar' ?>"
                                       data-body="<?= $activo?'¿Desactivar ':'¿Activar ' ?><?= $ns ?>?">
                                        <?= $activo?'Desactivar':'Activar' ?>
                                    </a>
                                    <a href="javascript:void(0)"
                                       class="btn btn--sm btn--danger action-btn"
                                       data-url="asignaciones_base.php?tab=<?= $tab ?>&accion=eliminar&id=<?= $a['id'] ?>"
                                       data-title="Eliminar"
                                       data-body="¿ELIMINAR <?= $ns ?>? No se puede deshacer.">
                                        🗑️ Eliminar
                                    </a>
                                </div>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        <?php endforeach; ?>
    <?php endif;
}

// ── Filtros compartidos (macro) ───────────────────────────────
function filtrosGrupo(string $tab, string $seccionSel, int $gradoSel, string $grupoSel): void { ?>
    <form method="GET" style="display:contents;">
    <input type="hidden" name="tab" value="<?= $tab ?>">
    <div class="form-group">
        <label>Sección *</label>
        <select name="seccion" class="form-control" required onchange="this.form.submit()">
            <option value="">Selecciona…</option>
            <?php foreach (['maternal','preescolar','primaria','secundaria'] as $s): ?>
                <option value="<?= $s ?>" <?= $seccionSel===$s?'selected':'' ?>><?= ucfirst($s) ?></option>
            <?php endforeach; ?>
        </select>
    </div>
    <div class="form-group">
        <label>Grado *</label>
        <select name="grado" class="form-control" required onchange="this.form.submit()">
            <option value="">Selecciona…</option>
            <?php for ($i=1;$i<=6;$i++): ?>
                <option value="<?= $i ?>" <?= $gradoSel==$i?'selected':'' ?>><?= $i ?>°</option>
            <?php endfor; ?>
        </select>
    </div>
    <div class="form-group">
        <label>Grupo *</label>
        <select name="grupo" class="form-control" required onchange="this.form.submit()">
            <option value="">Selecciona…</option>
            <?php foreach (['A','B','C','D'] as $g): ?>
                <option value="<?= $g ?>" <?= $grupoSel===$g?'selected':'' ?>><?= $g ?></option>
            <?php endforeach; ?>
        </select>
    </div>
    </form>
<?php }
?>

<!-- Modal de confirmación -->
<div id="confirmModal" style="display:none;position:fixed;top:0;left:0;width:100%;height:100%;
     background:rgba(0,0,0,0.5);z-index:1000;align-items:center;justify-content:center;">
    <div style="background:white;border-radius:12px;padding:24px;max-width:420px;
                margin:auto;box-shadow:0 4px 24px rgba(0,0,0,.2);">
        <h3 id="modalTitle" style="margin-bottom:14px;color:#1e3a5f;"></h3>
        <p  id="modalBody"  style="margin-bottom:20px;"></p>
        <div style="display:flex;gap:10px;justify-content:flex-end;">
            <button id="modalCancel" class="btn" style="background:#e2e8f0;color:#333;">Cancelar</button>
            <a      id="modalConfirm" class="btn" style="background:#dc2626;color:white;">Confirmar</a>
        </div>
    </div>
</div>

<main class="container">

<?php if ($msgRedir === 'activado'): ?>
    <p class="alert alert--success">✅ Asignación activada.</p>
<?php elseif ($msgRedir === 'desactivado'): ?>
    <p class="alert alert--success">✅ Asignación desactivada.</p>
<?php elseif ($msgRedir === 'eliminado'): ?>
    <p class="alert alert--success">✅ Asignación eliminada.</p>
<?php endif; ?>

<?php if ($resultado): ?>
    <?php if (!empty($resultado['error'])): ?>
        <p class="alert alert--error">⚠️ <?= htmlspecialchars($resultado['error']) ?></p>
    <?php else: ?>
        <p class="alert alert--success">✅ Guardado correctamente.</p>
    <?php endif; ?>
<?php endif; ?>

<?php if (!$cicloActivo): ?>
    <p class="alert alert--error">
        ⚠️ No hay ciclo escolar activo.
        <a href="ciclos_escolares.php">Configura uno primero</a>.
    </p>
<?php else: ?>

<!-- Pestañas -->
<div class="tabs-nav">
    <a href="?tab=base&seccion=<?= urlencode($seccionSel) ?>&grado=<?= $gradoSel ?>&grupo=<?= urlencode($grupoSel) ?>"
       class="tab-link <?= $tabActual==='base'?'tab-link--active':'' ?>">📚 Materias Base</a>
    <a href="?tab=artes&seccion=<?= urlencode($seccionSel) ?>&grado=<?= $gradoSel ?>&grupo=<?= urlencode($grupoSel) ?>"
       class="tab-link <?= $tabActual==='artes'?'tab-link--active':'' ?>">🎨 Artes</a>
    <a href="?tab=ingles&seccion=<?= urlencode($seccionSel) ?>&grado=<?= $gradoSel ?>&grupo=<?= urlencode($grupoSel) ?>"
       class="tab-link <?= $tabActual==='ingles'?'tab-link--active':'' ?>">🇬🇧 Inglés</a>
</div>

<?php
// ════════════════════════════════════════
// PESTAÑA: MATERIAS BASE
// ════════════════════════════════════════
if ($tabActual === 'base'): ?>
<div class="asignaciones-layout">

    <div class="asignaciones-formulario">
    <section class="card">
        <h2 class="section-title">📚 Materias del grupo</h2>
        <p class="form-hint">Ciclo: <strong><?= htmlspecialchars($cicloActivo['nombre']) ?></strong></p>

        <?php filtrosGrupo('base', $seccionSel, $gradoSel, $grupoSel); ?>

        <?php if ($seccionSel && $gradoSel && $grupoSel): ?>
        <form method="POST" novalidate>
            <input type="hidden" name="form_tipo" value="base">
            <input type="hidden" name="ciclo_id"  value="<?= $cicloActivo['id'] ?>">
            <input type="hidden" name="seccion"   value="<?= $seccionSel ?>">
            <input type="hidden" name="grado"     value="<?= $gradoSel ?>">
            <input type="hidden" name="grupo"     value="<?= $grupoSel ?>">

            <hr class="separator">
            <p class="form-hint" style="margin-bottom:.8rem;">
                Marca las materias que corresponden a
                <strong><?= ucfirst($seccionSel) ?> <?= $gradoSel ?>° <?= $grupoSel ?></strong>.
                Artes e Inglés se configuran en sus pestañas propias.
            </p>

            <?php
            // Agrupar por campo formativo para mejor presentación
            $porCampo = [];
            foreach ($todasMaterias as $m) {
                // Excluir Artes e Inglés de aquí (tienen su propia pestaña)
                if ((int)$m['es_artes'] === 1) continue;
                if ($m['nombre'] === 'Inglés') continue;
                $clave = $m['campo_nombre'] ?? '— Sin campo formativo —';
                $porCampo[$clave][] = $m;
            }
            foreach ($porCampo as $campoNombre => $mats): ?>
                <div class="campo-grupo">
                    <div class="campo-titulo"><?= htmlspecialchars($campoNombre) ?></div>
                    <?php foreach ($mats as $m):
                        $checked = isset($asignacionesActuales[$m['id']]);
                        $matId   = $m['id'];
                    ?>
                        <label class="materia-check-label <?= $checked?'materia-check-label--on':'' ?>">
                            <!-- campo disponible siempre presente -->
                            <input type="hidden" name="materias_disp[]" value="<?= $matId ?>">
                            <input type="checkbox"
                                   name="materias_sel[]"
                                   value="<?= $matId ?>"
                                   <?= $checked?'checked':'' ?>
                                   class="mat-check">
                            <span class="mat-nombre"><?= htmlspecialchars($m['nombre']) ?></span>
                            <?php if ((int)$m['es_higiene']): ?>
                                <span class="badge">Higiene</span>
                            <?php elseif ((int)$m['es_disciplina']): ?>
                                <span class="badge badge--warn">Disciplina</span>
                            <?php elseif ((int)$m['es_ausencias']): ?>
                                <span class="badge badge--info">Ausencias</span>
                            <?php endif; ?>
                        </label>
                    <?php endforeach; ?>
                </div>
            <?php endforeach; ?>

            <button class="btn" type="submit" style="margin-top:1rem;">💾 Guardar materias</button>
        </form>
        <?php endif; ?>
    </section>
    </div>

    <div class="asignaciones-listado">
    <section>
        <h2 class="section-title">Asignaciones Base — <?= htmlspecialchars($cicloActivo['nombre']) ?></h2>
        <?php renderLista($listBase, 'base'); ?>
    </section>
    </div>
</div>

<?php
// ════════════════════════════════════════
// PESTAÑA: ARTES
// ════════════════════════════════════════
elseif ($tabActual === 'artes'): ?>
<div class="asignaciones-layout">

    <div class="asignaciones-formulario">
    <section class="card">
        <h2 class="section-title">🎨 Subcomponentes de Artes</h2>
        <p class="form-hint">Ciclo: <strong><?= htmlspecialchars($cicloActivo['nombre']) ?></strong></p>
        <p class="form-hint" style="color:var(--color-muted);font-size:.82rem;margin-bottom:.8rem;">
            Cada subcomponente seleccionado tendrá sus 6 aspectos de calificación:
            Examen 50%, Tareas 10%, Participación 10%, Evaluación Parcial 10%,
            Proyecto 10%, Trabajo y Exposiciones 10%.
        </p>

        <?php filtrosGrupo('artes', $seccionSel, $gradoSel, $grupoSel); ?>

        <?php if ($seccionSel && $gradoSel && $grupoSel): ?>
        <form method="POST" novalidate>
            <input type="hidden" name="form_tipo" value="artes">
            <input type="hidden" name="ciclo_id"  value="<?= $cicloActivo['id'] ?>">
            <input type="hidden" name="seccion"   value="<?= $seccionSel ?>">
            <input type="hidden" name="grado"     value="<?= $gradoSel ?>">
            <input type="hidden" name="grupo"     value="<?= $grupoSel ?>">

            <hr class="separator">
            <p class="form-hint" style="margin-bottom:.8rem;">
                Subcomponentes para
                <strong><?= ucfirst($seccionSel) ?> <?= $gradoSel ?>° <?= $grupoSel ?></strong>:
            </p>

            <?php if (empty($artesSubs)): ?>
                <p class="alert alert--warn">No hay subcomponentes de Artes activos en el catálogo.</p>
            <?php else: ?>
                <div class="subs-grid">
                <?php foreach ($artesSubs as $sub):
                    $checked = in_array($sub['id'], $subsArtesActuales); ?>
                    <label class="sub-check-label <?= $checked?'sub-check-label--on':'' ?>">
                        <input type="hidden" name="subs_disp[]" value="<?= $sub['id'] ?>">
                        <input type="checkbox"
                               name="subs_sel[]"
                               value="<?= $sub['id'] ?>"
                               <?= $checked?'checked':'' ?>
                               class="sub-check">
                        <span><?= htmlspecialchars($sub['nombre']) ?></span>
                    </label>
                <?php endforeach; ?>
                </div>

                <!-- Previsualización de aspectos -->
                <div class="aspectos-preview">
                    <span class="asp-tag">Examen 50%</span>
                    <span class="asp-tag">Tareas 10%</span>
                    <span class="asp-tag">Participación 10%</span>
                    <span class="asp-tag">Eval. Parcial 10%</span>
                    <span class="asp-tag">Proyecto 10%</span>
                    <span class="asp-tag">Trabajo y Exp. 10%</span>
                </div>

                <button class="btn" type="submit" style="margin-top:.8rem;">💾 Guardar Artes</button>
            <?php endif; ?>
        </form>
        <?php endif; ?>
    </section>
    </div>

    <div class="asignaciones-listado">
    <section>
        <h2 class="section-title">Artes — <?= htmlspecialchars($cicloActivo['nombre']) ?></h2>
        <?php renderLista($listArtes, 'artes'); ?>
    </section>
    </div>
</div>

<?php
// ════════════════════════════════════════
// PESTAÑA: INGLÉS
// ════════════════════════════════════════
elseif ($tabActual === 'ingles'): ?>
<div class="asignaciones-layout">

    <div class="asignaciones-formulario">
    <section class="card">
        <h2 class="section-title">🇬🇧 Subcomponentes de Inglés</h2>
        <p class="form-hint">Ciclo: <strong><?= htmlspecialchars($cicloActivo['nombre']) ?></strong></p>
        <p class="form-hint" style="color:var(--color-muted);font-size:.82rem;margin-bottom:.8rem;">
            Cada subcomponente seleccionado tendrá: Examen 50%, Tareas 10%, Participación 10%,
            Evaluación Parcial 10%, Proyecto 10%, Trabajo y Exposiciones 10%.
        </p>

        <?php filtrosGrupo('ingles', $seccionSel, $gradoSel, $grupoSel); ?>

        <?php if ($seccionSel && $gradoSel && $grupoSel): ?>
        <form method="POST" novalidate>
            <input type="hidden" name="form_tipo" value="ingles">
            <input type="hidden" name="ciclo_id"  value="<?= $cicloActivo['id'] ?>">
            <input type="hidden" name="seccion"   value="<?= $seccionSel ?>">
            <input type="hidden" name="grado"     value="<?= $gradoSel ?>">
            <input type="hidden" name="grupo"     value="<?= $grupoSel ?>">

            <hr class="separator">
            <p class="form-hint" style="margin-bottom:.8rem;">
                Subcomponentes para
                <strong><?= ucfirst($seccionSel) ?> <?= $gradoSel ?>° <?= $grupoSel ?></strong>:
            </p>

            <?php if (empty($inglesSubs)): ?>
                <p class="alert alert--warn">
                    No hay subcomponentes de Inglés. Ejecuta la migración SQL.
                </p>
            <?php else: ?>
                <div class="subs-grid">
                <?php foreach ($inglesSubs as $sub):
                    $checked = in_array($sub['id'], $subsInglesActuales); ?>
                    <label class="sub-check-label <?= $checked?'sub-check-label--on':'' ?>">
                        <input type="hidden" name="subs_disp[]" value="<?= $sub['id'] ?>">
                        <input type="checkbox"
                               name="subs_sel[]"
                               value="<?= $sub['id'] ?>"
                               <?= $checked?'checked':'' ?>
                               class="sub-check">
                        <span><?= htmlspecialchars($sub['nombre']) ?></span>
                    </label>
                <?php endforeach; ?>
                </div>

                <div style="margin-top:.6rem;">
                    <button type="button" id="btn-todos-ingles" class="btn btn--sm"
                            style="background:#f1f5f9;color:#334155;font-size:.8rem;">
                        Seleccionar todos
                    </button>
                </div>

                <div class="aspectos-preview" style="margin-top:.8rem;">
                    <span class="asp-tag">Examen 50%</span>
                    <span class="asp-tag">Tareas 10%</span>
                    <span class="asp-tag">Participación 10%</span>
                    <span class="asp-tag">Eval. Parcial 10%</span>
                    <span class="asp-tag">Proyecto 10%</span>
                    <span class="asp-tag">Trabajo y Exp. 10%</span>
                </div>

                <button class="btn" type="submit" style="margin-top:.8rem;">💾 Guardar Inglés</button>
            <?php endif; ?>
        </form>
        <?php endif; ?>
    </section>
    </div>

    <div class="asignaciones-listado">
    <section>
        <h2 class="section-title">Inglés — <?= htmlspecialchars($cicloActivo['nombre']) ?></h2>
        <?php renderLista($listIngles, 'ingles'); ?>
    </section>
    </div>
</div>

<?php endif; // tabs ?>
<?php endif; // cicloActivo ?>
</main>

<script>
document.addEventListener('DOMContentLoaded', function () {
    // Modal
    const modal   = document.getElementById('confirmModal');
    const mTitle  = document.getElementById('modalTitle');
    const mBody   = document.getElementById('modalBody');
    const mOk     = document.getElementById('modalConfirm');
    const mCancel = document.getElementById('modalCancel');

    document.querySelectorAll('.action-btn').forEach(btn => {
        btn.addEventListener('click', function () {
            mTitle.textContent = this.dataset.title;
            mBody.textContent  = this.dataset.body;
            mOk.href           = this.dataset.url;
            modal.style.display= 'flex';
        });
    });
    mCancel.addEventListener('click', () => modal.style.display = 'none');
    modal.addEventListener('click', e => { if (e.target===modal) modal.style.display='none'; });

    // Resaltar checkboxes al marcar
    document.querySelectorAll('.mat-check, .sub-check').forEach(chk => {
        const lbl = chk.closest('label');
        if (!lbl) return;
        chk.addEventListener('change', () => {
            lbl.classList.toggle('materia-check-label--on', chk.checked);
            lbl.classList.toggle('sub-check-label--on',     chk.checked);
        });
    });

    // Seleccionar todos en inglés
    const btnTodos = document.getElementById('btn-todos-ingles');
    if (btnTodos) {
        btnTodos.addEventListener('click', function () {
            const checks = document.querySelectorAll('input[name="subs_sel[]"]');
            const todos  = [...checks].every(c => c.checked);
            checks.forEach(c => {
                c.checked = !todos;
                c.dispatchEvent(new Event('change'));
            });
            this.textContent = todos ? 'Seleccionar todos' : 'Deseleccionar todos';
        });
    }
});
</script>

<style>
/* ── Layout ─────────────────────────────────── */
.asignaciones-layout {
    display: grid;
    grid-template-columns: 1fr 1.8fr;
    gap: 1.5rem;
    align-items: start;
}
.asignaciones-formulario, .asignaciones-listado { min-width: 0; }

/* ── Pestañas ───────────────────────────────── */
.tabs-nav {
    display: flex;
    gap: .4rem;
    border-bottom: 2px solid var(--color-border);
    margin-bottom: 1.5rem;
    flex-wrap: wrap;
}
.tab-link {
    padding: .5rem 1.1rem;
    border-radius: var(--radius-sm) var(--radius-sm) 0 0;
    text-decoration: none;
    font-size: .87rem;
    font-weight: 500;
    color: var(--color-muted);
    background: var(--color-surface);
    border: 1px solid transparent;
    border-bottom: none;
    transition: background .13s, color .13s;
}
.tab-link:hover { background: #eef2f7; color: var(--color-primary); }
.tab-link--active {
    background: white;
    color: var(--color-primary);
    border-color: var(--color-border);
    font-weight: 700;
    margin-bottom: -2px;
    padding-bottom: .65rem;
}

/* ── Campos formativos ──────────────────────── */
.campo-grupo { margin-bottom: 1rem; }
.campo-titulo {
    font-size: .72rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: .06em;
    color: var(--color-muted);
    padding: .3rem 0 .3rem .4rem;
    border-left: 3px solid var(--color-primary);
    margin-bottom: .4rem;
}

/* ── Checkboxes de materias ─────────────────── */
.materia-check-label {
    display: flex;
    align-items: center;
    gap: .5rem;
    padding: .45rem .6rem;
    border: 1px solid var(--color-border);
    border-radius: var(--radius-sm);
    margin-bottom: .3rem;
    cursor: pointer;
    font-size: .87rem;
    background: var(--color-surface);
    transition: background .12s, border-color .12s;
}
.materia-check-label:hover { background: #f1f5f9; }
.materia-check-label--on  { background: #eff6ff; border-color: #93c5fd; }
.materia-check-label input[type=checkbox] {
    width: 16px; height: 16px;
    accent-color: var(--color-primary);
    cursor: pointer;
}
.mat-nombre { flex: 1; }

/* ── Subcomponentes grid ────────────────────── */
.subs-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: .35rem;
    margin-bottom: .5rem;
}
.sub-check-label {
    display: flex;
    align-items: center;
    gap: .4rem;
    padding: .45rem .6rem;
    border: 1px solid var(--color-border);
    border-radius: var(--radius-sm);
    cursor: pointer;
    font-size: .87rem;
    background: var(--color-surface);
    transition: background .12s, border-color .12s;
}
.sub-check-label:hover    { background: #f1f5f9; }
.sub-check-label--on      { background: #eff6ff; border-color: #93c5fd; }
.sub-check-label input[type=checkbox] {
    width:15px; height:15px;
    accent-color: var(--color-primary);
}

/* ── Aspectos preview ───────────────────────── */
.aspectos-preview {
    display: flex;
    flex-wrap: wrap;
    gap: .3rem;
    margin-top: .6rem;
}
.asp-tag {
    font-size: .72rem;
    padding: .15rem .5rem;
    border-radius: 20px;
    background: #dbeafe;
    color: #1e40af;
    font-weight: 500;
}

/* ── Tabla listado ──────────────────────────── */
.separator { margin: 1rem 0; border: none; border-top: 1px solid var(--color-border); }
.grupo-asignaciones { margin-bottom: 1.5rem; }
.grupo-titulo { font-size: .95rem; color: var(--color-primary); margin-bottom: .5rem; }
.estado-cell, .acciones-cell { text-align: center; }
.table-actions { display: flex; gap: .4rem; flex-wrap: wrap; justify-content: center; }

/* ── Formulario ─────────────────────────────── */
.form-group { margin-bottom: .8rem; }
.form-group label { display: block; font-size: .75rem; color: var(--color-muted); margin-bottom: .3rem; }
.form-control {
    width: 100%;
    padding: .5rem .75rem;
    border: 1px solid #ccd3db;
    border-radius: var(--radius-sm);
    font-size: .85rem;
    background: var(--color-surface);
}

/* ── Badges ─────────────────────────────────── */
.badge--info { background: #dbeafe; color: #1e40af; }
.btn--warning { background: #f59e0b; color: white; }
.btn--warning:hover { background: #d97706; }
.btn--danger  { background: #dc2626; color: white; }
.btn--danger:hover  { background: #b91c1c; }

/* ── Responsive ─────────────────────────────── */
@media (max-width: 700px) {
    .asignaciones-layout { grid-template-columns: 1fr; }
    .subs-grid { grid-template-columns: 1fr; }
    .tabs-nav  { gap: .2rem; }
    .tab-link  { font-size: .8rem; padding: .4rem .7rem; }
}
</style>

<?php include __DIR__ . '/../includes/footer.php'; ?>