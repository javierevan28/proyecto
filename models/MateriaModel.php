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
        $res = $this->db->query("
            SELECT m.id, m.nombre, m.es_ingles, m.es_artes, m.es_higiene,
                   m.es_disciplina, m.es_ausencias, m.grupo_visual,
                   m.activo, m.creado_en,
                   cf.nombre AS campo_formativo_nombre,
                   m.campo_formativo_id
            FROM materias m
            LEFT JOIN campos_formativos cf ON cf.id = m.campo_formativo_id
            ORDER BY m.activo DESC, m.nombre ASC
        ");
        $rows = [];
        while ($row = $res->fetch_assoc()) $rows[] = $row;
        return $rows;
    }

    // ----------------------------------------------------------
    // Solo las activas (para selects en otras vistas)
    // ----------------------------------------------------------
    public function listarActivas(): array {
        $res = $this->db->query("
            SELECT m.id, m.nombre, m.es_ingles, m.es_artes, m.es_higiene,
                   m.es_disciplina, m.es_ausencias, m.grupo_visual,
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
            SELECT m.id, m.nombre, m.campo_formativo_id, m.grupo_visual,
                   m.es_ingles, m.es_artes, m.es_higiene,
                   m.es_disciplina, m.es_ausencias, m.activo
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

        if ($nombre === '')       return 'El nombre es obligatorio';
        if (strlen($nombre) > 80) return 'El nombre no puede superar 80 caracteres';

        // Solo una flag especial a la vez
        $esIngles     = isset($datos['es_ingles'])     ? 1 : 0;
        $esArtes      = isset($datos['es_artes'])      ? 1 : 0;
        $esHigiene    = isset($datos['es_higiene'])    ? 1 : 0;
        $esDisciplina = isset($datos['es_disciplina']) ? 1 : 0;
        $esAusencias  = isset($datos['es_ausencias'])  ? 1 : 0;

        if (($esIngles + $esArtes + $esHigiene + $esDisciplina + $esAusencias) > 1) {
            return 'Una materia solo puede ser de un tipo especial a la vez';
        }

        // Higiene, Disciplina y Ausencias no pueden tener campo formativo
        $campoId = (int)($datos['campo_formativo_id'] ?? 0);
        if (($esHigiene || $esDisciplina || $esAusencias) && $campoId > 0) {
            return 'Este tipo de materia no puede tener campo formativo asignado';
        }

        // Validar que el campo formativo existe (si se proporcionó)
        if ($campoId > 0) {
            $stmt = $this->db->prepare("SELECT id FROM campos_formativos WHERE id = ? AND activo = 1 LIMIT 1");
            $stmt->bind_param('i', $campoId);
            $stmt->execute();
            if ($stmt->get_result()->num_rows === 0) {
                return 'El campo formativo seleccionado no existe o está inactivo';
            }
        }

        // Verificar nombre duplicado solo entre activas
        $sql    = "SELECT id FROM materias WHERE nombre = ? AND activo = 1";
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
            return "Ya existe una materia activa con el nombre \"$nombre\"";
        }

        return null;
    }

    // ----------------------------------------------------------
    // Crear
    // ----------------------------------------------------------
    public function crear(array $datos): array {
        $error = $this->validar($datos);
        if ($error) return ['error' => $error];

        $nombre       = trim($datos['nombre']);
        $campoId      = (int)($datos['campo_formativo_id'] ?? 0) ?: null;
        $grupoVisual  = $datos['grupo_visual'] ?? 'base';
        $esIngles     = isset($datos['es_ingles'])     ? 1 : 0;
        $esArtes      = isset($datos['es_artes'])      ? 1 : 0;
        $esHigiene    = isset($datos['es_higiene'])    ? 1 : 0;
        $esDisciplina = isset($datos['es_disciplina']) ? 1 : 0;
        $esAusencias  = isset($datos['es_ausencias'])  ? 1 : 0;

        $stmt = $this->db->prepare("
            INSERT INTO materias
                (nombre, campo_formativo_id, grupo_visual, es_ingles, es_artes, es_higiene, es_disciplina, es_ausencias)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ");
        $stmt->bind_param('sisiiiii', $nombre, $campoId, $grupoVisual, $esIngles, $esArtes, $esHigiene, $esDisciplina, $esAusencias);

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

        $nombre       = trim($datos['nombre']);
        $campoId      = (int)($datos['campo_formativo_id'] ?? 0) ?: null;
        $grupoVisual  = $datos['grupo_visual'] ?? 'base';
        $esIngles     = isset($datos['es_ingles'])     ? 1 : 0;
        $esArtes      = isset($datos['es_artes'])      ? 1 : 0;
        $esHigiene    = isset($datos['es_higiene'])    ? 1 : 0;
        $esDisciplina = isset($datos['es_disciplina']) ? 1 : 0;
        $esAusencias  = isset($datos['es_ausencias'])  ? 1 : 0;

        $stmt = $this->db->prepare("
            UPDATE materias
            SET nombre = ?, campo_formativo_id = ?, grupo_visual = ?,
                es_ingles = ?, es_artes = ?, es_higiene = ?,
                es_disciplina = ?, es_ausencias = ?
            WHERE id = ?
        ");
        $stmt->bind_param('sisiiiiii', $nombre, $campoId, $grupoVisual, $esIngles, $esArtes, $esHigiene, $esDisciplina, $esAusencias, $id);

        if ($stmt->execute()) {
            return ['success' => true];
        }
        return ['error' => 'Error al actualizar: ' . $stmt->error];
    }

    // ----------------------------------------------------------
    // Activar / desactivar (lógico)
    // ----------------------------------------------------------
    public function toggleActivo(int $id, int $activo): array {
        if ($activo === 0) {
            // Verificar que no tenga asignaciones activas antes de desactivar
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

        $stmt = $this->db->prepare("UPDATE materias SET activo = ? WHERE id = ?");
        $stmt->bind_param('ii', $activo, $id);
        if ($stmt->execute()) {
            return ['success' => true];
        }
        return ['error' => 'Error al actualizar el estado'];
    }

    // ----------------------------------------------------------
    // Obtener materias agrupadas por grupo_visual (NUEVO)
    // ----------------------------------------------------------
    public function listarAgrupadasPorVisual(): array {
        $res = $this->db->query("
            SELECT grupo_visual, COUNT(*) as total 
            FROM materias 
            WHERE activo = 1 AND grupo_visual IS NOT NULL
            GROUP BY grupo_visual 
            ORDER BY FIELD(grupo_visual, 'base', 'ciencias', 'ingles', 'artes', 'cocurriculares', 'higiene', 'disciplina', 'ausencias')
        ");
        $grupos = [];
        while ($row = $res->fetch_assoc()) {
            $grupos[$row['grupo_visual']] = $row['total'];
        }
        return $grupos;
    }

    // ----------------------------------------------------------
    // Obtener materias por grupo_visual (NUEVO)
    // ----------------------------------------------------------
    public function listarPorGrupoVisual(string $grupoVisual): array {
        $stmt = $this->db->prepare("
            SELECT m.id, m.nombre, m.campo_formativo_id, m.grupo_visual,
                   m.es_ingles, m.es_artes, m.es_higiene, m.es_disciplina, m.es_ausencias,
                   cf.nombre AS campo_formativo_nombre
            FROM materias m
            LEFT JOIN campos_formativos cf ON cf.id = m.campo_formativo_id
            WHERE m.activo = 1 AND m.grupo_visual = ?
            ORDER BY m.nombre ASC
        ");
        $stmt->bind_param('s', $grupoVisual);
        $stmt->execute();
        return $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    }

    // ----------------------------------------------------------
    // Actualizar grupo_visual de una materia (NUEVO)
    // ----------------------------------------------------------
    public function actualizarGrupoVisual(int $id, string $grupoVisual): array {
        $stmt = $this->db->prepare("UPDATE materias SET grupo_visual = ? WHERE id = ?");
        $stmt->bind_param('si', $grupoVisual, $id);
        
        if ($stmt->execute()) {
            return ['success' => true];
        }
        return ['error' => 'Error al actualizar grupo visual'];
    }

    // ----------------------------------------------------------
    // Obtener todos los grupo_visual disponibles (para selects) (NUEVO)
    // ----------------------------------------------------------
    public function obtenerGruposVisualesDisponibles(): array {
        $res = $this->db->query("
            SELECT DISTINCT grupo_visual 
            FROM materias 
            WHERE activo = 1 AND grupo_visual IS NOT NULL
            ORDER BY grupo_visual
        ");
        return array_column($res->fetch_all(MYSQLI_ASSOC), 'grupo_visual');
    }
}