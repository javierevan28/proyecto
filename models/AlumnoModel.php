<?php
// models/AlumnoModel.php

class AlumnoModel {

    private mysqli $db;
    private UserModel $userModel;

    public function __construct(mysqli $db, UserModel $userModel) {
        $this->db        = $db;
        $this->userModel = $userModel;
    }

    // ----------------------------------------------------------
    // Genera la matrícula automática
    // ----------------------------------------------------------
    private function generarMatricula(
        string $apellidoPaterno,
        string $apellidoMaterno,
        string $nombre
    ): string {
        $mapeo = [
            'á'=>'A','é'=>'E','í'=>'I','ó'=>'O','ú'=>'U','ü'=>'U',
            'Á'=>'A','É'=>'E','Í'=>'I','Ó'=>'O','Ú'=>'U','Ü'=>'U',
            'ñ'=>'N','Ñ'=>'N',
        ];

        $norm = function(string $s) use ($mapeo): string {
            return strtoupper(strtr(trim($s), $mapeo));
        };

        $ap1    = $norm($apellidoPaterno);
        $ap2    = $norm($apellidoMaterno);
        $partes = array_filter(explode(' ', $norm($nombre)));
        $partes = array_values($partes);

        $i1 = $ap1[0] ?? 'X';
        $i2 = $ap2 !== '' ? ($ap2[0] ?? 'X') : 'X';
        $i3 = $partes[0][0] ?? 'X';
        $i4 = isset($partes[1]) ? ($partes[1][0] ?? 'X') : 'X';

        $iniciales = $i1 . $i2 . $i3 . $i4;
        $fecha     = date('Ymd');
        $prefijo   = 'CEF' . $iniciales . $fecha;

        $stmt = $this->db->prepare(
            "SELECT matricula FROM alumnos WHERE matricula LIKE ? ORDER BY matricula DESC LIMIT 1"
        );
        $like = $prefijo . '%';
        $stmt->bind_param('s', $like);
        $stmt->execute();
        $res = $stmt->get_result();

        if ($res->num_rows > 0) {
            $ultima      = $res->fetch_assoc()['matricula'];
            $consecutivo = (int) substr($ultima, -6) + 1;
        } else {
            $consecutivo = 1;
        }

        return $prefijo . str_pad($consecutivo, 6, '0', STR_PAD_LEFT);
    }

