<?php
// superadmin/alta_padre.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/UserModel.php';
require_once __DIR__ . '/../models/PadreModel.php';
requireRol([1]);

$db         = getConexion();
$userModel  = new UserModel($db);
$padreModel = new PadreModel($db, $userModel);

$resultado = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $resultado = $padreModel->crear($_POST);
}

// Variables para el partial de cabecera
$pageTitle = 'Superadmin › Alta de padre / tutor';
$backLink  = 'dashboard.php';
include __DIR__ . '/../includes/header.php';
?>

<main class="container container--sm">
  <section class="card">
    <h2 class="section-title">Registrar padre o tutor</h2>

    <?php if ($resultado): ?>
      <?php if (isset($resultado['success'])): ?>
        <!-- Alta exitosa -->
        <p class="alert alert--success" role="status">
          ✅ <strong>Padre registrado correctamente.</strong><br>
          Usuario generado: <strong><?= htmlspecialchars($resultado['username']) ?></strong><br>
          <small>La contraseña es igual al usuario.</small>
        </p>
      <?php else: ?>
        <!-- Error de validación o BD -->
        <p class="alert alert--error" role="alert">
          ⚠️ <?= htmlspecialchars($resultado['error']) ?>
        </p>
      <?php endif; ?>
    <?php endif; ?>

    <form method="POST" novalidate>
      <div class="form-grid">

        <!-- Apellido paterno -->
        <div class="form-group">
          <label for="apellido_paterno">Apellido paterno *</label>
          <input
            type="text" id="apellido_paterno" name="apellido_paterno"
            value="<?= htmlspecialchars($_POST['apellido_paterno'] ?? '') ?>"
            placeholder="Apellido Paterno" required maxlength="60"
          >
        </div>

        <!-- Apellido materno -->
        <div class="form-group">
          <label for="apellido_materno">Apellido materno</label>
          <input
            type="text" id="apellido_materno" name="apellido_materno"
            value="<?= htmlspecialchars($_POST['apellido_materno'] ?? '') ?>"
            placeholder="Apellido Materno (opcional)" maxlength="60"
          >
          <span class="form-hint">Déjalo vacío si solo tiene un apellido</span>
        </div>

        <!-- Nombre(s) – ocupa ambas columnas -->
        <div class="form-group full">
          <label for="nombre">Nombre(s) *</label>
          <input
            type="text" id="nombre" name="nombre"
            value="<?= htmlspecialchars($_POST['nombre'] ?? '') ?>"
            placeholder="Nombre" required maxlength="100"
          >
        </div>

        <!-- Género -->
        <div class="form-group">
          <label for="genero">Género *</label>
          <select id="genero" name="genero" required>
            <option value="">Selecciona…</option>
            <?php foreach (['masculino' => 'Masculino', 'femenino' => 'Femenino', 'otro' => 'Otro'] as $val => $label): ?>
              <option value="<?= $val ?>" <?= (($_POST['genero'] ?? '') === $val) ? 'selected' : '' ?>>
                <?= $label ?>
              </option>
            <?php endforeach; ?>
          </select>
        </div>

        <!-- CURP -->
        <div class="form-group">
          <label for="curp">CURP</label>
          <input
            type="text" id="curp" name="curp"
            value="<?= htmlspecialchars($_POST['curp'] ?? '') ?>"
            placeholder="CURP" maxlength="18"
          >
        </div>

        <!-- Teléfono de contacto -->
        <div class="form-group">
          <label for="telefono">Teléfono de contacto *</label>
          <input
            type="tel" id="telefono" name="telefono"
            value="<?= htmlspecialchars($_POST['telefono'] ?? '') ?>"
            placeholder="10 dígitos" required maxlength="20"
          >
        </div>

        <!-- Teléfono de emergencia -->
        <div class="form-group">
          <label for="telefono_emergencia">Teléfono de emergencia</label>
          <input
            type="tel" id="telefono_emergencia" name="telefono_emergencia"
            value="<?= htmlspecialchars($_POST['telefono_emergencia'] ?? '') ?>"
            placeholder="Teléfono de emergencia" maxlength="20"
          >
        </div>

        <!-- Correo – ocupa ambas columnas -->
        <div class="form-group full">
          <label for="correo">Correo electrónico</label>
          <input
            type="email" id="correo" name="correo"
            value="<?= htmlspecialchars($_POST['correo'] ?? '') ?>"
            placeholder="correo@ejemplo.com" maxlength="120"
          >
        </div>

      </div><!-- /.form-grid -->

      <button class="btn" type="submit">Registrar padre / tutor</button>
    </form>
  </section>
</main>

<?php include __DIR__ . '/../includes/footer.php'; ?>