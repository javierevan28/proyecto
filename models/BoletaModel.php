<?php
// models/BoletaModel.php

class BoletaModel {

    private mysqli $db;

    public function __construct(mysqli $db) {
        $this->db = $db;
    }

    // ----------------------------------------------------------
    // Obtiene todos los datos de la boleta de un alumno
    // en el ciclo activo
    // ----------------------------------------------------------
    public function obtenerBoleta(int $alumnoId, int $cicloId): array {

        // Datos del alumno
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

        // Periodos que han sido abiertos en este ciclo
        $stmtP = $this->db->prepare("
            SELECT periodo FROM periodos_apertura
            WHERE ciclo_id = ?
            ORDER BY periodo ASC
        ");
        $stmtP->bind_param('i', $cicloId);
        $stmtP->execute();
        $resP    = $stmtP->get_result();
        $periodosAbiertos = [];
        while ($row = $resP->fetch_assoc()) {
            $periodosAbiertos[] = (int)$row['periodo'];
        }

        // Asignaciones del grupo del alumno en este ciclo
        $stmtAsig = $this->db->prepare("
            SELECT a.id AS asignacion_id, a.orden,
                   m.nombre AS materia_nombre,
                   m.es_ingles, m.es_artes, m.es_higiene,
                   cf.nombre AS campo_formativo_nombre,
                   cf.orden  AS campo_orden
            FROM asignaciones a
            JOIN materias           m  ON m.id  = a.materia_id
            LEFT JOIN campos_formativos cf ON cf.id = a.campo_formativo_id
            WHERE a.ciclo_id = ?
              AND a.seccion  = ?
              AND a.grado    = ?
              AND a.grupo    = ?
              AND a.activo   = 1
            ORDER BY cf.orden ASC, a.orden ASC
        ");
        $stmtAsig->bind_param(
            'isis',
            $cicloId,
            $alumno['seccion'],
            $alumno['grado'],
            $alumno['grupo']
        );
        $stmtAsig->execute();
        $asignaciones = $stmtAsig->get_result()->fetch_all(MYSQLI_ASSOC);

        // Para cada asignación obtener calificaciones por periodo
        $materias = [];
        foreach ($asignaciones as $asig) {
            $asigId   = (int)$asig['asignacion_id'];
            $esIngles = (int)$asig['es_ingles'];
            $esArtes  = (int)$asig['es_artes'];

            $calsPorPeriodo = [];

            if ($esIngles) {
                // Obtener aspectos
                $stmtAsp = $this->db->prepare("
                    SELECT id, nombre, orden
                    FROM asignacion_ingles_aspectos
                    WHERE asignacion_id = ? AND activo = 1
                    ORDER BY orden ASC
                ");
                $stmtAsp->bind_param('i', $asigId);
                $stmtAsp->execute();
                $aspectos = $stmtAsp->get_result()->fetch_all(MYSQLI_ASSOC);

                // Por cada periodo obtener promedio de aspectos
                for ($p = 1; $p <= 6; $p++) {
                    if (!in_array($p, $periodosAbiertos)) {
                        $calsPorPeriodo[$p] = null;
                        continue;
                    }
                    $suma  = 0;
                    $count = 0;
                    foreach ($aspectos as $asp) {
                        $stmtC = $this->db->prepare("
                            SELECT calificacion FROM calificaciones_ingles
                            WHERE alumno_id = ? AND aspecto_id = ? AND periodo = ?
                            LIMIT 1
                        ");
                        $stmtC->bind_param('iii', $alumnoId, $asp['id'], $p);
                        $stmtC->execute();
                        $resC = $stmtC->get_result()->fetch_assoc();
                        if ($resC && $resC['calificacion'] !== null) {
                            $suma += $resC['calificacion'];
                            $count++;
                        }
                    }
                    $calsPorPeriodo[$p] = $count > 0 ? round($suma / $count, 1) : null;
                }
                $asig['aspectos'] = $aspectos;

            } elseif ($esArtes) {
                // Obtener subcomponente asignado
                $stmtSub = $this->db->prepare("
                    SELECT s.nombre
                    FROM asignacion_artes aa
                    JOIN artes_subcomponentes s ON s.id = aa.subcomponente_id
                    WHERE aa.asignacion_id = ? LIMIT 1
                ");
                $stmtSub->bind_param('i', $asigId);
                $stmtSub->execute();
                $sub = $stmtSub->get_result()->fetch_assoc();
                $asig['subcomponente'] = $sub['nombre'] ?? '';

                // Calificaciones normales por periodo
                for ($p = 1; $p <= 6; $p++) {
                    if (!in_array($p, $periodosAbiertos)) {
                        $calsPorPeriodo[$p] = null;
                        continue;
                    }
                    $stmtC = $this->db->prepare("
                        SELECT calificacion FROM calificaciones
                        WHERE alumno_id = ? AND asignacion_id = ? AND periodo = ?
                        LIMIT 1
                    ");
                    $stmtC->bind_param('iii', $alumnoId, $asigId, $p);
                    $stmtC->execute();
                    $resC = $stmtC->get_result()->fetch_assoc();
                    $calsPorPeriodo[$p] = $resC ? $resC['calificacion'] : null;
                }

            } else {
                // Materia normal
                for ($p = 1; $p <= 6; $p++) {
                    if (!in_array($p, $periodosAbiertos)) {
                        $calsPorPeriodo[$p] = null;
                        continue;
                    }
                    $stmtC = $this->db->prepare("
                        SELECT calificacion FROM calificaciones
                        WHERE alumno_id = ? AND asignacion_id = ? AND periodo = ?
                        LIMIT 1
                    ");
                    $stmtC->bind_param('iii', $alumnoId, $asigId, $p);
                    $stmtC->execute();
                    $resC = $stmtC->get_result()->fetch_assoc();
                    $calsPorPeriodo[$p] = $resC ? $resC['calificacion'] : null;
                }
            }

            // Calcular promedios por trimestre
            $trim = [];
            for ($t = 1; $t <= 3; $t++) {
                $p1 = $calsPorPeriodo[$t * 2 - 1];
                $p2 = $calsPorPeriodo[$t * 2];
                if ($p1 !== null && $p2 !== null) {
                    $trim[$t] = round(($p1 + $p2) / 2, 1);
                } elseif ($p1 !== null) {
                    $trim[$t] = $p1;
                } elseif ($p2 !== null) {
                    $trim[$t] = $p2;
                } else {
                    $trim[$t] = null;
                }
            }

            $asig['calificaciones'] = $calsPorPeriodo;
            $asig['trimestres']     = $trim;
            $materias[]             = $asig;
        }

        // Agrupar por campo formativo
        $porCampo = [];
        foreach ($materias as $mat) {
            $campo = $mat['campo_formativo_nombre'] ?? 'Sin campo formativo';
            $porCampo[$campo][] = $mat;
        }

        return [
            'alumno'           => $alumno,
            'ciclo_id'         => $cicloId,
            'periodosAbiertos' => $periodosAbiertos,
            'porCampo'         => $porCampo,
            'materias'         => $materias,
        ];
    }

    // ----------------------------------------------------------
    // Obtiene aspectos de inglés con calificaciones por periodo
    // para la boleta de inglés
    // ----------------------------------------------------------
    public function obtenerBoletaIngles(int $alumnoId, int $cicloId, int $asignacionId): array {
        // Periodos abiertos
        $stmtP = $this->db->prepare("
            SELECT periodo FROM periodos_apertura
            WHERE ciclo_id = ? ORDER BY periodo ASC
        ");
        $stmtP->bind_param('i', $cicloId);
        $stmtP->execute();
        $periodosAbiertos = array_column(
            $stmtP->get_result()->fetch_all(MYSQLI_ASSOC), 'periodo'
        );

        // Aspectos
        $stmtAsp = $this->db->prepare("
            SELECT id, nombre, orden
            FROM asignacion_ingles_aspectos
            WHERE asignacion_id = ? AND activo = 1
            ORDER BY orden ASC
        ");
        $stmtAsp->bind_param('i', $asignacionId);
        $stmtAsp->execute();
        $aspectos = $stmtAsp->get_result()->fetch_all(MYSQLI_ASSOC);

        // Calificaciones por aspecto y periodo
        foreach ($aspectos as &$asp) {
            $calsPorPeriodo = [];
            for ($p = 1; $p <= 6; $p++) {
                if (!in_array($p, $periodosAbiertos)) {
                    $calsPorPeriodo[$p] = null;
                    continue;
                }
                $stmtC = $this->db->prepare("
                    SELECT calificacion FROM calificaciones_ingles
                    WHERE alumno_id = ? AND aspecto_id = ? AND periodo = ?
                    LIMIT 1
                ");
                $stmtC->bind_param('iii', $alumnoId, $asp['id'], $p);
                $stmtC->execute();
                $resC = $stmtC->get_result()->fetch_assoc();
                $calsPorPeriodo[$p] = $resC ? $resC['calificacion'] : null;
            }

            // Trimestres
            $trim = [];
            for ($t = 1; $t <= 3; $t++) {
                $p1 = $calsPorPeriodo[$t * 2 - 1];
                $p2 = $calsPorPeriodo[$t * 2];
                if ($p1 !== null && $p2 !== null)   $trim[$t] = round(($p1 + $p2) / 2, 1);
                elseif ($p1 !== null)                $trim[$t] = $p1;
                elseif ($p2 !== null)                $trim[$t] = $p2;
                else                                 $trim[$t] = null;
            }

            $asp['calificaciones'] = $calsPorPeriodo;
            $asp['trimestres']     = $trim;
        }

        return [
            'aspectos'         => $aspectos,
            'periodosAbiertos' => $periodosAbiertos,
        ];
    }
}