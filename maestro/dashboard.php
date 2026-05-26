<?php
// maestro/dashboard.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/ProfesorModel.php';
require_once __DIR__ . '/../models/UserModel.php';
require_once __DIR__ . '/../models/CicloModel.php';
require_once __DIR__ . '/../models/PeriodoAperturaModel.php';
require_once __DIR__ . '/../models/CalificacionModel.php';
requireRol([4]); // rol_id 4 = profesor

$db            = getConexion();
$profModelo    = new ProfesorModel($db, new UserModel($db));
$cicloModelo   = new CicloModel($db);
$periodoModelo = new PeriodoAperturaModel($db);
$calModelo     = new CalificacionModel($db);

$profesor = $profModelo->obtenerPorUserId((int)$_SESSION['user_id']);
if (!$profesor) {
    header('Location: /proyecto/login.php');
    exit;
}

$cicloActivo    = $cicloModelo->obtenerActivo();
$periodoAbierto = $cicloActivo
    ? $periodoModelo->obtenerAbierto((int)$cicloActivo['id'])
    : null;

$grupos = $cicloActivo
    ? $calModelo->obtenerGruposDeProfesor((int)$profesor['id'], (int)$cicloActivo['id'])
    : [];

$pageTitle = 'Portal del Maestro';
$backLink  = '';
include __DIR__ . '/../includes/header.php';
?>

<main class="container">

  <?php if (!$cicloActivo): ?>
    <p class="alert alert--error">⚠️ No hay ciclo escolar activo.</p>
  <?php elseif (!$periodoAbierto): ?>
    <p class="alert alert--info">📋 No hay ningún periodo abierto actualmente. Consulta al administrador.</p>
  <?php else: ?>
    <div class="ciclo-banner" style="margin-bottom:1.5rem;">
      <span class="ciclo-banner__label">
        📅 Ciclo: <strong><?= htmlspecialchars($cicloActivo['nombre']) ?></strong>
        &nbsp;|&nbsp;
        📂 Periodo abierto: <strong>Periodo <?= $periodoAbierto['periodo'] ?></strong>
        — Trimestre <?= (int)ceil($periodoAbierto['periodo'] / 2) ?>
      </span>
    </div>
  <?php endif; ?>

  <h2 class="section-title">
    Bienvenido/a, <?= htmlspecialchars($profesor['nombre'] . ' ' . $profesor['apellido_paterno']) ?>
  </h2>

  <?php if (empty($grupos)): ?>
    <p class="empty-state">No tienes grupos asignados en el ciclo actual.</p>
  <?php else: ?>
    <div class="card-grid">
      <?php foreach ($grupos as $g): ?>
        <a class="nav-card"
           href="captura.php?seccion=<?= $g['seccion'] ?>&grado=<?= $g['grado'] ?>&grupo=<?= $g['grupo'] ?>">
          <span class="nav-card__icon" aria-hidden="true">📚</span>
          <h3 class="nav-card__title">
            <?= ucfirst($g['seccion']) ?> — <?= $g['grado'] ?>° <?= $g['grupo'] ?>
          </h3>
          <p class="nav-card__desc">Ver materias y capturar calificaciones</p>
        </a>
      <?php endforeach; ?>
    </div>
  <?php endif; ?>

</main>

<?php include __DIR__ . '/../includes/footer.php'; ?>
