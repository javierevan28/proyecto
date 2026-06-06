<?php
// models/BoletaModel.php

class BoletaModel {

    private mysqli $db;

    public function __construct(mysqli $db) {
        $this->db = $db;
    }

    public function obtenerBoleta(int $alumnoId, int $cicloId): array {

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

        $stmtAsig = $this->db->prepare("
            SELECT a.id AS asignacion_id, a.orden,
                   m.nombre AS materia_nombre,
                   m.es_ingles, m.es_artes, m.es_higiene,
                   cf.id AS campo_id, cf.nombre AS campo_nombre, cf.orden AS campo_orden
            FROM asignaciones a
            JOIN materias m ON m.id = a.materia_id
            LEFT JOIN campos_formativos cf ON cf.id = a.campo_formativo_id
            WHERE a.ciclo_id = ? AND a.seccion = ? AND a.grado = ? AND a.grupo = ? AND a.activo = 1
            ORDER BY cf.orden ASC, a.orden ASC
        ");
        $stmtAsig->bind_param('isis', $cicloId, $alumno['seccion'], $alumno['grado'], $alumno['grupo']);
        $stmtAsig->execute();
        $asignaciones = $stmtAsig->get_result()->fetch_all(MYSQLI_ASSOC);

        $materiasBase = [];
        $materiasIngles = [];
        $materiasArtes = [];

        foreach ($asignaciones as $asig) {
            if ((int)$asig['es_ingles'] === 1) {
                $materiasIngles[] = $asig;
            } elseif ((int)$asig['es_artes'] === 1) {
                $materiasArtes[] = $asig;
            } else {
                $materiasBase[] = $asig;
            }
        }

        $materiasConCals = [];
        foreach ($materiasBase as $asig) {
            $asigId = (int)$asig['asignacion_id'];
            $cals = [];
            for ($p = 1; $p <= 6; $p++) {
                $cals[$p] = $this->obtenerCalificacionMateria($alumnoId, $asigId, $p);
            }
            $trims = [];
            for ($t = 1; $t <= 3; $t++) {
                $trims[$t] = $this->calcTrimestre($cals[$t*2-1], $cals[$t*2]);
            }
            $asig['calificaciones'] = $cals;
            $asig['trimestres'] = $trims;
            $materiasConCals[] = $asig;
        }

        // Materias de inglés con sus calificaciones individuales
        $materiasInglesConCals = [];
        foreach ($materiasIngles as $asig) {
            $asigId = (int)$asig['asignacion_id'];
            $cals = [];
            for ($p = 1; $p <= 6; $p++) {
                $cals[$p] = $this->obtenerCalificacionMateria($alumnoId, $asigId, $p);
            }
            $trims = [];
            for ($t = 1; $t <= 3; $t++) {
                $trims[$t] = $this->calcTrimestre($cals[$t*2-1], $cals[$t*2]);
            }
            $asig['calificaciones'] = $cals;
            $asig['trimestres'] = $trims;
            $materiasInglesConCals[] = $asig;
        }

        // Calcular promedio de INGLÉS
        $promedioIngles = [];
        if (!empty($materiasIngles)) {
            for ($p = 1; $p <= 6; $p++) {
                $suma = 0;
                $count = 0;
                foreach ($materiasIngles as $asig) {
                    $cal = $this->obtenerCalificacionMateria($alumnoId, (int)$asig['asignacion_id'], $p);
                    if ($cal !== null) {
                        $suma += $cal;
                        $count++;
                    }
                }
                $promedioIngles[$p] = $count > 0 ? round($suma / $count) : null;
            }
        }

        // Promedio de ARTES
        $promedioArtes = [];
        if (!empty($materiasArtes)) {
            for ($p = 1; $p <= 6; $p++) {
                $suma = 0;
                $count = 0;
                foreach ($materiasArtes as $asig) {
                    $cal = $this->obtenerCalificacionMateria($alumnoId, (int)$asig['asignacion_id'], $p);
                    if ($cal !== null) {
                        $suma += $cal;
                        $count++;
                    }
                }
                $promedioArtes[$p] = $count > 0 ? round($suma / $count) : null;
            }
        }

        $porCampo = [];

        foreach ($materiasConCals as $asig) {
            $campo = $asig['campo_nombre'] ?? 'Sin campo formativo';
            if (!isset($porCampo[$campo])) {
                $porCampo[$campo] = [];
            }
            $porCampo[$campo][] = $asig;
        }

        if (!empty($materiasIngles)) {
            $trimIngles = [];
            for ($t = 1; $t <= 3; $t++) {
                $trimIngles[$t] = $this->calcTrimestre($promedioIngles[$t*2-1], $promedioIngles[$t*2]);
            }
            $materiaIngles = [
                'asignacion_id' => 0,
                'materia_nombre' => 'Inglés',
                'es_ingles' => 0,
                'es_artes' => 0,
                'calificaciones' => $promedioIngles,
                'trimestres' => $trimIngles,
                'subcomponente' => ''
            ];
            $campoLenguajes = 'LENGUAJES';
            if (!isset($porCampo[$campoLenguajes])) {
                $porCampo[$campoLenguajes] = [];
            }
            $porCampo[$campoLenguajes][] = $materiaIngles;
        }

        if (!empty($materiasArtes)) {
            $trimArtes = [];
            for ($t = 1; $t <= 3; $t++) {
                $trimArtes[$t] = $this->calcTrimestre($promedioArtes[$t*2-1], $promedioArtes[$t*2]);
            }
            $materiaArtes = [
                'asignacion_id' => 0,
                'materia_nombre' => 'Artes',
                'es_ingles' => 0,
                'es_artes' => 0,
                'calificaciones' => $promedioArtes,
                'trimestres' => $trimArtes,
                'subcomponente' => ''
            ];
            $campoArtes = 'DE LO HUMANO Y LO COMUNITARIO';
            if (!isset($porCampo[$campoArtes])) {
                $porCampo[$campoArtes] = [];
            }
            $porCampo[$campoArtes][] = $materiaArtes;
        }

        return [
            'alumno' => $alumno,
            'ciclo_id' => $cicloId,
            'periodosAbiertos' => $periodosAbiertos,
            'porCampo' => $porCampo,
            'materias' => $materiasConCals,
            'materiasIngles' => $materiasInglesConCals, // Para la boleta de inglés
        ];
    }

    private function obtenerCalificacionMateria(int $alumnoId, int $asignacionId, int $periodo): ?float {
        $stmt = $this->db->prepare("
            SELECT SUM(c.calificacion * ap.porcentaje) / SUM(ap.porcentaje) as promedio
            FROM calificaciones c
            JOIN asignacion_aspectos ap ON ap.id = c.aspecto_id
            WHERE c.alumno_id = ? AND c.asignacion_id = ? AND c.periodo = ?
        ");
        $stmt->bind_param('iii', $alumnoId, $asignacionId, $periodo);
        $stmt->execute();
        $res = $stmt->get_result()->fetch_assoc();
        
        if ($res && $res['promedio'] !== null) {
            return round($res['promedio']);
        }
        return null;
    }

    private function calcTrimestre(?float $p1, ?float $p2): ?float {
        if ($p1 !== null && $p2 !== null) {
            return round(($p1 + $p2) / 2);
        }
        if ($p1 !== null) return $p1;
        if ($p2 !== null) return $p2;
        return null;
    }
}
?>