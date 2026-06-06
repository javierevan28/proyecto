<?php
// superadmin/asignaciones_higiene.php
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

$db            = getConexion();
$asigModelo    = new AsignacionModel($db);
$cicloModelo   = new CicloModel($db);
$materiaModelo = new MateriaModel($db);
$campoModelo   = new CampoFormativoModel($db);
$profModelo    = new ProfesorModel($db, new UserModel($db));
$artesModelo   = new ArteSubcomponenteModel($db);

$resultado = null;
$accion    = $_GET['accion'] ?? '';
$editId    = (int)($_GET['id'] ?? 0);

if ($accion === 'desactivar' && $editId > 0) {
    $stmt = $db->prepare("UPDATE asignaciones SET activo = 0 WHERE id = ?");
    $stmt->bind_param('i', $editId);
    $stmt->execute();
    header('Location: asignaciones_higiene.php?msg=desactivado');
    exit;
}

if ($accion === 'activar' && $editId > 0) {
    $stmt = $db->prepare("UPDATE asignaciones SET activo = 1 WHERE id = ?");
    $stmt->bind_param('i', $editId);
    $stmt->execute();
    header('Location: asignaciones_higiene.php?msg=activado');
    exit;
}

// ELIMINAR
if ($accion === 'eliminar' && $editId > 0) {
    $db->query("DELETE FROM asignacion_maestros WHERE asignacion_id = $editId");
    $db->query("DELETE FROM asignacion_artes WHERE asignacion_id = $editId");
    $db->query("DELETE FROM asignacion_ingles_aspectos WHERE asignacion_id = $editId");
    $db->query("DELETE FROM asignaciones WHERE id = $editId");
    header('Location: asignaciones_higiene.php?msg=eliminado');
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Validar que el grado sea válido para Higiene (solo secundaria 1-3)
    $seccion = $_POST['seccion'] ?? '';
    $grado = (int)($_POST['grado'] ?? 0);
    
    if ($seccion !== 'secundaria' || $grado < 1 || $grado > 3) {
        $resultado = ['error' => 'Higiene solo está disponible para secundaria (1° a 3° grado)'];
    } else {
        $resultado = $asigModelo->crearLote($_POST);
    }
}

$msgRedir  = $_GET['msg']     ?? '';
$msgDetall = $_GET['detalle'] ?? '';

$cicloActivo = $cicloModelo->obtenerActivo();

// FILTRAR materias disponibles: solo Higiene
$todasMaterias = $materiaModelo->listarActivas();
$materiasForm = array_filter($todasMaterias, function($m) {
    return (int)$m['es_higiene'] === 1;
});
$materiasForm = array_values($materiasForm);

$campos         = $campoModelo->listarActivos();
$subcomps       = $artesModelo->listarActivos();
$titulares      = $profModelo->listarActivosPorTipo('titular');
$frances        = $profModelo->listarActivosPorTipo('frances');
$cocurriculares = $profModelo->listarActivosPorTipo('cocurricular');

// Obtener TODAS las asignaciones y filtrar para mostrar solo Higiene
$todasAsignaciones = $cicloActivo
    ? $asigModelo->listarPorCicloAgrupado((int)$cicloActivo['id'])
    : [];

$asignaciones = [];
foreach ($todasAsignaciones as $key => $grupo) {
    $grupoFiltrado = [];
    foreach ($grupo as $asignacion) {
        if ((int)$asignacion['es_higiene'] === 1) {
            $grupoFiltrado[] = $asignacion;
        }
    }
    if (!empty($grupoFiltrado)) {
        $asignaciones[$key] = $grupoFiltrado;
    }
}

