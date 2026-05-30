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

$asignacionInglesId = null;
foreach ($boleta['materias'] ?? [] as $m) {
    if ((int)$m['es_ingles']) {
        $asignacionInglesId = (int)$m['asignacion_id'];
        break;
    }
}

$boletaIngles = $asignacionInglesId
    ? $boletaModel->obtenerBoletaIngles($alumnoId, (int)$cicloActivo['id'], $asignacionInglesId)
    : null;

$alumno    = $boleta['alumno']   ?? [];
$porCampo  = $boleta['porCampo'] ?? [];
$periodosAbiertos = $boleta['periodosAbiertos'] ?? [];

$totalAusencias = 0;
$promedioDisciplina = 0;
$promedioHigiene = 0;

if ($cicloActivo && $alumnoId) {
    $stmt = $db->prepare("
        SELECT 
            SUM(ausencias) as total_ausencias,
            AVG(disciplina) as promedio_disciplina,
            AVG(higiene) as promedio_higiene
        FROM calificaciones_titular
        WHERE alumno_id = ? AND ciclo_id = ?
    ");
    $stmt->bind_param('ii', $alumnoId, $cicloActivo['id']);
    $stmt->execute();
    $resTitular = $stmt->get_result()->fetch_assoc();
    
    $totalAusencias = (int)($resTitular['total_ausencias'] ?? 0);
    $promedioDisciplina = round($resTitular['promedio_disciplina'] ?? 0, 1);
    $promedioHigiene = round($resTitular['promedio_higiene'] ?? 0, 1);
}

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
        <p class="form-hint" style="margin-top:0;">
          Matrícula: <strong><?= htmlspecialchars($alumno['matricula'] ?? '—') ?></strong>
          &nbsp;|&nbsp;
          <?= ucfirst($alumno['seccion']) ?> — <?= $alumno['grado'] ?>° <?= $alumno['grupo'] ?>
          &nbsp;|&nbsp;
          Ciclo: <strong><?= htmlspecialchars($cicloActivo['nombre']) ?></strong>
        </p>
      </div>
      <div style="display:flex; gap:.6rem;">
        <a class="btn btn--sm btn--accent"
           href="boleta_pdf.php?alumno_id=<?= $alumnoId ?>&tipo=espanol"
           target="_blank">
          ⬇ PDF Español
        </a>
        <?php if ($boletaIngles): ?>
          <a class="btn btn--sm btn--success"
             href="boleta_pdf.php?alumno_id=<?= $alumnoId ?>&tipo=ingles"
             target="_blank">
            ⬇ PDF Inglés
          </a>
        <?php endif; ?>
      </div>
    </div>
  </div>

  <section class="card" style="margin-bottom:1.5rem;">
    <h3 class="section-title" style="margin-bottom:1rem; font-size:1rem;">
      📋 Boleta — Español
    </h3>

    <div style="overflow-x:auto;">
      <table class="data-table">
        <thead>
          <tr>
            <th>Campo formativo</th>
            <th>Materia</th>
            <?php for ($p = 1; $p <= 6; $p++): ?>
              <th style="background:var(--color-primary); color:#fff; min-width:50px;">P<?= $p ?></th>
            <?php endfor; ?>
            <th style="background:var(--color-primary); color:#fff;">T1</th>
            <th style="background:var(--color-primary); color:#fff;">T2</th>
            <th style="background:var(--color-primary); color:#fff;">T3</th>
          </tr>
        </thead>
        <tbody>
          <?php foreach ($porCampo as $campo => $materias): ?>
            <?php foreach ($materias as $i => $m): ?>
              <?php if ((int)$m['es_ingles']) continue; ?>
              <tr>
                <?php if ($i === 0): ?>
                  <td rowspan="<?= count(array_filter($materias, fn($x) => !(int)$x['es_ingles'])) ?>"
                      style="font-weight:600; color:var(--color-primary); font-size:.82rem; vertical-align:top;">
                    <?= htmlspecialchars($campo) ?>
                  </td>
                <?php endif; ?>
                <td style="font-size:.85rem;">
                  <?= htmlspecialchars($m['materia_nombre']) ?>
                  <?php if (!empty($m['subcomponente'])): ?>
                    <span class="badge" style="background:#f1f5f9; color:var(--color-muted);"><?= htmlspecialchars($m['subcomponente']) ?></span>
                  <?php endif; ?>
                </td>
                <?php for ($p = 1; $p <= 6; $p++): ?>
                  <?php $cal = $m['calificaciones'][$p] ?? null; ?>
                  <td style="text-align:center; font-size:.85rem; <?= ($cal !== null && $cal < 6) ? 'color:#991b1b; font-weight:600;' : '' ?>">
                    <?= $cal ?? (in_array($p, $periodosAbiertos) ? '—' : '') ?>
                  </td>
                <?php endfor; ?>
                <?php for ($t = 1; $t <= 3; $t++): ?>
                  <?php $prom = $m['trimestres'][$t] ?? null; ?>
                  <td style="text-align:center; font-size:.85rem; font-weight:600; background:#f8fafc; <?= ($prom !== null && $prom < 6) ? 'color:#991b1b;' : 'color:var(--color-primary);' ?>">
                    <?= $prom ?? '—' ?>
                  </td>
                <?php endfor; ?>
              </tr>
            <?php endforeach; ?>
          <?php endforeach; ?>
        </tbody>
      </table>
    </div>
  </section>

  <?php if ($boletaIngles && !empty($boletaIngles['aspectos'])): ?>
  <section class="card" style="margin-bottom:1.5rem;">
    <h3 class="section-title" style="margin-bottom:1rem; font-size:1rem;">
      🌐 Boleta — Inglés
    </h3>

    <div style="overflow-x:auto;">
      <table class="data-table">
        <thead>
          <tr>
            <th>Habilidad</th>
            <?php for ($p = 1; $p <= 6; $p++): ?>
              <th style="background:var(--color-primary); color:#fff; min-width:50px;">P<?= $p ?></th>
            <?php endfor; ?>
            <th style="background:var(--color-primary); color:#fff;">T1</th>
            <th style="background:var(--color-primary); color:#fff;">T2</th>
            <th style="background:var(--color-primary); color:#fff;">T3</th>
          </tr>
        </thead>
        <tbody>
          <?php foreach ($boletaIngles['aspectos'] as $asp): ?>
            <tr>
              <td style="font-size:.85rem;"><?= htmlspecialchars($asp['nombre']) ?></td>
              <?php for ($p = 1; $p <= 6; $p++): ?>
                <?php $cal = $asp['calificaciones'][$p] ?? null; ?>
                <td style="text-align:center; font-size:.85rem; <?= ($cal !== null && $cal < 6) ? 'color:#991b1b; font-weight:600;' : '' ?>">
                  <?= $cal ?? (in_array($p, $boletaIngles['periodosAbiertos']) ? '—' : '') ?>
                </td>
              <?php endfor; ?>
              <?php for ($t = 1; $t <= 3; $t++): ?>
                <?php $prom = $asp['trimestres'][$t] ?? null; ?>
                <td style="text-align:center; font-size:.85rem; font-weight:600; background:#f8fafc; <?= ($prom !== null && $prom < 6) ? 'color:#991b1b;' : 'color:var(--color-primary);' ?>">
                  <?= $prom ?? '—' ?>
                </td>
              <?php endfor; ?>
            </tr>
          <?php endforeach; ?>
        </tbody>
      </table>
    </div>
  </section>
  <?php endif; ?>

  <div class="alert alert--info" style="margin-top:1.5rem; text-align:center;">
    <div style="display: grid; grid-template-columns: repeat(<?= $alumno['seccion'] === 'secundaria' ? '3' : '2' ?>, 1fr); gap: 1rem;">
      
      <div>
        <strong>📅 TOTAL DE AUSENCIAS</strong><br>
        <span style="font-size: 1.8rem; font-weight: bold; color: #92400e;"><?= $totalAusencias ?></span><br>
        <small class="form-hint">días faltados en el ciclo</small>
      </div>

      <div>
        <strong>⚖️ PROMEDIO DE DISCIPLINA</strong><br>
        <span style="font-size: 1.8rem; font-weight: bold; color: #065f46;"><?= number_format($promedioDisciplina, 1) ?></span><br>
        <small class="form-hint">calificación 0-10</small>
      </div>

      <?php if ($alumno['seccion'] === 'secundaria'): ?>
      <div>
        <strong>🧼 PROMEDIO DE HIGIENE</strong><br>
        <span style="font-size: 1.8rem; font-weight: bold; color: #1d4ed8;"><?= number_format($promedioHigiene, 1) ?></span><br>
        <small class="form-hint">calificación 0-10</small>
      </div>
      <?php endif; ?>

    </div>
  </div>

  <div class="form-hint" style="text-align: center; margin-top: 1rem;">
    📌 P = Periodo (1-6) | T = Trimestre (1-3)
    <?php if ($totalAusencias > 0): ?>
      <span style="margin-left: 1rem;">⚠️ Total de ausencias: <?= $totalAusencias ?> días</span>
    <?php endif; ?>
  </div>

  <?php endif; ?>
</main>

<?php include __DIR__ . '/../includes/footer.php'; ?>