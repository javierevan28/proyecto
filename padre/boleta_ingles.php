<?php
// padre/boleta_ingles.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/UserModel.php';
require_once __DIR__ . '/../models/PadreModel.php';
require_once __DIR__ . '/../models/AlumnoModel.php';
require_once __DIR__ . '/../models/CicloModel.php';
require_once __DIR__ . '/../models/BoletaInglesModel.php';
requireRol([2]);

$db = getConexion();
$padreModel = new PadreModel($db, new UserModel($db));
$alumnoModel = new AlumnoModel($db, new UserModel($db));
$cicloModelo = new CicloModel($db);
$boletaInglesModel = new BoletaInglesModel($db);

$padre = $padreModel->obtenerPorUserId((int)$_SESSION['user_id']);
if (!$padre) {
    header('Location: /proyecto/login.php');
    exit;
}

$cicloActivo = $cicloModelo->obtenerActivo();
$alumnoId = (int)($_GET['alumno_id'] ?? 0);

$hijos = $alumnoModel->obtenerPorPadreId((int)$padre['id']);
$alumnoValido = false;
foreach ($hijos as $h) {
    if ((int)$h['id'] === $alumnoId) {
        $alumnoValido = true;
        break;
    }
}

if (!$alumnoValido || !$cicloActivo) {
    header('Location: mis_hijos.php');
    exit;
}

// Obtener datos con el nuevo modelo
$boleta = $boletaInglesModel->obtenerBoletaIngles($alumnoId, (int)$cicloActivo['id']);

$alumno = $boleta['alumno'] ?? [];
$materias = $boleta['materias'] ?? [];
$periodosAbiertos = $boleta['periodosAbiertos'] ?? [];

$pageTitle = 'English Report Card — ' . ($alumno['nombre'] ?? '');
$backLink = 'mis_hijos.php';
$backLabel = '← My children';
include __DIR__ . '/../includes/header.php';
?>

<main class="container">
    <div style="margin-bottom: 20px; text-align: right;">
        <a class="btn btn--sm btn--success" 
           href="boleta_pdf_ingles.php?alumno_id=<?= $alumnoId ?>" 
           target="_blank">
            📄 PDF Report Card
        </a>
    </div>

    <?php if (empty($alumno)): ?>
        <p class="empty-state">Student information not found.</p>
    <?php else: ?>

    <div class="card" style="margin-bottom:1.5rem;">
        <div style="display:flex; justify-content:space-between; align-items:start; flex-wrap:wrap; gap:1rem;">
            <div>
                <h2 style="color:var(--color-primary); font-size:1.2rem; margin-bottom:.3rem;">
                    <?= htmlspecialchars($alumno['nombre'] . ' ' . $alumno['apellido_paterno'] . ' ' . ($alumno['apellido_materno'] ?? '')) ?>
                </h2>
                <p class="form-hint">
                    ID: <strong><?= htmlspecialchars($alumno['matricula'] ?? '—') ?></strong>
                    &nbsp;|&nbsp;
                    <?= ucfirst($alumno['seccion']) ?> — <?= $alumno['grado'] ?>° <?= $alumno['grupo'] ?>
                    &nbsp;|&nbsp;
                    Cycle: <strong><?= htmlspecialchars($cicloActivo['nombre']) ?></strong>
                </p>
            </div>
        </div>
    </div>

    <section class="card">
        <h3 class="section-title" style="margin-bottom:1rem;">📋 English Report Card</h3>

        <?php if (empty($materias)): ?>
            <p class="empty-state">No English subjects found for this student.</p>
        <?php else: ?>

        <div style="overflow-x:auto;">
            <table class="data-table">
                <thead>
                    <tr>
                        <th style="text-align:left; width:30%;">SUBJECT</th>
                        <?php for ($p = 1; $p <= 6; $p++): ?>
                            <th style="text-align:center; min-width:50px;">P<?= $p ?></th>
                        <?php endfor; ?>
                        <th style="text-align:center;">T1</th>
                        <th style="text-align:center;">T2</th>
                        <th style="text-align:center;">T3</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($materias as $m): ?>
                        <tr>
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
                </tbody>
            </table>
        </div>

        <?php if (!empty($periodosAbiertos)): ?>
            <p style="font-size:0.75rem; color:#6c757d; margin-top:1rem; font-style:italic;">
                * Open periods are marked with "—"
            </p>
        <?php endif; ?>

        <?php endif; ?>
    </section>

    <?php endif; ?>
</main>

<?php include __DIR__ . '/../includes/footer.php'; ?>