$pageTitle = 'Superadmin › Asignaciones - Higiene (solo secundaria)';
$backLink  = 'dashboard.php';
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

  <?php if ($resultado && isset($resultado['success'])): ?>
    <p class="alert alert--success">✅ <?= $resultado['creadas'] ?> asignación(es) creada(s).</p>
  <?php elseif ($resultado && isset($resultado['error'])): ?>
    <p class="alert alert--error">⚠️ <?= htmlspecialchars($resultado['error']) ?></p>
  <?php endif; ?>

  <?php if ($msgRedir === 'activado'): ?>
    <p class="alert alert--success">✅ Asignación activada.</p>
  <?php elseif ($msgRedir === 'desactivado'): ?>
    <p class="alert alert--success">✅ Asignación desactivada.</p>
  <?php elseif ($msgRedir === 'eliminado'): ?>
    <p class="alert alert--success">✅ Asignación ELIMINADA correctamente.</p>
  <?php elseif ($msgRedir === 'error'): ?>
    <p class="alert alert--error">⚠️ <?= htmlspecialchars($msgDetall) ?></p>
  <?php endif; ?>

  <?php if (!$cicloActivo): ?>
    <p class="alert alert--error">
      ⚠️ No hay un ciclo escolar activo.
      <a href="ciclos_escolares.php">Configura uno primero</a>.
    </p>
  <?php else: ?>

  <div style="display:grid; grid-template-columns:1fr 1.8fr; gap:1.5rem; align-items:start;">

    <section class="card">
      <h2 class="section-title">➕ Nueva asignación - Higiene</h2>
      <p style="font-size:.82rem; color:var(--color-muted); margin-bottom:1rem;">
        Ciclo: <strong><?= htmlspecialchars($cicloActivo['nombre']) ?></strong>
      </p>
      <p class="alert alert--info" style="margin-bottom:1rem;">⚠️ Higiene solo aplica para <strong>Secundaria (1° a 3° grado)</strong></p>

      <form method="POST" id="form-asignacion" novalidate>
        <input type="hidden" name="ciclo_id" value="<?= $cicloActivo['id'] ?>">

        <div class="form-group">
          <label for="seccion">Sección *</label>
          <select id="seccion" name="seccion" required>
            <option value="">Selecciona…</option>
            <option value="secundaria">Secundaria</option>
          </select>
        </div>

        <div class="form-group">
          <label for="grado">Grado *</label>
          <select id="grado" name="grado" required>
            <option value="">Selecciona…</option>
            <?php for ($i = 1; $i <= 3; $i++): ?>
              <option value="<?= $i ?>"><?= $i ?>°</option>
            <?php endfor; ?>
          </select>
        </div>

        <div class="form-group">
          <label for="grupo">Grupo *</label>
          <select id="grupo" name="grupo" required>
            <option value="">Selecciona…</option>
            <?php foreach (['A','B','C','D'] as $grp): ?>
              <option value="<?= $grp ?>"><?= $grp ?></option>
            <?php endforeach; ?>
          </select>
        </div>

        <div id="wrap-materias" hidden>
          <hr style="margin:1rem 0; border-color:var(--color-border);">
          <p style="font-size:.85rem; color:var(--color-muted); margin-bottom:.8rem;">
            Selecciona las materias y asigna un maestro a cada una:
          </p>
          <div id="lista-materias"></div>
        </div>

        <button class="btn" type="submit" id="btn-guardar" hidden>
          Guardar asignaciones
        </button>
      </form>
    </section>

    <section>
      <h2 class="section-title">
        Asignaciones — <?= htmlspecialchars($cicloActivo['nombre']) ?>
      </h2>

      <?php if (empty($asignaciones)): ?>
        <p class="empty-state">Aún no hay asignaciones de Higiene para este ciclo.</p>
      <?php else: ?>

        <?php foreach ($asignaciones as $key => $grupo): ?>
          <?php
            $primera = $grupo[0];
            $label   = ucfirst($primera['seccion']) . ' — ' .
                       $primera['grado'] . '° ' . $primera['grupo'];
          ?>
          <div style="margin-bottom:1.5rem;">
            <h3 style="font-size:.95rem; color:var(--color-primary); margin-bottom:.5rem;">
              📚 <?= $label ?>
            </h3>
            <table class="data-table">
              <thead>
                <tr>
                  <th>Materia</th>
                  <th>Campo formativo</th>
                  <th>Maestro(s)</th>
                  <th>Estado</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <?php foreach ($grupo as $a): ?>
                  <?php
                    $esActivo   = (int)$a['activo'] === 1;
                    $nombreSafe = htmlspecialchars($a['materia_nombre']);
                  ?>
                  <tr>
                    <td>
                      <strong><?= $nombreSafe ?></strong>
                      <span class="badge badge--warn">Higiene</span>
                      <?php if ((int)($a['hay_titular'] ?? 0)): ?>
                        <span class="badge badge--active">Titular</span>
                      <?php endif; ?>
                    </td>
                    <td>
                      <?= $a['campo_formativo_nombre']
                          ? htmlspecialchars($a['campo_formativo_nombre'])
                          : '<span style="color:var(--color-placeholder)">—</span>'
                      ?>
                    </td>
                    <td style="font-size:.8rem;">
                      <?= $a['maestros']
                          ? htmlspecialchars($a['maestros'])
                          : '<span style="color:var(--color-placeholder)">Sin asignar</span>'
                      ?>
                    </td>
                    <td style="text-align:center;">
                      <?php if ($esActivo): ?>
                        <span class="badge badge--active">Activo</span>
                      <?php else: ?>
                        <span class="badge badge--warn">Inactivo</span>
                      <?php endif; ?>
                    </td>
                    <td style="text-align:center;">
                      <div class="table-actions">
                        <a href="javascript:void(0)" class="btn btn--sm <?= $esActivo ? 'btn--warning' : 'btn--success' ?> action-btn"
                           data-url="asignaciones_higiene.php?accion=<?= $esActivo ? 'desactivar' : 'activar' ?>&id=<?= $a['id'] ?>"
                           data-title="<?= $esActivo ? 'Desactivar' : 'Activar' ?>"
                           data-body="<?= $esActivo ? '¿Desactivar ' . $nombreSafe . '?' : '¿Activar ' . $nombreSafe . '?' ?>">
                          <?= $esActivo ? 'Desactivar' : 'Activar' ?>
                        </a>
                        <a href="javascript:void(0)" class="btn btn--sm btn--danger action-btn"
                           data-url="asignaciones_higiene.php?accion=eliminar&id=<?= $a['id'] ?>"
                           data-title="Eliminar"
                           data-body="¿ELIMINAR <?= $nombreSafe ?>? Esta acción NO se puede deshacer.">
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

      <?php endif; ?>
    </section>

  </div>
  <?php endif; ?>
