<?php
// models/ProfesorModel.php

class ProfesorModel {

    private mysqli $db;
    private UserModel $userModel;

    public function __construct(mysqli $db, UserModel $userModel) {
        $this->db        = $db;
        $this->userModel = $userModel;
    }

    // ----------------------------------------------------------
    // Registra un profesor y crea su usuario de acceso (rol 4)
    // ----------------------------------------------------------
    public function crear(array $datos): array {

        $nombre   = trim($datos['nombre']           ?? '');
        $ap1      = trim($datos['apellido_paterno']  ?? '');
        $ap2      = trim($datos['apellido_materno']  ?? '');
        $curp     = strtoupper(trim($datos['curp']   ?? ''));
        $fnac     = trim($datos['fecha_nacimiento']  ?? '');
        $genero   = trim($datos['genero']            ?? '');
        $tipo     = trim($datos['tipo']              ?? '');
        $telefono = trim($datos['telefono']          ?? '');
        $correo   = trim($datos['correo']            ?? '');

        // --- Validaciones ---
        if ($nombre === '') return ['error' => 'El nombre es obligatorio'];
        if ($ap1    === '') return ['error' => 'El apellido paterno es obligatorio'];
        if ($fnac   === '') return ['error' => 'La fecha de nacimiento es obligatoria'];

        $generosValidos = ['masculino', 'femenino', 'otro'];
        if (!in_array($genero, $generosValidos)) {
            return ['error' => 'Género no válido'];
        }

        $tiposValidos = ['titular', 'frances', 'cocurricular'];
        if (!in_array($tipo, $tiposValidos)) {
            return ['error' => 'Tipo de maestro no válido'];
        }

        if ($correo !== '' && !filter_var($correo, FILTER_VALIDATE_EMAIL)) {
            return ['error' => 'Correo electrónico no válido'];
        }

        if ($curp !== '' && !preg_match('/^[A-Z]{4}\d{6}[HM][A-Z]{5}[A-Z0-9]\d$/', $curp)) {
            return ['error' => 'CURP no tiene formato válido'];
        }

        // Verificar CURP duplicada
        if ($curp !== '') {
            $stmtCurp = $this->db->prepare(
                "SELECT id FROM profesores WHERE curp = ? LIMIT 1"
            );
            $stmtCurp->bind_param('s', $curp);
            $stmtCurp->execute();
            if ($stmtCurp->get_result()->num_rows > 0) {
                return ['error' => 'Ya existe un profesor con esa CURP'];
            }
        }

        // --- Generar username ---
        $username = $this->userModel->generarUsernameUnico($ap1, $ap2, $nombre);
        if (!$username) {
            return ['error' => 'No se pudo generar un username para el profesor'];
        }

        // --- Transacción ---
        $this->db->begin_transaction();
        try {
            // 1. Crear login en users (rol 4 = profesor)
            $userId = $this->userModel->crearUserLogin($username, 4);
            if (!$userId) throw new Exception('Error al crear usuario de login');

            // 2. Insertar en profesores
            $stmt = $this->db->prepare("
                INSERT INTO profesores
                    (user_id, nombre, apellido_paterno, apellido_materno,
                     curp, fecha_nacimiento, genero, tipo, telefono, correo)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ");

            $ap2OrNull    = $ap2     !== '' ? $ap2     : null;
            $curpOrNull   = $curp    !== '' ? $curp    : null;
            $telOrNull    = $telefono !== '' ? $telefono : null;
            $correoOrNull = $correo  !== '' ? $correo  : null;

            $stmt->bind_param(
                'isssssssss',
                $userId, $nombre, $ap1, $ap2OrNull,
                $curpOrNull, $fnac, $genero, $tipo, $telOrNull, $correoOrNull
            );

            if (!$stmt->execute()) throw new Exception('Error al guardar profesor: ' . $stmt->error);

            $profesorId = (int) $this->db->insert_id;
            $this->db->commit();

            return [
                'success'     => true,
                'username'    => $username,
                'profesor_id' => $profesorId,
            ];

        } catch (Exception $e) {
            $this->db->rollback();
            return ['error' => $e->getMessage()];
        }
    }

    // ----------------------------------------------------------
    // Lista todos los profesores
    // ----------------------------------------------------------
    public function listarTodos(): array {
        $sql = "
            SELECT p.id, p.nombre, p.apellido_paterno, p.apellido_materno,
                   p.genero, p.tipo, p.telefono, p.correo, p.activo,
                   p.creado_en, u.username
            FROM profesores p
            JOIN users      u ON u.id = p.user_id
            ORDER BY p.tipo, p.apellido_paterno, p.nombre
        ";
        $res  = $this->db->query($sql);
        $rows = [];
        while ($row = $res->fetch_assoc()) $rows[] = $row;
        return $rows;
    }

    // ----------------------------------------------------------
    // Lista profesores activos filtrados por tipo
    // ----------------------------------------------------------
    public function listarActivosPorTipo(string $tipo): array {
        $stmt = $this->db->prepare("
            SELECT p.id, p.nombre, p.apellido_paterno, p.apellido_materno
            FROM profesores p
            WHERE p.activo = 1 AND p.tipo = ?
            ORDER BY p.apellido_paterno, p.nombre
        ");
        $stmt->bind_param('s', $tipo);
        $stmt->execute();
        $res  = $stmt->get_result();
        $rows = [];
        while ($row = $res->fetch_assoc()) $rows[] = $row;
        return $rows;
    }

    // ----------------------------------------------------------
    // Obtiene un profesor por su user_id
    // ----------------------------------------------------------
    public function obtenerPorUserId(int $userId): ?array {
        $stmt = $this->db->prepare(
            "SELECT * FROM profesores WHERE user_id = ? LIMIT 1"
        );
        $stmt->bind_param('i', $userId);
        $stmt->execute();
        $res = $stmt->get_result();
        return $res->num_rows > 0 ? $res->fetch_assoc() : null;
    }

    // ----------------------------------------------------------
    // Activar o desactivar un profesor
    // ----------------------------------------------------------
    public function toggleActivo(int $id, int $activo): array {
        $stmt = $this->db->prepare(
            "UPDATE profesores SET activo = ? WHERE id = ?"
        );
        $stmt->bind_param('ii', $activo, $id);
        if ($stmt->execute()) {
            return ['success' => true];
        }
        return ['error' => 'Error al actualizar el estado del profesor'];
    }
}