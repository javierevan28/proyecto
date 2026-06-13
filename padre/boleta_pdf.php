<?php
// padre/boleta_pdf_primaria.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/UserModel.php';
require_once __DIR__ . '/../models/PadreModel.php';
require_once __DIR__ . '/../models/AlumnoModel.php';
require_once __DIR__ . '/../models/CicloModel.php';
require_once __DIR__ . '/../models/BoletaModel.php';
require_once __DIR__ . '/../vendor/autoload.php';

use Dompdf\Dompdf;
use Dompdf\Options;

error_reporting(E_ALL);
ini_set('display_errors', 1);

requireRol([2]);

$db          = getConexion();
$padreModel  = new PadreModel($db, new UserModel($db));
$alumnoModel = new AlumnoModel($db, new UserModel($db));
$cicloModelo = new CicloModel($db);
$boletaModel = new BoletaModel($db);

$padre = $padreModel->obtenerPorUserId((int)$_SESSION['user_id']);
if (!$padre) { die('Acceso denegado'); }

$cicloActivo = $cicloModelo->obtenerActivo();
$alumnoId    = (int)($_GET['alumno_id'] ?? 0);

$hijos = $alumnoModel->obtenerPorPadreId((int)$padre['id']);
$alumnoValido = false;
foreach ($hijos as $h) {
    if ((int)$h['id'] === $alumnoId) { $alumnoValido = true; break; }
}

if (!$alumnoValido || !$cicloActivo) {
    die('Acceso denegado');
}

$boleta = $boletaModel->obtenerBoleta($alumnoId, (int)$cicloActivo['id']);
$alumno = $boleta['alumno'] ?? [];
$porCampo = $boleta['porCampo'] ?? [];

function getCalif($materias, $nombre, $periodo) {
    if (empty($materias)) return '—';
    $nombreBuscar = strtolower(trim($nombre));
    foreach ($materias as $campo => $lista) {
        if (empty($lista)) continue;
        foreach ($lista as $m) {
            $nombreMateria = strtolower(trim($m['materia_nombre']));
            if ($nombreMateria == $nombreBuscar || 
                strpos($nombreMateria, $nombreBuscar) !== false ||
                strpos($nombreBuscar, $nombreMateria) !== false) {
                $val = $m['calificaciones'][$periodo] ?? null;
                return ($val !== null && $val !== '') ? round($val) : '—';
            }
        }
    }
    return '—';
}

for ($p = 1; $p <= 6; $p++) {
    $lengua[$p] = getCalif($porCampo, 'Lengua Materna', $p);
    if ($lengua[$p] == '—') $lengua[$p] = getCalif($porCampo, 'Español', $p);
    
    $matematicas[$p] = getCalif($porCampo, 'Matemáticas', $p);
    if ($matematicas[$p] == '—') $matematicas[$p] = getCalif($porCampo, 'Matem', $p);
    
    $ciencias[$p] = getCalif($porCampo, 'Ciencias Naturales', $p);
    if ($ciencias[$p] == '—') $ciencias[$p] = getCalif($porCampo, 'Ciencia', $p);
    
    $tecnologia[$p] = getCalif($porCampo, 'Tecnología', $p);
    if ($tecnologia[$p] == '—') $tecnologia[$p] = getCalif($porCampo, 'Tecnolog', $p);
    
    $formacion[$p] = getCalif($porCampo, 'F.C. y E.', $p);
    if ($formacion[$p] == '—') $formacion[$p] = getCalif($porCampo, 'Formación', $p);
    
    $educacion_fisica[$p] = getCalif($porCampo, 'Educación Física', $p);
    $vida_saludable[$p] = getCalif($porCampo, 'Vida Saludable', $p);
    $socioemocional[$p] = getCalif($porCampo, 'Socioemocional', $p);
    $ingles[$p] = getCalif($porCampo, 'Inglés', $p);
    $artes[$p] = getCalif($porCampo, 'Artes', $p);
    $musica[$p] = getCalif($porCampo, 'Música', $p);
    $danza[$p] = getCalif($porCampo, 'Danza', $p);
}

$disciplina = array_fill(1, 6, '—');
$ausencias = array_fill(1, 6, '—');
$stmt = $db->prepare("SELECT periodo, disciplina, ausencias FROM calificaciones_titular WHERE alumno_id = ? AND ciclo_id = ? ORDER BY periodo");
if ($stmt) {
    $stmt->bind_param('ii', $alumnoId, $cicloActivo['id']);
    $stmt->execute();
    $res = $stmt->get_result();
    while ($row = $res->fetch_assoc()) {
        $disciplina[$row['periodo']] = $row['disciplina'] ?? '—';
        $ausencias[$row['periodo']] = $row['ausencias'] ?? '—';
    }
}

