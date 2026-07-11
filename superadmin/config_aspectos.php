<?php
// superadmin/config_aspectos.php

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/ConfigAspectosModel.php';
requireRol([1]);

$db      = getConexion();
$modelo  = new ConfigAspectosModel($db);

$resultado = null;
$seccionActual = $_GET['seccion'] ?? 'primaria';
$gradoActual = isset($_GET['grado']) ? (int)$_GET['grado'] : null;

// Guardar cambios globales
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['guardar_global'])) {
    foreach ($_POST['aspectos'] ?? [] as $id => $datos) {
        $modelo->actualizarGlobal((int)$id, $datos);
    }
    $resultado = ['success' => true, 'msg' => 'Configuración global guardada'];
}

// Guardar sobrescritura por grado
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['guardar_grado'])) {
    $seccion = $_POST['seccion'] ?? '';
    $grado = (int)($_POST['grado'] ?? 0);
    $aspectos = [];
    
    foreach ($_POST['nombre_aspecto'] ?? [] as $i => $nombre) {
        if (!empty($nombre)) {
            $aspectos[] = [
                'nombre' => $nombre,
                'porcentaje' => (float)($_POST['porcentaje'][$i] ?? 0),
                'orden' => (int)($_POST['orden'][$i] ?? 0)
            ];
        }
    }
    
    if (!empty($aspectos)) {
        $resultado = $modelo->guardarSobrescritura($seccion, $grado, $aspectos);
    }
}

// Eliminar sobrescritura
if ($_GET['accion'] === 'eliminar_sobrescritura' && isset($_GET['seccion']) && isset($_GET['grado'])) {
    $resultado = $modelo->eliminarSobrescritura($_GET['seccion'], (int)$_GET['grado']);
    header('Location: config_aspectos.php?seccion=' . urlencode($_GET['seccion']) . '&msg=eliminado');
    exit;
}

$aspectosGlobales = $modelo->listarGlobales();
$secciones = ['maternal', 'preescolar', 'primaria', 'secundaria'];
$grados = [];

if ($seccionActual === 'secundaria') {
    $grados = [1, 2, 3];
} else {
    $grados = [1, 2, 3, 4, 5, 6];
}

// Verificar si existe sobrescritura para este grado
$tieneSobrescritura = false;
$aspectosGrado = [];
if ($gradoActual) {
    $aspectosGrado = $modelo->obtenerPorGrado($seccionActual, $gradoActual);
    $tieneSobrescritura = !empty($aspectosGrado) && 
        $aspectosGrado !== $modelo->obtenerGlobales($seccionActual);
}

$pageTitle = 'Superadmin › Configuración de aspectos';
$backLink = 'dashboard.php';
include __DIR__ . '/../includes/header.php';
?>

