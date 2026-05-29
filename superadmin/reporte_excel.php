<?php
// superadmin/reporte_excel.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/CicloModel.php';
require_once __DIR__ . '/../models/ReporteModel.php';
require_once __DIR__ . '/../vendor/autoload.php';
requireRol([1]);

use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use PhpOffice\PhpSpreadsheet\Style\Fill;
use PhpOffice\PhpSpreadsheet\Style\Alignment;
use PhpOffice\PhpSpreadsheet\Style\Border;

$db            = getConexion();
$cicloModelo   = new CicloModel($db);
$reporteModelo = new ReporteModel($db);

$cicloActivo = $cicloModelo->obtenerActivo();
if (!$cicloActivo) { header('Location: reportes.php'); exit; }

$grupoSel   = $_GET['grupo_sel']  ?? '';
$vista      = $_GET['vista']      ?? 'trimestre';
$agrupacion = $_GET['agrupacion'] ?? 'campo';
$seleccion  = $_GET['seleccion']  ?? 'todos';

if (!$grupoSel) { header('Location: reportes.php'); exit; }

[$seccion, $grado, $grupo] = explode('|', $grupoSel);
$grado = (int)$grado;

$reporte = $reporteModelo->obtenerReporte(
    (int)$cicloActivo['id'],
    $seccion, $grado, $grupo,
    $vista, $agrupacion, $seleccion
);

$alumnos          = $reporte['alumnos'];
$encabezados      = $reporte['encabezados'];
$colsSeleccionadas= $reporte['colsSeleccionadas'];
$etiquetasCols    = $reporte['etiquetasCols'];

// ── Crear Excel ───────────────────────────────────────────────
$spreadsheet = new Spreadsheet();
$sheet       = $spreadsheet->getActiveSheet();
$sheet->setTitle('Reporte');

// Estilos
$estiloTitulo = [
    'font'      => ['bold' => true, 'size' => 12, 'color' => ['rgb' => 'FFFFFF']],
    'fill'      => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['rgb' => '1e3a5f']],
    'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER],
];
$estiloHeader = [
    'font'      => ['bold' => true, 'color' => ['rgb' => 'FFFFFF']],
    'fill'      => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['rgb' => '1e3a5f']],
    'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER],
    'borders'   => ['allBorders' => ['borderStyle' => Border::BORDER_THIN, 'color' => ['rgb' => 'FFFFFF']]],
];
$estiloSubheader = [
    'font'      => ['bold' => true, 'color' => ['rgb' => '1e3a5f']],
    'fill'      => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['rgb' => 'dbeafe']],
    'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER],
    'borders'   => ['allBorders' => ['borderStyle' => Border::BORDER_THIN]],
];
$estiloPromedio = [
    'font'      => ['bold' => true, 'color' => ['rgb' => 'FFFFFF']],
    'fill'      => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['rgb' => '065f46']],
    'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER],
];
$estiloDato = [
    'borders'   => ['allBorders' => ['borderStyle' => Border::BORDER_THIN]],
    'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER],
];
$estiloReprobado = [
    'font'   => ['bold' => true, 'color' => ['rgb' => '991b1b']],
    'borders'=> ['allBorders' => ['borderStyle' => Border::BORDER_THIN]],
    'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER],
];

$nCols = count($colsSeleccionadas);

// ── Fila 1: título ────────────────────────────────────────────
$totalCols = 1 + (count($encabezados) * $nCols) + 1;
$letraFin  = \PhpOffice\PhpSpreadsheet\Cell\Coordinate::stringFromColumnIndex($totalCols);

$titulo = 'Reporte — ' . ucfirst($seccion) . ' ' . $grado . '° ' . $grupo
        . ' | Ciclo: ' . $cicloActivo['nombre']
        . ' | ' . ($agrupacion === 'campo' ? 'Por campo formativo' : 'Por materia')
        . ' | ' . ($seleccion === 'todos'
            ? ($vista === 'periodo' ? 'Todos los periodos' : 'Todos los trimestres')
            : ($vista === 'periodo' ? 'Periodo ' : 'Trimestre ') . $seleccion);

$sheet->mergeCells('A1:' . $letraFin . '1');
$sheet->setCellValue('A1', $titulo);
$sheet->getStyle('A1')->applyFromArray($estiloTitulo);
$sheet->getRowDimension(1)->setRowHeight(20);

