<?php
// superadmin/asignaciones_artes.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/AsignacionModel.php';
require_once __DIR__ . '/../models/CicloModel.php';
require_once __DIR__ . '/../models/MateriaModel.php';
require_once __DIR__ . '/../models/CampoFormativoModel.php';
require_once __DIR__ . '/../models/ProfesorModel.php';
require_once __DIR__ . '/../models/ArteSubcomponenteModel.php';
require_once __DIR__ . '/../models/UserModel.php';
requireRol([1]);

$db = getConexion();
$asigModelo = new AsignacionModel($db);
$cicloModelo = new CicloModel($db);
$materiaModelo = new MateriaModel($db);
$campoModelo = new CampoFormativoModel($db);
$profModelo = new ProfesorModel($db, new UserModel($db));
$artesModelo = new ArteSubcomponenteModel($db);

$resultado = null;
$accion = $_GET['accion'] ?? '';
$editId = (int)($_GET['id'] ?? 0);

// ACTIVAR
if ($accion === 'activar' && $editId > 0) {
    $stmt = $db->prepare("UPDATE asignaciones SET activo = 1 WHERE id = ?");
    $stmt->bind_param('i', $editId);
    $stmt->execute();
    header('Location: asignaciones_artes.php?msg=activado');
    exit;
}

// DESACTIVAR
if ($accion === 'desactivar' && $editId > 0) {
    $stmt = $db->prepare("UPDATE asignaciones SET activo = 0 WHERE id = ?");
    $stmt->bind_param('i', $editId);
    $stmt->execute();
    header('Location: asignaciones_artes.php?msg=desactivado');
    exit;
}

// ELIMINAR
if ($accion === 'eliminar' && $editId > 0) {
    $db->query("DELETE FROM asignacion_maestros WHERE asignacion_id = $editId");
    $db->query("DELETE FROM asignacion_artes WHERE asignacion_id = $editId");
    $db->query("DELETE FROM asignacion_ingles_aspectos WHERE asignacion_id = $editId");
    $db->query("DELETE FROM asignaciones WHERE id = $editId");
    header('Location: asignaciones_artes.php?msg=eliminado');
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $resultado = $asigModelo->crearLote($_POST);
}

$msgRedir = $_GET['msg'] ?? '';
$msgDetall = $_GET['detalle'] ?? '';

$cicloActivo = $cicloModelo->obtenerActivo();

$campos = $campoModelo->listarActivos();
$subcomps = $artesModelo->listarActivos();
$cocurriculares = $profModelo->listarActivosPorTipo('cocurricular');

$todasAsignaciones = $cicloActivo
    ? $asigModelo->listarPorCicloAgrupado((int)$cicloActivo['id'])
    : [];

$asignaciones = [];
foreach ($todasAsignaciones as $key => $grupo) {
    $grupoFiltrado = [];
    foreach ($grupo as $asignacion) {
        if ((int)$asignacion['es_artes'] === 1) {
            $grupoFiltrado[] = $asignacion;
        }
    }
    if (!empty($grupoFiltrado)) {
        $asignaciones[$key] = $grupoFiltrado;
    }
}

$seccionSeleccionada = $_GET['seccion'] ?? '';
$gradoSeleccionado = $_GET['grado'] ?? '';
$grupoSeleccionado = $_GET['grupo'] ?? '';
$materiasDelGrado = [];

