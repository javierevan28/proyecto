<?php
// superadmin/gestion_calificaciones.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
requireRol([1]);

$db = getConexion();

$seccion = $_GET['seccion'] ?? '';
$grado = (int)($_GET['grado'] ?? 0);
$grupo = $_GET['grupo'] ?? '';
$materiaId = (int)($_GET['materia_id'] ?? 0);
$periodo = (int)($_GET['periodo'] ?? 1);

$mensaje = '';
$error = '';

// Obtener materias desde grados_materias
$materiasDisponibles = [];
if ($seccion && $grado) {
    $stmt = $db->prepare("
        SELECT m.id, m.nombre, m.es_ingles, m.es_artes
        FROM grados_materias gm
        JOIN materias m ON m.id = gm.materia_id
        WHERE gm.seccion = ? AND gm.grado = ? AND gm.activo = 1
        ORDER BY gm.orden ASC
    ");
    $stmt->bind_param('si', $seccion, $grado);
    $stmt->execute();
    $materiasDisponibles = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
}

// Guardar calificaciones
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['guardar'])) {
    $asignacionId = (int)$_POST['asignacion_id'];
    $periodo = (int)$_POST['periodo'];
    
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
    $mensaje = "Calificaciones guardadas correctamente.";
}

// Obtener datos si hay materia seleccionada
$alumnos = [];
$aspectos = [];
$asignacionId = 0;

