<?php
// superadmin/asignaciones.php
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
    header('Location: asignaciones.php?msg=' . $msg . '&detalle=' . urlencode($resultado['error'] ?? ''));
    exit;
}

if ($accion === 'activar' && $editId > 0) {
    $resultado = $asigModelo->toggleActivo($editId, 1);
    $msg = isset($resultado['success']) ? 'activado' : 'error';
    header('Location: asignaciones.php?msg=' . $msg . '&detalle=' . urlencode($resultado['error'] ?? ''));
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $resultado = $asigModelo->crearLote($_POST);
}

$msgRedir  = $_GET['msg']     ?? '';
$msgDetall = $_GET['detalle'] ?? '';

$cicloActivo    = $cicloModelo->obtenerActivo();
$materias       = $materiaModelo->listarActivas();
$campos         = $campoModelo->listarActivos();
$subcomps       = $artesModelo->listarActivos();
$titulares      = $profModelo->listarActivosPorTipo('titular');
$frances        = $profModelo->listarActivosPorTipo('frances');
$cocurriculares = $profModelo->listarActivosPorTipo('cocurricular');

$asignaciones = $cicloActivo
    ? $asigModelo->listarPorCicloAgrupado((int)$cicloActivo['id'])
    : [];

$jsonMaterias       = json_encode($materias);
$jsonCampos         = json_encode($campos);
$jsonSubcomps       = json_encode($subcomps);
$jsonTitulares      = json_encode($titulares);
$jsonFrances        = json_encode($frances);
$jsonCocurriculares = json_encode($cocurriculares);

$pageTitle = 'Superadmin › Asignaciones';
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
      <p class="alert alert--success" role="status">
        ✅ <?= $resultado['creadas'] ?> asignación(es) creada(s).
        <?= ($resultado['omitidas'] ?? 0) > 0 ? ($resultado['omitidas'] ?? 0) . ' ya existían y se actualizaron.' : '' ?>
      </p>
    <?php else: ?>
      <p class="alert alert--error" role="alert">⚠️ <?= htmlspecialchars($resultado['error']) ?></p>
    <?php endif; ?>
  <?php endif; ?>

  <?php if ($msgRedir === 'activado'): ?>
    <p class="alert alert--success" role="status">✅ Asignación activada.</p>
  <?php elseif ($msgRedir === 'desactivado'): ?>
    <p class="alert alert--success" role="status">✅ Asignación desactivada.</p>
  <?php elseif ($msgRedir === 'error'): ?>
    <p class="alert alert--error" role="alert">⚠️ <?= htmlspecialchars($msgDetall) ?></p>
  <?php endif; ?>

  <?php if (!$cicloActivo): ?>
    <p class="alert alert--error" role="alert">
      ⚠️ No hay un ciclo escolar activo.
      <a href="ciclos_escolares.php">Configura uno primero</a>.
    </p>
  <?php else: ?>

  <div class="asignaciones-layout">
    <div class="asignaciones-formulario">
      <section class="card">
        <h2 class="section-title">➕ Nueva asignación</h2>
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
              Selecciona las materias y asigna uno o varios maestros a cada una:
            </p>
            <div id="lista-materias"></div>
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
          <p class="empty-state">Aún no hay asignaciones para este ciclo.</p>
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
                      $urlActivar = 'asignaciones.php?accion=activar&id='    . $a['id'];
                      $urlDesact  = 'asignaciones.php?accion=desactivar&id=' . $a['id'];
                    ?>
                    <tr>
                      <td>
                        <strong><?= $nombreSafe ?></strong>
                        <?php if ((int)$a['es_ingles']): ?>
                          <span class="badge">Inglés</span>
                        <?php elseif ((int)$a['es_artes']): ?>
                          <span class="badge">Artes</span>
                        <?php elseif ((int)$a['es_higiene']): ?>
                          <span class="badge badge--warn">Higiene</span>
                        <?php endif; ?>
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
                      <td>
                        <?php if ((int)($a['total_maestros'] ?? 0) > 0): ?>
                          <?= htmlspecialchars($a['maestros']) ?>
                        <?php else: ?>
                          <span class="form-hint">Sin asignar</span>
                        <?php endif; ?>
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
                                    type="button"
                                    data-href="<?= $urlDesact ?>"
                                    data-title="Desactivar asignación"
                                    data-body="¿Confirmas desactivar &quot;<?= $nombreSafe ?>&quot;?">
                              Desactivar
                            </button>
                          <?php else: ?>
                            <button class="btn btn--sm btn--success js-modal-trigger"
                                    type="button"
                                    data-href="<?= $urlActivar ?>"
                                    data-title="Activar asignación"
                                    data-body="¿Confirmas activar &quot;<?= $nombreSafe ?>&quot;?">
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

