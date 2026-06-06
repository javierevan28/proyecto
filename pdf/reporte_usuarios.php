<?php
// Ajusta la ruta según dónde esté el vendor
// Si el vendor está en /opt/lampp/htdocs/proyecto/pdf/vendor/
require __DIR__ . '/vendor/autoload.php';

// Si el vendor está en /opt/lampp/htdocs/proyecto/vendor/
// require '/opt/lampp/htdocs/proyecto/vendor/autoload.php';

use Dompdf\Dompdf;
use Dompdf\Options;

// Conexión a BD
$conexion = new mysqli("localhost", "root", "", "escuela");

if ($conexion->connect_error) {
    die("Error de conexión: " . $conexion->connect_error);
}

$sql = "SELECT id, username, rol_id, activo, creado_en FROM users ORDER BY id";
$resultado = $conexion->query($sql);

$html = '
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Reporte de Usuarios</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { color: #2c3e50; text-align: center; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th { background-color: #3498db; color: white; padding: 10px; }
        td { border: 1px solid #ddd; padding: 8px; }
        .activo { color: green; font-weight: bold; }
    </style>
</head>
<body>
    <h1>REPORTE DE USUARIOS</h1>
    <p>Fecha: ' . date('d/m/Y H:i:s') . '</p>
    <table>
        <thead>
            <tr><th>ID</th><th>Usuario</th><th>Rol</th><th>Estado</th><th>Fecha Creación</th></tr>
        </thead>
        <tbody>';

while ($fila = $resultado->fetch_assoc()) {
    $estado = ($fila['activo'] == 1) ? '<span style="color:green;">✓ Activo</span>' : '<span style="color:red;">✗ Inactivo</span>';
    $html .= '<tr>';
    $html .= '<td>' . $fila['id'] . '</td>';
    $html .= '<td>' . htmlspecialchars($fila['username']) . '</td>';
    $html .= '<td>' . $fila['rol_id'] . '</td>';
    $html .= '<td>' . $estado . '</td>';
    $html .= '<td>' . $fila['creado_en'] . '</td>';
    $html .= '</tr>';
}

$html .= '</tbody>    赶
    <p>Total de usuarios: ' . $resultado->num_rows . '</p>
</body>
</html>';

$conexion->close();

// Generar PDF
$options = new Options();
$options->set('defaultFont', 'Arial');
$dompdf = new Dompdf($options);
$dompdf->loadHtml($html);
$dompdf->setPaper('A4', 'portrait');
$dompdf->render();

// Mostrar en navegador
$dompdf->stream("usuarios.pdf", array("Attachment" => false));
?>