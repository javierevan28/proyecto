<?php
// models/PeriodoModel.php

class PeriodoModel {

    private mysqli $db;

    public function __construct(mysqli $db) {
        $this->db = $db;
    }

    // Crear un nuevo periodo
    public function crear(array $datos): array {
        $nombre = trim($datos['nombre'] ?? '');
        $tipoPeriodoId = (int)($datos['tipo_periodo_id'] ?? 0);
        $numero = (int)($datos['numero'] ?? 0);
        $cicloEscolar = trim($datos['ciclo_escolar'] ?? '');
        $fechaInicio = trim($datos['fecha_inicio'] ?? '');
        $fechaFin = trim($datos['fecha_fin'] ?? '');
        $fechaInicioCalif = trim($datos['fecha_inicio_calificaciones'] ?? '');
        $fechaFinCalif = trim($datos['fecha_fin_calificaciones'] ?? '');

        if ($nombre === '') return ['error' => 'El nombre del periodo es obligatorio'];
        if ($tipoPeriodoId <= 0) return ['error' => 'Selecciona un tipo de periodo'];
        if ($numero <= 0) return ['error' => 'El número de periodo es obligatorio'];
        if ($cicloEscolar === '') return ['error' => 'El ciclo escolar es obligatorio'];

        $stmt = $this->db->prepare("
            INSERT INTO periodos (nombre, tipo_periodo_id, numero, ciclo_escolar, fecha_inicio, fecha_fin, fecha_inicio_calificaciones, fecha_fin_calificaciones)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ");
        $stmt->bind_param('siisssss', $nombre, $tipoPeriodoId, $numero, $cicloEscolar, $fechaInicio, $fechaFin, $fechaInicioCalif, $fechaFinCalif);
        
        if ($stmt->execute()) {
            return ['success' => true, 'periodo_id' => $this->db->insert_id];
        }
        return ['error' => 'Error al crear periodo: ' . $stmt->error];
    }

    // Listar todos los periodos activos
    public function listarTodos(): array {
        $sql = "
            SELECT p.*, tp.nombre as tipo_nombre
            FROM periodos p
            JOIN tipos_periodo tp ON tp.id = p.tipo_periodo_id
            WHERE p.activo = 1
            ORDER BY p.ciclo_escolar DESC, p.fecha_inicio DESC
        ";
        $res = $this->db->query($sql);
        $rows = [];
        while ($row = $res->fetch_assoc()) $rows[] = $row;
        return $rows;
    }

    // Verificar si un periodo está abierto para calificaciones
    public function periodoAbierto(int $periodoId): bool {
        $ahora = date('Y-m-d H:i:s');
        $stmt = $this->db->prepare("
            SELECT id FROM periodos 
            WHERE id = ? AND activo = 1 
            AND fecha_inicio_calificaciones <= ? 
            AND fecha_fin_calificaciones >= ?
            LIMIT 1
        ");
        $stmt->bind_param('iss', $periodoId, $ahora, $ahora);
        $stmt->execute();
        return $stmt->get_result()->num_rows > 0;
    }
}