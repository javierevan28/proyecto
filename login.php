<?php
session_start();

if (!empty($_SESSION['user_id'])) {
    header('Location: ' . routeByRole((int)$_SESSION['rol_id']));
    exit;
}

require_once __DIR__ . '/config/db.php';

$error   = '';
$timeout = isset($_GET['timeout']);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = trim($_POST['username'] ?? '');
    $password = trim($_POST['password'] ?? '');

    if ($username === '' || $password === '') {
        $error = 'Ingresa usuario y contraseña';
    } else {
        $db   = getConexion();
        $stmt = $db->prepare(
            "SELECT id, password_hash, rol_id FROM users WHERE username = ? AND activo = 1 LIMIT 1"
        );
        $stmt->bind_param('s', $username);
        $stmt->execute();
        $res  = $stmt->get_result();
        $user = $res->fetch_assoc();

        if ($user && password_verify($password, $user['password_hash'])) {
            session_regenerate_id(true);
            $_SESSION['user_id']       = (int)$user['id'];
            $_SESSION['rol_id']        = (int)$user['rol_id'];
            $_SESSION['username']      = $username;
            $_SESSION['last_activity'] = time();
            header('Location: ' . routeByRole((int)$user['rol_id']));
            exit;
        } else {
            $error = 'Usuario o contraseña incorrectos';
        }
    }
}

function routeByRole(int $rolId): string {
    return match($rolId) {
        1 => '/proyecto/superadmin/dashboard.php',
        2 => '/proyecto/padre/mis_hijos.php',
        4 => '/proyecto/maestro/dashboard.php',
        default => '/proyecto/login.php',
    };
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Iniciar sesión – Sistema Escolar</title>
<style>
  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    font-family: 'Segoe UI', sans-serif;
    background: #f0f4f8;
    display: flex; align-items: center; justify-content: center;
    min-height: 100vh;
  }
  .card {
    background: #fff;
    border-radius: 10px;
    box-shadow: 0 4px 20px rgba(0,0,0,.1);
    padding: 2.5rem 2rem;
    width: 100%; max-width: 380px;
  }
  h1 { font-size: 1.4rem; color: #1e3a5f; margin-bottom: 1.5rem; text-align: center; }
  label { display: block; font-size: .85rem; color: #555; margin-bottom: .3rem; }
  input {
    width: 100%; padding: .65rem .8rem;
    border: 1px solid #ccd3db; border-radius: 6px;
    font-size: .95rem; margin-bottom: 1rem;
  }
  input:focus { outline: none; border-color: #3b82f6; box-shadow: 0 0 0 3px rgba(59,130,246,.15); }
  button {
    width: 100%; padding: .75rem;
    background: #1e3a5f; color: #fff;
    border: none; border-radius: 6px;
    font-size: 1rem; cursor: pointer;
  }
  button:hover { background: #2d5282; }
  .error {
    background: #fee2e2; color: #991b1b;
    padding: .65rem .8rem; border-radius: 6px;
    margin-bottom: 1rem; font-size: .85rem;
  }
  .timeout {
    background: #fef3c7; color: #92400e;
    padding: .65rem .8rem; border-radius: 6px;
    margin-bottom: 1rem; font-size: .85rem;
  }
</style>
</head>
<body>
<div class="card">
  <h1>🏫 Sistema Escolar</h1>

  <?php if ($timeout): ?>
    <div class="timeout">⏱ Tu sesión expiró por inactividad. Vuelve a iniciar sesión.</div>
  <?php endif; ?>

  <?php if ($error): ?>
    <div class="error"><?= htmlspecialchars($error) ?></div>
  <?php endif; ?>

  <form method="POST" action="/proyecto/login.php">
    <label for="username">Usuario</label>
    <input type="text" id="username" name="username"
           value="<?= htmlspecialchars($_POST['username'] ?? '') ?>"
           placeholder="usuario" required autofocus>
    <label for="password">Contraseña</label>
    <input type="password" id="password" name="password"
           placeholder="••••••••" required>
    <button type="submit">Entrar</button>
  </form>
</div>
</body>
</html>
