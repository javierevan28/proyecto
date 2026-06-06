<?php
require 'vendor/autoload.php'; // Asegúrate de tener DOMPDF instalado

use Dompdf\Dompdf;
use Dompdf\Options;
use mysqli;

// 1. CONEXIÓN A LA BASE DE DATOS
$conexion = new mysqli("localhost", "root", "", "escuela");

// Verificar conexión
if ($conexion->connect_error) {
    die("Error de conexión: " . $conexion->connect_error);
}

// 2. CONSULTAR LOS USUARIOS
$sql = "SELECT id, username, rol_id, activo, creado_en FROM users ORDER BY id";
$resultado = $conexion->query($sql);

// 3. PREPARAR EL HTML PARA EL PDF
$html = '
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Reporte de Usuarios</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
        }
        h1 {
            color: #2c3e50;
            text-align: center;
            border-bottom: 3px solid #3498db;
            padding-bottom: 10px;
        }
        .fecha {
            text-align: right;
            font-size: 12px;
            color: #7f8c8d;
            margin-bottom: 20px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th {
            background-color: #3498db;
            color: white;
            padding: 12px;
            text-align: left;
            font-size: 14px;
        }
        td {
            border: 1px solid #ddd;
            padding: 8px;
            font-size: 12px;
        }
        tr:nth-child(even) {
            background-color: #f2f2f2;
        }
        tr:hover {
            background-color: #e8f4f8;
        }
        .activo {
            color: green;
            font-weight: bold;
        }
        .inactivo {
            color: red;
            font-weight: bold;
        }
        .footer {
            text-align: center;
            font-size: 10px;
            color: #7f8c8d;
            margin-top: 30px;
            border-top: 1px solid #ddd;
            padding-top: 10px;
        }
    </style>
</head>
<body>
    <h1>📋 REPORTE DE USUARIOS</h1>
    <div class="fecha">Generado: ' . date('d/m/Y H:i:s') . '</div>
    
    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Nombre de Usuario</th>
                <th>Rol ID</th>
                <th>Estado</th>
                <th>Fecha de Creación</th>
            </tr>
        </thead>
        <tbody>
';

// Verificar si hay datos
if ($resultado->num_rows > 0) {
    while ($fila = $resultado->fetch_assoc()) {
        // Determinar estado (activo/inactivo)
        $estado = ($fila['activo'] == 1) 
            ? '<span class="activo">✓ Activo</span>' 
            : '<span class="inactivo">✗ Inactivo</span>';
        
        // Determinar rol (opcional - puedes personalizar según tu tabla roles)
        $rol_nombre = '';
        switch($fila['rol_id']) {
            case 1: $rol_nombre = 'Super Admin'; break;
            case 2: $rol_nombre = 'Admin'; break;
            case 3: $rol_nombre = 'Usuario'; break;
            case 4: $rol_nombre = 'Invitado'; break;
            default: $rol_nombre = 'Rol ' . $fila['rol_id'];
        }
        
        $html .= '<tr>';
        $html .= '<td>' . $fila['id'] . '</td>';
        $html .= '<td>' . htmlspecialchars($fila['username']) . '</td>';
        $html .= '<td>' . $rol_nombre . '</td>';
        $html .= '<td>' . $estado . '</td>';
        $html .= '<td>' . date('d/m/Y H:i', strtotime($fila['creado_en'])) . '</td>';
        $html .= '</tr>';
    }
} else {
    $html .= '<tr><td colspan="5" style="text-align: center;">No hay usuarios registrados</td></tr>';
}

$html .= '
        </tbody>
    </table>
    
    <div class="footer">
        Total de usuarios: ' . $resultado->num_rows . '<br>
        Sistema Escuela - Reporte generado automáticamente
    </div>
</body>
</html>
';

// 4. CERRAR CONEXIÓN
$conexion->close();

// 5. CONFIGURAR Y GENERAR EL PDF
$options = new Options();
$options->set('defaultFont', 'Arial');
$options->set('isHtml5ParserEnabled', true);
$options->set('isRemoteEnabled', true); // Si necesitas cargar imágenes externas

$dompdf = new Dompdf($options);
$dompdf->loadHtml($html);
$dompdf->setPaper('A4', 'portrait'); // Tamaño carta, vertical

// Renderizar el PDF
$dompdf->render();

// 6. ENVIAR AL NAVEGADOR (descarga automática)
$dompdf->stream("reporte_usuarios_" . date('Ymd_His') . ".pdf", array("Attachment" => true));

// Si prefieres verlo en el navegador (no descarga automática):
// $dompdf->stream("reporte_usuarios.pdf", array("Attachment" => false));
?>