<?php
// models/PeriodoAperturaModel.php

class PeriodoAperturaModel {

    private mysqli $db;

    public function __construct(mysqli $db) {
        $this->db = $db;
    }

    // ----------------------------------------------------------
    // Lista todos los periodos de un ciclo
    // ----------------------------------------------------------
    public function listarPorCiclo(int $cicloId): array {
        $stmt = $this->db->prepare("
            SELECT id, ciclo_id, periodo, abierto, abierto_en, cerrado_en
            FROM periodos_apertura
            WHERE ciclo_id = ?
            ORDER BY periodo ASC
        ");
        $stmt->bind_param('i', $cicloId);
        $stmt->execute();
        $res  = $stmt->get_result();
        $rows = [];
        while ($row = $res->fetch_assoc()) $rows[] = $row;
        return $rows;
    }

    // ----------------------------------------------------------
    // Obtiene el periodo actualmente abierto de un ciclo
    // ----------------------------------------------------------
    public function obtenerAbierto(int $cicloId): ?array {
        $stmt = $this->db->prepare("
            SELECT id, periodo FROM periodos_apertura
            WHERE ciclo_id = ? AND abierto = 1 LIMIT 1
        ");
        $stmt->bind_param('i', $cicloId);
        $stmt->execute();
        $res = $stmt->get_result();
        return $res->num_rows > 0 ? $res->fetch_assoc() : null;
    }

    // ----------------------------------------------------------
    // Abre un periodo (cierra el que esté abierto primero)
    // ----------------------------------------------------------
    public function abrir(int $cicloId, int $periodo): array {
        if ($periodo < 1 || $periodo > 6) {
            return ['error' => 'El periodo debe ser entre 1 y 6'];
        }

        $this->db->begin_transaction();
        try {
            // 1. Cerrar cualquier periodo abierto del ciclo
            $stmtCerrar = $this->db->prepare("
                UPDATE periodos_apertura
                SET abierto = 0, cerrado_en = NOW()
                WHERE ciclo_id = ? AND abierto = 1
            ");
            $stmtCerrar->bind_param('i', $cicloId);
            $stmtCerrar->execute();

            // 2. Insertar o actualizar el periodo solicitado
            $stmtAbrir = $this->db->prepare("
                INSERT INTO periodos_apertura (ciclo_id, periodo, abierto, abierto_en)
                VALUES (?, ?, 1, NOW())
                ON DUPLICATE KEY UPDATE
                    abierto    = 1,
                    abierto_en = NOW(),
                    cerrado_en = NULL
            ");
            $stmtAbrir->bind_param('ii', $cicloId, $periodo);
            if (!$stmtAbrir->execute()) {
                throw new Exception('Error al abrir el periodo: ' . $stmtAbrir->error);
            }

            $this->db->commit();
            return ['success' => true];

        } catch (Exception $e) {
            $this->db->rollback();
            return ['error' => $e->getMessage()];
        }
    }

    // ----------------------------------------------------------
    // Cierra el periodo abierto actual
    // ----------------------------------------------------------
    public function cerrar(int $cicloId): array {
        $stmt = $this->db->prepare("
            UPDATE periodos_apertura
            SET abierto = 0, cerrado_en = NOW()
            WHERE ciclo_id = ? AND abierto = 1
        ");
        $stmt->bind_param('i', $cicloId);
        if ($stmt->execute()) {
            if ($stmt->affected_rows === 0) {
                return ['error' => 'No hay ningún periodo abierto'];
            }
            return ['success' => true];
        }
        return ['error' => 'Error al cerrar el periodo'];
    }

    // ----------------------------------------------------------
    // Verifica si un periodo específico está abierto
    // (útil para el módulo de captura de calificaciones)
    // ----------------------------------------------------------
    public function estaAbierto(int $cicloId, int $periodo): bool {
        $stmt = $this->db->prepare("
            SELECT id FROM periodos_apertura
            WHERE ciclo_id = ? AND periodo = ? AND abierto = 1
            LIMIT 1
        ");
        $stmt->bind_param('ii', $cicloId, $periodo);
        $stmt->execute();
        return $stmt->get_result()->num_rows > 0;
    }
}