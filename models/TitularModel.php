<?php
// models/TitularModel.php

class TitularModel {

    private mysqli $db;

    public function __construct(mysqli $db) {
        $this->db = $db;
    }

    public function obtenerTitular(int $cicloId, string $seccion, int $grado, string $grupo): ?array {
        $stmt = $this->db->prepare("
            SELECT gt.id, gt.profesor_id, gt.asignacion_id,
                   p.nombre, p.apellido_paterno, p.apellido_materno
            FROM grupo_titular gt
            JOIN profesores p ON p.id = gt.profesor_id
            WHERE gt.ciclo_id = ? AND gt.seccion = ? AND gt.grado = ? AND gt.grupo = ?
            LIMIT 1
        ");
        $stmt->bind_param('isis', $cicloId, $seccion, $grado, $grupo);
        $stmt->execute();
        $res = $stmt->get_result();
        return $res->num_rows > 0 ? $res->fetch_assoc() : null;
    }

    public function asignarTitular(int $cicloId, int $asignacionId, int $profesorId, string $seccion, int $grado, string $grupo): array {
        $stmtP = $this->db->prepare("SELECT tipo FROM profesores WHERE id = ? LIMIT 1");
        $stmtP->bind_param('i', $profesorId);
        $stmtP->execute();
        $prof = $stmtP->get_result()->fetch_assoc();

        if (!$prof || $prof['tipo'] !== 'titular') {
            return ['error' => 'Solo un maestro de tipo Titular puede ser asignado como titular de grupo'];
        }

        $stmt = $this->db->prepare("
            INSERT INTO grupo_titular (ciclo_id, asignacion_id, profesor_id, seccion, grado, grupo)
            VALUES (?, ?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
                asignacion_id = VALUES(asignacion_id),
                profesor_id   = VALUES(profesor_id)
        ");
        $stmt->bind_param('iiisis', $cicloId, $asignacionId, $profesorId, $seccion, $grado, $grupo);

        if ($stmt->execute()) {
            return ['success' => true];
        }
        return ['error' => 'Error al asignar titular: ' . $stmt->error];
    }

    public function esTitularDeGrupo(int $profesorId, int $cicloId, string $seccion, int $grado, string $grupo): bool {
        $stmt = $this->db->prepare("
            SELECT id FROM grupo_titular
            WHERE profesor_id = ? AND ciclo_id = ? AND seccion = ? AND grado = ? AND grupo = ?
            LIMIT 1
        ");
        $stmt->bind_param('iisis', $profesorId, $cicloId, $seccion, $grado, $grupo);
        $stmt->execute();
        return $stmt->get_result()->num_rows > 0;
    }

    public function obtenerGruposTitular(int $profesorId, int $cicloId): array {
        $stmt = $this->db->prepare("
            SELECT seccion, grado, grupo
            FROM grupo_titular
            WHERE profesor_id = ? AND ciclo_id = ?
            ORDER BY seccion, grado, grupo
        ");
        $stmt->bind_param('ii', $profesorId, $cicloId);
        $stmt->execute();
        return $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    }

    public function obtenerAlumnosConCalTitular(int $cicloId, string $seccion, int $grado, string $grupo, int $periodo): array {
        $stmt = $this->db->prepare("
            SELECT al.id AS alumno_id,
                   al.nombre, al.apellido_paterno, al.apellido_materno,
                   al.matricula,
                   ct.socioemocional, ct.ausencias, ct.disciplina, ct.higiene
            FROM alumnos al
            LEFT JOIN calificaciones_titular ct
                ON  ct.alumno_id = al.id
                AND ct.ciclo_id  = ?
                AND ct.periodo   = ?
            WHERE al.seccion = ? AND al.grado = ? AND al.grupo = ?
            ORDER BY al.apellido_paterno, al.apellido_materno, al.nombre
        ");
        $stmt->bind_param('iisis', $cicloId, $periodo, $seccion, $grado, $grupo);
        $stmt->execute();
        return $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    }

    public function guardarCalificacionesTitular(int $cicloId, int $periodo, int $profesorId, string $seccion, array $datos): array {
        $esSecundaria = $seccion === 'secundaria';

        $stmt = $this->db->prepare("
            INSERT INTO calificaciones_titular
                (alumno_id, ciclo_id, periodo, socioemocional, ausencias, disciplina, higiene, capturado_por)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
                socioemocional = VALUES(socioemocional),
                ausencias      = VALUES(ausencias),
                disciplina     = VALUES(disciplina),
                higiene        = VALUES(higiene),
                capturado_por  = VALUES(capturado_por),
                actualizado_en = NOW()
        ");

        $errores = 0;
        foreach ($datos as $alumnoId => $vals) {
            $alumnoId      = (int)$alumnoId;
            $socioemocional = isset($vals['socioemocional']) && $vals['socioemocional'] !== ''
                ? (int)$vals['socioemocional'] : null;
            $ausencias      = isset($vals['ausencias']) && $vals['ausencias'] !== ''
                ? (int)$vals['ausencias'] : null;
            $disciplina     = isset($vals['disciplina']) && $vals['disciplina'] !== ''
                ? (int)$vals['disciplina'] : null;
            $higiene        = ($esSecundaria && isset($vals['higiene']) && $vals['higiene'] !== '')
                ? (int)$vals['higiene'] : null;

            if ($socioemocional !== null && ($socioemocional < 0 || $socioemocional > 10)) { $errores++; continue; }
            if ($disciplina !== null && ($disciplina < 0 || $disciplina > 10)) { $errores++; continue; }
            if ($higiene !== null && ($higiene < 0 || $higiene > 10)) { $errores++; continue; }
            if ($ausencias !== null && ($ausencias < 0 || $ausencias > 31)) { $errores++; continue; }

            $stmt->bind_param(
                'iiiiiiii',
                $alumnoId, $cicloId, $periodo,
                $socioemocional, $ausencias, $disciplina, $higiene,
                $profesorId
            );
            if (!$stmt->execute()) $errores++;
        }

        if ($errores > 0) {
            return ['error' => "Hubo $errores error(es) al guardar. Verifica que los valores sean correctos."];
        }
        return ['success' => true];
    }
}