$nombreProfesor = 'Por asignar';
$stmt = $db->prepare("SELECT p.nombre, p.apellido_paterno FROM grupo_titular gt JOIN profesores p ON gt.profesor_id = p.id WHERE gt.ciclo_id = ? AND gt.grado = ? AND gt.grupo = ? LIMIT 1");
if ($stmt) {
    $stmt->bind_param('iis', $cicloActivo['id'], $alumno['grado'], $alumno['grupo']);
    $stmt->execute();
    $prof = $stmt->get_result()->fetch_assoc();
    if ($prof) {
        $nombreProfesor = $prof['nombre'] . ' ' . $prof['apellido_paterno'];
    }
}

$logoPath = __DIR__ . '/logo.png';
$logoBase64 = '';
if (file_exists($logoPath)) {
    $logoData = base64_encode(file_get_contents($logoPath));
    $logoBase64 = 'data:image/png;base64,' . $logoData;
}

$html = '<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<title>Boleta - ' . htmlspecialchars($alumno['nombre'] ?? '') . '</title>
<style>
    body {
        font-family: Arial, sans-serif;
        margin: 0;
        padding: 20px;
        background: white;
    }
    .boleta {
        max-width: 1200px;
        margin: auto;
        border: 2px solid #1c2c4c;
        border-radius: 10px;
        padding: 15px;
        background: white;
    }
    .header-table {
        width: 100%;
        border-collapse: collapse;
        margin-bottom: 15px;
    }
    .header-table td {
        border: none;
        padding: 5px;
        vertical-align: middle;
    }
    .logo {
        width: 120px;
    }
    .titulo {
        text-align: center;
    }
    .titulo h1 {
        margin: 0;
        font-size: 20px;
        color: #1c2c4c;
    }
    .titulo h2 {
        background: #1c2c4c;
        color: white;
        display: inline-block;
        padding: 5px 20px;
        border-radius: 5px;
        margin: 5px 0;
        font-size: 16px;
    }
    .ciclo {
        font-size: 12px;
        color: #555;
        margin: 0;
    }
    .info-table {
        width: 100%;
        border-collapse: collapse;
        margin-bottom: 15px;
    }
    .info-table td {
        border: none;
        padding: 5px;
        vertical-align: middle;
    }
    .info-label {
        background: #1c2c4c;
        color: white;
        padding: 5px 12px;
        border-radius: 20px;
        font-size: 12px;
        white-space: nowrap;
        width: 1%;
    }
    .badge {
        background: #1c2c4c;
        color: white;
        padding: 5px 12px;
        border-radius: 20px;
        font-size: 12px;
        display: inline-block;
        margin-left: 5px;
    }
    .tabla {
        width: 100%;
        border-collapse: collapse;
        margin-top: 10px;
    }
    .tabla th, .tabla td {
        border: 1px solid #444;
        padding: 4px;
        text-align: center;
        font-size: 10px;
        vertical-align: middle;
    }
    .tabla th {
        background: #eaeaea;
    }
    .vertical {
        writing-mode: vertical-rl;
        text-orientation: mixed;
        white-space: nowrap;
    }
    th.vertical {
        width: 25px;
    }
    .text-left {
        text-align: left;
    }
    @media print {
        @page { size: landscape; margin: 10mm; }
        body { background: white; padding: 0; }
        .boleta { border: none; padding: 5px; }
    }
</style>
</head>
<body>
<div class="boleta">

<!-- HEADER con TABLA -->
<table class="header-table">
    <tr>
        <td style="width: 120px;"><img src="' . $logoBase64 . '" class="logo"></td>
        <td class="titulo">
            <h1>SECCIÓN PRIMARIA</h1>
            <p class="ciclo">CICLO ESCOLAR ' . htmlspecialchars($cicloActivo['nombre']) . '</p>
            <h2>BOLETA DE ESPAÑOL</h2>
        </td>
    </tr>
</table>

