<?php
// superadmin/asignar_maestros.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
requireRol([1]);

$db = getConexion();

$seccion = $_GET['seccion'] ?? '';
$grado = (int)($_GET['grado'] ?? 0);
$grupo = $_GET['grupo'] ?? '';
$materiaId = (int)($_GET['materia_id'] ?? 0);
$cicloId = 0;

$rowCiclo = $db->query("SELECT id FROM ciclos_escolares WHERE activo = 1 LIMIT 1")->fetch_assoc();
if ($rowCiclo) $cicloId = (int)$rowCiclo['id'];

// Grupos
$gruposDisponibles = [];
if ($seccion && $grado) {
    $stmt = $db->prepare("SELECT nombre FROM grupos WHERE seccion = ? AND grado = ? AND activo = 1 ORDER BY orden");
    $stmt->bind_param('si', $seccion, $grado);
    $stmt->execute();
    $gruposDisponibles = array_column($stmt->get_result()->fetch_all(MYSQLI_ASSOC), 'nombre');
}

// Materias
$materiasDisponibles = [];
if ($seccion && $grado) {
    $stmt = $db->prepare("
        SELECT m.id, m.nombre, m.es_ingles, m.es_artes, m.es_higiene, m.es_disciplina, m.es_ausencias,
               gm.campo_formativo_id, gm.orden
        FROM grados_materias gm
        JOIN materias m ON m.id = gm.materia_id
        WHERE gm.seccion = ? AND gm.grado = ? AND gm.activo = 1
        ORDER BY gm.orden ASC
    ");
    $stmt->bind_param('si', $seccion, $grado);
    $stmt->execute();
    $materiasDisponibles = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
}

// Subcomponentes de Artes
$subcomponentes = [];
$subcompStmt = $db->query("SELECT id, nombre FROM artes_subcomponentes WHERE activo = 1 ORDER BY orden");
while ($row = $subcompStmt->fetch_assoc()) {
    $subcomponentes[] = $row;
}

// Profesores
$profesores = [];
$stmt = $db->query("SELECT id, nombre, apellido_paterno, apellido_materno, tipo FROM profesores WHERE activo = 1 ORDER BY tipo, apellido_paterno");
while ($row = $stmt->fetch_assoc()) {
    $profesores[$row['tipo']][] = $row;
}

// Asignación actual
$asignacionActual = null;
$subcomponenteActual = null;
$aspectosInglesActuales = [];
$maestrosAsignados = [];

if ($cicloId && $seccion && $grado && $grupo && $materiaId) {
    $stmt = $db->prepare("SELECT a.id, a.orden, a.campo_formativo_id FROM asignaciones a WHERE a.ciclo_id = ? AND a.seccion = ? AND a.grado = ? AND a.grupo = ? AND a.materia_id = ? AND a.activo = 1 LIMIT 1");
    $stmt->bind_param('issii', $cicloId, $seccion, $grado, $grupo, $materiaId);
    $stmt->execute();
    $asignacionActual = $stmt->get_result()->fetch_assoc();
    
    if ($asignacionActual) {
        $asigId = $asignacionActual['id'];
        
        $stmt2 = $db->prepare("SELECT subcomponente_id FROM asignacion_artes WHERE asignacion_id = ? LIMIT 1");
        $stmt2->bind_param('i', $asigId);
        $stmt2->execute();
        $artesRow = $stmt2->get_result()->fetch_assoc();
        $subcomponenteActual = $artesRow ? $artesRow['subcomponente_id'] : null;
        
        $stmt3 = $db->prepare("SELECT id, nombre, porcentaje, orden FROM asignacion_ingles_aspectos WHERE asignacion_id = ? ORDER BY orden");
        $stmt3->bind_param('i', $asigId);
        $stmt3->execute();
        $aspectosInglesActuales = $stmt3->get_result()->fetch_all(MYSQLI_ASSOC);
        
        $stmt4 = $db->prepare("SELECT am.profesor_id, am.es_titular, p.nombre, p.apellido_paterno, p.apellido_materno, p.tipo FROM asignacion_maestros am JOIN profesores p ON p.id = am.profesor_id WHERE am.asignacion_id = ? AND am.activo = 1 ORDER BY am.es_titular DESC, am.orden ASC");
        $stmt4->bind_param('i', $asigId);
        $stmt4->execute();
        $maestrosAsignados = $stmt4->get_result()->fetch_all(MYSQLI_ASSOC);
    }
}

// Guardar
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['guardar'])) {
    $seccionPost = $_POST['seccion'];
    $gradoPost = (int)$_POST['grado'];
    $grupoPost = $_POST['grupo'];
    $materiaIdPost = (int)$_POST['materia_id'];
    $campoFormativoId = !empty($_POST['campo_formativo_id']) ? (int)$_POST['campo_formativo_id'] : null;
    $orden = (int)$_POST['orden'];
    $subcomponenteId = !empty($_POST['subcomponente_id']) ? (int)$_POST['subcomponente_id'] : null;
    $aspectosInglesPost = $_POST['aspectos_ingles'] ?? [];
    $maestros = $_POST['maestros'] ?? [];
    
    $materiaData = null;
    foreach ($materiasDisponibles as $m) {
        if ($m['id'] == $materiaIdPost) {
            $materiaData = $m;
            break;
        }
    }
    $esArtes = $materiaData['es_artes'] ?? 0;
    $esIngles = $materiaData['es_ingles'] ?? 0;
    
    if (!$cicloId) {
        $error = "No hay ciclo activo";
    } else {
        $stmt = $db->prepare("SELECT id FROM asignaciones WHERE ciclo_id = ? AND seccion = ? AND grado = ? AND grupo = ? AND materia_id = ? LIMIT 1");
        $stmt->bind_param('issii', $cicloId, $seccionPost, $gradoPost, $grupoPost, $materiaIdPost);
        $stmt->execute();
        $asig = $stmt->get_result()->fetch_assoc();
        
        if ($asig) {
            $asignacionId = $asig['id'];
            $upd = $db->prepare("UPDATE asignaciones SET campo_formativo_id = ?, orden = ? WHERE id = ?");
            $upd->bind_param('iii', $campoFormativoId, $orden, $asignacionId);
            $upd->execute();
            $del = $db->prepare("DELETE FROM asignacion_maestros WHERE asignacion_id = ?");
            $del->bind_param('i', $asignacionId);
            $del->execute();
        } else {
            $ins = $db->prepare("INSERT INTO asignaciones (ciclo_id, materia_id, campo_formativo_id, seccion, grado, grupo, orden, activo) VALUES (?, ?, ?, ?, ?, ?, ?, 1)");
            $ins->bind_param('iiissii', $cicloId, $materiaIdPost, $campoFormativoId, $seccionPost, $gradoPost, $grupoPost, $orden);
            $ins->execute();
            $asignacionId = $db->insert_id;
        }
        
        if ($asignacionId && $esArtes) {
            $delArtes = $db->prepare("DELETE FROM asignacion_artes WHERE asignacion_id = ?");
            $delArtes->bind_param('i', $asignacionId);
            $delArtes->execute();
            if ($subcomponenteId) {
                $insArtes = $db->prepare("INSERT INTO asignacion_artes (asignacion_id, subcomponente_id) VALUES (?, ?)");
                $insArtes->bind_param('ii', $asignacionId, $subcomponenteId);
                $insArtes->execute();
            }
        }
        
        if ($asignacionId && $esIngles) {
            $delIngles = $db->prepare("DELETE FROM asignacion_ingles_aspectos WHERE asignacion_id = ?");
            $delIngles->bind_param('i', $asignacionId);
            $delIngles->execute();
            
            if (!empty($aspectosInglesPost)) {
                $insAspecto = $db->prepare("INSERT INTO asignacion_ingles_aspectos (asignacion_id, nombre, porcentaje, orden, activo, grado, seccion) VALUES (?, ?, ?, ?, 1, ?, ?)");
                $ordenAsp = 0;
                foreach ($aspectosInglesPost as $asp) {
                    $nombre = trim($asp['nombre'] ?? '');
                    $porcentaje = (float)($asp['porcentaje'] ?? 0);
                    if (!empty($nombre)) {
                        $insAspecto->bind_param('isdiis', $asignacionId, $nombre, $porcentaje, $ordenAsp, $gradoPost, $seccionPost);
                        $insAspecto->execute();
                        $ordenAsp++;
                    }
                }
            }
        }
        
        if ($asignacionId && !empty($maestros)) {
            $insMaestro = $db->prepare("INSERT INTO asignacion_maestros (asignacion_id, profesor_id, es_titular, orden, activo) VALUES (?, ?, ?, ?, 1)");
            $ordenMaestro = 0;
            foreach ($maestros as $m) {
                $profesorId = (int)$m['profesor_id'];
                $esTitular = isset($m['es_titular']) ? 1 : 0;
                if ($profesorId > 0) {
                    $insMaestro->bind_param('iiii', $asignacionId, $profesorId, $esTitular, $ordenMaestro);
                    $insMaestro->execute();
                    $ordenMaestro++;
                }
            }
        }
        
        header("Location: asignar_maestros.php?seccion={$seccionPost}&grado={$gradoPost}&grupo={$grupoPost}&materia_id={$materiaIdPost}&success=1");
        exit;
    }
}

