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

$alumno           = $boleta['alumno']           ?? [];
$porCampo         = $boleta['porCampo']         ?? [];
$periodosAbiertos = $boleta['periodosAbiertos'] ?? [];

// ============================================================
// AGRUPAR MATERIAS DE ARTES
// ============================================================
// 4 = Artes | 27 = Música | 28 = Danza | 29 = Teatro
//
// Reglas de qué materias de artes se promedian:
//  - Primaria 1° a 4°: Artes + Danza + Música
//  - Primaria 5° y 6°: Artes + Música + Teatro
//  - Secundaria (todos los grados): Artes + Teatro
function agruparArtes($materias, $grado, $seccion) {
    $artesMaterias = [];
    $otrasMaterias = [];

    // IDs de materias de artes
    $artesIds = [4, 27, 28, 29];

    if ($seccion === 'secundaria') {
        $artesIdsAplican = [4, 29];
    } elseif ($grado >= 5) {
        $artesIdsAplican = [4, 27, 29];
    } else {
        $artesIdsAplican = [4, 27, 28];
    }

    foreach ($materias as $m) {
        $materiaId = (int)($m['materia_id'] ?? 0);

        // Verificar si es una materia de artes que aplica
        if (in_array($materiaId, $artesIds) && in_array($materiaId, $artesIdsAplican)) {
            $artesMaterias[] = $m;
        } else {
            $otrasMaterias[] = $m;
        }
    }

    // Si no hay materias de artes, devolver las originales
    if (empty($artesMaterias)) {
        return $materias;
    }

    // Crear la materia "Artes" con el promedio de todas las artes
    $promedioArtes = [
        'materia_nombre' => 'Artes',
        'materia_id' => 4,
        'es_artes' => 1,
        'es_ingles' => 0,
        'asignacion_id' => 0,
        'calificaciones' => [],
        'trimestres' => [1 => null, 2 => null, 3 => null],
    ];

    // Calcular promedio por período (1-6)
    for ($p = 1; $p <= 6; $p++) {
        $suma = 0;
        $count = 0;
        foreach ($artesMaterias as $am) {
            $cal = $am['calificaciones'][$p] ?? null;
            if ($cal !== null) {
                $suma += $cal;
                $count++;
            }
        }
        $promedioArtes['calificaciones'][$p] = $count > 0 ? round($suma / $count, 1) : null;
    }

    // Calcular trimestres
    for ($t = 1; $t <= 3; $t++) {
        $suma = 0;
        $count = 0;
        foreach ($artesMaterias as $am) {
            $prom = $am['trimestres'][$t] ?? null;
            if ($prom !== null) {
                $suma += $prom;
                $count++;
            }
        }
        $promedioArtes['trimestres'][$t] = $count > 0 ? round($suma / $count, 1) : null;
    }

    // Agregar la materia Artes al inicio de las otras materias
    array_unshift($otrasMaterias, $promedioArtes);

    return $otrasMaterias;
}

// ============================================================
// APLICAR AGRUPACIÓN EN TODOS LOS CAMPOS FORMATIVOS
// ============================================================
$gradoAlumno   = (int)($alumno['grado'] ?? 1);
$seccionAlumno = $alumno['seccion'] ?? 'primaria';

// Recorrer TODOS los campos formativos, no solo uno
foreach ($porCampo as $campo => $materias) {
    // Verificar si hay materias de artes en este campo
    $hayArtes = false;
    foreach ($materias as $m) {
        $materiaId = (int)($m['materia_id'] ?? 0);
        if (in_array($materiaId, [4, 27, 28, 29])) {
            $hayArtes = true;
            break;
        }
    }

    // Si hay artes en este campo, aplicar agrupación
    if ($hayArtes) {
        $porCampo[$campo] = agruparArtes($materias, $gradoAlumno, $seccionAlumno);
    }
}

// ORDEN ESPECÍFICO DE CAMPOS FORMATIVOS
$ordenCampos = [
    'LENGUAJES',
    'SABERES Y PENSAMIENTO CIENTÍFICO',
    'ÉTICA NATURALEZA Y SOCIEDADES',
    'DE LO HUMANO Y LO COMUNITARIO',
    'SIN CAMPO FORMATIVO',
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
  <div style="margin-bottom: 20px; text-align: right;">
      <a class="btn btn--sm btn--success" 
         href="boleta_pdf_primaria.php?alumno_id=<?= $alumnoId ?>" 
         target="_blank">
          📄 PDF Primaria
      </a>
  </div>

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
            <?php
              $materiasVista = array_values(array_filter($materias, function($m) {
                  return !((int)($m['es_ingles'] ?? 0) === 1 && (int)($m['asignacion_id'] ?? 0) > 0);
              }));
              $totalFilas = count($materiasVista);
              if ($totalFilas === 0) continue;
            ?>
            <?php foreach ($materiasVista as $i => $m): ?>
              <tr>
                <?php if ($i === 0): ?>
                  <td rowspan="<?= $totalFilas ?>"
                      style="font-weight:700; background:#f0f9ff; color:#0369a1; vertical-align:middle; border-right:2px solid #e2e8f0;">
                    <?= htmlspecialchars($campo) ?>
                  </td>
                <?php endif; ?>
                <td style="font-size:.85rem; font-weight:500; padding:10px 8px;">
                  <?= htmlspecialchars($m['materia_nombre']) ?>
                </td>
                <?php for ($p = 1; $p <= 6; $p++): ?>
                  <?php $cal = $m['calificaciones'][$p] ?? null; ?>
                  <td style="text-align:center; font-size:.85rem; padding:8px 4px;
                    <?= ($cal !== null && $cal < 6) ? 'color:#dc2626; font-weight:700;' : '' ?>">
                    <?= $cal !== null ? $cal : (in_array($p, $periodosAbiertos) ? '—' : '') ?>
                  </td>
                <?php endfor; ?>
                <?php for ($t = 1; $t <= 3; $t++): ?>
                  <?php $prom = $m['trimestres'][$t] ?? null; ?>
                  <td style="text-align:center; font-size:.85rem; font-weight:700; background:#f8fafc; padding:8px 4px;
                    <?= ($prom !== null && $prom < 6) ? 'color:#dc2626;' : 'color:#0369a1;' ?>">
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