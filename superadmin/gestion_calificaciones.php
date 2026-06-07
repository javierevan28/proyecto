<?php
// superadmin/gestion_calificaciones.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
requireRol([1]);

$db = getConexion();

$seccion   = $_GET['seccion']       ?? '';
$grado     = (int)($_GET['grado']   ?? 0);
$grupo     = $_GET['grupo']         ?? '';
$idioma    = $_GET['idioma']        ?? 'espanol';
$materiaId = (int)($_GET['materia_id'] ?? 0);
$periodo   = (int)($_GET['periodo']    ?? 1);

$mensaje = '';
$error   = '';

// Detectar si la materia seleccionada es de ausencias
$esAusencias = false;
if ($materiaId) {
    $stmtM = $db->prepare("SELECT es_ausencias FROM materias WHERE id = ? LIMIT 1");
    $stmtM->bind_param('i', $materiaId);
    $stmtM->execute();
    $rowM = $stmtM->get_result()->fetch_assoc();
    $esAusencias = $rowM && (int)$rowM['es_ausencias'] === 1;
}

// Obtener ciclo activo (para ausencias)
$cicloId = 0;
$rowCiclo = $db->query("SELECT id FROM ciclos_escolares WHERE activo = 1 LIMIT 1")->fetch_assoc();
if ($rowCiclo) $cicloId = (int)$rowCiclo['id'];

// ── POST: borrar calificaciones normales ──────────────────────
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['borrar_todas'])) {
    $asignacionId  = (int)$_POST['asignacion_id'];
    $periodoBorrar = (int)$_POST['periodo_borrar'];
    $stmt = $db->prepare("DELETE FROM calificaciones WHERE asignacion_id = ? AND periodo = ?");
    $stmt->bind_param('ii', $asignacionId, $periodoBorrar);
    if ($stmt->execute()) {
        $mensaje = "✅ Se eliminaron calificaciones correctamente.";
    } else {
        $error = "❌ Error al eliminar las calificaciones.";
    }
}

