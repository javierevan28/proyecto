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

// Verificar que el alumno es hijo del padre
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

// Encontrar asignación de inglés para la boleta de inglés
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

$pageTitle = 'Boleta — ' . ($alumno['nombre'] ?? '');
$backLink  = 'mis_hijos.php';
$backLabel = '← Mis hijos';
include __DIR__ . '/../includes/header.php';
?>

<main class="container">

  <?php if (empty($alumno)): ?>
    <p class="empty-state">No se encontró información del alumno.</p>
  <?php else: ?>

  <!-- Encabezado de la boleta -->
  <div class="card" style="margin-bottom:1.5rem;">
    <div style="display:flex; justify-content:space-between; align-items:start; flex-wrap:wrap; gap:1rem;">
      <div>
        <h2 style="color:var(--color-primary); font-size:1.2rem; margin-bottom:.3rem;">
          <?= htmlspecialchars($alumno['nombre'] . ' ' . $alumno['apellido_paterno'] . ' ' . ($alumno['apellido_materno'] ?? '')) ?>
        </h2>
        <p style="font-size:.85rem; color:var(--color-muted);">
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

  <!-- ── BOLETA ESPAÑOL ─────────────────────────────────────── -->
  <section class="card" style="margin-bottom:1.5rem;">
    <h3 style="color:var(--color-primary); margin-bottom:1rem; font-size:1rem;">
      📋 Boleta — Español
    </h3>

    <div style="overflow-x:auto;">
      <table class="data-table">
        <thead>
          <tr>
            <th>Campo formativo</th>
            <th>Materia</th>
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
              <?php if ((int)$m['es_ingles']) continue; // Inglés va en su propia boleta ?>
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
                    <span style="font-size:.75rem; color:var(--color-muted);">(<?= htmlspecialchars($m['subcomponente']) ?>)</span>
                  <?php endif; ?>
                </td>
                <?php for ($p = 1; $p <= 6; $p++): ?>
                  <?php $cal = $m['calificaciones'][$p] ?? null; ?>
                  <td style="text-align:center; font-size:.85rem;
                             <?= ($cal !== null && $cal < 6) ? 'color:#991b1b; font-weight:600;' : '' ?>">
                    <?= $cal ?? (in_array($p, $periodosAbiertos) ? '—' : '') ?>
                  </td>
                <?php endfor; ?>
                <?php for ($t = 1; $t <= 3; $t++): ?>
                  <?php $prom = $m['trimestres'][$t] ?? null; ?>
                  <td style="text-align:center; font-size:.85rem; font-weight:600; background:#f8fafc;
                             <?= ($prom !== null && $prom < 6) ? 'color:#991b1b;' : 'color:var(--color-primary);' ?>">
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

  <!-- ── BOLETA INGLÉS ──────────────────────────────────────── -->
  <?php if ($boletaIngles && !empty($boletaIngles['aspectos'])): ?>
  <section class="card">
    <h3 style="color:var(--color-primary); margin-bottom:1rem; font-size:1rem;">
      🌐 Boleta — Inglés
    </h3>

    <div style="overflow-x:auto;">
      <table class="data-table">
        <thead>
          <tr>
            <th>Habilidad</th>
            <?php for ($p = 1; $p <= 6; $p++): ?>
              <th style="text-align:center; min-width:50px;">P<?= $p ?></th>
            <?php endfor; ?>
            <th style="text-align:center;">T1</th>
            <th style="text-align:center;">T2</th>
            <th style="text-align:center;">T3</th>
          </tr>
        </thead>
        <tbody>
          <?php foreach ($boletaIngles['aspectos'] as $asp): ?>
            <tr>
              <td style="font-size:.85rem;"><?= htmlspecialchars($asp['nombre']) ?></td>
              <?php for ($p = 1; $p <= 6; $p++): ?>
                <?php $cal = $asp['calificaciones'][$p] ?? null; ?>
                <td style="text-align:center; font-size:.85rem;
                           <?= ($cal !== null && $cal < 6) ? 'color:#991b1b; font-weight:600;' : '' ?>">
                  <?= $cal ?? (in_array($p, $boletaIngles['periodosAbiertos']) ? '—' : '') ?>
                </td>
              <?php endfor; ?>
              <?php for ($t = 1; $t <= 3; $t++): ?>
                <?php $prom = $asp['trimestres'][$t] ?? null; ?>
                <td style="text-align:center; font-size:.85rem; font-weight:600; background:#f8fafc;
                           <?= ($prom !== null && $prom < 6) ? 'color:#991b1b;' : 'color:var(--color-primary);' ?>">
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

  <?php endif; ?>
</main>

<?php include __DIR__ . '/../includes/footer.php'; ?>