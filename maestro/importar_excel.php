<?php
// maestro/importar_excel.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/ProfesorModel.php';
require_once __DIR__ . '/../models/UserModel.php';
require_once __DIR__ . '/../models/CicloModel.php';
require_once __DIR__ . '/../models/PeriodoAperturaModel.php';
require_once __DIR__ . '/../models/CalificacionModel.php';
require_once __DIR__ . '/../vendor/autoload.php';
requireRol([4]);

use PhpOffice\PhpSpreadsheet\IOFactory;

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

$asignacionId = (int)($_POST['asignacion_id'] ?? 0);
$periodo      = (int)($_POST['periodo']       ?? 0);
$esIngles     = (int)($_POST['es_ingles']     ?? 0);

if (!$asignacionId || !$periodo || empty($_FILES['archivo_excel']['tmp_name'])) {
    header('Location: dashboard.php');
    exit;
}

$error     = '';
$resultado = null;

try {
    $archivo     = $_FILES['archivo_excel']['tmp_name'];
    $spreadsheet = IOFactory::load($archivo);
    $sheet       = $spreadsheet->getActiveSheet();

    // Leer metadatos de filas ocultas (1-3)
    $asigIdExcel  = (int)$sheet->getCell('B1')->getValue();
    $periodoExcel = (int)$sheet->getCell('B2')->getValue();
    $esInglesExcel = (int)$sheet->getCell('B3')->getValue();

    // Verificar que el Excel corresponde a esta asignación y periodo
    if ($asigIdExcel !== $asignacionId || $periodoExcel !== $periodo) {
        $error = 'El archivo no corresponde a esta materia o periodo. Descarga el Excel correcto.';
    } else {
        $highestRow = $sheet->getHighestRow();
        $calificaciones = [];

        if ($esInglesExcel) {
            // Leer encabezados de aspectos (fila 4 desde columna E)
            $aspectosCols = [];
            $col = 5;
            while (true) {
                $header = $sheet->getCellByColumnAndRow($col, 4)->getValue();
                if (!$header || $header === 'Promedio') break;
                $aspectosCols[$col] = $header;
                $col++;
            }

            // Obtener IDs de aspectos por nombre
            $stmtAsp = $db->prepare(
                "SELECT id, nombre FROM asignacion_ingles_aspectos WHERE asignacion_id = ? AND activo = 1"
            );
            $stmtAsp->bind_param('i', $asignacionId);
            $stmtAsp->execute();
            $resAsp  = $stmtAsp->get_result();
            $aspPorNombre = [];
            while ($row = $resAsp->fetch_assoc()) {
                $aspPorNombre[$row['nombre']] = (int)$row['id'];
            }

            // Leer calificaciones fila por fila desde fila 5
            for ($fila = 5; $fila <= $highestRow; $fila++) {
                $alumnoId = (int)$sheet->getCell('B' . $fila)->getValue();
                if (!$alumnoId) continue;

                foreach ($aspectosCols as $colNum => $aspNombre) {
                    $aspId = $aspPorNombre[$aspNombre] ?? null;
                    if (!$aspId) continue;
                    $val = $sheet->getCellByColumnAndRow($colNum, $fila)->getValue();
                    $calificaciones[$alumnoId][$aspId] = ($val !== '' && $val !== null) ? (int)$val : null;
                }
            }

            $resultado = $calModelo->guardarCalificacionesIngles(
                $periodo, (int)$profesor['id'], $calificaciones
            );

        } else {
            // Leer calificaciones normales desde columna E fila 5
            for ($fila = 5; $fila <= $highestRow; $fila++) {
                $alumnoId = (int)$sheet->getCell('B' . $fila)->getValue();
                if (!$alumnoId) continue;
                $val = $sheet->getCell('E' . $fila)->getValue();
                $calificaciones[$alumnoId] = ($val !== '' && $val !== null) ? (int)$val : null;
            }

            $resultado = $calModelo->guardarCalificaciones(
                $asignacionId, $periodo, (int)$profesor['id'], $calificaciones
            );
        }
    }

} catch (Exception $e) {
    $error = 'Error al leer el archivo: ' . $e->getMessage();
}

// Redirigir de vuelta con mensaje
$msg = '';
if ($error) {
    $msg = 'error&detalle=' . urlencode($error);
} elseif (isset($resultado['success'])) {
    $msg = 'importado';
} else {
    $msg = 'error&detalle=' . urlencode($resultado['error'] ?? 'Error desconocido');
}

// Recuperar seccion/grado/grupo de la asignación para redirigir correctamente
$stmtAsig = $db->prepare("SELECT seccion, grado, grupo FROM asignaciones WHERE id = ? LIMIT 1");
$stmtAsig->bind_param('i', $asignacionId);
$stmtAsig->execute();
$asig = $stmtAsig->get_result()->fetch_assoc();

header('Location: captura.php?seccion=' . $asig['seccion'] . '&grado=' . $asig['grado'] . '&grupo=' . $asig['grupo'] . '&asignacion_id=' . $asignacionId . '&msg=' . $msg);
exit;