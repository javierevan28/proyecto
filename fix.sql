-- =====================================================================
-- Completar tabla `grados_materias` (catálogo que usa la pantalla
-- superadmin/grados_materias.php) para que refleje las mismas materias
-- que ya se insertaron en `asignaciones` con el script anterior.
--
-- IMPORTANTE:
-- - grados_materias.php lee de `grados_materias`, NO de `asignaciones`.
-- - El script anterior (completar catálogo de materias/campos formativos)
--   solo insertó en `asignaciones` y en las tablas de aspectos, por eso
--   esta pantalla seguía sin mostrar Laboratorio y las demás materias
--   nuevas para 2°-6° primaria y 1°-3° secundaria.
-- - Este script es idempotente (usa NOT EXISTS), se puede correr varias
--   veces sin duplicar filas.
-- - Usa las MISMAS listas de materia_id / campo_formativo_id / orden que
--   ya se usaron en el script de `asignaciones`, para mantener todo
--   consistente.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) PRIMARIA - SEGUNDO GRADO
-- ---------------------------------------------------------------------
INSERT INTO grados_materias (seccion, grado, materia_id, campo_formativo_id, orden, activo)
SELECT 'primaria', 2, t.materia_id, t.campo_formativo_id, t.orden, 1
FROM (
    SELECT 1   AS materia_id, 1    AS campo_formativo_id, 1  AS orden  -- Lengua Materna
    UNION ALL SELECT 279, 1, 2   -- Listening
    UNION ALL SELECT 278, 1, 3   -- Speaking
    UNION ALL SELECT 281, 1, 4   -- Writing
    UNION ALL SELECT 280, 1, 5   -- Reading
    UNION ALL SELECT 285, 1, 6   -- Vocabulary
    UNION ALL SELECT 282, 1, 7   -- Grammar
    UNION ALL SELECT 286, 1, 8   -- Spelling
    UNION ALL SELECT 288, 1, 9   -- Science
    UNION ALL SELECT 3,   1, 10  -- Francés
    UNION ALL SELECT 4,   1, 11  -- Artes
    UNION ALL SELECT 27,  1, 12  -- Música
    UNION ALL SELECT 28,  1, 13  -- Danza
    UNION ALL SELECT 5,   2, 14  -- Matemáticas
    UNION ALL SELECT 9,   2, 15  -- Ciencias Naturales
    UNION ALL SELECT 10,  2, 16  -- Tecnología
    UNION ALL SELECT 13,  3, 17  -- Formación Cívica y Ética
    UNION ALL SELECT 14,  4, 18  -- Educación Física
    UNION ALL SELECT 15,  4, 19  -- Vida Saludable
    UNION ALL SELECT 16,  4, 20  -- Socioemocional
    UNION ALL SELECT 297, NULL, 21 -- Disciplina
    UNION ALL SELECT 298, NULL, 22 -- Ausencias
) t
WHERE NOT EXISTS (
    SELECT 1 FROM grados_materias gm
    WHERE gm.seccion = 'primaria' AND gm.grado = 2 AND gm.materia_id = t.materia_id
);

-- ---------------------------------------------------------------------
-- 2) PRIMARIA - TERCER GRADO (agrega "Entidad donde Vivo")
-- ---------------------------------------------------------------------
INSERT INTO grados_materias (seccion, grado, materia_id, campo_formativo_id, orden, activo)
SELECT 'primaria', 3, t.materia_id, t.campo_formativo_id, t.orden, 1
FROM (
    SELECT 1   AS materia_id, 1    AS campo_formativo_id, 1  AS orden
    UNION ALL SELECT 279, 1, 2
    UNION ALL SELECT 278, 1, 3
    UNION ALL SELECT 281, 1, 4
    UNION ALL SELECT 280, 1, 5
    UNION ALL SELECT 285, 1, 6
    UNION ALL SELECT 282, 1, 7
    UNION ALL SELECT 286, 1, 8
    UNION ALL SELECT 288, 1, 9
    UNION ALL SELECT 3,   1, 10
    UNION ALL SELECT 4,   1, 11
    UNION ALL SELECT 27,  1, 12
    UNION ALL SELECT 28,  1, 13
    UNION ALL SELECT 5,   2, 14
    UNION ALL SELECT 9,   2, 15
    UNION ALL SELECT 10,  2, 16
    UNION ALL SELECT 13,  3, 17  -- Formación Cívica y Ética
    UNION ALL SELECT 304, 3, 18  -- Entidad donde Vivo
    UNION ALL SELECT 14,  4, 19
    UNION ALL SELECT 15,  4, 20
    UNION ALL SELECT 16,  4, 21
    UNION ALL SELECT 297, NULL, 22
    UNION ALL SELECT 298, NULL, 23
) t
WHERE NOT EXISTS (
    SELECT 1 FROM grados_materias gm
    WHERE gm.seccion = 'primaria' AND gm.grado = 3 AND gm.materia_id = t.materia_id
);