$success = isset($_GET['success']) ? 1 : 0;

$pageTitle = 'Superadmin › Asignar maestros';
$backLink = 'dashboard.php';
include __DIR__ . '/../includes/header.php';
?>

<main class="container">
    
    <?php if ($success): ?>
        <p class="alert alert--success">✅ Asignación guardada correctamente.</p>
    <?php endif; ?>
    
    <?php if (isset($error)): ?>
        <p class="alert alert--error">⚠️ <?= htmlspecialchars($error) ?></p>
    <?php endif; ?>

    <div class="card">
        <h2 class="section-title">👨‍🏫 Asignar maestros a materias</h2>

        <form method="GET" style="margin-bottom: 1.5rem;">
            <div style="display: flex; gap: 1rem; flex-wrap: wrap;">
                <div class="form-group" style="margin-bottom: 0;">
                    <label for="seccion">Sección</label>
                    <select name="seccion" id="seccion" onchange="this.form.submit()">
                        <option value="">-- Selecciona --</option>
                        <option value="primaria" <?= $seccion === 'primaria' ? 'selected' : '' ?>>Primaria</option>
                        <option value="secundaria" <?= $seccion === 'secundaria' ? 'selected' : '' ?>>Secundaria</option>
                        <option value="preescolar" <?= $seccion === 'preescolar' ? 'selected' : '' ?>>Preescolar</option>
                        <option value="maternal" <?= $seccion === 'maternal' ? 'selected' : '' ?>>Maternal</option>
                    </select>
                </div>
                
                <div class="form-group" style="margin-bottom: 0;">
                    <label for="grado">Grado</label>
                    <select name="grado" id="grado" onchange="this.form.submit()" <?= !$seccion ? 'disabled' : '' ?>>
                        <option value="">-- Selecciona --</option>
                        <?php for ($i = 1; $i <= 6; $i++): ?>
                            <option value="<?= $i ?>" <?= $grado === $i ? 'selected' : '' ?>><?= $i ?>°</option>
                        <?php endfor; ?>
                    </select>
                </div>
                
                <div class="form-group" style="margin-bottom: 0;">
                    <label for="grupo">Grupo</label>
                    <select name="grupo" id="grupo" onchange="this.form.submit()" <?= !$grado ? 'disabled' : '' ?>>
                        <option value="">-- Selecciona --</option>
                        <?php foreach ($gruposDisponibles as $g): ?>
                            <option value="<?= $g ?>" <?= $grupo === $g ? 'selected' : '' ?>><?= $g ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                
                <div class="form-group" style="margin-bottom: 0;">
                    <label for="materia_id">Materia</label>
                    <select name="materia_id" id="materia_id" onchange="this.form.submit()" <?= !$grupo ? 'disabled' : '' ?>>
                        <option value="">-- Selecciona --</option>
                        <?php foreach ($materiasDisponibles as $m): ?>
                            <option value="<?= $m['id'] ?>" <?= $materiaId === $m['id'] ? 'selected' : '' ?>>
                                <?= htmlspecialchars($m['nombre']) ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                </div>
            </div>
        </form>

        <?php if ($seccion && $grado && $grupo && $materiaId): 
            $materiaSeleccionada = null;
            foreach ($materiasDisponibles as $m) {
                if ($m['id'] == $materiaId) {
                    $materiaSeleccionada = $m;
                    break;
                }
            }
            $esArtes = $materiaSeleccionada['es_artes'] ?? 0;
            $esIngles = $materiaSeleccionada['es_ingles'] ?? 0;
        ?>
            <form method="POST">
                <input type="hidden" name="seccion" value="<?= $seccion ?>">
                <input type="hidden" name="grado" value="<?= $grado ?>">
                <input type="hidden" name="grupo" value="<?= $grupo ?>">
                <input type="hidden" name="materia_id" value="<?= $materiaId ?>">

                <div class="form-group">
                    <label for="campo_formativo_id">Campo formativo</label>
                    <select name="campo_formativo_id" id="campo_formativo_id">
                        <option value="">Sin campo formativo</option>
                        <?php
                        $campos = $db->query("SELECT id, nombre FROM campos_formativos WHERE activo = 1 ORDER BY orden");
                        while ($cf = $campos->fetch_assoc()):
                        ?>
                            <option value="<?= $cf['id'] ?>" <?= ($asignacionActual['campo_formativo_id'] ?? $materiaSeleccionada['campo_formativo_id'] ?? '') == $cf['id'] ? 'selected' : '' ?>>
                                <?= htmlspecialchars($cf['nombre']) ?>
                            </option>
                        <?php endwhile; ?>
                    </select>
                </div>

                <div class="form-group">
                    <label for="orden">Orden en la boleta</label>
                    <input type="number" name="orden" id="orden" min="0" value="<?= $asignacionActual['orden'] ?? $materiaSeleccionada['orden'] ?? 0 ?>">
                </div>

                <?php if ($esArtes): ?>
                <div class="form-group">
                    <label for="subcomponente_id">🎨 Subcomponente de Artes</label>
                    <select name="subcomponente_id" id="subcomponente_id">
                        <option value="">-- Selecciona --</option>
                        <?php foreach ($subcomponentes as $sc): ?>
                            <option value="<?= $sc['id'] ?>" <?= ($subcomponenteActual == $sc['id']) ? 'selected' : '' ?>>
                                <?= htmlspecialchars($sc['nombre']) ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <?php endif; ?>

                <?php if ($esIngles): ?>
                <div class="form-group">
                    <label>🌐 Aspectos de Inglés</label>
                    <div id="aspectos-container">
                        <?php
                        // Aspectos por defecto para Inglés
                        $aspectosDefault = [
                            'Listening' => 0,
                            'Speaking' => 0,
                            'Reading' => 0,
                            'Writing' => 0,
                            'Vocabulary' => 0,
                            'Grammar' => 0,
                            'Spelling' => 0
                        ];
                        
                        if (!empty($aspectosInglesActuales)) {
                            foreach ($aspectosInglesActuales as $idx => $asp):
                        ?>
                            <div class="aspecto-row">
                                <input type="text" name="aspectos_ingles[<?= $idx ?>][nombre]" value="<?= htmlspecialchars($asp['nombre']) ?>" style="flex:2;" placeholder="Nombre">
                                <input type="number" name="aspectos_ingles[<?= $idx ?>][porcentaje]" value="<?= $asp['porcentaje'] ?>" step="0.01" style="width:80px;" placeholder="%">
                                <button type="button" class="btn btn--sm btn--danger remove-aspecto">✕</button>
                            </div>
                        <?php 
                            endforeach;
                        } else {
                            $idx = 0;
                            foreach ($aspectosDefault as $nombre => $porcentaje):
                        ?>
                            <div class="aspecto-row">
                                <input type="text" name="aspectos_ingles[<?= $idx ?>][nombre]" value="<?= $nombre ?>" style="flex:2;" placeholder="Nombre">
                                <input type="number" name="aspectos_ingles[<?= $idx ?>][porcentaje]" value="<?= $porcentaje ?>" step="0.01" style="width:80px;" placeholder="%">
                                <button type="button" class="btn btn--sm btn--danger remove-aspecto">✕</button>
                            </div>
                        <?php 
                                $idx++;
                            endforeach;
                        }
                        ?>
                    </div>
                    <button type="button" id="add-aspecto" class="btn btn--sm" style="margin-top: 0.5rem;">+ Agregar aspecto</button>
                </div>
                <?php endif; ?>

                <h3 style="margin: 1.5rem 0 1rem 0;">👨‍🏫 Maestros asignados</h3>
                <div id="maestros-container">
                    <?php if (empty($maestrosAsignados)): ?>
                        <div class="maestro-row">
                            <select name="maestros[0][profesor_id]" style="flex:2;">
                                <option value="">Seleccionar...</option>
                                <?php
                                $tipos = $esArtes ? ['cocurricular', 'titular'] : ['titular', 'frances', 'cocurricular'];
                                foreach ($tipos as $tipo):
                                    if (isset($profesores[$tipo])):
                                        foreach ($profesores[$tipo] as $p):
                                ?>
                                    <option value="<?= $p['id'] ?>">[<?= ucfirst($tipo) ?>] <?= htmlspecialchars($p['apellido_paterno'] . ' ' . $p['nombre']) ?></option>
                                <?php 
                                        endforeach;
                                    endif;
                                endforeach; 
                                ?>
                            </select>
                            <label style="white-space: nowrap;"><input type="checkbox" name="maestros[0][es_titular]" value="1"> Titular</label>
                            <button type="button" class="btn btn--sm btn--danger remove-maestro">✕</button>
                        </div>
                    <?php else: ?>
                        <?php foreach ($maestrosAsignados as $idx => $m): ?>
                            <div class="maestro-row">
                                <select name="maestros[<?= $idx ?>][profesor_id]" style="flex:2;">
                                    <option value="">Seleccionar...</option>
                                    <?php
                                    $tipos = $esArtes ? ['cocurricular', 'titular'] : ['titular', 'frances', 'cocurricular'];
                                    foreach ($tipos as $tipo):
                                        if (isset($profesores[$tipo])):
                                            foreach ($profesores[$tipo] as $p):
                                    ?>
                                        <option value="<?= $p['id'] ?>" <?= $m['profesor_id'] == $p['id'] ? 'selected' : '' ?>>
                                            [<?= ucfirst($tipo) ?>] <?= htmlspecialchars($p['apellido_paterno'] . ' ' . $p['nombre']) ?>
                                        </option>
                                    <?php 
                                            endforeach;
                                        endif;
                                    endforeach; 
                                    ?>
                                </select>
                                <label style="white-space: nowrap;"><input type="checkbox" name="maestros[<?= $idx ?>][es_titular]" value="1" <?= $m['es_titular'] ? 'checked' : '' ?>> Titular</label>
                                <button type="button" class="btn btn--sm btn--danger remove-maestro">✕</button>
                            </div>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </div>
                <button type="button" id="add-maestro" class="btn btn--sm" style="margin: 0.5rem 0;">+ Agregar otro maestro</button>

                <div style="margin-top: 1.5rem;">
                    <button type="submit" name="guardar" class="btn">💾 Guardar asignación</button>
                </div>
            </form>
        <?php endif; ?>
    </div>
