<?php
// superadmin/alta_padre_con_hijos.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/UserModel.php';
require_once __DIR__ . '/../models/PadreModel.php';
require_once __DIR__ . '/../models/AlumnoModel.php';
requireRol([1]);

$db          = getConexion();
$userModel   = new UserModel($db);
$padreModel  = new PadreModel($db, $userModel);
$alumnoModel = new AlumnoModel($db, $userModel);

$resultadoPadre = null;
$resultadoAlumnos = [];
$errorAlumnos = [];

// Procesar formulario
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // 1. Registrar al padre
    $datosPadre = [
        'apellido_paterno' => $_POST['padre_apellido_paterno'] ?? '',
        'apellido_materno' => $_POST['padre_apellido_materno'] ?? '',
        'nombre' => $_POST['padre_nombre'] ?? '',
        'genero' => $_POST['padre_genero'] ?? '',
        'curp' => $_POST['padre_curp'] ?? '',
        'telefono' => $_POST['padre_telefono'] ?? '',
        'telefono_emergencia' => $_POST['padre_telefono_emergencia'] ?? '',
        'correo' => $_POST['padre_correo'] ?? '',
    ];
    
    $resultadoPadre = $padreModel->crear($datosPadre);
    
    // 2. Si el padre se registró correctamente, registrar los hijos
    if (isset($resultadoPadre['success'])) {
        $padreId = $resultadoPadre['padre_id'];
        $numHijos = (int)($_POST['num_hijos'] ?? 0);
        
        for ($i = 1; $i <= $numHijos; $i++) {
            if (!empty($_POST["hijo_nombre_$i"])) {
                $datosAlumno = [
                    'apellido_paterno' => $_POST["hijo_apellido_paterno_$i"] ?? '',
                    'apellido_materno' => $_POST["hijo_apellido_materno_$i"] ?? '',
                    'nombre' => $_POST["hijo_nombre_$i"] ?? '',
                    'curp' => $_POST["hijo_curp_$i"] ?? '',
                    'fecha_nacimiento' => $_POST["hijo_fecha_nacimiento_$i"] ?? '',
                    'genero' => $_POST["hijo_genero_$i"] ?? '',
                    'grado' => $_POST["hijo_grado_$i"] ?? 0,
                    'grupo' => $_POST["hijo_grupo_$i"] ?? '',
                    'seccion' => $_POST["hijo_seccion_$i"] ?? '',
                    'padre_id' => $padreId,
                ];
                
                $resultadoAlumno = $alumnoModel->crear($datosAlumno);
                if (isset($resultadoAlumno['success'])) {
                    $resultadoAlumnos[] = $resultadoAlumno;
                } else {
                    $errorAlumnos[] = "Hijo #$i: " . $resultadoAlumno['error'];
                }
            }
        }
    }
}

$pageTitle = 'Superadmin › Alta rápida (Padre + Hijos)';
$backLink = 'dashboard.php';
include __DIR__ . '/../includes/header.php';
?>

