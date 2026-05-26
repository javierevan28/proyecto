<?php

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

  <nav class="card-grid" aria-label="Menú del superadmin">

    <a class="nav-card" href="alta_padre.php">
      <span class="nav-card__icon" aria-hidden="true">👨‍👩‍👧</span>
      <h3 class="nav-card__title">Dar de alta padre / tutor</h3>
      <p class="nav-card__desc">
        Registra un nuevo padre o tutor y genera su acceso automáticamente
      </p>
    </a>

    <a class="nav-card" href="alta_alumno.php">
      <span class="nav-card__icon" aria-hidden="true">🎒</span>
      <h3 class="nav-card__title">Dar de alta alumno</h3>
      <p class="nav-card__desc">
        Registra un nuevo alumno y vincúlalo a su padre o tutor
      </p>
    </a>

    <a class="nav-card" href="lista_padres.php">
      <span class="nav-card__icon" aria-hidden="true">📋</span>
      <h3 class="nav-card__title">Ver padres registrados</h3>
      <p class="nav-card__desc">
        Consulta todos los padres y tutores del sistema
      </p>
    </a>

    <a class="nav-card" href="lista_alumnos.php">
      <span class="nav-card__icon" aria-hidden="true">📚</span>
      <h3 class="nav-card__title">Ver alumnos registrados</h3>
      <p class="nav-card__desc">
        Consulta todos los alumnos con su grado y grupo
      </p>
    </a>

    <a class="nav-card" href="ciclos_escolares.php">
      <span class="nav-card__icon" aria-hidden="true">📅</span>
      <h3 class="nav-card__title">Ciclos escolares</h3>
      <p class="nav-card__desc">
        Crea, edita y activa los ciclos del año escolar
      </p>
    </a>

    <a class="nav-card" href="alta_profesor.php">
      <span class="nav-card__icon" aria-hidden="true">👨‍🏫</span>
      <h3 class="nav-card__title">Dar de alta profesor</h3>
      <p class="nav-card__desc">
        Registra un nuevo profesor y genera su acceso automáticamente
      </p>
    </a>

    <a class="nav-card" href="lista_profesores.php">
      <span class="nav-card__icon" aria-hidden="true">📝</span>
      <h3 class="nav-card__title">Ver profesores</h3>
      <p class="nav-card__desc">
        Consulta y administra todos los profesores del sistema
      </p>
    </a>

    <a class="nav-card" href="campos_formativos.php">
      <span class="nav-card__icon" aria-hidden="true">🗂️</span>
      <h3 class="nav-card__title">Campos formativos</h3>
      <p class="nav-card__desc">
      Gestiona los campos formativos que aparecen en la boleta
      </p>
    </a>

    <a class="nav-card" href="materias.php">
  <span class="nav-card__icon" aria-hidden="true">📖</span>
  <h3 class="nav-card__title">Materias</h3>
  <p class="nav-card__desc">
    Gestiona el catálogo de materias del sistema
  </p>
</a>

<a class="nav-card" href="artes_subcomponentes.php">
  <span class="nav-card__icon" aria-hidden="true">🎨</span>
  <h3 class="nav-card__title">Subcomponentes de Artes</h3>
  <p class="nav-card__desc">
    Gestiona Danza, Teatro, Dibujo, Música y Artes
  </p>
</a>

<a class="nav-card" href="asignaciones.php">
  <span class="nav-card__icon" aria-hidden="true">🗓️</span>
  <h3 class="nav-card__title">Asignaciones</h3>
  <p class="nav-card__desc">
    Asigna materias, maestros y grupos por ciclo escolar
  </p>
</a>

<a class="nav-card" href="periodos.php">
  <span class="nav-card__icon" aria-hidden="true">🔓</span>
  <h3 class="nav-card__title">Periodos</h3>
  <p class="nav-card__desc">
    Abre y cierra periodos para que los maestros capturen calificaciones
  </p>
</a>
  </nav>
</main>

<?php include __DIR__ . '/../includes/footer.php'; ?>