<?php
// padre/boleta_pdf_ingles.php
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
if (!$padre) { die('Access denied'); }

$cicloActivo = $cicloModelo->obtenerActivo();
$alumnoId    = (int)($_GET['alumno_id'] ?? 0);

$hijos = $alumnoModel->obtenerPorPadreId((int)$padre['id']);
$alumnoValido = false;
foreach ($hijos as $h) {
    if ((int)$h['id'] === $alumnoId) { $alumnoValido = true; break; }
}

if (!$alumnoValido || !$cicloActivo) {
    die('Access denied');
}

$boleta = $boletaModel->obtenerBoleta($alumnoId, (int)$cicloActivo['id']);

$alumno           = $boleta['alumno']           ?? [];
$porCampo         = $boleta['porCampo']         ?? [];
$periodosAbiertos = $boleta['periodosAbiertos'] ?? [];

// ============================================================
// OBTENER SOLO MATERIAS DE INGLES
// ============================================================
$listening = array_fill(1, 6, '—');
$speaking  = array_fill(1, 6, '—');
$writing   = array_fill(1, 6, '—');
$reading   = array_fill(1, 6, '—');
$vocabulary = array_fill(1, 6, '—');
$grammar   = array_fill(1, 6, '—');
$spelling  = array_fill(1, 6, '—');
$science   = array_fill(1, 6, '—');

foreach ($porCampo as $campo => $materias) {
    foreach ($materias as $m) {
        $nombre = $m['materia_nombre'] ?? '';
        $nombreLower = strtolower($nombre);
        
        for ($p = 1; $p <= 6; $p++) {
            $val = $m['calificaciones'][$p] ?? null;
            $cal = ($val !== null && $val !== '') ? round($val) : '—';
            
            if (strpos($nombreLower, 'listening') !== false) {
                $listening[$p] = $cal;
            } elseif (strpos($nombreLower, 'speaking') !== false) {
                $speaking[$p] = $cal;
            } elseif (strpos($nombreLower, 'writing') !== false) {
                $writing[$p] = $cal;
            } elseif (strpos($nombreLower, 'reading') !== false) {
                $reading[$p] = $cal;
            } elseif (strpos($nombreLower, 'vocabulary') !== false) {
                $vocabulary[$p] = $cal;
            } elseif (strpos($nombreLower, 'grammar') !== false) {
                $grammar[$p] = $cal;
            } elseif (strpos($nombreLower, 'spelling') !== false) {
                $spelling[$p] = $cal;
            } elseif (strpos($nombreLower, 'science') !== false) {
                $science[$p] = $cal;
            }
        }
    }
}

// ============================================================
// CALCULAR PROMEDIOS POR PERIODO
// ============================================================
$promediosPeriodo = array_fill(1, 6, '—');
for ($p = 1; $p <= 6; $p++) {
    $suma = 0;
    $count = 0;
    $materiasPeriodo = [$listening[$p], $speaking[$p], $writing[$p], $reading[$p], $vocabulary[$p], $grammar[$p], $spelling[$p], $science[$p]];
    foreach ($materiasPeriodo as $val) {
        if ($val !== '—' && $val !== null) {
            $suma += $val;
            $count++;
        }
    }
    $promediosPeriodo[$p] = $count > 0 ? round($suma / $count) : '—';
}

// ============================================================
// CALCULAR TRIMESTRES
// ============================================================
function calcTrimestreIngles($p1, $p2) {
    if ($p1 !== '—' && $p2 !== '—') {
        return round(($p1 + $p2) / 2);
    }
    if ($p1 !== '—') return $p1;
    if ($p2 !== '—') return $p2;
    return '—';
}

function calcPromedioFinal($arr) {
    $suma = 0;
    $count = 0;
    for ($p = 1; $p <= 6; $p++) {
        if ($arr[$p] !== '—' && $arr[$p] !== null) {
            $suma += $arr[$p];
            $count++;
        }
    }
    return $count > 0 ? round($suma / $count) : '—';
}

$trim1 = calcTrimestreIngles($promediosPeriodo[1], $promediosPeriodo[2]);
$trim2 = calcTrimestreIngles($promediosPeriodo[3], $promediosPeriodo[4]);
$trim3 = calcTrimestreIngles($promediosPeriodo[5], $promediosPeriodo[6]);
$promedioFinal = calcPromedioFinal($promediosPeriodo);

