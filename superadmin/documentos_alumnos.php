<?php
// superadmin/documentos_alumnos.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/DocumentoModel.php';
requireRol([1]);

$db = getConexion();
$documentoModel = new DocumentoModel($db);

// ============================================
// MANEJAR PETICIÓN AJAX (buscar alumnos)
// ============================================
if (isset($_GET['ajax']) && $_GET['ajax'] == 1) {
    header('Content-Type: application/json');
    $busqueda = $_GET['q'] ?? '';
    
    if (strlen($busqueda) < 2) {
        echo json_encode([]);
        exit;
    }
    
    $like = "%$busqueda%";
    $stmt = $db->prepare("
        SELECT a.id, a.nombre, a.apellido_paterno, a.apellido_materno, a.matricula, a.grado, a.grupo, a.seccion
        FROM alumnos a
        WHERE a.activo = 1 
        AND (a.nombre LIKE ? OR a.apellido_paterno LIKE ? OR a.apellido_materno LIKE ? OR a.matricula LIKE ?)
        ORDER BY a.apellido_paterno, a.nombre
        LIMIT 10
    ");
    $stmt->bind_param('ssss', $like, $like, $like, $like);
    $stmt->execute();
    $alumnos = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    
    echo json_encode($alumnos);
    exit;
}

// ============================================
// MANEJAR PETICIÓN NORMAL
// ============================================
$alumnoId = (int)($_GET['alumno_id'] ?? 0);
$busqueda = $_GET['busqueda'] ?? '';

// Obtener alumno seleccionado
$alumno = null;
$documentosPorTipo = [];
if ($alumnoId) {
    $stmt = $db->prepare("SELECT id, nombre, apellido_paterno, apellido_materno, matricula, grado, grupo, seccion FROM alumnos WHERE id = ? AND activo = 1");
    $stmt->bind_param('i', $alumnoId);
    $stmt->execute();
    $alumno = $stmt->get_result()->fetch_assoc();
    
    if ($alumno) {
        $docs = $documentoModel->getDocumentosPorAlumno($alumnoId);
        foreach ($docs as $doc) {
            $documentosPorTipo[$doc['tipo_documento']] = $doc;
        }
    }
}

$tipos = $documentoModel->getTiposDocumentos();

$pageTitle = 'Superadmin › Documentos';
$backLink = 'dashboard.php';
include __DIR__ . '/../includes/header.php';
?>

<main class="container">
    <div class="card">
        <h2 class="section-title">📄 Documentos de alumnos</h2>
        <p class="form-hint">Escribe el nombre, apellido o matrícula - aparecerán sugerencias automáticas</p>

        <!-- Buscador con autocompletado -->
        <div style="position: relative; margin-bottom: 1.5rem;">
            <input type="text" id="buscador" class="form-control" 
                   placeholder="Ej: Moreno, Amy, CEFSAMX2026..."
                   value="<?= htmlspecialchars($busqueda) ?>"
                   autocomplete="off"
                   style="width: 100%; padding: 0.6rem 0.75rem; border: 1px solid #ccd3db; border-radius: 6px; font-size: 0.9rem;">
            <div id="sugerencias" style="display: none; position: absolute; top: 100%; left: 0; right: 0; background: white; border: 1px solid #e2e8f0; border-radius: 6px; max-height: 300px; overflow-y: auto; z-index: 1000; margin-top: 4px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);"></div>
        </div>

        <!-- Documentos del alumno seleccionado -->
        <?php if ($alumno): ?>
            <div style="background: #f0f4f8; padding: 1rem; border-radius: 8px; margin-bottom: 1.5rem;">
                <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap;">
                    <div>
                        <h3 style="color: #1e3a5f; margin-bottom: 0.5rem;">
                            👨‍🎓 <?= htmlspecialchars($alumno['apellido_paterno'] . ' ' . ($alumno['apellido_materno'] ?? '') . ', ' . $alumno['nombre']) ?>
                        </h3>
                        <p class="form-hint" style="margin: 0;">
                            Matrícula: <strong><?= htmlspecialchars($alumno['matricula'] ?? '—') ?></strong> &nbsp;|&nbsp;
                            Sección: <strong><?= ucfirst($alumno['seccion']) ?></strong> &nbsp;|&nbsp;
                            Grado: <strong><?= $alumno['grado'] ?>°</strong> &nbsp;|&nbsp;
                            Grupo: <strong><?= $alumno['grupo'] ?></strong>
                        </p>
                    </div>
                    <a href="documentos_alumnos.php" class="btn btn--sm btn--muted" style="margin-top: 0.5rem;">← Buscar otro alumno</a>
                </div>
            </div>

            <div style="overflow-x: auto;">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Tipo de documento</th>
                            <th>Estado</th>
                            <th>Archivo</th>
                            <th>Ver</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($tipos as $key => $nombre): ?>
                            <?php $doc = $documentosPorTipo[$key] ?? null; ?>
                            <tr>
                                <td style="font-weight: 500;"><?= htmlspecialchars($nombre) ?></td>
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
                                    <?php if ($doc): ?>
                                        <a href="/proyecto/<?= $doc['ruta_archivo'] ?>" target="_blank" class="btn btn--sm btn--accent">📄 Ver PDF</a>
                                    <?php else: ?>
                                        <span class="btn btn--sm btn--disabled">📄 No disponible</span>
                                    <?php endif; ?>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        <?php endif; ?>
    </div>
</main>

<script>
const buscador = document.getElementById('buscador');
const sugerenciasDiv = document.getElementById('sugerencias');
let timeoutId = null;

buscador.addEventListener('input', function() {
    const query = this.value.trim();
    
    if (timeoutId) clearTimeout(timeoutId);
    
    if (query.length < 2) {
        sugerenciasDiv.style.display = 'none';
        sugerenciasDiv.innerHTML = '';
        return;
    }
    
    timeoutId = setTimeout(() => {
        // Llamar al mismo archivo con parámetro ajax=1
        fetch(`documentos_alumnos.php?ajax=1&q=${encodeURIComponent(query)}`)
            .then(response => response.json())
            .then(data => {
                if (data.length === 0) {
                    sugerenciasDiv.innerHTML = '<div style="padding: 0.5rem 0.75rem; color: #94a3b8;">No se encontraron alumnos...</div>';
                    sugerenciasDiv.style.display = 'block';
                    return;
                }
                
                sugerenciasDiv.innerHTML = data.map(alumno => `
                    <div class="sugerencia-item" data-id="${alumno.id}" style="padding: 0.5rem 0.75rem; cursor: pointer; border-bottom: 1px solid #e2e8f0; transition: background 0.15s;">
                        <strong>${alumno.apellido_paterno} ${alumno.apellido_materno || ''}, ${alumno.nombre}</strong>
                        <span style="display: inline-block; background: #dbeafe; color: #1d4ed8; border-radius: 4px; padding: 0.15rem 0.5rem; font-size: 0.65rem; margin-left: 0.5rem;">${alumno.seccion} ${alumno.grado}° ${alumno.grupo}</span>
                        <span style="display: inline-block; background: #f1f5f9; color: #64748b; border-radius: 4px; padding: 0.15rem 0.5rem; font-size: 0.65rem; margin-left: 0.5rem;">${alumno.matricula || '—'}</span>
                    </div>
                `).join('');
                sugerenciasDiv.style.display = 'block';
                
                document.querySelectorAll('.sugerencia-item').forEach(item => {
                    item.addEventListener('click', function() {
                        const id = this.dataset.id;
                        window.location.href = `documentos_alumnos.php?alumno_id=${id}`;
                    });
                    item.addEventListener('mouseenter', function() {
                        this.style.backgroundColor = '#f0f4f8';
                    });
                    item.addEventListener('mouseleave', function() {
                        this.style.backgroundColor = 'white';
                    });
                });
            })
            .catch(error => {
                console.error('Error:', error);
            });
    }, 300);
});

document.addEventListener('click', function(e) {
    if (!buscador.contains(e.target) && !sugerenciasDiv.contains(e.target)) {
        sugerenciasDiv.style.display = 'none';
    }
});
</script>

<?php include __DIR__ . '/../includes/footer.php'; ?>