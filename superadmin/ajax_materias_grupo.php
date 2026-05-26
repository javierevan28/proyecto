<?php
// superadmin/ajax_materias_grupo.php
// Devuelve JSON con las materias activas y los profesores por tipo
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/MateriaModel.php';
require_once __DIR__ . '/../models/ProfesorModel.php';
require_once __DIR__ . '/../models/UserModel.php';
requireRol([1]);

header('Content-Type: application/json');

$db            = getConexion();
$materiaModelo = new MateriaModel($db);
$profModelo    = new ProfesorModel($db, new UserModel($db));

$materias = $materiaModelo->listarActivas();

// Profesores agrupados por tipo
$titulares     = $profModelo->listarActivosPorTipo('titular');
$frances       = $profModelo->listarActivosPorTipo('frances');
$cocurriculares = $profModelo->listarActivosPorTipo('cocurricular');

echo json_encode([
    'materias'       => $materias,
    'titulares'      => $titulares,
    'frances'        => $frances,
    'cocurriculares' => $cocurriculares,
]);