<!-- INFO con TABLA -->
<table class="info-table">
    <tr>
        <td class="info-label">Nombre del alumno:</td>
        <td>' . htmlspecialchars($alumno['nombre'] . ' ' . $alumno['apellido_paterno'] . ' ' . ($alumno['apellido_materno'] ?? '')) . '</td>
        <td class="info-label">Grado:</td>
        <td>' . $alumno['grado'] . '°</td>
        <td class="info-label">Grupo:</td>
        <td>' . $alumno['grupo'] . '</td>
    </tr>
    <tr>
        <td class="info-label">Profesor(a):</td>
        <td colspan="5">' . htmlspecialchars($nombreProfesor) . '</td>
    </tr>
</table>

<!-- TABLA PRINCIPAL -->
<table class="tabla">
    <thead>
        <tr>
            <th rowspan="3">Periodo</th>
            <th colspan="3">Lenguajes</th>
            <th colspan="3">Saberes y Pensamiento Científico</th>
            <th>Ética, Naturaleza y Sociedades</th>
            <th colspan="3">De lo Humano y lo Comunitario</th>
            <th rowspan="3" class="vertical">Disciplina</th>
            <th rowspan="3" class="vertical">Ausencias</th>
        </tr>
        <tr>
            <th>Español</th><th>Inglés</th><th>Artes</th>
            <th>Matemáticas</th><th>Ciencias Naturales</th><th>Tecnología</th>
            <th>F.C.E.</th>
            <th>Educación Física</th><th>Vida Saludable</th><th>Socioemocional</th>
        </tr>
    </thead>
    <tbody>';

for ($p = 1; $p <= 6; $p++) {
    $html .= '<tr>
        <td><strong>Periodo ' . $p . '</strong></td>
        <td>' . ($lengua[$p] ?? '—') . '</td>
        <td>' . ($ingles[$p] ?? '—') . '</td>
        <td>' . ($artes[$p] ?? '—') . '</td>
        <td>' . ($matematicas[$p] ?? '—') . '</td>
        <td>' . ($ciencias[$p] ?? '—') . '</td>
        <td>' . ($tecnologia[$p] ?? '—') . '</td>
        <td>' . ($formacion[$p] ?? '—') . '</td>
        <td>' . ($educacion_fisica[$p] ?? '—') . '</td>
        <td>' . ($vida_saludable[$p] ?? '—') . '</td>
        <td>' . ($socioemocional[$p] ?? '—') . '</td>
        <td>' . ($disciplina[$p] ?? '—') . '</td>
        <td>' . ($ausencias[$p] ?? '—') . '</td>
    </tr>';
}

$html .= '</tbody>
</table>

<!-- TABLAS ABAJO (Artes, Música, Danza) -->
<div style="margin-top: 15px;">
    <table class="tabla" style="width: 100%;">
        <thead>
            <tr><th>ARTES</th><th>P1</th><th>P2</th><th>P3</th><th>P4</th><th>P5</th><th>P6</th></tr>
        </thead>
        <tbody>
            <tr><td>Artes</td>
                <td>' . ($artes[1] ?? '—') . '</td>
                <td>' . ($artes[2] ?? '—') . '</td>
                <td>' . ($artes[3] ?? '—') . '</td>
                <td>' . ($artes[4] ?? '—') . '</td>
                <td>' . ($artes[5] ?? '—') . '</td>
                <td>' . ($artes[6] ?? '—') . '</td>
            </tr>
            <tr><td>Música</td>
                <td>' . ($musica[1] ?? '—') . '</td>
                <td>' . ($musica[2] ?? '—') . '</td>
                <td>' . ($musica[3] ?? '—') . '</td>
                <td>' . ($musica[4] ?? '—') . '</td>
                <td>' . ($musica[5] ?? '—') . '</td>
                <td>' . ($musica[6] ?? '—') . '</td>
            </tr>
            <tr><td>Danza</td>
                <td>' . ($danza[1] ?? '—') . '</td>
                <td>' . ($danza[2] ?? '—') . '</td>
                <td>' . ($danza[3] ?? '—') . '</td>
                <td>' . ($danza[4] ?? '—') . '</td>
                <td>' . ($danza[5] ?? '—') . '</td>
                <td>' . ($danza[6] ?? '—') . '</td>
            </tr>
        </tbody>
    </table>
</div>

</div>
</body>
</html>';

try {
    $options = new Options();
    $options->set('defaultFont', 'Arial');
    $options->set('isRemoteEnabled', true);
    $dompdf = new Dompdf($options);
    $dompdf->loadHtml($html);
    $dompdf->setPaper('A4', 'landscape');
    $dompdf->render();
    $dompdf->stream("Boleta_Primaria_" . $alumno['matricula'] . ".pdf", array("Attachment" => true));
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
?>