.asignaciones-formulario {
  min-width: 0;
}

.asignaciones-listado {
  min-width: 0;
}

.separator {
  margin: 1rem 0;
  border: none;
  border-top: 1px solid var(--color-border);
}

.grupo-asignaciones {
  margin-bottom: 1.5rem;
}

.grupo-titulo {
  font-size: 0.95rem;
  color: var(--color-primary);
  margin-bottom: 0.5rem;
}

.estado-cell {
  text-align: center;
}

.acciones-cell {
  text-align: center;
}

.maestro-row {
  display: flex;
  gap: 0.5rem;
  align-items: center;
  margin-bottom: 0.5rem;
  padding: 0.5rem;
  background: #f8fafc;
  border-radius: var(--radius-sm);
  border: 1px solid var(--color-border);
}

.maestro-row select {
  flex: 2;
  padding: 0.4rem;
  border: 1px solid #ccd3db;
  border-radius: 4px;
  font-size: 0.85rem;
  font-family: var(--font);
  background: var(--color-surface);
}

.maestro-row .checkbox-titular {
  display: flex;
  align-items: center;
  gap: 0.3rem;
  font-size: 0.75rem;
  white-space: nowrap;
  color: var(--color-muted);
  cursor: pointer;
}

.maestro-row .checkbox-titular input {
  width: 16px;
  height: 16px;
  margin: 0;
  cursor: pointer;
  accent-color: var(--color-primary);
}

.btn-add-maestro {
  margin-top: 0.5rem;
  width: 100%;
  background: var(--color-accent);
  color: white;
  border: none;
  border-radius: var(--radius-sm);
  padding: 0.5rem;
  font-size: 0.8rem;
  cursor: pointer;
  transition: background 0.15s;
}

.btn-add-maestro:hover {
  background: #2563eb;
}

.materia-bloque {
  border: 1px solid var(--color-border);
  border-radius: var(--radius-sm);
  padding: 0.8rem;
  margin-bottom: 0.8rem;
  background: var(--color-surface);
  transition: box-shadow 0.15s;
}

.materia-bloque:hover {
  box-shadow: var(--shadow);
}

.materia-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.8rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid var(--color-border);
}

.badge-titular {
  background: #d1fae5;
  color: #065f46;
}

@media (max-width: 700px) {
  .asignaciones-layout {
    grid-template-columns: 1fr;
  }
  
  .maestro-row {
    flex-wrap: wrap;
  }
  
  .maestro-row select {
    flex: 1 1 100%;
    margin-bottom: 0.3rem;
  }
  
  .maestro-row .checkbox-titular {
    flex: 1;
  }
  
  .btn-add-maestro {
    width: 100%;
  }
}
</style>

<script>
const MATERIAS       = <?= $jsonMaterias ?>;
const CAMPOS         = <?= $jsonCampos ?>;
const SUBCOMPS       = <?= $jsonSubcomps ?>;
const TITULARES      = <?= $jsonTitulares ?>;
const FRANCES        = <?= $jsonFrances ?>;
const COCURRICULARES = <?= $jsonCocurriculares ?>;

function getProfesoresPorMateria(materia) {
    const esIngles = parseInt(materia.es_ingles);
    const esArtes = parseInt(materia.es_artes);
    const esHigiene = parseInt(materia.es_higiene);
    const nombre = materia.nombre.toLowerCase();
    
    if (esArtes || esHigiene) {
        return COCURRICULARES;
    } else if (esIngles) {
        return TITULARES;
    } else if (nombre.includes('franc')) {
        return FRANCES;
    } else {
        return TITULARES;
    }
}

