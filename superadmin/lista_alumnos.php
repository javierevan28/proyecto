<?php
// superadmin/lista_alumnos.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/UserModel.php';
require_once __DIR__ . '/../models/AlumnoModel.php';
requireRol([1]);

$db          = getConexion();
$alumnoModel = new AlumnoModel($db, new UserModel($db));
$alumnos     = $alumnoModel->listarTodos();

// Variables para el partial de cabecera
$pageTitle = 'Superadmin › Alumnos';
$backLink  = 'dashboard.php';
include __DIR__ . '/../includes/header.php';
?>

<main class="container">
  <h2 class="section-title">
    Alumnos registrados (<?= count($alumnos) ?>)
  </h2>

  <!-- Tabla de alumnos -->
  <table class="data-table">
    <thead>
      <tr>
        <th scope="col">#</th>
        <th scope="col">Nombre completo</th>
        <th scope="col">Usuario</th>
        <th scope="col">Grado</th>
        <th scope="col">Grupo</th>
        <th scope="col">Sección</th>
        <th scope="col">Padre / Tutor</th>
      </tr>
    </thead>
    <tbody>
      <?php if (empty($alumnos)): ?>
        <tr class="empty-row">
          <td colspan="7">Sin alumnos registrados aún</td>
        </tr>
      <?php else: ?>
        <?php foreach ($alumnos as $i => $a): ?>
          <tr>
            <td><?= $i + 1 ?></td>
            <td>
              <?= htmlspecialchars(
                $a['apellido_paterno'] . ' ' .
                ($a['apellido_materno'] ?? '') . ', ' .
                $a['nombre']
              ) ?>
            </td>
            <td>
              <span class="badge"><?= htmlspecialchars($a['username']) ?></span>
            </td>
            <td><?= $a['grado'] ?>°</td>
            <td><?= $a['grupo'] ?></td>
            <td>
              <span class="badge badge--warn"><?= ucfirst($a['seccion']) ?></span>
            </td>
            <td><?= htmlspecialchars($a['nombre_padre']) ?></td>
          </tr>
        <?php endforeach; ?>
      <?php endif; ?>
    </tbody>
  </table>
</main>

<?php include __DIR__ . '/../includes/footer.php'; ?>