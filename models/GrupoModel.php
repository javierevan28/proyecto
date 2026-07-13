<?php
// models/GrupoModel.php

class GrupoModel {
    private mysqli $db;
    
    public function __construct(mysqli $db) {
        $this->db = $db;
    }
    
    public function listarPorGrado(string $seccion, int $grado, bool $soloActivos = true): array {
        $sql = "SELECT id, seccion, grado, nombre, orden, activo 
                FROM grupos_catalogo 
                WHERE seccion = ? AND grado = ?";
        if ($soloActivos) {
            $sql .= " AND activo = 1";
        }
        $sql .= " ORDER BY orden ASC";
        
        $stmt = $this->db->prepare($sql);
        $stmt->bind_param('si', $seccion, $grado);
        $stmt->execute();
        return $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    }
    
    public function obtenerPorId(int $id): ?array {
        $stmt = $this->db->prepare("SELECT id, seccion, grado, nombre, orden, activo FROM grupos_catalogo WHERE id = ? LIMIT 1");
        $stmt->bind_param('i', $id);
        $stmt->execute();
        $res = $stmt->get_result();
        return $res->num_rows > 0 ? $res->fetch_assoc() : null;
    }
    
    public function crear(array $datos): array {
        $seccion = $datos['seccion'] ?? '';
        $grado   = (int)($datos['grado'] ?? 0);
        $nombre  = trim($datos['nombre'] ?? '');
        $orden   = (int)($datos['orden'] ?? 0);
        
        if ($seccion === '') return ['error' => 'La sección es obligatoria'];
        if ($grado <= 0)     return ['error' => 'El grado es obligatorio'];
        if ($nombre === '')  return ['error' => 'El nombre es obligatorio'];
        
        $stmt = $this->db->prepare("SELECT id FROM grupos_catalogo WHERE seccion = ? AND grado = ? AND nombre = ? LIMIT 1");
        $stmt->bind_param('sis', $seccion, $grado, $nombre);
        $stmt->execute();
        if ($stmt->get_result()->num_rows > 0) {
            return ['error' => "Ya existe el grupo '$nombre'"];
        }
        
        $stmt = $this->db->prepare("INSERT INTO grupos_catalogo (seccion, grado, nombre, orden) VALUES (?, ?, ?, ?)");
        $stmt->bind_param('sisi', $seccion, $grado, $nombre, $orden);
        
        if ($stmt->execute()) {
            return ['success' => true, 'id' => $stmt->insert_id];
        }
        return ['error' => 'Error al guardar: ' . $stmt->error];
    }
    
    public function editar(int $id, array $datos): array {
        $nombre = trim($datos['nombre'] ?? '');
        $orden  = isset($datos['orden']) ? (int)$datos['orden'] : null;
        
        if ($nombre === '') return ['error' => 'El nombre es obligatorio'];
        
        // Construir la consulta dinámicamente
        $sql = "UPDATE grupos_catalogo SET nombre = ?";
        $types = 's';
        $params = [$nombre];
        
        if ($orden !== null) {
            $sql .= ", orden = ?";
            $types .= 'i';
            $params[] = $orden;
        }
        
        $sql .= " WHERE id = ?";
        $types .= 'i';
        $params[] = $id;
        
        $stmt = $this->db->prepare($sql);
        $stmt->bind_param($types, ...$params);
        
        if ($stmt->execute()) {
            return ['success' => true];
        }
        return ['error' => 'Error al actualizar: ' . $stmt->error];
    }
    
    public function toggleActivo(int $id, int $activo): array {
        $stmt = $this->db->prepare("UPDATE grupos_catalogo SET activo = ? WHERE id = ?");
        $stmt->bind_param('ii', $activo, $id);
        
        if ($stmt->execute()) {
            return ['success' => true];
        }
        return ['error' => 'Error al actualizar: ' . $stmt->error];
    }
    
    public function eliminar(int $id): array {
        $stmt = $this->db->prepare("DELETE FROM grupos_catalogo WHERE id = ?");
        $stmt->bind_param('i', $id);
        
        if ($stmt->execute()) {
            return ['success' => true];
        }
        return ['error' => 'Error al eliminar: ' . $stmt->error];
    }

    public function listarNombresPorSeccion(string $seccion): array {
        $stmt = $this->db->prepare("
            SELECT DISTINCT nombre FROM grupos_catalogo
            WHERE seccion = ? AND activo = 1
            ORDER BY nombre ASC
        ");
        $stmt->bind_param('s', $seccion);
        $stmt->execute();
        $result = $stmt->get_result();
        $nombres = [];
        while ($row = $result->fetch_assoc()) {
            $nombres[] = $row['nombre'];
        }
        return $nombres;
    }

    /**
     * Obtener lista de grupos con nombre completo para select
     */
    public function listarGruposCompletos(string $seccion, int $grado): array {
        $stmt = $this->db->prepare("
            SELECT id, seccion, grado, nombre, orden 
            FROM grupos_catalogo 
            WHERE seccion = ? AND grado = ? AND activo = 1
            ORDER BY orden ASC
        ");
        $stmt->bind_param('si', $seccion, $grado);
        $stmt->execute();
        return $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    }
}