function agregarFilaMaestro(container, materiaId, profesores, profesorId = '', esTitular = false) {
    const row = document.createElement('div');
    row.className = 'maestro-row';
    
    const select = document.createElement('select');
    select.name = `materia[${materiaId}][maestros][][profesor_id]`;
    select.required = true;
    
    let options = '<option value="">Seleccionar maestro...</option>';
    profesores.forEach(p => {
        options += `<option value="${p.id}" ${profesorId == p.id ? 'selected' : ''}>
            ${p.apellido_paterno} ${p.apellido_materno || ''}, ${p.nombre}
        </option>`;
    });
    select.innerHTML = options;
    row.appendChild(select);
    
    const labelTitular = document.createElement('label');
    labelTitular.className = 'checkbox-titular';
    const chkTitular = document.createElement('input');
    chkTitular.type = 'checkbox';
    chkTitular.name = `materia[${materiaId}][maestros][][es_titular]`;
    chkTitular.value = '1';
    chkTitular.checked = esTitular;
    labelTitular.appendChild(chkTitular);
    labelTitular.appendChild(document.createTextNode('Titular'));
    row.appendChild(labelTitular);
    
    const btnRemove = document.createElement('button');
    btnRemove.type = 'button';
    btnRemove.textContent = '✕ Eliminar';
    btnRemove.className = 'btn btn--sm btn--danger';
    btnRemove.style.marginTop = '0';
    btnRemove.onclick = () => row.remove();
    row.appendChild(btnRemove);
    
    container.appendChild(row);
}

