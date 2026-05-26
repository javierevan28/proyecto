<?php
// models/AsignacionModel.php

class AsignacionModel {

    private mysqli $db;

    public function __construct(mysqli $db) {
        $this->db = $db;
    }

    public function listarPorCiclo(int $cicloId): array {
        $stmt = $this->db->prepare("
            SELECT a.id, a.seccion, a.grado, a.grupo, a.orden, a.activo,
                   m.nombre   AS materia_nombre,
                   m.es_ingles, m.es_artes, m.es_higiene,
                   cf.nombre  AS campo_formativo_nombre,
                   GROUP_CONCAT(
                       CONCAT(p.nombre,' ',p.apellido_paterno)
                       ORDER BY p.apellido_paterno SEPARATOR ', '
                   ) AS maestros,
                   MAX(am.es_titular) AS hay_titular
            FROM asignaciones a
            JOIN materias           m   ON m.id  = a.materia_id
            LEFT JOIN campos_formativos cf  ON cf.id = a.campo_formativo_id
            LEFT JOIN asignacion_maestros am ON am.asignacion_id = a.id
            LEFT JOIN profesores          p  ON p.id = am.profesor_id
            WHERE a.ciclo_id = ?
            GROUP BY a.id
            ORDER BY a.seccion, a.grado, a.grupo, a.orden
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

    public function crearLote(array $datos): array {
        $cicloId = (int)($datos['ciclo_id'] ?? 0);
        $seccion = trim($datos['seccion']   ?? '');
        $grado   = (int)($datos['grado']    ?? 0);
        $grupo   = trim($datos['grupo']     ?? '');

        if ($cicloId <= 0)  return ['error' => 'El ciclo es obligatorio'];
        if ($seccion === '') return ['error' => 'La sección es obligatoria'];
        if ($grado   <= 0)  return ['error' => 'El grado es obligatorio'];
        if ($grupo   === '') return ['error' => 'El grupo es obligatorio'];

        $materiasData = $datos['materia'] ?? [];
        if (empty($materiasData)) return ['error' => 'Selecciona al menos una materia'];

        $this->db->begin_transaction();
        try {
            $creadas  = 0;
            $omitidas = 0;

            foreach ($materiasData as $materiaId => $mDatos) {
                $materiaId  = (int)$materiaId;
                $profesorId = (int)($mDatos['profesor_id']        ?? 0);
                $esTitular  = (int)($mDatos['es_titular']         ?? 0);
                $campoId    = (int)($mDatos['campo_formativo_id']  ?? 0) ?: null;
                $orden      = (int)($mDatos['orden']              ?? 0);
                $subcompId  = (int)($mDatos['subcomponente_id']   ?? 0);
                $aspectos   = array_filter(
                    array_map('trim', (array)($mDatos['aspectos'] ?? []))
                );

                // Verificar si ya existe
                $stmtCheck = $this->db->prepare("
                    SELECT id FROM asignaciones
                    WHERE ciclo_id=? AND materia_id=? AND seccion=? AND grado=? AND grupo=?
                    LIMIT 1
                ");
                $stmtCheck->bind_param('iisis', $cicloId, $materiaId, $seccion, $grado, $grupo);
                $stmtCheck->execute();
                $existe = $stmtCheck->get_result();

                if ($existe->num_rows > 0) {
                    $asigId = (int)$existe->fetch_assoc()['id'];
                    $omitidas++;
                } else {
                    $stmtIns = $this->db->prepare("
                        INSERT INTO asignaciones
                            (ciclo_id, materia_id, campo_formativo_id, seccion, grado, grupo, orden)
                        VALUES (?, ?, ?, ?, ?, ?, ?)
                    ");
                    $stmtIns->bind_param('iiisisi', $cicloId, $materiaId, $campoId, $seccion, $grado, $grupo, $orden);
                    if (!$stmtIns->execute()) throw new Exception('Error al crear asignación: ' . $stmtIns->error);
                    $asigId = (int)$this->db->insert_id;
                    $creadas++;
                }

                // Asignar maestro
                if ($profesorId > 0) {
                    $stmtM = $this->db->prepare("
                        INSERT INTO asignacion_maestros (asignacion_id, profesor_id, es_titular)
                        VALUES (?, ?, ?)
                        ON DUPLICATE KEY UPDATE es_titular = VALUES(es_titular)
                    ");
                    $stmtM->bind_param('iii', $asigId, $profesorId, $esTitular);
                    if (!$stmtM->execute()) throw new Exception('Error al asignar maestro');
                }

                // Flags de la materia
                $stmtFlags = $this->db->prepare(
                    "SELECT es_artes, es_ingles FROM materias WHERE id = ? LIMIT 1"
                );
                $stmtFlags->bind_param('i', $materiaId);
                $stmtFlags->execute();
                $flags = $stmtFlags->get_result()->fetch_assoc();

                // Subcomponente de Artes
                if ($flags && (int)$flags['es_artes'] && $subcompId > 0) {
                    $stmtA = $this->db->prepare("
                        INSERT INTO asignacion_artes (asignacion_id, subcomponente_id)
                        VALUES (?, ?)
                        ON DUPLICATE KEY UPDATE subcomponente_id = VALUES(subcomponente_id)
                    ");
                    $stmtA->bind_param('ii', $asigId, $subcompId);
                    if (!$stmtA->execute()) throw new Exception('Error al asignar subcomponente');
                }

                // Aspectos de Inglés
                if ($flags && (int)$flags['es_ingles'] && !empty($aspectos)) {
                    $stmtDel = $this->db->prepare(
                        "DELETE FROM asignacion_ingles_aspectos WHERE asignacion_id = ?"
                    );
                    $stmtDel->bind_param('i', $asigId);
                    $stmtDel->execute();

                    $stmtI = $this->db->prepare(
                        "INSERT INTO asignacion_ingles_aspectos (asignacion_id, nombre, orden) VALUES (?, ?, ?)"
                    );
                    $ordenAsp = 1;
                    foreach ($aspectos as $aspNombre) {
                        $stmtI->bind_param('ssi', $asigId, $aspNombre, $ordenAsp);
                        if (!$stmtI->execute()) throw new Exception('Error al agregar aspecto de Inglés');
                        $ordenAsp++;
                    }
                }
            }

            $this->db->commit();
            return ['success' => true, 'creadas' => $creadas, 'omitidas' => $omitidas];

        } catch (Exception $e) {
            $this->db->rollback();
            return ['error' => $e->getMessage()];
        }
    }

    public function toggleActivo(int $id, int $activo): array {
        $stmt = $this->db->prepare(
            "UPDATE asignaciones SET activo = ? WHERE id = ?"
        );
        $stmt->bind_param('ii', $activo, $id);

        if ($stmt->execute()) return ['success' => true];
        return ['error' => 'Error al actualizar el estado'];
    }
}
