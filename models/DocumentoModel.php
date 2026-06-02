<?php
// models/DocumentoModel.php

class DocumentoModel {
    
    private mysqli $db;
    private string $uploadDir;
    
    public function __construct(mysqli $db) {
        $this->db = $db;
        $this->uploadDir = __DIR__ . '/../uploads/documentos/';
        
        // Crear directorio si no existe
        if (!file_exists($this->uploadDir)) {
            mkdir($this->uploadDir, 0755, true);
        }
    }
    
    // Tipos de documentos permitidos
    public function getTiposDocumentos(): array {
        return [
            'acta_nacimiento' => 'Acta de nacimiento',
            'comprobante_domicilio' => 'Comprobante de domicilio',
            'ine_padre' => 'INE del padre/tutor',
            'ine_madre' => 'INE de la madre',
            'fotografia' => 'Fotografía del alumno',
            'boleta_anterior' => 'Boleta de calificaciones (ciclo anterior)',
            'certificado_preescolar' => 'Certificado de preescolar (solo 1° primaria)',
            'certificado_primaria' => 'Certificado de primaria (solo 1° secundaria)',
            'carta_buena_conducta' => 'Carta de buena conducta',
            'carta_no_adeudo' => 'Carta de no adeudo',
            'contrato_adhesion' => 'Contrato de adhesión',
            'reglamento_escolar' => 'Reglamento escolar (firmado)',
            'curp_tutor' => 'CURP del tutor',
            'curp_alumno' => 'CURP del alumno',
            'ficha_inscripcion' => 'Ficha de inscripción'
        ];
    }
    
    // Subir documento
    public function subirDocumento(int $alumnoId, string $tipoDocumento, array $archivo, int $subidoPor, ?string $observaciones = null): array {
        // Validar tipo de documento
        $tiposValidos = array_keys($this->getTiposDocumentos());
        if (!in_array($tipoDocumento, $tiposValidos)) {
            return ['error' => 'Tipo de documento no válido'];
        }
        
        // Validar archivo
        if ($archivo['error'] !== UPLOAD_ERR_OK) {
            return ['error' => 'Error al subir el archivo'];
        }
        
        if ($archivo['size'] > 5242880) { // 5MB máximo
            return ['error' => 'El archivo no debe superar los 5MB'];
        }
        
        $extension = strtolower(pathinfo($archivo['name'], PATHINFO_EXTENSION));
        if ($extension !== 'pdf') {
            return ['error' => 'Solo se permiten archivos PDF'];
        }
        
        // Generar nombre único
        $nombreUnico = $alumnoId . '_' . $tipoDocumento . '_' . time() . '.pdf';
        $rutaCompleta = $this->uploadDir . $nombreUnico;
        $rutaRelativa = 'uploads/documentos/' . $nombreUnico;
        
        // Mover archivo
        if (!move_uploaded_file($archivo['tmp_name'], $rutaCompleta)) {
            return ['error' => 'Error al guardar el archivo'];
        }
        
        // Guardar en BD
        $stmt = $this->db->prepare("
            INSERT INTO documentos_alumnos (alumno_id, tipo_documento, nombre_archivo, ruta_archivo, tamano, observaciones, subido_por)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
                nombre_archivo = VALUES(nombre_archivo),
                ruta_archivo = VALUES(ruta_archivo),
                tamano = VALUES(tamano),
                observaciones = VALUES(observaciones),
                subido_por = VALUES(subido_por),
                fecha_subida = NOW()
        ");
        
        $tamano = $archivo['size'];
        $nombreOriginal = $archivo['name'];
        $stmt->bind_param('isssisi', $alumnoId, $tipoDocumento, $nombreOriginal, $rutaRelativa, $tamano, $observaciones, $subidoPor);
        
        if ($stmt->execute()) {
            return ['success' => true, 'mensaje' => 'Documento subido correctamente'];
        }
        
        return ['error' => 'Error al guardar en la base de datos: ' . $stmt->error];
    }
    
    // Obtener documentos de un alumno
    public function getDocumentosPorAlumno(int $alumnoId): array {
        $stmt = $this->db->prepare("
            SELECT d.*, u.username as subido_por_nombre
            FROM documentos_alumnos d
            JOIN users u ON u.id = d.subido_por
            WHERE d.alumno_id = ? AND d.activo = 1
            ORDER BY d.tipo_documento
        ");
        $stmt->bind_param('i', $alumnoId);
        $stmt->execute();
        $result = $stmt->get_result();
        $documentos = [];
        while ($row = $result->fetch_assoc()) {
            $documentos[] = $row;
        }
        return $documentos;
    }
    
    // Obtener documento específico
    public function getDocumento(int $documentoId, int $alumnoId): ?array {
        $stmt = $this->db->prepare("
            SELECT * FROM documentos_alumnos 
            WHERE id = ? AND alumno_id = ? AND activo = 1
        ");
        $stmt->bind_param('ii', $documentoId, $alumnoId);
        $stmt->execute();
        $result = $stmt->get_result();
        return $result->fetch_assoc();
    }
    
    // Eliminar documento (soft delete)
    public function eliminarDocumento(int $documentoId, int $alumnoId): array {
        $stmt = $this->db->prepare("
            UPDATE documentos_alumnos SET activo = 0 
            WHERE id = ? AND alumno_id = ?
        ");
        $stmt->bind_param('ii', $documentoId, $alumnoId);
        
        if ($stmt->execute()) {
            return ['success' => true];
        }
        return ['error' => 'Error al eliminar el documento'];
    }
    
    // Verificar si un alumno tiene un tipo de documento
    public function tieneDocumento(int $alumnoId, string $tipoDocumento): bool {
        $stmt = $this->db->prepare("
            SELECT id FROM documentos_alumnos 
            WHERE alumno_id = ? AND tipo_documento = ? AND activo = 1
        ");
        $stmt->bind_param('is', $alumnoId, $tipoDocumento);
        $stmt->execute();
        return $stmt->get_result()->num_rows > 0;
    }
    
    // Obtener resumen de documentos por alumno (para admin)
    public function getResumenDocumentosPorAlumno(int $alumnoId): array {
        $tipos = $this->getTiposDocumentos();
        $documentosSubidos = $this->getDocumentosPorAlumno($alumnoId);
        
        $resumen = [];
        foreach ($tipos as $tipo => $nombre) {
            $encontrado = false;
            $docInfo = null;
            foreach ($documentosSubidos as $doc) {
                if ($doc['tipo_documento'] === $tipo) {
                    $encontrado = true;
                    $docInfo = $doc;
                    break;
                }
            }
            $resumen[$tipo] = [
                'nombre' => $nombre,
                'subido' => $encontrado,
                'documento' => $docInfo
            ];
        }
        
        return $resumen;
    }
}
?>