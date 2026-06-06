<?php
// padre/boleta.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/UserModel.php';
require_once __DIR__ . '/../models/PadreModel.php';
require_once __DIR__ . '/../models/AlumnoModel.php';
require_once __DIR__ . '/../models/CicloModel.php';
require_once __DIR__ . '/../models/BoletaModel.php';
requireRol([2]);

$db          = getConexion();
$padreModel  = new PadreModel($db, new UserModel($db));
$alumnoModel = new AlumnoModel($db, new UserModel($db));
$cicloModelo = new CicloModel($db);
$boletaModel = new BoletaModel($db);

$padre = $padreModel->obtenerPorUserId((int)$_SESSION['user_id']);
if (!$padre) { header('Location: /proyecto/login.php'); exit; }

$cicloActivo = $cicloModelo->obtenerActivo();
$alumnoId    = (int)($_GET['alumno_id'] ?? 0);

$hijos = $alumnoModel->obtenerPorPadreId((int)$padre['id']);
$alumnoValido = false;
foreach ($hijos as $h) {
    if ((int)$h['id'] === $alumnoId) { $alumnoValido = true; break; }
}

if (!$alumnoValido || !$cicloActivo) {
    header('Location: mis_hijos.php');
    exit;
}

$boleta = $boletaModel->obtenerBoleta($alumnoId, (int)$cicloActivo['id']);

$alumno    = $boleta['alumno']   ?? [];
$porCampo  = $boleta['porCampo'] ?? [];
$periodosAbiertos = $boleta['periodosAbiertos'] ?? [];

// ============================================================
// FUNCIÓN PARA ASIGNAR CAMPO FORMATIVO SEGÚN LA MATERIA
// ============================================================
function asignarCampoFormativo($nombreMateria) {
    $materia = strtolower(trim($nombreMateria));
    
    // SABERES Y PENSAMIENTO CIENTÍFICO
    if (strpos($materia, 'matem') !== false || 
        strpos($materia, 'ciencia') !== false ||
        strpos($materia, 'biología') !== false ||
        strpos($materia, 'biologia') !== false ||
        strpos($materia, 'química') !== false ||
        strpos($materia, 'quimica') !== false ||
        strpos($materia, 'física') !== false ||
        strpos($materia, 'fisica') !== false) {
        return 'SABERES Y PENSAMIENTO CIENTÍFICO';
    }
    
    // LENGUAJES
    if (strpos($materia, 'lengua') !== false || 
        strpos($materia, 'español') !== false ||
        strpos($materia, 'comunicación') !== false ||
        strpos($materia, 'lectura') !== false ||
        strpos($materia, 'inglés') !== false ||
        strpos($materia, 'ingles') !== false ||
        strpos($materia, 'lenguaje') !== false ||
        strpos($materia, 'literatura') !== false) {
        return 'LENGUAJES';
    }
    
    // ÉTICA, NATURALEZA Y SOCIEDADES
    if (strpos($materia, 'ética') !== false || 
        strpos($materia, 'etica') !== false ||
        strpos($materia, 'cívica') !== false ||
        strpos($materia, 'civica') !== false ||
        strpos($materia, 'valores') !== false ||
        strpos($materia, 'historia') !== false ||
        strpos($materia, 'geografía') !== false ||
        strpos($materia, 'geografia') !== false ||
        strpos($materia, 'sociales') !== false ||
        strpos($materia, 'formación') !== false) {
        return 'ÉTICA, NATURALEZA Y SOCIEDADES';
    }
    
    // DE LO HUMANO Y LO COMUNITARIO
    if (strpos($materia, 'tutoría') !== false || 
        strpos($materia, 'tutoria') !== false ||
        strpos($materia, 'comunitario') !== false ||
        strpos($materia, 'humano') !== false ||
        strpos($materia, 'convivencia') !== false) {
        return 'DE LO HUMANO Y LO COMUNITARIO';
    }
    
    // EDUCACIÓN FÍSICA
    if (strpos($materia, 'educación física') !== false || 
        strpos($materia, 'educacion fisica') !== false ||
        strpos($materia, 'deporte') !== false) {
        return 'EDUCACIÓN FÍSICA';
    }
    
    return 'OTROS CAMPOS FORMATIVOS';
}

// ============================================================
// FUNCIÓN PARA CALCULAR PROMEDIO DE SUBMATERIAS (como Artes)
// ============================================================
function calcularPromedioSubmaterias($submaterias, $periodo) {
    $suma = 0;
    $count = 0;
    foreach ($submaterias as $sub) {
        $cal = $sub['calificaciones'][$periodo] ?? null;
        if ($cal !== null && is_numeric($cal)) {
            $suma += $cal;
            $count++;
        }
    }
    return $count > 0 ? round($suma / $count, 1) : null;
}