function crearBloqueMateria(materia, profesores) {
    const div = document.createElement('div');
    div.className = 'materia-bloque';
    div.setAttribute('data-materia-id', materia.id);
    
    const esIngles = parseInt(materia.es_ingles) === 1;
    const esArtes = parseInt(materia.es_artes) === 1;
    const esHigiene = parseInt(materia.es_higiene) === 1;
    
    const header = document.createElement('div');
    header.className = 'materia-header';
    header.innerHTML = `
        <strong style="font-size:.9rem; color:var(--color-primary);">${materia.nombre}</strong>
        <span>
            ${esIngles ? '<span class="badge">Inglés</span>' : ''}
            ${esArtes ? '<span class="badge">Artes</span>' : ''}
            ${esHigiene ? '<span class="badge badge--warn">Higiene</span>' : ''}
        </span>
    `;
    div.appendChild(header);
    
    const fieldsDiv = document.createElement('div');
    fieldsDiv.className = 'form-grid';
    fieldsDiv.style.marginBottom = '0.8rem';
    
    let campoOptions = '<option value="">Sin campo formativo</option>';
    CAMPOS.forEach(cf => {
        const selected = parseInt(materia.campo_formativo_id) === parseInt(cf.id) ? 'selected' : '';
        campoOptions += `<option value="${cf.id}" ${selected}>${cf.nombre}</option>`;
    });
    
    fieldsDiv.innerHTML = `
        <div class="form-group">
            <label class="form-hint">Campo formativo</label>
            <select name="materia[${materia.id}][campo_formativo_id]" class="form-control">
                ${campoOptions}
            </select>
        </div>
        <div class="form-group">
            <label class="form-hint">Orden en boleta</label>
            <input type="number" name="materia[${materia.id}][orden]" value="0" min="0" class="form-control">
        </div>
    `;
    div.appendChild(fieldsDiv);
    
    if (esArtes) {
        const subcompDiv = document.createElement('div');
        subcompDiv.className = 'form-group';
        subcompDiv.style.marginBottom = '0.8rem';
        let subcompOptions = '<option value="">Selecciona subcomponente…</option>';
        SUBCOMPS.forEach(s => {
            subcompOptions += `<option value="${s.id}">${s.nombre}</option>`;
        });
        subcompDiv.innerHTML = `
            <label class="form-hint">Subcomponente *</label>
            <select name="materia[${materia.id}][subcomponente_id]" class="form-control">
                ${subcompOptions}
            </select>
        `;
        div.appendChild(subcompDiv);
    }
    
    if (esIngles) {
        const aspectosDiv = document.createElement('div');
        aspectosDiv.className = 'form-group';
        aspectosDiv.style.marginBottom = '0.8rem';
        aspectosDiv.innerHTML = `
            <label class="form-hint">Aspectos de Inglés</label>
            <div class="aspectos-lista-${materia.id}"></div>
            <button type="button" class="btn btn--sm btn--accent btn-add-aspecto" data-materia="${materia.id}">
                + Agregar aspecto
            </button>
        `;
        div.appendChild(aspectosDiv);
    }
    
    const maestrosDiv = document.createElement('div');
    maestrosDiv.style.marginTop = '0.8rem';
    maestrosDiv.style.borderTop = '1px solid var(--color-border)';
    maestrosDiv.style.paddingTop = '0.8rem';
    maestrosDiv.innerHTML = `
        <label class="form-hint" style="font-weight:600;">Maestros asignados</label>
        <div class="maestros-lista-${materia.id}"></div>
        <button type="button" class="btn-add-maestro" data-materia="${materia.id}">
            + Agregar otro maestro
        </button>
    `;
    div.appendChild(maestrosDiv);
    
    const maestrosLista = div.querySelector(`.maestros-lista-${materia.id}`);
    agregarFilaMaestro(maestrosLista, materia.id, profesores);
    
    const btnAddMaestro = div.querySelector('.btn-add-maestro');
    btnAddMaestro.addEventListener('click', () => {
        agregarFilaMaestro(maestrosLista, materia.id, profesores);
    });
    
    if (esIngles) {
        const btnAddAspecto = div.querySelector('.btn-add-aspecto');
        const listaAsp = div.querySelector(`.aspectos-lista-${materia.id}`);
        btnAddAspecto.addEventListener('click', () => {
            const row = document.createElement('div');
            row.className = 'maestro-row';
            row.style.marginBottom = '0.3rem';
            row.innerHTML = `
                <input type="text" name="materia[${materia.id}][aspectos][]" placeholder="ej. Listening" maxlength="100" style="flex:1; padding:.35rem .5rem; border:1px solid #ccd3db; border-radius:4px;">
                <button type="button" class="btn btn--sm btn--danger" style="margin-top:0;">✕</button>
            `;
            row.querySelector('button').addEventListener('click', () => row.remove());
            listaAsp.appendChild(row);
        });
    }
    
    return div;
}

document.addEventListener('DOMContentLoaded', function() {
    const selSeccion = document.getElementById('seccion');
    const selGrado = document.getElementById('grado');
    const selGrupo = document.getElementById('grupo');
    const wrapMaterias = document.getElementById('wrap-materias');
    const listaMaterias = document.getElementById('lista-materias');
    const btnGuardar = document.getElementById('btn-guardar');
    
    if (!selSeccion) return;
    
    function renderizarMaterias() {
        const seccion = selSeccion.value;
        const grado = selGrado.value;
        const grupo = selGrupo.value;
        
        if (!seccion || !grado || !grupo) {
            wrapMaterias.hidden = true;
            btnGuardar.hidden = true;
            listaMaterias.innerHTML = '';
            return;
        }
        
        const materiasFiltradas = MATERIAS.filter(m => {
            if (parseInt(m.es_higiene) && seccion !== 'secundaria') return false;
            return true;
        });
        
        listaMaterias.innerHTML = '';
        
        materiasFiltradas.forEach(materia => {
            const profesores = getProfesoresPorMateria(materia);
            const bloque = crearBloqueMateria(materia, profesores);
            listaMaterias.appendChild(bloque);
        });
        
        wrapMaterias.hidden = false;
        btnGuardar.hidden = false;
    }
    
    selSeccion.addEventListener('change', renderizarMaterias);
    selGrado.addEventListener('change', renderizarMaterias);
    selGrupo.addEventListener('change', renderizarMaterias);
});
</script>

<?php include __DIR__ . '/../includes/footer.php'; ?>