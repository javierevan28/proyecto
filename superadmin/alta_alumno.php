<?php
// superadmin/alta_alumno.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/UserModel.php';
require_once __DIR__ . '/../models/AlumnoModel.php';
requireRol([1]);

$db          = getConexion();
$userModel   = new UserModel($db);
$alumnoModel = new AlumnoModel($db, $userModel);

// Cargar lista de padres activos para el selector
$padres    = [];
$resPadres = $db->query("
    SELECT p.id, p.nombre, p.apellido_paterno, p.apellido_materno
    FROM   padres p
    JOIN   users  u ON u.id = p.user_id AND u.activo = 1
    ORDER  BY p.apellido_paterno, p.nombre
");
while ($row = $resPadres->fetch_assoc()) {
    $padres[] = $row;
}

$resultado = null;
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $resultado = $alumnoModel->crear($_POST);
}

// Variables para el partial de cabecera
$pageTitle = 'Superadmin › Alta de alumno';
$backLink  = 'dashboard.php';
include __DIR__ . '/../includes/header.php';
?>

<main class="container container--md">
  <section class="card">
    <h2 class="section-title">Registrar alumno</h2>

    <?php if ($resultado): ?>
      <?php if (isset($resultado['success'])): ?>
        <!-- Alta exitosa -->
        <p class="alert alert--success" role="status">
          ✅ <strong>Alumno registrado correctamente.</strong><br>
          Usuario: <strong><?= htmlspecialchars($resultado['username']) ?></strong>
          &nbsp;(contraseña igual al usuario)
        </p>
      <?php else: ?>
        <!-- Error -->
        <p class="alert alert--error" role="alert">
          ⚠️ <?= htmlspecialchars($resultado['error']) ?>
        </p>
      <?php endif; ?>
    <?php endif; ?>

    <?php if (empty($padres)): ?>
      <!-- Sin padres registrados: no se puede dar alta un alumno aún -->
      <p class="alert alert--error" role="alert">
        ⚠️ No hay padres/tutores registrados aún.
        <a href="alta_padre.php">Registra uno primero</a>.
      </p>

    <?php else: ?>
      <form method="POST" novalidate>
        <div class="form-grid">

          <!-- Apellido paterno -->
          <div class="form-group">
            <label for="apellido_paterno">Apellido paterno *</label>
            <input
              type="text" id="apellido_paterno" name="apellido_paterno"
              value="<?= htmlspecialchars($_POST['apellido_paterno'] ?? '') ?>"
              required maxlength="60"
            >
          </div>

          <!-- Apellido materno -->
          <div class="form-group">
            <label for="apellido_materno">Apellido materno</label>
            <input
              type="text" id="apellido_materno" name="apellido_materno"
              value="<?= htmlspecialchars($_POST['apellido_materno'] ?? '') ?>"
              maxlength="60"
            >
          </div>

          <!-- Nombre(s) -->
          <div class="form-group full">
            <label for="nombre">Nombre(s) *</label>
            <input
              type="text" id="nombre" name="nombre"
              value="<?= htmlspecialchars($_POST['nombre'] ?? '') ?>"
              required maxlength="100"
            >
          </div>

          <!-- CURP -->
          <div class="form-group">
            <label for="curp">CURP</label>
            <input
              type="text" id="curp" name="curp"
              value="<?= htmlspecialchars($_POST['curp'] ?? '') ?>"
              maxlength="18"
            >
          </div>

          <!-- Fecha de nacimiento -->
          <div class="form-group">
            <label for="fecha_nacimiento">Fecha de nacimiento *</label>
            <input
              type="date" id="fecha_nacimiento" name="fecha_nacimiento"
              value="<?= htmlspecialchars($_POST['fecha_nacimiento'] ?? '') ?>"
              required
            >
          </div>

          <!-- Género -->
          <div class="form-group">
            <label for="genero">Género *</label>
            <select id="genero" name="genero" required>
              <option value="">Selecciona…</option>
              <?php foreach (['masculino' => 'Masculino', 'femenino' => 'Femenino', 'otro' => 'Otro'] as $val => $lbl): ?>
                <option value="<?= $val ?>" <?= (($_POST['genero'] ?? '') === $val) ? 'selected' : '' ?>>
                  <?= $lbl ?>
                </option>
              <?php endforeach; ?>
            </select>
          </div>

          <!-- Sección -->
          <div class="form-group">
            <label for="seccion">Sección *</label>
            <select id="seccion" name="seccion" required>
              <option value="">Selecciona…</option>
              <?php foreach (['maternal', 'preescolar', 'primaria', 'secundaria'] as $sec): ?>
                <option value="<?= $sec ?>" <?= (($_POST['seccion'] ?? '') === $sec) ? 'selected' : '' ?>>
                  <?= ucfirst($sec) ?>
                </option>
              <?php endforeach; ?>
            </select>
          </div>

          <!-- Grado -->
          <div class="form-group">
            <label for="grado">Grado *</label>
            <select id="grado" name="grado" required>
              <option value="">Selecciona…</option>
              <?php for ($i = 1; $i <= 6; $i++): ?>
                <option value="<?= $i ?>" <?= (($_POST['grado'] ?? '') == $i) ? 'selected' : '' ?>>
                  <?= $i ?>°
                </option>
              <?php endfor; ?>
            </select>
          </div>

          <!-- Grupo -->
          <div class="form-group">
            <label for="grupo">Grupo *</label>
            <select id="grupo" name="grupo" required>
              <option value="">Selecciona…</option>
              <?php foreach (['A', 'B', 'C', 'D'] as $grp): ?>
                <option value="<?= $grp ?>" <?= (($_POST['grupo'] ?? '') === $grp) ? 'selected' : '' ?>>
                  <?= $grp ?>
                </option>
              <?php endforeach; ?>
            </select>
          </div>

          <!-- Padre / tutor -->
          <div class="form-group full">
            <label for="padre_id">Padre / tutor *</label>
            <select id="padre_id" name="padre_id" required>
              <option value="">Selecciona el padre o tutor…</option>
              <?php foreach ($padres as $p): ?>
                <option value="<?= $p['id'] ?>"
                  <?= (($_POST['padre_id'] ?? '') == $p['id']) ? 'selected' : '' ?>>
                  <?= htmlspecialchars(
                    $p['apellido_paterno'] . ' ' .
                    ($p['apellido_materno'] ?? '') . ', ' .
                    $p['nombre']
                  ) ?>
                </option>
              <?php endforeach; ?>
            </select>
          </div>

        </div><!-- /.form-grid -->

        <button class="btn" type="submit">Registrar alumno</button>
      </form>
    <?php endif; ?>

  </section>
</main>

<?php include __DIR__ . '/../includes/footer.php'; ?>