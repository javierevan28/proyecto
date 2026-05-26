<?php
// maestro/exportar_excel.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/ProfesorModel.php';
require_once __DIR__ . '/../models/UserModel.php';
require_once __DIR__ . '/../models/CicloModel.php';
require_once __DIR__ . '/../models/PeriodoAperturaModel.php';
require_once __DIR__ . '/../models/CalificacionModel.php';
require_once __DIR__ . '/../vendor/autoload.php';
requireRol([4]);

use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use PhpOffice\PhpSpreadsheet\Style\Fill;
use PhpOffice\PhpSpreadsheet\Style\Alignment;
use PhpOffice\PhpSpreadsheet\Style\Border;

$db            = getConexion();
$profModelo    = new ProfesorModel($db, new UserModel($db));
$cicloModelo   = new CicloModel($db);
$periodoModelo = new PeriodoAperturaModel($db);
$calModelo     = new CalificacionModel($db);

$profesor = $profModelo->obtenerPorUserId((int)$_SESSION['user_id']);
if (!$profesor) { header('Location: /proyecto/login.php'); exit; }

$cicloActivo    = $cicloModelo->obtenerActivo();
$periodoAbierto = $cicloActivo ? $periodoModelo->obtenerAbierto((int)$cicloActivo['id']) : null;
if (!$cicloActivo || !$periodoAbierto) { header('Location: dashboard.php'); exit; }

$asignacionId = (int)($_GET['asignacion_id'] ?? 0);
$seccion      = trim($_GET['seccion'] ?? '');
$grado        = (int)($_GET['grado']  ?? 0);
$grupo        = trim($_GET['grupo']   ?? '');
$periodo      = (int)$periodoAbierto['periodo'];
$esIngles     = (int)($_GET['es_ingles'] ?? 0);

if (!$asignacionId || !$seccion || !$grado || !$grupo) {
    header('Location: dashboard.php');
    exit;
}

// Obtener datos
if ($esIngles) {
    $datos    = $calModelo->obtenerAlumnosIngles($asignacionId, $seccion, $grado, $grupo, $periodo);
    $alumnos  = $datos['alumnos'];
    $aspectos = $datos['aspectos'];
} else {
    $alumnos  = $calModelo->obtenerAlumnosConCalificacion($asignacionId, $seccion, $grado, $grupo, $periodo);
    $aspectos = [];
}

// Crear Excel
$spreadsheet = new Spreadsheet();
$sheet       = $spreadsheet->getActiveSheet();
$sheet->setTitle('Calificaciones');

// Estilo encabezado
$estiloHeader = [
    'font'      => ['bold' => true, 'color' => ['rgb' => 'FFFFFF']],
    'fill'      => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['rgb' => '1e3a5f']],
    'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER],
    'borders'   => ['allBorders' => ['borderStyle' => Border::BORDER_THIN]],
];

$estiloData = [
    'borders'   => ['allBorders' => ['borderStyle' => Border::BORDER_THIN]],
    'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER],
];

// Metadatos en las primeras filas (ocultos para importación)
$sheet->setCellValue('A1', 'asignacion_id');
$sheet->setCellValue('B1', $asignacionId);
$sheet->setCellValue('A2', 'periodo');
$sheet->setCellValue('B2', $periodo);
$sheet->setCellValue('A3', 'es_ingles');
$sheet->setCellValue('B3', $esIngles);
$sheet->getRowDimension(1)->setVisible(false);
$sheet->getRowDimension(2)->setVisible(false);
$sheet->getRowDimension(3)->setVisible(false);

// Fila de encabezados (fila 4)
$sheet->setCellValue('A4', '#');
$sheet->setCellValue('B4', 'alumno_id');
$sheet->setCellValue('C4', 'Alumno');
$sheet->setCellValue('D4', 'Matrícula');

if ($esIngles && !empty($aspectos)) {
    $col = 5;
    foreach ($aspectos as $asp) {
        $sheet->setCellValueByColumnAndRow($col, 4, $asp['nombre']);
        $col++;
    }
    $sheet->setCellValueByColumnAndRow($col, 4, 'Promedio');
} else {
    $sheet->setCellValue('E4', 'Calificación');
}

$sheet->getStyle('A4:' . $sheet->getHighestColumn() . '4')->applyFromArray($estiloHeader);

// Datos de alumnos desde fila 5
$fila = 5;
foreach ($alumnos as $i => $al) {
    $sheet->setCellValue('A' . $fila, $i + 1);
    $sheet->setCellValue('B' . $fila, $al['alumno_id']);
    $sheet->setCellValue('C' . $fila, $al['apellido_paterno'] . ' ' . ($al['apellido_materno'] ?? '') . ', ' . $al['nombre']);
    $sheet->setCellValue('D' . $fila, $al['matricula'] ?? '');

    if ($esIngles && !empty($aspectos)) {
        $col  = 5;
        $suma = 0; $count = 0;
        foreach ($aspectos as $asp) {
            $val = $al['aspectos'][$asp['id']] ?? null;
            $sheet->setCellValueByColumnAndRow($col, $fila, $val ?? '');
            if ($val !== null) { $suma += $val; $count++; }
            $col++;
        }
        $promedio = $count > 0 ? round($suma / $count, 1) : '';
        $sheet->setCellValueByColumnAndRow($col, $fila, $promedio);
        // Proteger columna promedio
        $sheet->getCellByColumnAndRow($col, $fila)->getStyle()->getProtection()
              ->setLocked(\PhpOffice\PhpSpreadsheet\Style\Protection::PROTECTION_PROTECTED);
    } else {
        $sheet->setCellValue('E' . $fila, $al['calificacion'] ?? '');
    }

    $sheet->getStyle('A' . $fila . ':' . $sheet->getHighestColumn() . $fila)
          ->applyFromArray($estiloData);

    $fila++;
}

// Proteger columnas no editables (A, B, C, D)
$sheet->getProtection()->setSheet(true);
foreach (['A', 'B', 'C', 'D'] as $colLetra) {
    $sheet->getStyle($colLetra . '5:' . $colLetra . ($fila - 1))
          ->getProtection()
          ->setLocked(\PhpOffice\PhpSpreadsheet\Style\Protection::PROTECTION_PROTECTED);
}

// Autofit columnas
foreach (range('A', $sheet->getHighestColumn()) as $col) {
    $sheet->getColumnDimension($col)->setAutoSize(true);
}

// Descargar
$nombreArchivo = 'calificaciones_' . $seccion . '_' . $grado . $grupo . '_p' . $periodo . '.xlsx';
header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
header('Content-Disposition: attachment; filename="' . $nombreArchivo . '"');
header('Cache-Control: max-age=0');

$writer = new Xlsx($spreadsheet);
$writer->save('php://output');
exit;