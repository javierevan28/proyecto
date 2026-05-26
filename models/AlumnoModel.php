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
    // Formato: CEF + 4 iniciales + fecha YYYYMMDD + consecutivo 6 dígitos
    // Iniciales: inicial ap.paterno + inicial ap.materno + inicial nombre + inicial 2do nombre
    // Ejemplo: CEFMAJO20260516000001
    // ----------------------------------------------------------
    private function generarMatricula(
        string $apellidoPaterno,
        string $apellidoMaterno,
        string $nombre            // puede tener 2 palabras: "Javier Omar"
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

        // Inicial 1: apellido paterno
        $i1 = $ap1[0] ?? 'X';
        // Inicial 2: apellido materno (X si no tiene)
        $i2 = $ap2 !== '' ? ($ap2[0] ?? 'X') : 'X';
        // Inicial 3: primer nombre
        $i3 = $partes[0][0] ?? 'X';
        // Inicial 4: segundo nombre (X si no tiene)
        $i4 = isset($partes[1]) ? ($partes[1][0] ?? 'X') : 'X';

        $iniciales = $i1 . $i2 . $i3 . $i4;
        $fecha     = date('Ymd');
        $prefijo   = 'CEF' . $iniciales . $fecha;

        // Consecutivo: buscar el último con ese mismo prefijo
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
    // Registra un alumno y lo vincula a su padre
    // ----------------------------------------------------------
    public function crear(array $datos): array {

        $nombre  = trim($datos['nombre']           ?? '');
        $ap1     = trim($datos['apellido_paterno']  ?? '');
        $ap2     = trim($datos['apellido_materno']  ?? '');
        $curp    = strtoupper(trim($datos['curp']   ?? ''));
        $fnac    = trim($datos['fecha_nacimiento']  ?? '');
        $genero  = trim($datos['genero']            ?? '');
        $grado   = (int)($datos['grado']            ?? 0);
        $grupo   = strtoupper(trim($datos['grupo']  ?? ''));
        $seccion = trim($datos['seccion']           ?? '');
        $padreId = (int)($datos['padre_id']         ?? 0);

        // --- Validaciones ---
        if ($nombre  === '') return ['error' => 'El nombre del alumno es obligatorio'];
        if ($ap1     === '') return ['error' => 'El apellido paterno es obligatorio'];
        if ($fnac    === '') return ['error' => 'La fecha de nacimiento es obligatoria'];
        if ($padreId  <= 0) return ['error' => 'Debes seleccionar un padre/tutor'];

        $generosValidos   = ['masculino', 'femenino', 'otro'];
        $gruposValidos    = ['A','B','C','D'];
        $seccionesValidas = ['maternal','preescolar','primaria','secundaria'];

        if (!in_array($genero,  $generosValidos))   return ['error' => 'Género no válido'];
        if (!in_array($grupo,   $gruposValidos))    return ['error' => 'Grupo no válido (A-D)'];
        if (!in_array($seccion, $seccionesValidas)) return ['error' => 'Sección no válida'];
        if ($grado < 1 || $grado > 6)              return ['error' => 'Grado debe ser entre 1 y 6'];

        if ($curp !== '' && !preg_match('/^[A-Z]{4}\d{6}[HM][A-Z]{5}[A-Z0-9]\d$/', $curp)) {
            return ['error' => 'CURP no tiene formato válido'];
        }

        // Verificar que el padre existe
        $stmtP = $this->db->prepare("SELECT id FROM padres WHERE id = ? LIMIT 1");
        $stmtP->bind_param('i', $padreId);
        $stmtP->execute();
        if ($stmtP->get_result()->num_rows === 0) {
            return ['error' => 'El padre/tutor seleccionado no existe'];
        }

        // --- Generar username y matrícula ---
        $username  = $this->userModel->generarUsernameUnico($ap1, $ap2, $nombre);
        if (!$username) {
            return ['error' => 'No se pudo generar un username para el alumno'];
        }

        $matricula = $this->generarMatricula($ap1, $ap2, $nombre);

        // --- Transacción ---
        $this->db->begin_transaction();
        try {
            // 1. Login (rol 3 = estudiante)
            $userId = $this->userModel->crearUserLogin($username, 3);
            if (!$userId) throw new Exception('Error al crear usuario de login para el alumno');

            // 2. Insertar alumno
            $stmt = $this->db->prepare("
                INSERT INTO alumnos
                    (user_id, matricula, nombre, apellido_paterno, apellido_materno,
                     curp, fecha_nacimiento, genero, grado, grupo, seccion)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ");

            $ap2OrNull  = $ap2  !== '' ? $ap2  : null;
            $curpOrNull = $curp !== '' ? $curp : null;

            $stmt->bind_param(
                'isssssssiss',
                $userId, $matricula, $nombre, $ap1, $ap2OrNull,
                $curpOrNull, $fnac, $genero, $grado, $grupo, $seccion
            );

            if (!$stmt->execute()) throw new Exception('Error al guardar alumno: ' . $stmt->error);
            $alumnoId = (int) $this->db->insert_id;

            // 3. Vincular padre ↔ alumno
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
    // Hijos de un padre (por padre_id)
    // ----------------------------------------------------------
    public function obtenerPorPadreId(int $padreId): array {
        $stmt = $this->db->prepare("
            SELECT a.id, a.matricula, a.nombre, a.apellido_paterno, a.apellido_materno,
                   a.grado, a.grupo, a.seccion, a.genero, a.fecha_nacimiento,
                   u.username
            FROM alumnos      a
            JOIN padre_alumno pa ON pa.alumno_id = a.id
            JOIN users        u  ON u.id = a.user_id
            WHERE pa.padre_id = ?
            ORDER BY a.apellido_paterno, a.nombre
        ");
        $stmt->bind_param('i', $padreId);
        $stmt->execute();
        $res  = $stmt->get_result();
        $rows = [];
        while ($row = $res->fetch_assoc()) $rows[] = $row;
        return $rows;
    }

    // ----------------------------------------------------------
    // Lista todos los alumnos (superadmin)
    // ----------------------------------------------------------
    public function listarTodos(): array {
        $sql = "
            SELECT a.id, a.matricula, a.nombre, a.apellido_paterno, a.apellido_materno,
                   a.grado, a.grupo, a.seccion, a.genero, u.username,
                   CONCAT(p.nombre,' ',p.apellido_paterno) AS nombre_padre
            FROM alumnos      a
            JOIN padre_alumno pa ON pa.alumno_id = a.id
            JOIN padres       p  ON p.id = pa.padre_id
            JOIN users        u  ON u.id = a.user_id
            ORDER BY a.apellido_paterno, a.nombre
        ";
        $res  = $this->db->query($sql);
        $rows = [];
        while ($row = $res->fetch_assoc()) $rows[] = $row;
        return $rows;
    }
}