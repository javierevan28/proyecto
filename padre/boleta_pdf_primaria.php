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
    if ($formacion[$p] == '—') $formacion[$p] = getCalif($porCampo, 'F.C.E.', $p);
    
    $educacion_fisica[$p] = getCalif($porCampo, 'Educación Física', $p);
    $vida_saludable[$p] = getCalif($porCampo, 'Vida Saludable', $p);
    if ($vida_saludable[$p] == '—') $vida_saludable[$p] = getCalif($porCampo, 'Vida', $p);
    
    $socioemocional[$p] = getCalif($porCampo, 'Socioemocional', $p);
    $ingles[$p] = getCalif($porCampo, 'Inglés', $p);
    $artes[$p] = getCalif($porCampo, 'Artes', $p);
}

// Obtener calificaciones de Música y Danza directamente
$musica = array_fill(1, 6, '—');
$danza = array_fill(1, 6, '—');

foreach ($porCampo as $campo => $materias) {
    if (empty($materias)) continue;
    foreach ($materias as $m) {
        $nombre = $m['materia_nombre'] ?? '';
        // Buscar Música
        if (strpos($nombre, 'Música') !== false || strpos($nombre, 'Musica') !== false) {
            for ($p = 1; $p <= 6; $p++) {
                $val = $m['calificaciones'][$p] ?? null;
                if ($val !== null && $val !== '') $musica[$p] = round($val);
            }
        }
        // Buscar Danza
        if (strpos($nombre, 'Danza') !== false) {
            for ($p = 1; $p <= 6; $p++) {
                $val = $m['calificaciones'][$p] ?? null;
                if ($val !== null && $val !== '') $danza[$p] = round($val);
            }
        }
    }
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

// Calcular promedios por trimestre y campo
function promTrim($vals, $p1, $p2) {
    $a = $vals[$p1] ?? '—';
    $b = $vals[$p2] ?? '—';
    if ($a === '—' && $b === '—') return '—';
    $sum = 0; $n = 0;
    if ($a !== '—') { $sum += $a; $n++; }
    if ($b !== '—') { $sum += $b; $n++; }
    return $n ? round($sum / $n) : '—';
}

function promAnual($vals) {
    $sum = 0; $n = 0;
    for ($p = 1; $p <= 6; $p++) {
        if (isset($vals[$p]) && $vals[$p] !== '—') { $sum += $vals[$p]; $n++; }
    }
    return $n ? round($sum / $n) : '—';
}

function promCampoTrim($arr1, $arr2, $arr3, $p1, $p2) {
    $vals = [];
    foreach ([$arr1, $arr2, $arr3] as $arr) {
        $a = $arr[$p1] ?? '—';
        $b = $arr[$p2] ?? '—';
        if ($a !== '—') $vals[] = $a;
        if ($b !== '—') $vals[] = $b;
    }
    return count($vals) ? round(array_sum($vals) / count($vals)) : '—';
}

function promCampoAnual($arr1, $arr2, $arr3) {
    $vals = [];
    foreach ([$arr1, $arr2, $arr3] as $arr) {
        for ($p = 1; $p <= 6; $p++) {
            if (isset($arr[$p]) && $arr[$p] !== '—') $vals[] = $arr[$p];
        }
    }
    return count($vals) ? round(array_sum($vals) / count($vals)) : '—';
}

$lenguajesT1   = promCampoTrim($lengua, $ingles, $artes, 1, 2);
$lenguajesT2   = promCampoTrim($lengua, $ingles, $artes, 3, 4);
$lenguajesT3   = promCampoTrim($lengua, $ingles, $artes, 5, 6);
$lenguajesProm = promCampoAnual($lengua, $ingles, $artes);

$saberesT1   = promCampoTrim($matematicas, $ciencias, $tecnologia, 1, 2);
$saberesT2   = promCampoTrim($matematicas, $ciencias, $tecnologia, 3, 4);
$saberesT3   = promCampoTrim($matematicas, $ciencias, $tecnologia, 5, 6);
$saberesProm = promCampoAnual($matematicas, $ciencias, $tecnologia);

$eticaT1   = promTrim($formacion, 1, 2);
$eticaT2   = promTrim($formacion, 3, 4);
$eticaT3   = promTrim($formacion, 5, 6);
$eticaProm = promAnual($formacion);

$humanoT1   = promCampoTrim($educacion_fisica, $vida_saludable, $socioemocional, 1, 2);
$humanoT2   = promCampoTrim($educacion_fisica, $vida_saludable, $socioemocional, 3, 4);
$humanoT3   = promCampoTrim($educacion_fisica, $vida_saludable, $socioemocional, 5, 6);
$humanoProm = promCampoAnual($educacion_fisica, $vida_saludable, $socioemocional);

$html = '<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<title>Boleta - ' . htmlspecialchars($alumno['nombre'] ?? '') . '</title>
<style>
body {
    font-family: Arial, sans-serif;
    margin: 0;
    padding: 0;
    background: white;
}
.boleta {
    width: 100%;
    background: white;
    padding: 6px;
    border: 2px solid #1c2c4c;
    box-sizing: border-box;
}
.logo { width: 95px; }
.titulo { text-align: center; padding: 0 10px; }
.titulo h1 { margin: 0 0 2px 0; font-size: 17px; color: #1c2c4c; }
.titulo h3 { margin: 2px 0; font-size: 11px; color: #555; letter-spacing: 1px; font-weight: normal; }
.titulo h2 {
    background: #1c2c4c; color: white;
    display: inline-block; padding: 4px 16px;
    border-radius: 5px; margin-top: 3px; font-size: 14px;
}
.label-badge {
    background: #1c2c4c; color: white;
    padding: 3px 10px; border-radius: 20px;
    font-size: 11px; display: inline-block;
    margin-right: 5px; white-space: nowrap;
}
.badge {
    background: #1c2c4c; color: white;
    padding: 3px 10px; border-radius: 20px;
    font-size: 11px; display: inline-block;
    white-space: nowrap;
}
.tabla {
    width: 100%;
    border-collapse: collapse;
    table-layout: fixed;
}
.tabla th, .tabla td {
    border: 1px solid #444;
    padding: 3px 2px;
    text-align: center;
    font-size: 9px;
}
.tabla thead { background: #eaeaea; }
.small { width: 100%; border-collapse: collapse; }
.small th, .small td {
    border: 1px solid #444;
    padding: 3px 2px;
    text-align: center;
    font-size: 9px;
}
.small thead { background: #eaeaea; }
</style>
</head>
<body>
<div class="boleta">

<!-- HEADER -->
<table width="100%" cellpadding="0" cellspacing="0" style="margin-bottom:6px;">
<tr>
    <td width="105" valign="middle"><img src="' . $logoBase64 . '" class="logo"></td>
    <td valign="middle" class="titulo">
        <h1>SECCIÓN PRIMARIA</h1>
        <h3>CICLO ESCOLAR ' . htmlspecialchars($cicloActivo['nombre']) . '</h3>
        <h2>BOLETA DE ESPAÑOL</h2>
    </td>
    <td width="105"></td>
</tr>
</table>

<!-- INFO -->
<table width="100%" cellpadding="0" cellspacing="0" style="margin-bottom:8px;">
<tr>
    <td width="75%" valign="middle">
        <table cellpadding="0" cellspacing="0">
        <tr>
            <td style="padding:3px 0;" valign="middle">
                <span class="label-badge">Nombre del alumno:</span>
                ' . htmlspecialchars($alumno['nombre'] . ' ' . $alumno['apellido_paterno'] . ' ' . ($alumno['apellido_materno'] ?? '')) . '
            </td>
        </tr>
        <tr>
            <td style="padding:3px 0;" valign="middle">
                <span class="label-badge">Profesor(a):</span>
                ' . htmlspecialchars($nombreProfesor) . '
            </td>
        </tr>
        </table>
    </td>
    <td valign="middle" align="right">
        <span class="badge">Grado: ' . $alumno['grado'] . '°</span>
        &nbsp;&nbsp;
        <span class="badge">Grupo: ' . $alumno['grupo'] . '</span>
    </td>
</tr>
</table>

<!-- TABLA PRINCIPAL -->
<table class="tabla">
<thead>
<tr>
    <th rowspan="3" style="width:50px;">Periodo</th>
    <th colspan="10">CAMPOS FORMATIVOS</th>
    <th rowspan="3">Disciplina</th>
    <th rowspan="3">Ausencias</th>
</tr>
<tr>
    <th colspan="3">Lenguajes</th>
    <th colspan="3">Saberes y Pensamiento Científico</th>
    <th>Ética, Naturaleza y Sociedades</th>
    <th colspan="3">De lo Humano y lo Comunitario</th>
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
        <td>Periodo ' . $p . '</td>
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

<!-- TABLAS ABAJO -->
<table width="100%" cellpadding="0" cellspacing="0" style="margin-top:10px;">
<tr>
<td width="49%" valign="top">
<table class="small">
<thead>
<tr><th>ARTES</th><th>P1</th><th>P2</th><th>P3</th><th>P4</th><th>P5</th><th>P6</th></tr>
</thead>
<tbody>
<tr>
    <td>Artes</td>
    <td>' . ($artes[1] ?? '—') . '</td>
    <td>' . ($artes[2] ?? '—') . '</td>
    <td>' . ($artes[3] ?? '—') . '</td>
    <td>' . ($artes[4] ?? '—') . '</td>
    <td>' . ($artes[5] ?? '—') . '</td>
    <td>' . ($artes[6] ?? '—') . '</td>
</tr>
<tr>
    <td>Música</td>
    <td>' . ($musica[1] ?? '—') . '</td>
    <td>' . ($musica[2] ?? '—') . '</td>
    <td>' . ($musica[3] ?? '—') . '</td>
    <td>' . ($musica[4] ?? '—') . '</td>
    <td>' . ($musica[5] ?? '—') . '</td>
    <td>' . ($musica[6] ?? '—') . '</td>
</tr>
<tr>
    <td>Danza</td>
    <td>' . ($danza[1] ?? '—') . '</td>
    <td>' . ($danza[2] ?? '—') . '</td>
    <td>' . ($danza[3] ?? '—') . '</td>
    <td>' . ($danza[4] ?? '—') . '</td>
    <td>' . ($danza[5] ?? '—') . '</td>
    <td>' . ($danza[6] ?? '—') . '</td>
</tr>
</tbody>
</table>
</td>
<td width="2%"></td>
<td width="49%" valign="top">
<table class="small">
<thead>
<tr>
    <th>Campo</th>
    <th>Trimestre 1</th><th>Trimestre 2</th><th>Trimestre 3</th><th>Promedio</th>
</tr>
</thead>
<tbody>
<tr>
    <td>Lenguajes</td>
    <td>' . $lenguajesT1 . '</td>
    <td>' . $lenguajesT2 . '</td>
    <td>' . $lenguajesT3 . '</td>
    <td>' . $lenguajesProm . '</td>
</tr>
<tr>
    <td>Saberes y Pensamiento Científico</td>
    <td>' . $saberesT1 . '</td>
    <td>' . $saberesT2 . '</td>
    <td>' . $saberesT3 . '</td>
    <td>' . $saberesProm . '</td>
</tr>
<tr>
    <td>Ética, Naturaleza y Sociedades</td>
    <td>' . $eticaT1 . '</td>
    <td>' . $eticaT2 . '</td>
    <td>' . $eticaT3 . '</td>
    <td>' . $eticaProm . '</td>
</tr>
<tr>
    <td>De lo Humano y lo Comunitario</td>
    <td>' . $humanoT1 . '</td>
    <td>' . $humanoT2 . '</td>
    <td>' . $humanoT3 . '</td>
    <td>' . $humanoProm . '</td>
</tr>
</tbody>
</table>
</td>
</tr>
</table>

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