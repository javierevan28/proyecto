-- MariaDB dump 10.19  Distrib 10.4.28-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: escuela
-- ------------------------------------------------------
-- Server version	10.4.28-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `alumno_materia`
--

DROP TABLE IF EXISTS `alumno_materia`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `alumno_materia` (
  `alumno_id` int(10) unsigned NOT NULL,
  `materia_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`alumno_id`,`materia_id`),
  KEY `materia_id` (`materia_id`),
  CONSTRAINT `alumno_materia_ibfk_1` FOREIGN KEY (`alumno_id`) REFERENCES `alumnos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `alumno_materia_ibfk_2` FOREIGN KEY (`materia_id`) REFERENCES `materias` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alumno_materia`
--

LOCK TABLES `alumno_materia` WRITE;
/*!40000 ALTER TABLE `alumno_materia` DISABLE KEYS */;
/*!40000 ALTER TABLE `alumno_materia` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `alumnos`
--

DROP TABLE IF EXISTS `alumnos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `alumnos` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `matricula` varchar(25) DEFAULT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido_paterno` varchar(60) NOT NULL,
  `apellido_materno` varchar(60) DEFAULT NULL,
  `curp` char(18) DEFAULT NULL,
  `fecha_nacimiento` date NOT NULL,
  `genero` enum('masculino','femenino','otro') NOT NULL,
  `rol` enum('estudiante') NOT NULL DEFAULT 'estudiante',
  `grado` tinyint(3) unsigned NOT NULL COMMENT '1-6',
  `grupo` enum('A','B','C','D') NOT NULL,
  `seccion` enum('maternal','preescolar','primaria','secundaria') NOT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  UNIQUE KEY `curp` (`curp`),
  UNIQUE KEY `matricula` (`matricula`),
  CONSTRAINT `alumnos_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alumnos`
--

LOCK TABLES `alumnos` WRITE;
/*!40000 ALTER TABLE `alumnos` DISABLE KEYS */;
INSERT INTO `alumnos` VALUES (1,4,NULL,'Amy','Moreno','Montes','MOMA191006MMSRNMA5','2019-10-06','femenino','estudiante',1,'A','primaria',1,'2026-05-15 17:50:28'),(3,8,'CEFSAMX20260517000001','Meribe','Sanchez','Aranda','MOMA191006MMSRNMA9','2018-12-13','femenino','estudiante',1,'A','primaria',1,'2026-05-16 19:16:27'),(5,10,'CEFMAAM20260517000001','Ana Maria','Moreno','Arellano','MOAJ000516HMNRRV09','2021-01-28','femenino','estudiante',2,'A','preescolar',1,'2026-05-17 10:02:47');
/*!40000 ALTER TABLE `alumnos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `artes_subcomponentes`
--

DROP TABLE IF EXISTS `artes_subcomponentes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `artes_subcomponentes` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `orden` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'Orden en la boleta',
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `artes_subcomponentes`
--

LOCK TABLES `artes_subcomponentes` WRITE;
/*!40000 ALTER TABLE `artes_subcomponentes` DISABLE KEYS */;
INSERT INTO `artes_subcomponentes` VALUES (1,'Danza',1,1,'2026-05-22 06:22:09'),(2,'Teatro',2,1,'2026-05-22 06:22:09'),(3,'Dibujo',3,1,'2026-05-22 06:22:09'),(4,'Música',4,1,'2026-05-22 06:22:09'),(5,'Artes',5,1,'2026-05-22 06:22:09');
/*!40000 ALTER TABLE `artes_subcomponentes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `asignacion_artes`
--

DROP TABLE IF EXISTS `asignacion_artes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `asignacion_artes` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `asignacion_id` int(10) unsigned NOT NULL,
  `subcomponente_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `asignacion_id` (`asignacion_id`),
  KEY `fk_asigArtes_sub` (`subcomponente_id`),
  CONSTRAINT `fk_asigArtes_asig` FOREIGN KEY (`asignacion_id`) REFERENCES `asignaciones` (`id`),
  CONSTRAINT `fk_asigArtes_sub` FOREIGN KEY (`subcomponente_id`) REFERENCES `artes_subcomponentes` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignacion_artes`
--

LOCK TABLES `asignacion_artes` WRITE;
/*!40000 ALTER TABLE `asignacion_artes` DISABLE KEYS */;
/*!40000 ALTER TABLE `asignacion_artes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `asignacion_ingles_aspectos`
--

DROP TABLE IF EXISTS `asignacion_ingles_aspectos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `asignacion_ingles_aspectos` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `asignacion_id` int(10) unsigned NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `orden` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'Orden en la boleta',
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_ingles_aspecto` (`asignacion_id`,`nombre`),
  CONSTRAINT `fk_asigIngles_asig` FOREIGN KEY (`asignacion_id`) REFERENCES `asignaciones` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignacion_ingles_aspectos`
--

LOCK TABLES `asignacion_ingles_aspectos` WRITE;
/*!40000 ALTER TABLE `asignacion_ingles_aspectos` DISABLE KEYS */;
/*!40000 ALTER TABLE `asignacion_ingles_aspectos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `asignacion_maestros`
--

DROP TABLE IF EXISTS `asignacion_maestros`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `asignacion_maestros` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `asignacion_id` int(10) unsigned NOT NULL,
  `profesor_id` int(10) unsigned NOT NULL,
  `es_titular` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Titular del grupo',
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_asig_prof` (`asignacion_id`,`profesor_id`),
  KEY `fk_asigmaestro_prof` (`profesor_id`),
  CONSTRAINT `fk_asigmaestro_asig` FOREIGN KEY (`asignacion_id`) REFERENCES `asignaciones` (`id`),
  CONSTRAINT `fk_asigmaestro_prof` FOREIGN KEY (`profesor_id`) REFERENCES `profesores` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignacion_maestros`
--

LOCK TABLES `asignacion_maestros` WRITE;
/*!40000 ALTER TABLE `asignacion_maestros` DISABLE KEYS */;
INSERT INTO `asignacion_maestros` VALUES (1,2,1,0,'2026-05-26 16:56:52'),(2,4,1,0,'2026-05-26 16:56:52'),(3,6,1,1,'2026-05-26 16:56:52'),(4,7,1,0,'2026-05-26 16:56:52'),(5,9,1,1,'2026-05-26 16:56:52'),(6,10,1,1,'2026-05-26 16:56:52'),(7,11,1,1,'2026-05-26 16:56:52'),(8,12,1,1,'2026-05-26 16:56:52'),(9,13,1,1,'2026-05-26 16:56:52'),(10,15,1,0,'2026-05-26 17:07:13'),(11,16,1,0,'2026-05-26 17:07:13'),(12,17,1,0,'2026-05-26 17:07:13'),(13,19,1,0,'2026-05-26 17:07:13'),(14,20,1,0,'2026-05-26 17:07:13'),(15,22,1,0,'2026-05-26 17:07:13'),(16,23,1,0,'2026-05-26 17:07:13'),(17,24,1,0,'2026-05-26 17:07:13'),(18,26,1,0,'2026-05-26 17:07:13');
/*!40000 ALTER TABLE `asignacion_maestros` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `asignaciones`
--

DROP TABLE IF EXISTS `asignaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `asignaciones` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ciclo_id` int(10) unsigned NOT NULL,
  `materia_id` int(10) unsigned NOT NULL,
  `campo_formativo_id` int(10) unsigned DEFAULT NULL COMMENT 'NULL para Higiene',
  `seccion` enum('maternal','preescolar','primaria','secundaria') NOT NULL,
  `grado` tinyint(3) unsigned NOT NULL,
  `grupo` enum('A','B','C','D') NOT NULL,
  `orden` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'Orden en la boleta',
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_asignacion` (`ciclo_id`,`materia_id`,`seccion`,`grado`,`grupo`),
  KEY `fk_asig_materia` (`materia_id`),
  KEY `fk_asig_campo` (`campo_formativo_id`),
  CONSTRAINT `fk_asig_campo` FOREIGN KEY (`campo_formativo_id`) REFERENCES `campos_formativos` (`id`),
  CONSTRAINT `fk_asig_ciclo` FOREIGN KEY (`ciclo_id`) REFERENCES `ciclos_escolares` (`id`),
  CONSTRAINT `fk_asig_materia` FOREIGN KEY (`materia_id`) REFERENCES `materias` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignaciones`
--

LOCK TABLES `asignaciones` WRITE;
/*!40000 ALTER TABLE `asignaciones` DISABLE KEYS */;
INSERT INTO `asignaciones` VALUES (1,1,7,4,'primaria',1,'A',0,1,'2026-05-26 16:56:52'),(2,1,9,2,'primaria',1,'A',0,1,'2026-05-26 16:56:52'),(3,1,14,4,'primaria',1,'A',0,1,'2026-05-26 16:56:52'),(4,1,13,3,'primaria',1,'A',0,1,'2026-05-26 16:56:52'),(5,1,6,1,'primaria',1,'A',0,1,'2026-05-26 16:56:52'),(6,1,11,3,'primaria',1,'A',0,1,'2026-05-26 16:56:52'),(7,1,12,3,'primaria',1,'A',0,1,'2026-05-26 16:56:52'),(8,1,5,1,'primaria',1,'A',0,1,'2026-05-26 16:56:52'),(9,1,2,1,'primaria',1,'A',0,1,'2026-05-26 16:56:52'),(10,1,8,2,'primaria',1,'A',0,1,'2026-05-26 16:56:52'),(11,1,16,4,'primaria',1,'A',0,1,'2026-05-26 16:56:52'),(12,1,10,2,'primaria',1,'A',0,1,'2026-05-26 16:56:52'),(13,1,15,4,'primaria',1,'A',0,1,'2026-05-26 16:56:52'),(14,1,7,4,'primaria',1,'B',0,1,'2026-05-26 17:07:13'),(15,1,9,2,'primaria',1,'B',0,1,'2026-05-26 17:07:13'),(16,1,14,4,'primaria',1,'B',0,1,'2026-05-26 17:07:13'),(17,1,13,3,'primaria',1,'B',0,1,'2026-05-26 17:07:13'),(18,1,6,1,'primaria',1,'B',0,1,'2026-05-26 17:07:13'),(19,1,11,3,'primaria',1,'B',0,1,'2026-05-26 17:07:13'),(20,1,12,3,'primaria',1,'B',0,1,'2026-05-26 17:07:13'),(21,1,5,1,'primaria',1,'B',0,1,'2026-05-26 17:07:13'),(22,1,2,1,'primaria',1,'B',0,1,'2026-05-26 17:07:13'),(23,1,8,2,'primaria',1,'B',0,1,'2026-05-26 17:07:13'),(24,1,16,4,'primaria',1,'B',0,1,'2026-05-26 17:07:13'),(25,1,10,2,'primaria',1,'B',0,1,'2026-05-26 17:07:13'),(26,1,15,4,'primaria',1,'B',0,1,'2026-05-26 17:07:13');
/*!40000 ALTER TABLE `asignaciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `banned_words`
--

DROP TABLE IF EXISTS `banned_words`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `banned_words` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `word` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `word` (`word`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `banned_words`
--

LOCK TABLES `banned_words` WRITE;
/*!40000 ALTER TABLE `banned_words` DISABLE KEYS */;
INSERT INTO `banned_words` VALUES (4,'culo'),(3,'mier'),(5,'pene'),(1,'puta'),(2,'puto'),(6,'vagi');
/*!40000 ALTER TABLE `banned_words` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `calificaciones`
--

DROP TABLE IF EXISTS `calificaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `calificaciones` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `alumno_id` int(10) unsigned NOT NULL,
  `asignacion_id` int(10) unsigned NOT NULL,
  `periodo` tinyint(3) unsigned NOT NULL COMMENT '1 al 6',
  `calificacion` tinyint(3) unsigned DEFAULT NULL COMMENT 'Entero, NULL = sin capturar',
  `capturado_por` int(10) unsigned NOT NULL COMMENT 'profesor_id',
  `capturado_en` datetime NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `calificaciones`
--

LOCK TABLES `calificaciones` WRITE;
/*!40000 ALTER TABLE `calificaciones` DISABLE KEYS */;
INSERT INTO `calificaciones` VALUES (1,1,10,1,10,1,'2026-05-26 17:03:06','2026-05-26 17:03:06'),(2,3,10,1,10,1,'2026-05-26 17:03:06','2026-05-26 17:03:06'),(3,1,4,1,10,1,'2026-05-26 19:53:44','2026-05-26 19:53:44'),(4,3,4,1,10,1,'2026-05-26 19:53:44','2026-05-26 19:53:44'),(5,1,12,1,10,1,'2026-05-26 19:53:54','2026-05-26 19:53:54'),(6,3,12,1,10,1,'2026-05-26 19:53:54','2026-05-26 19:53:54'),(7,1,6,1,10,1,'2026-05-26 19:54:12','2026-05-26 19:54:12'),(8,3,6,1,9,1,'2026-05-26 19:54:12','2026-05-26 19:54:12'),(9,1,7,1,10,1,'2026-05-26 19:54:26','2026-05-26 19:54:26'),(10,3,7,1,10,1,'2026-05-26 19:54:26','2026-05-26 19:54:26'),(11,1,2,1,9,1,'2026-05-26 19:54:34','2026-05-26 19:54:34'),(12,3,2,1,9,1,'2026-05-26 19:54:34','2026-05-26 19:54:34'),(13,1,11,1,9,1,'2026-05-26 19:54:45','2026-05-26 19:54:45'),(14,3,11,1,9,1,'2026-05-26 19:54:45','2026-05-26 19:54:45'),(15,1,13,1,8,1,'2026-05-26 19:54:56','2026-05-26 19:54:56'),(16,3,13,1,9,1,'2026-05-26 19:54:56','2026-05-26 19:54:56'),(17,1,9,1,9,1,'2026-05-26 19:55:03','2026-05-26 19:55:03'),(18,3,9,1,8,1,'2026-05-26 19:55:03','2026-05-26 19:55:03');
/*!40000 ALTER TABLE `calificaciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `calificaciones_ingles`
--

DROP TABLE IF EXISTS `calificaciones_ingles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `calificaciones_ingles` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `alumno_id` int(10) unsigned NOT NULL,
  `aspecto_id` int(10) unsigned NOT NULL,
  `periodo` tinyint(3) unsigned NOT NULL,
  `calificacion` tinyint(3) unsigned DEFAULT NULL,
  `capturado_por` int(10) unsigned NOT NULL,
  `capturado_en` datetime NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_cali` (`alumno_id`,`aspecto_id`,`periodo`),
  KEY `fk_cali_aspecto` (`aspecto_id`),
  KEY `fk_cali_prof` (`capturado_por`),
  CONSTRAINT `fk_cali_alumno` FOREIGN KEY (`alumno_id`) REFERENCES `alumnos` (`id`),
  CONSTRAINT `fk_cali_aspecto` FOREIGN KEY (`aspecto_id`) REFERENCES `asignacion_ingles_aspectos` (`id`),
  CONSTRAINT `fk_cali_prof` FOREIGN KEY (`capturado_por`) REFERENCES `profesores` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `calificaciones_ingles`
--

LOCK TABLES `calificaciones_ingles` WRITE;
/*!40000 ALTER TABLE `calificaciones_ingles` DISABLE KEYS */;
/*!40000 ALTER TABLE `calificaciones_ingles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `calificaciones_titular`
--

DROP TABLE IF EXISTS `calificaciones_titular`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `calificaciones_titular` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `alumno_id` int(10) unsigned NOT NULL,
  `ciclo_id` int(10) unsigned NOT NULL,
  `periodo` tinyint(3) unsigned NOT NULL,
  `socioemocional` tinyint(3) unsigned DEFAULT NULL,
  `ausencias` tinyint(3) unsigned DEFAULT NULL,
  `disciplina` tinyint(3) unsigned DEFAULT NULL,
  `higiene` tinyint(3) unsigned DEFAULT NULL COMMENT 'Solo secundaria',
  `capturado_por` int(10) unsigned NOT NULL,
  `actualizado_en` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_cal_titular` (`alumno_id`,`ciclo_id`,`periodo`),
  KEY `fk_ct_ciclo` (`ciclo_id`),
  KEY `fk_ct_prof` (`capturado_por`),
  CONSTRAINT `fk_ct_alumno` FOREIGN KEY (`alumno_id`) REFERENCES `alumnos` (`id`),
  CONSTRAINT `fk_ct_ciclo` FOREIGN KEY (`ciclo_id`) REFERENCES `ciclos_escolares` (`id`),
  CONSTRAINT `fk_ct_prof` FOREIGN KEY (`capturado_por`) REFERENCES `profesores` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `calificaciones_titular`
--

LOCK TABLES `calificaciones_titular` WRITE;
/*!40000 ALTER TABLE `calificaciones_titular` DISABLE KEYS */;
/*!40000 ALTER TABLE `calificaciones_titular` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `campos_formativos`
--

DROP TABLE IF EXISTS `campos_formativos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `campos_formativos` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `orden` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'Orden en la boleta',
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `campos_formativos`
--

LOCK TABLES `campos_formativos` WRITE;
/*!40000 ALTER TABLE `campos_formativos` DISABLE KEYS */;
INSERT INTO `campos_formativos` VALUES (1,'LENGUAJES',1,1,'2026-05-21 21:45:44'),(2,'SABERES Y PENSAMIENTO CIENTÍFICO',2,1,'2026-05-21 21:45:44'),(3,'ÉTICA NATURALEZA Y SOCIEDADES',3,1,'2026-05-21 21:45:44'),(4,'DE LO HUMANO Y LO COMUNITARIO',4,1,'2026-05-21 21:45:44');
/*!40000 ALTER TABLE `campos_formativos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ciclos_escolares`
--

DROP TABLE IF EXISTS `ciclos_escolares`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ciclos_escolares` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(30) NOT NULL,
  `fecha_inicio` date NOT NULL,
  `fecha_fin` date NOT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 0,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ciclos_escolares`
--

LOCK TABLES `ciclos_escolares` WRITE;
/*!40000 ALTER TABLE `ciclos_escolares` DISABLE KEYS */;
INSERT INTO `ciclos_escolares` VALUES (1,'2025 - 2026','2025-09-01','2026-07-15',1,'2026-05-21 03:46:30'),(2,'2024 - 2025','2024-09-01','2025-09-17',0,'2026-05-21 03:53:41');
/*!40000 ALTER TABLE `ciclos_escolares` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `grupo_titular`
--

DROP TABLE IF EXISTS `grupo_titular`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `grupo_titular` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ciclo_id` int(10) unsigned NOT NULL,
  `asignacion_id` int(10) unsigned NOT NULL,
  `profesor_id` int(10) unsigned NOT NULL,
  `seccion` enum('maternal','preescolar','primaria','secundaria') NOT NULL,
  `grado` tinyint(3) unsigned NOT NULL,
  `grupo` enum('A','B','C','D') NOT NULL,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_grupo_titular` (`ciclo_id`,`seccion`,`grado`,`grupo`),
  KEY `fk_gt_asig` (`asignacion_id`),
  KEY `fk_gt_prof` (`profesor_id`),
  CONSTRAINT `fk_gt_asig` FOREIGN KEY (`asignacion_id`) REFERENCES `asignaciones` (`id`),
  CONSTRAINT `fk_gt_ciclo` FOREIGN KEY (`ciclo_id`) REFERENCES `ciclos_escolares` (`id`),
  CONSTRAINT `fk_gt_prof` FOREIGN KEY (`profesor_id`) REFERENCES `profesores` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `grupo_titular`
--

LOCK TABLES `grupo_titular` WRITE;
/*!40000 ALTER TABLE `grupo_titular` DISABLE KEYS */;
/*!40000 ALTER TABLE `grupo_titular` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `materias`
--

DROP TABLE IF EXISTS `materias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `materias` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(80) NOT NULL,
  `campo_formativo_id` int(10) unsigned DEFAULT NULL,
  `es_ingles` tinyint(1) NOT NULL DEFAULT 0,
  `es_artes` tinyint(1) NOT NULL DEFAULT 0,
  `es_higiene` tinyint(1) NOT NULL DEFAULT 0,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_materia_campo` (`campo_formativo_id`),
  CONSTRAINT `fk_materia_campo` FOREIGN KEY (`campo_formativo_id`) REFERENCES `campos_formativos` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `materias`
--

LOCK TABLES `materias` WRITE;
/*!40000 ALTER TABLE `materias` DISABLE KEYS */;
INSERT INTO `materias` VALUES (2,'Lengua Materna',1,0,0,0,1,'2026-05-21 21:47:08'),(5,'Inglés',1,1,0,0,1,'2026-05-24 10:26:38'),(6,'Francés',1,0,0,0,1,'2026-05-24 10:26:38'),(7,'Artes',4,0,1,0,1,'2026-05-24 10:26:38'),(8,'Matemáticas',2,0,0,0,1,'2026-05-24 10:26:38'),(9,'Ciencias Naturales',2,0,0,0,1,'2026-05-24 10:26:38'),(10,'Tecnología',2,0,0,0,1,'2026-05-24 10:26:38'),(11,'Geografía',3,0,0,0,1,'2026-05-24 10:26:38'),(12,'Historia',3,0,0,0,1,'2026-05-24 10:26:38'),(13,'F.C. y E.',3,0,0,0,1,'2026-05-24 10:26:38'),(14,'Educación Física',4,0,0,0,1,'2026-05-24 10:26:38'),(15,'Vida Saludable',4,0,0,0,1,'2026-05-24 10:26:38'),(16,'Socioemocional',4,0,0,0,1,'2026-05-24 10:26:38'),(17,'Higiene',NULL,0,0,1,1,'2026-05-24 10:26:38');
/*!40000 ALTER TABLE `materias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `padre_alumno`
--

DROP TABLE IF EXISTS `padre_alumno`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `padre_alumno` (
  `padre_id` int(10) unsigned NOT NULL,
  `alumno_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`padre_id`,`alumno_id`),
  UNIQUE KEY `alumno_id` (`alumno_id`),
  CONSTRAINT `padre_alumno_ibfk_1` FOREIGN KEY (`padre_id`) REFERENCES `padres` (`id`) ON DELETE CASCADE,
  CONSTRAINT `padre_alumno_ibfk_2` FOREIGN KEY (`alumno_id`) REFERENCES `alumnos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `padre_alumno`
--

LOCK TABLES `padre_alumno` WRITE;
/*!40000 ALTER TABLE `padre_alumno` DISABLE KEYS */;
INSERT INTO `padre_alumno` VALUES (1,1),(1,3),(2,5);
/*!40000 ALTER TABLE `padre_alumno` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `padres`
--

DROP TABLE IF EXISTS `padres`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `padres` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido_paterno` varchar(60) NOT NULL,
  `apellido_materno` varchar(60) DEFAULT NULL,
  `genero` enum('masculino','femenino','otro') NOT NULL,
  `telefono` varchar(20) NOT NULL,
  `telefono_emergencia` varchar(20) DEFAULT NULL,
  `correo` varchar(120) DEFAULT NULL,
  `curp` char(18) DEFAULT NULL,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  UNIQUE KEY `curp` (`curp`),
  CONSTRAINT `padres_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `padres`
--

LOCK TABLES `padres` WRITE;
/*!40000 ALTER TABLE `padres` DISABLE KEYS */;
INSERT INTO `padres` VALUES (1,2,'Javier Omar','Moreno','Arellano','masculino','7773220180','7772517476','jomaevan13@gmail.com','MOAJ880128HMSRRV03','2026-05-15 17:24:12'),(2,6,'Amy','Lee','Lynn','femenino','7773220180','7772517476','jomaevan18@gmail.com','MOMA191006MMSRNMA9','2026-05-15 18:07:36');
/*!40000 ALTER TABLE `padres` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `periodos_apertura`
--

DROP TABLE IF EXISTS `periodos_apertura`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `periodos_apertura` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ciclo_id` int(10) unsigned NOT NULL,
  `periodo` tinyint(3) unsigned NOT NULL COMMENT '1 al 6',
  `abierto` tinyint(1) NOT NULL DEFAULT 0,
  `abierto_en` datetime DEFAULT NULL,
  `cerrado_en` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_ciclo_periodo` (`ciclo_id`,`periodo`),
  CONSTRAINT `fk_periodo_ciclo` FOREIGN KEY (`ciclo_id`) REFERENCES `ciclos_escolares` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `periodos_apertura`
--

LOCK TABLES `periodos_apertura` WRITE;
/*!40000 ALTER TABLE `periodos_apertura` DISABLE KEYS */;
INSERT INTO `periodos_apertura` VALUES (1,1,1,1,'2026-05-24 15:05:30',NULL);
/*!40000 ALTER TABLE `periodos_apertura` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `profesores`
--

DROP TABLE IF EXISTS `profesores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `profesores` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido_paterno` varchar(60) NOT NULL,
  `apellido_materno` varchar(60) DEFAULT NULL,
  `curp` char(18) DEFAULT NULL,
  `fecha_nacimiento` date NOT NULL,
  `genero` enum('masculino','femenino','otro') NOT NULL,
  `tipo` enum('titular','frances','cocurricular') NOT NULL DEFAULT 'titular',
  `telefono` varchar(20) DEFAULT NULL,
  `correo` varchar(120) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  UNIQUE KEY `curp` (`curp`),
  CONSTRAINT `fk_profesor_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `profesores`
--

LOCK TABLES `profesores` WRITE;
/*!40000 ALTER TABLE `profesores` DISABLE KEYS */;
INSERT INTO `profesores` VALUES (1,12,'Sughey Adriana','Moreno','Arellano','MOAS820608MMSRRG04','1982-06-08','femenino','titular','7773220180','adriana23@gmail.com',1,'2026-05-24 10:06:41'),(2,13,'Ana','Izquierdo','Bello',NULL,'1970-03-09','femenino','titular',NULL,NULL,1,'2026-05-28 07:28:10');
/*!40000 ALTER TABLE `profesores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roles` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(30) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (3,'estudiante'),(2,'padre'),(4,'profesor'),(1,'superadmin');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `rol_id` int(10) unsigned NOT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  KEY `rol_id` (`rol_id`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`rol_id`) REFERENCES `roles` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'superadmin','$2y$10$F6bwXR9C73lmTlUAnxlme.9YDF/FLiccDp/zhLJeBzOeD6xkJPb4e',1,1,'2026-05-15 16:47:22'),(2,'morarejavieromar','$2y$10$5AIH2lcLCnlsXDyCDwafsusbSqViH.HnaSCui3SmTj5e7A9FeEY3G',2,1,'2026-05-15 17:24:12'),(4,'mormonamy','$2y$10$hhXxSIEyaxL.8BY51BXZBuHQ0oPFOLE8W3p/guM8kRFMRKAqzytX.',3,1,'2026-05-15 17:50:28'),(6,'leelynamy','$2y$10$.JpZmEjxJ2dWhk7ykonxbOZ6pXjf/JSDaSo7Bfygcde8jNIb/duLW',2,1,'2026-05-15 18:07:36'),(8,'sanarameribe','$2y$10$Z4lY3VuYUmszJhY.gfqNv.260KIJQ3I8K7Q0v9H68twC.ET0h/HMe',3,1,'2026-05-16 19:16:27'),(9,'morareanamaria','$2y$10$vwkjxH1RtOR2tSBRIUg3tudBhom1B5k5pNqppqTP84kTNjLdcqX2q',3,1,'2026-05-17 09:56:31'),(10,'morareanamaria1','$2y$10$Z7YbL3/8mWB6cyMPW1BbWelnmD27Ouob4A700062F3xdN1gzUjUci',3,1,'2026-05-17 10:02:47'),(12,'moraresugheyadriana','$2y$10$wCXHc2t1ecZEMh9uwl5SO.ULqtmRSBssZQoife.VZLux/8L7e1iq6',4,1,'2026-05-24 10:06:41'),(13,'izqbelana','$2y$10$P4xBHRGg.WPp3tI.Zgbs7u8Mx/AVZNctHbfaTo3YZu/LGwFjfsTgW',4,1,'2026-05-28 07:28:10');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-29 19:58:14
