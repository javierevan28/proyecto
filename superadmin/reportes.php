<?php
// superadmin/reportes.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/CicloModel.php';
require_once __DIR__ . '/../models/ReporteModel.php';
requireRol([1]);

$db            = getConexion();
$cicloModelo   = new CicloModel($db);
$reporteModelo = new ReporteModel($db);

$cicloActivo = $cicloModelo->obtenerActivo();
$grupos      = $cicloActivo
    ? $reporteModelo->listarGrupos((int)$cicloActivo['id'])
    : [];

// Filtros
$grupoSel  = $_GET['grupo_sel']  ?? '';         // "primaria|2|A"
$vista      = $_GET['vista']      ?? 'trimestre'; // periodo | trimestre
$agrupacion = $_GET['agrupacion'] ?? 'campo';    // materia | campo

$seccion = '';
$grado   = 0;
$grupo   = '';

if ($grupoSel) {
    [$seccion, $grado, $grupo] = explode('|', $grupoSel);
    $grado = (int)$grado;
}

$reporte = null;
if ($cicloActivo && $seccion && $grado && $grupo) {
    $reporte = $reporteModelo->obtenerReporte(
        (int)$cicloActivo['id'],
        $seccion, $grado, $grupo,
        $vista, $agrupacion
    );
}

$pageTitle = 'Superadmin › Reportes';
$backLink  = 'dashboard.php';
include __DIR__ . '/../includes/header.php';
?>

<main class="container">

  <h2 class="section-title">Reportes de calificaciones</h2>

  <?php if (!$cicloActivo): ?>
    <p class="alert alert--error">⚠️ No hay ciclo escolar activo.</p>
  <?php else: ?>

  <!-- ── Filtros ────────────────────────────────────────────── -->
  <section class="card" style="margin-bottom:1.5rem;">
    <form method="GET" novalidate>
      <div style="display:grid; grid-template-columns:repeat(auto-fit,minmax(170px,1fr)); gap:1rem; align-items:end;">

        <div class="form-group">
          <label for="grupo_sel">Grupo *</label>
          <select id="grupo_sel" name="grupo_sel" required>
            <option value="">Selecciona…</option>
            <?php foreach ($grupos as $g): ?>
              <?php $val = $g['seccion'] . '|' . $g['grado'] . '|' . $g['grupo']; ?>
              <option value="<?= $val ?>" <?= $grupoSel === $val ? 'selected' : '' ?>>
                <?= ucfirst($g['seccion']) ?> — <?= $g['grado'] ?>° <?= $g['grupo'] ?>
              </option>
            <?php endforeach; ?>
          </select>
        </div>

        <div class="form-group">
          <label for="vista">Ver por</label>
          <select id="vista" name="vista">
            <option value="trimestre" <?= $vista === 'trimestre' ? 'selected' : '' ?>>Trimestre</option>
            <option value="periodo"   <?= $vista === 'periodo'   ? 'selected' : '' ?>>Periodo</option>
          </select>
        </div>

        <div class="form-group">
          <label for="agrupacion">Agrupar por</label>
          <select id="agrupacion" name="agrupacion">
            <option value="campo"   <?= $agrupacion === 'campo'   ? 'selected' : '' ?>>Campo formativo</option>
            <option value="materia" <?= $agrupacion === 'materia' ? 'selected' : '' ?>>Materia</option>
          </select>
        </div>

        <div class="form-group">
          <button class="btn" type="submit" style="margin-top:0;">Ver reporte</button>
        </div>

      </div>
    </form>
  </section>

  <!-- ── Tabla de reporte ───────────────────────────────────── -->
  <?php if ($reporte): ?>
    <?php
      $alumnos     = $reporte['alumnos'];
      $encabezados = $reporte['encabezados'];
      $colsTiempo  = $reporte['colsTiempo'];
      $esTriestre  = $reporte['vista'] === 'trimestre';
      $nCols       = count($colsTiempo);
    ?>

    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1rem;">
      <h3 style="color:var(--color-primary);">
        <?= ucfirst($seccion) ?> — <?= $grado ?>° <?= $grupo ?>
        &nbsp;|&nbsp;
        <?= $agrupacion === 'campo' ? 'Por campo formativo' : 'Por materia' ?>
        &nbsp;|&nbsp;
        <?= $vista === 'trimestre' ? 'Trimestral' : 'Por periodo' ?>
        (<?= count($alumnos) ?> alumnos)
      </h3>
      <a class="btn btn--sm btn--accent"
         href="reporte_excel.php?grupo_sel=<?= urlencode($grupoSel) ?>&vista=<?= $vista ?>&agrupacion=<?= $agrupacion ?>">
        ⬇ Exportar Excel
      </a>
    </div>

    <div style="overflow-x:auto;">
      <table class="data-table">
        <thead>
          <!-- Fila 1: encabezados de columnas (materia o campo) -->
          <tr>
            <th rowspan="2" style="text-align:left; min-width:180px;">Alumno</th>
            <?php foreach ($encabezados as $enc): ?>
              <th colspan="<?= $nCols ?>" style="font-size:.78rem; border-left:2px solid #2d5282;">
                <?= htmlspecialchars($enc['label']) ?>
              </th>
            <?php endforeach; ?>
            <th rowspan="2" style="background:#065f46; min-width:60px;">Promedio</th>
          </tr>
          <!-- Fila 2: P1-P6 o T1-T3 por cada columna -->
          <tr>
            <?php foreach ($encabezados as $enc): ?>
              <?php foreach ($colsTiempo as $ct): ?>
                <th style="font-size:.72rem; border-left:<?= $ct === $colsTiempo[0] ? '2px solid #2d5282' : 'none' ?>;">
                  <?= $ct ?>
                </th>
              <?php endforeach; ?>
            <?php endforeach; ?>
          </tr>
        </thead>
        <tbody>
          <?php foreach ($alumnos as $i => $al): ?>
            <tr>
              <td style="font-size:.82rem; text-align:left;">
                <?= htmlspecialchars($al['apellido_paterno'] . ' ' . ($al['apellido_materno'] ?? '') . ', ' . $al['nombre']) ?>
              </td>
              <?php foreach ($al['columnas'] as $col): ?>
                <?php foreach ($col['valor'] as $v): ?>
                  <td style="font-size:.82rem; text-align:center;
                             <?= ($v !== null && $v < 6) ? 'color:#991b1b; font-weight:bold;' : '' ?>
                             <?= array_key_first($col['valor']) === array_key_first($col['valor']) ? 'border-left:2px solid #e2e8f0;' : '' ?>">
                    <?= $v ?? '—' ?>
                  </td>
                <?php endforeach; ?>
              <?php endforeach; ?>
              <td style="text-align:center; font-weight:bold; font-size:.85rem;
                         background:#f0fdf4;
                         color:<?= ($al['promedio_general'] !== null && $al['promedio_general'] < 6) ? '#991b1b' : '#065f46' ?>;">
                <?= $al['promedio_general'] ?? '—' ?>
              </td>
            </tr>
          <?php endforeach; ?>
        </tbody>
      </table>
    </div>

  <?php elseif ($grupoSel): ?>
    <p class="empty-state">No hay datos para este grupo en el ciclo activo.</p>
  <?php endif; ?>

  <?php endif; ?>
</main>

<?php include __DIR__ . '/../includes/footer.php'; ?>