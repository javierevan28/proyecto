<?php
// padre/mis_hijos.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/UserModel.php';
require_once __DIR__ . '/../models/PadreModel.php';
require_once __DIR__ . '/../models/AlumnoModel.php';
requireRol([2]);

$db          = getConexion();
$userModel   = new UserModel($db);
$padreModel  = new PadreModel($db, $userModel);
$alumnoModel = new AlumnoModel($db, $userModel);

$padre = $padreModel->obtenerPorUserId((int)$_SESSION['user_id']);
$hijos = $padre ? $alumnoModel->obtenerPorPadreId((int)$padre['id']) : [];

$pageTitle = 'Portal de Padres';
$backLink  = '';
include __DIR__ . '/../includes/header.php';
?>

<main class="container">

  <?php if ($padre): ?>
    <p class="alert alert--info">
      👋 Bienvenido/a,
      <strong>
        <?= htmlspecialchars($padre['nombre'] . ' ' . $padre['apellido_paterno']) ?>
      </strong>
    </p>
  <?php endif; ?>

  <h2 class="section-title">
    Mis hijos (<?= count($hijos) ?>)
  </h2>

  <?php if (empty($hijos)): ?>
    <p class="empty-state">
      Aún no tienes alumnos vinculados a tu cuenta.<br>
      Contacta al administrador del sistema.
    </p>

  <?php else: ?>
    <section class="children-grid" aria-label="Lista de hijos">

      <?php foreach ($hijos as $hijo): ?>
        <article class="child-card">

          <div class="child-card__avatar" aria-hidden="true">
            <?= $hijo['genero'] === 'femenino' ? '👧' : '👦' ?>
          </div>

          <h3 class="child-card__name">
            <?= htmlspecialchars(
              $hijo['nombre'] . ' ' .
              $hijo['apellido_paterno'] . ' ' .
              ($hijo['apellido_materno'] ?? '')
            ) ?>
          </h3>

          <p class="child-card__dato">
            <strong>Usuario:</strong> <?= htmlspecialchars($hijo['username']) ?>
          </p>
          <p class="child-card__dato">
            <strong>Grado:</strong> <?= $hijo['grado'] ?>°
            &nbsp;
            <strong>Grupo:</strong> <?= $hijo['grupo'] ?>
          </p>
          <p class="child-card__dato">
            <strong>Sección:</strong> <?= ucfirst($hijo['seccion']) ?>
          </p>
          <p class="child-card__dato">
            <strong>Género:</strong> <?= ucfirst($hijo['genero']) ?>
          </p>

          <?php
            $edad = (int) date_diff(
              date_create($hijo['fecha_nacimiento']),
              date_create()
            )->y;
          ?>
          <p class="child-card__dato">
            <strong>Edad:</strong> <?= $edad ?> años
          </p>

          <span class="badge">Estudiante</span>

          <!-- Botón boleta — va al final de cada tarjeta -->
          <a class="btn btn--sm btn--accent"
             href="boleta.php?alumno_id=<?= $hijo['id'] ?>"
             style="margin-top:.8rem; display:inline-block;">
            Ver boleta
          </a>

        </article>
      <?php endforeach; ?>

    </section>
  <?php endif; ?>

</main>

<?php include __DIR__ . '/../includes/footer.php'; ?>