    // ----------------------------------------------------------
    // Registra un alumno
    // ----------------------------------------------------------
    public function crear(array $datos): array {
        $nombre  = trim($datos['nombre']           ?? '');
        $ap1     = trim($datos['apellido_paterno']  ?? '');
        $ap2     = trim($datos['apellido_materno']  ?? '');
        $curp    = strtoupper(trim($datos['curp']   ?? ''));
        $fnac    = trim($datos['fecha_nacimiento']  ?? '');
        $fing    = trim($datos['fecha_ingreso']     ?? ''); // <--- NUEVO: Fecha de ingreso
        $genero  = trim($datos['genero']            ?? '');
        $grado   = (int)($datos['grado']            ?? 0);
        $grupo   = strtoupper(trim($datos['grupo']  ?? ''));
        $seccion = trim($datos['seccion']           ?? '');
        $padreId = (int)($datos['padre_id']         ?? 0);
        $estatus = trim($datos['estatus']           ?? 'regular');
        $becaInterna = (float)($datos['beca_interna'] ?? 0);
        $becaExterna = (float)($datos['beca_externa'] ?? 0);

        if ($nombre === '') return ['error' => 'El nombre del alumno es obligatorio'];
        if ($ap1 === '') return ['error' => 'El apellido paterno es obligatorio'];
        if ($fnac === '') return ['error' => 'La fecha de nacimiento es obligatoria'];
        if ($padreId <= 0) return ['error' => 'Debes seleccionar un padre/tutor'];

        // Si no viene fecha_ingreso, usar la fecha actual
        if ($fing === '') {
            $fing = date('Y-m-d');
        }

        $generosValidos   = ['masculino', 'femenino', 'otro'];
        $gruposValidos    = ['A','B','C','D'];
        $seccionesValidas = ['maternal','preescolar','primaria','secundaria'];
        $estatusValidos   = ['nuevo_ingreso', 'reinscripcion', 'regular', 'baja'];

        if (!in_array($genero, $generosValidos))   return ['error' => 'Género no válido'];
        if (!in_array($grupo, $gruposValidos))    return ['error' => 'Grupo no válido (A-D)'];
        if (!in_array($seccion, $seccionesValidas)) return ['error' => 'Sección no válida'];
        if (!in_array($estatus, $estatusValidos)) return ['error' => 'Estatus no válido'];
        if ($grado < 1 || $grado > 6) return ['error' => 'Grado debe ser entre 1 y 6'];

        if ($curp !== '' && !preg_match('/^[A-Z]{4}\d{6}[HM][A-Z]{5}[A-Z0-9]\d$/', $curp)) {
            return ['error' => 'CURP no tiene formato válido'];
        }

        $stmtP = $this->db->prepare("SELECT id FROM padres WHERE id = ? LIMIT 1");
        $stmtP->bind_param('i', $padreId);
        $stmtP->execute();
        if ($stmtP->get_result()->num_rows === 0) {
            return ['error' => 'El padre/tutor seleccionado no existe'];
        }

        $username = $this->userModel->generarUsernameUnico($ap1, $ap2, $nombre);
        if (!$username) {
            return ['error' => 'No se pudo generar un username para el alumno'];
        }

        $matricula = $this->generarMatricula($ap1, $ap2, $nombre);

        $this->db->begin_transaction();
        try {
            $userId = $this->userModel->crearUserLogin($username, 3);
            if (!$userId) throw new Exception('Error al crear usuario de login');

            // ============================================================
            // CONSULTA CORREGIDA: Se agregó fecha_ingreso y becas
            // ============================================================
            $stmt = $this->db->prepare("
                INSERT INTO alumnos
                    (user_id, matricula, nombre, apellido_paterno, apellido_materno,
                     curp, fecha_nacimiento, fecha_ingreso, genero, grado, grupo, seccion, estatus,
                     beca_interna, beca_externa)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ");

            $ap2OrNull  = $ap2  !== '' ? $ap2  : null;
            $curpOrNull = $curp !== '' ? $curp : null;

            $stmt->bind_param(
                'issssssssisssdd',
                $userId, $matricula, $nombre, $ap1, $ap2OrNull,
                $curpOrNull, $fnac, $fing, $genero, $grado, $grupo, $seccion, $estatus,
                $becaInterna, $becaExterna
            );

            if (!$stmt->execute()) throw new Exception('Error al guardar alumno: ' . $stmt->error);
            $alumnoId = (int) $this->db->insert_id;

            $stmtRel = $this->db->prepare(
                "INSERT INTO padre_alumno (padre_id, alumno_id) VALUES (?, ?)"
            );
            $stmtRel->bind_param('ii', $padreId, $alumnoId);
            if (!$stmtRel->execute()) throw new Exception('Error al vincular padre y alumno');

            $this->db->commit();
            return [
                'success'   => true,
                'username'  => $username,
                'matricula' => $matricula,
                'alumno_id' => $alumnoId,
            ];

        } catch (Exception $e) {
            $this->db->rollback();
            return ['error' => $e->getMessage()];
        }
    }

    // ----------------------------------------------------------
    // Obtiene un alumno por ID
    // ----------------------------------------------------------
    public function obtenerPorId(int $id): ?array {
        $stmt = $this->db->prepare("
            SELECT a.*, u.username 
            FROM alumnos a
            JOIN users u ON u.id = a.user_id
            WHERE a.id = ? LIMIT 1
        ");
        $stmt->bind_param('i', $id);
        $stmt->execute();
        $res = $stmt->get_result();
        return $res->num_rows > 0 ? $res->fetch_assoc() : null;
    }

    // ----------------------------------------------------------
    // Cambia el estatus de un alumno
    // ----------------------------------------------------------
    public function cambiarEstatus(int $alumnoId, string $estatus): array {
        $estatusValidos = ['nuevo_ingreso', 'reinscripcion', 'regular', 'baja'];
        if (!in_array($estatus, $estatusValidos)) {
            return ['error' => 'Estatus no válido'];
        }
        
        $stmt = $this->db->prepare("UPDATE alumnos SET estatus = ? WHERE id = ?");
        $stmt->bind_param('si', $estatus, $alumnoId);
        
        if ($stmt->execute()) {
            return ['success' => true, 'mensaje' => 'Estatus actualizado correctamente'];
        }
        return ['error' => 'Error al actualizar estatus'];
    }

    // ----------------------------------------------------------
    // Hijos de un padre
    // ----------------------------------------------------------
    public function obtenerPorPadreId(int $padreId): array {
        $stmt = $this->db->prepare("
            SELECT a.id, a.matricula, a.nombre, a.apellido_paterno, a.apellido_materno,
                   a.grado, a.grupo, a.seccion, a.genero, a.fecha_nacimiento, a.estatus,
                   u.username
            FROM alumnos a
            JOIN padre_alumno pa ON pa.alumno_id = a.id
            JOIN users u ON u.id = a.user_id
            WHERE pa.padre_id = ?
            ORDER BY a.apellido_paterno, a.nombre
        ");
        $stmt->bind_param('i', $padreId);
        $stmt->execute();
        return $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    }

    // ----------------------------------------------------------
    // Lista todos los alumnos (para superadmin)
    // ----------------------------------------------------------
    public function listarTodos(): array {
        $sql = "
            SELECT a.id, a.matricula, a.nombre, a.apellido_paterno, a.apellido_materno,
                   a.grado, a.grupo, a.seccion, a.genero, a.estatus, u.username,
                   CONCAT(p.nombre,' ',p.apellido_paterno) AS nombre_padre
            FROM alumnos a
            JOIN padre_alumno pa ON pa.alumno_id = a.id
            JOIN padres p ON p.id = pa.padre_id
            JOIN users u ON u.id = a.user_id
            ORDER BY a.apellido_paterno, a.nombre
        ";
        $res = $this->db->query($sql);
        $rows = [];
        while ($row = $res->fetch_assoc()) $rows[] = $row;
        return $rows;
    }
}
?>