</main>

<style>
.maestro-row, .aspecto-row {
    display: flex;
    gap: 0.5rem;
    align-items: center;
    margin-bottom: 0.5rem;
    padding: 0.5rem;
    background: #f8fafc;
    border-radius: 4px;
    border: 1px solid #e2e8f0;
}
.maestro-row select { flex: 2; padding: 0.3rem; }
.aspecto-row input { padding: 0.3rem; }
</style>

<script>
document.getElementById('add-maestro')?.addEventListener('click', function() {
    const c = document.getElementById('maestros-container');
    const i = c.children.length;
    const d = document.createElement('div');
    d.className = 'maestro-row';
    d.innerHTML = `<select name="maestros[${i}][profesor_id]" style="flex:2;"><option value="">Seleccionar...</option><?php
        $tipos = ['titular', 'frances', 'cocurricular'];
        foreach ($tipos as $tipo):
            if (isset($profesores[$tipo])):
                foreach ($profesores[$tipo] as $p):
    ?><option value="<?= $p['id'] ?>">[<?= ucfirst($tipo) ?>] <?= htmlspecialchars($p['apellido_paterno'] . ' ' . $p['nombre']) ?></option><?php
                endforeach;
            endif;
        endforeach;
    ?></select>
    <label style="white-space: nowrap;"><input type="checkbox" name="maestros[${i}][es_titular]" value="1"> Titular</label>
    <button type="button" class="btn btn--sm btn--danger remove-maestro">✕</button>`;
    c.appendChild(d);
    d.querySelector('.remove-maestro').onclick = () => d.remove();
});

document.getElementById('add-aspecto')?.addEventListener('click', function() {
    const c = document.getElementById('aspectos-container');
    const i = c.children.length;
    const d = document.createElement('div');
    d.className = 'aspecto-row';
    d.innerHTML = `<input type="text" name="aspectos_ingles[${i}][nombre]" placeholder="ej. Listening" style="flex:2;">
                   <input type="number" name="aspectos_ingles[${i}][porcentaje]" placeholder="%" step="0.01" style="width:80px;">
                   <button type="button" class="btn btn--sm btn--danger remove-aspecto">✕</button>`;
    c.appendChild(d);
    d.querySelector('.remove-aspecto').onclick = () => d.remove();
});

document.querySelectorAll('.remove-maestro').forEach(b => b.onclick = () => b.closest('.maestro-row').remove());
document.querySelectorAll('.remove-aspecto').forEach(b => b.onclick = () => b.closest('.aspecto-row').remove());
</script>

<?php include __DIR__ . '/../includes/footer.php'; ?>