// ============================================================
// PROFESOR TITULAR
// ============================================================
$nombreProfesor = 'Not assigned';
$stmt = $db->prepare("
    SELECT p.nombre, p.apellido_paterno 
    FROM asignacion_maestros am
    JOIN profesores p ON p.id = am.profesor_id
    JOIN asignaciones a ON a.id = am.asignacion_id
    WHERE a.ciclo_id = ? 
      AND a.seccion = ? 
      AND a.grado = ? 
      AND a.grupo = ? 
      AND am.es_titular = 1
    LIMIT 1
");
if ($stmt) {
    $stmt->bind_param('isis', $cicloActivo['id'], $alumno['seccion'], $alumno['grado'], $alumno['grupo']);
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
<html lang="en">
<head>
<meta charset="UTF-8">
<title>English Report Card - ' . htmlspecialchars($alumno['nombre'] ?? '') . '</title>
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
        <h1>ELEMENTARY SCHOOL</h1>
        <h3>SCHOOL YEAR ' . htmlspecialchars($cicloActivo['nombre']) . '</h3>
        <h2>ENGLISH REPORT CARD</h2>
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
                <span class="label-badge">Student\'s Name:</span>
                ' . htmlspecialchars($alumno['nombre'] . ' ' . $alumno['apellido_paterno'] . ' ' . ($alumno['apellido_materno'] ?? '')) . '
            </td>
        </tr>
        <tr>
            <td style="padding:3px 0;" valign="middle">
                <span class="label-badge">Teacher\'s Name:</span>
                ' . htmlspecialchars($nombreProfesor) . '
            </td>
        </tr>
        </table>
    </td>
    <td valign="middle" align="right">
        <span class="badge">Grade: ' . $alumno['grado'] . '°</span>
        &nbsp;&nbsp;
        <span class="badge">Group: ' . $alumno['grupo'] . '</span>
    </td>
</tr>
</table>

<!-- TABLA PRINCIPAL -->
<table class="tabla">
<thead>
<tr>
    <th style="width:8%;">Period</th>
    <th>Listening</th>
    <th>Speaking</th>
    <th>Writing</th>
    <th>Reading</th>
    <th>Vocabulary</th>
    <th>Grammar</th>
    <th>Spelling</th>
    <th>Science</th>
</tr>
</thead>
<tbody>';

for ($p = 1; $p <= 6; $p++) {
    $html .= '<tr>
        <td><strong>Period ' . $p . '</strong></td>
        <td>' . ($listening[$p] ?? '—') . '</td>
        <td>' . ($speaking[$p] ?? '—') . '</td>
        <td>' . ($writing[$p] ?? '—') . '</td>
        <td>' . ($reading[$p] ?? '—') . '</td>
        <td>' . ($vocabulary[$p] ?? '—') . '</td>
        <td>' . ($grammar[$p] ?? '—') . '</td>
        <td>' . ($spelling[$p] ?? '—') . '</td>
        <td>' . ($science[$p] ?? '—') . '</td>
    </tr>';
}

$html .= '<tr style="background:#f0f9ff; font-weight:700;">
    <td style="background:#1c2c4c; color:white;">Average</td>';
for ($p = 1; $p <= 6; $p++) {
    $html .= '<td>' . ($promediosPeriodo[$p] ?? '—') . '</td>';
}
$html .= '</tr>';

$html .= '</tbody>
</table>

<!-- TABLAS ABAJO -->
<table width="100%" cellpadding="0" cellspacing="0" style="margin-top:10px;">
<tr>
<td width="49%" valign="top">
<table class="small">
<thead>
<tr><th>Period</th><th>P1</th><th>P2</th><th>P3</th><th>P4</th><th>P5</th><th>P6</th></tr>
</thead>
<tbody>
<tr>
    <td><strong>Average</strong></td>
    <td>' . ($promediosPeriodo[1] ?? '—') . '</td>
    <td>' . ($promediosPeriodo[2] ?? '—') . '</td>
    <td>' . ($promediosPeriodo[3] ?? '—') . '</td>
    <td>' . ($promediosPeriodo[4] ?? '—') . '</td>
    <td>' . ($promediosPeriodo[5] ?? '—') . '</td>
    <td>' . ($promediosPeriodo[6] ?? '—') . '</td>
</tr>
</tbody>
</table>
</td>
<td width="2%"></td>
<td width="49%" valign="top">
<table class="small">
<thead>
<tr><th>Trimestre</th><th>Trimestre 1</th><th>Trimestre 2</th><th>Trimestre 3</th><th>Average</th></tr>
</thead>
<tbody>
<tr>
    <td><strong>Average</strong></td>
    <td>' . $trim1 . '</td>
    <td>' . $trim2 . '</td>
    <td>' . $trim3 . '</td>
    <td>' . $promedioFinal . '</td>
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
    $dompdf->stream("English_Report_Card_" . $alumno['matricula'] . ".pdf", array("Attachment" => true));
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
?>