<style>
    .hijo-card {
        background: #f8fafc;
        border: 1px solid var(--color-border);
        border-radius: var(--radius);
        padding: 1.25rem;
        margin-top: 1rem;
        position: relative;
    }
    .hijo-card__header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 1rem;
        padding-bottom: 0.5rem;
        border-bottom: 1px solid var(--color-border);
    }
    .hijo-card__title {
        font-weight: 600;
        color: var(--color-primary);
        font-size: 0.9rem;
    }
    .btn-remove-hijo {
        background: #fee2e2;
        color: #991b1b;
        border: none;
        padding: 0.25rem 0.6rem;
        border-radius: var(--radius-sm);
        cursor: pointer;
        font-size: 0.75rem;
    }
    .btn-remove-hijo:hover {
        background: #fecaca;
    }
    .btn-add-hijo {
        background: var(--color-accent);
        color: white;
        border: none;
        padding: 0.5rem 1rem;
        border-radius: var(--radius-sm);
        cursor: pointer;
        font-size: 0.85rem;
        margin-top: 1rem;
        width: 100%;
    }
    .btn-add-hijo:hover {
        background: #2563eb;
    }
    .seccion-badge {
        display: inline-block;
        font-size: 0.7rem;
        padding: 0.15rem 0.5rem;
        border-radius: var(--radius-sm);
        margin-left: 0.5rem;
    }
    .seccion-maternal { background: #fef3c7; color: #92400e; }
    .seccion-preescolar { background: #d1fae5; color: #065f46; }
    .seccion-primaria { background: #dbeafe; color: #1d4ed8; }
    .seccion-secundaria { background: #e0e7ff; color: #3730a3; }
</style>

<main class="container">
    <section class="card">
        <h2 class="section-title">
            👨‍👩‍👧‍👦 Alta rápida: Padre / Tutor + Hijos
        </h2>
        <p class="form-hint" style="margin-bottom: 1rem;">
            Registra un padre/tutor y hasta 6 hijos en un solo paso. 
            Los hijos se vincularán automáticamente al padre.
        </p>

        <!-- Mensajes de éxito -->
        <?php if ($resultadoPadre && isset($resultadoPadre['success'])): ?>
            <div class="alert alert--success" role="status">
                <strong>✅ Padre registrado correctamente</strong><br>
                Usuario: <strong><?= htmlspecialchars($resultadoPadre['username']) ?></strong>
                (contraseña igual al usuario)
            </div>
            
            <?php if (!empty($resultadoAlumnos)): ?>
                <div class="alert alert--success" role="status" style="margin-top: 0.5rem;">
                    <strong>📚 Hijos registrados:</strong>
                    <ul style="margin-top: 0.5rem; margin-left: 1rem;">
                        <?php foreach ($resultadoAlumnos as $al): ?>
                            <li><?= htmlspecialchars($al['username']) ?> - Matrícula: <?= htmlspecialchars($al['matricula']) ?></li>
                        <?php endforeach; ?>
                    </ul>
                </div>
            <?php endif; ?>
            
            <?php if (!empty($errorAlumnos)): ?>
                <div class="alert alert--error" role="alert" style="margin-top: 0.5rem;">
                    <strong>⚠️ Errores al registrar algunos hijos:</strong>
                    <ul style="margin-top: 0.5rem; margin-left: 1rem;">
                        <?php foreach ($errorAlumnos as $err): ?>
                            <li><?= htmlspecialchars($err) ?></li>
                        <?php endforeach; ?>
                    </ul>
                </div>
            <?php endif; ?>
            
            <!-- Botones de acción después del registro -->
            <div style="display: flex; gap: 1rem; margin-top: 1rem;">
                <a href="alta_padre_con_hijos.php" class="btn btn--accent">➕ Registrar otro</a>
                <a href="lista_padres.php" class="btn">📋 Ver padres registrados</a>
                <a href="dashboard.php" class="btn" style="background: var(--color-muted);">← Volver al dashboard</a>
            </div>
            
        <?php elseif ($resultadoPadre && isset($resultadoPadre['error'])): ?>
            <div class="alert alert--error" role="alert">
                ⚠️ Error al registrar padre: <?= htmlspecialchars($resultadoPadre['error']) ?>
            </div>
        <?php endif; ?>

        <!-- Formulario combinado -->
        <form method="POST" id="formPadreHijos" novalidate>
            <!-- ========== DATOS DEL PADRE ========== -->
            <div style="background: #f0f4f8; padding: 1rem; border-radius: var(--radius); margin-bottom: 1.5rem;">
                <h3 style="font-size: 1rem; color: var(--color-primary); margin-bottom: 1rem;">👨‍👩 Datos del padre / tutor</h3>
                
                <div class="form-grid">
                    <div class="form-group">
                        <label for="padre_apellido_paterno">Apellido paterno *</label>
                        <input type="text" id="padre_apellido_paterno" name="padre_apellido_paterno"
                               value="<?= htmlspecialchars($_POST['padre_apellido_paterno'] ?? '') ?>"
                               required maxlength="60">
                    </div>
                    
                    <div class="form-group">
                        <label for="padre_apellido_materno">Apellido materno</label>
                        <input type="text" id="padre_apellido_materno" name="padre_apellido_materno"
                               value="<?= htmlspecialchars($_POST['padre_apellido_materno'] ?? '') ?>"
                               maxlength="60">
                    </div>
                    
                    <div class="form-group full">
                        <label for="padre_nombre">Nombre(s) *</label>
                        <input type="text" id="padre_nombre" name="padre_nombre"
                               value="<?= htmlspecialchars($_POST['padre_nombre'] ?? '') ?>"
                               required maxlength="100">
                    </div>
                    
                    <div class="form-group">
                        <label for="padre_genero">Género *</label>
                        <select id="padre_genero" name="padre_genero" required>
                            <option value="">Selecciona…</option>
                            <option value="masculino" <?= (($_POST['padre_genero'] ?? '') === 'masculino') ? 'selected' : '' ?>>Masculino</option>
                            <option value="femenino" <?= (($_POST['padre_genero'] ?? '') === 'femenino') ? 'selected' : '' ?>>Femenino</option>
                            <option value="otro" <?= (($_POST['padre_genero'] ?? '') === 'otro') ? 'selected' : '' ?>>Otro</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="padre_curp">CURP</label>
                        <input type="text" id="padre_curp" name="padre_curp"
                               value="<?= htmlspecialchars($_POST['padre_curp'] ?? '') ?>"
                               maxlength="18">
                    </div>
                    
                    <div class="form-group">
                        <label for="padre_telefono">Teléfono de contacto *</label>
                        <input type="tel" id="padre_telefono" name="padre_telefono"
                               value="<?= htmlspecialchars($_POST['padre_telefono'] ?? '') ?>"
                               required maxlength="20">
                    </div>
                    
                    <div class="form-group">
                        <label for="padre_telefono_emergencia">Teléfono de emergencia</label>
                        <input type="tel" id="padre_telefono_emergencia" name="padre_telefono_emergencia"
                               value="<?= htmlspecialchars($_POST['padre_telefono_emergencia'] ?? '') ?>"
                               maxlength="20">
                    </div>
                    
                    <div class="form-group full">
                        <label for="padre_correo">Correo electrónico</label>
                        <input type="email" id="padre_correo" name="padre_correo"
                               value="<?= htmlspecialchars($_POST['padre_correo'] ?? '') ?>"
                               maxlength="120">
                    </div>
                </div>
            </div>
            
            <!-- ========== HIJOS (CONTENEDOR DINÁMICO) ========== -->
            <div>
                <h3 style="font-size: 1rem; color: var(--color-primary); margin-bottom: 0.5rem;">👧👦 Hijos</h3>
                <p class="form-hint" style="margin-bottom: 1rem;">
                    Selecciona cuántos hijos tiene y completa sus datos. 
                    Todos se vincularán automáticamente al padre.
                </p>
                
                <!-- Selector de número de hijos -->
                <div style="display: flex; gap: 1rem; align-items: center; margin-bottom: 1rem;">
                    <label for="num_hijos" style="font-weight: 500;">Número de hijos:</label>
                    <select id="num_hijos" name="num_hijos" style="width: auto; padding: 0.4rem 1rem;">
                        <option value="0">0 - Sin hijos</option>
                        <option value="1" <?= (($_POST['num_hijos'] ?? '') == 1) ? 'selected' : '' ?>>1 hijo</option>
                        <option value="2" <?= (($_POST['num_hijos'] ?? '') == 2) ? 'selected' : '' ?>>2 hijos</option>
                        <option value="3" <?= (($_POST['num_hijos'] ?? '') == 3) ? 'selected' : '' ?>>3 hijos</option>
                        <option value="4" <?= (($_POST['num_hijos'] ?? '') == 4) ? 'selected' : '' ?>>4 hijos</option>
                        <option value="5" <?= (($_POST['num_hijos'] ?? '') == 5) ? 'selected' : '' ?>>5 hijos</option>
                        <option value="6" <?= (($_POST['num_hijos'] ?? '') == 6) ? 'selected' : '' ?>>6 hijos</option>
                    </select>
                </div>
                
                <!-- Contenedor donde se generarán los formularios de hijos -->
                <div id="hijos-container"></div>
                
                <button type="button" class="btn-add-hijo" id="btnAddHijo" style="display: none;">
                    + Agregar otro hijo
                </button>
            </div>
            
            <input type="hidden" name="num_hijos_actual" id="num_hijos_actual" value="<?= (int)($_POST['num_hijos'] ?? 0) ?>">
            
            <button class="btn" type="submit" style="margin-top: 1.5rem; width: 100%;">
                💾 Registrar padre y sus hijos
            </button>
        </form>
    </section>
</main>

<script>
// Configuración de opciones para selects
const SECCIONES = [
    { value: 'maternal', label: 'Maternal' },
    { value: 'preescolar', label: 'Preescolar' },
    { value: 'primaria', label: 'Primaria' },
    { value: 'secundaria', label: 'Secundaria' }
];

const GRADOS = [1, 2, 3, 4, 5, 6];
const GRUPOS = ['A', 'B', 'C', 'D'];
const GENEROS = [
    { value: 'masculino', label: 'Masculino' },
    { value: 'femenino', label: 'Femenino' },
    { value: 'otro', label: 'Otro' }
];

// Función para obtener el badge de sección
function getSeccionBadge(seccion) {
    const clases = {
        'maternal': 'seccion-maternal',
        'preescolar': 'seccion-preescolar',
        'primaria': 'seccion-primaria',
        'secundaria': 'seccion-secundaria'
    };
    return `<span class="seccion-badge ${clases[seccion] || ''}">${seccion.charAt(0).toUpperCase() + seccion.slice(1)}</span>`;
}

// Función para generar el HTML de un hijo
function generarHijoHTML(index, datos = null) {
    const defaultData = datos || {
        apellido_paterno: '',
        apellido_materno: '',
        nombre: '',
        curp: '',
        fecha_nacimiento: '',
        genero: '',
        grado: '',
        grupo: '',
        seccion: ''
    };
    
    // Opciones de grado
    let gradoOptions = '<option value="">Selecciona…</option>';
    GRADOS.forEach(g => {
        gradoOptions += `<option value="${g}" ${defaultData.grado == g ? 'selected' : ''}>${g}°</option>`;
    });
    
    // Opciones de grupo
    let grupoOptions = '<option value="">Selecciona…</option>';
    GRUPOS.forEach(g => {
        grupoOptions += `<option value="${g}" ${defaultData.grupo === g ? 'selected' : ''}>${g}</option>`;
    });
    
    // Opciones de género
    let generoOptions = '<option value="">Selecciona…</option>';
    GENEROS.forEach(g => {
        generoOptions += `<option value="${g.value}" ${defaultData.genero === g.value ? 'selected' : ''}>${g.label}</option>`;
    });
    
    // Opciones de sección
    let seccionOptions = '<option value="">Selecciona…</option>';
    SECCIONES.forEach(s => {
        seccionOptions += `<option value="${s.value}" ${defaultData.seccion === s.value ? 'selected' : ''}>${s.label}</option>`;
    });
    
    return `
        <div class="hijo-card" data-hijo-index="${index}">
            <div class="hijo-card__header">
                <span class="hijo-card__title">
                    🧒 Hijo #${index}
                    <span id="seccion-badge-${index}" style="display: none;"></span>
                </span>
                <button type="button" class="btn-remove-hijo" onclick="removerHijo(${index})">✕ Eliminar</button>
            </div>
            
            <div class="form-grid">
                <div class="form-group">
                    <label for="hijo_apellido_paterno_${index}">Apellido paterno *</label>
                    <input type="text" id="hijo_apellido_paterno_${index}" 
                           name="hijo_apellido_paterno_${index}"
                           value="${escapeHtml(defaultData.apellido_paterno)}"
                           required maxlength="60">
                </div>
                
                <div class="form-group">
                    <label for="hijo_apellido_materno_${index}">Apellido materno</label>
                    <input type="text" id="hijo_apellido_materno_${index}" 
                           name="hijo_apellido_materno_${index}"
                           value="${escapeHtml(defaultData.apellido_materno)}"
                           maxlength="60">
                </div>
                
                <div class="form-group full">
                    <label for="hijo_nombre_${index}">Nombre(s) *</label>
                    <input type="text" id="hijo_nombre_${index}" 
                           name="hijo_nombre_${index}"
                           value="${escapeHtml(defaultData.nombre)}"
                           required maxlength="100">
                </div>
                
                <div class="form-group">
                    <label for="hijo_curp_${index}">CURP</label>
                    <input type="text" id="hijo_curp_${index}" 
                           name="hijo_curp_${index}"
                           value="${escapeHtml(defaultData.curp)}"
                           maxlength="18">
                </div>
                
                <div class="form-group">
                    <label for="hijo_fecha_nacimiento_${index}">Fecha de nacimiento *</label>
                    <input type="date" id="hijo_fecha_nacimiento_${index}" 
                           name="hijo_fecha_nacimiento_${index}"
                           value="${defaultData.fecha_nacimiento}"
                           required>
                </div>
                
                <div class="form-group">
                    <label for="hijo_genero_${index}">Género *</label>
                    <select id="hijo_genero_${index}" name="hijo_genero_${index}" required>
                        ${generoOptions}
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="hijo_seccion_${index}">Sección *</label>
                    <select id="hijo_seccion_${index}" name="hijo_seccion_${index}" 
                            required onchange="actualizarBadgeSeccion(${index}, this.value)">
                        ${seccionOptions}
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="hijo_grado_${index}">Grado *</label>
                    <select id="hijo_grado_${index}" name="hijo_grado_${index}" required>
                        ${gradoOptions}
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="hijo_grupo_${index}">Grupo *</label>
                    <select id="hijo_grupo_${index}" name="hijo_grupo_${index}" required>
                        ${grupoOptions}
                    </select>
                </div>
            </div>
        </div>
    `;
}

// Función para escapar HTML
function escapeHtml(str) {
    if (!str) return '';
    return str.replace(/[&<>]/g, function(m) {
        if (m === '&') return '&amp;';
        if (m === '<') return '&lt;';
        if (m === '>') return '&gt;';
        return m;
    });
}

// Función para actualizar el badge de sección
function actualizarBadgeSeccion(index, seccion) {
    const badgeSpan = document.getElementById(`seccion-badge-${index}`);
    if (badgeSpan) {
        if (seccion) {
            const clases = {
                'maternal': 'seccion-maternal',
                'preescolar': 'seccion-preescolar',
                'primaria': 'seccion-primaria',
                'secundaria': 'seccion-secundaria'
            };
            const texto = seccion.charAt(0).toUpperCase() + seccion.slice(1);
            badgeSpan.innerHTML = `<span class="seccion-badge ${clases[seccion] || ''}">${texto}</span>`;
            badgeSpan.style.display = 'inline';
        } else {
            badgeSpan.style.display = 'none';
        }
    }
}

// Función para actualizar todos los badges después de cargar
function actualizarTodosLosBadges() {
    for (let i = 1; i <= 6; i++) {
        const select = document.getElementById(`hijo_seccion_${i}`);
        if (select) {
            actualizarBadgeSeccion(i, select.value);
        }
    }
}

// Función para actualizar el contenedor de hijos
function actualizarHijos(numHijos) {
    const container = document.getElementById('hijos-container');
    const numActual = document.getElementById('num_hijos_actual');
    
    if (!container) return;
    
    // Guardar datos existentes antes de regenerar
    const datosExistentes = {};
    for (let i = 1; i <= 6; i++) {
        const card = document.querySelector(`.hijo-card[data-hijo-index="${i}"]`);
        if (card) {
            datosExistentes[i] = {
                apellido_paterno: document.getElementById(`hijo_apellido_paterno_${i}`)?.value || '',
                apellido_materno: document.getElementById(`hijo_apellido_materno_${i}`)?.value || '',
                nombre: document.getElementById(`hijo_nombre_${i}`)?.value || '',
                curp: document.getElementById(`hijo_curp_${i}`)?.value || '',
                fecha_nacimiento: document.getElementById(`hijo_fecha_nacimiento_${i}`)?.value || '',
                genero: document.getElementById(`hijo_genero_${i}`)?.value || '',
                grado: document.getElementById(`hijo_grado_${i}`)?.value || '',
                grupo: document.getElementById(`hijo_grupo_${i}`)?.value || '',
                seccion: document.getElementById(`hijo_seccion_${i}`)?.value || ''
            };
        }
    }
    
    // Generar HTML
    let html = '';
    for (let i = 1; i <= numHijos; i++) {
        html += generarHijoHTML(i, datosExistentes[i] || null);
    }
    container.innerHTML = html;
    
    // Actualizar el campo oculto
    if (numActual) {
        numActual.value = numHijos;
    }
    
    // Actualizar badges después de cargar
    setTimeout(actualizarTodosLosBadges, 50);
}

// Función para remover un hijo específico
function removerHijo(index) {
    const select = document.getElementById('num_hijos');
    if (!select) return;
    
    let numActual = parseInt(select.value);
    if (numActual > 0 && index <= numActual) {
        // Crear un nuevo array con los hijos excluyendo el eliminado
        const nuevosValores = [];
        for (let i = 1; i <= numActual; i++) {
            if (i !== index) {
                // Guardar datos del hijo que se mantiene
                const datos = {
                    apellido_paterno: document.getElementById(`hijo_apellido_paterno_${i}`)?.value || '',
                    apellido_materno: document.getElementById(`hijo_apellido_materno_${i}`)?.value || '',
                    nombre: document.getElementById(`hijo_nombre_${i}`)?.value || '',
                    curp: document.getElementById(`hijo_curp_${i}`)?.value || '',
                    fecha_nacimiento: document.getElementById(`hijo_fecha_nacimiento_${i}`)?.value || '',
                    genero: document.getElementById(`hijo_genero_${i}`)?.value || '',
                    grado: document.getElementById(`hijo_grado_${i}`)?.value || '',
                    grupo: document.getElementById(`hijo_grupo_${i}`)?.value || '',
                    seccion: document.getElementById(`hijo_seccion_${i}`)?.value || ''
                };
                nuevosValores.push(datos);
            }
        }
        
        // Actualizar el select a la nueva cantidad
        select.value = nuevosValores.length;
        
        // Regenerar con los datos guardados
        const container = document.getElementById('hijos-container');
        let html = '';
        for (let i = 0; i < nuevosValores.length; i++) {
            html += generarHijoHTML(i + 1, nuevosValores[i]);
        }
        container.innerHTML = html;
        
        // Actualizar campo oculto
        document.getElementById('num_hijos_actual').value = nuevosValores.length;
        
        // Actualizar badges
        setTimeout(actualizarTodosLosBadges, 50);
    }
}

// Evento cuando cambia el número de hijos
document.addEventListener('DOMContentLoaded', function() {
    const selectNumHijos = document.getElementById('num_hijos');
    const btnAddHijo = document.getElementById('btnAddHijo');
    
    if (selectNumHijos) {
        // Inicializar con el valor actual
        actualizarHijos(parseInt(selectNumHijos.value));
        
        selectNumHijos.addEventListener('change', function() {
            actualizarHijos(parseInt(this.value));
        });
    }
    
    // Botón "Agregar otro hijo"
    if (btnAddHijo) {
        btnAddHijo.addEventListener('click', function() {
            if (selectNumHijos) {
                let newVal = parseInt(selectNumHijos.value) + 1;
                if (newVal <= 6) {
                    selectNumHijos.value = newVal;
                    actualizarHijos(newVal);
                } else {
                    alert('Máximo 6 hijos por padre/tutor');
                }
            }
        });
    }
    
    // Actualizar badges en tiempo real cuando cambia la sección
    document.addEventListener('change', function(e) {
        if (e.target && e.target.id && e.target.id.startsWith('hijo_seccion_')) {
            const match = e.target.id.match(/hijo_seccion_(\d+)/);
            if (match) {
                actualizarBadgeSeccion(parseInt(match[1]), e.target.value);
            }
        }
    });
});
</script>

<?php include __DIR__ . '/../includes/footer.php'; ?>