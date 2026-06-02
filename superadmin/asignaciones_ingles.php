<?php
// superadmin/asignaciones_ingles.php
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
    $resultado = $asigModelo->toggleActivo($editId, 0);
    $msg = isset($resultado['success']) ? 'desactivado' : 'error';
    header('Location: asignaciones_ingles.php?msg=' . $msg . '&detalle=' . urlencode($resultado['error'] ?? ''));
    exit;
}

if ($accion === 'activar' && $editId > 0) {
    $resultado = $asigModelo->toggleActivo($editId, 1);
    $msg = isset($resultado['success']) ? 'activado' : 'error';
    header('Location: asignaciones_ingles.php?msg=' . $msg . '&detalle=' . urlencode($resultado['error'] ?? ''));
    exit;
}

// Función para copiar aspectos según grado
function copiarAspectosIngles($db, $asignacionId, $seccion, $grado) {
    // Obtener aspectos plantilla del grado
    $stmt = $db->prepare("
        SELECT nombre, orden FROM asignacion_ingles_aspectos 
        WHERE seccion = ? AND grado = ? AND asignacion_id IS NULL
        ORDER BY orden ASC
    ");
    $stmt->bind_param('si', $seccion, $grado);
    $stmt->execute();
    $aspectos = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    
    if (empty($aspectos)) return;
    
    // Insertar aspectos para esta asignación
    $stmtDel = $db->prepare("DELETE FROM asignacion_ingles_aspectos WHERE asignacion_id = ?");
    $stmtDel->bind_param('i', $asignacionId);
    $stmtDel->execute();
    
    $stmtIns = $db->prepare("INSERT INTO asignacion_ingles_aspectos (asignacion_id, nombre, orden) VALUES (?, ?, ?)");
    foreach ($aspectos as $asp) {
        $stmtIns->bind_param('isi', $asignacionId, $asp['nombre'], $asp['orden']);
        $stmtIns->execute();
    }
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $resultado = $asigModelo->crearLote($_POST);
    
    // Si se creó una nueva asignación, copiar aspectos
    if (isset($resultado['success']) && isset($_POST['seccion']) && isset($_POST['grado'])) {
        $seccion = $_POST['seccion'];
        $grado = (int)$_POST['grado'];
        $grupo = $_POST['grupo'];
        
        // Obtener el ID de la asignación creada
        $stmt = $db->prepare("
            SELECT a.id FROM asignaciones a
            JOIN materias m ON m.id = a.materia_id
            WHERE m.es_ingles = 1 AND a.seccion = ? AND a.grado = ? AND a.grupo = ?
            ORDER BY a.id DESC LIMIT 1
        ");
        $stmt->bind_param('sis', $seccion, $grado, $grupo);
        $stmt->execute();
        $asig = $stmt->get_result()->fetch_assoc();
        if ($asig) {
            copiarAspectosIngles($db, $asig['id'], $seccion, $grado);
        }
    }
}

$msgRedir  = $_GET['msg']     ?? '';
$msgDetall = $_GET['detalle'] ?? '';

$cicloActivo = $cicloModelo->obtenerActivo();

// Obtener la materia Inglés
$stmtIngles = $db->prepare("SELECT id FROM materias WHERE es_ingles = 1 LIMIT 1");
$stmtIngles->execute();
$materiaIngles = $stmtIngles->get_result()->fetch_assoc();
$materiaInglesId = $materiaIngles ? $materiaIngles['id'] : 0;

// Solo la materia Inglés
$materiasForm = [];
if ($materiaInglesId) {
    $materiaInglesData = $materiaModelo->obtenerPorId($materiaInglesId);
    if ($materiaInglesData) {
        $materiasForm = [$materiaInglesData];
    }
}

$campos         = $campoModelo->listarActivos();
$subcomps       = $artesModelo->listarActivos();
$titulares      = $profModelo->listarActivosPorTipo('titular');
$frances        = $profModelo->listarActivosPorTipo('frances');
$cocurriculares = $profModelo->listarActivosPorTipo('cocurricular');

$todasAsignaciones = $cicloActivo
    ? $asigModelo->listarPorCicloAgrupado((int)$cicloActivo['id'])
    : [];

$asignaciones = [];
foreach ($todasAsignaciones as $key => $grupo) {
    $grupoFiltrado = [];
    foreach ($grupo as $asignacion) {
        if ((int)$asignacion['es_ingles'] === 1) {
            $grupoFiltrado[] = $asignacion;
        }
    }
    if (!empty($grupoFiltrado)) {
        $asignaciones[$key] = $grupoFiltrado;
    }
}

$pageTitle = 'Superadmin › Asignaciones - Inglés';
$backLink  = 'dashboard.php';
$scripts   = ['/proyecto/js/modal.js'];
include __DIR__ . '/../includes/header.php';
?>

<div class="modal-overlay" id="modalOverlay" role="dialog" aria-modal="true" aria-labelledby="modalTitle" hidden>
  <div class="modal">
    <h3 class="modal__title" id="modalTitle"></h3>
    <p class="modal__body" id="modalBody"></p>
    <div class="modal__actions">
      <a class="btn modal__confirm" id="modalConfirm" href="#">Confirmar</a>
      <button class="btn modal__cancel" id="modalCancel" type="button">Cancelar</button>
    </div>
  </div>
</div>

<main class="container">

  <?php if ($resultado): ?>
    <?php if (isset($resultado['success'])): ?>
      <p class="alert alert--success">
        ✅ <?= $resultado['creadas'] ?> asignación(es) creada(s).
        <?= ($resultado['omitidas'] ?? 0) > 0 ? ($resultado['omitidas'] ?? 0) . ' ya existían y se actualizaron.' : '' ?>
      </p>
    <?php else: ?>
      <p class="alert alert--error">⚠️ <?= htmlspecialchars($resultado['error']) ?></p>
    <?php endif; ?>
  <?php endif; ?>

  <?php if ($msgRedir === 'activado'): ?>
    <p class="alert alert--success">✅ Asignación activada.</p>
  <?php elseif ($msgRedir === 'desactivado'): ?>
    <p class="alert alert--success">✅ Asignación desactivada.</p>
  <?php elseif ($msgRedir === 'error'): ?>
    <p class="alert alert--error">⚠️ <?= htmlspecialchars($msgDetall) ?></p>
  <?php endif; ?>

  <?php if (!$cicloActivo): ?>
    <p class="alert alert--error">
      ⚠️ No hay un ciclo escolar activo.
      <a href="ciclos_escolares.php">Configura uno primero</a>.
    </p>
  <?php else: ?>

  <div class="asignaciones-layout">
    <div class="asignaciones-formulario">
      <section class="card">
        <h2 class="section-title">➕ Nueva asignación - Inglés</h2>
        <p class="form-hint" style="margin-bottom:1rem;">
          Ciclo: <strong><?= htmlspecialchars($cicloActivo['nombre']) ?></strong>
        </p>

        <form method="POST" id="form-asignacion" novalidate>
          <input type="hidden" name="ciclo_id" value="<?= $cicloActivo['id'] ?>">

          <div class="form-group">
            <label for="seccion">Sección *</label>
            <select id="seccion" name="seccion" required>
              <option value="">Selecciona…</option>
              <?php foreach (['maternal','preescolar','primaria','secundaria'] as $sec): ?>
                <option value="<?= $sec ?>"><?= ucfirst($sec) ?></option>
              <?php endforeach; ?>
            </select>
          </div>

          <div class="form-group">
            <label for="grado">Grado *</label>
            <select id="grado" name="grado" required>
              <option value="">Selecciona…</option>
              <?php for ($i = 1; $i <= 6; $i++): ?>
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
            <hr class="separator">
            <p class="form-hint" style="margin-bottom:.8rem;">
              Asigna un maestro para la materia de Inglés:
            </p>
            <div id="lista-materias"></div>
            <p class="form-hint" style="margin-top:.8rem;">
              <strong>Nota:</strong> Los aspectos (Listening, Speaking, etc.) se asignan automáticamente según el grado.
            </p>
          </div>

          <button class="btn" type="submit" id="btn-guardar" hidden>Guardar asignaciones</button>
        </form>
      </section>
    </div>

    <div class="asignaciones-listado">
      <section>
        <h2 class="section-title">
          Asignaciones — <?= htmlspecialchars($cicloActivo['nombre']) ?>
        </h2>

        <?php if (empty($asignaciones)): ?>
          <p class="empty-state">Aún no hay asignaciones de Inglés para este ciclo.</p>
        <?php else: ?>
          <?php foreach ($asignaciones as $key => $grupo): ?>
            <?php $primera = $grupo[0]; ?>
            <div class="grupo-asignaciones">
              <h3 class="grupo-titulo">
                📚 <?= ucfirst($primera['seccion']) ?> — <?= $primera['grado'] ?>° <?= $primera['grupo'] ?>
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
                      $urlActivar = 'asignaciones_ingles.php?accion=activar&id=' . $a['id'];
                      $urlDesact  = 'asignaciones_ingles.php?accion=desactivar&id=' . $a['id'];
                    ?>
                    <tr>
                      <td>
                        <strong><?= $nombreSafe ?></strong>
                        <span class="badge">Inglés</span>
                        <?php if ((int)($a['hay_titular'] ?? 0)): ?>
                          <span class="badge badge--active">Titular</span>
                        <?php endif; ?>
                      </td>
                      <td>
                        <?= $a['campo_formativo_nombre']
                            ? htmlspecialchars($a['campo_formativo_nombre'])
                            : '<span class="form-hint">—</span>'
                        ?>
                      </td>
                      <td class="maestros-cell">
                        <?= $a['maestros']
                            ? htmlspecialchars($a['maestros'])
                            : '<span class="form-hint">Sin asignar</span>'
                        ?>
                      </td>
                      <td class="estado-cell">
                        <?php if ($esActivo): ?>
                          <span class="badge badge--active">Activo</span>
                        <?php else: ?>
                          <span class="badge badge--warn">Inactivo</span>
                        <?php endif; ?>
                      </td>
                      <td class="acciones-cell">
                        <div class="table-actions">
                          <?php if ($esActivo): ?>
                            <button class="btn btn--sm btn--danger js-modal-trigger"
                                    data-href="<?= $urlDesact ?>"
                                    data-title="Desactivar asignación"
                                    data-body="¿Confirmas desactivar <?= $nombreSafe ?>?">
                              Desactivar
                            </button>
                          <?php else: ?>
                            <button class="btn btn--sm btn--success js-modal-trigger"
                                    data-href="<?= $urlActivar ?>"
                                    data-title="Activar asignación"
                                    data-body="¿Confirmas activar <?= $nombreSafe ?>?">
                              Activar
                            </button>
                          <?php endif; ?>
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
  </div>
  <?php endif; ?>
</main>

<style>
.asignaciones-layout {
  display: grid;
  grid-template-columns: 1fr 1.8fr;
  gap: 1.5rem;
  align-items: start;
}
.asignaciones-formulario, .asignaciones-listado { min-width: 0; }
.separator { margin: 1rem 0; border: none; border-top: 1px solid var(--color-border); }
.grupo-asignaciones { margin-bottom: 1.5rem; }
.grupo-titulo { font-size: 0.95rem; color: var(--color-primary); margin-bottom: 0.5rem; }
.estado-cell, .acciones-cell { text-align: center; }
.materia-bloque { border: 1px solid var(--color-border); border-radius: var(--radius-sm); padding: 0.8rem; margin-bottom: 0.8rem; background: var(--color-surface); }
.materia-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.8rem; padding-bottom: 0.5rem; border-bottom: 1px solid var(--color-border); font-weight: 600; color: var(--color-primary); }
.form-group { margin-bottom: 0.8rem; }
.form-group label { display: block; font-size: 0.75rem; color: var(--color-muted); margin-bottom: 0.3rem; }
.form-control { width: 100%; padding: 0.5rem 0.75rem; border: 1px solid #ccd3db; border-radius: var(--radius-sm); font-size: 0.85rem; background: var(--color-surface); }
.check-option { display: flex; align-items: center; gap: 0.5rem; margin-top: 0.5rem; }
.check-option input { width: 16px; height: 16px; cursor: pointer; accent-color: var(--color-primary); }
.check-option label { font-size: 0.8rem; color: var(--color-text); cursor: pointer; }
.table-actions { display: flex; gap: 0.4rem; flex-wrap: wrap; justify-content: center; }
@media (max-width: 700px) { .asignaciones-layout { grid-template-columns: 1fr; } }
</style>

<script>
const TITULARES = <?= json_encode($titulares) ?>;
const MATERIAS_INGLES = <?= json_encode($materiasForm) ?>;

function renderizarMaterias() {
    const seccion = document.getElementById('seccion').value;
    const grado = document.getElementById('grado').value;
    const grupo = document.getElementById('grupo').value;
    const wrap = document.getElementById('wrap-materias');
    const lista = document.getElementById('lista-materias');
    const btn = document.getElementById('btn-guardar');
    
    if (!seccion || !grado || !grupo) {
        if (wrap) wrap.hidden = true;
        if (btn) btn.hidden = true;
        if (lista) lista.innerHTML = '';
        return;
    }
    
    if (!lista) return;
    lista.innerHTML = '';
    
    if (MATERIAS_INGLES.length === 0) {
        lista.innerHTML = '<p class="alert alert--warn">No hay materia de Inglés registrada. Crea una materia con es_ingles=1 primero.</p>';
        if (wrap) wrap.hidden = false;
        if (btn) btn.hidden = false;
        return;
    }
    
    MATERIAS_INGLES.forEach(m => {
        const div = document.createElement('div');
        div.className = 'materia-bloque';
        
        div.innerHTML = `
            <div class="materia-header">
                <strong>${m.nombre}</strong>
                <span class="badge">Inglés</span>
            </div>
            <div class="form-group">
                <label class="form-hint">Maestro asignado</label>
                <select name="materia[${m.id}][profesor_id]" class="form-control">
                    <option value="">Seleccionar maestro...</option>
                    ${TITULARES.map(p => `<option value="${p.id}">${p.apellido_paterno} ${p.apellido_materno || ''}, ${p.nombre}</option>`).join('')}
                </select>
            </div>
            <div class="check-option">
                <input type="checkbox" name="materia[${m.id}][es_titular]" value="1" id="titular_${m.id}">
                <label for="titular_${m.id}">Es titular de este grupo</label>
            </div>
            <input type="hidden" name="materia[${m.id}][campo_formativo_id]" value="${m.campo_formativo_id || ''}">
            <input type="hidden" name="materia[${m.id}][orden]" value="0">
        `;
        
        lista.appendChild(div);
    });
    
    if (wrap) wrap.hidden = false;
    if (btn) btn.hidden = false;
}

const selSeccion = document.getElementById('seccion');
const selGrado = document.getElementById('grado');
const selGrupo = document.getElementById('grupo');

if (selSeccion) selSeccion.addEventListener('change', renderizarMaterias);
if (selGrado) selGrado.addEventListener('change', renderizarMaterias);
if (selGrupo) selGrupo.addEventListener('change', renderizarMaterias);
</script>

<?php include __DIR__ . '/../includes/footer.php'; ?>