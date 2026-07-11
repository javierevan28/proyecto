<?php
// superadmin/dashboard.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../models/CicloModel.php';
requireRol([1]);

$db          = getConexion();
$cicloModel  = new CicloModel($db);
$cicloActivo = $cicloModel->obtenerActivo();

$pageTitle = 'Sistema Escolar › Superadmin';
$backLink  = '';
include __DIR__ . '/../includes/header.php';
?>

<main class="container">

  <h2 class="section-title">¿Qué deseas hacer?</h2>

  <!-- ========== GESTIÓN DE USUARIOS ========== -->
  <h3 style="font-size:0.9rem; color:var(--color-muted); margin: 1rem 0 0.8rem 0;">👥 Gestión de usuarios</h3>
  <nav class="card-grid" aria-label="Menú de usuarios">

    <a class="nav-card" href="alta_padre_con_hijos.php">
      <span class="nav-card__icon" aria-hidden="true">👨‍👩‍👧‍👦</span>
      <h3 class="nav-card__title">Alta rápida (Padre + Hijos)</h3>
      <p class="nav-card__desc">Registra padre/tutor y hasta 6 hijos en un solo paso</p>
    </a>

    <a class="nav-card" href="alta_padre.php">
      <span class="nav-card__icon" aria-hidden="true">👨‍👩‍👧</span>
      <h3 class="nav-card__title">Dar de alta padre / tutor</h3>
      <p class="nav-card__desc">Registra un nuevo padre o tutor</p>
    </a>

    <a class="nav-card" href="alta_alumno.php">
      <span class="nav-card__icon" aria-hidden="true">🎒</span>
      <h3 class="nav-card__title">Dar de alta alumno</h3>
      <p class="nav-card__desc">Registra un nuevo alumno</p>
    </a>

    <a class="nav-card" href="alta_profesor.php">
      <span class="nav-card__icon" aria-hidden="true">👨‍🏫</span>
      <h3 class="nav-card__title">Dar de alta profesor</h3>
      <p class="nav-card__desc">Registra un nuevo profesor</p>
    </a>

  </nav>

  <!-- ========== LISTADOS ========== -->
  <h3 style="font-size:0.9rem; color:var(--color-muted); margin: 1rem 0 0.8rem 0;">📋 Listados</h3>
  <nav class="card-grid" aria-label="Menú de listados">

    <a class="nav-card" href="lista_padres.php">
      <span class="nav-card__icon" aria-hidden="true">📋</span>
      <h3 class="nav-card__title">Ver padres registrados</h3>
      <p class="nav-card__desc">Consulta todos los padres y tutores</p>
    </a>

    <a class="nav-card" href="lista_alumnos.php">
      <span class="nav-card__icon" aria-hidden="true">📚</span>
      <h3 class="nav-card__title">Ver alumnos registrados</h3>
      <p class="nav-card__desc">Consulta todos los alumnos</p>
    </a>

    <a class="nav-card" href="lista_profesores.php">
      <span class="nav-card__icon" aria-hidden="true">📝</span>
      <h3 class="nav-card__title">Ver profesores</h3>
      <p class="nav-card__desc">Consulta y administra profesores</p>
    </a>

  </nav>

  <!-- ========== CONFIGURACIÓN ACADÉMICA ========== -->
  <h3 style="font-size:0.9rem; color:var(--color-muted); margin: 1rem 0 0.8rem 0;">⚙️ Configuración académica</h3>
  <nav class="card-grid" aria-label="Menú de configuración">

    <a class="nav-card" href="ciclos_escolares.php">
      <span class="nav-card__icon" aria-hidden="true">📅</span>
      <h3 class="nav-card__title">Ciclos escolares</h3>
      <p class="nav-card__desc">Crea, edita y activa los ciclos</p>
    </a>

    <a class="nav-card" href="campos_formativos.php">
      <span class="nav-card__icon" aria-hidden="true">🗂️</span>
      <h3 class="nav-card__title">Campos formativos</h3>
      <p class="nav-card__desc">Gestiona los campos formativos</p>
    </a>

    <a class="nav-card" href="periodos.php">
      <span class="nav-card__icon" aria-hidden="true">🔓</span>
      <h3 class="nav-card__title">Periodos</h3>
      <p class="nav-card__desc">Abre y cierra periodos de calificación</p>
    </a>

    <!-- NUEVO: Grupos dinámicos -->
    <a class="nav-card" href="grupos.php">
      <span class="nav-card__icon" aria-hidden="true">👥</span>
      <h3 class="nav-card__title">Grupos</h3>
      <p class="nav-card__desc">Gestiona los grupos por sección (A, B, C, D, etc.)</p>
    </a>

    <!-- NUEVO: Configuración de aspectos -->
    <a class="nav-card" href="config_aspectos.php">
      <span class="nav-card__icon" aria-hidden="true">⚡</span>
      <h3 class="nav-card__title">Aspectos de evaluación</h3>
      <p class="nav-card__desc">Configura porcentajes por sección y grado</p>
    </a>

  </nav>

  <!-- ========== ASIGNACIONES POR MÓDULO ========== -->
  <h3 style="font-size:0.9rem; color:var(--color-muted); margin: 1rem 0 0.8rem 0;">📖 Asignaciones por módulo</h3>
  <nav class="card-grid" aria-label="Menú de asignaciones">

    <!-- MODIFICADO: Ahora usa el nuevo sistema dinámico -->
    <a class="nav-card" href="grados_materias.php">
        <span class="nav-card__icon" aria-hidden="true">📋</span>
        <h3 class="nav-card__title">Materias por grado</h3>
        <p class="nav-card__desc">Asigna qué materias tiene cada grado (sistema dinámico)</p>
    </a>

    <a class="nav-card" href="materias.php">
      <span class="nav-card__icon" aria-hidden="true">📖</span>
      <h3 class="nav-card__title">Materias</h3>
      <p class="nav-card__desc">Gestiona el catálogo de materias del sistema</p>
    </a>

  </nav>

  <!-- ========== GESTIÓN DE CALIFICACIONES Y PERMISOS ========== -->
  <h3 style="font-size:0.9rem; color:var(--color-muted); margin: 1rem 0 0.8rem 0;">🔧 Administración avanzada</h3>
  <nav class="card-grid" aria-label="Menú de administración">

    <a class="nav-card" href="gestion_calificaciones.php">
      <span class="nav-card__icon" aria-hidden="true">📊</span>
      <h3 class="nav-card__title">Gestionar calificaciones</h3>
      <p class="nav-card__desc">Ver, editar o eliminar calificaciones por grupo</p>
    </a>

    <a class="nav-card" href="gestion_usuarios_permisos.php">
      <span class="nav-card__icon" aria-hidden="true">👥</span>
      <h3 class="nav-card__title">Usuarios y permisos</h3>
      <p class="nav-card__desc">Asignar roles y permisos a coordinadores</p>
    </a>

    <!-- NUEVO: Asignaciones directas (para compatibilidad) -->

    <a class="nav-card" href="asignar_maestros.php">
    <span class="nav-card__icon" aria-hidden="true">👨‍🏫</span>
    <h3 class="nav-card__title">Asignar maestros</h3>
    <p class="nav-card__desc">Asigna maestros a materias por grado y grupo</p>
</a>

  </nav>

  <!-- ========== REPORTES ========== -->
  <h3 style="font-size:0.9rem; color:var(--color-muted); margin: 1rem 0 0.8rem 0;">📊 Reportes</h3>
  <nav class="card-grid" aria-label="Menú de reportes">

    <a class="nav-card" href="reportes.php">
      <span class="nav-card__icon" aria-hidden="true">📊</span>
      <h3 class="nav-card__title">Reportes</h3>
      <p class="nav-card__desc">Consulta calificaciones por grupo</p>
    </a>

    <a class="nav-card" href="documentos_alumnos.php">
      <span class="nav-card__icon" aria-hidden="true">📄</span>
      <h3 class="nav-card__title">Documentos de alumnos</h3>
      <p class="nav-card__desc">Consulta todos los documentos subidos por los padres</p>
    </a>

  </nav>

</main>

<?php include __DIR__ . '/../includes/footer.php'; ?>