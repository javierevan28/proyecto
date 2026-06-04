<?php
// models/ReporteModel.php

class ReporteModel {

    private mysqli $db;

    public function __construct(mysqli $db) {
        $this->db = $db;
    }

    private function periodosAbiertos(int $cicloId): array {
        $stmt = $this->db->prepare("SELECT periodo FROM periodos_apertura WHERE ciclo_id = ? ORDER BY periodo");
        $stmt->bind_param('i', $cicloId);
        $stmt->execute();
        return array_column($stmt->get_result()->fetch_all(MYSQLI_ASSOC), 'periodo');
    }

    private function obtenerCalificacionMateria(int $alumnoId, int $asignacionId, int $periodo): ?float {
        $stmt = $this->db->prepare("
            SELECT ROUND(SUM(c.calificacion * ap.porcentaje) / SUM(ap.porcentaje)) as promedio
            FROM calificaciones c
            JOIN asignacion_aspectos ap ON ap.id = c.aspecto_id
            WHERE c.alumno_id = ? AND c.asignacion_id = ? AND c.periodo = ?
        ");
        $stmt->bind_param('iii', $alumnoId, $asignacionId, $periodo);
        $stmt->execute();
        $res = $stmt->get_result()->fetch_assoc();
        return ($res && $res['promedio'] !== null) ? (float)$res['promedio'] : null;
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

    public function obtenerReporte(
        int    $cicloId,
        string $seccion,
        int    $grado,
        string $grupo,
        string $vista,
        string $agrupacion,
        string $seleccion
    ): array {

        $periodosAb = $this->periodosAbiertos($cicloId);
        $colsTodos = $vista === 'periodo' ? [1,2,3,4,5,6] : [1,2,3];
        $colsSeleccionadas = $seleccion === 'todos' ? $colsTodos : [(int)$seleccion];

        // Alumnos
        $stmtAl = $this->db->prepare("
            SELECT id AS alumno_id, nombre, apellido_paterno, apellido_materno, matricula
            FROM alumnos
            WHERE seccion = ? AND grado = ? AND grupo = ? AND activo = 1
            ORDER BY apellido_paterno, apellido_materno, nombre
        ");
        $stmtAl->bind_param('sis', $seccion, $grado, $grupo);
        $stmtAl->execute();
        $alumnos = $stmtAl->get_result()->fetch_all(MYSQLI_ASSOC);

        // Materias del grupo
        $stmtMat = $this->db->prepare("
            SELECT a.id, m.nombre, m.es_ingles, m.es_artes, cf.nombre as campo_nombre, cf.id as campo_id
            FROM asignaciones a
            JOIN materias m ON m.id = a.materia_id
            LEFT JOIN campos_formativos cf ON cf.id = a.campo_formativo_id
            WHERE a.ciclo_id = ? AND a.seccion = ? AND a.grado = ? AND a.grupo = ? AND a.activo = 1
            ORDER BY a.orden ASC
        ");
        $stmtMat->bind_param('isis', $cicloId, $seccion, $grado, $grupo);
        $stmtMat->execute();
        $materias = $stmtMat->get_result()->fetch_all(MYSQLI_ASSOC);

        // Separar por tipo
        $materiasBase = [];
        $materiasIngles = [];
        $materiasArtes = [];
        foreach ($materias as $m) {
            if ((int)$m['es_ingles'] === 1) {
                $materiasIngles[] = $m;
            } elseif ((int)$m['es_artes'] === 1) {
                $materiasArtes[] = $m;
            } else {
                $materiasBase[] = $m;
            }
        }

        foreach ($alumnos as &$al) {
            $al['columnas'] = [];

            if ($agrupacion === 'materia') {
                // Materias base (individuales)
                foreach ($materiasBase as $mat) {
                    $cals = [];
                    for ($p = 1; $p <= 6; $p++) {
                        $cals[$p] = in_array($p, $periodosAb) 
                            ? $this->obtenerCalificacionMateria($al['alumno_id'], $mat['id'], $p) 
                            : null;
                    }
                    $trims = [];
                    for ($t = 1; $t <= 3; $t++) {
                        $trims[$t] = $this->calcTrimestre($cals[$t*2-1], $cals[$t*2]);
                    }
                    $valores = [];
                    foreach ($colsSeleccionadas as $col) {
                        $valores[$col] = $vista === 'periodo' ? $cals[$col] : $trims[$col];
                    }
                    $al['columnas'][] = ['key' => 'mat_' . $mat['id'], 'valor' => $valores];
                }
                
                // PROMEDIO DE INGLÉS (todas las materias de inglés juntas)
                if (!empty($materiasIngles)) {
                    $calsIngles = [];
                    for ($p = 1; $p <= 6; $p++) {
                        $suma = 0; $count = 0;
                        foreach ($materiasIngles as $mat) {
                            $cal = in_array($p, $periodosAb) 
                                ? $this->obtenerCalificacionMateria($al['alumno_id'], $mat['id'], $p) 
                                : null;
                            if ($cal !== null) {
                                $suma += $cal;
                                $count++;
                            }
                        }
                        $calsIngles[$p] = $count > 0 ? round($suma / $count, 1) : null;
                    }
                    $trimsIngles = [];
                    for ($t = 1; $t <= 3; $t++) {
                        $trimsIngles[$t] = $this->calcTrimestre($calsIngles[$t*2-1], $calsIngles[$t*2]);
                    }
                    $valoresIngles = [];
                    foreach ($colsSeleccionadas as $col) {
                        $valoresIngles[$col] = $vista === 'periodo' ? $calsIngles[$col] : $trimsIngles[$col];
                    }
                    $al['columnas'][] = ['key' => 'ingles', 'valor' => $valoresIngles];
                }

                // PROMEDIO DE ARTES (todas las materias de artes juntas)
                if (!empty($materiasArtes)) {
                    $calsArtes = [];
                    for ($p = 1; $p <= 6; $p++) {
                        $suma = 0; $count = 0;
                        foreach ($materiasArtes as $mat) {
                            $cal = in_array($p, $periodosAb) 
                                ? $this->obtenerCalificacionMateria($al['alumno_id'], $mat['id'], $p) 
                                : null;
                            if ($cal !== null) {
                                $suma += $cal;
                                $count++;
                            }
                        }
                        $calsArtes[$p] = $count > 0 ? round($suma / $count, 1) : null;
                    }
                    $trimsArtes = [];
                    for ($t = 1; $t <= 3; $t++) {
                        $trimsArtes[$t] = $this->calcTrimestre($calsArtes[$t*2-1], $calsArtes[$t*2]);
                    }
                    $valoresArtes = [];
                    foreach ($colsSeleccionadas as $col) {
                        $valoresArtes[$col] = $vista === 'periodo' ? $calsArtes[$col] : $trimsArtes[$col];
                    }
                    $al['columnas'][] = ['key' => 'artes', 'valor' => $valoresArtes];
                }

            } else {
                // Agrupar por campo formativo
                $campos = [];
                foreach ($materiasBase as $mat) {
                    $campoKey = $mat['campo_id'] ?? 'sin_campo';
                    if (!isset($campos[$campoKey])) {
                        $campos[$campoKey] = ['nombre' => $mat['campo_nombre'] ?? 'Sin campo', 'materias_ids' => []];
                    }
                    $campos[$campoKey]['materias_ids'][] = $mat['id'];
                }
                
                foreach ($campos as $campoKey => $campoData) {
                    $promCals = [];
                    for ($p = 1; $p <= 6; $p++) {
                        if (in_array($p, $periodosAb)) {
                            $suma = 0; $cont = 0;
                            foreach ($campoData['materias_ids'] as $matId) {
                                $cal = $this->obtenerCalificacionMateria($al['alumno_id'], $matId, $p);
                                if ($cal !== null) {
                                    $suma += $cal;
                                    $cont++;
                                }
                            }
                            $promCals[$p] = $cont > 0 ? round($suma / $cont, 1) : null;
                        } else {
                            $promCals[$p] = null;
                        }
                    }
                    $promTrims = [];
                    for ($t = 1; $t <= 3; $t++) {
                        $promTrims[$t] = $this->calcTrimestre($promCals[$t*2-1], $promCals[$t*2]);
                    }
                    $valores = [];
                    foreach ($colsSeleccionadas as $col) {
                        $valores[$col] = $vista === 'periodo' ? $promCals[$col] : $promTrims[$col];
                    }
                    $al['columnas'][] = ['key' => 'campo_' . $campoKey, 'valor' => $valores];
                }
                
                // Campo de inglés
                if (!empty($materiasIngles)) {
                    $promCalsIngles = [];
                    for ($p = 1; $p <= 6; $p++) {
                        $suma = 0; $cont = 0;
                        foreach ($materiasIngles as $mat) {
                            $cal = in_array($p, $periodosAb) 
                                ? $this->obtenerCalificacionMateria($al['alumno_id'], $mat['id'], $p) 
                                : null;
                            if ($cal !== null) {
                                $suma += $cal;
                                $cont++;
                            }
                        }
                        $promCalsIngles[$p] = $cont > 0 ? round($suma / $cont, 1) : null;
                    }
                    $promTrimsIngles = [];
                    for ($t = 1; $t <= 3; $t++) {
                        $promTrimsIngles[$t] = $this->calcTrimestre($promCalsIngles[$t*2-1], $promCalsIngles[$t*2]);
                    }
                    $valoresIngles = [];
                    foreach ($colsSeleccionadas as $col) {
                        $valoresIngles[$col] = $vista === 'periodo' ? $promCalsIngles[$col] : $promTrimsIngles[$col];
                    }
                    $al['columnas'][] = ['key' => 'ingles', 'valor' => $valoresIngles];
                }

                // Campo de artes
                if (!empty($materiasArtes)) {
                    $promCalsArtes = [];
                    for ($p = 1; $p <= 6; $p++) {
                        $suma = 0; $cont = 0;
                        foreach ($materiasArtes as $mat) {
                            $cal = in_array($p, $periodosAb) 
                                ? $this->obtenerCalificacionMateria($al['alumno_id'], $mat['id'], $p) 
                                : null;
                            if ($cal !== null) {
                                $suma += $cal;
                                $cont++;
                            }
                        }
                        $promCalsArtes[$p] = $cont > 0 ? round($suma / $cont, 1) : null;
                    }
                    $promTrimsArtes = [];
                    for ($t = 1; $t <= 3; $t++) {
                        $promTrimsArtes[$t] = $this->calcTrimestre($promCalsArtes[$t*2-1], $promCalsArtes[$t*2]);
                    }
                    $valoresArtes = [];
                    foreach ($colsSeleccionadas as $col) {
                        $valoresArtes[$col] = $vista === 'periodo' ? $promCalsArtes[$col] : $promTrimsArtes[$col];
                    }
                    $al['columnas'][] = ['key' => 'artes', 'valor' => $valoresArtes];
                }
            }

            // Promedio general
            $todos = [];
            foreach ($al['columnas'] as $col) {
                foreach ($col['valor'] as $v) {
                    if ($v !== null) $todos[] = $v;
                }
            }
            $al['promedio_general'] = !empty($todos) ? round(array_sum($todos) / count($todos), 1) : null;
        }

        // Encabezados
        $encabezados = [];
        if ($agrupacion === 'materia') {
            foreach ($materiasBase as $mat) {
                $encabezados[] = ['key' => 'mat_' . $mat['id'], 'label' => $mat['nombre']];
            }
            if (!empty($materiasIngles)) {
                $encabezados[] = ['key' => 'ingles', 'label' => 'Inglés'];
            }
            if (!empty($materiasArtes)) {
                $encabezados[] = ['key' => 'artes', 'label' => 'Artes'];
            }
        } else {
            $vistos = [];
            foreach ($materiasBase as $mat) {
                $campoKey = $mat['campo_id'] ?? 'sin_campo';
                if (!in_array($campoKey, $vistos)) {
                    $vistos[] = $campoKey;
                    $encabezados[] = ['key' => 'campo_' . $campoKey, 'label' => $mat['campo_nombre'] ?? 'Sin campo'];
                }
            }
            if (!empty($materiasIngles)) {
                $encabezados[] = ['key' => 'ingles', 'label' => 'Inglés'];
            }
            if (!empty($materiasArtes)) {
                $encabezados[] = ['key' => 'artes', 'label' => 'Artes'];
            }
        }

        $etiquetasCols = [];
        foreach ($colsSeleccionadas as $col) {
            $etiquetasCols[$col] = ($vista === 'periodo' ? 'P' : 'T') . $col;
        }

        return [
            'alumnos' => $alumnos,
            'encabezados' => $encabezados,
            'colsSeleccionadas' => $colsSeleccionadas,
            'etiquetasCols' => $etiquetasCols,
            'periodosAbiertos' => $periodosAb,
            'vista' => $vista,
            'agrupacion' => $agrupacion,
            'seleccion' => $seleccion,
        ];
    }
}
?>