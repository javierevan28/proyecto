<?php
// models/PadreModel.php

class PadreModel {

    private mysqli $db;
    private UserModel $userModel;

    public function __construct(mysqli $db, UserModel $userModel) {
        $this->db        = $db;
        $this->userModel = $userModel;
    }

    // ----------------------------------------------------------
    // Registra un padre/tutor completo
    // Devuelve ['success'=>true, 'username'=>..., 'padre_id'=>...]
    // o        ['error' => 'mensaje']
    // ----------------------------------------------------------
    public function crear(array $datos): array {

        // --- Validaciones ---
        $nombre   = trim($datos['nombre']          ?? '');
        $ap1      = trim($datos['apellido_paterno'] ?? '');
        $ap2      = trim($datos['apellido_materno'] ?? '');
        $genero   = trim($datos['genero']           ?? '');
        $tel      = trim($datos['telefono']         ?? '');
        $telEmer  = trim($datos['telefono_emergencia'] ?? '');
        $correo   = trim($datos['correo']           ?? '');
        $curp     = strtoupper(trim($datos['curp']  ?? ''));

        if ($nombre === '')  return ['error' => 'El nombre es obligatorio'];
        if ($ap1    === '')  return ['error' => 'El apellido paterno es obligatorio'];
        if ($tel    === '')  return ['error' => 'El teléfono de contacto es obligatorio'];

        $generosValidos = ['masculino', 'femenino', 'otro'];
        if (!in_array($genero, $generosValidos)) {
            return ['error' => 'Género no válido'];
        }

        if ($correo !== '' && !filter_var($correo, FILTER_VALIDATE_EMAIL)) {
            return ['error' => 'Correo electrónico no válido'];
        }

        if ($curp !== '' && !preg_match('/^[A-Z]{4}\d{6}[HM][A-Z]{5}[A-Z0-9]\d$/', $curp)) {
            return ['error' => 'CURP no tiene formato válido'];
        }

        // --- Generar username ---
        $username = $this->userModel->generarUsernameUnico($ap1, $ap2, $nombre);
        if (!$username) {
            return ['error' => 'No se pudo generar un username válido (verifica nombre o palabras prohibidas)'];
        }

        // --- Transacción ---
        $this->db->begin_transaction();
        try {
            // 1. Crear login en users (rol 2 = padre)
            $userId = $this->userModel->crearUserLogin($username, 2);
            if (!$userId) throw new Exception('Error al crear usuario de login');

            // 2. Insertar en padres
            $stmt = $this->db->prepare("
                INSERT INTO padres
                    (user_id, nombre, apellido_paterno, apellido_materno,
                     genero, telefono, telefono_emergencia, correo, curp)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ");

            $ap2OrNull   = $ap2    !== '' ? $ap2    : null;
            $telEOrNull  = $telEmer !== '' ? $telEmer : null;
            $correoOrNull= $correo !== '' ? $correo  : null;
            $curpOrNull  = $curp   !== '' ? $curp    : null;

            $stmt->bind_param(
                'issssssss',
                $userId, $nombre, $ap1, $ap2OrNull,
                $genero, $tel, $telEOrNull, $correoOrNull, $curpOrNull
            );

            if (!$stmt->execute()) throw new Exception('Error al guardar padre: ' . $stmt->error);

            $padreId = (int) $this->db->insert_id;
            $this->db->commit();

            return [
                'success'  => true,
                'username' => $username,
                'padre_id' => $padreId,
            ];

        } catch (Exception $e) {
            $this->db->rollback();
            return ['error' => $e->getMessage()];
        }
    }

    // ----------------------------------------------------------
    // Lista todos los padres (para el superadmin)
    // ----------------------------------------------------------
    public function listarTodos(): array {
        $sql = "
            SELECT p.id, p.nombre, p.apellido_paterno, p.apellido_materno,
                   p.genero, p.telefono, p.correo, u.username, p.creado_en
            FROM padres p
            JOIN users  u ON u.id = p.user_id
            ORDER BY p.apellido_paterno, p.nombre
        ";
        $res  = $this->db->query($sql);
        $rows = [];
        while ($row = $res->fetch_assoc()) $rows[] = $row;
        return $rows;
    }

    // ----------------------------------------------------------
    // Obtiene un padre por su user_id
    // ----------------------------------------------------------
    public function obtenerPorUserId(int $userId): ?array {
        $stmt = $this->db->prepare(
            "SELECT * FROM padres WHERE user_id = ? LIMIT 1"
        );
        $stmt->bind_param('i', $userId);
        $stmt->execute();
        $res = $stmt->get_result();
        return $res->num_rows > 0 ? $res->fetch_assoc() : null;
    }
}