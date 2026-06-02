<?php
// padre/documentos.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/UserModel.php';
require_once __DIR__ . '/../models/PadreModel.php';
require_once __DIR__ . '/../models/AlumnoModel.php';
require_once __DIR__ . '/../models/DocumentoModel.php';
requireRol([2]);

$db = getConexion();
$userModel = new UserModel($db);
$padreModel = new PadreModel($db, $userModel);
$alumnoModel = new AlumnoModel($db, $userModel);
$documentoModel = new DocumentoModel($db);

$padre = $padreModel->obtenerPorUserId((int)$_SESSION['user_id']);
if (!$padre) {
    header('Location: /proyecto/login.php');
    exit;
}

$alumnoId = (int)($_GET['alumno_id'] ?? 0);
$hijos = $alumnoModel->obtenerPorPadreId((int)$padre['id']);

// Verificar que el alumno es hijo del padre
$alumnoValido = false;
foreach ($hijos as $h) {
    if ((int)$h['id'] === $alumnoId) {
        $alumnoValido = true;
        break;
    }
}

if (!$alumnoValido) {
    header('Location: mis_hijos.php');
    exit;
}

$tiposDocumentos = $documentoModel->getTiposDocumentos();
$documentosSubidos = $documentoModel->getDocumentosPorAlumno($alumnoId);
$documentosPorTipo = [];
foreach ($documentosSubidos as $doc) {
    $documentosPorTipo[$doc['tipo_documento']] = $doc;
}

$mensaje = null;
$error = null;

// Procesar subida
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_FILES['documento'])) {
    $tipo = $_POST['tipo_documento'] ?? '';
    $observaciones = $_POST['observaciones'] ?? '';
    
    $resultado = $documentoModel->subirDocumento(
        $alumnoId,
        $tipo,
        $_FILES['documento'],
        (int)$_SESSION['user_id'],
        $observaciones
    );
    
    if (isset($resultado['success'])) {
        $mensaje = $resultado['mensaje'];
        // Recargar documentos
        $documentosSubidos = $documentoModel->getDocumentosPorAlumno($alumnoId);
        $documentosPorTipo = [];
        foreach ($documentosSubidos as $doc) {
            $documentosPorTipo[$doc['tipo_documento']] = $doc;
        }
    } else {
        $error = $resultado['error'];
    }
}

// Procesar eliminación
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['eliminar_documento'])) {
    $documentoId = (int)$_POST['documento_id'];
    $resultado = $documentoModel->eliminarDocumento($documentoId, $alumnoId);
    if (isset($resultado['success'])) {
        $mensaje = 'Documento eliminado correctamente';
        $documentosSubidos = $documentoModel->getDocumentosPorAlumno($alumnoId);
        $documentosPorTipo = [];
        foreach ($documentosSubidos as $doc) {
            $documentosPorTipo[$doc['tipo_documento']] = $doc;
        }
    } else {
        $error = $resultado['error'];
    }
}

// Obtener datos del alumno
$stmtAlumno = $db->prepare("SELECT nombre, apellido_paterno, apellido_materno, grado, grupo, seccion, matricula FROM alumnos WHERE id = ?");
$stmtAlumno->bind_param('i', $alumnoId);
$stmtAlumno->execute();
$alumno = $stmtAlumno->get_result()->fetch_assoc();

$pageTitle = 'Documentos - ' . htmlspecialchars($alumno['nombre'] . ' ' . $alumno['apellido_paterno']);
$backLink = 'mis_hijos.php';
$backLabel = '← Mis hijos';
include __DIR__ . '/../includes/header.php';
?>

