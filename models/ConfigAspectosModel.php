<?php
// models/ConfigAspectosModel.php

class ConfigAspectosModel {
    private mysqli $db;
    
    public function __construct(mysqli $db) {
        $this->db = $db;
    }
    
    public function obtenerGlobales(string $seccion, bool $incluirAusencias = false): array {
        $sql = "SELECT id, nombre_aspecto, porcentaje_default, orden_default 
                FROM config_aspectos_global 
                WHERE seccion = ? AND activo = 1";
        if (!$incluirAusencias) {
            $sql .= " AND aplica_ausencias = 0";
        }
        $sql .= " ORDER BY orden_default";
        
        $stmt = $this->db->prepare($sql);
        $stmt->bind_param('s', $seccion);
        $stmt->execute();
        return $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    }
    
    public function obtenerPorGrado(string $seccion, int $grado, bool $incluirAusencias = false): array {
        $sql = "SELECT nombre_aspecto, porcentaje, orden 
                FROM config_aspectos_por_grado 
                WHERE seccion = ? AND grado = ? AND activo = 1
                ORDER BY orden";
        
        $stmt = $this->db->prepare($sql);
        $stmt->bind_param('si', $seccion, $grado);
        $stmt->execute();
        $gradoConfig = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
        
        if (!empty($gradoConfig)) {
            return $gradoConfig;
        }
        
        return $this->obtenerGlobales($seccion, $incluirAusencias);
    }
    
    public function obtenerParaAsignacion(int $asignacionId): array {
        $stmt = $this->db->prepare("
            SELECT aa.id, aa.nombre, aa.porcentaje, aa.orden 
            FROM asignacion_aspectos aa
            WHERE aa.asignacion_id = ? AND aa.activo = 1
            ORDER BY aa.orden
        ");
        $stmt->bind_param('i', $asignacionId);
        $stmt->execute();
        return $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    }
    
    public function insertarAspectosEstandar(int $asignacionId, string $seccion, int $grado): void {
        $aspectos = $this->obtenerPorGrado($seccion, $grado, false);
        
        $stmt = $this->db->prepare("
            INSERT IGNORE INTO asignacion_aspectos 
            (asignacion_id, nombre, porcentaje, orden, activo)
            VALUES (?, ?, ?, ?, 1)
        ");
        
        foreach ($aspectos as $aspecto) {
            // Variables necesarias para que bind_param pueda pasarlas por referencia
            $nombre     = $aspecto['nombre_aspecto'] ?? $aspecto['nombre'];
            $porcentaje = (float)($aspecto['porcentaje_default'] ?? $aspecto['porcentaje']);
            $orden      = (int)($aspecto['orden_default'] ?? $aspecto['orden']);

            $stmt->bind_param('isdi', $asignacionId, $nombre, $porcentaje, $orden);
            $stmt->execute();
        }
    }
    
    public function listarGlobales(): array {
        $res = $this->db->query("
            SELECT cg.*, 
                   (SELECT COUNT(*) FROM config_aspectos_por_grado cpg 
                    WHERE cpg.seccion = cg.seccion AND cpg.nombre_aspecto = cg.nombre_aspecto) as tiene_sobrescritura
            FROM config_aspectos_global cg
            ORDER BY FIELD(seccion, 'maternal', 'preescolar', 'primaria', 'secundaria'), orden_default
        ");
        return $res->fetch_all(MYSQLI_ASSOC);
    }
    
    public function actualizarGlobal(int $id, array $datos): array {
        $porcentaje = (float)($datos['porcentaje'] ?? 0);
        $orden      = (int)($datos['orden'] ?? 0);
        $activo     = isset($datos['activo']) ? 1 : 0;
        
        $stmt = $this->db->prepare("
            UPDATE config_aspectos_global 
            SET porcentaje_default = ?, orden_default = ?, activo = ?
            WHERE id = ?
        ");
        $stmt->bind_param('diii', $porcentaje, $orden, $activo, $id);
        
        if ($stmt->execute()) {
            return ['success' => true];
        }
        return ['error' => 'Error al actualizar: ' . $stmt->error];
    }
    
    public function guardarSobrescritura(string $seccion, int $grado, array $aspectos): array {
        $stmt = $this->db->prepare("
            DELETE FROM config_aspectos_por_grado 
            WHERE seccion = ? AND grado = ?
        ");
        $stmt->bind_param('si', $seccion, $grado);
        $stmt->execute();
        
        $stmt = $this->db->prepare("
            INSERT INTO config_aspectos_por_grado 
            (seccion, grado, nombre_aspecto, porcentaje, orden, activo)
            VALUES (?, ?, ?, ?, ?, 1)
        ");
        
        foreach ($aspectos as $aspecto) {
            $nombre     = $aspecto['nombre'];
            $porcentaje = (float)$aspecto['porcentaje'];
            $orden      = (int)$aspecto['orden'];

            $stmt->bind_param('sisdi', $seccion, $grado, $nombre, $porcentaje, $orden);
            $stmt->execute();
        }
        
        return ['success' => true];
    }
    
    public function eliminarSobrescritura(string $seccion, int $grado): array {
        $stmt = $this->db->prepare("
            DELETE FROM config_aspectos_por_grado 
            WHERE seccion = ? AND grado = ?
        ");
        $stmt->bind_param('si', $seccion, $grado);
        
        if ($stmt->execute()) {
            return ['success' => true];
        }
        return ['error' => 'Error al eliminar sobrescritura'];
    }
}