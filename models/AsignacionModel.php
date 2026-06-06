<?php
// models/AsignacionModel.php

class AsignacionModel {

    private mysqli $db;

    public function __construct(mysqli $db) {
        $this->db = $db;
    }

    public function listarPorCiclo(int $cicloId): array {
        $stmt = $this->db->prepare("
            SELECT a.id, a.seccion, a.grado, a.grupo, a.orden, a.activo, a.campo_formativo_id,
                   m.id AS materia_id, m.nombre AS materia_nombre,
                   m.es_ingles, m.es_artes, m.es_higiene,
                   cf.nombre AS campo_formativo_nombre,
                   GROUP_CONCAT(
                       DISTINCT CONCAT(p.nombre,' ',p.apellido_paterno)
                       ORDER BY p.apellido_paterno SEPARATOR ', '
                   ) AS maestros,
                   MAX(am.es_titular) AS hay_titular,
                   aa.subcomponente_id,
                   GROUP_CONCAT(DISTINCT aia.nombre ORDER BY aia.orden SEPARATOR '|') AS aspectos_ingles
            FROM asignaciones a
            JOIN materias m ON m.id = a.materia_id
            LEFT JOIN campos_formativos cf ON cf.id = a.campo_formativo_id
            LEFT JOIN asignacion_maestros am ON am.asignacion_id = a.id
            LEFT JOIN profesores p ON p.id = am.profesor_id
            LEFT JOIN asignacion_artes aa ON aa.asignacion_id = a.id
            LEFT JOIN asignacion_ingles_aspectos aia ON aia.asignacion_id = a.id
            WHERE a.ciclo_id = ?
            GROUP BY a.id
            ORDER BY a.seccion, a.grado, a.grupo, a.orden, m.nombre
        ");
        $stmt->bind_param('i', $cicloId);
        $stmt->execute();
        $res  = $stmt->get_result();
        $rows = [];
        while ($row = $res->fetch_assoc()) $rows[] = $row;
        return $rows;
    }

    public function listarPorCicloAgrupado(int $cicloId): array {
        $rows     = $this->listarPorCiclo($cicloId);
        $agrupado = [];
        foreach ($rows as $r) {
            $key = $r['seccion'] . '-' . $r['grado'] . '-' . $r['grupo'];
            $agrupado[$key][] = $r;
        }
        return $agrupado;
    }

    // ============================================================
    // HELPER: leer orden de grados_materias
    // ============================================================
    private function obtenerOrdenDeGrado(string $seccion, int $grado, int $materiaId): int {
        $stmt = $this->db->prepare("
            SELECT orden FROM grados_materias
            WHERE seccion = ? AND grado = ? AND materia_id = ?
            LIMIT 1
        ");
        $stmt->bind_param('sii', $seccion, $grado, $materiaId);
        $stmt->execute();
        $row = $stmt->get_result()->fetch_assoc();
        return $row ? (int)$row['orden'] : 0;
    }

    // ============================================================
    // HELPER: eliminar asignación y todas sus tablas hijas
    // ============================================================
    private function eliminarAsignacion(int $asigId): void {
        $this->db->query("DELETE FROM asignacion_maestros        WHERE asignacion_id = $asigId");
        $this->db->query("DELETE FROM asignacion_artes           WHERE asignacion_id = $asigId");
        $this->db->query("DELETE FROM asignacion_ingles_aspectos WHERE asignacion_id = $asigId");
        $this->db->query("DELETE FROM asignacion_aspectos        WHERE asignacion_id = $asigId");
        $this->db->query("DELETE FROM asignaciones               WHERE id            = $asigId");
    }

    // ============================================================
    // HELPER: insertar los 6 aspectos estándar al crear asignación
    // ============================================================
    private function insertarAspectosEstandar(int $asigId): void {
        $aspectos = [
            ['Examen',                 50.00, 1],
            ['Tareas',                 10.00, 2],
            ['Participación',          10.00, 3],
            ['Evaluación Parcial',     10.00, 4],
            ['Proyecto',               10.00, 5],
            ['Trabajo y Exposiciones', 10.00, 6],
        ];
        $stmt = $this->db->prepare("
            INSERT IGNORE INTO asignacion_aspectos (asignacion_id, nombre, porcentaje, orden)
            VALUES (?, ?, ?, ?)
        ");
        foreach ($aspectos as [$nombre, $porcentaje, $orden]) {
            $stmt->bind_param('isdi', $asigId, $nombre, $porcentaje, $orden);
            $stmt->execute();
        }
    }

    // ============================================================
    // crearLote
    // ============================================================
    public function crearLote(array $datos): array {
        $cicloId = (int)($datos['ciclo_id'] ?? 0);
        $seccion = trim($datos['seccion']   ?? '');
        $grado   = (int)($datos['grado']    ?? 0);
        $grupo   = trim($datos['grupo']     ?? '');

        if ($cicloId <= 0) return ['error' => 'El ciclo es obligatorio'];
        if ($seccion === '') return ['error' => 'La sección es obligatoria'];
        if ($grado   <= 0)  return ['error' => 'El grado es obligatorio'];
        if ($grupo   === '') return ['error' => 'El grupo es obligatorio'];

        $materiasData        = $datos['materia']              ?? [];
        $materiasDisponibles = array_map('intval', (array)($datos['materias_disponibles'] ?? []));
        $materiasCheck       = array_map('intval', (array)($datos['materias_check']       ?? []));

        $this->db->begin_transaction();
        try {
            $eliminadas   = 0;
            $creadas      = 0;
            $actualizadas = 0;

            // PASO 1: Eliminar asignaciones de materias desmarcadas
            if (!empty($materiasDisponibles)) {
                $desmarcadas = array_diff($materiasDisponibles, $materiasCheck);
                foreach ($desmarcadas as $matId) {
                    $stmtB = $this->db->prepare("
                        SELECT id FROM asignaciones
                        WHERE ciclo_id = ? AND materia_id = ? AND seccion = ? AND grado = ? AND grupo = ?
                        LIMIT 1
                    ");
                    $stmtB->bind_param('iisis', $cicloId, $matId, $seccion, $grado, $grupo);
                    $stmtB->execute();
                    $row = $stmtB->get_result()->fetch_assoc();
                    if ($row) {
                        $this->eliminarAsignacion((int)$row['id']);
                        $eliminadas++;
                    }
                }
            }

            // PASO 2: Crear o actualizar materias marcadas
            foreach ($materiasData as $materiaId => $mDatos) {
                $materiaId  = (int)$materiaId;
                $profesorId = (int)($mDatos['profesor_id']       ?? 0);
                $esTitular  = (int)($mDatos['es_titular']         ?? 0);
                $campoId    = (int)($mDatos['campo_formativo_id'] ?? 0);
                $campoId    = $campoId > 0 ? $campoId : null;
                $subcompId  = (int)($mDatos['subcomponente_id']   ?? 0);
                $aspectos   = array_filter(array_map('trim', (array)($mDatos['aspectos'] ?? [])));

                // Orden siempre de grados_materias
                $orden = $this->obtenerOrdenDeGrado($seccion, $grado, $materiaId);

                // ¿Ya existe?
                $stmtChk = $this->db->prepare("
                    SELECT id FROM asignaciones
                    WHERE ciclo_id = ? AND materia_id = ? AND seccion = ? AND grado = ? AND grupo = ?
                    LIMIT 1
                ");
                $stmtChk->bind_param('iisis', $cicloId, $materiaId, $seccion, $grado, $grupo);
                $stmtChk->execute();
                $existe = $stmtChk->get_result();

                if ($existe->num_rows > 0) {
                    $asigId = (int)$existe->fetch_assoc()['id'];
                    $stmtU  = $this->db->prepare("
                        UPDATE asignaciones
                        SET campo_formativo_id = ?, orden = ?, activo = 1
                        WHERE id = ?
                    ");
                    $stmtU->bind_param('iii', $campoId, $orden, $asigId);
                    if (!$stmtU->execute()) throw new Exception('Error al actualizar asignación: ' . $stmtU->error);
                    $actualizadas++;
                } else {
                    $stmtI = $this->db->prepare("
                        INSERT INTO asignaciones
                            (ciclo_id, materia_id, campo_formativo_id, seccion, grado, grupo, orden, activo)
                        VALUES (?, ?, ?, ?, ?, ?, ?, 1)
                    ");
                    $stmtI->bind_param('iiisisi', $cicloId, $materiaId, $campoId, $seccion, $grado, $grupo, $orden);
                    if (!$stmtI->execute()) throw new Exception('Error al crear asignación: ' . $stmtI->error);
                    $asigId = (int)$this->db->insert_id;
                    $creadas++;

                    // Insertar aspectos estándar automáticamente
                    $this->insertarAspectosEstandar($asigId);
                }

                // MAESTRO
                if ($profesorId > 0) {
                    $stmtCM = $this->db->prepare("
                        SELECT id FROM asignacion_maestros
                        WHERE asignacion_id = ? AND profesor_id = ? LIMIT 1
                    ");
                    $stmtCM->bind_param('ii', $asigId, $profesorId);
                    $stmtCM->execute();
                    if ($stmtCM->get_result()->num_rows > 0) {
                        $stmtUM = $this->db->prepare("
                            UPDATE asignacion_maestros SET es_titular = ?
                            WHERE asignacion_id = ? AND profesor_id = ?
                        ");
                        $stmtUM->bind_param('iii', $esTitular, $asigId, $profesorId);
                        if (!$stmtUM->execute()) throw new Exception('Error al actualizar maestro');
                    } else {
                        $stmtIM = $this->db->prepare("
                            INSERT INTO asignacion_maestros (asignacion_id, profesor_id, es_titular)
                            VALUES (?, ?, ?)
                        ");
                        $stmtIM->bind_param('iii', $asigId, $profesorId, $esTitular);
                        if (!$stmtIM->execute()) throw new Exception('Error al asignar maestro');
                    }
                }

                // FLAGS
                $stmtF = $this->db->prepare("SELECT es_artes, es_ingles FROM materias WHERE id = ? LIMIT 1");
                $stmtF->bind_param('i', $materiaId);
                $stmtF->execute();
                $flags = $stmtF->get_result()->fetch_assoc();

                // ARTES
                if ($flags && (int)$flags['es_artes'] && $subcompId > 0) {
                    $stmtCA = $this->db->prepare("SELECT id FROM asignacion_artes WHERE asignacion_id = ? LIMIT 1");
                    $stmtCA->bind_param('i', $asigId);
                    $stmtCA->execute();
                    if ($stmtCA->get_result()->num_rows > 0) {
                        $stmtUA = $this->db->prepare("UPDATE asignacion_artes SET subcomponente_id = ? WHERE asignacion_id = ?");
                        $stmtUA->bind_param('ii', $subcompId, $asigId);
                        if (!$stmtUA->execute()) throw new Exception('Error al actualizar subcomponente de Artes');
                    } else {
                        $stmtIA = $this->db->prepare("INSERT INTO asignacion_artes (asignacion_id, subcomponente_id) VALUES (?, ?)");
                        $stmtIA->bind_param('ii', $asigId, $subcompId);
                        if (!$stmtIA->execute()) throw new Exception('Error al insertar subcomponente de Artes');
                    }
                }

                // INGLÉS — aspectos personalizados
                if ($flags && (int)$flags['es_ingles'] && !empty($aspectos)) {
                    $stmtDI = $this->db->prepare("DELETE FROM asignacion_ingles_aspectos WHERE asignacion_id = ?");
                    $stmtDI->bind_param('i', $asigId);
                    $stmtDI->execute();
                    $stmtII = $this->db->prepare("
                        INSERT INTO asignacion_ingles_aspectos (asignacion_id, nombre, orden)
                        VALUES (?, ?, ?)
                    ");
                    $ord = 1;
                    foreach ($aspectos as $aspNombre) {
                        if ($aspNombre !== '') {
                            $stmtII->bind_param('isi', $asigId, $aspNombre, $ord);
                            if (!$stmtII->execute()) throw new Exception('Error al agregar aspecto de Inglés');
                            $ord++;
                        }
                    }
                }
            }

            $this->db->commit();
            return [
                'success'      => true,
                'creadas'      => $creadas,
                'actualizadas' => $actualizadas,
                'eliminadas'   => $eliminadas,
                'total'        => $creadas + $actualizadas,
            ];

        } catch (Exception $e) {
            $this->db->rollback();
            return ['error' => $e->getMessage()];
        }
    }

    public function toggleActivo(int $id, int $activo): array {
        $stmt = $this->db->prepare("UPDATE asignaciones SET activo = ? WHERE id = ?");
        $stmt->bind_param('ii', $activo, $id);
        return $stmt->execute() ? ['success' => true] : ['error' => 'Error al actualizar el estado'];
    }

    public function listarPorProfesor(int $profesorId, int $cicloId): array {
        $stmt = $this->db->prepare("
            SELECT a.id, a.seccion, a.grado, a.grupo, a.orden, a.campo_formativo_id,
                   m.id AS materia_id, m.nombre AS materia_nombre,
                   cf.nombre AS campo_formativo_nombre,
                   am.es_titular,
                   aa.subcomponente_id,
                   s.nombre AS subcomponente_nombre
            FROM asignaciones a
            JOIN materias m ON m.id = a.materia_id
            LEFT JOIN campos_formativos cf ON cf.id = a.campo_formativo_id
            JOIN asignacion_maestros am ON am.asignacion_id = a.id
            LEFT JOIN asignacion_artes aa ON aa.asignacion_id = a.id
            LEFT JOIN subcomponentes_artes s ON s.id = aa.subcomponente_id
            WHERE a.ciclo_id = ? AND am.profesor_id = ? AND a.activo = 1
            ORDER BY a.seccion, a.grado, a.grupo, a.orden, m.nombre
        ");
        $stmt->bind_param('ii', $cicloId, $profesorId);
        $stmt->execute();
        return $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    }
}
?>