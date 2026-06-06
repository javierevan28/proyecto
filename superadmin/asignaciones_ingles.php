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
    $stmt = $db->prepare("UPDATE asignaciones SET activo = 0 WHERE id = ?");
    $stmt->bind_param('i', $editId);
    $stmt->execute();
    header('Location: asignaciones_ingles.php?msg=desactivado');
    exit;
}

if ($accion === 'activar' && $editId > 0) {
    $stmt = $db->prepare("UPDATE asignaciones SET activo = 1 WHERE id = ?");
    $stmt->bind_param('i', $editId);
    $stmt->execute();
    header('Location: asignaciones_ingles.php?msg=activado');
    exit;
}

if ($accion === 'eliminar' && $editId > 0) {
    $db->query("DELETE FROM asignacion_maestros WHERE asignacion_id = $editId");
    $db->query("DELETE FROM asignacion_artes WHERE asignacion_id = $editId");
    $db->query("DELETE FROM asignacion_ingles_aspectos WHERE asignacion_id = $editId");
    $db->query("DELETE FROM asignaciones WHERE id = $editId");
    header('Location: asignaciones_ingles.php?msg=eliminado');
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $resultado = $asigModelo->crearLote($_POST);
}

$msgRedir  = $_GET['msg']     ?? '';
$msgDetall = $_GET['detalle'] ?? '';

$cicloActivo = $cicloModelo->obtenerActivo();

$seccionSeleccionada = $_GET['seccion'] ?? '';
$gradoSeleccionado   = $_GET['grado']   ?? '';
$grupoSeleccionado   = $_GET['grupo']   ?? '';

