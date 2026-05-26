<?php
// models/MaestroModel.php

class MaestroModel {

    private mysqli $db;
    private UserModel $userModel;

    public function __construct(mysqli $db, UserModel $userModel) {
        $this->db        = $db;
        $this->userModel = $userModel;
    }

    // Registra un maestro completo
    public function crear(array $datos): array {
        $nombre   = trim($datos['nombre'] ?? '');
        $ap1      = trim($datos['apellido_paterno'] ?? '');
        $ap2      = trim($datos['apellido_materno'] ?? '');
        $email    = trim($datos['email'] ?? '');
        $telefono = trim($datos['telefono'] ?? '');
        $especialidad = trim($datos['especialidad'] ?? '');

        if ($nombre === '') return ['error' => 'El nombre es obligatorio'];
        if ($ap1 === '') return ['error' => 'El apellido paterno es obligatorio'];

        if ($email !== '' && !filter_var($email, FILTER_VALIDATE_EMAIL)) {
            return ['error' => 'Correo electrónico no válido'];
        }

        // Generar username
        $username = $this->userModel->generarUsernameUnico($ap1, $ap2, $nombre);
        if (!$username) {
            return ['error' => 'No se pudo generar un username válido'];
        }

        $this->db->begin_transaction();
        try {
            // Crear login (rol 2 = maestro)
            $userId = $this->userModel->crearUserLogin($username, 2);
            if (!$userId) throw new Exception('Error al crear usuario de login');

            // Insertar en maestros
            $stmt = $this->db->prepare("
                INSERT INTO maestros (user_id, nombre, apellido_paterno, apellido_materno, email, telefono, especialidad)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            ");
            $ap2OrNull = $ap2 !== '' ? $ap2 : null;
            $stmt->bind_param('issssss', $userId, $nombre, $ap1, $ap2OrNull, $email, $telefono, $especialidad);
            
            if (!$stmt->execute()) throw new Exception('Error al guardar maestro');
            
            $this->db->commit();
            return ['success' => true, 'username' => $username, 'maestro_id' => $this->db->insert_id];
        } catch (Exception $e) {
            $this->db->rollback();
            return ['error' => $e->getMessage()];
        }
    }

    // Listar todos los maestros
    public function listarTodos(): array {
        $sql = "
            SELECT m.*, u.username 
            FROM maestros m
            JOIN users u ON u.id = m.user_id
            WHERE m.activo = 1
            ORDER BY m.apellido_paterno, m.nombre
        ";
        $res = $this->db->query($sql);
        $rows = [];
        while ($row = $res->fetch_assoc()) $rows[] = $row;
        return $rows;
    }

    // Obtener maestro por user_id
    public function obtenerPorUserId(int $userId): ?array {
        $stmt = $this->db->prepare("SELECT * FROM maestros WHERE user_id = ? AND activo = 1 LIMIT 1");
        $stmt->bind_param('i', $userId);
        $stmt->execute();
        $res = $stmt->get_result();
        return $res->num_rows > 0 ? $res->fetch_assoc() : null;
    }
}