if ($materiaId && $seccion && $grado && $grupo) {
    // Buscar asignacion_id
    $stmt = $db->prepare("
        SELECT id FROM asignaciones 
        WHERE materia_id = ? AND seccion = ? AND grado = ? AND grupo = ? AND activo = 1
        LIMIT 1
    ");
    $stmt->bind_param('isis', $materiaId, $seccion, $grado, $grupo);
    $stmt->execute();
    $row = $stmt->get_result()->fetch_assoc();
    $asignacionId = $row ? $row['id'] : 0;
    
    if ($asignacionId) {
        // Obtener aspectos
        $stmt = $db->prepare("SELECT id, nombre, porcentaje FROM asignacion_aspectos WHERE asignacion_id = ? AND activo = 1 ORDER BY orden");
        $stmt->bind_param('i', $asignacionId);
        $stmt->execute();
        $aspectos = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
        
        // Obtener alumnos (SIN DUPLICADOS)
        $stmt = $db->prepare("
            SELECT al.id, al.nombre, al.apellido_paterno, al.apellido_materno, al.matricula
            FROM alumnos al
            WHERE al.seccion = ? AND al.grado = ? AND al.grupo = ? AND al.activo = 1
            ORDER BY al.apellido_paterno, al.apellido_materno, al.nombre
        ");
        $stmt->bind_param('sis', $seccion, $grado, $grupo);
        $stmt->execute();
        $alumnosRaw = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
        
        // Obtener calificaciones existentes y evitar duplicados
        $alumnos = [];
        $idsVistos = [];
        foreach ($alumnosRaw as $al) {
            if (!in_array($al['id'], $idsVistos)) {
                $idsVistos[] = $al['id'];
                $al['califs'] = [];
                
                $stmt2 = $db->prepare("
                    SELECT aspecto_id, calificacion FROM calificaciones 
                    WHERE alumno_id = ? AND asignacion_id = ? AND periodo = ?
                ");
                $stmt2->bind_param('iii', $al['id'], $asignacionId, $periodo);
                $stmt2->execute();
                $res2 = $stmt2->get_result();
                while ($r = $res2->fetch_assoc()) {
                    $al['califs'][$r['aspecto_id']] = $r['calificacion'];
                }
                $alumnos[] = $al;
            }
        }
    }
}

$pageTitle = 'Superadmin › Gestionar calificaciones';
$backLink = 'dashboard.php';
include __DIR__ . '/../includes/header.php';
?>

<style>
.filtros { background: #f8fafc; padding: 1rem; border-radius: 8px; margin-bottom: 1.5rem; display: flex; gap: 1rem; flex-wrap: wrap; align-items: end; }
.filtros .form-group { margin-bottom: 0; }
.tabla-calif { width: 100%; border-collapse: collapse; font-size: 0.75rem; }
.tabla-calif th, .tabla-calif td { border: 1px solid #e2e8f0; padding: 0.4rem; text-align: center; }
.tabla-calif th { background: #1e3a5f; color: white; }
.cal-input { width: 55px; padding: 0.2rem; text-align: center; border: 1px solid #ccc; border-radius: 4px; }
</style>

<main class="container">
    <div class="card">
        <h2 class="section-title">📊 Gestionar calificaciones</h2>
        
        <?php if ($mensaje): ?>
            <p class="alert alert--success">✅ <?= $mensaje ?></p>
        <?php endif; ?>
        <?php if ($error): ?>
            <p class="alert alert--error">⚠️ <?= $error ?></p>
        <?php endif; ?>
        
        <form method="GET" class="filtros">
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
                    <?php for ($i=1;$i<=6;$i++): ?>
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
                <label>Materia</label>
                <select name="materia_id" onchange="this.form.submit()" <?= !$grupo ? 'disabled' : '' ?>>
                    <option value="">--</option>
                    <?php foreach ($materiasDisponibles as $m): ?>
                        <option value="<?= $m['id'] ?>" <?= $materiaId === $m['id'] ? 'selected' : '' ?>><?= $m['nombre'] ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="form-group">
                <label>Periodo</label>
                <select name="periodo" onchange="this.form.submit()">
                    <?php for ($p=1;$p<=6;$p++): ?>
                        <option value="<?= $p ?>" <?= $periodo === $p ? 'selected' : '' ?>>Periodo <?= $p ?></option>
                    <?php endfor; ?>
                </select>
            </div>
        </form>
        
        <?php if ($materiaId && $asignacionId && $alumnos): ?>
            <form method="POST">
                <input type="hidden" name="asignacion_id" value="<?= $asignacionId ?>">
                <input type="hidden" name="periodo" value="<?= $periodo ?>">
                <div style="overflow-x: auto;">
                    <table class="tabla-calif">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Alumno</th>
                                <th>Matrícula</th>
                                <?php foreach ($aspectos as $asp): ?>
                                    <th><?= $asp['nombre'] ?><br><small><?= $asp['porcentaje'] ?>%</small></th>
                                <?php endforeach; ?>
                                <th>Promedio</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php $i=1; foreach ($alumnos as $al): 
                                $suma = 0; $peso = 0;
                            ?>
                            <tr>
                                <td><?= $i++ ?></td>
                                <td style="text-align:left;"><?= htmlspecialchars($al['apellido_paterno'] . ' ' . ($al['apellido_materno'] ?? '') . ', ' . $al['nombre']) ?></td>
                                <td><?= htmlspecialchars($al['matricula'] ?? '—') ?></td>
                                <?php foreach ($aspectos as $asp): 
                                    $val = $al['califs'][$asp['id']] ?? '';
                                    if ($val !== '') {
                                        $suma += $val * ($asp['porcentaje'] / 100);
                                        $peso += $asp['porcentaje'];
                                    }
                                ?>
                                    <td><input type="number" name="calificacion[<?= $al['id'] ?>][<?= $asp['id'] ?>]" value="<?= $val ?>" min="0" max="10" step="0.1" class="cal-input"></td>
                                <?php endforeach; 
                                    $promedio = $peso > 0 ? round($suma) : '';
                                ?>
                                <td><strong><?= $promedio ?></strong></td>
                            </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
                <button type="submit" name="guardar" class="btn" style="margin-top:1rem;">💾 Guardar cambios</button>
            </form>
        <?php elseif ($materiaId && !$asignacionId): ?>
            <p class="empty-state">⚠️ Esta materia no está asignada a este grupo.</p>
        <?php elseif ($materiaId): ?>
            <p class="empty-state">No hay alumnos en este grupo.</p>
        <?php endif; ?>
    </div>
</main>

<?php include __DIR__ . '/../includes/footer.php'; ?>