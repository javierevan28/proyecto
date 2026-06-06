<?php
// models/ReporteModel.php

class ReporteModel {

    private mysqli $db;

    public function __construct(mysqli $db) {
        $this->db = $db;
    }

    /**
     * Redondea según la regla: >= .5 sube, < .5 baja
     * Ej: 8.6 -> 9, 8.5 -> 9, 8.4 -> 8
     */
    private function redondearNota(?float $nota): ?float {
        if ($nota === null) return null;
        return round($nota, 0, PHP_ROUND_HALF_UP);
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
        $promedio = ($res && $res['promedio'] !== null) ? (float)$res['promedio'] : null;
        return $this->redondearNota($promedio);
    }

    private function calcTrimestre(?float $p1, ?float $p2): ?float {
        if ($p1 !== null && $p2 !== null) {
            $promedio = ($p1 + $p2) / 2;
            return $this->redondearNota($promedio);
        }
        if ($p1 !== null) return $this->redondearNota($p1);
        if ($p2 !== null) return $this->redondearNota($p2);
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
                // =========================================================
                // VISTA POR MATERIA
                // Mostrar: Lengua Materna, Inglés (promedio), Artes (promedio)
                // y luego las demás materias base
                // =========================================================
                
                // Separar Lengua Materna de las demás materias base
                $lenguaMaterna = null;
                $otrasMateriasBase = [];
                
                foreach ($materiasBase as $mat) {
                    if ($mat['nombre'] === 'Lengua Materna') {
                        $lenguaMaterna = $mat;
                    } else {
                        $otrasMateriasBase[] = $mat;
                    }
                }
                
                // 1. Mostrar Lengua Materna (si existe)
                if ($lenguaMaterna) {
                    $cals = [];
                    for ($p = 1; $p <= 6; $p++) {
                        $cals[$p] = in_array($p, $periodosAb) 
                            ? $this->obtenerCalificacionMateria($al['alumno_id'], $lenguaMaterna['id'], $p) 
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
                    $al['columnas'][] = ['key' => 'mat_' . $lenguaMaterna['id'], 'valor' => $valores];
                }
                
                // 2. Promedio de INGLÉS (todas las materias de inglés juntas)
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
                        $promedio = $count > 0 ? $suma / $count : null;
                        $calsIngles[$p] = $promedio !== null ? $this->redondearNota($promedio) : null;
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

                // 3. Promedio de ARTES (todas las materias de artes juntas)
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
                        $promedio = $count > 0 ? $suma / $count : null;
                        $calsArtes[$p] = $promedio !== null ? $this->redondearNota($promedio) : null;
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
                
                // 4. Mostrar las demás materias base
                foreach ($otrasMateriasBase as $mat) {
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

            } else {
                // =========================================================
                // VISTA POR CAMPO FORMATIVO (ORIGINAL)
                // LENGUAJES con un solo promedio que incluye todo
                // =========================================================
                $campos = [];
                foreach ($materiasBase as $mat) {
                    $campoKey = $mat['campo_id'] ?? 'sin_campo';
                    if (!isset($campos[$campoKey])) {
                        $campos[$campoKey] = [
                            'nombre' => $mat['campo_nombre'] ?? 'Sin campo', 
                            'materias_ids' => [],
                            'incluye_ingles' => false,
                            'incluye_artes' => false
                        ];
                    }
                    $campos[$campoKey]['materias_ids'][] = $mat['id'];
                }
                
                // Campo LENGUAJES (incluye inglés y artes)
                $campoLenguajesKey = null;
                foreach ($campos as $key => $campo) {
                    if ($campo['nombre'] === 'LENGUAJES') {
                        $campoLenguajesKey = $key;
                        break;
                    }
                }
                
                if ($campoLenguajesKey === null) {
                    $campoLenguajesKey = 'lenguajes';
                    $campos[$campoLenguajesKey] = [
                        'nombre' => 'LENGUAJES',
                        'materias_ids' => [],
                        'incluye_ingles' => false,
                        'incluye_artes' => false
                    ];
                }
                
                $campos[$campoLenguajesKey]['incluye_ingles'] = !empty($materiasIngles);
                $campos[$campoLenguajesKey]['incluye_artes'] = !empty($materiasArtes);
                
                foreach ($campos as $campoKey => $campoData) {
                    $promCals = [];
                    
                    for ($p = 1; $p <= 6; $p++) {
                        $suma = 0;
                        $cont = 0;
                        
                        foreach ($campoData['materias_ids'] as $matId) {
                            if (in_array($p, $periodosAb)) {
                                $cal = $this->obtenerCalificacionMateria($al['alumno_id'], $matId, $p);
                                if ($cal !== null) {
                                    $suma += $cal;
                                    $cont++;
                                }
                            }
                        }
                        
                        if ($campoData['incluye_ingles'] && !empty($materiasIngles)) {
                            $sumaIngles = 0;
                            $countIngles = 0;
                            foreach ($materiasIngles as $mat) {
                                $cal = in_array($p, $periodosAb) 
                                    ? $this->obtenerCalificacionMateria($al['alumno_id'], $mat['id'], $p) 
                                    : null;
                                if ($cal !== null) {
                                    $sumaIngles += $cal;
                                    $countIngles++;
                                }
                            }
                            $promIngles = $countIngles > 0 ? $sumaIngles / $countIngles : null;
                            if ($promIngles !== null) {
                                $suma += $promIngles;
                                $cont++;
                            }
                        }
                        
                        if ($campoData['incluye_artes'] && !empty($materiasArtes)) {
                            $sumaArtes = 0;
                            $countArtes = 0;
                            foreach ($materiasArtes as $mat) {
                                $cal = in_array($p, $periodosAb) 
                                    ? $this->obtenerCalificacionMateria($al['alumno_id'], $mat['id'], $p) 
                                    : null;
                                if ($cal !== null) {
                                    $sumaArtes += $cal;
                                    $countArtes++;
                                }
                            }
                            $promArtes = $countArtes > 0 ? $sumaArtes / $countArtes : null;
                            if ($promArtes !== null) {
                                $suma += $promArtes;
                                $cont++;
                            }
                        }
                        
                        $promedio = $cont > 0 ? $suma / $cont : null;
                        $promCals[$p] = $promedio !== null ? $this->redondearNota($promedio) : null;
                    }
                    
                    $promTrims = [];
                    for ($t = 1; $t <= 3; $t++) {
                        $promTrims[$t] = $this->calcTrimestre($promCals[$t*2-1], $promCals[$t*2]);
                    }
                    
                    $valores = [];
                    foreach ($colsSeleccionadas as $col) {
                        $valores[$col] = $vista === 'periodo' ? $promCals[$col] : $promTrims[$col];
                    }
                    
                    $al['columnas'][] = [
                        'key' => 'campo_' . $campoKey, 
                        'valor' => $valores
                    ];
                }
            }

            // Promedio general redondeado
            $todos = [];
            foreach ($al['columnas'] as $col) {
                foreach ($col['valor'] as $v) {
                    if ($v !== null) $todos[] = $v;
                }
            }
            $promGeneral = !empty($todos) ? array_sum($todos) / count($todos) : null;
            $al['promedio_general'] = $promGeneral !== null ? $this->redondearNota($promGeneral) : null;
        }

        // Encabezados
        $encabezados = [];
        if ($agrupacion === 'materia') {
            // Lengua Materna
            foreach ($materiasBase as $mat) {
                if ($mat['nombre'] === 'Lengua Materna') {
                    $encabezados[] = ['key' => 'mat_' . $mat['id'], 'label' => $mat['nombre']];
                    break;
                }
            }
            // Inglés
            if (!empty($materiasIngles)) {
                $encabezados[] = ['key' => 'ingles', 'label' => 'Inglés'];
            }
            // Artes
            if (!empty($materiasArtes)) {
                $encabezados[] = ['key' => 'artes', 'label' => 'Artes'];
            }
            // Otras materias base
            foreach ($materiasBase as $mat) {
                if ($mat['nombre'] !== 'Lengua Materna') {
                    $encabezados[] = ['key' => 'mat_' . $mat['id'], 'label' => $mat['nombre']];
                }
            }
        } else {
            // Campos formativos
            foreach ($campos as $campoKey => $campoData) {
                $encabezados[] = [
                    'key' => 'campo_' . $campoKey, 
                    'label' => $campoData['nombre']
                ];
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