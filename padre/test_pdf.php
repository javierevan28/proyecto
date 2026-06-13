<?php
// padre/test_pdf.php
require_once __DIR__ . '/../vendor/autoload.php';

echo "Autoload cargado correctamente<br>";

// Probar TCPDF
if (class_exists('TCPDF')) {
    echo "✓ TCPDF está disponible<br>";
} else {
    echo "✗ TCPDF NO está disponible<br>";
}

// Probar Dompdf
if (class_exists('Dompdf\Dompdf')) {
    echo "✓ Dompdf está disponible<br>";
} else {
    echo "✗ Dompdf NO está disponible<br>";
}