if ($seccionSeleccionada && $gradoSeleccionado && $cicloActivo) {
    $stmt = $db->prepare("
        SELECT m.id, m.nombre, m.campo_formativo_id, gm.orden
        FROM grados_materias gm
        JOIN materias m ON m.id = gm.materia_id
        WHERE gm.seccion = ? AND gm.grado = ? AND m.es_artes = 1
        AND NOT EXISTS (
            SELECT 1 FROM asignaciones a 
            WHERE a.ciclo_id = ? 
            AND a.seccion = gm.seccion 
            AND a.grado = gm.grado 
            AND a.grupo = ? 
            AND a.materia_id = m.id
        )
        ORDER BY gm.orden ASC
    ");
    $stmt->bind_param('siis', $seccionSeleccionada, $gradoSeleccionado, $cicloActivo['id'], $grupoSeleccionado);
    $stmt->execute();
    $materiasDelGrado = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
}

$pageTitle = 'Superadmin › Asignaciones - Artes';
$backLink = 'dashboard.php';
include __DIR__ . '/../includes/header.php';
?>

<!-- MODAL PERSONALIZADO -->
<div id="confirmModal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:1000; align-items:center; justify-content:center;">
    <div style="background:white; border-radius:12px; padding:20px; max-width:400px; margin:auto; box-shadow:0 4px 20px rgba(0,0,0,0.2);">
        <h3 id="modalTitle" style="margin-bottom:15px; color:#1e3a5f;">Confirmar</h3>
        <p id="modalBody" style="margin-bottom:20px;">¿Estás seguro de realizar esta acción?</p>
        <div style="display:flex; gap:10px; justify-content:flex-end;">
            <button id="modalCancel" class="btn" style="background:#e2e8f0; color:#333;">Cancelar</button>
            <a id="modalConfirm" class="btn" style="background:#dc2626; color:white;">Confirmar</a>
        </div>
    </div>
</div>

<main class="container">

  <?php if ($msgRedir === 'activado'): ?>
    <p class="alert alert--success">✅ Asignación activada.</p>
  <?php elseif ($msgRedir === 'desactivado'): ?>
    <p class="alert alert--success">✅ Asignación desactivada.</p>
  <?php elseif ($msgRedir === 'eliminado'): ?>
    <p class="alert alert--success">✅ Asignación ELIMINADA correctamente.</p>
  <?php endif; ?>

  <?php if (!$cicloActivo): ?>
    <p class="alert alert--error">⚠️ No hay un ciclo escolar activo.</p>
  <?php else: ?>

  <div style="display: grid; grid-template-columns: 1fr 1.8fr; gap: 1.5rem;">
    <!-- FORMULARIO PARA NUEVAS ASIGNACIONES -->
    <div class="card">
      <h2 class="section-title">🎨 Nueva asignación - Artes</h2>
      <p class="form-hint">Ciclo: <strong><?= htmlspecialchars($cicloActivo['nome']) ?></strong></p>

      <form method="GET" style="margin-bottom: 1rem;">
        <div class="form-group">
          <label for="seccion">Sección</label>
          <select name="seccion" id="seccion" onchange="this.form.submit()" required>
            <option value="">Selecciona...</option>
            <?php foreach (['maternal','preescolar','primaria','secundaria'] as $sec): ?>
              <option value="<?= $sec ?>" <?= $seccionSeleccionada === $sec ? 'selected' : '' ?>><?= ucfirst($sec) ?></option>
            <?php endforeach; ?>
          </select>
        </div>
        <div class="form-group">
          <label for="grado">Grado</label>
          <select name="grado" id="grado" onchange="this.form.submit()" required>
            <option value="">Selecciona...</option>
            <?php for ($i = 1; $i <= 6; $i++): ?>
              <option value="<?= $i ?>" <?= $gradoSeleccionado == $i ? 'selected' : '' ?>><?= $i ?>°</option>
            <?php endfor; ?>
          </select>
        </div>
        <div class="form-group">
          <label for="grupo">Grupo</label>
          <select name="grupo" id="grupo" onchange="this.form.submit()" required>
            <option value="">Selecciona...</option>
            <?php foreach (['A','B','C','D'] as $grp): ?>
              <option value="<?= $grp ?>" <?= $grupoSeleccionado === $grp ? 'selected' : '' ?>><?= $grp ?></option>
            <?php endforeach; ?>
          </select>
        </div>
      </form>

      <?php if ($seccionSeleccionada && $gradoSeleccionado && $grupoSeleccionado): ?>
        <form method="POST">
          <input type="hidden" name="ciclo_id" value="<?= $cicloActivo['id'] ?>">
          <input type="hidden" name="seccion" value="<?= $seccionSeleccionada ?>">
          <input type="hidden" name="grado" value="<?= $gradoSeleccionado ?>">
          <input type="hidden" name="grupo" value="<?= $grupoSeleccionado ?>">

          <?php if (empty($materiasDelGrado)): ?>
            <p class="alert alert--success">✅ Todas las materias de Artes ya están asignadas.</p>
          <?php else: ?>
            <?php foreach ($materiasDelGrado as $m): ?>
              <div style="border:1px solid #ccc; padding:0.8rem; margin-bottom:0.8rem; border-radius:8px;">
                <strong><?= htmlspecialchars($m['nombre']) ?></strong>
                <div class="form-group" style="margin-top:0.5rem;">
                  <label>Maestro</label>
                  <select name="materia[<?= $m['id'] ?>][profesor_id]" class="form-control" required>
                    <option value="">Seleccionar...</option>
                    <?php foreach ($cocurriculares as $p): ?>
                      <option value="<?= $p['id'] ?>"><?= htmlspecialchars($p['apellido_paterno'] . ' ' . ($p['apellido_materno'] ?? '') . ', ' . $p['nombre']) ?></option>
                    <?php endforeach; ?>
                  </select>
                </div>
                <div>
                  <input type="checkbox" name="materia[<?= $m['id'] ?>][es_titular]" value="1" id="titular_<?= $m['id'] ?>">
                  <label for="titular_<?= $m['id'] ?>">Es titular</label>
                </div>
                <input type="hidden" name="materia[<?= $m['id'] ?>][campo_formativo_id]" value="<?= $m['campo_formativo_id'] ?? '' ?>">
                <input type="hidden" name="materia[<?= $m['id'] ?>][orden]" value="<?= $m['orden'] ?? 0 ?>">
                <input type="hidden" name="materia[<?= $m['id'] ?>][es_artes]" value="1">
              </div>
            <?php endforeach; ?>
            <button type="submit" name="guardar" class="btn">💾 Guardar asignaciones</button>
          <?php endif; ?>
        </form>
      <?php endif; ?>
    </div>

    <!-- LISTADO DE ASIGNACIONES EXISTENTES -->
    <div class="card">
      <h2 class="section-title">📋 Asignaciones actuales</h2>
      <?php if (empty($asignaciones)): ?>
        <p class="empty-state">No hay asignaciones de Artes.</p>
      <?php else: ?>
        <?php foreach ($asignaciones as $key => $grupo): ?>
          <?php $primera = $grupo[0]; ?>
          <div style="margin-bottom: 1.5rem;">
            <h3 style="color:var(--color-primary);">🎨 <?= ucfirst($primera['seccion']) ?> — <?= $primera['grado'] ?>° <?= $primera['grupo'] ?></h3>
            <table class="data-table" style="width:100%; font-size:0.8rem;">
              <thead>
                <tr><th>Materia</th><th>Maestro(s)</th><th>Estado</th><th>Acciones</th></tr>
              </thead>
              <tbody>
                <?php foreach ($grupo as $a): ?>
                  <?php
                  $esActivo = (int)$a['activo'] === 1;
                  $nombreSafe = htmlspecialchars($a['materia_nombre']);
                  ?>
                  <tr>
                    <td><strong><?= $nombreSafe ?></strong></td>
                    <td><?= $a['maestros'] ? htmlspecialchars($a['maestros']) : '—' ?></td>
                    <td><?= $esActivo ? '✅ Activo' : '❌ Inactivo' ?></td>
                    <td>
                      <a href="javascript:void(0)" class="btn btn--sm <?= $esActivo ? 'btn--warning' : 'btn--success' ?> action-btn"
                         data-url="?accion=<?= $esActivo ? 'desactivar' : 'activar' ?>&id=<?= $a['id'] ?>"
                         data-title="<?= $esActivo ? 'Desactivar' : 'Activar' ?>"
                         data-body="<?= $esActivo ? '¿Desactivar ' . $nombreSafe . '?' : '¿Activar ' . $nombreSafe . '?' ?>">
                        <?= $esActivo ? 'Desactivar' : 'Activar' ?>
                      </a>
                      <a href="javascript:void(0)" class="btn btn--sm btn--danger action-btn"
                         data-url="?accion=eliminar&id=<?= $a['id'] ?>"
                         data-title="Eliminar"
                         data-body="¿ELIMINAR <?= $nombreSafe ?>? Esta acción NO se puede deshacer.">
                        🗑️ Eliminar
                      </a>
                    </td>
                  </tr>
                <?php endforeach; ?>
              </tbody>
            </table>
          </div>
        <?php endforeach; ?>
      <?php endif; ?>
    </div>
  </div>
  <?php endif; ?>
</main>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const modal = document.getElementById('confirmModal');
    const modalTitle = document.getElementById('modalTitle');
    const modalBody = document.getElementById('modalBody');
    const modalConfirm = document.getElementById('modalConfirm');
    const modalCancel = document.getElementById('modalCancel');
    
    let currentUrl = '';
    
    document.querySelectorAll('.action-btn').forEach(btn => {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            currentUrl = this.dataset.url;
            modalTitle.textContent = this.dataset.title;
            modalBody.textContent = this.dataset.body;
            modal.style.display = 'flex';
        });
    });
    
    modalConfirm.addEventListener('click', function() {
        window.location.href = currentUrl;
    });
    
    modalCancel.addEventListener('click', function() {
        modal.style.display = 'none';
    });
    
    modal.addEventListener('click', function(e) {
        if (e.target === modal) {
            modal.style.display = 'none';
        }
    });
});
</script>

<style>
.form-group { margin-bottom: 1rem; }
.form-group label { display: block; font-size: 0.75rem; margin-bottom: 0.3rem; color: #666; }
.form-control { width: 100%; padding: 0.5rem; border: 1px solid #ccc; border-radius: 4px; }
.btn--warning { background: #f59e0b; color: white; }
.btn--warning:hover { background: #d97706; }
</style>

<?php include __DIR__ . '/../includes/footer.php'; ?>