-- ---------------------------------------------------------------------
-- 3) PRIMARIA - CUARTO GRADO (Geografía + Historia en vez de Entidad donde Vivo)
-- ---------------------------------------------------------------------
INSERT INTO grados_materias (seccion, grado, materia_id, campo_formativo_id, orden, activo)
SELECT 'primaria', 4, t.materia_id, t.campo_formativo_id, t.orden, 1
FROM (
    SELECT 1   AS materia_id, 1    AS campo_formativo_id, 1  AS orden
    UNION ALL SELECT 279, 1, 2
    UNION ALL SELECT 278, 1, 3
    UNION ALL SELECT 281, 1, 4
    UNION ALL SELECT 280, 1, 5
    UNION ALL SELECT 285, 1, 6
    UNION ALL SELECT 282, 1, 7
    UNION ALL SELECT 286, 1, 8
    UNION ALL SELECT 288, 1, 9
    UNION ALL SELECT 3,   1, 10
    UNION ALL SELECT 4,   1, 11
    UNION ALL SELECT 27,  1, 12
    UNION ALL SELECT 28,  1, 13
    UNION ALL SELECT 5,   2, 14
    UNION ALL SELECT 9,   2, 15
    UNION ALL SELECT 10,  2, 16
    UNION ALL SELECT 11,  3, 17  -- Geografía
    UNION ALL SELECT 12,  3, 18  -- Historia
    UNION ALL SELECT 13,  3, 19  -- Formación Cívica y Ética
    UNION ALL SELECT 14,  4, 20
    UNION ALL SELECT 15,  4, 21
    UNION ALL SELECT 16,  4, 22
    UNION ALL SELECT 297, NULL, 23
    UNION ALL SELECT 298, NULL, 24
) t
WHERE NOT EXISTS (
    SELECT 1 FROM grados_materias gm
    WHERE gm.seccion = 'primaria' AND gm.grado = 4 AND gm.materia_id = t.materia_id
);

-- ---------------------------------------------------------------------
-- 4) PRIMARIA - QUINTO GRADO (Artes usa Teatro en vez de Danza; agrega
--    Laboratorio sin campo formativo)
-- ---------------------------------------------------------------------
INSERT INTO grados_materias (seccion, grado, materia_id, campo_formativo_id, orden, activo)
SELECT 'primaria', 5, t.materia_id, t.campo_formativo_id, t.orden, 1
FROM (
    SELECT 1   AS materia_id, 1    AS campo_formativo_id, 1  AS orden
    UNION ALL SELECT 279, 1, 2
    UNION ALL SELECT 278, 1, 3
    UNION ALL SELECT 281, 1, 4
    UNION ALL SELECT 280, 1, 5
    UNION ALL SELECT 285, 1, 6
    UNION ALL SELECT 282, 1, 7
    UNION ALL SELECT 286, 1, 8
    UNION ALL SELECT 288, 1, 9
    UNION ALL SELECT 3,   1, 10
    UNION ALL SELECT 4,   1, 11
    UNION ALL SELECT 27,  1, 12
    UNION ALL SELECT 29,  1, 13  -- Teatro (en vez de Danza)
    UNION ALL SELECT 5,   2, 14
    UNION ALL SELECT 9,   2, 15
    UNION ALL SELECT 10,  2, 16
    UNION ALL SELECT 11,  3, 17
    UNION ALL SELECT 12,  3, 18
    UNION ALL SELECT 13,  3, 19
    UNION ALL SELECT 14,  4, 20
    UNION ALL SELECT 15,  4, 21
    UNION ALL SELECT 16,  4, 22
    UNION ALL SELECT 297, NULL, 23
    UNION ALL SELECT 298, NULL, 24
    UNION ALL SELECT 299, NULL, 25  -- Laboratorio
) t
WHERE NOT EXISTS (
    SELECT 1 FROM grados_materias gm
    WHERE gm.seccion = 'primaria' AND gm.grado = 5 AND gm.materia_id = t.materia_id
);

