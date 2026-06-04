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
            FROM asignaciones a
            JOIN asignacion_maestros am ON am.asignacion_id = a.id
            WHERE am.profesor_id = ? AND a.ciclo_id = ? AND a.activo = 1 AND am.activo = 1
            ORDER BY a.seccion, a.grado, a.grupo
        ");
        $stmt->bind_param('ii', $profesorId, $cicloId);
        $stmt->execute();
        return $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    }

    // ----------------------------------------------------------
    // Obtiene las materias que imparte un profesor en un grupo
    // ----------------------------------------------------------
    public function obtenerMateriasDeProfesor(int $profesorId, int $cicloId, string $seccion, int $grado, string $grupo): array {
        $stmt = $this->db->prepare("
            SELECT a.id AS asignacion_id, m.nombre AS materia_nombre,
                   m.es_ingles, m.es_artes, m.es_higiene,
                   am.es_titular
            FROM asignaciones a
            JOIN materias m ON m.id = a.materia_id
            JOIN asignacion_maestros am ON am.asignacion_id = a.id
            WHERE am.profesor_id = ?
              AND a.ciclo_id = ?
              AND a.seccion = ?
              AND a.grado = ?
              AND a.grupo = ?
              AND a.activo = 1
              AND am.activo = 1
            ORDER BY a.orden ASC
        ");
        $stmt->bind_param('iisis', $profesorId, $cicloId, $seccion, $grado, $grupo);
        $stmt->execute();
        return $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    }

    // ----------------------------------------------------------
    // Obtiene los aspectos de una asignación (para materias normales)
    // ----------------------------------------------------------
    public function obtenerAspectosPorAsignacion(int $asignacionId): array {
        $stmt = $this->db->prepare("
            SELECT id, nombre, porcentaje, orden
            FROM asignacion_aspectos
            WHERE asignacion_id = ? AND activo = 1
            ORDER BY orden ASC
        ");
        $stmt->bind_param('i', $asignacionId);
        $stmt->execute();
        return $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    }

    // ----------------------------------------------------------
    // Calcula el promedio ponderado y redondea (8.5->9, 8.4->8)
    // ----------------------------------------------------------
    private function calcularPromedioPonderado(array $calificaciones, array $aspectos): ?float {
        if (empty($aspectos)) return null;
        
        $sumaPonderada = 0;
        $porcentajeTotal = 0;
        
        foreach ($aspectos as $asp) {
            $cal = $calificaciones[$asp['id']] ?? null;
            if ($cal !== null && $cal !== '') {
                $sumaPonderada += (float)$cal * ((float)$asp['porcentaje'] / 100);
                $porcentajeTotal += (float)$asp['porcentaje'];
            }
        }
        
        if ($porcentajeTotal == 0) return null;
        
        // Si no están todos los aspectos capturados, ajustar el porcentaje
        $promedio = $sumaPonderada;
        
        // Redondear: 8.5 -> 9, 8.4 -> 8
        $decimal = $promedio - floor($promedio);
        if ($decimal >= 0.5) {
            return ceil($promedio);
        } else {
            return floor($promedio);
        }
    }

    // ----------------------------------------------------------
    // Obtiene alumnos con calificaciones por aspecto (materias normales)
    // ----------------------------------------------------------
    public function obtenerAlumnosConCalificacionesPorAspecto(int $asignacionId, string $seccion, int $grado, string $grupo, int $periodo): array {
        // Obtener aspectos
        $aspectos = $this->obtenerAspectosPorAsignacion($asignacionId);
        
        // Obtener alumnos del grupo
        $stmtAl = $this->db->prepare("
            SELECT al.id AS alumno_id,
                   al.nombre, al.apellido_paterno, al.apellido_materno,
                   al.matricula
            FROM alumnos al
            WHERE al.seccion = ? AND al.grado = ? AND al.grupo = ? AND al.activo = 1
            ORDER BY al.apellido_paterno, al.apellido_materno, al.nombre
        ");
        $stmtAl->bind_param('sis', $seccion, $grado, $grupo);
        $stmtAl->execute();
        $alumnos = $stmtAl->get_result()->fetch_all(MYSQLI_ASSOC);
        
        // Para cada alumno, obtener calificaciones por aspecto
        foreach ($alumnos as &$alumno) {
            $alumno['aspectos'] = [];
            foreach ($aspectos as $asp) {
                $stmtC = $this->db->prepare("
                    SELECT calificacion FROM calificaciones
                    WHERE alumno_id = ? AND aspecto_id = ? AND periodo = ?
                    LIMIT 1
                ");
                $stmtC->bind_param('iii', $alumno['alumno_id'], $asp['id'], $periodo);
                $stmtC->execute();
                $res = $stmtC->get_result()->fetch_assoc();
                $alumno['aspectos'][$asp['id']] = $res['calificacion'] ?? null;
            }
            // Calcular promedio ponderado
            $alumno['promedio'] = $this->calcularPromedioPonderado($alumno['aspectos'], $aspectos);
        }
        
        return ['aspectos' => $aspectos, 'alumnos' => $alumnos];
    }

    // ----------------------------------------------------------
    // Guarda calificaciones por aspecto (materias normales)
    // ----------------------------------------------------------
    public function guardarCalificacionesPorAspecto(int $asignacionId, int $periodo, int $profesorId, array $calificaciones): array {
        $stmt = $this->db->prepare("
            INSERT INTO calificaciones (alumno_id, asignacion_id, aspecto_id, periodo, calificacion, capturado_por)
            VALUES (?, ?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
                calificacion = VALUES(calificacion),
                capturado_por = VALUES(capturado_por),
                actualizado_en = NOW()
        ");

        $errores = 0;
        foreach ($calificaciones as $alumnoId => $aspectos) {
            $alumnoId = (int)$alumnoId;
            foreach ($aspectos as $aspectoId => $cal) {
                $aspectoId = (int)$aspectoId;
                $cal = ($cal === '' || $cal === null) ? null : (float)$cal;
                
                if ($cal !== null && ($cal < 0 || $cal > 10)) {
                    $errores++;
                    continue;
                }
                
                $stmt->bind_param('iiiidi', $alumnoId, $asignacionId, $aspectoId, $periodo, $cal, $profesorId);
                if (!$stmt->execute()) {
                    $errores++;
                    error_log("Error guardando calificación: " . $stmt->error);
                }
            }
        }
        
        if ($errores > 0) {
            return ['error' => "Hubo $errores error(es) al guardar."];
        }
        return ['success' => true];
    }

    // ----------------------------------------------------------
    // Obtiene alumnos con calificaciones de Artes
    // ----------------------------------------------------------
    public function obtenerAlumnosConCalificacionArtes(int $asignacionId, string $seccion, int $grado, string $grupo, int $periodo): array {
        $stmt = $this->db->prepare("
            SELECT al.id AS alumno_id,
                   al.nombre, al.apellido_paterno, al.apellido_materno,
                   al.matricula,
                   ca.calificacion
            FROM alumnos al
            LEFT JOIN calificaciones_artes ca
                ON ca.alumno_id = al.id
                AND ca.asignacion_id = ?
                AND ca.periodo = ?
            WHERE al.seccion = ? AND al.grado = ? AND al.grupo = ? AND al.activo = 1
            ORDER BY al.apellido_paterno, al.apellido_materno, al.nombre
        ");
        $stmt->bind_param('iisis', $asignacionId, $periodo, $seccion, $grado, $grupo);
        $stmt->execute();
        return $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    }

    // ----------------------------------------------------------
    // Guarda calificaciones de Artes
    // ----------------------------------------------------------
    public function guardarCalificacionesArtes(int $asignacionId, int $periodo, int $profesorId, array $calificaciones): array {
        $stmt = $this->db->prepare("
            INSERT INTO calificaciones_artes (alumno_id, asignacion_id, periodo, calificacion, capturado_por)
            VALUES (?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
                calificacion = VALUES(calificacion),
                capturado_por = VALUES(capturado_por),
                actualizado_en = NOW()
        ");

        $errores = 0;
        foreach ($calificaciones as $alumnoId => $cal) {
            $alumnoId = (int)$alumnoId;
            $cal = ($cal === '' || $cal === null) ? null : (int)$cal;

            if ($cal !== null && ($cal < 0 || $cal > 10)) {
                $errores++;
                continue;
            }

            $stmt->bind_param('iiiii', $alumnoId, $asignacionId, $periodo, $cal, $profesorId);
            if (!$stmt->execute()) $errores++;
        }

        if ($errores > 0) {
            return ['error' => "Hubo $errores error(es) al guardar calificaciones de Artes."];
        }
        return ['success' => true];
    }

    // ----------------------------------------------------------
    // Obtiene alumnos con calificaciones de inglés
    // ----------------------------------------------------------
    public function obtenerAlumnosIngles(int $asignacionId, string $seccion, int $grado, string $grupo, int $periodo): array {
        $stmtAsp = $this->db->prepare("
            SELECT id, nombre, orden
            FROM asignacion_ingles_aspectos
            WHERE asignacion_id = ? AND activo = 1
            ORDER BY orden ASC
        ");
        $stmtAsp->bind_param('i', $asignacionId);
        $stmtAsp->execute();
        $aspectos = $stmtAsp->get_result()->fetch_all(MYSQLI_ASSOC);
        
        $stmtAl = $this->db->prepare("
            SELECT al.id AS alumno_id,
                   al.nombre, al.apellido_paterno, al.apellido_materno,
                   al.matricula
            FROM alumnos al
            WHERE al.seccion = ? AND al.grado = ? AND al.grupo = ? AND al.activo = 1
            ORDER BY al.apellido_paterno, al.apellido_materno, al.nombre
        ");
        $stmtAl->bind_param('sis', $seccion, $grado, $grupo);
        $stmtAl->execute();
        $alumnos = $stmtAl->get_result()->fetch_all(MYSQLI_ASSOC);
        
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
    // Guarda calificaciones de inglés
    // ----------------------------------------------------------
    public function guardarCalificacionesIngles(int $periodo, int $profesorId, array $calificaciones): array {
        $stmt = $this->db->prepare("
            INSERT INTO calificaciones_ingles (alumno_id, aspecto_id, periodo, calificacion, capturado_por)
            VALUES (?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
                calificacion = VALUES(calificacion),
                capturado_por = VALUES(capturado_por),
                actualizado_en = NOW()
        ");
        
        $errores = 0;
        foreach ($calificaciones as $alumnoId => $aspectos) {
            $alumnoId = (int)$alumnoId;
            foreach ($aspectos as $aspectoId => $cal) {
                $aspectoId = (int)$aspectoId;
                $cal = ($cal === '' || $cal === null) ? null : (float)$cal;
                
                if ($cal !== null && ($cal < 0 || $cal > 10)) {
                    $errores++;
                    continue;
                }
                
                $stmt->bind_param('iiiid', $alumnoId, $aspectoId, $periodo, $cal, $profesorId);
                if (!$stmt->execute()) $errores++;
            }
        }
        
        if ($errores > 0) {
            return ['error' => "Hubo $errores error(es) al guardar calificaciones de inglés."];
        }
        return ['success' => true];
    }
    
    // ----------------------------------------------------------
    // Obtiene todas las asignaciones de un profesor
    // ----------------------------------------------------------
    public function obtenerTodasAsignacionesDeProfesor(int $profesorId, int $cicloId): array {
        $stmt = $this->db->prepare("
            SELECT a.id AS asignacion_id, a.seccion, a.grado, a.grupo,
                   m.nombre AS materia_nombre, m.es_ingles, m.es_artes, m.es_higiene,
                   am.es_titular
            FROM asignacion_maestros am
            JOIN asignaciones a ON a.id = am.asignacion_id
            JOIN materias m ON m.id = a.materia_id
            WHERE am.profesor_id = ? 
              AND a.ciclo_id = ? 
              AND a.activo = 1 
              AND am.activo = 1
            ORDER BY a.seccion, a.grado, a.grupo, a.orden
        ");
        $stmt->bind_param('ii', $profesorId, $cicloId);
        $stmt->execute();
        return $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    }
}
?>