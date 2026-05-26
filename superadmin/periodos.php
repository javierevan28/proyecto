<?php
// superadmin/periodos.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/PeriodoAperturaModel.php';
require_once __DIR__ . '/../models/CicloModel.php';
requireRol([1]);

$db            = getConexion();
$periodoModelo = new PeriodoAperturaModel($db);
$cicloModelo   = new CicloModel($db);

$resultado   = null;
$cicloActivo = $cicloModelo->obtenerActivo();
$accion      = $_GET['accion'] ?? '';

// ── Acciones GET ──────────────────────────────────────────────
if ($cicloActivo) {

    if ($accion === 'abrir') {
        $periodo   = (int)($_GET['periodo'] ?? 0);
        $resultado = $periodoModelo->abrir((int)$cicloActivo['id'], $periodo);
        $msg = isset($resultado['success']) ? 'abierto' : 'error';
        header('Location: periodos.php?msg=' . $msg . '&detalle=' . urlencode($resultado['error'] ?? ''));
        exit;
    }

    if ($accion === 'cerrar') {
        $resultado = $periodoModelo->cerrar((int)$cicloActivo['id']);
        $msg = isset($resultado['success']) ? 'cerrado' : 'error';
        header('Location: periodos.php?msg=' . $msg . '&detalle=' . urlencode($resultado['error'] ?? ''));
        exit;
    }
}

$msgRedir  = $_GET['msg']     ?? '';
$msgDetall = $_GET['detalle'] ?? '';

// Datos para la vista
$periodos     = $cicloActivo
    ? $periodoModelo->listarPorCiclo((int)$cicloActivo['id'])
    : [];
$periodoAbierto = $cicloActivo
    ? $periodoModelo->obtenerAbierto((int)$cicloActivo['id'])
    : null;

// Indexar periodos existentes por número para fácil acceso en la vista
$periodosPorNum = [];
foreach ($periodos as $p) {
    $periodosPorNum[(int)$p['periodo']] = $p;
}

$pageTitle = 'Superadmin › Periodos';
$backLink  = 'dashboard.php';
$scripts   = ['/proyecto/js/modal.js'];
include __DIR__ . '/../includes/header.php';
?>

<!-- Modal de confirmación -->
<div class="modal-overlay" id="modalOverlay" role="dialog" aria-modal="true" aria-labelledby="modalTitle" hidden>
  <div class="modal">
    <h3 class="modal__title" id="modalTitle"></h3>
    <p  class="modal__body"  id="modalBody"></p>
    <div class="modal__actions">
      <a      class="btn modal__confirm" id="modalConfirm" href="#">Confirmar</a>
      <button class="btn modal__cancel"  id="modalCancel"  type="button">Cancelar</button>
    </div>
  </div>
</div>