</main>

<script>
// Modal personalizado
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

// Generar formulario dinámico
const seccionSelect = document.getElementById('seccion');
const gradoSelect = document.getElementById('grado');
const grupoSelect = document.getElementById('grupo');
const wrapMaterias = document.getElementById('wrap-materias');
const listaMaterias = document.getElementById('lista-materias');
const btnGuardar = document.getElementById('btn-guardar');

function generarFormulario() {
    const seccion = seccionSelect.value;
    const grado = gradoSelect.value;
    const grupo = grupoSelect.value;
    
    const MATERIAS = <?= json_encode($materiasForm) ?>;
    const TITULARES = <?= json_encode($titulares) ?>;

    if (!seccion || !grado || !grupo) {
        wrapMaterias.hidden = true;
        btnGuardar.hidden = true;
        return;
    }

    let html = '';
    for (const materia of MATERIAS) {
        html += `
            <div style="border:1px solid #ccc; padding:0.8rem; margin-bottom:0.8rem; border-radius:8px;">
                <strong>${materia.nombre}</strong>
                <div class="form-group" style="margin-top:0.5rem;">
                    <label>Maestro asignado</label>
                    <select name="materia[${materia.id}][profesor_id]" class="form-control" required>
                        <option value="">Seleccionar maestro...</option>
                        ${TITULARES.map(p => `<option value="${p.id}">${p.apellido_paterno} ${p.apellido_materno || ''}, ${p.nombre}</option>`).join('')}
                    </select>
                </div>
                <div class="check-option">
                    <input type="checkbox" name="materia[${materia.id}][es_titular]" value="1" id="titular_${materia.id}">
                    <label for="titular_${materia.id}">Es titular de este grupo</label>
                </div>
                <input type="hidden" name="materia[${materia.id}][campo_formativo_id]" value="${materia.campo_formativo_id || ''}">
                <input type="hidden" name="materia[${materia.id}][orden]" value="0">
            </div>
        `;
    }
    listaMaterias.innerHTML = html;
    wrapMaterias.hidden = false;
    btnGuardar.hidden = false;
}

seccionSelect.addEventListener('change', generarFormulario);
gradoSelect.addEventListener('change', generarFormulario);
grupoSelect.addEventListener('change', generarFormulario);
</script>

<style>
.form-group { margin-bottom: 1rem; }
.form-group label { display: block; font-size: 0.75rem; margin-bottom: 0.3rem; color: #666; }
.form-control { width: 100%; padding: 0.5rem; border: 1px solid #ccc; border-radius: 4px; }
.check-option { display: flex; align-items: center; gap: 0.5rem; margin-top: 0.5rem; }
.check-option input { width: 16px; height: 16px; cursor: pointer; accent-color: var(--color-primary); }
.check-option label { font-size: 0.8rem; color: var(--color-text); cursor: pointer; }
.table-actions { display: flex; gap: 0.4rem; flex-wrap: wrap; justify-content: center; }
.btn--warning { background: #f59e0b; color: white; }
.btn--warning:hover { background: #d97706; }
.badge--active { background: #10b981; color: white; }
.badge--warn { background: #f59e0b; color: white; }
.alert--info { background: #dbeafe; color: #1e40af; padding: 0.5rem; border-radius: 6px; font-size: 0.75rem; }
</style>

<?php include __DIR__ . '/../includes/footer.php'; ?>