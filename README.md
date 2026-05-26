# Sistema Escolar — Guía de instalación

## Estructura de archivos

```
/
├── login.php
├── logout.php
├── config/
│   ├── db.php          ← Configura host, user, pass, dbname
│   └── session.php     ← Guard de sesiones y roles
├── models/
│   ├── UserModel.php   ← Generación de username/contraseña
│   ├── PadreModel.php  ← Alta y consulta de padres
│   └── AlumnoModel.php ← Alta y consulta de alumnos
├── superadmin/
│   ├── dashboard.php   ← Menú principal del superadmin
│   ├── alta_padre.php  ← Formulario nuevo padre/tutor
│   ├── alta_alumno.php ← Formulario nuevo alumno
│   ├── lista_padres.php
│   └── lista_alumnos.php
├── padre/
│   └── mis_hijos.php   ← Vista del padre: sus hijos
└── escuela.sql         ← Script completo de la base de datos
```

## Pasos para instalar

### 1. Base de datos
```sql
mysql -u root -p < escuela.sql
```
Esto crea la BD `escuela` con todas las tablas y el superadmin inicial.

### 2. Configurar conexión
Edita `config/db.php`:
```php
define('DB_HOST', 'localhost');
define('DB_USER', 'tu_usuario');
define('DB_PASS', 'tu_contraseña');
define('DB_NAME', 'escuela');
```

### 3. Ajustar BASE_URL (si está en subcarpeta)
En `config/session.php`:
```php
define('BASE_URL', '/mi-carpeta/');  // si está en /mi-carpeta
define('BASE_URL', '/');             // si está en la raíz
```

### 4. Acceder
Abre `http://localhost/login.php`

---

## Credenciales iniciales

| Rol        | Usuario     | Contraseña  |
|------------|-------------|-------------|
| Superadmin | superadmin  | superadmin  |

> ⚠️ Cambia la contraseña del superadmin después de la primera entrada.

---

## Reglas de generación de username

- **Con 2 apellidos:** `3 letras ap1` + `3 letras ap2` + nombre  
  Ejemplo: Moreno Arellano Javier → `morarjavier`
- **Con 1 apellido:** `4 letras ap1` + nombre  
  Ejemplo: Moreno Javier → `morejavier`
- Si hay colisión, se agrega sufijo numérico: `morarjavier1`, `morarjavier2`...
- La contraseña inicial es igual al username generado
- Se verifica contra tabla `banned_words` antes de asignar

---

## Roles del sistema

| rol_id | Nombre      | Acceso                              |
|--------|-------------|-------------------------------------|
| 1      | superadmin  | Dar de alta padres y alumnos, listas|
| 2      | padre       | Ver sus propios hijos               |
| 3      | estudiante  | (próximas versiones)                |

---

## Próximas extensiones sugeridas
- Módulo de materias y asignación a alumnos
- Calificaciones por materia
- Cambio de contraseña propio
- Vista del alumno (portal)
- Recuperación de contraseña por correo