// ── Fila 2: encabezados de columnas (materia/campo) ───────────
$sheet->setCellValue('A2', 'Alumno');
$sheet->getStyle('A2')->applyFromArray($estiloHeader);
$sheet->mergeCells('A2:A3'); // rowspan 2

$col = 2;
foreach ($encabezados as $enc) {
    $letraInicio = \PhpOffice\PhpSpreadsheet\Cell\Coordinate::stringFromColumnIndex($col);
    $letraFin2   = \PhpOffice\PhpSpreadsheet\Cell\Coordinate::stringFromColumnIndex($col + $nCols - 1);
    $sheet->mergeCells($letraInicio . '2:' . $letraFin2 . '2');
    $sheet->setCellValue($letraInicio . '2', $enc['label']);
    $sheet->getStyle($letraInicio . '2:' . $letraFin2 . '2')->applyFromArray($estiloHeader);
    $col += $nCols;
}

// Encabezado promedio
$letraPromedio = \PhpOffice\PhpSpreadsheet\Cell\Coordinate::stringFromColumnIndex($col);
$sheet->mergeCells($letraPromedio . '2:' . $letraPromedio . '3');
$sheet->setCellValue($letraPromedio . '2', 'Promedio');
$sheet->getStyle($letraPromedio . '2:' . $letraPromedio . '3')->applyFromArray($estiloPromedio);

// ── Fila 3: P1/T1 etc por cada columna ───────────────────────
$col = 2;
foreach ($encabezados as $enc) {
    foreach ($etiquetasCols as $lbl) {
        $letra = \PhpOffice\PhpSpreadsheet\Cell\Coordinate::stringFromColumnIndex($col);
        $sheet->setCellValue($letra . '3', $lbl);
        $sheet->getStyle($letra . '3')->applyFromArray($estiloSubheader);
        $col++;
    }
}

// ── Filas de datos desde fila 4 ───────────────────────────────
$fila = 4;
foreach ($alumnos as $al) {
    $sheet->setCellValue('A' . $fila,
        $al['apellido_paterno'] . ' ' . ($al['apellido_materno'] ?? '') . ', ' . $al['nombre']
    );
    $sheet->getStyle('A' . $fila)->applyFromArray($estiloDato);

    $col = 2;
    foreach ($al['columnas'] as $columna) {
        foreach ($columna['valor'] as $v) {
            $letra = \PhpOffice\PhpSpreadsheet\Cell\Coordinate::stringFromColumnIndex($col);
            $sheet->setCellValue($letra . $fila, $v ?? '');
            $estilo = ($v !== null && $v < 6) ? $estiloReprobado : $estiloDato;
            $sheet->getStyle($letra . $fila)->applyFromArray($estilo);
            $col++;
        }
    }

    // Promedio general
    $letraP = \PhpOffice\PhpSpreadsheet\Cell\Coordinate::stringFromColumnIndex($col);
    $prom   = $al['promedio_general'];
    $sheet->setCellValue($letraP . $fila, $prom ?? '');
    $sheet->getStyle($letraP . $fila)->applyFromArray(
        ($prom !== null && $prom < 6) ? $estiloReprobado : [
            'font'      => ['bold' => true, 'color' => ['rgb' => '065f46']],
            'fill'      => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['rgb' => 'f0fdf4']],
            'borders'   => ['allBorders' => ['borderStyle' => Border::BORDER_THIN]],
            'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER],
        ]
    );

    $fila++;
}

// Autofit columnas
$sheet->getColumnDimension('A')->setWidth(30);
for ($c = 2; $c <= $totalCols; $c++) {
    $sheet->getColumnDimensionByColumn($c)->setAutoSize(true);
}

// Freeze panes — congelar primera columna y primeras 3 filas
$sheet->freezePane('B4');

// ── Descargar ─────────────────────────────────────────────────
$nombreArchivo = 'reporte_' . $seccion . '_' . $grado . $grupo
               . '_' . $vista . '_' . $seleccion . '.xlsx';

header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
header('Content-Disposition: attachment; filename="' . $nombreArchivo . '"');
header('Cache-Control: max-age=0');

$writer = new Xlsx($spreadsheet);
$writer->save('php://output');
exit;