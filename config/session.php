<?php
// config/session.php

define('SESSION_TIMEOUT', 300); // 5 minutos en segundos

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// Headers anti-cache en TODAS las páginas protegidas
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
header('Pragma: no-cache');
header('Expires: Sat, 01 Jan 2000 00:00:00 GMT');

define('BASE_URL', '/proyecto/');

/**
 * Requiere autenticación y rol válido.
 * Verifica también que la sesión no haya caducado por inactividad.
 */
function requireRol(array $rolesPermitidos): void {
    if (empty($_SESSION['user_id'])) {
        header('Location: ' . BASE_URL . 'login.php');
        exit;
    }

    // Verificar timeout por inactividad
    if (!empty($_SESSION['last_activity'])) {
        $inactivo = time() - $_SESSION['last_activity'];
        if ($inactivo > SESSION_TIMEOUT) {
            $_SESSION = [];
            session_destroy();
            setcookie(session_name(), '', time() - 3600, '/');
            header('Location: ' . BASE_URL . 'login.php?timeout=1');
            exit;
        }
    }

    // Actualizar último acceso
    $_SESSION['last_activity'] = time();

    if (!in_array((int)$_SESSION['rol_id'], $rolesPermitidos, true)) {
        header('Location: ' . BASE_URL . 'login.php');
        exit;
    }
}