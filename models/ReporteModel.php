<?php
// models/ReporteModel.php

class ReporteModel {

    private mysqli $db;

    public function __construct(mysqli $db) {
        $this->db = $db;
    }

    private function periodosAbiertos(int $cicloId): array {
        $stmt = $this->db->prepare(
            "SELECT periodo FROM periodos_apertura WHERE ciclo_id = ? ORDER BY periodo"
        );
        $stmt->bind_param('i', $cicloId);
        $stmt->execute();
        return array_column($stmt->get_result()->fetch_all(MYSQLI_ASSOC), 'periodo');
    }

    private function obtenerCal(int $alumnoId, int $asigId, int $periodo, bool $esIngles): ?float {
        if ($esIngles) {
            $stmt = $this->db->prepare("
                SELECT AVG(ci.calificacion) AS promedio
                FROM calificaciones_ingles ci
                JOIN asignacion_ingles_aspectos aia ON aia.id = ci.aspecto_id
                WHERE aia.asignacion_id = ? AND ci.alumno_id = ? AND ci.periodo = ?
            ");
            $stmt->bind_param('iii', $asigId, $alumnoId, $periodo);
            $stmt->execute();
            $res = $stmt->get_result()->fetch_assoc();
            return $res['promedio'] !== null ? round((float)$res['promedio'], 1) : null;
        }
        $stmt = $this->db->prepare("
            SELECT calificacion FROM calificaciones
            WHERE alumno_id = ? AND asignacion_id = ? AND periodo = ? LIMIT 1
        ");
        $stmt->bind_param('iii', $alumnoId, $asigId, $periodo);
        $stmt->execute();
        $res = $stmt->get_result()->fetch_assoc();
        return $res && $res['calificacion'] !== null ? (float)$res['calificacion'] : null;
    }

    private function calcTrimestre(?float $p1, ?float $p2): ?float {
        if ($p1 !== null && $p2 !== null) return round(($p1 + $p2) / 2, 1);
        if ($p1 !== null) return $p1;
        if ($p2 !== null) return $p2;
        return null;
    }

    public function listarGrupos(int $cicloId): array {
        $stmt = $this->db->prepare("
            SELECT DISTINCT seccion, grado, grupo
            FROM asignaciones WHERE ciclo_id = ? AND activo = 1
            ORDER BY seccion, grado, grupo
        ");
        $stmt->bind_param('i', $cicloId);
        $stmt->execute();
        return $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    }

    // ----------------------------------------------------------
    // Reporte principal
    // $vista       = 'periodo' | 'trimestre'
    // $agrupacion  = 'materia' | 'campo'
    // $seleccion   = 'todos' | '1'..'6' (periodos) | '1'..'3' (trimestres)
    // ----------------------------------------------------------
    public function obtenerReporte(
        int    $cicloId,
        string $seccion,
        int    $grado,
        string $grupo,
        string $vista,
        string $agrupacion,
        string $seleccion    // 'todos' | número
    ): array {

        $periodosAb = $this->periodosAbiertos($cicloId);

        // Definir qué columnas de tiempo mostrar
        if ($vista === 'periodo') {
            $maxCols = 6;
            $colsTodos = [1, 2, 3, 4, 5, 6];
        } else {
            $maxCols = 3;
            $colsTodos = [1, 2, 3];
        }

        $colsSeleccionadas = ($seleccion === 'todos')
            ? $colsTodos
            : [(int)$seleccion];

        // Alumnos del grupo
        $stmtAl = $this->db->prepare("
            SELECT id AS alumno_id, nombre, apellido_paterno, apellido_materno, matricula
            FROM alumnos
            WHERE seccion = ? AND grado = ? AND grupo = ?
            ORDER BY apellido_paterno, apellido_materno, nombre
        ");
        $stmtAl->bind_param('sis', $seccion, $grado, $grupo);
        $stmtAl->execute();
        $alumnos = $stmtAl->get_result()->fetch_all(MYSQLI_ASSOC);

        // Asignaciones del grupo
        $stmtAsig = $this->db->prepare("
            SELECT a.id AS asignacion_id, a.orden,
                   m.nombre AS materia_nombre,
                   m.es_ingles, m.es_artes, m.es_higiene,
                   cf.id    AS campo_id,
                   cf.nombre AS campo_nombre,
                   cf.orden  AS campo_orden
            FROM asignaciones a
            JOIN materias           m  ON m.id  = a.materia_id
            LEFT JOIN campos_formativos cf ON cf.id = a.campo_formativo_id
            WHERE a.ciclo_id = ? AND a.seccion = ? AND a.grado = ? AND a.grupo = ? AND a.activo = 1
            ORDER BY cf.orden ASC, a.orden ASC
        ");
        $stmtAsig->bind_param('isis', $cicloId, $seccion, $grado, $grupo);
        $stmtAsig->execute();
        $asignaciones = $stmtAsig->get_result()->fetch_all(MYSQLI_ASSOC);

        // Para cada alumno calcular valores
        foreach ($alumnos as &$al) {
            $al['columnas'] = [];

            if ($agrupacion === 'materia') {
                foreach ($asignaciones as $asig) {
                    $asigId   = (int)$asig['asignacion_id'];
                    $esIngles = (int)$asig['es_ingles'] === 1;

                    // Calcular los 6 periodos siempre (para poder calcular trimestres)
                    $cals = [];
                    for ($p = 1; $p <= 6; $p++) {
                        $cals[$p] = in_array($p, $periodosAb)
                            ? $this->obtenerCal($al['alumno_id'], $asigId, $p, $esIngles)
                            : null;
                    }

                    $trims = [];
                    for ($t = 1; $t <= 3; $t++) {
                        $trims[$t] = $this->calcTrimestre($cals[$t*2-1], $cals[$t*2]);
                    }

                    // Filtrar solo las columnas seleccionadas
                    $valoresFiltrados = [];
                    foreach ($colsSeleccionadas as $col) {
                        $valoresFiltrados[$col] = $vista === 'periodo'
                            ? $cals[$col]
                            : $trims[$col];
                    }

                    $al['columnas'][] = [
                        'key'    => 'asig_' . $asigId,
                        'valor'  => $valoresFiltrados,
                    ];
                }

            } else {
                // Agrupar por campo formativo
                $porCampo = [];
                foreach ($asignaciones as $asig) {
                    $campoKey = $asig['campo_id'] ?? 'sin_campo';
                    $asigId   = (int)$asig['asignacion_id'];
                    $esIngles = (int)$asig['es_ingles'] === 1;

                    if (!isset($porCampo[$campoKey])) {
                        $porCampo[$campoKey] = [
                            'campo_nombre'  => $asig['campo_nombre'] ?? 'Sin campo',
                            'materias_cals' => [],
                        ];
                    }

                    $cals = [];
                    for ($p = 1; $p <= 6; $p++) {
                        $cals[$p] = in_array($p, $periodosAb)
                            ? $this->obtenerCal($al['alumno_id'], $asigId, $p, $esIngles)
                            : null;
                    }
                    $porCampo[$campoKey]['materias_cals'][] = $cals;
                }

                foreach ($porCampo as $campoKey => $campoData) {
                    $promCals = [];
                    for ($p = 1; $p <= 6; $p++) {
                        $vals = array_filter(
                            array_column($campoData['materias_cals'], $p),
                            fn($v) => $v !== null
                        );
                        $promCals[$p] = count($vals) > 0
                            ? round(array_sum($vals) / count($vals), 1)
                            : null;
                    }

                    $promTrims = [];
                    for ($t = 1; $t <= 3; $t++) {
                        $promTrims[$t] = $this->calcTrimestre($promCals[$t*2-1], $promCals[$t*2]);
                    }

                    // Filtrar columnas seleccionadas
                    $valoresFiltrados = [];
                    foreach ($colsSeleccionadas as $col) {
                        $valoresFiltrados[$col] = $vista === 'periodo'
                            ? $promCals[$col]
                            : $promTrims[$col];
                    }

                    $al['columnas'][] = [
                        'key'   => 'campo_' . $campoKey,
                        'valor' => $valoresFiltrados,
                    ];
                }
            }

            // Promedio general — solo con los valores seleccionados
            $todosLosValores = [];
            foreach ($al['columnas'] as $col) {
                foreach ($col['valor'] as $v) {
                    if ($v !== null) $todosLosValores[] = $v;
                }
            }
            $al['promedio_general'] = count($todosLosValores) > 0
                ? round(array_sum($todosLosValores) / count($todosLosValores), 1)
                : null;
        }
        unset($al);

        // Encabezados de columnas
        $encabezados = [];
        if ($agrupacion === 'materia') {
            foreach ($asignaciones as $asig) {
                $encabezados[] = [
                    'key'   => 'asig_' . $asig['asignacion_id'],
                    'label' => $asig['materia_nombre'],
                ];
            }
        } else {
            $camposVistos = [];
            foreach ($asignaciones as $asig) {
                $campoKey = $asig['campo_id'] ?? 'sin_campo';
                if (!isset($camposVistos[$campoKey])) {
                    $camposVistos[$campoKey] = true;
                    $encabezados[] = [
                        'key'   => 'campo_' . $campoKey,
                        'label' => $asig['campo_nombre'] ?? 'Sin campo',
                    ];
                }
            }
        }

        // Etiquetas de columnas de tiempo
        $etiquetasCols = [];
        foreach ($colsSeleccionadas as $col) {
            $etiquetasCols[$col] = ($vista === 'periodo' ? 'P' : 'T') . $col;
        }

        return [
            'alumnos'          => $alumnos,
            'encabezados'      => $encabezados,
            'colsSeleccionadas'=> $colsSeleccionadas,
            'etiquetasCols'    => $etiquetasCols,
            'periodosAbiertos' => $periodosAb,
            'vista'            => $vista,
            'agrupacion'       => $agrupacion,
            'seleccion'        => $seleccion,
        ];
    }
}