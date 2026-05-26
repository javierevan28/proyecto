<?php
// models/CicloModel.php

class CicloModel {

    private mysqli $db;

    public function __construct(mysqli $db) {
        $this->db = $db;
    }

    public function listarTodos(): array {
        $res  = $this->db->query("
            SELECT id, nombre, fecha_inicio, fecha_fin, activo
            FROM ciclos_escolares
            ORDER BY fecha_inicio DESC
        ");
        $rows = [];
        while ($row = $res->fetch_assoc()) $rows[] = $row;
        return $rows;
    }

    public function obtenerPorId(int $id): ?array {
        $stmt = $this->db->prepare(
            "SELECT id, nombre, fecha_inicio, fecha_fin, activo
             FROM ciclos_escolares WHERE id = ? LIMIT 1"
        );
        $stmt->bind_param('i', $id);
        $stmt->execute();
        $res = $stmt->get_result();
        return $res->num_rows > 0 ? $res->fetch_assoc() : null;
    }

    private function validar(array $datos): ?string {
        $nombre = trim($datos['nombre'] ?? '');
        $inicio = trim($datos['fecha_inicio'] ?? '');
        $fin    = trim($datos['fecha_fin']    ?? '');

        if ($nombre === '')  return 'El nombre del ciclo es obligatorio';
        if (strlen($nombre) > 30) return 'El nombre no puede superar 30 caracteres';
        if ($inicio === '')  return 'La fecha de inicio es obligatoria';
        if ($fin    === '')  return 'La fecha de fin es obligatoria';
        if (strtotime($fin) <= strtotime($inicio)) {
            return 'La fecha de fin debe ser posterior a la fecha de inicio';
        }
        return null;
    }

    public function crear(array $datos): array {
        $error = $this->validar($datos);
        if ($error) return ['error' => $error];

        $nombre = trim($datos['nombre']);
        $inicio = trim($datos['fecha_inicio']);
        $fin    = trim($datos['fecha_fin']);

        $stmtCheck = $this->db->prepare(
            "SELECT id FROM ciclos_escolares WHERE nombre = ? LIMIT 1"
        );
        $stmtCheck->bind_param('s', $nombre);
        $stmtCheck->execute();
        if ($stmtCheck->get_result()->num_rows > 0) {
            return ['error' => "Ya existe un ciclo con el nombre \"$nombre\""];
        }

        $stmt = $this->db->prepare(
            "INSERT INTO ciclos_escolares (nombre, fecha_inicio, fecha_fin, activo)
             VALUES (?, ?, ?, 0)"
        );
        $stmt->bind_param('sss', $nombre, $inicio, $fin);

        if ($stmt->execute()) {
            return ['success' => true, 'id' => (int)$this->db->insert_id];
        }
        return ['error' => 'Error al guardar el ciclo: ' . $stmt->error];
    }

    public function editar(int $id, array $datos): array {
        $error = $this->validar($datos);
        if ($error) return ['error' => $error];

        $nombre = trim($datos['nombre']);
        $inicio = trim($datos['fecha_inicio']);
        $fin    = trim($datos['fecha_fin']);

        $stmtCheck = $this->db->prepare(
            "SELECT id FROM ciclos_escolares WHERE nombre = ? AND id <> ? LIMIT 1"
        );
        $stmtCheck->bind_param('si', $nombre, $id);
        $stmtCheck->execute();
        if ($stmtCheck->get_result()->num_rows > 0) {
            return ['error' => "Ya existe otro ciclo con el nombre \"$nombre\""];
        }

        $stmt = $this->db->prepare(
            "UPDATE ciclos_escolares SET nombre = ?, fecha_inicio = ?, fecha_fin = ? WHERE id = ?"
        );
        $stmt->bind_param('sssi', $nombre, $inicio, $fin, $id);

        if ($stmt->execute()) {
            return ['success' => true];
        }
        return ['error' => 'Error al actualizar el ciclo: ' . $stmt->error];
    }

    public function activar(int $id): array {
        if (!$this->obtenerPorId($id)) {
            return ['error' => 'El ciclo no existe'];
        }

        $this->db->begin_transaction();
        try {
            $this->db->query("UPDATE ciclos_escolares SET activo = 0");
            $stmt = $this->db->prepare(
                "UPDATE ciclos_escolares SET activo = 1 WHERE id = ?"
            );
            $stmt->bind_param('i', $id);
            $stmt->execute();
            $this->db->commit();
            return ['success' => true];
        } catch (Exception $e) {
            $this->db->rollback();
            return ['error' => 'Error al activar el ciclo: ' . $e->getMessage()];
        }
    }

    public function eliminar(int $id): array {
        $ciclo = $this->obtenerPorId($id);
        if (!$ciclo) return ['error' => 'El ciclo no existe'];

        if ((int)$ciclo['activo'] === 1) {
            return ['error' => 'No puedes eliminar el ciclo activo. Activa otro primero'];
        }

        $stmt = $this->db->prepare(
            "DELETE FROM ciclos_escolares WHERE id = ?"
        );
        $stmt->bind_param('i', $id);

        if ($stmt->execute()) {
            return ['success' => true];
        }
        return ['error' => 'Error al eliminar el ciclo: ' . $stmt->error];
    }

    public function obtenerActivo(): ?array {
        $res = $this->db->query(
            "SELECT id, nombre, fecha_inicio, fecha_fin
             FROM ciclos_escolares WHERE activo = 1 LIMIT 1"
        );
        return ($res && $res->num_rows > 0) ? $res->fetch_assoc() : null;
    }
}