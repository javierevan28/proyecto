<?php
// models/MateriaModel.php

class MateriaModel {

    private mysqli $db;

    public function __construct(mysqli $db) {
        $this->db = $db;
    }

    // ----------------------------------------------------------
    // Lista todas ordenadas por nombre, con nombre del campo formativo
    // ----------------------------------------------------------
    public function listarTodos(): array {
        $res  = $this->db->query("
            SELECT m.id, m.nombre, m.es_ingles, m.es_artes, m.es_higiene,
                   m.activo, m.creado_en,
                   cf.nombre AS campo_formativo_nombre,
                   m.campo_formativo_id
            FROM materias m
            LEFT JOIN campos_formativos cf ON cf.id = m.campo_formativo_id
            ORDER BY m.nombre ASC
        ");
        $rows = [];
        while ($row = $res->fetch_assoc()) $rows[] = $row;
        return $rows;
    }

    // ----------------------------------------------------------
    // Solo las activas (para selects en otras vistas)
    // ----------------------------------------------------------
    public function listarActivas(): array {
        $res  = $this->db->query("
            SELECT m.id, m.nombre, m.es_ingles, m.es_artes, m.es_higiene,
                   m.campo_formativo_id,
                   cf.nombre AS campo_formativo_nombre
            FROM materias m
            LEFT JOIN campos_formativos cf ON cf.id = m.campo_formativo_id
            WHERE m.activo = 1
            ORDER BY m.nombre ASC
        ");
        $rows = [];
        while ($row = $res->fetch_assoc()) $rows[] = $row;
        return $rows;
    }

    // ----------------------------------------------------------
    // Obtiene una por ID
    // ----------------------------------------------------------
    public function obtenerPorId(int $id): ?array {
        $stmt = $this->db->prepare("
            SELECT m.id, m.nombre, m.campo_formativo_id,
                   m.es_ingles, m.es_artes, m.es_higiene, m.activo
            FROM materias m
            WHERE m.id = ? LIMIT 1
        ");
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

        if ($nombre === '')        return 'El nombre es obligatorio';
        if (strlen($nombre) > 80)  return 'El nombre no puede superar 80 caracteres';

        // Solo una flag especial a la vez
        $esIngles  = isset($datos['es_ingles'])  ? 1 : 0;
        $esArtes   = isset($datos['es_artes'])   ? 1 : 0;
        $esHigiene = isset($datos['es_higiene']) ? 1 : 0;

        if (($esIngles + $esArtes + $esHigiene) > 1) {
            return 'Una materia solo puede ser de un tipo especial a la vez';
        }

        // Higiene no puede tener campo formativo
        $campoId = (int)($datos['campo_formativo_id'] ?? 0);
        if ($esHigiene && $campoId > 0) {
            return 'Higiene no puede tener campo formativo asignado';
        }

        // Verificar nombre duplicado
        $sql    = "SELECT id FROM materias WHERE nombre = ?";
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
            return "Ya existe una materia con el nombre \"$nombre\"";
        }

        return null;
    }

    // ----------------------------------------------------------
    // Crear
    // ----------------------------------------------------------
    public function crear(array $datos): array {
        $error = $this->validar($datos);
        if ($error) return ['error' => $error];

        $nombre    = trim($datos['nombre']);
        $campoId   = (int)($datos['campo_formativo_id'] ?? 0) ?: null;
        $esIngles  = isset($datos['es_ingles'])  ? 1 : 0;
        $esArtes   = isset($datos['es_artes'])   ? 1 : 0;
        $esHigiene = isset($datos['es_higiene']) ? 1 : 0;

        $stmt = $this->db->prepare("
            INSERT INTO materias (nombre, campo_formativo_id, es_ingles, es_artes, es_higiene)
            VALUES (?, ?, ?, ?, ?)
        ");
        $stmt->bind_param('siiii', $nombre, $campoId, $esIngles, $esArtes, $esHigiene);

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

        $nombre    = trim($datos['nombre']);
        $campoId   = (int)($datos['campo_formativo_id'] ?? 0) ?: null;
        $esIngles  = isset($datos['es_ingles'])  ? 1 : 0;
        $esArtes   = isset($datos['es_artes'])   ? 1 : 0;
        $esHigiene = isset($datos['es_higiene']) ? 1 : 0;

        $stmt = $this->db->prepare("
            UPDATE materias
            SET nombre = ?, campo_formativo_id = ?,
                es_ingles = ?, es_artes = ?, es_higiene = ?
            WHERE id = ?
        ");
        $stmt->bind_param('siiiii', $nombre, $campoId, $esIngles, $esArtes, $esHigiene, $id);

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
            $stmt = $this->db->prepare(
                "SELECT COUNT(*) AS total FROM asignaciones
                 WHERE materia_id = ? AND activo = 1"
            );
            $stmt->bind_param('i', $id);
            $stmt->execute();
            $total = (int)$stmt->get_result()->fetch_assoc()['total'];
            if ($total > 0) {
                return ['error' => "No puedes desactivar esta materia, tiene $total asignación(es) activa(s)"];
            }
        }

        $stmt = $this->db->prepare(
            "UPDATE materias SET activo = ? WHERE id = ?"
        );
        $stmt->bind_param('ii', $activo, $id);
        if ($stmt->execute()) {
            return ['success' => true];
        }
        return ['error' => 'Error al actualizar el estado'];
    }
}