// ── POST: guardar ausencias ───────────────────────────────────
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['guardar_ausencias'])) {
    $periodoPost = (int)$_POST['periodo'];
    $stmt = $db->prepare("
        INSERT INTO ausencias (alumno_id, ciclo_id, periodo, dias_ausencia, capturado_por)
        VALUES (?, ?, ?, ?, 1)
        ON DUPLICATE KEY UPDATE
            dias_ausencia  = VALUES(dias_ausencia),
            capturado_por  = VALUES(capturado_por),
            actualizado_en = NOW()
    ");
    $errores = 0;
    foreach ($_POST['dias'] as $alumnoId => $d) {
        $alumnoId = (int)$alumnoId;
        $d        = max(0, min(31, (int)$d));
        $stmt->bind_param('iiiii', $alumnoId, $cicloId, $periodoPost, $d, $d); // capturado_por = 1 (superadmin)
        if (!$stmt->execute()) $errores++;
    }
    $mensaje = $errores > 0
        ? "⚠️ Hubo $errores error(es) al guardar ausencias."
        : "✅ Ausencias guardadas correctamente.";
}

// ── POST: guardar calificaciones normales ─────────────────────
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['guardar'])) {
    $asignacionId = (int)$_POST['asignacion_id'];
    $periodo      = (int)$_POST['periodo'];
    foreach ($_POST['calificacion'] as $alumnoId => $aspectos) {
        foreach ($aspectos as $aspectoId => $cal) {
            $cal = $cal === '' ? null : (float)$cal;
            if ($cal !== null && ($cal < 0 || $cal > 10)) continue;
            $stmt = $db->prepare("
                INSERT INTO calificaciones (alumno_id, asignacion_id, aspecto_id, periodo, calificacion, capturado_por)
                VALUES (?, ?, ?, ?, ?, 1)
                ON DUPLICATE KEY UPDATE calificacion = VALUES(calificacion)
            ");
            $stmt->bind_param('iiiid', $alumnoId, $asignacionId, $aspectoId, $periodo, $cal);
            $stmt->execute();
        }
    }
    $mensaje = "✅ Calificaciones guardadas correctamente.";
}

// ── Materias separadas por idioma ─────────────────────────────
$materiasEspanol = [];
$materiasIngles  = [];

if ($seccion && $grado) {
    $stmt = $db->prepare("
        SELECT m.id, m.nombre, m.es_ingles
        FROM grados_materias gm
        JOIN materias m ON m.id = gm.materia_id
        WHERE gm.seccion = ? AND gm.grado = ? AND gm.activo = 1
        ORDER BY
            CASE WHEN m.es_ingles = 1 THEN 1 ELSE 0 END ASC,
            gm.orden ASC, m.nombre ASC
    ");
    $stmt->bind_param('si', $seccion, $grado);
    $stmt->execute();
    $todasMaterias = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);

    foreach ($todasMaterias as $m) {
        if ((int)$m['es_ingles'] === 1) {
            $materiasIngles[] = $m;
        } else {
            $materiasEspanol[] = $m;
        }
    }
}

$materiasActuales = $idioma === 'ingles' ? $materiasIngles : $materiasEspanol;

// ── Datos para la tabla ───────────────────────────────────────
$alumnos       = [];
$aspectos      = [];
$asignacionId  = 0;
$nombreMateria = '';

if ($materiaId && $seccion && $grado && $grupo) {
    $stmt = $db->prepare("SELECT nombre FROM materias WHERE id = ?");
    $stmt->bind_param('i', $materiaId);
    $stmt->execute();
    $rowMateria    = $stmt->get_result()->fetch_assoc();
    $nombreMateria = $rowMateria ? $rowMateria['nombre'] : '';

    if (!$esAusencias) {
        // Necesitamos asignacion_id solo para materias normales
        $stmt = $db->prepare("
            SELECT id FROM asignaciones
            WHERE materia_id = ? AND seccion = ? AND grado = ? AND grupo = ? AND activo = 1
            LIMIT 1
        ");
        $stmt->bind_param('isis', $materiaId, $seccion, $grado, $grupo);
        $stmt->execute();
        $row          = $stmt->get_result()->fetch_assoc();
        $asignacionId = $row ? $row['id'] : 0;

        if ($asignacionId) {
            $stmt = $db->prepare("SELECT id, nombre, porcentaje FROM asignacion_aspectos WHERE asignacion_id = ? AND activo = 1 ORDER BY orden");
            $stmt->bind_param('i', $asignacionId);
            $stmt->execute();
            $aspectos = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);

            $stmt = $db->prepare("
                SELECT al.id, al.nombre, al.apellido_paterno, al.apellido_materno
                FROM alumnos al
                WHERE al.seccion = ? AND al.grado = ? AND al.grupo = ? AND al.activo = 1
                ORDER BY al.apellido_paterno, al.apellido_materno, al.nombre
            ");
            $stmt->bind_param('sis', $seccion, $grado, $grupo);
            $stmt->execute();
            $alumnosRaw = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);

            $idsVistos = [];
            foreach ($alumnosRaw as $al) {
                if (in_array($al['id'], $idsVistos)) continue;
                $idsVistos[]  = $al['id'];
                $al['califs'] = [];
                $stmt2 = $db->prepare("SELECT aspecto_id, calificacion FROM calificaciones WHERE alumno_id = ? AND asignacion_id = ? AND periodo = ?");
                $stmt2->bind_param('iii', $al['id'], $asignacionId, $periodo);
                $stmt2->execute();
                $res2 = $stmt2->get_result();
                while ($r = $res2->fetch_assoc()) {
                    $al['califs'][$r['aspecto_id']] = $r['calificacion'];
                }
                $alumnos[] = $al;
            }
        }
    } else {
        // AUSENCIAS: traer alumnos con días registrados
        $stmt = $db->prepare("
            SELECT al.id, al.nombre, al.apellido_paterno, al.apellido_materno,
                   COALESCE(au.dias_ausencia, 0) AS dias
            FROM alumnos al
            LEFT JOIN ausencias au
                ON au.alumno_id = al.id
               AND au.ciclo_id  = ?
               AND au.periodo   = ?
            WHERE al.seccion = ? AND al.grado = ? AND al.grupo = ? AND al.activo = 1
            ORDER BY al.apellido_paterno, al.apellido_materno, al.nombre
        ");
        $stmt->bind_param('iisis', $cicloId, $periodo, $seccion, $grado, $grupo);
        $stmt->execute();
        $alumnos = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    }
}

$pageTitle = 'Superadmin › Gestionar calificaciones';
$backLink  = 'dashboard.php';
include __DIR__ . '/../includes/header.php';
?>

<!-- MODAL PERSONALIZADO -->
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
.filtros-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(110px, 1fr));
    gap: 0.75rem;
    margin-bottom: 0.75rem;
    align-items: end;
}
.filtros-idioma-materia {
    display: grid;
    grid-template-columns: 160px 1fr;
    gap: 0.75rem;
    margin-bottom: 1rem;
    align-items: end;
}
.form-group { margin-bottom: 0; }
.form-group label { display: block; font-size: 0.75rem; margin-bottom: 0.3rem; color: #555; }
.form-group select { width: 100%; box-sizing: border-box; }

.tabla-calif { width: 100%; border-collapse: collapse; font-size: 0.75rem; }
.tabla-calif th, .tabla-calif td { border: 1px solid #e2e8f0; padding: 0.4rem; text-align: center; }
.tabla-calif th { background: #1e3a5f; color: white; }
.tabla-calif td.alumno-nombre { text-align: left; white-space: nowrap; }
.cal-input { width: 55px; padding: 0.2rem; text-align: center; border: 1px solid #ccc; border-radius: 4px; }
.aus-input { width: 70px; padding: 0.3rem; text-align: center; border: 1px solid #ccc; border-radius: 4px; font-size: 0.85rem; }

.idioma-btn {
    display: flex;
    gap: 0.5rem;
    margin-bottom: 0.3rem;
}
.idioma-btn button {
    flex: 1;
    padding: 0.4rem 0.5rem;
    border: 2px solid var(--color-border);
    border-radius: var(--radius-sm);
    background: white;
    cursor: pointer;
    font-size: 0.8rem;
    font-weight: 600;
    transition: all .15s;
    color: var(--color-muted);
}
.idioma-btn button.active {
    background: var(--color-primary);
    border-color: var(--color-primary);
    color: white;
}
.header-acciones {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1rem;
    flex-wrap: wrap;
    gap: 0.5rem;
}
.btn-danger { background: #dc2626; color: white; }
.btn-danger:hover { background: #b91c1c; }

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
</style>

<main class="container">
    <div class="card">
        <h2 class="section-title">📊 Gestionar calificaciones</h2>

        <form method="GET" id="form-filtros">
            <input type="hidden" name="idioma" id="input-idioma" value="<?= htmlspecialchars($idioma) ?>">

            <div class="filtros-grid">
                <div class="form-group">
                    <label>Sección</label>
                    <select name="seccion" onchange="this.form.submit()">
                        <option value="">--</option>
                        <?php foreach (['maternal','preescolar','primaria','secundaria'] as $s): ?>
                            <option value="<?= $s ?>" <?= $seccion === $s ? 'selected' : '' ?>><?= ucfirst($s) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="form-group">
                    <label>Grado</label>
                    <select name="grado" onchange="this.form.submit()" <?= !$seccion ? 'disabled' : '' ?>>
                        <option value="">--</option>
                        <?php for ($i = 1; $i <= 6; $i++): ?>
                            <option value="<?= $i ?>" <?= $grado === $i ? 'selected' : '' ?>><?= $i ?>°</option>
                        <?php endfor; ?>
                    </select>
                </div>
                <div class="form-group">
                    <label>Grupo</label>
                    <select name="grupo" onchange="this.form.submit()" <?= !$grado ? 'disabled' : '' ?>>
                        <option value="">--</option>
                        <?php foreach (['A','B','C','D'] as $g): ?>
                            <option value="<?= $g ?>" <?= $grupo === $g ? 'selected' : '' ?>><?= $g ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="form-group">
                    <label>Periodo</label>
                    <select name="periodo" onchange="this.form.submit()">
                        <?php for ($p = 1; $p <= 6; $p++): ?>
                            <option value="<?= $p ?>" <?= $periodo === $p ? 'selected' : '' ?>>Periodo <?= $p ?></option>
                        <?php endfor; ?>
                    </select>
                </div>
            </div>

            <?php if ($grupo): ?>
            <div class="filtros-idioma-materia">
                <div class="form-group">
                    <label>Idioma</label>
                    <div class="idioma-btn">
                        <button type="button"
                                class="<?= $idioma === 'espanol' ? 'active' : '' ?>"
                                onclick="setIdioma('espanol')">🇲🇽 Español</button>
                        <button type="button"
                                class="<?= $idioma === 'ingles' ? 'active' : '' ?>"
                                onclick="setIdioma('ingles')">🇺🇸 Inglés</button>
                    </div>
                </div>
                <div class="form-group">
                    <label>Materia</label>
                    <select name="materia_id" onchange="this.form.submit()">
                        <option value="">-- Selecciona --</option>
                        <?php foreach ($materiasActuales as $m): ?>
                            <option value="<?= $m['id'] ?>" <?= $materiaId === $m['id'] ? 'selected' : '' ?>>
                                <?= htmlspecialchars($m['nombre']) ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                </div>
            </div>
            <?php endif; ?>
        </form>

        <?php if ($materiaId && $alumnos): ?>

            <?php if ($esAusencias): ?>
            <!-- ──────────────── AUSENCIAS ──────────────── -->
            <div class="header-acciones">
                <h3 style="margin:0;">📖 <?= htmlspecialchars($nombreMateria) ?> — Periodo <?= $periodo ?></h3>
            </div>
            <form method="POST">
                <input type="hidden" name="periodo" value="<?= $periodo ?>">
                <table class="tabla-calif">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th style="text-align:left;">Alumno</th>
                            <th>Días de ausencia</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php $i = 1; foreach ($alumnos as $al): ?>
                        <tr>
                            <td><?= $i++ ?></td>
                            <td class="alumno-nombre"><?= htmlspecialchars($al['apellido_paterno'] . ' ' . ($al['apellido_materno'] ?? '') . ', ' . $al['nombre']) ?></td>
                            <td>
                                <input type="number"
                                       name="dias[<?= $al['id'] ?>]"
                                       value="<?= (int)$al['dias'] ?>"
                                       min="0" max="31"
                                       class="aus-input">
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
                <button type="submit" name="guardar_ausencias" class="btn" style="margin-top:1rem;">💾 Guardar ausencias</button>
            </form>

            <?php else: ?>
            <!-- ──────────────── CALIFICACIONES NORMALES ──────────────── -->
            <div class="header-acciones">
                <h3 style="margin:0;">📖 <?= htmlspecialchars($nombreMateria) ?> — Periodo <?= $periodo ?></h3>
                <button type="button" class="btn btn-danger" id="btnBorrarTodo">
                    🗑️ Borrar todas las calificaciones
                </button>
            </div>
            <form method="POST" id="form-calificaciones">
                <input type="hidden" name="asignacion_id" value="<?= $asignacionId ?>">
                <input type="hidden" name="periodo" value="<?= $periodo ?>">
                <div style="overflow-x: auto;">
                    <table class="tabla-calif">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th style="text-align:left; min-width:160px;">Alumno</th>
                                <?php foreach ($aspectos as $asp): ?>
                                    <th><?= htmlspecialchars($asp['nombre']) ?><br><small><?= $asp['porcentaje'] ?>%</small></th>
                                <?php endforeach; ?>
                                <th>Promedio</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php $i = 1; foreach ($alumnos as $al):
                                $suma = 0; $peso = 0;
                            ?>
                            <tr>
                                <td><?= $i++ ?></td>
                                <td class="alumno-nombre"><?= htmlspecialchars($al['apellido_paterno'] . ' ' . ($al['apellido_materno'] ?? '') . ', ' . $al['nombre']) ?></td>
                                <?php foreach ($aspectos as $asp):
                                    $val = $al['califs'][$asp['id']] ?? '';
                                    if ($val !== '') {
                                        $suma += $val * ($asp['porcentaje'] / 100);
                                        $peso += $asp['porcentaje'];
                                    }
                                ?>
                                    <td>
                                        <input type="number"
                                               name="calificacion[<?= $al['id'] ?>][<?= $asp['id'] ?>]"
                                               value="<?= $val ?>"
                                               min="0" max="10" step="0.1"
                                               class="cal-input">
                                    </td>
                                <?php endforeach;
                                    $promedio = $peso > 0 ? round($suma) : '—';
                                ?>
                                <td><strong><?= $promedio ?></strong></td>
                            </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
                <button type="submit" name="guardar" class="btn" style="margin-top:1rem;">💾 Guardar cambios</button>
            </form>
            <?php endif; ?>

        <?php elseif ($materiaId && !$esAusencias && !$asignacionId): ?>
            <p class="empty-state">⚠️ Esta materia no está asignada a este grupo.</p>
        <?php elseif ($grupo && !$materiaId): ?>
            <p class="empty-state">Selecciona un idioma y una materia para capturar calificaciones.</p>
        <?php endif; ?>
    </div>
</main>

<script>
function mostrarNotificacion(mensaje, tipo) {
    const notifExistente = document.querySelector('.notificacion-flotante');
    if (notifExistente) notifExistente.remove();
    const notif = document.createElement('div');
    notif.className = 'notificacion-flotante ' + tipo;
    notif.innerHTML = mensaje;
    document.body.appendChild(notif);
    setTimeout(() => {
        notif.style.animation = 'fadeOut 0.3s ease-out';
        setTimeout(() => { if (notif.parentNode) notif.parentNode.removeChild(notif); }, 300);
    }, 2000);
}

document.addEventListener('DOMContentLoaded', function() {
    const modal       = document.getElementById('confirmModal');
    const modalTitle  = document.getElementById('modalTitle');
    const modalBody   = document.getElementById('modalBody');
    const modalConfirm = document.getElementById('modalConfirm');
    const modalCancel  = document.getElementById('modalCancel');

    <?php if ($mensaje): ?>
        mostrarNotificacion('<?= addslashes($mensaje) ?>', 'success');
    <?php elseif ($error): ?>
        mostrarNotificacion('<?= addslashes($error) ?>', 'error');
    <?php endif; ?>

    const btnBorrar = document.getElementById('btnBorrarTodo');
    if (btnBorrar) {
        btnBorrar.addEventListener('click', function(e) {
            e.preventDefault();
            modalTitle.textContent = '⚠️ Eliminar todas las calificaciones';
            modalBody.innerHTML = `
                <strong>Materia:</strong> <?= addslashes($nombreMateria) ?><br>
                <strong>Periodo:</strong> <?= $periodo ?><br>
                <strong>Grupo:</strong> <?= ucfirst($seccion) ?> <?= $grado ?>° <?= $grupo ?><br><br>
                <span style="color:#dc2626;">⚠️ Esta acción NO se puede deshacer.</span>
            `;
            modal.style.display = 'flex';
        });
    }

    modalConfirm.addEventListener('click', function() {
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = '';
        const inputAsig = document.createElement('input');
        inputAsig.type = 'hidden'; inputAsig.name = 'asignacion_id'; inputAsig.value = '<?= $asignacionId ?>';
        const inputPeriodo = document.createElement('input');
        inputPeriodo.type = 'hidden'; inputPeriodo.name = 'periodo_borrar'; inputPeriodo.value = '<?= $periodo ?>';
        const inputAction = document.createElement('input');
        inputAction.type = 'hidden'; inputAction.name = 'borrar_todas'; inputAction.value = '1';
        form.appendChild(inputAsig);
        form.appendChild(inputPeriodo);
        form.appendChild(inputAction);
        document.body.appendChild(form);
        form.submit();
    });

    modalCancel.addEventListener('click', function() { modal.style.display = 'none'; });
    modal.addEventListener('click', function(e) { if (e.target === modal) modal.style.display = 'none'; });
});

function setIdioma(idioma) {
    document.getElementById('input-idioma').value = idioma;
    const sel = document.querySelector('select[name="materia_id"]');
    if (sel) sel.value = '';
    document.getElementById('form-filtros').submit();
}
</script>

<?php include __DIR__ . '/../includes/footer.php'; ?>