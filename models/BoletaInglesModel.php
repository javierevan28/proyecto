<?php
// models/BoletaInglesModel.php

class BoletaInglesModel {

    private mysqli $db;

    public function __construct(mysqli $db) {
        $this->db = $db;
    }

    public function obtenerBoletaIngles(int $alumnoId, int $cicloId): array {

        // Obtener datos del alumno
        $stmtAl = $this->db->prepare("
            SELECT al.nombre, al.apellido_paterno, al.apellido_materno,
                   al.matricula, al.grado, al.grupo, al.seccion
            FROM alumnos al
            WHERE al.id = ? LIMIT 1
        ");
        $stmtAl->bind_param('i', $alumnoId);
        $stmtAl->execute();
        $alumno = $stmtAl->get_result()->fetch_assoc();
        if (!$alumno) return [];

        // Obtener periodos abiertos
        $stmtP = $this->db->prepare("
            SELECT periodo FROM periodos_apertura
            WHERE ciclo_id = ?
            ORDER BY periodo ASC
        ");
        $stmtP->bind_param('i', $cicloId);
        $stmtP->execute();
        $resP = $stmtP->get_result();
        $periodosAbiertos = [];
        while ($row = $resP->fetch_assoc()) {
            $periodosAbiertos[] = (int)$row['periodo'];
        }

        // Obtener SOLO materias de inglés (con sus IDs correctos)
        $sql = "
            SELECT a.id AS asignacion_id, a.orden,
                   m.nombre AS materia_nombre,
                   m.id AS materia_id
            FROM asignaciones a
            JOIN materias m ON m.id = a.materia_id
            WHERE a.ciclo_id = ? 
              AND a.seccion = ? 
              AND a.grado = ? 
              AND a.grupo = ? 
              AND a.activo = 1
              AND m.es_ingles = 1
            ORDER BY a.orden ASC
        ";

        $stmtAsig = $this->db->prepare($sql);
        $stmtAsig->bind_param('isis', $cicloId, $alumno['seccion'], $alumno['grado'], $alumno['grupo']);
        $stmtAsig->execute();
        $asignaciones = $stmtAsig->get_result()->fetch_all(MYSQLI_ASSOC);

        // Orden específico de materias de inglés
        $ordenIngles = [
            'Listening' => null,
            'Speaking' => null,
            'Writing' => null,
            'Reading' => null,
            'Vocabulary' => null,
            'Grammar' => null,
            'Spelling' => null,
            'Science' => null
        ];

        // Asignar cada materia a su posición en el orden
        foreach ($asignaciones as $asig) {
            $nombre = trim($asig['materia_nombre'] ?? '');
            
            foreach ($ordenIngles as $key => $value) {
                if (strcasecmp($nombre, $key) === 0) {
                    // Obtener calificaciones DIRECTAS de la tabla calificaciones (sin aspectos)
                    $cals = [];
                    for ($p = 1; $p <= 6; $p++) {
                        $cals[$p] = $this->obtenerCalificacionDirecta($alumnoId, $asig['asignacion_id'], $p);
                    }
                    $trims = [];
                    for ($t = 1; $t <= 3; $t++) {
                        $trims[$t] = $this->calcTrimestre($cals[$t*2-1], $cals[$t*2]);
                    }
                    
                    $asig['calificaciones'] = $cals;
                    $asig['trimestres'] = $trims;
                    $ordenIngles[$key] = $asig;
                    break;
                }
            }
        }

        // Crear array final
        $materiasFinal = [];
        foreach ($ordenIngles as $nombre => $materia) {
            if ($materia !== null) {
                $materia['materia_nombre'] = $nombre;
                $materiasFinal[] = $materia;
            }
        }

        return [
            'alumno' => $alumno,
            'ciclo_id' => $cicloId,
            'periodosAbiertos' => $periodosAbiertos,
            'materias' => $materiasFinal,
        ];
    }

    // NUEVO: Obtiene calificación DIRECTA de la tabla calificaciones
    private function obtenerCalificacionDirecta(int $alumnoId, int $asignacionId, int $periodo): ?float {
        $stmt = $this->db->prepare("
            SELECT AVG(calificacion) AS promedio
            FROM calificaciones
            WHERE alumno_id = ? AND asignacion_id = ? AND periodo = ?
        ");
        $stmt->bind_param('iii', $alumnoId, $asignacionId, $periodo);
        $stmt->execute();
        $res = $stmt->get_result()->fetch_assoc();
        return ($res && $res['promedio'] !== null) ? (float)round($res['promedio'], 1) : null;
    }

    private function calcTrimestre(?float $p1, ?float $p2): ?float {
        if ($p1 !== null && $p2 !== null) return round(($p1 + $p2), 1);
        if ($p1 !== null) return $p1;
        if ($p2 !== null) return $p2;
        return null;
    }
}