// ============================================================
// AGRUPAR MATERIAS Y SUS SUBMATERIAS (Música, Danza, Teatro van dentro de Artes)
// ============================================================
$materiasPrincipales = [];
$submaterias = [];

foreach ($porCampo as $campoViejo => $materias) {
    foreach ($materias as $materia) {
        $nombre = $materia['materia_nombre'];
        $nombreLower = strtolower($nombre);
        
        // Detectar si es una submateria de Artes
        $esSubmateriaArtes = (strpos($nombreLower, 'música') !== false || 
                               strpos($nombreLower, 'musica') !== false ||
                               strpos($nombreLower, 'danza') !== false ||
                               strpos($nombreLower, 'teatro') !== false ||
                               strpos($nombreLower, 'dibujo') !== false ||
                               strpos($nombreLower, 'pintura') !== false ||
                               strpos($nombreLower, 'escultura') !== false ||
                               strpos($nombreLower, 'plástica') !== false ||
                               strpos($nombreLower, 'artes visuales') !== false);
        
        if ($esSubmateriaArtes) {
            // Es una submateria de Artes
            if (!isset($submaterias['ARTES'])) {
                $submaterias['ARTES'] = [];
            }
            $submaterias['ARTES'][] = $materia;
        } else {
            // Es materia principal
            $campoReal = asignarCampoFormativo($nombre);
            if (!isset($materiasPrincipales[$campoReal])) {
                $materiasPrincipales[$campoReal] = [];
            }
            $materiasPrincipales[$campoReal][] = $materia;
        }
    }
}

// Crear la materia ARTES con sus promedios calculados
if (isset($submaterias['ARTES']) && !empty($submaterias['ARTES'])) {
    $campoArtes = asignarCampoFormativo('ARTES'); // Esto debe dar LENGUAJES
    if (!isset($materiasPrincipales[$campoArtes])) {
        $materiasPrincipales[$campoArtes] = [];
    }
    
    // Calcular promedios de ARTES para cada período y trimestre
    $calificacionesArtes = [];
    for ($p = 1; $p <= 6; $p++) {
        $calificacionesArtes[$p] = calcularPromedioSubmaterias($submaterias['ARTES'], $p);
    }
    
    $trimestresArtes = [];
    for ($t = 1; $t <= 3; $t++) {
        // Para trimestres, promediar los períodos que corresponden a cada trimestre
        if ($t == 1) $periodos = [1, 2];
        elseif ($t == 2) $periodos = [3, 4];
        else $periodos = [5, 6];
        
        $suma = 0;
        $count = 0;
        foreach ($periodos as $p) {
            if ($calificacionesArtes[$p] !== null) {
                $suma += $calificacionesArtes[$p];
                $count++;
            }
        }
        $trimestresArtes[$t] = $count > 0 ? round($suma / $count, 1) : null;
    }
    
    $materiasPrincipales[$campoArtes][] = [
        'materia_nombre' => 'Artes',
        'calificaciones' => $calificacionesArtes,
        'trimestres' => $trimestresArtes,
        'es_promedio' => true,
        'submaterias' => $submaterias['ARTES']
    ];
}

$porCampo = $materiasPrincipales;

// ORDEN ESPECÍFICO DE CAMPOS FORMATIVOS
$ordenCampos = [
    'SABERES Y PENSAMIENTO CIENTÍFICO',
    'LENGUAJES',
    'ÉTICA, NATURALEZA Y SOCIEDADES',
    'DE LO HUMANO Y LO COMUNITARIO',
    'EDUCACIÓN FÍSICA',
    'OTROS CAMPOS FORMATIVOS'
];

$porCampoFinal = [];
foreach ($ordenCampos as $campo) {
    if (isset($porCampo[$campo])) {
        $porCampoFinal[$campo] = $porCampo[$campo];
    }
}
foreach ($porCampo as $campo => $materias) {
    if (!isset($porCampoFinal[$campo])) {
        $porCampoFinal[$campo] = $materias;
    }
}
$porCampo = $porCampoFinal;

$pageTitle = 'Boleta — ' . ($alumno['nombre'] ?? '');
$backLink  = 'mis_hijos.php';
$backLabel = '← Mis hijos';
include __DIR__ . '/../includes/header.php';
?>