// ============================================================
// Materias de Inglés asignadas a este grado en grados_materias
// DISTINCT para evitar duplicados si hay datos sucios
// ============================================================
$materiasForm = [];
if ($seccionSeleccionada && $gradoSeleccionado) {
    $stmt = $db->prepare("
        SELECT DISTINCT m.id, m.nombre, m.campo_formativo_id,
               gm.campo_formativo_id AS campo_grado
        FROM grados_materias gm
        JOIN materias m ON m.id = gm.materia_id
        WHERE gm.seccion = ? AND gm.grado = ? AND m.es_ingles = 1 AND gm.activo = 1
        ORDER BY gm.orden ASC, m.nombre ASC
    ");
    $stmt->bind_param('si', $seccionSeleccionada, $gradoSeleccionado);
    $stmt->execute();
    $materiasForm = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
}

// ============================================================
// Si hay grupo seleccionado, obtener asignaciones YA EXISTENTES
// para ese ciclo/sección/grado/grupo — para mostrar checks
// ============================================================
$asignacionesExistentes = []; // materia_id => asignacion row
if ($cicloActivo && $seccionSeleccionada && $gradoSeleccionado && $grupoSeleccionado) {
    $stmt = $db->prepare("
        SELECT a.id AS asignacion_id, a.materia_id, a.campo_formativo_id, a.activo,
               GROUP_CONCAT(DISTINCT am.profesor_id) AS profesor_ids,
               MAX(am.es_titular) AS es_titular,
               p.id AS profesor_id_primero,
               p.nombre AS prof_nombre, p.apellido_paterno AS prof_ap
        FROM asignaciones a
        JOIN materias m ON m.id = a.materia_id
        LEFT JOIN asignacion_maestros am ON am.asignacion_id = a.id
        LEFT JOIN profesores p ON p.id = am.profesor_id
        WHERE a.ciclo_id = ? AND a.seccion = ? AND a.grado = ? AND a.grupo = ? AND m.es_ingles = 1
        GROUP BY a.id
    ");
    $stmt->bind_param('isis', $cicloActivo['id'], $seccionSeleccionada, $gradoSeleccionado, $grupoSeleccionado);
    $stmt->execute();
    $rows = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    foreach ($rows as $r) {
        $asignacionesExistentes[$r['materia_id']] = $r;
    }
}

$titulares = $profModelo->listarActivosPorTipo('titular');

// ============================================================
// LISTADO INFERIOR: solo mostrar asignaciones de Inglés cuya
// materia SÍ esté actualmente en grados_materias para ese grado
// ============================================================
$todasAsignaciones = $cicloActivo
    ? $asigModelo->listarPorCicloAgrupado((int)$cicloActivo['id'])
    : [];

$asignaciones = [];
foreach ($todasAsignaciones as $key => $grupoAsig) {
    $grupoFiltrado = [];
    foreach ($grupoAsig as $asignacion) {
        if ((int)$asignacion['es_ingles'] !== 1) continue;

        // Verificar que esta materia SÍ esté en grados_materias actualmente
        $stmtCheck = $db->prepare("
            SELECT id FROM grados_materias
            WHERE seccion = ? AND grado = ? AND materia_id = ? AND activo = 1
            LIMIT 1
        ");
        $stmtCheck->bind_param('sii', $asignacion['seccion'], $asignacion['grado'], $asignacion['materia_id']);
        $stmtCheck->execute();
        if ($stmtCheck->get_result()->num_rows === 0) continue;

        $grupoFiltrado[] = $asignacion;
    }
    if (!empty($grupoFiltrado)) {
        $asignaciones[$key] = $grupoFiltrado;
    }
}

$pageTitle = 'Superadmin › Asignaciones - Inglés';
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

  <?php if ($msgRedir === 'activado'): ?>
    <p class="alert alert--success">✅ Asignación activada.</p>
  <?php elseif ($msgRedir === 'desactivado'): ?>
    <p class="alert alert--success">✅ Asignación desactivada.</p>
  <?php elseif ($msgRedir === 'eliminado'): ?>
    <p class="alert alert--success">✅ Asignación eliminada correctamente.</p>
  <?php elseif ($msgRedir === 'error'): ?>
    <p class="alert alert--error">⚠️ <?= htmlspecialchars($msgDetall) ?></p>
  <?php endif; ?>

  <?php if ($resultado): ?>
    <?php if (isset($resultado['error'])): ?>
      <p class="alert alert--error">⚠️ <?= htmlspecialchars($resultado['error']) ?></p>
    <?php else: ?>
      <p class="alert alert--success">
        ✅ <?= $resultado['creadas'] ?> creada(s),
           <?= $resultado['actualizadas'] ?> actualizada(s)
        <?php if (!empty($resultado['eliminadas']) && $resultado['eliminadas'] > 0): ?>
          , <?= $resultado['eliminadas'] ?> eliminada(s)
        <?php endif; ?>.
      </p>
    <?php endif; ?>
  <?php endif; ?>

  <?php if (!$cicloActivo): ?>
    <p class="alert alert--error">
      ⚠️ No hay un ciclo escolar activo.
      <a href="ciclos_escolares.php">Configura uno primero</a>.
    </p>
  <?php else: ?>

  <div style="display:grid; grid-template-columns:1fr 1.8fr; gap:1.5rem; align-items:start;">

    <!-- ============================================================
         FORMULARIO IZQUIERDO
    ============================================================ -->
    <div class="card">
      <h2 class="section-title">➕ Asignaciones - Inglés</h2>
      <p class="form-hint" style="margin-bottom:1rem;">
        Ciclo: <strong><?= htmlspecialchars($cicloActivo['nombre']) ?></strong>
      </p>

      <!-- Filtros de sección/grado/grupo -->
      <form method="GET" id="form-filtros" style="margin-bottom: 1rem;">
        <div class="form-group">
          <label for="seccion">Sección *</label>
          <select id="seccion" name="seccion" required onchange="this.form.submit()">
            <option value="">Selecciona…</option>
            <?php foreach (['maternal','preescolar','primaria','secundaria'] as $sec): ?>
              <option value="<?= $sec ?>" <?= $seccionSeleccionada === $sec ? 'selected' : '' ?>><?= ucfirst($sec) ?></option>
            <?php endforeach; ?>
          </select>
        </div>

        <div class="form-group">
          <label for="grado">Grado *</label>
          <select id="grado" name="grado" required onchange="this.form.submit()">
            <option value="">Selecciona…</option>
            <?php for ($i = 1; $i <= 6; $i++): ?>
              <option value="<?= $i ?>" <?= $gradoSeleccionado == $i ? 'selected' : '' ?>><?= $i ?>°</option>
            <?php endfor; ?>
          </select>
        </div>

        <div class="form-group">
          <label for="grupo">Grupo *</label>
          <select id="grupo" name="grupo" required onchange="this.form.submit()">
            <option value="">Selecciona…</option>
            <?php foreach (['A','B','C','D'] as $grp): ?>
              <option value="<?= $grp ?>" <?= $grupoSeleccionado === $grp ? 'selected' : '' ?>><?= $grp ?></option>
            <?php endforeach; ?>
          </select>
        </div>
      </form>

      <?php if ($seccionSeleccionada && $gradoSeleccionado && $grupoSeleccionado): ?>

        <?php if (empty($materiasForm)): ?>
          <p class="alert alert--warn">
            ⚠️ No hay materias de Inglés asignadas a <?= ucfirst($seccionSeleccionada) ?> <?= $gradoSeleccionado ?>°.
            <br><a href="grados_materias.php?seccion=<?= $seccionSeleccionada ?>&grado=<?= $gradoSeleccionado ?>&tab=ingles">
              Ir a Materias por grado →
            </a>
          </p>
        <?php else: ?>

          <form method="POST" id="form-asignacion" novalidate>
            <input type="hidden" name="ciclo_id"  value="<?= $cicloActivo['id'] ?>">
            <input type="hidden" name="seccion"   value="<?= $seccionSeleccionada ?>">
            <input type="hidden" name="grado"     value="<?= $gradoSeleccionado ?>">
            <input type="hidden" name="grupo"     value="<?= $grupoSeleccionado ?>">
            <?php foreach ($materiasForm as $mDisp): ?>
              <input type="hidden" name="materias_disponibles[]" value="<?= $mDisp['id'] ?>">
            <?php endforeach; ?>

            <hr class="separator">
            <p class="form-hint" style="margin-bottom:.8rem;">
              Marca las materias a asignar al grupo <strong><?= $grupoSeleccionado ?></strong> y selecciona el maestro:
            </p>

            <?php foreach ($materiasForm as $m):
                $yaAsignada = isset($asignacionesExistentes[$m['id']]);
                $asigRow    = $yaAsignada ? $asignacionesExistentes[$m['id']] : null;
                $profIdActual = $asigRow['profesor_id_primero'] ?? 0;
                $esTitularActual = $asigRow['es_titular'] ?? 0;
                // Nombre a mostrar: "1° - Grammar" etc
                $gradoTexto = ($seccionSeleccionada === 'secundaria')
                    ? $gradoSeleccionado . ' Sec'
                    : $gradoSeleccionado . '°';
                $nombreMostrar = $gradoTexto . ' - ' . $m['nombre'];
            ?>
              <div class="materia-bloque <?= $yaAsignada ? 'materia-bloque--asignada' : '' ?>">
                <div class="materia-header">
                  <div style="display:flex; align-items:center; gap:.6rem;">
                    <input type="checkbox"
                           name="materias_check[]"
                           value="<?= $m['id'] ?>"
                           id="chk_<?= $m['id'] ?>"
                           class="materia-check"
                           data-id="<?= $m['id'] ?>"
                           <?= $yaAsignada ? 'checked' : '' ?>>
                    <label for="chk_<?= $m['id'] ?>" style="cursor:pointer; font-weight:600; color:var(--color-primary);">
                      <?= htmlspecialchars($nombreMostrar) ?>
                    </label>
                  </div>
                  <span class="badge">Inglés</span>
                  <?php if ($yaAsignada): ?>
                    <span class="badge badge--active" style="font-size:.65rem;">✓ Asignada</span>
                  <?php endif; ?>
                </div>

                <div class="materia-campos" id="campos_<?= $m['id'] ?>">
                  <div class="form-group" style="margin-top:.6rem; margin-bottom:.4rem;">
                    <label class="form-hint">Maestro asignado</label>
                    <select name="materia[<?= $m['id'] ?>][profesor_id]" class="form-control">
                      <option value="">Sin maestro…</option>
                      <?php foreach ($titulares as $p): ?>
                        <option value="<?= $p['id'] ?>"
                          <?= ($profIdActual == $p['id']) ? 'selected' : '' ?>>
                          <?= htmlspecialchars($p['apellido_paterno'] . ' ' . ($p['apellido_materno'] ?? '') . ', ' . $p['nombre']) ?>
                        </option>
                      <?php endforeach; ?>
                    </select>
                  </div>

                  <div class="check-option">
                    <input type="checkbox"
                           name="materia[<?= $m['id'] ?>][es_titular]"
                           value="1"
                           id="titular_<?= $m['id'] ?>"
                           <?= $esTitularActual ? 'checked' : '' ?>>
                    <label for="titular_<?= $m['id'] ?>">Es titular de este grupo</label>
                  </div>

                  <input type="hidden" name="materia[<?= $m['id'] ?>][campo_formativo_id]" value="<?= $m['campo_grado'] ?? $m['campo_formativo_id'] ?? '' ?>">
                  <input type="hidden" name="materia[<?= $m['id'] ?>][orden]" value="0">
                </div>
              </div>
            <?php endforeach; ?>

            <button class="btn" type="submit" style="margin-top:1rem;">💾 Guardar asignaciones</button>
          </form>

        <?php endif; ?>
      <?php endif; ?>
    </div>

    <!-- ============================================================
         LISTADO DERECHO — solo materias que tienen check en grados_materias
    ============================================================ -->
    <div>
      <h2 class="section-title">
        Asignaciones Inglés — <?= htmlspecialchars($cicloActivo['nombre']) ?>
      </h2>

      <?php if (empty($asignaciones)): ?>
        <p class="empty-state">No hay asignaciones de Inglés para este ciclo.</p>
      <?php else: ?>
        <?php foreach ($asignaciones as $key => $grupoAsig): ?>
          <?php $primera = $grupoAsig[0]; ?>
          <div style="margin-bottom:1.5rem;">
            <h3 style="font-size:.95rem; color:var(--color-primary); margin-bottom:.5rem;">
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
                <?php foreach ($grupoAsig as $a):
                  $esActivo   = (int)$a['activo'] === 1;
                  $gradoTexto = ($a['seccion'] === 'secundaria')
                      ? $a['grado'] . ' Sec'
                      : $a['grado'] . '°';
                  $nombreMostrar = $gradoTexto . ' - ' . $a['materia_nombre'];
                  $nombreSafe    = htmlspecialchars($nombreMostrar);
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
                    <td style="font-size:.8rem;">
                      <?= $a['maestros']
                          ? htmlspecialchars($a['maestros'])
                          : '<span class="form-hint">Sin asignar</span>'
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
                        <a href="javascript:void(0)"
                           class="btn btn--sm <?= $esActivo ? 'btn--warning' : 'btn--success' ?> action-btn"
                           data-url="asignaciones_ingles.php?accion=<?= $esActivo ? 'desactivar' : 'activar' ?>&id=<?= $a['id'] ?>"
                           data-title="<?= $esActivo ? 'Desactivar' : 'Activar' ?>"
                           data-body="<?= $esActivo ? '¿Desactivar ' . $nombreSafe . '?' : '¿Activar ' . $nombreSafe . '?' ?>">
                          <?= $esActivo ? 'Desactivar' : 'Activar' ?>
                        </a>
                        <a href="javascript:void(0)"
                           class="btn btn--sm btn--danger action-btn"
                           data-url="asignaciones_ingles.php?accion=eliminar&id=<?= $a['id'] ?>"
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
    </div>

  </div>
  <?php endif; ?>
</main>

<script>
document.addEventListener('DOMContentLoaded', function () {

    // Modal de confirmación
    const modal       = document.getElementById('confirmModal');
    const modalTitle  = document.getElementById('modalTitle');
    const modalBody   = document.getElementById('modalBody');
    const modalConfirm = document.getElementById('modalConfirm');
    const modalCancel  = document.getElementById('modalCancel');

    document.querySelectorAll('.action-btn').forEach(btn => {
        btn.addEventListener('click', function (e) {
            e.preventDefault();
            modalTitle.textContent   = this.dataset.title;
            modalBody.textContent    = this.dataset.body;
            modalConfirm.href        = this.dataset.url;
            modal.style.display = 'flex';
        });
    });

    modalCancel.addEventListener('click', () => modal.style.display = 'none');
    modal.addEventListener('click', e => { if (e.target === modal) modal.style.display = 'none'; });

    // Cuando se desmarca un checkbox, ocultar los campos de ese bloque
    // (la materia no se enviará en materia[] porque solo se envía si está marcada)
    document.querySelectorAll('.materia-check').forEach(chk => {
        const campos = document.getElementById('campos_' + chk.dataset.id);
        if (!campos) return;

        // Estado inicial
        campos.style.display = chk.checked ? 'block' : 'none';

        chk.addEventListener('change', function () {
            campos.style.display = this.checked ? 'block' : 'none';
            // Si se desmarca, limpiar el select de profesor para no enviarlo
            if (!this.checked) {
                const sel = campos.querySelector('select');
                if (sel) sel.value = '';
                const titCheck = campos.querySelector('input[type="checkbox"]');
                if (titCheck) titCheck.checked = false;
            }
        });
    });

    // El form solo debe enviar en materia[] las que están marcadas
    const formAsig = document.getElementById('form-asignacion');
    if (formAsig) {
        formAsig.addEventListener('submit', function (e) {
            // Desactivar los selects/inputs de bloques NO marcados
            // para que no se envíen en el POST
            document.querySelectorAll('.materia-check').forEach(chk => {
                if (!chk.checked) {
                    const campos = document.getElementById('campos_' + chk.dataset.id);
                    if (campos) {
                        campos.querySelectorAll('input, select').forEach(el => el.disabled = true);
                    }
                }
            });
        });
    }
});
</script>

<style>
.form-group { margin-bottom: 1rem; }
.form-group label { display: block; font-size: 0.75rem; margin-bottom: 0.3rem; color: #666; }
.form-control { width: 100%; padding: 0.5rem; border: 1px solid #ccc; border-radius: 4px; }
.materia-bloque {
    border: 1px solid var(--color-border);
    border-radius: var(--radius-sm);
    padding: 0.8rem;
    margin-bottom: 0.8rem;
    background: var(--color-surface);
    transition: border-color .15s;
}
.materia-bloque--asignada {
    border-color: #10b981;
    background: #f0fdf4;
}
.materia-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: .4rem;
    padding-bottom: 0.3rem;
}
.check-option { display: flex; align-items: center; gap: 0.5rem; margin-top: 0.5rem; }
.check-option input { width: 16px; height: 16px; cursor: pointer; accent-color: var(--color-primary); }
.check-option label { font-size: 0.8rem; color: var(--color-text); cursor: pointer; }
.table-actions { display: flex; gap: 0.4rem; flex-wrap: wrap; justify-content: center; }
.btn--warning { background: #f59e0b; color: white; }
.btn--warning:hover { background: #d97706; }
.separator { margin: 1rem 0; border: none; border-top: 1px solid var(--color-border); }
.badge--active { background: #10b981; color: white; }
.badge--warn { background: #f59e0b; color: white; }
</style>

<?php include __DIR__ . '/../includes/footer.php'; ?>