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
$grupoSel   = $_GET['grupo_sel']  ?? '';
$vista      = $_GET['vista']      ?? 'trimestre';
$agrupacion = $_GET['agrupacion'] ?? 'campo';
$seleccion  = $_GET['seleccion']  ?? 'todos';

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
        $vista, $agrupacion, $seleccion
    );
}

// Opciones del select de periodo/trimestre según vista
$opcionesSeleccion = ['todos' => 'Todos'];
if ($vista === 'periodo') {
    for ($p = 1; $p <= 6; $p++) {
        $opcionesSeleccion[(string)$p] = 'Periodo ' . $p;
    }
} else {
    for ($t = 1; $t <= 3; $t++) {
        $opcionesSeleccion[(string)$t] = 'Trimestre ' . $t;
    }
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
      <div style="display:grid; grid-template-columns:repeat(auto-fit,minmax(160px,1fr)); gap:1rem; align-items:end;">

        <!-- Grupo -->
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

        <!-- Ver por -->
        <div class="form-group">
          <label for="vista">Ver por</label>
          <select id="vista" name="vista" onchange="this.form.submit()">
            <option value="trimestre" <?= $vista === 'trimestre' ? 'selected' : '' ?>>Trimestre</option>
            <option value="periodo"   <?= $vista === 'periodo'   ? 'selected' : '' ?>>Periodo</option>
          </select>
        </div>

        <!-- Periodo / Trimestre específico -->
        <div class="form-group">
          <label for="seleccion">
            <?= $vista === 'periodo' ? 'Periodo' : 'Trimestre' ?>
          </label>
          <select id="seleccion" name="seleccion">
            <?php foreach ($opcionesSeleccion as $val => $lbl): ?>
              <option value="<?= $val ?>" <?= $seleccion === (string)$val ? 'selected' : '' ?>>
                <?= $lbl ?>
              </option>
            <?php endforeach; ?>
          </select>
        </div>

        <!-- Agrupar por -->
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

  <!-- ── Tabla ──────────────────────────────────────────────── -->
  <?php if ($reporte): ?>
    <?php
      $alumnos          = $reporte['alumnos'];
      $encabezados      = $reporte['encabezados'];
      $colsSeleccionadas= $reporte['colsSeleccionadas'];
      $etiquetasCols    = $reporte['etiquetasCols'];
      $nCols            = count($colsSeleccionadas);
    ?>

    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1rem;">
      <h3 style="color:var(--color-primary); font-size:.95rem;">
        <?= ucfirst($seccion) ?> — <?= $grado ?>° <?= $grupo ?>
        &nbsp;·&nbsp;
        <?= $agrupacion === 'campo' ? 'Por campo formativo' : 'Por materia' ?>
        &nbsp;·&nbsp;
        <?= $seleccion === 'todos'
            ? ($vista === 'periodo' ? 'Todos los periodos' : 'Todos los trimestres')
            : ($vista === 'periodo' ? 'Periodo ' : 'Trimestre ') . $seleccion
        ?>
        &nbsp;(<?= count($alumnos) ?> alumnos)
      </h3>
      <a class="btn btn--sm btn--accent"
         href="reporte_excel.php?grupo_sel=<?= urlencode($grupoSel) ?>&vista=<?= $vista ?>&agrupacion=<?= $agrupacion ?>&seleccion=<?= $seleccion ?>">
        ⬇ Exportar Excel
      </a>
    </div>

    <div style="overflow-x:auto;">
      <table class="data-table">
        <thead>
          <!-- Fila 1: nombres de columnas -->
          <tr>
            <th rowspan="2" style="text-align:left; min-width:180px;">Alumno</th>
            <?php foreach ($encabezados as $enc): ?>
              <th colspan="<?= $nCols ?>"
                  style="font-size:.78rem; border-left:2px solid #2d5282; text-align:center;">
                <?= htmlspecialchars($enc['label']) ?>
              </th>
            <?php endforeach; ?>
            <th rowspan="2" style="background:#065f46; min-width:65px; text-align:center;">
              Promedio
            </th>
          </tr>
          <!-- Fila 2: P1/T1 etc por cada columna -->
          <tr>
            <?php foreach ($encabezados as $i => $enc): ?>
              <?php foreach ($etiquetasCols as $col => $lbl): ?>
                <th style="font-size:.72rem; text-align:center;
                           border-left:<?= $col === array_key_first($etiquetasCols) ? '2px solid #2d5282' : 'none' ?>;">
                  <?= $lbl ?>
                </th>
              <?php endforeach; ?>
            <?php endforeach; ?>
          </tr>
        </thead>
        <tbody>
          <?php foreach ($alumnos as $al): ?>
            <tr>
              <td style="font-size:.82rem; text-align:left;">
                <?= htmlspecialchars(
                  $al['apellido_paterno'] . ' ' .
                  ($al['apellido_materno'] ?? '') . ', ' .
                  $al['nombre']
                ) ?>
              </td>
              <?php foreach ($al['columnas'] as $j => $col): ?>
                <?php foreach ($col['valor'] as $v): ?>
                  <td style="text-align:center; font-size:.82rem;
                             border-left:<?= array_key_first($col['valor']) === array_key_first($col['valor']) && $j > 0 ? '1px solid #e2e8f0' : 'none' ?>;
                             <?= ($v !== null && $v < 6) ? 'color:#991b1b; font-weight:bold;' : '' ?>">
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