<main class="container">
    <div class="card">
        <h2 class="section-title">⚙️ Configuración de aspectos de evaluación</h2>
        <p class="form-hint">Define los porcentajes de evaluación por sección. Puedes sobrescribir por grado específico.</p>

        <?php if ($resultado && isset($resultado['success'])): ?>
            <p class="alert alert--success">✅ <?= htmlspecialchars($resultado['msg'] ?? 'Operación exitosa') ?></p>
        <?php elseif ($resultado && isset($resultado['error'])): ?>
            <p class="alert alert--error">⚠️ <?= htmlspecialchars($resultado['error']) ?></p>
        <?php endif; ?>

        <!-- Selector de sección -->
        <div style="display: flex; gap: 1rem; align-items: center; margin-bottom: 1.5rem;">
            <div class="form-group" style="margin-bottom:0;">
                <label for="seccion">Sección</label>
                <select name="seccion" id="seccion" onchange="location.href='config_aspectos.php?seccion='+this.value">
                    <?php foreach ($secciones as $sec): ?>
                        <option value="<?= $sec ?>" <?= $seccionActual === $sec ? 'selected' : '' ?>>
                            <?= ucfirst($sec) ?>
                        </option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="form-group" style="margin-bottom:0;">
                <label for="grado">Sobrescribir por grado</label>
                <select name="grado" id="grado" onchange="location.href='config_aspectos.php?seccion=<?= $seccionActual ?>&grado='+this.value">
                    <option value="">--- Sin sobrescritura ---</option>
                    <?php foreach ($grados as $g): ?>
                        <option value="<?= $g ?>" <?= $gradoActual === $g ? 'selected' : '' ?>>
                            <?= $g ?>° grado
                        </option>
                    <?php endforeach; ?>
                </select>
            </div>
            <?php if ($tieneSobrescritura): ?>
                <a href="config_aspectos.php?accion=eliminar_sobrescritura&seccion=<?= $seccionActual ?>&grado=<?= $gradoActual ?>"
                   class="btn btn--sm btn--danger"
                   onclick="return confirm('¿Eliminar sobrescritura? Volverá a usar la configuración global.')">
                    🗑️ Eliminar sobrescritura
                </a>
            <?php endif; ?>
        </div>

        <?php if ($gradoActual && $tieneSobrescritura): ?>
            <!-- Formulario de sobrescritura por grado -->
            <form method="POST">
                <input type="hidden" name="seccion" value="<?= $seccionActual ?>">
                <input type="hidden" name="grado" value="<?= $gradoActual ?>">
                <h3>Sobrescritura para <?= ucfirst($seccionActual) ?> <?= $gradoActual ?>°</h3>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Orden</th>
                            <th>Aspecto</th>
                            <th>Porcentaje (%)</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody id="aspectos-grado-body">
                        <?php foreach ($aspectosGrado as $idx => $asp): ?>
                            <tr>
                                <td><input type="number" name="orden[]" value="<?= $asp['orden'] ?>" style="width:60px;" min="0"></td>
                                <td><input type="text" name="nombre_aspecto[]" value="<?= htmlspecialchars($asp['nombre_aspecto'] ?? $asp['nombre']) ?>" style="width:100%;"></td>
                                <td><input type="number" name="porcentaje[]" value="<?= $asp['porcentaje_default'] ?? $asp['porcentaje'] ?>" step="0.01" style="width:80px;"></td>
                                <td><button type="button" class="btn btn--sm btn--danger" onclick="this.closest('tr').remove()">🗑️</button></td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
                <button type="button" class="btn btn--sm" onclick="agregarFilaGrado()">+ Agregar aspecto</button>
                <button type="submit" name="guardar_grado" class="btn">💾 Guardar sobrescritura</button>
            </form>

        <?php elseif ($gradoActual && !$tieneSobrescritura): ?>
            <!-- Crear nueva sobrescritura -->
            <form method="POST">
                <input type="hidden" name="seccion" value="<?= $seccionActual ?>">
                <input type="hidden" name="grado" value="<?= $gradoActual ?>">
                <h3>Crear sobrescritura para <?= ucfirst($seccionActual) ?> <?= $gradoActual ?>°</h3>
                <p class="form-hint">Configura aspectos específicos para este grado. Si no configuras, usará la configuración global.</p>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Orden</th>
                            <th>Aspecto</th>
                            <th>Porcentaje (%)</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody id="aspectos-grado-nuevo">
                        <?php 
                        $globales = $modelo->obtenerGlobales($seccionActual);
                        foreach ($globales as $asp): ?>
                            <tr>
                                <td><input type="number" name="orden[]" value="<?= $asp['orden_default'] ?>" style="width:60px;" min="0"></td>
                                <td><input type="text" name="nombre_aspecto[]" value="<?= htmlspecialchars($asp['nombre_aspecto']) ?>" style="width:100%;"></td>
                                <td><input type="number" name="porcentaje[]" value="<?= $asp['porcentaje_default'] ?>" step="0.01" style="width:80px;"></td>
                                <td><button type="button" class="btn btn--sm btn--danger" onclick="this.closest('tr').remove()">🗑️</button></td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
                <button type="button" class="btn btn--sm" onclick="agregarFilaGrado()">+ Agregar aspecto</button>
                <button type="submit" name="guardar_grado" class="btn">💾 Crear sobrescritura</button>
            </form>

        <?php else: ?>
            <!-- Configuración global -->
            <form method="POST">
                <h3>Configuración global para <?= ucfirst($seccionActual) ?></h3>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Orden</th>
                            <th>Aspecto</th>
                            <th>Porcentaje (%)</th>
                            <th>Activo</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($aspectosGlobales as $asp): 
                            if ($asp['seccion'] !== $seccionActual) continue;
                        ?>
                            <tr>
                                <td><input type="number" name="aspectos[<?= $asp['id'] ?>][orden]" value="<?= $asp['orden_default'] ?>" style="width:60px;" min="0"></td>
                                <td><?= htmlspecialchars($asp['nombre_aspecto']) ?></td>
                                <td><input type="number" name="aspectos[<?= $asp['id'] ?>][porcentaje]" value="<?= $asp['porcentaje_default'] ?>" step="0.01" style="width:80px;"></td>
                                <td>
                                    <input type="checkbox" name="aspectos[<?= $asp['id'] ?>][activo]" value="1" <?= $asp['activo'] ? 'checked' : '' ?>>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
                <button type="submit" name="guardar_global" class="btn">💾 Guardar configuración global</button>
            </form>
        <?php endif; ?>

        <hr style="margin: 2rem 0;">

        <div class="alert alert--info">
            <strong>📌 Nota:</strong> Los porcentajes deben sumar 100% para primaria y secundaria.<br>
            Para preescolar se recomienda enfoque cualitativo. Para maternal los porcentajes no aplican (0%).
        </div>
    </div>
</main>

<script>
function agregarFilaGrado() {
    const tbody = document.querySelector('#aspectos-grado-body, #aspectos-grado-nuevo');
    if (!tbody) return;
    const row = document.createElement('tr');
    row.innerHTML = `
        <td><input type="number" name="orden[]" style="width:60px;" min="0"></td>
        <td><input type="text" name="nombre_aspecto[]" style="width:100%;" placeholder="Nuevo aspecto"></td>
        <td><input type="number" name="porcentaje[]" step="0.01" style="width:80px;"></td>
        <td><button type="button" class="btn btn--sm btn--danger" onclick="this.closest('tr').remove()">🗑️</button></td>
    `;
    tbody.appendChild(row);
}
</script>

<?php include __DIR__ . '/../includes/footer.php'; ?>