<main class="container">
    <div class="card">
        <h2 class="section-title">📄 Documentos del alumno</h2>
        <p class="form-hint">
            Alumno: <strong><?= htmlspecialchars($alumno['nombre'] . ' ' . $alumno['apellido_paterno'] . ' ' . ($alumno['apellido_materno'] ?? '')) ?></strong><br>
            Matrícula: <?= htmlspecialchars($alumno['matricula'] ?? '—') ?> | <?= ucfirst($alumno['seccion']) ?> — <?= $alumno['grado'] ?>° <?= $alumno['grupo'] ?>
        </p>
        
        <?php if ($mensaje): ?>
            <p class="alert alert--success">✅ <?= htmlspecialchars($mensaje) ?></p>
        <?php endif; ?>
        <?php if ($error): ?>
            <p class="alert alert--error">⚠️ <?= htmlspecialchars($error) ?></p>
        <?php endif; ?>
        
        <!-- Tabla de documentos -->
        <div style="overflow-x: auto; margin-bottom: 2rem;">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Documento</th>
                        <th>Estado</th>
                        <th>Archivo</th>
                        <th>Fecha de subida</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($tiposDocumentos as $tipo => $nombre): ?>
                        <?php $doc = $documentosPorTipo[$tipo] ?? null; ?>
                        <tr>
                            <td><strong><?= htmlspecialchars($nombre) ?></strong></td>
                            <td>
                                <?php if ($doc): ?>
                                    <span class="badge badge--active">✅ Subido</span>
                                <?php else: ?>
                                    <span class="badge badge--warn">⚠️ Pendiente</span>
                                <?php endif; ?>
                            </td>
                            <td>
                                <?= $doc ? htmlspecialchars($doc['nombre_archivo']) : '—' ?>
                            </td>
                            <td>
                                <?= $doc ? date('d/m/Y H:i', strtotime($doc['fecha_subida'])) : '—' ?>
                            </td>
                            <td class="table-actions">
                                <?php if ($doc): ?>
                                    <a href="/proyecto/<?= $doc['ruta_archivo'] ?>" target="_blank" class="btn btn--sm btn--accent">👁️ Ver</a>
                                    <form method="POST" style="display: inline;" onsubmit="return confirm('¿Eliminar este documento?')">
                                        <input type="hidden" name="documento_id" value="<?= $doc['id'] ?>">
                                        <button type="submit" name="eliminar_documento" class="btn btn--sm btn--danger">🗑️ Eliminar</button>
                                    </form>
                                <?php else: ?>
                                    <button type="button" class="btn btn--sm btn--success btn-subir" data-tipo="<?= $tipo ?>" data-nombre="<?= htmlspecialchars($nombre) ?>">📤 Subir</button>
                                <?php endif; ?>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</main>

<!-- Modal para subir documento -->
<div class="modal-overlay" id="modalSubir" role="dialog" aria-modal="true" hidden>
    <div class="modal">
        <h3 class="modal__title" id="modalSubirTitle">Subir documento</h3>
        <form method="POST" enctype="multipart/form-data" id="formSubir">
            <input type="hidden" name="tipo_documento" id="tipo_documento">
            <div class="form-group">
                <label>Archivo PDF *</label>
                <input type="file" name="documento" accept=".pdf" required style="width: 100%; padding: 0.5rem; border: 1px solid #ccd3db; border-radius: 4px;">
                <span class="form-hint">Máximo 5MB, solo PDF</span>
            </div>
            <div class="form-group">
                <label>Observaciones (opcional)</label>
                <textarea name="observaciones" rows="2" style="width: 100%; padding: 0.5rem; border: 1px solid #ccd3db; border-radius: 4px;"></textarea>
            </div>
            <div class="modal__actions">
                <button type="submit" class="btn">Subir documento</button>
                <button type="button" class="btn modal__cancel" id="btnCancelarSubir">Cancelar</button>
            </div>
        </form>
    </div>
</div>

<script>
// Modal para subir documento
document.querySelectorAll('.btn-subir').forEach(btn => {
    btn.addEventListener('click', function() {
        const tipo = this.dataset.tipo;
        const nombre = this.dataset.nombre;
        document.getElementById('modalSubirTitle').textContent = 'Subir: ' + nombre;
        document.getElementById('tipo_documento').value = tipo;
        document.getElementById('modalSubir').hidden = false;
    });
});

document.getElementById('btnCancelarSubir').addEventListener('click', function() {
    document.getElementById('modalSubir').hidden = true;
    document.getElementById('formSubir').reset();
});

document.getElementById('modalSubir').addEventListener('click', function(e) {
    if (e.target === this) {
        this.hidden = true;
        document.getElementById('formSubir').reset();
    }
});
</script>

<?php include __DIR__ . '/../includes/footer.php'; ?>