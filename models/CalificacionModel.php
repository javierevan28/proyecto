<?php
// models/CalificacionModel.php

class CalificacionModel {

    private mysqli $db;

    public function __construct(mysqli $db) {
        $this->db = $db;
    }

    // ----------------------------------------------------------
    // Obtiene los grupos asignados a un profesor en el ciclo activo
    // ----------------------------------------------------------
    public function obtenerGruposDeProfesor(int $profesorId, int $cicloId): array {
        $stmt = $this->db->prepare("
            SELECT DISTINCT a.seccion, a.grado, a.grupo
            FROM asignaciones        a
            JOIN asignacion_maestros am ON am.asignacion_id = a.id
            WHERE am.profesor_id = ? AND a.ciclo_id = ? AND a.activo = 1
            ORDER BY a.seccion, a.grado, a.grupo
        ");
        $stmt->bind_param('ii', $profesorId, $cicloId);
        $stmt->execute();
        $res  = $stmt->get_result();
        $rows = [];
        while ($row = $res->fetch_assoc()) $rows[] = $row;
        return $rows;
    }

    // ----------------------------------------------------------
    // Obtiene las materias que imparte un profesor en un grupo
    // ----------------------------------------------------------
    public function obtenerMateriasDeProfesor(int $profesorId, int $cicloId, string $seccion, int $grado, string $grupo): array {
        $stmt = $this->db->prepare("
            SELECT a.id AS asignacion_id, m.nombre AS materia_nombre,
                   m.es_ingles, m.es_artes, m.es_higiene,
                   am.es_titular
            FROM asignaciones        a
            JOIN materias            m  ON m.id  = a.materia_id
            JOIN asignacion_maestros am ON am.asignacion_id = a.id
            WHERE am.profesor_id = ?
              AND a.ciclo_id     = ?
              AND a.seccion      = ?
              AND a.grado        = ?
              AND a.grupo        = ?
              AND a.activo       = 1
            ORDER BY a.orden ASC
        ");
        $stmt->bind_param('iisis', $profesorId, $cicloId, $seccion, $grado, $grupo);
        $stmt->execute();
        $res  = $stmt->get_result();
        $rows = [];
        while ($row = $res->fetch_assoc()) $rows[] = $row;
        return $rows;
    }

    // ----------------------------------------------------------
    // Obtiene alumnos de un grupo con sus calificaciones
    // de una asignación y periodo específicos
    // ----------------------------------------------------------
    public function obtenerAlumnosConCalificacion(int $asignacionId, string $seccion, int $grado, string $grupo, int $periodo): array {
        $stmt = $this->db->prepare("
            SELECT al.id AS alumno_id,
                   al.nombre, al.apellido_paterno, al.apellido_materno,
                   al.matricula,
                   c.calificacion
            FROM alumnos       al
            JOIN padre_alumno  pa ON pa.alumno_id = al.id
            LEFT JOIN calificaciones c
                ON  c.alumno_id     = al.id
                AND c.asignacion_id = ?
                AND c.periodo       = ?
            WHERE al.seccion = ? AND al.grado = ? AND al.grupo = ?
            ORDER BY al.apellido_paterno, al.apellido_materno, al.nombre
        ");
        $stmt->bind_param('iisis', $asignacionId, $periodo, $seccion, $grado, $grupo);
        $stmt->execute();
        $res  = $stmt->get_result();
        $rows = [];
        while ($row = $res->fetch_assoc()) $rows[] = $row;
        return $rows;
    }

    // ----------------------------------------------------------
    // Obtiene alumnos con sus calificaciones por aspecto de inglés
    // ----------------------------------------------------------
    public function obtenerAlumnosIngles(int $asignacionId, string $seccion, int $grado, string $grupo, int $periodo): array {
        // Obtener aspectos de esta asignación
        $stmtA = $this->db->prepare("
            SELECT id, nombre, orden
            FROM asignacion_ingles_aspectos
            WHERE asignacion_id = ? AND activo = 1
            ORDER BY orden ASC
        ");
        $stmtA->bind_param('i', $asignacionId);
        $stmtA->execute();
        $aspectos = $stmtA->get_result()->fetch_all(MYSQLI_ASSOC);

        // Obtener alumnos del grupo
        $stmtAl = $this->db->prepare("
            SELECT al.id AS alumno_id,
                   al.nombre, al.apellido_paterno, al.apellido_materno,
                   al.matricula
            FROM alumnos al
            WHERE al.seccion = ? AND al.grado = ? AND al.grupo = ?
            ORDER BY al.apellido_paterno, al.apellido_materno, al.nombre
        ");
        $stmtAl->bind_param('sis', $seccion, $grado, $grupo);
        $stmtAl->execute();
        $alumnos = $stmtAl->get_result()->fetch_all(MYSQLI_ASSOC);

        // Para cada alumno obtener sus calificaciones por aspecto
        foreach ($alumnos as &$alumno) {
            $alumno['aspectos'] = [];
            foreach ($aspectos as $asp) {
                $stmtC = $this->db->prepare("
                    SELECT calificacion FROM calificaciones_ingles
                    WHERE alumno_id = ? AND aspecto_id = ? AND periodo = ?
                    LIMIT 1
                ");
                $stmtC->bind_param('iii', $alumno['alumno_id'], $asp['id'], $periodo);
                $stmtC->execute();
                $resC = $stmtC->get_result()->fetch_assoc();
                $alumno['aspectos'][$asp['id']] = $resC['calificacion'] ?? null;
            }
        }

        return ['aspectos' => $aspectos, 'alumnos' => $alumnos];
    }

    // ----------------------------------------------------------
    // Guarda calificaciones normales (INSERT o UPDATE)
    // $calificaciones = [alumno_id => calificacion]
    // ----------------------------------------------------------
    public function guardarCalificaciones(int $asignacionId, int $periodo, int $profesorId, array $calificaciones): array {
        $stmt = $this->db->prepare("
            INSERT INTO calificaciones (alumno_id, asignacion_id, periodo, calificacion, capturado_por)
            VALUES (?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
                calificacion   = VALUES(calificacion),
                capturado_por  = VALUES(capturado_por),
                actualizado_en = NOW()
        ");

        $errores = 0;
        foreach ($calificaciones as $alumnoId => $cal) {
            $alumnoId = (int)$alumnoId;
            $cal      = ($cal === '' || $cal === null) ? null : (int)$cal;

            // Validar rango si tiene valor
            if ($cal !== null && ($cal < 0 || $cal > 10)) {
                $errores++;
                continue;
            }

            $stmt->bind_param('iiiii', $alumnoId, $asignacionId, $periodo, $cal, $profesorId);
            if (!$stmt->execute()) $errores++;
        }

        if ($errores > 0) {
            return ['error' => "Hubo $errores error(es) al guardar. Verifica que las calificaciones sean entre 0 y 10."];
        }
        return ['success' => true];
    }

    // ----------------------------------------------------------
    // Guarda calificaciones de inglés
    // $calificaciones = [alumno_id => [aspecto_id => calificacion]]
    // ----------------------------------------------------------
    public function guardarCalificacionesIngles(int $periodo, int $profesorId, array $calificaciones): array {
        $stmt = $this->db->prepare("
            INSERT INTO calificaciones_ingles (alumno_id, aspecto_id, periodo, calificacion, capturado_por)
            VALUES (?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
                calificacion   = VALUES(calificacion),
                capturado_por  = VALUES(capturado_por),
                actualizado_en = NOW()
        ");

        $errores = 0;
        foreach ($calificaciones as $alumnoId => $aspectos) {
            $alumnoId = (int)$alumnoId;
            foreach ($aspectos as $aspectoId => $cal) {
                $aspectoId = (int)$aspectoId;
                $cal       = ($cal === '' || $cal === null) ? null : (int)$cal;

                if ($cal !== null && ($cal < 0 || $cal > 10)) {
                    $errores++;
                    continue;
                }

                $stmt->bind_param('iiiii', $alumnoId, $aspectoId, $periodo, $cal, $profesorId);
                if (!$stmt->execute()) $errores++;
            }
        }

        if ($errores > 0) {
            return ['error' => "Hubo $errores error(es) al guardar calificaciones de inglés."];
        }
        return ['success' => true];
    }

    // ----------------------------------------------------------
    // Genera datos para exportar a Excel
    // Devuelve array listo para PhpSpreadsheet
    // ----------------------------------------------------------
    public function exportarParaExcel(int $asignacionId, string $seccion, int $grado, string $grupo, int $periodo, bool $esIngles, int $profesorId): array {
        if ($esIngles) {
            $datos = $this->obtenerAlumnosIngles($asignacionId, $seccion, $grado, $grupo, $periodo);
            return $datos;
        }
        $alumnos = $this->obtenerAlumnosConCalificacion($asignacionId, $seccion, $grado, $grupo, $periodo);
        return ['alumnos' => $alumnos, 'aspectos' => []];
    }
}