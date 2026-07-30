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

    /**
     * Calcula los periodos/trimestres de una materia y devuelve el arreglo
     * de valores listo para insertarse en 'columnas'.
     */
    private function calcularValoresMateria(
        int $alumnoId, int $materiaAsignacionId, array $periodosAb,
        string $vista, array $colsSeleccionadas
    ): array {
        $cals = [];
        for ($p = 1; $p <= 6; $p++) {
            $cals[$p] = in_array($p, $periodosAb)
                ? $this->obtenerCalificacionMateria($alumnoId, $materiaAsignacionId, $p)
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
        return $valores;
    }

    /**
     * Las ausencias NO se capturan como calificación (no tienen aspectos en
     * asignacion_aspectos), viven en su propia tabla `ausencias`
     * (alumno_id, ciclo_id, periodo, dias_ausencia). Por eso se leen aparte
     * en vez de usar obtenerCalificacionMateria().
     */
    private function obtenerAusenciasAlumno(
        int $alumnoId, int $cicloId, array $periodosAb,
        string $vista, array $colsSeleccionadas
    ): array {
        $stmt = $this->db->prepare("
            SELECT periodo, dias_ausencia
            FROM ausencias
            WHERE alumno_id = ? AND ciclo_id = ?
        ");
        $stmt->bind_param('ii', $alumnoId, $cicloId);
        $stmt->execute();
        $filas = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);

        $porPeriodo = [];
        foreach ($filas as $f) {
            $porPeriodo[(int)$f['periodo']] = (int)$f['dias_ausencia'];
        }

        $cals = [];
        for ($p = 1; $p <= 6; $p++) {
            $cals[$p] = (in_array($p, $periodosAb) && isset($porPeriodo[$p]))
                ? $porPeriodo[$p]
                : null;
        }

        // Para trimestre se suman los días de ausencia de los 2 periodos (no se promedia)
        $trims = [];
        for ($t = 1; $t <= 3; $t++) {
            $p1 = $cals[$t*2-1];
            $p2 = $cals[$t*2];
            $trims[$t] = ($p1 === null && $p2 === null) ? null : ($p1 ?? 0) + ($p2 ?? 0);
        }

        $valores = [];
        foreach ($colsSeleccionadas as $col) {
            $valores[$col] = $vista === 'periodo' ? $cals[$col] : $trims[$col];
        }
        return $valores;
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
            SELECT a.id, m.nombre, m.es_ingles, m.es_artes, m.es_ausencias, cf.nombre as campo_nombre, cf.id as campo_id
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

        // ============================================================
        // NOMBRES DE LENGUA MATERNA/ESPAÑOL
        // (movido arriba del filtro de "materias base" para que el
        // filtro pueda usarlo: ver FIX abajo)
        // ============================================================
        $nombresLengua = ['Lengua Materna', 'Español'];

        // Las materias base que no pertenecen a ningún campo formativo no deben
        // aparecer ni afectar el promedio. Las excepciones son:
        //  - Ausencias: se muestra aparte, pero tampoco cuenta para el promedio.
        //  - Lengua Materna / Español: SIEMPRE debe mostrarse aunque a la
        //    asignación le falte el campo_formativo_id (esto es lo que
        //    causaba que en 1° de secundaria "Lengua Materna" desapareciera
        //    del reporte: al no tener campo asignado, se descartaba en
        //    silencio antes de llegar a buscarla por nombre). [FIX]
        $materiaAusencias = null;
        $materiasBaseFiltradas = [];
        foreach ($materiasBase as $mat) {
            if ((int)($mat['es_ausencias'] ?? 0) === 1) {
                $materiaAusencias = $mat;
            } elseif ($mat['campo_id'] !== null || in_array($mat['nombre'], $nombresLengua)) {
                // FIX: se agrega el OR in_array(...) para no perder
                // Lengua Materna/Español cuando campo_id viene NULL.
                $materiasBaseFiltradas[] = $mat;
            }
            // else: sin campo formativo, no es Ausencias, no es Lengua Materna/Español -> se descarta
        }
        $materiasBase = $materiasBaseFiltradas;

        foreach ($alumnos as &$al) {
            $al['columnas'] = [];

            if ($agrupacion === 'materia') {
                // =========================================================
                // VISTA POR MATERIA
                // =========================================================
                
                // Separar Lengua Materna/Español de las demás materias base
                $lenguaMaterna = null;
                $otrasMateriasBase = [];
                
                foreach ($materiasBase as $mat) {
                    if (in_array($mat['nombre'], $nombresLengua)) {
                        $lenguaMaterna = $mat;
                    } else {
                        $otrasMateriasBase[] = $mat;
                    }
                }
                
                // 1. Mostrar Lengua Materna/Español (si existe)
                if ($lenguaMaterna) {
                    $valores = $this->calcularValoresMateria($al['alumno_id'], $lenguaMaterna['id'], $periodosAb, $vista, $colsSeleccionadas);
                    $label = $seccion === 'secundaria' ? 'Español' : 'Lengua Materna';
                    $al['columnas'][] = ['key' => 'mat_' . $lenguaMaterna['id'], 'valor' => $valores, 'incluir_promedio' => true, 'label' => $label];
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
                    $al['columnas'][] = ['key' => 'ingles', 'valor' => $valoresIngles, 'incluir_promedio' => true];
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
                    $al['columnas'][] = ['key' => 'artes', 'valor' => $valoresArtes, 'incluir_promedio' => true];
                }
                
                // 4. Mostrar las demás materias base (ya filtradas: solo las que
                //    pertenecen a un campo formativo, o Lengua Materna/Español)
                foreach ($otrasMateriasBase as $mat) {
                    $valores = $this->calcularValoresMateria($al['alumno_id'], $mat['id'], $periodosAb, $vista, $colsSeleccionadas);
                    $al['columnas'][] = ['key' => 'mat_' . $mat['id'], 'valor' => $valores, 'incluir_promedio' => true];
                }

                // 5. Ausencias: se muestra pero no cuenta para el promedio
                if ($materiaAusencias) {
                    $valoresAusencias = $this->obtenerAusenciasAlumno($al['alumno_id'], $cicloId, $periodosAb, $vista, $colsSeleccionadas);
                    $al['columnas'][] = ['key' => 'mat_' . $materiaAusencias['id'], 'valor' => $valoresAusencias, 'incluir_promedio' => false];
                }

            } else {
                // =========================================================
                // VISTA POR CAMPO FORMATIVO (MODIFICADA)
                // Lengua Materna/Español aparece como columna individual
                // LENGUAJES = solo Inglés + Artes (sin Lengua Materna/Español)
                // =========================================================
                
                // --- PASO 1: DETECTAR LENGUA MATERNA/ESPAÑOL ---
                $lenguaMaternaMat = null;
                $otrasMateriasBase = [];
                
                foreach ($materiasBase as $mat) {
                    if (in_array($mat['nombre'], $nombresLengua)) {
                        $lenguaMaternaMat = $mat;
                    } else {
                        $otrasMateriasBase[] = $mat;
                    }
                }
                
                $campos = [];
                
                // --- PASO 2: AGREGAR LENGUA MATERNA/ESPAÑOL COMO CAMPO INDIVIDUAL ---
                if ($lenguaMaternaMat !== null) {
                    $nombreLengua = $seccion === 'secundaria' ? 'ESPAÑOL' : 'LENGUA MATERNA';
                    $campos['lengua_materna'] = [
                        'nombre' => $nombreLengua,
                        'materias_ids' => [$lenguaMaternaMat['id']],
                        'incluye_ingles' => false,
                        'incluye_artes' => false
                    ];
                }
                
                // --- PASO 3: AGREGAR EL RESTO DE CAMPOS FORMATIVOS ---
                foreach ($otrasMateriasBase as $mat) {
                    $campoKey = $mat['campo_id'] ?? 'sin_campo';
                    $nombreCampo = $mat['campo_nombre'] ?? 'Sin campo';
                    
                    if (!isset($campos[$campoKey])) {
                        $campos[$campoKey] = [
                            'nombre' => $nombreCampo,
                            'materias_ids' => [],
                            'incluye_ingles' => false,
                            'incluye_artes' => false
                        ];
                    }
                    $campos[$campoKey]['materias_ids'][] = $mat['id'];
                }
                
                // --- PASO 4: LENGUAJES SOLO INCLUYE INGLÉS Y ARTES ---
                $campoLenguajesKey = null;
                foreach ($campos as $key => $campo) {
                    if ($campo['nombre'] === 'LENGUAJES') {
                        $campoLenguajesKey = $key;
                        break;
                    }
                }
                
                if ($campoLenguajesKey === null) {
                    $campoLenguajesKey = 'lenguajes';
                    $nombreLenguajes = ($lenguaMaternaMat !== null) ? 'LENGUAJES (sin Lengua Materna)' : 'LENGUAJES';
                    $campos[$campoLenguajesKey] = [
                        'nombre' => $nombreLenguajes,
                        'materias_ids' => [],
                        'incluye_ingles' => false,
                        'incluye_artes' => false
                    ];
                }
                
                // LENGUAJES ahora SOLO incluye inglés y artes (NO Lengua Materna/Español)
                $campos[$campoLenguajesKey]['incluye_ingles'] = !empty($materiasIngles);
                $campos[$campoLenguajesKey]['incluye_artes'] = !empty($materiasArtes);
                
                // --- PASO 5: CALCULAR PROMEDIOS PARA CADA CAMPO ---
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
                        'valor' => $valores,
                        'incluir_promedio' => true
                    ];
                }

                // --- PASO 6: AUSENCIAS ---
                if ($materiaAusencias) {
                    $valoresAusencias = $this->obtenerAusenciasAlumno($al['alumno_id'], $cicloId, $periodosAb, $vista, $colsSeleccionadas);
                    $al['columnas'][] = ['key' => 'mat_' . $materiaAusencias['id'], 'valor' => $valoresAusencias, 'incluir_promedio' => false];
                }
            }

            // Promedio general redondeado (excluye columnas marcadas como incluir_promedio = false, p.ej. Ausencias)
            $todos = [];
            foreach ($al['columnas'] as $col) {
                if (isset($col['incluir_promedio']) && $col['incluir_promedio'] === false) {
                    continue;
                }
                foreach ($col['valor'] as $v) {
                    if ($v !== null) $todos[] = $v;
                }
            }
            $promGeneral = !empty($todos) ? array_sum($todos) / count($todos) : null;
            $al['promedio_general'] = $promGeneral !== null ? $this->redondearNota($promGeneral) : null;
        }

        // ============================================================
        // ENCABEZADOS
        // ============================================================
        $encabezados = [];
        if ($agrupacion === 'materia') {
            // Lengua Materna/Español
            foreach ($materiasBase as $mat) {
                if (in_array($mat['nombre'], $nombresLengua)) {
                    $label = $seccion === 'secundaria' ? 'Español' : 'Lengua Materna';
                    $encabezados[] = ['key' => 'mat_' . $mat['id'], 'label' => $label];
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
                if (!in_array($mat['nombre'], $nombresLengua)) {
                    $encabezados[] = ['key' => 'mat_' . $mat['id'], 'label' => $mat['nombre']];
                }
            }
            // Ausencias
            if ($materiaAusencias) {
                $encabezados[] = ['key' => 'mat_' . $materiaAusencias['id'], 'label' => $materiaAusencias['nombre']];
            }
        } else {
            // Campos formativos
            // NOTA: $campos aquí es el valor que quedó tras el último alumno
            // procesado en el foreach de arriba. Como $materiasBase (y por
            // lo tanto $lenguaMaternaMat) es igual para todo el grupo, esto
            // es consistente entre alumnos, pero si el grupo no tiene
            // alumnos, $campos nunca se calculó y los encabezados saldrían
            // vacíos. Por eso se recalcula aquí de forma independiente.
            $lenguaMaternaMatHdr = null;
            $otrasMateriasBaseHdr = [];
            foreach ($materiasBase as $mat) {
                if (in_array($mat['nombre'], $nombresLengua)) {
                    $lenguaMaternaMatHdr = $mat;
                } else {
                    $otrasMateriasBaseHdr[] = $mat;
                }
            }

            $camposHdr = [];
            if ($lenguaMaternaMatHdr !== null) {
                $nombreLengua = $seccion === 'secundaria' ? 'ESPAÑOL' : 'LENGUA MATERNA';
                $camposHdr['lengua_materna'] = ['nombre' => $nombreLengua];
            }
            foreach ($otrasMateriasBaseHdr as $mat) {
                $campoKey = $mat['campo_id'] ?? 'sin_campo';
                $nombreCampo = $mat['campo_nombre'] ?? 'Sin campo';
                if (!isset($camposHdr[$campoKey])) {
                    $camposHdr[$campoKey] = ['nombre' => $nombreCampo];
                }
            }
            $tieneLenguajes = false;
            foreach ($camposHdr as $c) {
                if ($c['nombre'] === 'LENGUAJES') { $tieneLenguajes = true; break; }
            }
            if (!$tieneLenguajes && (!empty($materiasIngles) || !empty($materiasArtes))) {
                $nombreLenguajes = ($lenguaMaternaMatHdr !== null) ? 'LENGUAJES (sin Lengua Materna)' : 'LENGUAJES';
                $camposHdr['lenguajes'] = ['nombre' => $nombreLenguajes];
            }

            foreach ($camposHdr as $campoKey => $campoData) {
                $encabezados[] = [
                    'key' => 'campo_' . $campoKey,
                    'label' => $campoData['nombre']
                ];
            }
            // Ausencias
            if ($materiaAusencias) {
                $encabezados[] = ['key' => 'mat_' . $materiaAusencias['id'], 'label' => $materiaAusencias['nombre']];
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