<main class="container">

  <?php if (empty($alumno)): ?>
    <p class="empty-state">No se encontró información del alumno.</p>
  <?php else: ?>

  <div class="card" style="margin-bottom:1.5rem;">
    <div style="display:flex; justify-content:space-between; align-items:start; flex-wrap:wrap; gap:1rem;">
      <div>
        <h2 style="color:var(--color-primary); font-size:1.2rem; margin-bottom:.3rem;">
          <?= htmlspecialchars($alumno['nombre'] . ' ' . $alumno['apellido_paterno'] . ' ' . ($alumno['apellido_materno'] ?? '')) ?>
        </h2>
        <p class="form-hint">
          Matrícula: <strong><?= htmlspecialchars($alumno['matricula'] ?? '—') ?></strong>
          &nbsp;|&nbsp;
          <?= ucfirst($alumno['seccion']) ?> — <?= $alumno['grado'] ?>° <?= $alumno['grupo'] ?>
          &nbsp;|&nbsp;
          Ciclo: <strong><?= htmlspecialchars($cicloActivo['nombre']) ?></strong>
        </p>
      </div>
      <div>
        <a class="btn btn--sm btn--accent"
           href="boleta_pdf.php?alumno_id=<?= $alumnoId ?>&tipo=espanol"
           target="_blank">
          ⬇ PDF Boleta
        </a>
      </div>
    </div>
  </div>

  <section class="card">
    <h3 class="section-title" style="margin-bottom:1rem;">📋 Boletín de Calificaciones</h3>

    <div style="overflow-x:auto;">
      <table class="data-table">
        <thead>
          <tr>
            <th style="text-align:left; width:25%;">CAMPO FORMATIVO</th>
            <th style="text-align:left; width:25%;">MATERIA / ASIGNATURA</th>
            <?php for ($p = 1; $p <= 6; $p++): ?>
              <th style="text-align:center; min-width:50px;">P<?= $p ?></th>
            <?php endfor; ?>
            <th style="text-align:center;">T1</th>
            <th style="text-align:center;">T2</th>
            <th style="text-align:center;">T3</th>
          </tr>
        </thead>
        <tbody>
          <?php foreach ($porCampo as $campo => $materias): ?>
            <?php foreach ($materias as $i => $m): ?>
              <tr>
                <?php if ($i === 0): ?>
                  <td rowspan="<?= count($materias) ?>"
                      style="font-weight:700; background:#f0f9ff; color:#0369a1; vertical-align:middle; border-right:2px solid #e2e8f0;">
                    <strong><?= htmlspecialchars($campo) ?></strong>
                  </td>
                <?php endif; ?>
                <td style="font-size:.85rem; font-weight:500; padding:10px 8px;">
                  <?= htmlspecialchars($m['materia_nombre']) ?>
                  <?php if (isset($m['es_promedio']) && $m['es_promedio'] === true): ?>
                    <span style="background:#dbeafe; color:#1e40af; font-size:0.65rem; padding:2px 6px; border-radius:12px; margin-left:6px;">
                      Promedio de Artes
                    </span>
                    <br>
                    <small style="font-size:0.7rem; color:#6c757d;">
                      (<?= implode(', ', array_map(function($sub) { return $sub['materia_nombre']; }, $m['submaterias'])) ?>)
                    </small>
                  <?php endif; ?>
                  <?php if ($m['materia_nombre'] === 'Inglés'): ?>
                    <span class="badge">Inglés</span>
                  <?php endif; ?>
                </td>
                <?php for ($p = 1; $p <= 6; $p++): ?>
                  <?php $cal = $m['calificaciones'][$p] ?? null; ?>
                  <td style="text-align:center; font-size:.85rem; padding:8px 4px; <?= ($cal !== null && $cal < 6) ? 'color:#dc2626; font-weight:700;' : '' ?>">
                    <?= $cal !== null ? $cal : (in_array($p, $periodosAbiertos) ? '—' : '') ?>
                  </td>
                <?php endfor; ?>
                <?php for ($t = 1; $t <= 3; $t++): ?>
                  <?php $prom = $m['trimestres'][$t] ?? null; ?>
                  <td style="text-align:center; font-size:.85rem; font-weight:700; background:#f8fafc; padding:8px 4px; <?= ($prom !== null && $prom < 6) ? 'color:#dc2626;' : 'color:#0369a1;' ?>">
                    <?= $prom !== null ? $prom : '—' ?>
                  </td>
                <?php endfor; ?>
              </tr>
            <?php endforeach; ?>
          <?php endforeach; ?>
        </tbody>
      </table>
    </div>
    
    <?php if (!empty($periodosAbiertos)): ?>
    <p style="font-size:0.75rem; color:#6c757d; margin-top:1rem; font-style:italic;">
      * Los periodos abiertos están marcados con "—"
    </p>
    <?php endif; ?>
  </section>

  <?php endif; ?>
</main>

<?php include __DIR__ . '/../includes/footer.php'; ?>