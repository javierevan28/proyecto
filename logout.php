<?php
    session_start();
    $_SESSION = [];
    session_destroy();
    setcookie(session_name(), '', time() - 3600, '/');

    // Headers para que el navegador no guarde cache y no pueda regresar
    header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
    header('Cache-Control: post-check=0, pre-check=0', false);
    header('Pragma: no-cache');
    header('Location: /proyecto/login.php');
    exit;