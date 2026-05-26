<?php
// models/ArteSubcomponenteModel.php

class ArteSubcomponenteModel {

    private mysqli $db;

    public function __construct(mysqli $db) {
        $this->db = $db;
    }

    // ----------------------------------------------------------
    // Lista todos ordenados por orden ASC
    // ----------------------------------------------------------
    public function listarTodos(): array {
        $res  = $this->db->query("
            SELECT id, nombre, orden, activo
            FROM artes_subcomponentes
            ORDER BY orden ASC, nombre ASC
        ");
        $rows = [];
        while ($row = $res->fetch_assoc()) $rows[] = $row;
        return $rows;
    }

    // ----------------------------------------------------------
    // Solo los activos (para selects en asignaciones)
    // ----------------------------------------------------------
    public function listarActivos(): array {
        $res  = $this->db->query("
            SELECT id, nombre, orden
            FROM artes_subcomponentes
            WHERE activo = 1
            ORDER BY orden ASC, nombre ASC
        ");
        $rows = [];
        while ($row = $res->fetch_assoc()) $rows[] = $row;
        return $rows;
    }

    // ----------------------------------------------------------
    // Obtiene uno por ID
    // ----------------------------------------------------------
    public function obtenerPorId(int $id): ?array {
        $stmt = $this->db->prepare(
            "SELECT id, nombre, orden, activo
             FROM artes_subcomponentes WHERE id = ? LIMIT 1"
        );
        $stmt->bind_param('i', $id);
        $stmt->execute();
        $res = $stmt->get_result();
        return $res->num_rows > 0 ? $res->fetch_assoc() : null;
    }

    // ----------------------------------------------------------
    // Validaciones comunes
    // ----------------------------------------------------------
    private function validar(array $datos, ?int $excludeId = null): ?string {
        $nombre = trim($datos['nombre'] ?? '');
        $orden  = (int)($datos['orden'] ?? 0);

        if ($nombre === '')        return 'El nombre es obligatorio';
        if (strlen($nombre) > 100) return 'El nombre no puede superar 100 caracteres';
        if ($orden < 0)            return 'El orden debe ser un número positivo';

        // Verificar nombre duplicado
        $sql    = "SELECT id FROM artes_subcomponentes WHERE nombre = ?";
        $params = [$nombre];
        $types  = 's';

        if ($excludeId !== null) {
            $sql    .= " AND id <> ?";
            $params[] = $excludeId;
            $types   .= 'i';
        }

        $stmt = $this->db->prepare($sql . " LIMIT 1");
        $stmt->bind_param($types, ...$params);
        $stmt->execute();
        if ($stmt->get_result()->num_rows > 0) {
            return "Ya existe un subcomponente con el nombre \"$nombre\"";
        }

        return null;
    }

    // ----------------------------------------------------------
    // Crear
    // ----------------------------------------------------------
    public function crear(array $datos): array {
        $error = $this->validar($datos);
        if ($error) return ['error' => $error];

        $nombre = trim($datos['nombre']);
        $orden  = (int)($datos['orden'] ?? 0);

        $stmt = $this->db->prepare(
            "INSERT INTO artes_subcomponentes (nombre, orden) VALUES (?, ?)"
        );
        $stmt->bind_param('si', $nombre, $orden);

        if ($stmt->execute()) {
            return ['success' => true, 'id' => (int)$this->db->insert_id];
        }
        return ['error' => 'Error al guardar: ' . $stmt->error];
    }

    // ----------------------------------------------------------
    // Editar
    // ----------------------------------------------------------
    public function editar(int $id, array $datos): array {
        $error = $this->validar($datos, $id);
        if ($error) return ['error' => $error];

        $nombre = trim($datos['nombre']);
        $orden  = (int)($datos['orden'] ?? 0);

        $stmt = $this->db->prepare(
            "UPDATE artes_subcomponentes SET nombre = ?, orden = ? WHERE id = ?"
        );
        $stmt->bind_param('sii', $nombre, $orden, $id);

        if ($stmt->execute()) {
            return ['success' => true];
        }
        return ['error' => 'Error al actualizar: ' . $stmt->error];
    }

    // ----------------------------------------------------------
    // Activar / desactivar
    // ----------------------------------------------------------
    public function toggleActivo(int $id, int $activo): array {
        if ($activo === 0) {
            // No desactivar si está en uso en alguna asignación activa
            $stmt = $this->db->prepare("
                SELECT COUNT(*) AS total
                FROM asignacion_artes aa
                JOIN asignaciones     a  ON a.id = aa.asignacion_id
                WHERE aa.subcomponente_id = ? AND a.activo = 1
            ");
            $stmt->bind_param('i', $id);
            $stmt->execute();
            $total = (int)$stmt->get_result()->fetch_assoc()['total'];
            if ($total > 0) {
                return ['error' => "No puedes desactivar este subcomponente, está en uso en $total asignación(es) activa(s)"];
            }
        }

        $stmt = $this->db->prepare(
            "UPDATE artes_subcomponentes SET activo = ? WHERE id = ?"
        );
        $stmt->bind_param('ii', $activo, $id);
        if ($stmt->execute()) {
            return ['success' => true];
        }
        return ['error' => 'Error al actualizar el estado'];
    }
}