-- ---------------------------------------------------------------------
-- 5) PRIMARIA - SEXTO GRADO (igual que quinto, incluye Laboratorio)
-- ---------------------------------------------------------------------
INSERT INTO grados_materias (seccion, grado, materia_id, campo_formativo_id, orden, activo)
SELECT 'primaria', 6, t.materia_id, t.campo_formativo_id, t.orden, 1
FROM (
    SELECT 1   AS materia_id, 1    AS campo_formativo_id, 1  AS orden
    UNION ALL SELECT 279, 1, 2
    UNION ALL SELECT 278, 1, 3
    UNION ALL SELECT 281, 1, 4
    UNION ALL SELECT 280, 1, 5
    UNION ALL SELECT 285, 1, 6
    UNION ALL SELECT 282, 1, 7
    UNION ALL SELECT 286, 1, 8
    UNION ALL SELECT 288, 1, 9
    UNION ALL SELECT 3,   1, 10
    UNION ALL SELECT 4,   1, 11
    UNION ALL SELECT 27,  1, 12
    UNION ALL SELECT 29,  1, 13
    UNION ALL SELECT 5,   2, 14
    UNION ALL SELECT 9,   2, 15
    UNION ALL SELECT 10,  2, 16
    UNION ALL SELECT 11,  3, 17
    UNION ALL SELECT 12,  3, 18
    UNION ALL SELECT 13,  3, 19
    UNION ALL SELECT 14,  4, 20
    UNION ALL SELECT 15,  4, 21
    UNION ALL SELECT 16,  4, 22
    UNION ALL SELECT 297, NULL, 23
    UNION ALL SELECT 298, NULL, 24
    UNION ALL SELECT 299, NULL, 25  -- Laboratorio
) t
WHERE NOT EXISTS (
    SELECT 1 FROM grados_materias gm
    WHERE gm.seccion = 'primaria' AND gm.grado = 6 AND gm.materia_id = t.materia_id
);

-- ---------------------------------------------------------------------
-- 6) SECUNDARIA - PRIMER GRADO (Biología; Historia+Formación Cívica,
--    IGUAL que 2°/3° secundaria -- SIN Geografía)
-- ---------------------------------------------------------------------
INSERT INTO grados_materias (seccion, grado, materia_id, campo_formativo_id, orden, activo)
SELECT 'secundaria', 1, t.materia_id, t.campo_formativo_id, t.orden, 1
FROM (
    SELECT 1   AS materia_id, 1    AS campo_formativo_id, 1  AS orden  -- Lengua Materna
    UNION ALL SELECT 279, 1, 2   -- Listening
    UNION ALL SELECT 278, 1, 3   -- Speaking
    UNION ALL SELECT 281, 1, 4   -- Writing
    UNION ALL SELECT 280, 1, 5   -- Reading
    UNION ALL SELECT 285, 1, 6   -- Vocabulary
    UNION ALL SELECT 282, 1, 7   -- Grammar
    UNION ALL SELECT 286, 1, 8   -- Spelling
    UNION ALL SELECT 287, 1, 9   -- Phonetics
    UNION ALL SELECT 288, 1, 10  -- Science
    UNION ALL SELECT 289, 1, 11  -- Social Studies
    UNION ALL SELECT 290, 1, 12  -- Literature
    UNION ALL SELECT 4,   1, 13  -- Artes
    UNION ALL SELECT 27,  1, 14  -- Música
    UNION ALL SELECT 5,   2, 15  -- Matemáticas
    UNION ALL SELECT 302, 2, 16  -- Biología
    UNION ALL SELECT 12,  3, 17  -- Historia
    UNION ALL SELECT 13,  3, 18  -- Formación Cívica y Ética
    UNION ALL SELECT 10,  4, 19  -- Tecnología
    UNION ALL SELECT 14,  4, 20  -- Educación Física
    UNION ALL SELECT 298, NULL, 21 -- Ausencias
    UNION ALL SELECT 30,  NULL, 22 -- Dibujo
    UNION ALL SELECT 17,  NULL, 23 -- Hábitos de Higiene
    UNION ALL SELECT 297, NULL, 24 -- Disciplina
    UNION ALL SELECT 3,   NULL, 25 -- Francés
) t
WHERE NOT EXISTS (
    SELECT 1 FROM grados_materias gm
    WHERE gm.seccion = 'secundaria' AND gm.grado = 1 AND gm.materia_id = t.materia_id
);

