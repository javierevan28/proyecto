<?php
// superadmin/api_alumno.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
requireRol([1]);

header('Content-Type: application/json');

$db = getConexion();
$action = $_POST['action'] ?? $_GET['action'] ?? '';

try {
    switch ($action) {
        case 'get':
            $id = (int)($_GET['id'] ?? 0);
            if ($id <= 0) throw new Exception('ID de alumno inválido');
            
            $stmt = $db->prepare("SELECT * FROM alumnos WHERE id = ?");
            $stmt->bind_param('i', $id);
            $stmt->execute();
            $result = $stmt->get_result();
            $alumno = $result->fetch_assoc();
            
            if (!$alumno) throw new Exception('Alumno no encontrado');
            
            echo json_encode(['success' => true, 'data' => $alumno]);
            break;
            
        case 'update':
            $id = (int)($_POST['id'] ?? 0);
            if ($id <= 0) throw new Exception('ID de alumno inválido');
            
            // Recibir datos
            $matricula = trim($_POST['matricula'] ?? '');
            $nombre = trim($_POST['nombre'] ?? '');
            $apellido_paterno = trim($_POST['apellido_paterno'] ?? '');
            $apellido_materno = trim($_POST['apellido_materno'] ?? '');
            $genero = $_POST['genero'] ?? '';
            $seccion = $_POST['seccion'] ?? '';
            $grado = (int)($_POST['grado'] ?? 0);
            $grupo = $_POST['grupo'] ?? '';
            $curp = strtoupper(trim($_POST['curp'] ?? ''));
            $fecha_nacimiento = $_POST['fecha_nacimiento'] ?? '';
            $fecha_ingreso = $_POST['fecha_ingreso'] ?? '';
            $estatus = $_POST['estatus'] ?? 'regular';
            $beca_interna = (float)($_POST['beca_interna'] ?? 0);
            $beca_externa = (float)($_POST['beca_externa'] ?? 0);
            
            // Validaciones
            if (empty($nombre)) throw new Exception('El nombre es obligatorio');
            if (empty($apellido_paterno)) throw new Exception('El apellido paterno es obligatorio');
            if (empty($fecha_nacimiento)) throw new Exception('La fecha de nacimiento es obligatoria');
            if (empty($fecha_ingreso)) throw new Exception('La fecha de ingreso es obligatoria');
            
            // ACTUALIZACIÓN SIMPLE Y DIRECTA
            $sql = "UPDATE alumnos SET 
                matricula = '$matricula',
                nombre = '$nombre',
                apellido_paterno = '$apellido_paterno',
                apellido_materno = '$apellido_materno',
                genero = '$genero',
                seccion = '$seccion',
                grado = $grado,
                grupo = '$grupo',
                curp = '$curp',
                fecha_nacimiento = '$fecha_nacimiento',
                fecha_ingreso = '$fecha_ingreso',
                estatus = '$estatus',
                beca_interna = $beca_interna,
                beca_externa = $beca_externa
                WHERE id = $id";
            
            if (!$db->query($sql)) {
                throw new Exception('Error al actualizar: ' . $db->error);
            }
            
            echo json_encode(['success' => true, 'message' => 'Alumno actualizado correctamente']);
            break;
            
        case 'deactivate':
            $id = (int)($_POST['id'] ?? 0);
            if ($id <= 0) throw new Exception('ID de alumno inválido');
            
            $db->query("UPDATE alumnos SET activo = 0, estatus = 'baja' WHERE id = $id");
            
            if ($db->affected_rows === 0) {
                throw new Exception('Alumno no encontrado');
            }
            
            echo json_encode(['success' => true, 'message' => 'Alumno dado de baja correctamente']);
            break;
            
        case 'activate':
            $id = (int)($_POST['id'] ?? 0);
            if ($id <= 0) throw new Exception('ID de alumno inválido');
            
            $db->query("UPDATE alumnos SET activo = 1, estatus = 'regular' WHERE id = $id AND activo = 0");
            
            if ($db->affected_rows === 0) {
                throw new Exception('Alumno no encontrado o ya está activo');
            }
            
            echo json_encode(['success' => true, 'message' => 'Alumno reactivado correctamente']);
            break;
            
        default:
            throw new Exception('Acción no válida');
    }
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}