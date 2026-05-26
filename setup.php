<?php
require_once __DIR__ . '/config/db.php';

$db   = getConexion();
$hash = password_hash('superadmin', PASSWORD_DEFAULT);

$stmt = $db->prepare("UPDATE users SET password_hash = ? WHERE username = 'superadmin'");
$stmt->bind_param('s', $hash);

if ($stmt->execute()) {
    echo "✅ Listo. Usuario: <b>superadmin</b> / Contraseña: <b>superadmin</b><br>";
    echo "Hash generado: " . $hash . "<br><br>";
    echo "<a href='login.php'>Ir al login</a>";
} else {
    echo "❌ Error: " . $db->error;
}
?>