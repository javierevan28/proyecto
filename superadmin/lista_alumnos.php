<?php
// superadmin/lista_alumnos.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/UserModel.php';
require_once __DIR__ . '/../models/AlumnoModel.php';
requireRol([1]);

$db          = getConexion();
$alumnoModel = new AlumnoModel($db, new UserModel($db));

$filtroEstatus = $_GET['estatus'] ?? '';
$alumnos = $alumnoModel->listarTodos();

if ($filtroEstatus) {
    $alumnos = array_filter($alumnos, function($a) use ($filtroEstatus) {
        return ($a['estatus'] ?? 'regular') === $filtroEstatus;
    });
}

$pageTitle = 'Superadmin › Alumnos';
$backLink  = 'dashboard.php';
include __DIR__ . '/../includes/header.php';
?>

<main class="container">
  <h2 class="section-title">
    Alumnos registrados (<?= count($alumnos) ?>)
  </h2>

  <!-- Filtro por estatus -->
  <div class="card" style="margin-bottom: 1rem; padding: 1rem;">
    <form method="GET" style="display: flex; gap: 1rem; align-items: center; flex-wrap: wrap;">
      <div class="form-group" style="margin-bottom: 0;">
        <label for="estatus">Filtrar por estatus</label>
        <select name="estatus" id="estatus" onchange="this.form.submit()">
          <option value="">Todos</option>
          <option value="nuevo_ingreso" <?= $filtroEstatus === 'nuevo_ingreso' ? 'selected' : '' ?>>🆕 Nuevo Ingreso</option>
          <option value="reinscripcion" <?= $filtroEstatus === 'reinscripcion' ? 'selected' : '' ?>>🔄 Reinscripción</option>
          <option value="regular" <?= $filtroEstatus === 'regular' ? 'selected' : '' ?>>✅ Regular</option>
          <option value="baja" <?= $filtroEstatus === 'baja' ? 'selected' : '' ?>>❌ Baja</option>
        </select>
      </div>
      <?php if ($filtroEstatus): ?>
        <a href="lista_alumnos.php" class="btn btn--sm btn--muted">Limpiar filtro</a>
      <?php endif; ?>
    </form>
  </div>

  <table class="data-table">
    <thead>
      <tr>
        <th>#</th>
        <th>Nombre completo</th>
        <th>Usuario</th>
        <th>Grado</th>
        <th>Grupo</th>
        <th>Sección</th>
        <th>Estatus</th>
        <th>Padre / Tutor</th>
        <th>Acciones</th>
      </tr>
    </thead>
    <tbody>
      <?php if (empty($alumnos)): ?>
        <tr class="empty-row">
          <td colspan="9">Sin alumnos registrados aún</td>
        </tr>
      <?php else: ?>
        <?php foreach ($alumnos as $i => $a): ?>
          <?php
            $estatus = $a['estatus'] ?? 'regular';
            $badgeClass = match($estatus) {
                'nuevo_ingreso' => 'badge--success',
                'reinscripcion' => 'badge--accent',
                'regular' => 'badge--active',
                'baja' => 'badge--warn',
                default => ''
            };
            $estatusTexto = match($estatus) {
                'nuevo_ingreso' => '🆕 Nuevo Ingreso',
                'reinscripcion' => '🔄 Reinscripción',
                'regular' => '✅ Regular',
                'baja' => '❌ Baja',
                default => ucfirst($estatus)
            };
          ?>
          <tr>
            <td><?= $i + 1 ?></td>
            <td><?= htmlspecialchars($a['apellido_paterno'] . ' ' . ($a['apellido_materno'] ?? '') . ', ' . $a['nombre']) ?></td>
            <td><span class="badge"><?= htmlspecialchars($a['username']) ?></span></td>
            <td><?= $a['grado'] ?>°</td>
            <td><?= $a['grupo'] ?></td>
            <td><span class="badge badge--warn"><?= ucfirst($a['seccion']) ?></span></td>
            <td><span class="badge <?= $badgeClass ?>"><?= $estatusTexto ?></span></td>
            <td><?= htmlspecialchars($a['nombre_padre']) ?></td>
            <td class="table-actions">
              <a href="cambiar_estatus_alumno.php?id=<?= $a['id'] ?>" class="btn btn--sm btn--accent">Cambiar Estatus</a>
            </td>
          </tr>
        <?php endforeach; ?>
      <?php endif; ?>
    </tbody>
  </table>
</main>

<?php include __DIR__ . '/../includes/footer.php'; ?>