-- ---------------------------------------------------------------------
-- 7) SECUNDARIA - SEGUNDO GRADO (Física; Historia+Formación Cívica)
-- ---------------------------------------------------------------------
INSERT INTO grados_materias (seccion, grado, materia_id, campo_formativo_id, orden, activo)
SELECT 'secundaria', 2, t.materia_id, t.campo_formativo_id, t.orden, 1
FROM (
    SELECT 1   AS materia_id, 1    AS campo_formativo_id, 1  AS orden
    UNION ALL SELECT 279, 1, 2
    UNION ALL SELECT 278, 1, 3
    UNION ALL SELECT 281, 1, 4
    UNION ALL SELECT 280, 1, 5
    UNION ALL SELECT 285, 1, 6
    UNION ALL SELECT 282, 1, 7
    UNION ALL SELECT 286, 1, 8
    UNION ALL SELECT 287, 1, 9
    UNION ALL SELECT 288, 1, 10
    UNION ALL SELECT 289, 1, 11
    UNION ALL SELECT 290, 1, 12
    UNION ALL SELECT 4,   1, 13
    UNION ALL SELECT 27,  1, 14
    UNION ALL SELECT 5,   2, 15  -- Matemáticas
    UNION ALL SELECT 300, 2, 16  -- Física
    UNION ALL SELECT 12,  3, 17  -- Historia
    UNION ALL SELECT 13,  3, 18  -- Formación Cívica y Ética
    UNION ALL SELECT 10,  4, 19  -- Tecnología
    UNION ALL SELECT 14,  4, 20  -- Educación Física
    UNION ALL SELECT 298, NULL, 21
    UNION ALL SELECT 30,  NULL, 22
    UNION ALL SELECT 17,  NULL, 23
    UNION ALL SELECT 297, NULL, 24
    UNION ALL SELECT 3,   NULL, 25
) t
WHERE NOT EXISTS (
    SELECT 1 FROM grados_materias gm
    WHERE gm.seccion = 'secundaria' AND gm.grado = 2 AND gm.materia_id = t.materia_id
);

-- ---------------------------------------------------------------------
-- 8) SECUNDARIA - TERCER GRADO (Química; Historia+Formación Cívica)
-- ---------------------------------------------------------------------
INSERT INTO grados_materias (seccion, grado, materia_id, campo_formativo_id, orden, activo)
SELECT 'secundaria', 3, t.materia_id, t.campo_formativo_id, t.orden, 1
FROM (
    SELECT 1   AS materia_id, 1    AS campo_formativo_id, 1  AS orden
    UNION ALL SELECT 279, 1, 2
    UNION ALL SELECT 278, 1, 3
    UNION ALL SELECT 281, 1, 4
    UNION ALL SELECT 280, 1, 5
    UNION ALL SELECT 285, 1, 6
    UNION ALL SELECT 282, 1, 7
    UNION ALL SELECT 286, 1, 8
    UNION ALL SELECT 287, 1, 9
    UNION ALL SELECT 288, 1, 10
    UNION ALL SELECT 289, 1, 11
    UNION ALL SELECT 290, 1, 12
    UNION ALL SELECT 4,   1, 13
    UNION ALL SELECT 27,  1, 14
    UNION ALL SELECT 5,   2, 15  -- Matemáticas
    UNION ALL SELECT 301, 2, 16  -- Química
    UNION ALL SELECT 12,  3, 17
    UNION ALL SELECT 13,  3, 18
    UNION ALL SELECT 10,  4, 19
    UNION ALL SELECT 14,  4, 20
    UNION ALL SELECT 298, NULL, 21
    UNION ALL SELECT 30,  NULL, 22
    UNION ALL SELECT 17,  NULL, 23
    UNION ALL SELECT 297, NULL, 24
    UNION ALL SELECT 3,   NULL, 25
) t
WHERE NOT EXISTS (
    SELECT 1 FROM grados_materias gm
    WHERE gm.seccion = 'secundaria' AND gm.grado = 3 AND gm.materia_id = t.materia_id
);

-- =====================================================================
-- Nota: este script solo llena `grados_materias`. Las tablas
-- `asignaciones`, `asignacion_aspectos` y `asignacion_disciplina_aspectos`
-- ya se llenaron con el script anterior, así que NO se tocan aquí.
-- Al abrir superadmin/grados_materias.php para cada sección/grado, ahora
-- deberías ver los checkboxes marcados y la tabla inferior con todas las
-- materias (incluyendo Laboratorio, Biología, Física, Química, etc.).
-- =====================================================================