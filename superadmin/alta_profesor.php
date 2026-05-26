<?php
// superadmin/alta_profesor.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/UserModel.php';
require_once __DIR__ . '/../models/ProfesorModel.php';
requireRol([1]);

$db            = getConexion();
$userModel     = new UserModel($db);
$profesorModel = new ProfesorModel($db, $userModel);

$resultado = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $resultado = $profesorModel->crear($_POST);
}

$pageTitle = 'Superadmin › Alta de profesor';
$backLink  = 'dashboard.php';
include __DIR__ . '/../includes/header.php';
?>

<main class="container container--sm">
  <section class="card">
    <h2 class="section-title">Registrar profesor</h2>

    <?php if ($resultado): ?>
      <?php if (isset($resultado['success'])): ?>
        <p class="alert alert--success" role="status">
          ✅ <strong>Profesor registrado correctamente.</strong><br>
          Usuario: <strong><?= htmlspecialchars($resultado['username']) ?></strong><br>
          <small>La contraseña es igual al usuario.</small>
        </p>
      <?php else: ?>
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
          <span class="form-hint">Déjalo vacío si solo tiene un apellido</span>
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

        <!-- Tipo de maestro -->
        <div class="form-group full">
          <label for="tipo">Tipo de maestro *</label>
          <select id="tipo" name="tipo" required>
            <option value="">Selecciona…</option>
            <option value="titular"
              <?= (($_POST['tipo'] ?? '') === 'titular') ? 'selected' : '' ?>>
              Titular (Español / Inglés)
            </option>
            <option value="frances"
              <?= (($_POST['tipo'] ?? '') === 'frances') ? 'selected' : '' ?>>
              Francés
            </option>
            <option value="cocurricular"
              <?= (($_POST['tipo'] ?? '') === 'cocurricular') ? 'selected' : '' ?>>
              Cocurricular (Artes, Danza, Música, Ed. Física, Tecnología)
            </option>
          </select>
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

        <!-- Fecha de nacimiento -->
        <div class="form-group">
          <label for="fecha_nacimiento">Fecha de nacimiento *</label>
          <input
            type="date" id="fecha_nacimiento" name="fecha_nacimiento"
            value="<?= htmlspecialchars($_POST['fecha_nacimiento'] ?? '') ?>"
            required
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

        <!-- Teléfono -->
        <div class="form-group">
          <label for="telefono">Teléfono</label>
          <input
            type="tel" id="telefono" name="telefono"
            value="<?= htmlspecialchars($_POST['telefono'] ?? '') ?>"
            maxlength="20"
          >