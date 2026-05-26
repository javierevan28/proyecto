<?php
// includes/header.php
// Uso:  include __DIR__ . '/../includes/header.php';
//
// Variables que DEBES declarar ANTES de incluir este archivo:
//   $pageTitle  (string)  – Texto del <title> y del breadcrumb del header
//   $backLink   (string)  – URL del enlace "← Volver" (vacío = sin enlace)
//   $backLabel  (string)  – Texto del enlace de regreso (por defecto "← Menú")
//   $cssDepth   (string)  – Ruta relativa al CSS según la profundidad del archivo
//                           ej. '../css/style.css'  (subcarpeta)
//                                'css/style.css'     (raíz)
//
// Ejemplo de uso en superadmin/dashboard.php:
//   $pageTitle = 'Panel – Superadmin';
//   $backLink  = '';
//   $cssDepth  = '../css/style.css';
//   include __DIR__ . '/../includes/header.php';

$backLabel = $backLabel ?? '← Menú';
$backLink  = $backLink  ?? '';
$cssDepth  = $cssDepth  ?? '../css/style.css';
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title><?= htmlspecialchars($pageTitle ?? 'Sistema Escolar') ?></title>
  <link rel="stylesheet" href="/proyecto/css/style.css">
</head>
<body>

<header class="site-header">
  <span class="site-header__title">
    🏫 <?= htmlspecialchars($pageTitle ?? 'Sistema Escolar') ?>
  </span>

  <nav class="site-header__nav" aria-label="Navegación de cabecera">
    <?php if (!empty($_SESSION['username'])): ?>
      <span>Hola, <strong><?= htmlspecialchars($_SESSION['username']) ?></strong></span>
    <?php endif; ?>

    <?php if ($backLink !== ''): ?>
      <a href="<?= htmlspecialchars($backLink) ?>"><?= htmlspecialchars($backLabel) ?></a>
    <?php endif; ?>

    <?php if (!empty($_SESSION['user_id'])): ?>
      <a href="/proyecto/logout.php">Cerrar sesión</a>
    <?php endif; ?>
  </nav>
</header>