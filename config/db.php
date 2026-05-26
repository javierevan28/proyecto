<?php
// config/db.php  – Ajusta host, user, pass y dbname
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_NAME', 'escuela');

function getConexion(): mysqli {
    $conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
    if ($conn->connect_error) {
        die(json_encode(['error' => 'Conexión fallida: ' . $conn->connect_error]));
    }
    $conn->set_charset('utf8mb4');
    return $conn;
}