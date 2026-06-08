<?php
// superadmin/reporte_excel.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/CicloModel.php';
require_once __DIR__ . '/../models/ReporteModel.php';
requireRol([1]);

$db            = getConexion();
$cicloModelo   = new CicloModel($db);
$reporteModelo = new ReporteModel($db);

$cicloActivo = $cicloModelo->obtenerActivo();
if (!$cicloActivo) die('No hay ciclo escolar activo.');

$grupoSel   = $_GET['grupo_sel']  ?? '';
$vista      = $_GET['vista']      ?? 'trimestre';
$agrupacion = $_GET['agrupacion'] ?? 'campo';
$seleccion  = $_GET['seleccion']  ?? 'todos';

if (!$grupoSel) die('Selecciona un grupo.');

[$seccion, $grado, $grupo] = explode('|', $grupoSel);
$grado = (int)$grado;

$reporte = $reporteModelo->obtenerReporte(
    (int)$cicloActivo['id'],
    $seccion, $grado, $grupo,
    $vista, $agrupacion, $seleccion
);

if (!$reporte) die('No hay datos para este grupo.');

$alumnos       = $reporte['alumnos'];
$encabezados   = $reporte['encabezados'];
$etiquetasCols = $reporte['etiquetasCols'];
$nCols         = count($reporte['colsSeleccionadas']);

// Nombre del archivo
$nombreArchivo = sprintf(
    'reporte_%s_%d%s_%s.xls',
    $seccion, $grado, $grupo,
    date('Ymd')
);

// Cabeceras para descarga
header("Content-Type: application/vnd.ms-excel");
header("Content-Disposition: attachment; filename=\"{$nombreArchivo}\"");
header("Pragma: no-cache");
header("Expires: 0");
?>
<table border="1" cellpadding="4" cellspacing="0">

  <!-- Fila 1: encabezados de grupos -->
  <tr>
    <th rowspan="2" style="background:#2d5282; color:#fff; min-width:180px;">No.</th>
    <th rowspan="2" style="background:#2d5282; color:#fff; min-width:180px;">Alumno</th>
    <?php foreach ($encabezados as $enc): ?>
      <th colspan="<?= $nCols ?>" style="background:#2d5282; color:#fff; text-align:center;">
        <?= htmlspecialchars($enc['label']) ?>
      </th>
    <?php endforeach; ?>
    <th rowspan="2" style="background:#065f46; color:#fff; text-align:center;">Promedio</th>
  </tr>

  <!-- Fila 2: sub-encabezados de columnas -->
  <tr>
    <?php foreach ($encabezados as $enc): ?>
      <?php foreach ($etiquetasCols as $lbl): ?>
        <th style="background:#4a6fa5; color:#fff; text-align:center; font-size:11px;">
          <?= htmlspecialchars($lbl) ?>
        </th>
      <?php endforeach; ?>
    <?php endforeach; ?>
  </tr>

  <!-- Filas de alumnos -->
  <?php $numero = 1; ?>
  <?php foreach ($alumnos as $al): ?>
    <tr>
      <td style="text-align:center; font-weight:bold;"><?= $numero++ ?></td>
      <td style="text-align:left;">
        <?= htmlspecialchars($al['apellido_paterno'] . ' ' . ($al['apellido_materno'] ?? '') . ', ' . $al['nombre']) ?>
      </td>

      <?php foreach ($al['columnas'] as $col): ?>
        <?php foreach ($col['valor'] as $v): ?>
          <td style="text-align:center; <?= ($v !== null && $v < 6) ? 'color:#991b1b; font-weight:bold;' : '' ?>">
            <?= $v ?? '—' ?>
          </td>
        <?php endforeach; ?>
      <?php endforeach; ?>

      <td style="text-align:center; font-weight:bold; background:#f0fdf4; color:<?= ($al['promedio_general'] !== null && $al['promedio_general'] < 6) ? '#991b1b' : '#065f46' ?>;">
        <?= $al['promedio_general'] ?? '—' ?>
      </td>
    </tr>
  <?php endforeach; ?>

</tr>