<main class="container container--md">

  <!-- ── Mensajes ──────────────────────────────────────────────── -->
  <?php if ($msgRedir === 'abierto'): ?>
    <p class="alert alert--success" role="status">✅ Periodo abierto correctamente.</p>
  <?php elseif ($msgRedir === 'cerrado'): ?>
    <p class="alert alert--success" role="status">✅ Periodo cerrado correctamente.</p>
  <?php elseif ($msgRedir === 'error'): ?>
    <p class="alert alert--error"   role="alert">⚠️ <?= htmlspecialchars($msgDetall) ?></p>
  <?php endif; ?>

  <?php if (!$cicloActivo): ?>
    <p class="alert alert--error" role="alert">
      ⚠️ No hay un ciclo escolar activo.
      <a href="ciclos_escolares.php">Configura uno primero</a>.
    </p>
  <?php else: ?>

    <h2 class="section-title">
      Periodos — <?= htmlspecialchars($cicloActivo['nombre']) ?>
    </h2>

    <!-- Banner periodo abierto -->
    <?php if ($periodoAbierto): ?>
      <div class="ciclo-banner" style="margin-bottom:1.5rem;">
        <span class="ciclo-banner__label">
          📂 Periodo abierto actualmente:
          <strong>Periodo <?= $periodoAbierto['periodo'] ?></strong>
          <?php
            $num = (int)$periodoAbierto['periodo'];
            $trim = (int)ceil($num / 2);
          ?>
          — Trimestre <?= $trim ?>
        </span>
        <button
          class="btn btn--sm btn--danger js-modal-trigger ciclo-banner__link"
          type="button"
          style="background:#991b1b; color:#fff; text-decoration:none;"
          data-href="periodos.php?accion=cerrar"
          data-title="Cerrar periodo"
          data-body="¿Confirmas cerrar el Periodo <?= $periodoAbierto['periodo'] ?>? Los maestros ya no podrán capturar calificaciones.">
          Cerrar periodo
        </button>
      </div>
    <?php else: ?>
      <div class="ciclo-banner ciclo-banner--warn" style="margin-bottom:1.5rem;">
        <span class="ciclo-banner__label">⚠️ No hay ningún periodo abierto. Los maestros no pueden capturar calificaciones.</span>
      </div>
    <?php endif; ?>

    <!-- Tabla de 6 periodos con su trimestre -->
    <section class="card">
      <table class="data-table">
        <thead>
          <tr>
            <th>Periodo</th>
            <th>Trimestre</th>
            <th>Estado</th>
            <th>Abierto el</th>
            <th>Cerrado el</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <?php for ($p = 1; $p <= 6; $p++):
            $datos    = $periodosPorNum[$p] ?? null;
            $abierto  = $datos && (int)$datos['abierto'] === 1;
            $esActual = $periodoAbierto && (int)$periodoAbierto['periodo'] === $p;
            $trimestre = (int)ceil($p / 2);
            $urlAbrir  = 'periodos.php?accion=abrir&periodo=' . $p;
          ?>
            <tr <?= $esActual ? 'style="background:#f0fdf4;"' : '' ?>>
              <td><strong>Periodo <?= $p ?></strong></td>
              <td>Trimestre <?= $trimestre ?></td>
              <td>
                <?php if ($esActual): ?>
                  <span class="badge badge--active">🟢 Abierto</span>
                <?php elseif ($datos): ?>
                  <span class="badge badge--warn">Cerrado</span>
                <?php else: ?>
                  <span class="badge" style="background:#f1f5f9;color:#64748b;">Sin abrir</span>
                <?php endif; ?>
              </td>
              <td style="font-size:.82rem;">
                <?= $datos && $datos['abierto_en']
                    ? date('d/m/Y H:i', strtotime($datos['abierto_en']))
                    : '—'
                ?>
              </td>
              <td style="font-size:.82rem;">
                <?= $datos && $datos['cerrado_en']
                    ? date('d/m/Y H:i', strtotime($datos['cerrado_en']))
                    : '—'
                ?>
              </td>
              <td>
                <?php if ($esActual): ?>
                  <!-- Ya está abierto, no se puede abrir de nuevo -->
                  <span class="btn btn--sm btn--disabled">Abrir</span>
                <?php else: ?>
                  <button
                    class="btn btn--sm btn--success js-modal-trigger"
                    type="button"
                    data-href="<?= $urlAbrir ?>"
                    data-title="Abrir Periodo <?= $p ?>"
                    data-body="¿Confirmas abrir el Periodo <?= $p ?> (Trimestre <?= $trimestre ?>)?<?= $periodoAbierto ? ' El Periodo ' . $periodoAbierto['periodo'] . ' quedará cerrado automáticamente.' : '' ?>">
                    Abrir
                  </button>
                <?php endif; ?>
              </td>
            </tr>
          <?php endfor; ?>
        </tbody>
      </table>
    </section>

  <?php endif; ?>
</main>

<?php include __DIR__ . '/../includes/footer.php'; ?>