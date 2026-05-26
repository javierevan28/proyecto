<?php
// superadmin/lista_padres.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/UserModel.php';
require_once __DIR__ . '/../models/PadreModel.php';
requireRol([1]);

$db         = getConexion();
$padreModel = new PadreModel($db, new UserModel($db));
$padres     = $padreModel->listarTodos();

// Variables para el partial de cabecera
$pageTitle = 'Superadmin › Padres / Tutores';
$backLink  = 'dashboard.php';
include __DIR__ . '/../includes/header.php';
?>

<main class="container">
  <h2 class="section-title">
    Padres / Tutores registrados (<?= count($padres) ?>)
  </h2>

  <!-- Tabla de padres registrados -->
  <table class="data-table">
    <thead>
      <tr>
        <th scope="col">#</th>
        <th scope="col">Nombre completo</th>
        <th scope="col">Usuario</th>
        <th scope="col">Teléfono</th>
        <th scope="col">Correo</th>
        <th scope="col">Género</th>
        <th scope="col">Registrado</th>
      </tr>
    </thead>
    <tbody>
      <?php if (empty($padres)): ?>
        <tr class="empty-row">
          <td colspan="7">Sin registros aún</td>
        </tr>
      <?php else: ?>
        <?php foreach ($padres as $i => $p): ?>
          <tr>
            <td><?= $i + 1 ?></td>
            <td>
              <?= htmlspecialchars(
                $p['apellido_paterno'] . ' ' .
                ($p['apellido_materno'] ?? '') . ', ' .
                $p['nombre']
              ) ?>
            </td>
            <td>
              <span class="badge"><?= htmlspecialchars($p['username']) ?></span>
            </td>
            <td><?= htmlspecialchars($p['telefono']) ?></td>
            <td><?= htmlspecialchars($p['correo'] ?? '—') ?></td>
            <td><?= ucfirst($p['genero']) ?></td>
            <td><?= date('d/m/Y', strtotime($p['creado_en'])) ?></td>
          </tr>
        <?php endforeach; ?>
      <?php endif; ?>
    </tbody>
  </table>
</main>

<?php include __DIR__ . '/../includes/footer.php'; ?>