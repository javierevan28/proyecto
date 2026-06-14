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
  `fecha_ingreso` date NOT NULL,
  `genero` enum('masculino','femenino','otro') NOT NULL,
  `rol` enum('estudiante') NOT NULL DEFAULT 'estudiante',
  `grado` tinyint(3) unsigned NOT NULL COMMENT '1-6',
  `grupo` enum('A','B','C','D') NOT NULL,
  `seccion` enum('maternal','preescolar','primaria','secundaria') NOT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  `estatus` enum('nuevo_ingreso','reinscripcion','regular','baja') NOT NULL DEFAULT 'regular' COMMENT 'Estatus del alumno',
  `beca_interna` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Monto de beca interna',
  `beca_externa` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Monto de beca externa',
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  UNIQUE KEY `curp` (`curp`),
  UNIQUE KEY `matricula` (`matricula`),
  KEY `idx_estatus` (`estatus`),
  KEY `idx_beca_interna` (`beca_interna`),
  KEY `idx_beca_externa` (`beca_externa`),
  KEY `idx_fecha_ingreso` (`fecha_ingreso`),
  KEY `idx_apellidos_nombre` (`apellido_paterno`,`apellido_materno`,`nombre`),
  CONSTRAINT `alumnos_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alumnos`
--

LOCK TABLES `alumnos` WRITE;
/*!40000 ALTER TABLE `alumnos` DISABLE KEYS */;
INSERT INTO `alumnos` VALUES (1,4,NULL,'Amy','Moreno','Montes','MOMA191006MMSRNMA5','2019-10-06','2026-05-15','femenino','estudiante',1,'A','primaria',1,'2026-05-15 17:50:28','regular',0.00,0.00),(3,8,'CEFSAMX20260517000001','Meribe','Sanchez','Aranda','MOMA191006MMSRNMA9','2018-12-13','2026-05-16','femenino','estudiante',1,'A','primaria',1,'2026-05-16 19:16:27','regular',0.00,0.00),(5,10,'CEFMAAM20260517000001','Ana Maria','Moreno','Arellano','MOAJ000516HMNRRV09','2021-01-28','2026-05-17','femenino','estudiante',2,'A','preescolar',1,'2026-05-17 10:02:47','regular',0.00,0.00),(6,100,'2024001','PENDIENTE','PENDIENTE','PENDIENTE','PEND0001010101','2000-01-01','2024-08-15','otro','estudiante',1,'A','primaria',1,'2026-06-09 12:20:57','regular',0.00,0.00),(7,101,'2024002','PENDIENTE','PENDIENTE','PENDIENTE','PEND0001010102','2000-01-01','2024-08-15','otro','estudiante',1,'B','primaria',1,'2026-06-09 12:20:57','regular',0.00,0.00);
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
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignacion_artes`
--

LOCK TABLES `asignacion_artes` WRITE;
/*!40000 ALTER TABLE `asignacion_artes` DISABLE KEYS */;
/*!40000 ALTER TABLE `asignacion_artes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `asignacion_aspectos`
--

DROP TABLE IF EXISTS `asignacion_aspectos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `asignacion_aspectos` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `asignacion_id` int(10) unsigned NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `porcentaje` decimal(5,2) NOT NULL DEFAULT 0.00,
  `orden` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_aspecto` (`asignacion_id`,`nombre`),
  CONSTRAINT `asignacion_aspectos_ibfk_1` FOREIGN KEY (`asignacion_id`) REFERENCES `asignaciones` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1089 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignacion_aspectos`
--

LOCK TABLES `asignacion_aspectos` WRITE;
/*!40000 ALTER TABLE `asignacion_aspectos` DISABLE KEYS */;
INSERT INTO `asignacion_aspectos` VALUES (7,44,'Examen',50.00,1,1),(8,44,'Tareas',10.00,2,1),(9,44,'Participación',10.00,3,1),(10,44,'Evaluación Parcial',10.00,4,1),(11,44,'Proyecto',10.00,5,1),(12,44,'Trabajo y Exposiciones',10.00,6,1),(25,36,'Examen',50.00,1,1),(26,36,'Tareas',10.00,2,1),(27,36,'Participación',10.00,3,1),(28,36,'Evaluación Parcial',10.00,4,1),(29,36,'Proyecto',10.00,5,1),(30,36,'Trabajo y Exposiciones',10.00,6,1),(37,38,'Examen',50.00,1,1),(38,38,'Tareas',10.00,2,1),(39,38,'Participación',10.00,3,1),(40,38,'Evaluación Parcial',10.00,4,1),(41,38,'Proyecto',10.00,5,1),(42,38,'Trabajo y Exposiciones',10.00,6,1),(49,43,'Examen',50.00,1,1),(50,43,'Tareas',10.00,2,1),(51,43,'Participación',10.00,3,1),(52,43,'Evaluación Parcial',10.00,4,1),(53,43,'Proyecto',10.00,5,1),(54,43,'Trabajo y Exposiciones',10.00,6,1),(55,41,'Examen',50.00,1,1),(56,41,'Tareas',10.00,2,1),(57,41,'Participación',10.00,3,1),(58,41,'Evaluación Parcial',10.00,4,1),(59,41,'Proyecto',10.00,5,1),(60,41,'Trabajo y Exposiciones',10.00,6,1),(61,47,'Examen',50.00,1,1),(62,47,'Tareas',10.00,2,1),(63,47,'Participación',10.00,3,1),(64,47,'Evaluación Parcial',10.00,4,1),(65,47,'Proyecto',10.00,5,1),(66,47,'Trabajo y Exposiciones',10.00,6,1),(67,48,'Examen',50.00,1,1),(68,48,'Tareas',10.00,2,1),(69,48,'Participación',10.00,3,1),(70,48,'Evaluación Parcial',10.00,4,1),(71,48,'Proyecto',10.00,5,1),(72,48,'Trabajo y Exposiciones',10.00,6,1),(280,77,'Examen',50.00,1,1),(281,77,'Tareas',10.00,2,1),(282,77,'Participación',10.00,3,1),(283,77,'Evaluación Parcial',10.00,4,1),(284,77,'Proyecto',10.00,5,1),(285,77,'Trabajo y Exposiciones',10.00,6,1),(286,78,'Examen',50.00,1,1),(287,78,'Tareas',10.00,2,1),(288,78,'Participación',10.00,3,1),(289,78,'Evaluación Parcial',10.00,4,1),(290,78,'Proyecto',10.00,5,1),(291,78,'Trabajo y Exposiciones',10.00,6,1),(292,79,'Examen',50.00,1,1),(293,79,'Tareas',10.00,2,1),(294,79,'Participación',10.00,3,1),(295,79,'Evaluación Parcial',10.00,4,1),(296,79,'Proyecto',10.00,5,1),(297,79,'Trabajo y Exposiciones',10.00,6,1),(298,80,'Examen',50.00,1,1),(299,80,'Tareas',10.00,2,1),(300,80,'Participación',10.00,3,1),(301,80,'Evaluación Parcial',10.00,4,1),(302,80,'Proyecto',10.00,5,1),(303,80,'Trabajo y Exposiciones',10.00,6,1),(304,81,'Examen',50.00,1,1),(305,81,'Tareas',10.00,2,1),(306,81,'Participación',10.00,3,1),(307,81,'Evaluación Parcial',10.00,4,1),(308,81,'Proyecto',10.00,5,1),(309,81,'Trabajo y Exposiciones',10.00,6,1),(310,82,'Examen',50.00,1,1),(311,82,'Tareas',10.00,2,1),(312,82,'Participación',10.00,3,1),(313,82,'Evaluación Parcial',10.00,4,1),(314,82,'Proyecto',10.00,5,1),(315,82,'Trabajo y Exposiciones',10.00,6,1),(316,83,'Examen',50.00,1,1),(317,83,'Tareas',10.00,2,1),(318,83,'Participación',10.00,3,1),(319,83,'Evaluación Parcial',10.00,4,1),(320,83,'Proyecto',10.00,5,1),(321,83,'Trabajo y Exposiciones',10.00,6,1),(322,84,'Examen',50.00,1,1),(323,84,'Tareas',10.00,2,1),(324,84,'Participación',10.00,3,1),(325,84,'Evaluación Parcial',10.00,4,1),(326,84,'Proyecto',10.00,5,1),(327,84,'Trabajo y Exposiciones',10.00,6,1),(334,86,'Examen',50.00,1,1),(335,86,'Tareas',10.00,2,1),(336,86,'Participación',10.00,3,1),(337,86,'Evaluación Parcial',10.00,4,1),(338,86,'Proyecto',10.00,5,1),(339,86,'Trabajo y Exposiciones',10.00,6,1),(340,87,'Examen',50.00,1,1),(341,87,'Tareas',10.00,2,1),(342,87,'Participación',10.00,3,1),(343,87,'Evaluación Parcial',10.00,4,1),(344,87,'Proyecto',10.00,5,1),(345,87,'Trabajo y Exposiciones',10.00,6,1),(346,88,'Examen',50.00,1,1),(347,88,'Tareas',10.00,2,1),(348,88,'Participación',10.00,3,1),(349,88,'Evaluación Parcial',10.00,4,1),(350,88,'Proyecto',10.00,5,1),(351,88,'Trabajo y Exposiciones',10.00,6,1),(352,89,'Examen',50.00,1,1),(353,89,'Tareas',10.00,2,1),(354,89,'Participación',10.00,3,1),(355,89,'Evaluación Parcial',10.00,4,1),(356,89,'Proyecto',10.00,5,1),(357,89,'Trabajo y Exposiciones',10.00,6,1),(358,264,'Examen',50.00,1,1),(359,264,'Tareas',10.00,2,1),(360,264,'Participación',10.00,3,1),(361,264,'Evaluación parcial',10.00,4,1),(362,264,'Proyecto',10.00,5,1),(363,264,'Trabajos o exposición',10.00,6,1),(364,265,'Examen',50.00,1,1),(365,265,'Tareas',10.00,2,1),(366,265,'Participación',10.00,3,1),(367,265,'Evaluación parcial',10.00,4,1),(368,265,'Proyecto',10.00,5,1),(369,265,'Trabajos o exposición',10.00,6,1),(370,268,'Examen',50.00,1,1),(371,268,'Tareas',10.00,2,1),(372,268,'Participación',10.00,3,1),(373,268,'Evaluación parcial',10.00,4,1),(374,268,'Proyecto',10.00,5,1),(375,268,'Trabajos o exposición',10.00,6,1),(376,269,'Examen',50.00,1,1),(377,269,'Tareas',10.00,2,1),(378,269,'Participación',10.00,3,1),(379,269,'Evaluación parcial',10.00,4,1),(380,269,'Proyecto',10.00,5,1),(381,269,'Trabajos o exposición',10.00,6,1),(394,272,'Examen',50.00,1,1),(395,272,'Tareas',10.00,2,1),(396,272,'Participación',10.00,3,1),(397,272,'Evaluación parcial',10.00,4,1),(398,272,'Proyecto',10.00,5,1),(399,272,'Trabajos o exposición',10.00,6,1),(400,273,'Examen',50.00,1,1),(401,273,'Tareas',10.00,2,1),(402,273,'Participación',10.00,3,1),(403,273,'Evaluación parcial',10.00,4,1),(404,273,'Proyecto',10.00,5,1),(405,273,'Trabajos o exposición',10.00,6,1),(406,274,'Examen',50.00,1,1),(407,274,'Tareas',10.00,2,1),(408,274,'Participación',10.00,3,1),(409,274,'Evaluación parcial',10.00,4,1),(410,274,'Proyecto',10.00,5,1),(411,274,'Trabajos o exposición',10.00,6,1),(436,279,'Examen',50.00,1,1),(437,279,'Tareas',10.00,2,1),(438,279,'Participación',10.00,3,1),(439,279,'Evaluación parcial',10.00,4,1),(440,279,'Proyecto',10.00,5,1),(441,279,'Trabajos o exposición',10.00,6,1),(442,280,'Examen',50.00,1,1),(443,280,'Tareas',10.00,2,1),(444,280,'Participación',10.00,3,1),(445,280,'Evaluación parcial',10.00,4,1),(446,280,'Proyecto',10.00,5,1),(447,280,'Trabajos o exposición',10.00,6,1),(448,281,'Examen',50.00,1,1),(449,281,'Tareas',10.00,2,1),(450,281,'Participación',10.00,3,1),(451,281,'Evaluación parcial',10.00,4,1),(452,281,'Proyecto',10.00,5,1),(453,281,'Trabajos o exposición',10.00,6,1),(454,282,'Examen',50.00,1,1),(455,282,'Tareas',10.00,2,1),(456,282,'Participación',10.00,3,1),(457,282,'Evaluación parcial',10.00,4,1),(458,282,'Proyecto',10.00,5,1),(459,282,'Trabajos o exposición',10.00,6,1),(460,305,'Participación',40.00,1,1),(461,305,'Habilidades',30.00,2,1),(462,305,'Trabajo en equipo',30.00,3,1),(463,306,'Participación',40.00,1,1),(464,306,'Habilidades',30.00,2,1),(465,306,'Trabajo en equipo',30.00,3,1),(466,307,'Examen',50.00,1,1),(467,307,'Tareas',10.00,2,1),(468,307,'Participación',10.00,3,1),(469,307,'Evaluación parcial',10.00,4,1),(470,307,'Proyecto',10.00,5,1),(471,307,'Trabajos o exposición',10.00,6,1),(472,308,'Examen',50.00,1,1),(473,308,'Tareas',10.00,2,1),(474,308,'Participación',10.00,3,1),(475,308,'Evaluación parcial',10.00,4,1),(476,308,'Proyecto',10.00,5,1),(477,308,'Trabajos o exposición',10.00,6,1),(484,314,'Examen',50.00,1,1),(485,314,'Tareas',10.00,2,1),(486,314,'Participación',10.00,3,1),(487,314,'Evaluación parcial',10.00,4,1),(488,314,'Proyecto',10.00,5,1),(489,314,'Trabajos o exposición',10.00,6,1),(490,315,'Examen',50.00,1,1),(491,315,'Tareas',10.00,2,1),(492,315,'Participación',10.00,3,1),(493,315,'Evaluación parcial',10.00,4,1),(494,315,'Proyecto',10.00,5,1),(495,315,'Trabajos o exposición',10.00,6,1),(496,316,'Examen',50.00,1,1),(497,316,'Tareas',10.00,2,1),(498,316,'Participación',10.00,3,1),(499,316,'Evaluación parcial',10.00,4,1),(500,316,'Proyecto',10.00,5,1),(501,316,'Trabajos o exposición',10.00,6,1),(508,93,'Examen',50.00,1,1),(509,93,'Tareas',10.00,2,1),(510,93,'Participación',10.00,3,1),(511,93,'Evaluación parcial',10.00,4,1),(512,93,'Proyecto',10.00,5,1),(513,93,'Trabajos o exposición',10.00,6,1),(526,346,'Examen',50.00,1,1),(527,346,'Tareas',10.00,2,1),(528,346,'Participación',10.00,3,1),(529,346,'Evaluación Parcial',10.00,4,1),(530,346,'Proyecto',10.00,5,1),(531,346,'Trabajo y Exposiciones',10.00,6,1),(571,107,'Examen',50.00,1,1),(572,130,'Examen',50.00,1,1),(573,337,'Examen',50.00,1,1),(574,338,'Examen',50.00,1,1),(575,339,'Examen',50.00,1,1),(576,340,'Examen',50.00,1,1),(577,108,'Examen',50.00,1,1),(578,131,'Examen',50.00,1,1),(579,321,'Examen',50.00,1,1),(580,322,'Examen',50.00,1,1),(581,323,'Examen',50.00,1,1),(582,324,'Examen',50.00,1,1),(583,109,'Examen',50.00,1,1),(584,132,'Examen',50.00,1,1),(585,333,'Examen',50.00,1,1),(586,334,'Examen',50.00,1,1),(587,335,'Examen',50.00,1,1),(588,336,'Examen',50.00,1,1),(589,110,'Examen',50.00,1,1),(590,133,'Examen',50.00,1,1),(591,317,'Examen',50.00,1,1),(592,318,'Examen',50.00,1,1),(593,319,'Examen',50.00,1,1),(594,320,'Examen',50.00,1,1),(595,111,'Examen',50.00,1,1),(596,134,'Examen',50.00,1,1),(597,329,'Examen',50.00,1,1),(598,330,'Examen',50.00,1,1),(599,331,'Examen',50.00,1,1),(600,332,'Examen',50.00,1,1),(601,112,'Examen',50.00,1,1),(602,135,'Examen',50.00,1,1),(603,325,'Examen',50.00,1,1),(604,326,'Examen',50.00,1,1),(605,327,'Examen',50.00,1,1),(606,328,'Examen',50.00,1,1),(607,63,'Examen',50.00,1,1),(608,68,'Examen',50.00,1,1),(609,291,'Examen',50.00,1,1),(610,292,'Examen',50.00,1,1),(611,60,'Examen',50.00,1,1),(612,67,'Examen',50.00,1,1),(613,285,'Examen',50.00,1,1),(614,286,'Examen',50.00,1,1),(615,348,'Examen',50.00,1,1),(616,349,'Examen',50.00,1,1),(617,350,'Examen',50.00,1,1),(618,351,'Examen',50.00,1,1),(619,352,'Examen',50.00,1,1),(620,353,'Examen',50.00,1,1),(621,354,'Examen',50.00,1,1),(622,355,'Examen',50.00,1,1),(623,356,'Examen',50.00,1,1),(624,357,'Examen',50.00,1,1),(625,358,'Examen',50.00,1,1),(626,359,'Examen',50.00,1,1),(627,360,'Examen',50.00,1,1),(628,361,'Examen',50.00,1,1),(629,362,'Examen',50.00,1,1),(630,363,'Examen',50.00,1,1),(631,364,'Examen',50.00,1,1),(632,365,'Examen',50.00,1,1),(633,366,'Examen',50.00,1,1),(634,367,'Examen',50.00,1,1),(635,368,'Examen',50.00,1,1),(636,369,'Examen',50.00,1,1),(637,370,'Examen',50.00,1,1),(638,371,'Examen',50.00,1,1),(639,372,'Examen',50.00,1,1),(640,373,'Examen',50.00,1,1),(641,374,'Examen',50.00,1,1),(642,375,'Examen',50.00,1,1),(643,376,'Examen',50.00,1,1),(644,377,'Examen',50.00,1,1),(645,378,'Examen',50.00,1,1),(646,379,'Examen',50.00,1,1),(647,380,'Examen',50.00,1,1),(648,381,'Examen',50.00,1,1),(649,382,'Examen',50.00,1,1),(650,383,'Examen',50.00,1,1),(651,107,'Tareas',10.00,2,1),(652,130,'Tareas',10.00,2,1),(653,337,'Tareas',10.00,2,1),(654,338,'Tareas',10.00,2,1),(655,339,'Tareas',10.00,2,1),(656,340,'Tareas',10.00,2,1),(657,108,'Tareas',10.00,2,1),(658,131,'Tareas',10.00,2,1),(659,321,'Tareas',10.00,2,1),(660,322,'Tareas',10.00,2,1),(661,323,'Tareas',10.00,2,1),(662,324,'Tareas',10.00,2,1),(663,109,'Tareas',10.00,2,1),(664,132,'Tareas',10.00,2,1),(665,333,'Tareas',10.00,2,1),(666,334,'Tareas',10.00,2,1),(667,335,'Tareas',10.00,2,1),(668,336,'Tareas',10.00,2,1),(669,110,'Tareas',10.00,2,1),(670,133,'Tareas',10.00,2,1),(671,317,'Tareas',10.00,2,1),(672,318,'Tareas',10.00,2,1),(673,319,'Tareas',10.00,2,1),(674,320,'Tareas',10.00,2,1),(675,111,'Tareas',10.00,2,1),(676,134,'Tareas',10.00,2,1),(677,329,'Tareas',10.00,2,1),(678,330,'Tareas',10.00,2,1),(679,331,'Tareas',10.00,2,1),(680,332,'Tareas',10.00,2,1),(681,112,'Tareas',10.00,2,1),(682,135,'Tareas',10.00,2,1),(683,325,'Tareas',10.00,2,1),(684,326,'Tareas',10.00,2,1),(685,327,'Tareas',10.00,2,1),(686,328,'Tareas',10.00,2,1),(687,63,'Tareas',10.00,2,1),(688,68,'Tareas',10.00,2,1),(689,291,'Tareas',10.00,2,1),(690,292,'Tareas',10.00,2,1),(691,60,'Tareas',10.00,2,1),(692,67,'Tareas',10.00,2,1),(693,285,'Tareas',10.00,2,1),(694,286,'Tareas',10.00,2,1),(695,348,'Tareas',10.00,2,1),(696,349,'Tareas',10.00,2,1),(697,350,'Tareas',10.00,2,1),(698,351,'Tareas',10.00,2,1),(699,352,'Tareas',10.00,2,1),(700,353,'Tareas',10.00,2,1),(701,354,'Tareas',10.00,2,1),(702,355,'Tareas',10.00,2,1),(703,356,'Tareas',10.00,2,1),(704,357,'Tareas',10.00,2,1),(705,358,'Tareas',10.00,2,1),(706,359,'Tareas',10.00,2,1),(707,360,'Tareas',10.00,2,1),(708,361,'Tareas',10.00,2,1),(709,362,'Tareas',10.00,2,1),(710,363,'Tareas',10.00,2,1),(711,364,'Tareas',10.00,2,1),(712,365,'Tareas',10.00,2,1),(713,366,'Tareas',10.00,2,1),(714,367,'Tareas',10.00,2,1),(715,368,'Tareas',10.00,2,1),(716,369,'Tareas',10.00,2,1),(717,370,'Tareas',10.00,2,1),(718,371,'Tareas',10.00,2,1),(719,372,'Tareas',10.00,2,1),(720,373,'Tareas',10.00,2,1),(721,374,'Tareas',10.00,2,1),(722,375,'Tareas',10.00,2,1),(723,376,'Tareas',10.00,2,1),(724,377,'Tareas',10.00,2,1),(725,378,'Tareas',10.00,2,1),(726,379,'Tareas',10.00,2,1),(727,380,'Tareas',10.00,2,1),(728,381,'Tareas',10.00,2,1),(729,382,'Tareas',10.00,2,1),(730,383,'Tareas',10.00,2,1),(731,107,'Participación',10.00,3,1),(732,130,'Participación',10.00,3,1),(733,337,'Participación',10.00,3,1),(734,338,'Participación',10.00,3,1),(735,339,'Participación',10.00,3,1),(736,340,'Participación',10.00,3,1),(737,108,'Participación',10.00,3,1),(738,131,'Participación',10.00,3,1),(739,321,'Participación',10.00,3,1),(740,322,'Participación',10.00,3,1),(741,323,'Participación',10.00,3,1),(742,324,'Participación',10.00,3,1),(743,109,'Participación',10.00,3,1),(744,132,'Participación',10.00,3,1),(745,333,'Participación',10.00,3,1),(746,334,'Participación',10.00,3,1),(747,335,'Participación',10.00,3,1),(748,336,'Participación',10.00,3,1),(749,110,'Participación',10.00,3,1),(750,133,'Participación',10.00,3,1),(751,317,'Participación',10.00,3,1),(752,318,'Participación',10.00,3,1),(753,319,'Participación',10.00,3,1),(754,320,'Participación',10.00,3,1),(755,111,'Participación',10.00,3,1),(756,134,'Participación',10.00,3,1),(757,329,'Participación',10.00,3,1),(758,330,'Participación',10.00,3,1),(759,331,'Participación',10.00,3,1),(760,332,'Participación',10.00,3,1),(761,112,'Participación',10.00,3,1),(762,135,'Participación',10.00,3,1),(763,325,'Participación',10.00,3,1),(764,326,'Participación',10.00,3,1),(765,327,'Participación',10.00,3,1),(766,328,'Participación',10.00,3,1),(767,63,'Participación',10.00,3,1),(768,68,'Participación',10.00,3,1),(769,291,'Participación',10.00,3,1),(770,292,'Participación',10.00,3,1),(771,60,'Participación',10.00,3,1),(772,67,'Participación',10.00,3,1),(773,285,'Participación',10.00,3,1),(774,286,'Participación',10.00,3,1),(775,348,'Participación',10.00,3,1),(776,349,'Participación',10.00,3,1),(777,350,'Participación',10.00,3,1),(778,351,'Participación',10.00,3,1),(779,352,'Participación',10.00,3,1),(780,353,'Participación',10.00,3,1),(781,354,'Participación',10.00,3,1),(782,355,'Participación',10.00,3,1),(783,356,'Participación',10.00,3,1),(784,357,'Participación',10.00,3,1),(785,358,'Participación',10.00,3,1),(786,359,'Participación',10.00,3,1),(787,360,'Participación',10.00,3,1),(788,361,'Participación',10.00,3,1),(789,362,'Participación',10.00,3,1),(790,363,'Participación',10.00,3,1),(791,364,'Participación',10.00,3,1),(792,365,'Participación',10.00,3,1),(793,366,'Participación',10.00,3,1),(794,367,'Participación',10.00,3,1),(795,368,'Participación',10.00,3,1),(796,369,'Participación',10.00,3,1),(797,370,'Participación',10.00,3,1),(798,371,'Participación',10.00,3,1),(799,372,'Participación',10.00,3,1),(800,373,'Participación',10.00,3,1),(801,374,'Participación',10.00,3,1),(802,375,'Participación',10.00,3,1),(803,376,'Participación',10.00,3,1),(804,377,'Participación',10.00,3,1),(805,378,'Participación',10.00,3,1),(806,379,'Participación',10.00,3,1),(807,380,'Participación',10.00,3,1),(808,381,'Participación',10.00,3,1),(809,382,'Participación',10.00,3,1),(810,383,'Participación',10.00,3,1),(811,107,'Evaluación Parcial',10.00,4,1),(812,130,'Evaluación Parcial',10.00,4,1),(813,337,'Evaluación Parcial',10.00,4,1),(814,338,'Evaluación Parcial',10.00,4,1),(815,339,'Evaluación Parcial',10.00,4,1),(816,340,'Evaluación Parcial',10.00,4,1),(817,108,'Evaluación Parcial',10.00,4,1),(818,131,'Evaluación Parcial',10.00,4,1),(819,321,'Evaluación Parcial',10.00,4,1),(820,322,'Evaluación Parcial',10.00,4,1),(821,323,'Evaluación Parcial',10.00,4,1),(822,324,'Evaluación Parcial',10.00,4,1),(823,109,'Evaluación Parcial',10.00,4,1),(824,132,'Evaluación Parcial',10.00,4,1),(825,333,'Evaluación Parcial',10.00,4,1),(826,334,'Evaluación Parcial',10.00,4,1),(827,335,'Evaluación Parcial',10.00,4,1),(828,336,'Evaluación Parcial',10.00,4,1),(829,110,'Evaluación Parcial',10.00,4,1),(830,133,'Evaluación Parcial',10.00,4,1),(831,317,'Evaluación Parcial',10.00,4,1),(832,318,'Evaluación Parcial',10.00,4,1),(833,319,'Evaluación Parcial',10.00,4,1),(834,320,'Evaluación Parcial',10.00,4,1),(835,111,'Evaluación Parcial',10.00,4,1),(836,134,'Evaluación Parcial',10.00,4,1),(837,329,'Evaluación Parcial',10.00,4,1),(838,330,'Evaluación Parcial',10.00,4,1),(839,331,'Evaluación Parcial',10.00,4,1),(840,332,'Evaluación Parcial',10.00,4,1),(841,112,'Evaluación Parcial',10.00,4,1),(842,135,'Evaluación Parcial',10.00,4,1),(843,325,'Evaluación Parcial',10.00,4,1),(844,326,'Evaluación Parcial',10.00,4,1),(845,327,'Evaluación Parcial',10.00,4,1),(846,328,'Evaluación Parcial',10.00,4,1),(847,63,'Evaluación Parcial',10.00,4,1),(848,68,'Evaluación Parcial',10.00,4,1),(849,291,'Evaluación Parcial',10.00,4,1),(850,292,'Evaluación Parcial',10.00,4,1),(851,60,'Evaluación Parcial',10.00,4,1),(852,67,'Evaluación Parcial',10.00,4,1),(853,285,'Evaluación Parcial',10.00,4,1),(854,286,'Evaluación Parcial',10.00,4,1),(855,348,'Evaluación Parcial',10.00,4,1),(856,349,'Evaluación Parcial',10.00,4,1),(857,350,'Evaluación Parcial',10.00,4,1),(858,351,'Evaluación Parcial',10.00,4,1),(859,352,'Evaluación Parcial',10.00,4,1),(860,353,'Evaluación Parcial',10.00,4,1),(861,354,'Evaluación Parcial',10.00,4,1),(862,355,'Evaluación Parcial',10.00,4,1),(863,356,'Evaluación Parcial',10.00,4,1),(864,357,'Evaluación Parcial',10.00,4,1),(865,358,'Evaluación Parcial',10.00,4,1),(866,359,'Evaluación Parcial',10.00,4,1),(867,360,'Evaluación Parcial',10.00,4,1),(868,361,'Evaluación Parcial',10.00,4,1),(869,362,'Evaluación Parcial',10.00,4,1),(870,363,'Evaluación Parcial',10.00,4,1),(871,364,'Evaluación Parcial',10.00,4,1),(872,365,'Evaluación Parcial',10.00,4,1),(873,366,'Evaluación Parcial',10.00,4,1),(874,367,'Evaluación Parcial',10.00,4,1),(875,368,'Evaluación Parcial',10.00,4,1),(876,369,'Evaluación Parcial',10.00,4,1),(877,370,'Evaluación Parcial',10.00,4,1),(878,371,'Evaluación Parcial',10.00,4,1),(879,372,'Evaluación Parcial',10.00,4,1),(880,373,'Evaluación Parcial',10.00,4,1),(881,374,'Evaluación Parcial',10.00,4,1),(882,375,'Evaluación Parcial',10.00,4,1),(883,376,'Evaluación Parcial',10.00,4,1),(884,377,'Evaluación Parcial',10.00,4,1),(885,378,'Evaluación Parcial',10.00,4,1),(886,379,'Evaluación Parcial',10.00,4,1),(887,380,'Evaluación Parcial',10.00,4,1),(888,381,'Evaluación Parcial',10.00,4,1),(889,382,'Evaluación Parcial',10.00,4,1),(890,383,'Evaluación Parcial',10.00,4,1),(891,107,'Proyecto',10.00,5,1),(892,130,'Proyecto',10.00,5,1),(893,337,'Proyecto',10.00,5,1),(894,338,'Proyecto',10.00,5,1),(895,339,'Proyecto',10.00,5,1),(896,340,'Proyecto',10.00,5,1),(897,108,'Proyecto',10.00,5,1),(898,131,'Proyecto',10.00,5,1),(899,321,'Proyecto',10.00,5,1),(900,322,'Proyecto',10.00,5,1),(901,323,'Proyecto',10.00,5,1),(902,324,'Proyecto',10.00,5,1),(903,109,'Proyecto',10.00,5,1),(904,132,'Proyecto',10.00,5,1),(905,333,'Proyecto',10.00,5,1),(906,334,'Proyecto',10.00,5,1),(907,335,'Proyecto',10.00,5,1),(908,336,'Proyecto',10.00,5,1),(909,110,'Proyecto',10.00,5,1),(910,133,'Proyecto',10.00,5,1),(911,317,'Proyecto',10.00,5,1),(912,318,'Proyecto',10.00,5,1),(913,319,'Proyecto',10.00,5,1),(914,320,'Proyecto',10.00,5,1),(915,111,'Proyecto',10.00,5,1),(916,134,'Proyecto',10.00,5,1),(917,329,'Proyecto',10.00,5,1),(918,330,'Proyecto',10.00,5,1),(919,331,'Proyecto',10.00,5,1),(920,332,'Proyecto',10.00,5,1),(921,112,'Proyecto',10.00,5,1),(922,135,'Proyecto',10.00,5,1),(923,325,'Proyecto',10.00,5,1),(924,326,'Proyecto',10.00,5,1),(925,327,'Proyecto',10.00,5,1),(926,328,'Proyecto',10.00,5,1),(927,63,'Proyecto',10.00,5,1),(928,68,'Proyecto',10.00,5,1),(929,291,'Proyecto',10.00,5,1),(930,292,'Proyecto',10.00,5,1),(931,60,'Proyecto',10.00,5,1),(932,67,'Proyecto',10.00,5,1),(933,285,'Proyecto',10.00,5,1),(934,286,'Proyecto',10.00,5,1),(935,348,'Proyecto',10.00,5,1),(936,349,'Proyecto',10.00,5,1),(937,350,'Proyecto',10.00,5,1),(938,351,'Proyecto',10.00,5,1),(939,352,'Proyecto',10.00,5,1),(940,353,'Proyecto',10.00,5,1),(941,354,'Proyecto',10.00,5,1),(942,355,'Proyecto',10.00,5,1),(943,356,'Proyecto',10.00,5,1),(944,357,'Proyecto',10.00,5,1),(945,358,'Proyecto',10.00,5,1),(946,359,'Proyecto',10.00,5,1),(947,360,'Proyecto',10.00,5,1),(948,361,'Proyecto',10.00,5,1),(949,362,'Proyecto',10.00,5,1),(950,363,'Proyecto',10.00,5,1),(951,364,'Proyecto',10.00,5,1),(952,365,'Proyecto',10.00,5,1),(953,366,'Proyecto',10.00,5,1),(954,367,'Proyecto',10.00,5,1),(955,368,'Proyecto',10.00,5,1),(956,369,'Proyecto',10.00,5,1),(957,370,'Proyecto',10.00,5,1),(958,371,'Proyecto',10.00,5,1),(959,372,'Proyecto',10.00,5,1),(960,373,'Proyecto',10.00,5,1),(961,374,'Proyecto',10.00,5,1),(962,375,'Proyecto',10.00,5,1),(963,376,'Proyecto',10.00,5,1),(964,377,'Proyecto',10.00,5,1),(965,378,'Proyecto',10.00,5,1),(966,379,'Proyecto',10.00,5,1),(967,380,'Proyecto',10.00,5,1),(968,381,'Proyecto',10.00,5,1),(969,382,'Proyecto',10.00,5,1),(970,383,'Proyecto',10.00,5,1),(971,107,'Trabajo y Exposiciones',10.00,6,1),(972,130,'Trabajo y Exposiciones',10.00,6,1),(973,337,'Trabajo y Exposiciones',10.00,6,1),(974,338,'Trabajo y Exposiciones',10.00,6,1),(975,339,'Trabajo y Exposiciones',10.00,6,1),(976,340,'Trabajo y Exposiciones',10.00,6,1),(977,108,'Trabajo y Exposiciones',10.00,6,1),(978,131,'Trabajo y Exposiciones',10.00,6,1),(979,321,'Trabajo y Exposiciones',10.00,6,1),(980,322,'Trabajo y Exposiciones',10.00,6,1),(981,323,'Trabajo y Exposiciones',10.00,6,1),(982,324,'Trabajo y Exposiciones',10.00,6,1),(983,109,'Trabajo y Exposiciones',10.00,6,1),(984,132,'Trabajo y Exposiciones',10.00,6,1),(985,333,'Trabajo y Exposiciones',10.00,6,1),(986,334,'Trabajo y Exposiciones',10.00,6,1),(987,335,'Trabajo y Exposiciones',10.00,6,1),(988,336,'Trabajo y Exposiciones',10.00,6,1),(989,110,'Trabajo y Exposiciones',10.00,6,1),(990,133,'Trabajo y Exposiciones',10.00,6,1),(991,317,'Trabajo y Exposiciones',10.00,6,1),(992,318,'Trabajo y Exposiciones',10.00,6,1),(993,319,'Trabajo y Exposiciones',10.00,6,1),(994,320,'Trabajo y Exposiciones',10.00,6,1),(995,111,'Trabajo y Exposiciones',10.00,6,1),(996,134,'Trabajo y Exposiciones',10.00,6,1),(997,329,'Trabajo y Exposiciones',10.00,6,1),(998,330,'Trabajo y Exposiciones',10.00,6,1),(999,331,'Trabajo y Exposiciones',10.00,6,1),(1000,332,'Trabajo y Exposiciones',10.00,6,1),(1001,112,'Trabajo y Exposiciones',10.00,6,1),(1002,135,'Trabajo y Exposiciones',10.00,6,1),(1003,325,'Trabajo y Exposiciones',10.00,6,1),(1004,326,'Trabajo y Exposiciones',10.00,6,1),(1005,327,'Trabajo y Exposiciones',10.00,6,1),(1006,328,'Trabajo y Exposiciones',10.00,6,1),(1007,63,'Trabajo y Exposiciones',10.00,6,1),(1008,68,'Trabajo y Exposiciones',10.00,6,1),(1009,291,'Trabajo y Exposiciones',10.00,6,1),(1010,292,'Trabajo y Exposiciones',10.00,6,1),(1011,60,'Trabajo y Exposiciones',10.00,6,1),(1012,67,'Trabajo y Exposiciones',10.00,6,1),(1013,285,'Trabajo y Exposiciones',10.00,6,1),(1014,286,'Trabajo y Exposiciones',10.00,6,1),(1015,348,'Trabajo y Exposiciones',10.00,6,1),(1016,349,'Trabajo y Exposiciones',10.00,6,1),(1017,350,'Trabajo y Exposiciones',10.00,6,1),(1018,351,'Trabajo y Exposiciones',10.00,6,1),(1019,352,'Trabajo y Exposiciones',10.00,6,1),(1020,353,'Trabajo y Exposiciones',10.00,6,1),(1021,354,'Trabajo y Exposiciones',10.00,6,1),(1022,355,'Trabajo y Exposiciones',10.00,6,1),(1023,356,'Trabajo y Exposiciones',10.00,6,1),(1024,357,'Trabajo y Exposiciones',10.00,6,1),(1025,358,'Trabajo y Exposiciones',10.00,6,1),(1026,359,'Trabajo y Exposiciones',10.00,6,1),(1027,360,'Trabajo y Exposiciones',10.00,6,1),(1028,361,'Trabajo y Exposiciones',10.00,6,1),(1029,362,'Trabajo y Exposiciones',10.00,6,1),(1030,363,'Trabajo y Exposiciones',10.00,6,1),(1031,364,'Trabajo y Exposiciones',10.00,6,1),(1032,365,'Trabajo y Exposiciones',10.00,6,1),(1033,366,'Trabajo y Exposiciones',10.00,6,1),(1034,367,'Trabajo y Exposiciones',10.00,6,1),(1035,368,'Trabajo y Exposiciones',10.00,6,1),(1036,369,'Trabajo y Exposiciones',10.00,6,1),(1037,370,'Trabajo y Exposiciones',10.00,6,1),(1038,371,'Trabajo y Exposiciones',10.00,6,1),(1039,372,'Trabajo y Exposiciones',10.00,6,1),(1040,373,'Trabajo y Exposiciones',10.00,6,1),(1041,374,'Trabajo y Exposiciones',10.00,6,1),(1042,375,'Trabajo y Exposiciones',10.00,6,1),(1043,376,'Trabajo y Exposiciones',10.00,6,1),(1044,377,'Trabajo y Exposiciones',10.00,6,1),(1045,378,'Trabajo y Exposiciones',10.00,6,1),(1046,379,'Trabajo y Exposiciones',10.00,6,1),(1047,380,'Trabajo y Exposiciones',10.00,6,1),(1048,381,'Trabajo y Exposiciones',10.00,6,1),(1049,382,'Trabajo y Exposiciones',10.00,6,1),(1050,383,'Trabajo y Exposiciones',10.00,6,1),(1084,113,'Examen',50.00,1,1),(1085,113,'Tareas',20.00,2,1),(1086,113,'Participación',15.00,3,1),(1087,113,'Proyecto',15.00,4,1);
/*!40000 ALTER TABLE `asignacion_aspectos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `asignacion_disciplina_aspectos`
--

DROP TABLE IF EXISTS `asignacion_disciplina_aspectos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `asignacion_disciplina_aspectos` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `asignacion_id` int(10) unsigned DEFAULT NULL,
  `grado` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `seccion` enum('maternal','preescolar','primaria','secundaria') NOT NULL DEFAULT 'primaria',
  `nombre` varchar(100) NOT NULL,
  `porcentaje` decimal(5,2) NOT NULL DEFAULT 0.00,
  `orden` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_disciplina_aspecto` (`asignacion_id`,`nombre`),
  CONSTRAINT `fk_disciplina_asig` FOREIGN KEY (`asignacion_id`) REFERENCES `asignaciones` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignacion_disciplina_aspectos`
--

LOCK TABLES `asignacion_disciplina_aspectos` WRITE;
/*!40000 ALTER TABLE `asignacion_disciplina_aspectos` DISABLE KEYS */;
INSERT INTO `asignacion_disciplina_aspectos` VALUES (1,NULL,1,'primaria','Examen',50.00,1,1),(2,NULL,1,'primaria','Tareas',10.00,2,1),(3,NULL,1,'primaria','Participación',10.00,3,1),(4,NULL,1,'primaria','Evaluación Parcial',10.00,4,1),(5,NULL,1,'primaria','Proyecto',10.00,5,1),(6,NULL,1,'primaria','Trabajo y Exposiciones',10.00,6,1),(7,NULL,1,'primaria','Promedio',0.00,7,1);
/*!40000 ALTER TABLE `asignacion_disciplina_aspectos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `asignacion_ingles_aspectos`
--

DROP TABLE IF EXISTS `asignacion_ingles_aspectos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `asignacion_ingles_aspectos` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `asignacion_id` int(10) unsigned DEFAULT NULL,
  `grado` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `seccion` enum('maternal','preescolar','primaria','secundaria') NOT NULL DEFAULT 'primaria',
  `nombre` varchar(100) NOT NULL,
  `porcentaje` decimal(5,2) NOT NULL DEFAULT 0.00,
  `orden` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'Orden en la boleta',
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_ingles_aspecto` (`asignacion_id`,`nombre`),
  CONSTRAINT `fk_asigIngles_asig` FOREIGN KEY (`asignacion_id`) REFERENCES `asignaciones` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1024 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignacion_ingles_aspectos`
--

LOCK TABLES `asignacion_ingles_aspectos` WRITE;
/*!40000 ALTER TABLE `asignacion_ingles_aspectos` DISABLE KEYS */;
INSERT INTO `asignacion_ingles_aspectos` VALUES (169,NULL,1,'primaria','Listening',0.00,0,1),(170,NULL,1,'primaria','Speaking',0.00,0,1),(171,NULL,1,'primaria','Reading',0.00,0,1),(172,NULL,1,'primaria','Writing',0.00,0,1),(173,NULL,1,'primaria','Vocabulary',0.00,0,1),(174,NULL,1,'primaria','Grammar',0.00,0,1),(175,NULL,1,'primaria','Spelling',0.00,0,1),(176,NULL,1,'primaria','Science',0.00,0,1),(177,44,1,'primaria','Listening',0.00,0,1),(178,44,1,'primaria','Speaking',0.00,0,1),(179,44,1,'primaria','Reading',0.00,0,1),(180,44,1,'primaria','Writing',0.00,0,1),(181,44,1,'primaria','Vocabulary',0.00,0,1),(182,44,1,'primaria','Grammar',0.00,0,1),(183,44,1,'primaria','Spelling',0.00,0,1),(184,44,1,'primaria','Science',0.00,0,1),(193,NULL,1,'primaria','Listening',0.00,0,1),(194,NULL,1,'primaria','Speaking',0.00,0,1),(195,NULL,1,'primaria','Reading',0.00,0,1),(196,NULL,1,'primaria','Writing',0.00,0,1),(197,NULL,1,'primaria','Vocabulary',0.00,0,1),(198,NULL,1,'primaria','Grammar',0.00,0,1),(199,NULL,1,'primaria','Spelling',0.00,0,1),(200,NULL,1,'primaria','Science',0.00,0,1),(201,NULL,1,'primaria','Listening',0.00,0,1),(202,NULL,1,'primaria','Speaking',0.00,0,1),(203,NULL,1,'primaria','Reading',0.00,0,1),(204,NULL,1,'primaria','Writing',0.00,0,1),(205,NULL,1,'primaria','Vocabulary',0.00,0,1),(206,NULL,1,'primaria','Grammar',0.00,0,1),(207,NULL,1,'primaria','Spelling',0.00,0,1),(208,NULL,1,'primaria','Phonetics',0.00,0,1),(209,NULL,1,'primaria','Science',0.00,0,1),(210,NULL,2,'primaria','Listening',0.00,0,1),(211,NULL,2,'primaria','Speaking',0.00,0,1),(212,NULL,2,'primaria','Reading',0.00,0,1),(213,NULL,2,'primaria','Writing',0.00,0,1),(214,NULL,2,'primaria','Vocabulary',0.00,0,1),(215,NULL,2,'primaria','Grammar',0.00,0,1),(216,NULL,2,'primaria','Spelling',0.00,0,1),(217,NULL,2,'primaria','Phonetics',0.00,0,1),(218,NULL,2,'primaria','Science',0.00,0,1),(219,NULL,3,'primaria','Listening',0.00,0,1),(220,NULL,3,'primaria','Speaking',0.00,0,1),(221,NULL,3,'primaria','Reading',0.00,0,1),(222,NULL,3,'primaria','Writing',0.00,0,1),(223,NULL,3,'primaria','Vocabulary',0.00,0,1),(224,NULL,3,'primaria','Grammar',0.00,0,1),(225,NULL,3,'primaria','Spelling',0.00,0,1),(226,NULL,3,'primaria','Phonetics',0.00,0,1),(227,NULL,3,'primaria','Science',0.00,0,1),(228,NULL,4,'primaria','Listening',0.00,0,1),(229,NULL,4,'primaria','Speaking',0.00,0,1),(230,NULL,4,'primaria','Reading',0.00,0,1),(231,NULL,4,'primaria','Writing',0.00,0,1),(232,NULL,4,'primaria','Vocabulary',0.00,0,1),(233,NULL,4,'primaria','Grammar',0.00,0,1),(234,NULL,4,'primaria','Spelling',0.00,0,1),(235,NULL,4,'primaria','Phonetics',0.00,0,1),(236,NULL,4,'primaria','Science',0.00,0,1),(237,NULL,5,'primaria','Listening',0.00,0,1),(238,NULL,5,'primaria','Speaking',0.00,0,1),(239,NULL,5,'primaria','Reading',0.00,0,1),(240,NULL,5,'primaria','Writing',0.00,0,1),(241,NULL,5,'primaria','Vocabulary',0.00,0,1),(242,NULL,5,'primaria','Grammar',0.00,0,1),(243,NULL,5,'primaria','Spelling',0.00,0,1),(244,NULL,5,'primaria','Phonetics',0.00,0,1),(245,NULL,5,'primaria','Science',0.00,0,1),(246,NULL,5,'primaria','Social Studies',0.00,0,1),(247,NULL,5,'primaria','Literature',0.00,0,1),(248,NULL,6,'primaria','Listening',0.00,0,1),(249,NULL,6,'primaria','Speaking',0.00,0,1),(250,NULL,6,'primaria','Reading',0.00,0,1),(251,NULL,6,'primaria','Writing',0.00,0,1),(252,NULL,6,'primaria','Vocabulary',0.00,0,1),(253,NULL,6,'primaria','Grammar',0.00,0,1),(254,NULL,6,'primaria','Spelling',0.00,0,1),(255,NULL,6,'primaria','Phonetics',0.00,0,1),(256,NULL,6,'primaria','Science',0.00,0,1),(257,NULL,6,'primaria','Social Studies',0.00,0,1),(258,NULL,6,'primaria','Literature',0.00,0,1),(259,NULL,1,'secundaria','Listening',0.00,0,1),(260,NULL,1,'secundaria','Speaking',0.00,0,1),(261,NULL,1,'secundaria','Reading',0.00,0,1),(262,NULL,1,'secundaria','Writing',0.00,0,1),(263,NULL,1,'secundaria','Vocabulary',0.00,0,1),(264,NULL,1,'secundaria','Grammar',0.00,0,1),(265,NULL,1,'secundaria','Spelling',0.00,0,1),(266,NULL,1,'secundaria','Phonetics',0.00,0,1),(267,NULL,1,'secundaria','Science',0.00,0,1),(268,NULL,1,'secundaria','Social Studies',0.00,0,1),(269,NULL,1,'secundaria','Literature',0.00,0,1),(270,NULL,2,'secundaria','Listening',0.00,0,1),(271,NULL,2,'secundaria','Speaking',0.00,0,1),(272,NULL,2,'secundaria','Reading',0.00,0,1),(273,NULL,2,'secundaria','Writing',0.00,0,1),(274,NULL,2,'secundaria','Vocabulary',0.00,0,1),(275,NULL,2,'secundaria','Grammar',0.00,0,1),(276,NULL,2,'secundaria','Spelling',0.00,0,1),(277,NULL,2,'secundaria','Phonetics',0.00,0,1),(278,NULL,2,'secundaria','Science',0.00,0,1),(279,NULL,2,'secundaria','Social Studies',0.00,0,1),(280,NULL,2,'secundaria','Literature',0.00,0,1),(281,NULL,3,'secundaria','Listening',0.00,0,1),(282,NULL,3,'secundaria','Speaking',0.00,0,1),(283,NULL,3,'secundaria','Reading',0.00,0,1),(284,NULL,3,'secundaria','Writing',0.00,0,1),(285,NULL,3,'secundaria','Vocabulary',0.00,0,1),(286,NULL,3,'secundaria','Grammar',0.00,0,1),(287,NULL,3,'secundaria','Spelling',0.00,0,1),(288,NULL,3,'secundaria','Phonetics',0.00,0,1),(289,NULL,3,'secundaria','Science',0.00,0,1),(290,NULL,3,'secundaria','Social Studies',0.00,0,1),(291,NULL,3,'secundaria','Literature',0.00,0,1),(292,NULL,1,'primaria','Listening',0.00,0,1),(293,NULL,1,'primaria','Speaking',0.00,0,1),(294,NULL,1,'primaria','Reading',0.00,0,1),(295,NULL,1,'primaria','Writing',0.00,0,1),(296,NULL,1,'primaria','Vocabulary',0.00,0,1),(297,NULL,1,'primaria','Grammar',0.00,0,1),(298,NULL,1,'primaria','Spelling',0.00,0,1),(299,NULL,1,'primaria','Phonetics',0.00,0,1),(300,NULL,1,'primaria','Science',0.00,0,1),(301,NULL,2,'primaria','Listening',0.00,0,1),(302,NULL,2,'primaria','Speaking',0.00,0,1),(303,NULL,2,'primaria','Reading',0.00,0,1),(304,NULL,2,'primaria','Writing',0.00,0,1),(305,NULL,2,'primaria','Vocabulary',0.00,0,1),(306,NULL,2,'primaria','Grammar',0.00,0,1),(307,NULL,2,'primaria','Spelling',0.00,0,1),(308,NULL,2,'primaria','Phonetics',0.00,0,1),(309,NULL,2,'primaria','Science',0.00,0,1),(310,NULL,3,'primaria','Listening',0.00,0,1),(311,NULL,3,'primaria','Speaking',0.00,0,1),(312,NULL,3,'primaria','Reading',0.00,0,1),(313,NULL,3,'primaria','Writing',0.00,0,1),(314,NULL,3,'primaria','Vocabulary',0.00,0,1),(315,NULL,3,'primaria','Grammar',0.00,0,1),(316,NULL,3,'primaria','Spelling',0.00,0,1),(317,NULL,3,'primaria','Phonetics',0.00,0,1),(318,NULL,3,'primaria','Science',0.00,0,1),(319,NULL,4,'primaria','Listening',0.00,0,1),(320,NULL,4,'primaria','Speaking',0.00,0,1),(321,NULL,4,'primaria','Reading',0.00,0,1),(322,NULL,4,'primaria','Writing',0.00,0,1),(323,NULL,4,'primaria','Vocabulary',0.00,0,1),(324,NULL,4,'primaria','Grammar',0.00,0,1),(325,NULL,4,'primaria','Spelling',0.00,0,1),(326,NULL,4,'primaria','Phonetics',0.00,0,1),(327,NULL,4,'primaria','Science',0.00,0,1),(328,NULL,5,'primaria','Listening',0.00,0,1),(329,NULL,5,'primaria','Speaking',0.00,0,1),(330,NULL,5,'primaria','Reading',0.00,0,1),(331,NULL,5,'primaria','Writing',0.00,0,1),(332,NULL,5,'primaria','Vocabulary',0.00,0,1),(333,NULL,5,'primaria','Grammar',0.00,0,1),(334,NULL,5,'primaria','Spelling',0.00,0,1),(335,NULL,5,'primaria','Phonetics',0.00,0,1),(336,NULL,5,'primaria','Science',0.00,0,1),(337,NULL,5,'primaria','Social Studies',0.00,0,1),(338,NULL,5,'primaria','Literature',0.00,0,1),(339,NULL,6,'primaria','Listening',0.00,0,1),(340,NULL,6,'primaria','Speaking',0.00,0,1),(341,NULL,6,'primaria','Reading',0.00,0,1),(342,NULL,6,'primaria','Writing',0.00,0,1),(343,NULL,6,'primaria','Vocabulary',0.00,0,1),(344,NULL,6,'primaria','Grammar',0.00,0,1),(345,NULL,6,'primaria','Spelling',0.00,0,1),(346,NULL,6,'primaria','Phonetics',0.00,0,1),(347,NULL,6,'primaria','Science',0.00,0,1),(348,NULL,6,'primaria','Social Studies',0.00,0,1),(349,NULL,6,'primaria','Literature',0.00,0,1),(350,NULL,1,'secundaria','Listening',0.00,0,1),(351,NULL,1,'secundaria','Speaking',0.00,0,1),(352,NULL,1,'secundaria','Reading',0.00,0,1),(353,NULL,1,'secundaria','Writing',0.00,0,1),(354,NULL,1,'secundaria','Vocabulary',0.00,0,1),(355,NULL,1,'secundaria','Grammar',0.00,0,1),(356,NULL,1,'secundaria','Spelling',0.00,0,1),(357,NULL,1,'secundaria','Phonetics',0.00,0,1),(358,NULL,1,'secundaria','Science',0.00,0,1),(359,NULL,1,'secundaria','Social Studies',0.00,0,1),(360,NULL,1,'secundaria','Literature',0.00,0,1),(361,NULL,2,'secundaria','Listening',0.00,0,1),(362,NULL,2,'secundaria','Speaking',0.00,0,1),(363,NULL,2,'secundaria','Reading',0.00,0,1),(364,NULL,2,'secundaria','Writing',0.00,0,1),(365,NULL,2,'secundaria','Vocabulary',0.00,0,1),(366,NULL,2,'secundaria','Grammar',0.00,0,1),(367,NULL,2,'secundaria','Spelling',0.00,0,1),(368,NULL,2,'secundaria','Phonetics',0.00,0,1),(369,NULL,2,'secundaria','Science',0.00,0,1),(370,NULL,2,'secundaria','Social Studies',0.00,0,1),(371,NULL,2,'secundaria','Literature',0.00,0,1),(372,NULL,3,'secundaria','Listening',0.00,0,1),(373,NULL,3,'secundaria','Speaking',0.00,0,1),(374,NULL,3,'secundaria','Reading',0.00,0,1),(375,NULL,3,'secundaria','Writing',0.00,0,1),(376,NULL,3,'secundaria','Vocabulary',0.00,0,1),(377,NULL,3,'secundaria','Grammar',0.00,0,1),(378,NULL,3,'secundaria','Spelling',0.00,0,1),(379,NULL,3,'secundaria','Phonetics',0.00,0,1),(380,NULL,3,'secundaria','Science',0.00,0,1),(381,NULL,3,'secundaria','Social Studies',0.00,0,1),(382,NULL,3,'secundaria','Literature',0.00,0,1),(383,149,2,'primaria','Listening',0.00,1,1),(384,149,2,'primaria','Speaking',0.00,2,1),(385,149,2,'primaria','Writing',0.00,3,1),(386,149,2,'primaria','Reading',0.00,4,1),(387,149,2,'primaria','Vocabulary',0.00,5,1),(388,149,2,'primaria','Grammar',0.00,6,1),(389,149,2,'primaria','Spelling',0.00,7,1),(390,149,2,'primaria','Science',0.00,8,1),(391,164,2,'primaria','Listening',0.00,1,1),(392,164,2,'primaria','Speaking',0.00,2,1),(393,164,2,'primaria','Writing',0.00,3,1),(394,164,2,'primaria','Reading',0.00,4,1),(395,164,2,'primaria','Vocabulary',0.00,5,1),(396,164,2,'primaria','Grammar',0.00,6,1),(397,164,2,'primaria','Spelling',0.00,7,1),(398,164,2,'primaria','Science',0.00,8,1),(399,123,1,'primaria','Grammar',50.00,1,1),(400,123,1,'primaria','Speaking',20.00,2,1),(401,123,1,'primaria','Listening',10.00,3,1),(402,123,1,'primaria','Reading',10.00,4,1),(403,123,1,'primaria','Writing',10.00,5,1),(404,107,1,'primaria','Grammar',0.00,1,1),(405,130,1,'primaria','Grammar',0.00,1,1),(406,181,2,'primaria','Grammar',0.00,1,1),(407,192,2,'primaria','Grammar',0.00,1,1),(408,212,2,'primaria','Grammar',0.00,1,1),(409,243,2,'primaria','Grammar',0.00,1,1),(410,337,1,'primaria','Grammar',0.00,1,1),(411,338,1,'primaria','Grammar',0.00,1,1),(412,339,1,'primaria','Grammar',0.00,1,1),(413,340,1,'primaria','Grammar',0.00,1,1),(414,108,1,'primaria','Grammar',0.00,1,1),(415,131,1,'primaria','Grammar',0.00,1,1),(416,185,2,'primaria','Grammar',0.00,1,1),(417,196,2,'primaria','Grammar',0.00,1,1),(418,213,2,'primaria','Grammar',0.00,1,1),(419,244,2,'primaria','Grammar',0.00,1,1),(420,321,1,'primaria','Grammar',0.00,1,1),(421,322,1,'primaria','Grammar',0.00,1,1),(422,323,1,'primaria','Grammar',0.00,1,1),(423,324,1,'primaria','Grammar',0.00,1,1),(424,109,1,'primaria','Grammar',0.00,1,1),(425,132,1,'primaria','Grammar',0.00,1,1),(426,183,2,'primaria','Grammar',0.00,1,1),(427,194,2,'primaria','Grammar',0.00,1,1),(428,214,2,'primaria','Grammar',0.00,1,1),(429,245,2,'primaria','Grammar',0.00,1,1),(430,333,1,'primaria','Grammar',0.00,1,1),(431,334,1,'primaria','Grammar',0.00,1,1),(432,335,1,'primaria','Grammar',0.00,1,1),(433,336,1,'primaria','Grammar',0.00,1,1),(434,110,1,'primaria','Grammar',0.00,1,1),(435,133,1,'primaria','Grammar',0.00,1,1),(436,182,2,'primaria','Grammar',0.00,1,1),(437,193,2,'primaria','Grammar',0.00,1,1),(438,215,2,'primaria','Grammar',0.00,1,1),(439,246,2,'primaria','Grammar',0.00,1,1),(440,317,1,'primaria','Grammar',0.00,1,1),(441,318,1,'primaria','Grammar',0.00,1,1),(442,319,1,'primaria','Grammar',0.00,1,1),(443,320,1,'primaria','Grammar',0.00,1,1),(444,111,1,'primaria','Grammar',0.00,1,1),(445,134,1,'primaria','Grammar',0.00,1,1),(446,184,2,'primaria','Grammar',0.00,1,1),(447,195,2,'primaria','Grammar',0.00,1,1),(448,216,2,'primaria','Grammar',0.00,1,1),(449,247,2,'primaria','Grammar',0.00,1,1),(450,329,1,'primaria','Grammar',0.00,1,1),(451,330,1,'primaria','Grammar',0.00,1,1),(452,331,1,'primaria','Grammar',0.00,1,1),(453,332,1,'primaria','Grammar',0.00,1,1),(454,112,1,'primaria','Grammar',0.00,1,1),(455,135,1,'primaria','Grammar',0.00,1,1),(456,187,2,'primaria','Grammar',0.00,1,1),(457,198,2,'primaria','Grammar',0.00,1,1),(458,217,2,'primaria','Grammar',0.00,1,1),(459,248,2,'primaria','Grammar',0.00,1,1),(460,325,1,'primaria','Grammar',0.00,1,1),(461,326,1,'primaria','Grammar',0.00,1,1),(462,327,1,'primaria','Grammar',0.00,1,1),(463,328,1,'primaria','Grammar',0.00,1,1),(464,63,1,'primaria','Grammar',0.00,1,1),(465,68,1,'primaria','Grammar',0.00,1,1),(466,180,2,'primaria','Grammar',0.00,1,1),(467,191,2,'primaria','Grammar',0.00,1,1),(468,220,2,'primaria','Grammar',0.00,1,1),(469,251,2,'primaria','Grammar',0.00,1,1),(470,291,1,'primaria','Grammar',0.00,1,1),(471,292,1,'primaria','Grammar',0.00,1,1),(472,60,1,'primaria','Grammar',0.00,1,1),(473,67,1,'primaria','Grammar',0.00,1,1),(474,179,2,'primaria','Grammar',0.00,1,1),(475,190,2,'primaria','Grammar',0.00,1,1),(476,221,2,'primaria','Grammar',0.00,1,1),(477,252,2,'primaria','Grammar',0.00,1,1),(478,285,1,'primaria','Grammar',0.00,1,1),(479,286,1,'primaria','Grammar',0.00,1,1),(480,348,1,'primaria','Grammar',0.00,1,1),(481,349,1,'primaria','Grammar',0.00,1,1),(482,350,1,'primaria','Grammar',0.00,1,1),(483,351,1,'primaria','Grammar',0.00,1,1),(484,352,1,'primaria','Grammar',0.00,1,1),(485,353,1,'primaria','Grammar',0.00,1,1),(486,354,1,'primaria','Grammar',0.00,1,1),(487,355,1,'primaria','Grammar',0.00,1,1),(488,356,1,'primaria','Grammar',0.00,1,1),(489,357,1,'primaria','Grammar',0.00,1,1),(490,358,1,'primaria','Grammar',0.00,1,1),(491,359,1,'primaria','Grammar',0.00,1,1),(492,360,1,'primaria','Grammar',0.00,1,1),(493,361,1,'primaria','Grammar',0.00,1,1),(494,362,1,'primaria','Grammar',0.00,1,1),(495,363,1,'primaria','Grammar',0.00,1,1),(496,364,1,'primaria','Grammar',0.00,1,1),(497,365,1,'primaria','Grammar',0.00,1,1),(498,366,1,'primaria','Grammar',0.00,1,1),(499,367,1,'primaria','Grammar',0.00,1,1),(500,186,2,'primaria','Grammar',0.00,1,1),(501,197,2,'primaria','Grammar',0.00,1,1),(502,222,2,'primaria','Grammar',0.00,1,1),(503,253,2,'primaria','Grammar',0.00,1,1),(504,368,1,'primaria','Grammar',0.00,1,1),(505,369,1,'primaria','Grammar',0.00,1,1),(506,370,1,'primaria','Grammar',0.00,1,1),(507,371,1,'primaria','Grammar',0.00,1,1),(508,372,1,'primaria','Grammar',0.00,1,1),(509,373,1,'primaria','Grammar',0.00,1,1),(510,374,1,'primaria','Grammar',0.00,1,1),(511,375,1,'primaria','Grammar',0.00,1,1),(512,188,2,'primaria','Grammar',0.00,1,1),(513,199,2,'primaria','Grammar',0.00,1,1),(514,223,2,'primaria','Grammar',0.00,1,1),(515,254,2,'primaria','Grammar',0.00,1,1),(516,376,1,'primaria','Grammar',0.00,1,1),(517,377,1,'primaria','Grammar',0.00,1,1),(518,378,1,'primaria','Grammar',0.00,1,1),(519,379,1,'primaria','Grammar',0.00,1,1),(520,178,2,'primaria','Grammar',0.00,1,1),(521,189,2,'primaria','Grammar',0.00,1,1),(522,224,2,'primaria','Grammar',0.00,1,1),(523,255,2,'primaria','Grammar',0.00,1,1),(524,380,1,'primaria','Grammar',0.00,1,1),(525,381,1,'primaria','Grammar',0.00,1,1),(526,382,1,'primaria','Grammar',0.00,1,1),(527,383,1,'primaria','Grammar',0.00,1,1),(528,107,1,'primaria','Speaking',0.00,2,1),(529,130,1,'primaria','Speaking',0.00,2,1),(530,181,2,'primaria','Speaking',0.00,2,1),(531,192,2,'primaria','Speaking',0.00,2,1),(532,212,2,'primaria','Speaking',0.00,2,1),(533,243,2,'primaria','Speaking',0.00,2,1),(534,337,1,'primaria','Speaking',0.00,2,1),(535,338,1,'primaria','Speaking',0.00,2,1),(536,339,1,'primaria','Speaking',0.00,2,1),(537,340,1,'primaria','Speaking',0.00,2,1),(538,108,1,'primaria','Speaking',0.00,2,1),(539,131,1,'primaria','Speaking',0.00,2,1),(540,185,2,'primaria','Speaking',0.00,2,1),(541,196,2,'primaria','Speaking',0.00,2,1),(542,213,2,'primaria','Speaking',0.00,2,1),(543,244,2,'primaria','Speaking',0.00,2,1),(544,321,1,'primaria','Speaking',0.00,2,1),(545,322,1,'primaria','Speaking',0.00,2,1),(546,323,1,'primaria','Speaking',0.00,2,1),(547,324,1,'primaria','Speaking',0.00,2,1),(548,109,1,'primaria','Speaking',0.00,2,1),(549,132,1,'primaria','Speaking',0.00,2,1),(550,183,2,'primaria','Speaking',0.00,2,1),(551,194,2,'primaria','Speaking',0.00,2,1),(552,214,2,'primaria','Speaking',0.00,2,1),(553,245,2,'primaria','Speaking',0.00,2,1),(554,333,1,'primaria','Speaking',0.00,2,1),(555,334,1,'primaria','Speaking',0.00,2,1),(556,335,1,'primaria','Speaking',0.00,2,1),(557,336,1,'primaria','Speaking',0.00,2,1),(558,110,1,'primaria','Speaking',0.00,2,1),(559,133,1,'primaria','Speaking',0.00,2,1),(560,182,2,'primaria','Speaking',0.00,2,1),(561,193,2,'primaria','Speaking',0.00,2,1),(562,215,2,'primaria','Speaking',0.00,2,1),(563,246,2,'primaria','Speaking',0.00,2,1),(564,317,1,'primaria','Speaking',0.00,2,1),(565,318,1,'primaria','Speaking',0.00,2,1),(566,319,1,'primaria','Speaking',0.00,2,1),(567,320,1,'primaria','Speaking',0.00,2,1),(568,111,1,'primaria','Speaking',0.00,2,1),(569,134,1,'primaria','Speaking',0.00,2,1),(570,184,2,'primaria','Speaking',0.00,2,1),(571,195,2,'primaria','Speaking',0.00,2,1),(572,216,2,'primaria','Speaking',0.00,2,1),(573,247,2,'primaria','Speaking',0.00,2,1),(574,329,1,'primaria','Speaking',0.00,2,1),(575,330,1,'primaria','Speaking',0.00,2,1),(576,331,1,'primaria','Speaking',0.00,2,1),(577,332,1,'primaria','Speaking',0.00,2,1),(578,112,1,'primaria','Speaking',0.00,2,1),(579,135,1,'primaria','Speaking',0.00,2,1),(580,187,2,'primaria','Speaking',0.00,2,1),(581,198,2,'primaria','Speaking',0.00,2,1),(582,217,2,'primaria','Speaking',0.00,2,1),(583,248,2,'primaria','Speaking',0.00,2,1),(584,325,1,'primaria','Speaking',0.00,2,1),(585,326,1,'primaria','Speaking',0.00,2,1),(586,327,1,'primaria','Speaking',0.00,2,1),(587,328,1,'primaria','Speaking',0.00,2,1),(588,63,1,'primaria','Speaking',0.00,2,1),(589,68,1,'primaria','Speaking',0.00,2,1),(590,180,2,'primaria','Speaking',0.00,2,1),(591,191,2,'primaria','Speaking',0.00,2,1),(592,220,2,'primaria','Speaking',0.00,2,1),(593,251,2,'primaria','Speaking',0.00,2,1),(594,291,1,'primaria','Speaking',0.00,2,1),(595,292,1,'primaria','Speaking',0.00,2,1),(596,60,1,'primaria','Speaking',0.00,2,1),(597,67,1,'primaria','Speaking',0.00,2,1),(598,179,2,'primaria','Speaking',0.00,2,1),(599,190,2,'primaria','Speaking',0.00,2,1),(600,221,2,'primaria','Speaking',0.00,2,1),(601,252,2,'primaria','Speaking',0.00,2,1),(602,285,1,'primaria','Speaking',0.00,2,1),(603,286,1,'primaria','Speaking',0.00,2,1),(604,348,1,'primaria','Speaking',0.00,2,1),(605,349,1,'primaria','Speaking',0.00,2,1),(606,350,1,'primaria','Speaking',0.00,2,1),(607,351,1,'primaria','Speaking',0.00,2,1),(608,352,1,'primaria','Speaking',0.00,2,1),(609,353,1,'primaria','Speaking',0.00,2,1),(610,354,1,'primaria','Speaking',0.00,2,1),(611,355,1,'primaria','Speaking',0.00,2,1),(612,356,1,'primaria','Speaking',0.00,2,1),(613,357,1,'primaria','Speaking',0.00,2,1),(614,358,1,'primaria','Speaking',0.00,2,1),(615,359,1,'primaria','Speaking',0.00,2,1),(616,360,1,'primaria','Speaking',0.00,2,1),(617,361,1,'primaria','Speaking',0.00,2,1),(618,362,1,'primaria','Speaking',0.00,2,1),(619,363,1,'primaria','Speaking',0.00,2,1),(620,364,1,'primaria','Speaking',0.00,2,1),(621,365,1,'primaria','Speaking',0.00,2,1),(622,366,1,'primaria','Speaking',0.00,2,1),(623,367,1,'primaria','Speaking',0.00,2,1),(624,186,2,'primaria','Speaking',0.00,2,1),(625,197,2,'primaria','Speaking',0.00,2,1),(626,222,2,'primaria','Speaking',0.00,2,1),(627,253,2,'primaria','Speaking',0.00,2,1),(628,368,1,'primaria','Speaking',0.00,2,1),(629,369,1,'primaria','Speaking',0.00,2,1),(630,370,1,'primaria','Speaking',0.00,2,1),(631,371,1,'primaria','Speaking',0.00,2,1),(632,372,1,'primaria','Speaking',0.00,2,1),(633,373,1,'primaria','Speaking',0.00,2,1),(634,374,1,'primaria','Speaking',0.00,2,1),(635,375,1,'primaria','Speaking',0.00,2,1),(636,188,2,'primaria','Speaking',0.00,2,1),(637,199,2,'primaria','Speaking',0.00,2,1),(638,223,2,'primaria','Speaking',0.00,2,1),(639,254,2,'primaria','Speaking',0.00,2,1),(640,376,1,'primaria','Speaking',0.00,2,1),(641,377,1,'primaria','Speaking',0.00,2,1),(642,378,1,'primaria','Speaking',0.00,2,1),(643,379,1,'primaria','Speaking',0.00,2,1),(644,178,2,'primaria','Speaking',0.00,2,1),(645,189,2,'primaria','Speaking',0.00,2,1),(646,224,2,'primaria','Speaking',0.00,2,1),(647,255,2,'primaria','Speaking',0.00,2,1),(648,380,1,'primaria','Speaking',0.00,2,1),(649,381,1,'primaria','Speaking',0.00,2,1),(650,382,1,'primaria','Speaking',0.00,2,1),(651,383,1,'primaria','Speaking',0.00,2,1),(652,107,1,'primaria','Listening',0.00,3,1),(653,130,1,'primaria','Listening',0.00,3,1),(654,181,2,'primaria','Listening',0.00,3,1),(655,192,2,'primaria','Listening',0.00,3,1),(656,212,2,'primaria','Listening',0.00,3,1),(657,243,2,'primaria','Listening',0.00,3,1),(658,337,1,'primaria','Listening',0.00,3,1),(659,338,1,'primaria','Listening',0.00,3,1),(660,339,1,'primaria','Listening',0.00,3,1),(661,340,1,'primaria','Listening',0.00,3,1),(662,108,1,'primaria','Listening',0.00,3,1),(663,131,1,'primaria','Listening',0.00,3,1),(664,185,2,'primaria','Listening',0.00,3,1),(665,196,2,'primaria','Listening',0.00,3,1),(666,213,2,'primaria','Listening',0.00,3,1),(667,244,2,'primaria','Listening',0.00,3,1),(668,321,1,'primaria','Listening',0.00,3,1),(669,322,1,'primaria','Listening',0.00,3,1),(670,323,1,'primaria','Listening',0.00,3,1),(671,324,1,'primaria','Listening',0.00,3,1),(672,109,1,'primaria','Listening',0.00,3,1),(673,132,1,'primaria','Listening',0.00,3,1),(674,183,2,'primaria','Listening',0.00,3,1),(675,194,2,'primaria','Listening',0.00,3,1),(676,214,2,'primaria','Listening',0.00,3,1),(677,245,2,'primaria','Listening',0.00,3,1),(678,333,1,'primaria','Listening',0.00,3,1),(679,334,1,'primaria','Listening',0.00,3,1),(680,335,1,'primaria','Listening',0.00,3,1),(681,336,1,'primaria','Listening',0.00,3,1),(682,110,1,'primaria','Listening',0.00,3,1),(683,133,1,'primaria','Listening',0.00,3,1),(684,182,2,'primaria','Listening',0.00,3,1),(685,193,2,'primaria','Listening',0.00,3,1),(686,215,2,'primaria','Listening',0.00,3,1),(687,246,2,'primaria','Listening',0.00,3,1),(688,317,1,'primaria','Listening',0.00,3,1),(689,318,1,'primaria','Listening',0.00,3,1),(690,319,1,'primaria','Listening',0.00,3,1),(691,320,1,'primaria','Listening',0.00,3,1),(692,111,1,'primaria','Listening',0.00,3,1),(693,134,1,'primaria','Listening',0.00,3,1),(694,184,2,'primaria','Listening',0.00,3,1),(695,195,2,'primaria','Listening',0.00,3,1),(696,216,2,'primaria','Listening',0.00,3,1),(697,247,2,'primaria','Listening',0.00,3,1),(698,329,1,'primaria','Listening',0.00,3,1),(699,330,1,'primaria','Listening',0.00,3,1),(700,331,1,'primaria','Listening',0.00,3,1),(701,332,1,'primaria','Listening',0.00,3,1),(702,112,1,'primaria','Listening',0.00,3,1),(703,135,1,'primaria','Listening',0.00,3,1),(704,187,2,'primaria','Listening',0.00,3,1),(705,198,2,'primaria','Listening',0.00,3,1),(706,217,2,'primaria','Listening',0.00,3,1),(707,248,2,'primaria','Listening',0.00,3,1),(708,325,1,'primaria','Listening',0.00,3,1),(709,326,1,'primaria','Listening',0.00,3,1),(710,327,1,'primaria','Listening',0.00,3,1),(711,328,1,'primaria','Listening',0.00,3,1),(712,63,1,'primaria','Listening',0.00,3,1),(713,68,1,'primaria','Listening',0.00,3,1),(714,180,2,'primaria','Listening',0.00,3,1),(715,191,2,'primaria','Listening',0.00,3,1),(716,220,2,'primaria','Listening',0.00,3,1),(717,251,2,'primaria','Listening',0.00,3,1),(718,291,1,'primaria','Listening',0.00,3,1),(719,292,1,'primaria','Listening',0.00,3,1),(720,60,1,'primaria','Listening',0.00,3,1),(721,67,1,'primaria','Listening',0.00,3,1),(722,179,2,'primaria','Listening',0.00,3,1),(723,190,2,'primaria','Listening',0.00,3,1),(724,221,2,'primaria','Listening',0.00,3,1),(725,252,2,'primaria','Listening',0.00,3,1),(726,285,1,'primaria','Listening',0.00,3,1),(727,286,1,'primaria','Listening',0.00,3,1),(728,348,1,'primaria','Listening',0.00,3,1),(729,349,1,'primaria','Listening',0.00,3,1),(730,350,1,'primaria','Listening',0.00,3,1),(731,351,1,'primaria','Listening',0.00,3,1),(732,352,1,'primaria','Listening',0.00,3,1),(733,353,1,'primaria','Listening',0.00,3,1),(734,354,1,'primaria','Listening',0.00,3,1),(735,355,1,'primaria','Listening',0.00,3,1),(736,356,1,'primaria','Listening',0.00,3,1),(737,357,1,'primaria','Listening',0.00,3,1),(738,358,1,'primaria','Listening',0.00,3,1),(739,359,1,'primaria','Listening',0.00,3,1),(740,360,1,'primaria','Listening',0.00,3,1),(741,361,1,'primaria','Listening',0.00,3,1),(742,362,1,'primaria','Listening',0.00,3,1),(743,363,1,'primaria','Listening',0.00,3,1),(744,364,1,'primaria','Listening',0.00,3,1),(745,365,1,'primaria','Listening',0.00,3,1),(746,366,1,'primaria','Listening',0.00,3,1),(747,367,1,'primaria','Listening',0.00,3,1),(748,186,2,'primaria','Listening',0.00,3,1),(749,197,2,'primaria','Listening',0.00,3,1),(750,222,2,'primaria','Listening',0.00,3,1),(751,253,2,'primaria','Listening',0.00,3,1),(752,368,1,'primaria','Listening',0.00,3,1),(753,369,1,'primaria','Listening',0.00,3,1),(754,370,1,'primaria','Listening',0.00,3,1),(755,371,1,'primaria','Listening',0.00,3,1),(756,372,1,'primaria','Listening',0.00,3,1),(757,373,1,'primaria','Listening',0.00,3,1),(758,374,1,'primaria','Listening',0.00,3,1),(759,375,1,'primaria','Listening',0.00,3,1),(760,188,2,'primaria','Listening',0.00,3,1),(761,199,2,'primaria','Listening',0.00,3,1),(762,223,2,'primaria','Listening',0.00,3,1),(763,254,2,'primaria','Listening',0.00,3,1),(764,376,1,'primaria','Listening',0.00,3,1),(765,377,1,'primaria','Listening',0.00,3,1),(766,378,1,'primaria','Listening',0.00,3,1),(767,379,1,'primaria','Listening',0.00,3,1),(768,178,2,'primaria','Listening',0.00,3,1),(769,189,2,'primaria','Listening',0.00,3,1),(770,224,2,'primaria','Listening',0.00,3,1),(771,255,2,'primaria','Listening',0.00,3,1),(772,380,1,'primaria','Listening',0.00,3,1),(773,381,1,'primaria','Listening',0.00,3,1),(774,382,1,'primaria','Listening',0.00,3,1),(775,383,1,'primaria','Listening',0.00,3,1),(776,107,1,'primaria','Reading',0.00,4,1),(777,130,1,'primaria','Reading',0.00,4,1),(778,181,2,'primaria','Reading',0.00,4,1),(779,192,2,'primaria','Reading',0.00,4,1),(780,212,2,'primaria','Reading',0.00,4,1),(781,243,2,'primaria','Reading',0.00,4,1),(782,337,1,'primaria','Reading',0.00,4,1),(783,338,1,'primaria','Reading',0.00,4,1),(784,339,1,'primaria','Reading',0.00,4,1),(785,340,1,'primaria','Reading',0.00,4,1),(786,108,1,'primaria','Reading',0.00,4,1),(787,131,1,'primaria','Reading',0.00,4,1),(788,185,2,'primaria','Reading',0.00,4,1),(789,196,2,'primaria','Reading',0.00,4,1),(790,213,2,'primaria','Reading',0.00,4,1),(791,244,2,'primaria','Reading',0.00,4,1),(792,321,1,'primaria','Reading',0.00,4,1),(793,322,1,'primaria','Reading',0.00,4,1),(794,323,1,'primaria','Reading',0.00,4,1),(795,324,1,'primaria','Reading',0.00,4,1),(796,109,1,'primaria','Reading',0.00,4,1),(797,132,1,'primaria','Reading',0.00,4,1),(798,183,2,'primaria','Reading',0.00,4,1),(799,194,2,'primaria','Reading',0.00,4,1),(800,214,2,'primaria','Reading',0.00,4,1),(801,245,2,'primaria','Reading',0.00,4,1),(802,333,1,'primaria','Reading',0.00,4,1),(803,334,1,'primaria','Reading',0.00,4,1),(804,335,1,'primaria','Reading',0.00,4,1),(805,336,1,'primaria','Reading',0.00,4,1),(806,110,1,'primaria','Reading',0.00,4,1),(807,133,1,'primaria','Reading',0.00,4,1),(808,182,2,'primaria','Reading',0.00,4,1),(809,193,2,'primaria','Reading',0.00,4,1),(810,215,2,'primaria','Reading',0.00,4,1),(811,246,2,'primaria','Reading',0.00,4,1),(812,317,1,'primaria','Reading',0.00,4,1),(813,318,1,'primaria','Reading',0.00,4,1),(814,319,1,'primaria','Reading',0.00,4,1),(815,320,1,'primaria','Reading',0.00,4,1),(816,111,1,'primaria','Reading',0.00,4,1),(817,134,1,'primaria','Reading',0.00,4,1),(818,184,2,'primaria','Reading',0.00,4,1),(819,195,2,'primaria','Reading',0.00,4,1),(820,216,2,'primaria','Reading',0.00,4,1),(821,247,2,'primaria','Reading',0.00,4,1),(822,329,1,'primaria','Reading',0.00,4,1),(823,330,1,'primaria','Reading',0.00,4,1),(824,331,1,'primaria','Reading',0.00,4,1),(825,332,1,'primaria','Reading',0.00,4,1),(826,112,1,'primaria','Reading',0.00,4,1),(827,135,1,'primaria','Reading',0.00,4,1),(828,187,2,'primaria','Reading',0.00,4,1),(829,198,2,'primaria','Reading',0.00,4,1),(830,217,2,'primaria','Reading',0.00,4,1),(831,248,2,'primaria','Reading',0.00,4,1),(832,325,1,'primaria','Reading',0.00,4,1),(833,326,1,'primaria','Reading',0.00,4,1),(834,327,1,'primaria','Reading',0.00,4,1),(835,328,1,'primaria','Reading',0.00,4,1),(836,63,1,'primaria','Reading',0.00,4,1),(837,68,1,'primaria','Reading',0.00,4,1),(838,180,2,'primaria','Reading',0.00,4,1),(839,191,2,'primaria','Reading',0.00,4,1),(840,220,2,'primaria','Reading',0.00,4,1),(841,251,2,'primaria','Reading',0.00,4,1),(842,291,1,'primaria','Reading',0.00,4,1),(843,292,1,'primaria','Reading',0.00,4,1),(844,60,1,'primaria','Reading',0.00,4,1),(845,67,1,'primaria','Reading',0.00,4,1),(846,179,2,'primaria','Reading',0.00,4,1),(847,190,2,'primaria','Reading',0.00,4,1),(848,221,2,'primaria','Reading',0.00,4,1),(849,252,2,'primaria','Reading',0.00,4,1),(850,285,1,'primaria','Reading',0.00,4,1),(851,286,1,'primaria','Reading',0.00,4,1),(852,348,1,'primaria','Reading',0.00,4,1),(853,349,1,'primaria','Reading',0.00,4,1),(854,350,1,'primaria','Reading',0.00,4,1),(855,351,1,'primaria','Reading',0.00,4,1),(856,352,1,'primaria','Reading',0.00,4,1),(857,353,1,'primaria','Reading',0.00,4,1),(858,354,1,'primaria','Reading',0.00,4,1),(859,355,1,'primaria','Reading',0.00,4,1),(860,356,1,'primaria','Reading',0.00,4,1),(861,357,1,'primaria','Reading',0.00,4,1),(862,358,1,'primaria','Reading',0.00,4,1),(863,359,1,'primaria','Reading',0.00,4,1),(864,360,1,'primaria','Reading',0.00,4,1),(865,361,1,'primaria','Reading',0.00,4,1),(866,362,1,'primaria','Reading',0.00,4,1),(867,363,1,'primaria','Reading',0.00,4,1),(868,364,1,'primaria','Reading',0.00,4,1),(869,365,1,'primaria','Reading',0.00,4,1),(870,366,1,'primaria','Reading',0.00,4,1),(871,367,1,'primaria','Reading',0.00,4,1),(872,186,2,'primaria','Reading',0.00,4,1),(873,197,2,'primaria','Reading',0.00,4,1),(874,222,2,'primaria','Reading',0.00,4,1),(875,253,2,'primaria','Reading',0.00,4,1),(876,368,1,'primaria','Reading',0.00,4,1),(877,369,1,'primaria','Reading',0.00,4,1),(878,370,1,'primaria','Reading',0.00,4,1),(879,371,1,'primaria','Reading',0.00,4,1),(880,372,1,'primaria','Reading',0.00,4,1),(881,373,1,'primaria','Reading',0.00,4,1),(882,374,1,'primaria','Reading',0.00,4,1),(883,375,1,'primaria','Reading',0.00,4,1),(884,188,2,'primaria','Reading',0.00,4,1),(885,199,2,'primaria','Reading',0.00,4,1),(886,223,2,'primaria','Reading',0.00,4,1),(887,254,2,'primaria','Reading',0.00,4,1),(888,376,1,'primaria','Reading',0.00,4,1),(889,377,1,'primaria','Reading',0.00,4,1),(890,378,1,'primaria','Reading',0.00,4,1),(891,379,1,'primaria','Reading',0.00,4,1),(892,178,2,'primaria','Reading',0.00,4,1),(893,189,2,'primaria','Reading',0.00,4,1),(894,224,2,'primaria','Reading',0.00,4,1),(895,255,2,'primaria','Reading',0.00,4,1),(896,380,1,'primaria','Reading',0.00,4,1),(897,381,1,'primaria','Reading',0.00,4,1),(898,382,1,'primaria','Reading',0.00,4,1),(899,383,1,'primaria','Reading',0.00,4,1),(900,107,1,'primaria','Writing',0.00,5,1),(901,130,1,'primaria','Writing',0.00,5,1),(902,181,2,'primaria','Writing',0.00,5,1),(903,192,2,'primaria','Writing',0.00,5,1),(904,212,2,'primaria','Writing',0.00,5,1),(905,243,2,'primaria','Writing',0.00,5,1),(906,337,1,'primaria','Writing',0.00,5,1),(907,338,1,'primaria','Writing',0.00,5,1),(908,339,1,'primaria','Writing',0.00,5,1),(909,340,1,'primaria','Writing',0.00,5,1),(910,108,1,'primaria','Writing',0.00,5,1),(911,131,1,'primaria','Writing',0.00,5,1),(912,185,2,'primaria','Writing',0.00,5,1),(913,196,2,'primaria','Writing',0.00,5,1),(914,213,2,'primaria','Writing',0.00,5,1),(915,244,2,'primaria','Writing',0.00,5,1),(916,321,1,'primaria','Writing',0.00,5,1),(917,322,1,'primaria','Writing',0.00,5,1),(918,323,1,'primaria','Writing',0.00,5,1),(919,324,1,'primaria','Writing',0.00,5,1),(920,109,1,'primaria','Writing',0.00,5,1),(921,132,1,'primaria','Writing',0.00,5,1),(922,183,2,'primaria','Writing',0.00,5,1),(923,194,2,'primaria','Writing',0.00,5,1),(924,214,2,'primaria','Writing',0.00,5,1),(925,245,2,'primaria','Writing',0.00,5,1),(926,333,1,'primaria','Writing',0.00,5,1),(927,334,1,'primaria','Writing',0.00,5,1),(928,335,1,'primaria','Writing',0.00,5,1),(929,336,1,'primaria','Writing',0.00,5,1),(930,110,1,'primaria','Writing',0.00,5,1),(931,133,1,'primaria','Writing',0.00,5,1),(932,182,2,'primaria','Writing',0.00,5,1),(933,193,2,'primaria','Writing',0.00,5,1),(934,215,2,'primaria','Writing',0.00,5,1),(935,246,2,'primaria','Writing',0.00,5,1),(936,317,1,'primaria','Writing',0.00,5,1),(937,318,1,'primaria','Writing',0.00,5,1),(938,319,1,'primaria','Writing',0.00,5,1),(939,320,1,'primaria','Writing',0.00,5,1),(940,111,1,'primaria','Writing',0.00,5,1),(941,134,1,'primaria','Writing',0.00,5,1),(942,184,2,'primaria','Writing',0.00,5,1),(943,195,2,'primaria','Writing',0.00,5,1),(944,216,2,'primaria','Writing',0.00,5,1),(945,247,2,'primaria','Writing',0.00,5,1),(946,329,1,'primaria','Writing',0.00,5,1),(947,330,1,'primaria','Writing',0.00,5,1),(948,331,1,'primaria','Writing',0.00,5,1),(949,332,1,'primaria','Writing',0.00,5,1),(950,112,1,'primaria','Writing',0.00,5,1),(951,135,1,'primaria','Writing',0.00,5,1),(952,187,2,'primaria','Writing',0.00,5,1),(953,198,2,'primaria','Writing',0.00,5,1),(954,217,2,'primaria','Writing',0.00,5,1),(955,248,2,'primaria','Writing',0.00,5,1),(956,325,1,'primaria','Writing',0.00,5,1),(957,326,1,'primaria','Writing',0.00,5,1),(958,327,1,'primaria','Writing',0.00,5,1),(959,328,1,'primaria','Writing',0.00,5,1),(960,63,1,'primaria','Writing',0.00,5,1),(961,68,1,'primaria','Writing',0.00,5,1),(962,180,2,'primaria','Writing',0.00,5,1),(963,191,2,'primaria','Writing',0.00,5,1),(964,220,2,'primaria','Writing',0.00,5,1),(965,251,2,'primaria','Writing',0.00,5,1),(966,291,1,'primaria','Writing',0.00,5,1),(967,292,1,'primaria','Writing',0.00,5,1),(968,60,1,'primaria','Writing',0.00,5,1),(969,67,1,'primaria','Writing',0.00,5,1),(970,179,2,'primaria','Writing',0.00,5,1),(971,190,2,'primaria','Writing',0.00,5,1),(972,221,2,'primaria','Writing',0.00,5,1),(973,252,2,'primaria','Writing',0.00,5,1),(974,285,1,'primaria','Writing',0.00,5,1),(975,286,1,'primaria','Writing',0.00,5,1),(976,348,1,'primaria','Writing',0.00,5,1),(977,349,1,'primaria','Writing',0.00,5,1),(978,350,1,'primaria','Writing',0.00,5,1),(979,351,1,'primaria','Writing',0.00,5,1),(980,352,1,'primaria','Writing',0.00,5,1),(981,353,1,'primaria','Writing',0.00,5,1),(982,354,1,'primaria','Writing',0.00,5,1),(983,355,1,'primaria','Writing',0.00,5,1),(984,356,1,'primaria','Writing',0.00,5,1),(985,357,1,'primaria','Writing',0.00,5,1),(986,358,1,'primaria','Writing',0.00,5,1),(987,359,1,'primaria','Writing',0.00,5,1),(988,360,1,'primaria','Writing',0.00,5,1),(989,361,1,'primaria','Writing',0.00,5,1),(990,362,1,'primaria','Writing',0.00,5,1),(991,363,1,'primaria','Writing',0.00,5,1),(992,364,1,'primaria','Writing',0.00,5,1),(993,365,1,'primaria','Writing',0.00,5,1),(994,366,1,'primaria','Writing',0.00,5,1),(995,367,1,'primaria','Writing',0.00,5,1),(996,186,2,'primaria','Writing',0.00,5,1),(997,197,2,'primaria','Writing',0.00,5,1),(998,222,2,'primaria','Writing',0.00,5,1),(999,253,2,'primaria','Writing',0.00,5,1),(1000,368,1,'primaria','Writing',0.00,5,1),(1001,369,1,'primaria','Writing',0.00,5,1),(1002,370,1,'primaria','Writing',0.00,5,1),(1003,371,1,'primaria','Writing',0.00,5,1),(1004,372,1,'primaria','Writing',0.00,5,1),(1005,373,1,'primaria','Writing',0.00,5,1),(1006,374,1,'primaria','Writing',0.00,5,1),(1007,375,1,'primaria','Writing',0.00,5,1),(1008,188,2,'primaria','Writing',0.00,5,1),(1009,199,2,'primaria','Writing',0.00,5,1),(1010,223,2,'primaria','Writing',0.00,5,1),(1011,254,2,'primaria','Writing',0.00,5,1),(1012,376,1,'primaria','Writing',0.00,5,1),(1013,377,1,'primaria','Writing',0.00,5,1),(1014,378,1,'primaria','Writing',0.00,5,1),(1015,379,1,'primaria','Writing',0.00,5,1),(1016,178,2,'primaria','Writing',0.00,5,1),(1017,189,2,'primaria','Writing',0.00,5,1),(1018,224,2,'primaria','Writing',0.00,5,1),(1019,255,2,'primaria','Writing',0.00,5,1),(1020,380,1,'primaria','Writing',0.00,5,1),(1021,381,1,'primaria','Writing',0.00,5,1),(1022,382,1,'primaria','Writing',0.00,5,1),(1023,383,1,'primaria','Writing',0.00,5,1);
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
  `orden` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'Orden en que aparecen los maestros',
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  `activo` tinyint(1) NOT NULL DEFAULT 1 COMMENT '1=activo, 0=inactivo',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_asig_prof` (`asignacion_id`,`profesor_id`),
  KEY `fk_asigmaestro_prof` (`profesor_id`),
  KEY `idx_profesor_activo` (`profesor_id`,`activo`),
  CONSTRAINT `fk_asigmaestro_asig` FOREIGN KEY (`asignacion_id`) REFERENCES `asignaciones` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_asigmaestro_prof` FOREIGN KEY (`profesor_id`) REFERENCES `profesores` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=93 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignacion_maestros`
--

LOCK TABLES `asignacion_maestros` WRITE;
/*!40000 ALTER TABLE `asignacion_maestros` DISABLE KEYS */;
INSERT INTO `asignacion_maestros` VALUES (29,36,1,1,0,'2026-05-30 19:43:36',1),(30,38,1,1,0,'2026-05-30 19:43:36',1),(33,41,1,1,0,'2026-05-30 19:43:36',1),(34,43,1,1,0,'2026-05-30 19:43:36',1),(35,44,4,0,0,'2026-05-30 20:24:31',1),(44,60,4,0,0,'2026-06-04 20:11:05',1),(47,63,4,0,0,'2026-06-04 20:11:05',1),(51,67,4,0,0,'2026-06-05 18:39:22',1),(52,68,4,1,0,'2026-06-05 18:39:22',1),(61,77,1,0,0,'2026-06-05 18:40:26',1),(62,78,1,0,0,'2026-06-05 18:40:26',1),(63,79,1,0,0,'2026-06-05 18:40:26',1),(64,80,1,0,0,'2026-06-05 18:40:26',1),(65,86,1,1,0,'2026-06-06 15:43:05',1),(66,87,1,1,0,'2026-06-06 15:43:05',1),(67,88,4,1,0,'2026-06-06 15:43:57',1),(68,89,4,1,0,'2026-06-06 15:43:57',1),(87,346,1,1,0,'2026-06-09 20:39:27',1),(88,337,4,0,0,'2026-06-09 21:15:53',1),(89,321,4,0,0,'2026-06-09 21:15:54',1),(90,317,4,0,0,'2026-06-09 21:15:54',1),(91,329,4,0,0,'2026-06-09 21:15:54',1),(92,325,4,0,0,'2026-06-09 21:15:54',1);
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
) ENGINE=InnoDB AUTO_INCREMENT=416 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignaciones`
--

LOCK TABLES `asignaciones` WRITE;
/*!40000 ALTER TABLE `asignaciones` DISABLE KEYS */;
INSERT INTO `asignaciones` VALUES (36,1,9,2,'primaria',1,'A',5,1,'2026-05-30 19:43:36'),(38,1,13,NULL,'primaria',1,'A',7,1,'2026-05-30 19:43:36'),(41,1,16,4,'primaria',1,'A',10,1,'2026-05-30 19:43:36'),(43,1,15,4,'primaria',1,'A',9,1,'2026-05-30 19:43:36'),(44,1,5,2,'primaria',1,'A',4,1,'2026-05-30 20:24:31'),(47,1,27,4,'primaria',1,'A',3,1,'2026-06-02 16:00:31'),(48,1,28,1,'primaria',1,'A',3,1,'2026-06-02 16:00:31'),(55,1,27,1,'primaria',1,'B',3,1,'2026-06-04 08:17:45'),(56,1,28,1,'primaria',1,'B',3,1,'2026-06-04 08:17:45'),(60,1,279,1,'primaria',1,'A',11,1,'2026-06-04 20:11:05'),(63,1,278,1,'primaria',1,'A',12,1,'2026-06-04 20:11:05'),(67,1,279,1,'primaria',1,'B',11,1,'2026-06-05 18:39:22'),(68,1,278,1,'primaria',1,'B',12,1,'2026-06-05 18:39:22'),(77,1,9,2,'primaria',1,'B',5,1,'2026-06-05 18:40:26'),(78,1,13,3,'primaria',1,'B',7,1,'2026-06-05 18:40:26'),(79,1,15,4,'primaria',1,'B',9,1,'2026-06-05 18:40:26'),(80,1,16,4,'primaria',1,'B',10,1,'2026-06-05 18:40:26'),(81,1,14,4,'primaria',1,'A',8,1,'2026-06-05 18:41:18'),(82,1,10,2,'primaria',1,'A',6,1,'2026-06-05 18:41:18'),(83,1,14,4,'primaria',1,'B',8,1,'2026-06-05 18:41:30'),(84,1,10,2,'primaria',1,'B',6,1,'2026-06-05 18:41:30'),(86,1,297,NULL,'primaria',1,'A',19,1,'2026-06-06 15:43:05'),(87,1,298,NULL,'primaria',1,'A',20,1,'2026-06-06 15:43:05'),(88,1,297,NULL,'primaria',1,'B',19,1,'2026-06-06 15:43:57'),(89,1,298,NULL,'primaria',1,'B',20,1,'2026-06-06 15:43:57'),(93,4,4,1,'primaria',1,'A',4,1,'2026-06-09 12:20:56'),(94,4,5,2,'primaria',1,'A',5,1,'2026-06-09 12:20:56'),(95,4,6,2,'primaria',1,'A',6,1,'2026-06-09 12:20:56'),(98,4,9,3,'primaria',1,'A',9,1,'2026-06-09 12:20:56'),(99,4,10,3,'primaria',1,'A',10,1,'2026-06-09 12:20:56'),(100,4,11,4,'primaria',1,'A',11,1,'2026-06-09 12:20:56'),(101,4,12,4,'primaria',1,'A',12,1,'2026-06-09 12:20:56'),(102,4,13,4,'primaria',1,'A',13,1,'2026-06-09 12:20:56'),(103,4,14,NULL,'primaria',1,'A',14,1,'2026-06-09 12:20:56'),(104,4,15,NULL,'primaria',1,'A',15,1,'2026-06-09 12:20:56'),(105,4,16,1,'primaria',1,'A',16,1,'2026-06-09 12:20:56'),(106,4,17,1,'primaria',1,'A',17,1,'2026-06-09 12:20:56'),(107,4,18,1,'primaria',1,'A',18,1,'2026-06-09 12:20:56'),(108,4,19,1,'primaria',1,'A',19,1,'2026-06-09 12:20:56'),(109,4,20,1,'primaria',1,'A',20,1,'2026-06-09 12:20:56'),(110,4,21,1,'primaria',1,'A',21,1,'2026-06-09 12:20:56'),(111,4,22,1,'primaria',1,'A',22,1,'2026-06-09 12:20:56'),(112,4,23,1,'primaria',1,'A',23,1,'2026-06-09 12:20:56'),(113,4,1,1,'primaria',1,'B',1,1,'2026-06-09 12:20:56'),(116,4,4,1,'primaria',1,'B',4,1,'2026-06-09 12:20:56'),(117,4,5,2,'primaria',1,'B',5,1,'2026-06-09 12:20:56'),(118,4,6,2,'primaria',1,'B',6,1,'2026-06-09 12:20:56'),(121,4,9,3,'primaria',1,'B',9,1,'2026-06-09 12:20:56'),(122,4,10,3,'primaria',1,'B',10,1,'2026-06-09 12:20:56'),(123,4,11,4,'primaria',1,'B',11,1,'2026-06-09 12:20:56'),(124,4,12,4,'primaria',1,'B',12,1,'2026-06-09 12:20:56'),(125,4,13,4,'primaria',1,'B',13,1,'2026-06-09 12:20:56'),(126,4,14,NULL,'primaria',1,'B',14,1,'2026-06-09 12:20:56'),(127,4,15,NULL,'primaria',1,'B',15,1,'2026-06-09 12:20:56'),(128,4,16,1,'primaria',1,'B',16,1,'2026-06-09 12:20:56'),(129,4,17,1,'primaria',1,'B',17,1,'2026-06-09 12:20:56'),(130,4,18,1,'primaria',1,'B',18,1,'2026-06-09 12:20:56'),(131,4,19,1,'primaria',1,'B',19,1,'2026-06-09 12:20:56'),(132,4,20,1,'primaria',1,'B',20,1,'2026-06-09 12:20:56'),(133,4,21,1,'primaria',1,'B',21,1,'2026-06-09 12:20:56'),(134,4,22,1,'primaria',1,'B',22,1,'2026-06-09 12:20:56'),(135,4,23,1,'primaria',1,'B',23,1,'2026-06-09 12:20:56'),(142,4,4,1,'primaria',2,'A',4,1,'2026-06-09 12:30:30'),(145,4,4,1,'primaria',2,'B',4,1,'2026-06-09 12:30:30'),(148,4,1,1,'primaria',2,'A',1,1,'2026-06-09 12:34:08'),(149,4,2,1,'primaria',2,'A',2,1,'2026-06-09 12:34:08'),(150,4,3,1,'primaria',2,'A',3,1,'2026-06-09 12:34:08'),(151,4,5,2,'primaria',2,'A',5,1,'2026-06-09 12:34:08'),(152,4,6,2,'primaria',2,'A',6,1,'2026-06-09 12:34:08'),(154,4,10,3,'primaria',2,'A',8,1,'2026-06-09 12:34:08'),(155,4,11,4,'primaria',2,'A',9,1,'2026-06-09 12:34:08'),(156,4,12,4,'primaria',2,'A',10,1,'2026-06-09 12:34:08'),(157,4,13,4,'primaria',2,'A',11,1,'2026-06-09 12:34:08'),(158,4,14,NULL,'primaria',2,'A',12,1,'2026-06-09 12:34:08'),(159,4,15,NULL,'primaria',2,'A',13,1,'2026-06-09 12:34:08'),(163,4,1,1,'primaria',2,'B',1,1,'2026-06-09 12:34:08'),(164,4,2,1,'primaria',2,'B',2,1,'2026-06-09 12:34:08'),(165,4,3,1,'primaria',2,'B',3,1,'2026-06-09 12:34:08'),(166,4,5,2,'primaria',2,'B',5,1,'2026-06-09 12:34:08'),(167,4,6,2,'primaria',2,'B',6,1,'2026-06-09 12:34:08'),(169,4,10,3,'primaria',2,'B',8,1,'2026-06-09 12:34:08'),(170,4,11,4,'primaria',2,'B',9,1,'2026-06-09 12:34:08'),(171,4,12,4,'primaria',2,'B',10,1,'2026-06-09 12:34:08'),(172,4,13,4,'primaria',2,'B',11,1,'2026-06-09 12:34:08'),(173,4,14,NULL,'primaria',2,'B',12,1,'2026-06-09 12:34:08'),(174,4,15,NULL,'primaria',2,'B',13,1,'2026-06-09 12:34:08'),(178,4,290,1,'primaria',2,'A',1,1,'2026-06-09 12:36:31'),(179,4,279,1,'primaria',2,'A',2,1,'2026-06-09 12:36:31'),(180,4,278,1,'primaria',2,'A',3,1,'2026-06-09 12:36:31'),(181,4,18,1,'primaria',2,'A',4,1,'2026-06-09 12:36:31'),(182,4,21,1,'primaria',2,'A',5,1,'2026-06-09 12:36:31'),(183,4,20,1,'primaria',2,'A',6,1,'2026-06-09 12:36:31'),(184,4,22,1,'primaria',2,'A',7,1,'2026-06-09 12:36:31'),(185,4,19,1,'primaria',2,'A',8,1,'2026-06-09 12:36:31'),(186,4,287,1,'primaria',2,'A',9,1,'2026-06-09 12:36:31'),(187,4,23,1,'primaria',2,'A',10,1,'2026-06-09 12:36:31'),(188,4,289,1,'primaria',2,'A',11,1,'2026-06-09 12:36:31'),(189,4,290,1,'primaria',2,'B',1,1,'2026-06-09 12:36:31'),(190,4,279,1,'primaria',2,'B',2,1,'2026-06-09 12:36:31'),(191,4,278,1,'primaria',2,'B',3,1,'2026-06-09 12:36:31'),(192,4,18,1,'primaria',2,'B',4,1,'2026-06-09 12:36:31'),(193,4,21,1,'primaria',2,'B',5,1,'2026-06-09 12:36:31'),(194,4,20,1,'primaria',2,'B',6,1,'2026-06-09 12:36:31'),(195,4,22,1,'primaria',2,'B',7,1,'2026-06-09 12:36:31'),(196,4,19,1,'primaria',2,'B',8,1,'2026-06-09 12:36:31'),(197,4,287,1,'primaria',2,'B',9,1,'2026-06-09 12:36:31'),(198,4,23,1,'primaria',2,'B',10,1,'2026-06-09 12:36:31'),(199,4,289,1,'primaria',2,'B',11,1,'2026-06-09 12:36:31'),(200,1,1,1,'primaria',2,'A',7,1,'2026-06-09 12:47:42'),(201,1,3,NULL,'primaria',2,'A',4,1,'2026-06-09 12:47:42'),(202,1,4,1,'primaria',2,'A',20,1,'2026-06-09 12:47:42'),(203,1,5,2,'primaria',2,'A',8,1,'2026-06-09 12:47:42'),(204,1,9,2,'primaria',2,'A',1,1,'2026-06-09 12:47:42'),(205,1,10,2,'primaria',2,'A',10,1,'2026-06-09 12:47:42'),(206,1,11,3,'primaria',2,'A',5,1,'2026-06-09 12:47:42'),(207,1,12,3,'primaria',2,'A',6,1,'2026-06-09 12:47:42'),(208,1,13,3,'primaria',2,'A',3,1,'2026-06-09 12:47:42'),(209,1,14,4,'primaria',2,'A',2,1,'2026-06-09 12:47:42'),(210,1,15,4,'primaria',2,'A',11,1,'2026-06-09 12:47:42'),(211,1,16,4,'primaria',2,'A',9,1,'2026-06-09 12:47:42'),(212,1,18,1,'primaria',2,'A',0,1,'2026-06-09 12:47:42'),(213,1,19,1,'primaria',2,'A',0,1,'2026-06-09 12:47:42'),(214,1,20,1,'primaria',2,'A',0,1,'2026-06-09 12:47:42'),(215,1,21,1,'primaria',2,'A',0,1,'2026-06-09 12:47:42'),(216,1,22,1,'primaria',2,'A',0,1,'2026-06-09 12:47:42'),(217,1,23,1,'primaria',2,'A',0,1,'2026-06-09 12:47:42'),(218,1,27,4,'primaria',2,'A',21,1,'2026-06-09 12:47:42'),(219,1,28,1,'primaria',2,'A',22,1,'2026-06-09 12:47:42'),(220,1,278,1,'primaria',2,'A',0,1,'2026-06-09 12:47:42'),(221,1,279,1,'primaria',2,'A',0,1,'2026-06-09 12:47:42'),(222,1,287,1,'primaria',2,'A',0,1,'2026-06-09 12:47:42'),(223,1,289,1,'primaria',2,'A',0,1,'2026-06-09 12:47:42'),(224,1,290,1,'primaria',2,'A',0,1,'2026-06-09 12:47:42'),(231,1,1,1,'primaria',2,'B',7,1,'2026-06-09 12:47:42'),(232,1,3,NULL,'primaria',2,'B',4,1,'2026-06-09 12:47:42'),(233,1,4,1,'primaria',2,'B',20,1,'2026-06-09 12:47:42'),(234,1,5,2,'primaria',2,'B',8,1,'2026-06-09 12:47:42'),(235,1,9,2,'primaria',2,'B',1,1,'2026-06-09 12:47:42'),(236,1,10,2,'primaria',2,'B',10,1,'2026-06-09 12:47:42'),(237,1,11,3,'primaria',2,'B',5,1,'2026-06-09 12:47:42'),(238,1,12,3,'primaria',2,'B',6,1,'2026-06-09 12:47:42'),(239,1,13,3,'primaria',2,'B',3,1,'2026-06-09 12:47:42'),(240,1,14,4,'primaria',2,'B',2,1,'2026-06-09 12:47:42'),(241,1,15,4,'primaria',2,'B',11,1,'2026-06-09 12:47:42'),(242,1,16,4,'primaria',2,'B',9,1,'2026-06-09 12:47:42'),(243,1,18,1,'primaria',2,'B',0,1,'2026-06-09 12:47:42'),(244,1,19,1,'primaria',2,'B',0,1,'2026-06-09 12:47:42'),(245,1,20,1,'primaria',2,'B',0,1,'2026-06-09 12:47:42'),(246,1,21,1,'primaria',2,'B',0,1,'2026-06-09 12:47:42'),(247,1,22,1,'primaria',2,'B',0,1,'2026-06-09 12:47:42'),(248,1,23,1,'primaria',2,'B',0,1,'2026-06-09 12:47:42'),(249,1,27,4,'primaria',2,'B',21,1,'2026-06-09 12:47:42'),(250,1,28,1,'primaria',2,'B',22,1,'2026-06-09 12:47:42'),(251,1,278,1,'primaria',2,'B',0,1,'2026-06-09 12:47:42'),(252,1,279,1,'primaria',2,'B',0,1,'2026-06-09 12:47:42'),(253,1,287,1,'primaria',2,'B',0,1,'2026-06-09 12:47:42'),(254,1,289,1,'primaria',2,'B',0,1,'2026-06-09 12:47:42'),(255,1,290,1,'primaria',2,'B',0,1,'2026-06-09 12:47:42'),(262,1,298,NULL,'primaria',1,'C',20,1,'2026-06-09 19:04:03'),(263,1,298,NULL,'primaria',1,'D',20,1,'2026-06-09 19:04:03'),(264,1,9,2,'primaria',1,'C',5,1,'2026-06-09 19:04:03'),(265,1,9,2,'primaria',1,'D',5,1,'2026-06-09 19:04:03'),(266,1,297,NULL,'primaria',1,'C',19,1,'2026-06-09 19:04:03'),(267,1,297,NULL,'primaria',1,'D',19,1,'2026-06-09 19:04:03'),(268,1,13,3,'primaria',1,'C',7,1,'2026-06-09 19:04:03'),(269,1,13,3,'primaria',1,'D',7,1,'2026-06-09 19:04:03'),(272,1,5,2,'primaria',1,'B',4,1,'2026-06-09 19:04:03'),(273,1,5,2,'primaria',1,'C',4,1,'2026-06-09 19:04:03'),(274,1,5,2,'primaria',1,'D',4,1,'2026-06-09 19:04:03'),(279,1,16,4,'primaria',1,'C',10,1,'2026-06-09 19:04:04'),(280,1,16,4,'primaria',1,'D',10,1,'2026-06-09 19:04:04'),(281,1,15,4,'primaria',1,'C',9,1,'2026-06-09 19:04:04'),(282,1,15,4,'primaria',1,'D',9,1,'2026-06-09 19:04:04'),(285,1,279,1,'primaria',1,'C',11,1,'2026-06-09 19:04:04'),(286,1,279,1,'primaria',1,'D',11,1,'2026-06-09 19:04:04'),(291,1,278,1,'primaria',1,'C',12,1,'2026-06-09 19:04:04'),(292,1,278,1,'primaria',1,'D',12,1,'2026-06-09 19:04:04'),(301,1,28,1,'primaria',1,'C',3,1,'2026-06-09 19:04:04'),(302,1,28,1,'primaria',1,'D',3,1,'2026-06-09 19:04:04'),(303,1,27,1,'primaria',1,'C',3,1,'2026-06-09 19:04:04'),(304,1,27,1,'primaria',1,'D',3,1,'2026-06-09 19:04:04'),(305,1,14,4,'primaria',1,'C',8,1,'2026-06-09 19:04:04'),(306,1,14,4,'primaria',1,'D',8,1,'2026-06-09 19:04:04'),(307,1,10,2,'primaria',1,'C',6,1,'2026-06-09 19:04:04'),(308,1,10,2,'primaria',1,'D',6,1,'2026-06-09 19:04:04'),(310,1,4,1,'primaria',1,'B',2,1,'2026-06-09 19:35:09'),(311,1,4,1,'primaria',1,'C',2,1,'2026-06-09 19:35:09'),(312,1,4,1,'primaria',1,'D',2,1,'2026-06-09 19:35:09'),(314,1,1,1,'primaria',1,'B',1,1,'2026-06-09 19:35:29'),(315,1,1,1,'primaria',1,'C',1,1,'2026-06-09 19:35:29'),(316,1,1,1,'primaria',1,'D',1,1,'2026-06-09 19:35:29'),(317,1,21,1,'primaria',1,'A',16,1,'2026-06-09 19:37:34'),(318,1,21,1,'primaria',1,'B',16,1,'2026-06-09 19:37:34'),(319,1,21,1,'primaria',1,'C',16,1,'2026-06-09 19:37:35'),(320,1,21,1,'primaria',1,'D',16,1,'2026-06-09 19:37:35'),(321,1,19,1,'primaria',1,'A',14,1,'2026-06-09 19:37:35'),(322,1,19,1,'primaria',1,'B',14,1,'2026-06-09 19:37:35'),(323,1,19,1,'primaria',1,'C',14,1,'2026-06-09 19:37:35'),(324,1,19,1,'primaria',1,'D',14,1,'2026-06-09 19:37:35'),(325,1,23,1,'primaria',1,'A',18,1,'2026-06-09 19:37:35'),(326,1,23,1,'primaria',1,'B',18,1,'2026-06-09 19:37:35'),(327,1,23,1,'primaria',1,'C',18,1,'2026-06-09 19:37:35'),(328,1,23,1,'primaria',1,'D',18,1,'2026-06-09 19:37:35'),(329,1,22,1,'primaria',1,'A',17,1,'2026-06-09 19:37:35'),(330,1,22,1,'primaria',1,'B',17,1,'2026-06-09 19:37:35'),(331,1,22,1,'primaria',1,'C',17,1,'2026-06-09 19:37:35'),(332,1,22,1,'primaria',1,'D',17,1,'2026-06-09 19:37:35'),(333,1,20,1,'primaria',1,'A',15,1,'2026-06-09 19:37:35'),(334,1,20,1,'primaria',1,'B',15,1,'2026-06-09 19:37:35'),(335,1,20,1,'primaria',1,'C',15,1,'2026-06-09 19:37:35'),(336,1,20,1,'primaria',1,'D',15,1,'2026-06-09 19:37:35'),(337,1,18,1,'primaria',1,'A',13,1,'2026-06-09 19:37:35'),(338,1,18,1,'primaria',1,'B',13,1,'2026-06-09 19:37:35'),(339,1,18,1,'primaria',1,'C',13,1,'2026-06-09 19:37:35'),(340,1,18,1,'primaria',1,'D',13,1,'2026-06-09 19:37:35'),(346,1,1,1,'primaria',1,'A',1,1,'2026-06-09 20:39:27'),(348,1,280,1,'primaria',1,'A',1,1,'2026-06-09 21:13:23'),(349,1,280,1,'primaria',1,'B',1,1,'2026-06-09 21:13:23'),(350,1,280,1,'primaria',1,'C',1,1,'2026-06-09 21:13:23'),(351,1,280,1,'primaria',1,'D',1,1,'2026-06-09 21:13:23'),(352,1,281,1,'primaria',1,'A',1,1,'2026-06-09 21:13:23'),(353,1,281,1,'primaria',1,'B',1,1,'2026-06-09 21:13:23'),(354,1,281,1,'primaria',1,'C',1,1,'2026-06-09 21:13:23'),(355,1,281,1,'primaria',1,'D',1,1,'2026-06-09 21:13:23'),(356,1,282,1,'primaria',1,'A',1,1,'2026-06-09 21:13:23'),(357,1,282,1,'primaria',1,'B',1,1,'2026-06-09 21:13:23'),(358,1,282,1,'primaria',1,'C',1,1,'2026-06-09 21:13:23'),(359,1,282,1,'primaria',1,'D',1,1,'2026-06-09 21:13:23'),(360,1,285,1,'primaria',1,'A',1,1,'2026-06-09 21:13:23'),(361,1,285,1,'primaria',1,'B',1,1,'2026-06-09 21:13:23'),(362,1,285,1,'primaria',1,'C',1,1,'2026-06-09 21:13:23'),(363,1,285,1,'primaria',1,'D',1,1,'2026-06-09 21:13:23'),(364,1,286,1,'primaria',1,'A',1,1,'2026-06-09 21:13:23'),(365,1,286,1,'primaria',1,'B',1,1,'2026-06-09 21:13:23'),(366,1,286,1,'primaria',1,'C',1,1,'2026-06-09 21:13:23'),(367,1,286,1,'primaria',1,'D',1,1,'2026-06-09 21:13:23'),(368,1,287,1,'primaria',1,'A',1,1,'2026-06-09 21:13:23'),(369,1,287,1,'primaria',1,'B',1,1,'2026-06-09 21:13:23'),(370,1,287,1,'primaria',1,'C',1,1,'2026-06-09 21:13:23'),(371,1,287,1,'primaria',1,'D',1,1,'2026-06-09 21:13:23'),(372,1,288,1,'primaria',1,'A',1,1,'2026-06-09 21:13:23'),(373,1,288,1,'primaria',1,'B',1,1,'2026-06-09 21:13:23'),(374,1,288,1,'primaria',1,'C',1,1,'2026-06-09 21:13:23'),(375,1,288,1,'primaria',1,'D',1,1,'2026-06-09 21:13:23'),(376,1,289,1,'primaria',1,'A',1,1,'2026-06-09 21:13:23'),(377,1,289,1,'primaria',1,'B',1,1,'2026-06-09 21:13:23'),(378,1,289,1,'primaria',1,'C',1,1,'2026-06-09 21:13:23'),(379,1,289,1,'primaria',1,'D',1,1,'2026-06-09 21:13:23'),(380,1,290,1,'primaria',1,'A',1,1,'2026-06-09 21:13:23'),(381,1,290,1,'primaria',1,'B',1,1,'2026-06-09 21:13:23'),(382,1,290,1,'primaria',1,'C',1,1,'2026-06-09 21:13:23'),(383,1,290,1,'primaria',1,'D',1,1,'2026-06-09 21:13:23');
/*!40000 ALTER TABLE `asignaciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ausencias`
--

DROP TABLE IF EXISTS `ausencias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ausencias` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `alumno_id` int(10) unsigned NOT NULL,
  `ciclo_id` int(10) unsigned NOT NULL,
  `periodo` tinyint(3) unsigned NOT NULL COMMENT '1 al 6',
  `dias_ausencia` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `capturado_por` int(10) unsigned NOT NULL,
  `capturado_en` datetime NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_ausencia` (`alumno_id`,`ciclo_id`,`periodo`),
  KEY `fk_ausencias_ciclo` (`ciclo_id`),
  KEY `fk_ausencias_prof` (`capturado_por`),
  CONSTRAINT `fk_ausencias_alumno` FOREIGN KEY (`alumno_id`) REFERENCES `alumnos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ausencias_ciclo` FOREIGN KEY (`ciclo_id`) REFERENCES `ciclos_escolares` (`id`),
  CONSTRAINT `fk_ausencias_prof` FOREIGN KEY (`capturado_por`) REFERENCES `profesores` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ausencias`
--

LOCK TABLES `ausencias` WRITE;
/*!40000 ALTER TABLE `ausencias` DISABLE KEYS */;
/*!40000 ALTER TABLE `ausencias` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=125 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `banned_words`
--

LOCK TABLES `banned_words` WRITE;
/*!40000 ALTER TABLE `banned_words` DISABLE KEYS */;
INSERT INTO `banned_words` VALUES (121,'alv'),(117,'babos'),(104,'cabro'),(105,'cabron'),(100,'ching'),(109,'coño'),(124,'ctm'),(106,'culer'),(4,'culo'),(114,'estup'),(118,'guey'),(122,'hdp'),(113,'idiot'),(107,'joder'),(108,'jodid'),(112,'maric'),(3,'mier'),(120,'nmms'),(103,'pende'),(5,'pene'),(110,'perra'),(123,'ptm'),(1,'puta'),(2,'puto'),(116,'tarad'),(115,'tonto'),(6,'vagi'),(102,'verg'),(101,'verga'),(119,'wey'),(111,'zorra');
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
  `aspecto_id` int(10) unsigned NOT NULL,
  `periodo` tinyint(3) unsigned NOT NULL,
  `calificacion` decimal(5,2) DEFAULT NULL,
  `capturado_por` int(10) unsigned NOT NULL,
  `capturado_en` datetime NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_calificacion` (`alumno_id`,`asignacion_id`,`aspecto_id`,`periodo`),
  KEY `asignacion_id` (`asignacion_id`),
  KEY `aspecto_id` (`aspecto_id`),
  KEY `capturado_por` (`capturado_por`),
  CONSTRAINT `calificaciones_ibfk_1` FOREIGN KEY (`alumno_id`) REFERENCES `alumnos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `calificaciones_ibfk_2` FOREIGN KEY (`asignacion_id`) REFERENCES `asignaciones` (`id`) ON DELETE CASCADE,
  CONSTRAINT `calificaciones_ibfk_3` FOREIGN KEY (`aspecto_id`) REFERENCES `asignacion_aspectos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `calificaciones_ibfk_4` FOREIGN KEY (`capturado_por`) REFERENCES `profesores` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=777 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `calificaciones`
--

LOCK TABLES `calificaciones` WRITE;
/*!40000 ALTER TABLE `calificaciones` DISABLE KEYS */;
INSERT INTO `calificaciones` VALUES (61,1,43,49,1,9.00,1,'2026-06-03 21:48:46','2026-06-03 21:48:46'),(62,1,43,50,1,8.00,1,'2026-06-03 21:48:46','2026-06-03 21:48:46'),(63,1,43,51,1,9.00,1,'2026-06-03 21:48:46','2026-06-03 21:48:46'),(64,1,43,52,1,8.00,1,'2026-06-03 21:48:47','2026-06-03 21:48:47'),(65,1,43,53,1,9.00,1,'2026-06-03 21:48:47','2026-06-03 21:48:47'),(66,1,43,54,1,8.00,1,'2026-06-03 21:48:47','2026-06-03 21:48:47'),(67,3,43,49,1,NULL,1,'2026-06-03 21:48:47','2026-06-03 21:48:47'),(68,3,43,50,1,NULL,1,'2026-06-03 21:48:48','2026-06-03 21:48:48'),(69,3,43,51,1,NULL,1,'2026-06-03 21:48:48','2026-06-03 21:48:48'),(70,3,43,52,1,NULL,1,'2026-06-03 21:48:48','2026-06-03 21:48:48'),(71,3,43,53,1,NULL,1,'2026-06-03 21:48:48','2026-06-03 21:48:48'),(72,3,43,54,1,NULL,1,'2026-06-03 21:48:48','2026-06-03 21:48:48'),(85,1,36,25,1,9.00,1,'2026-06-03 21:49:12','2026-06-03 21:49:12'),(86,1,36,26,1,9.00,1,'2026-06-03 21:49:12','2026-06-03 21:49:12'),(87,1,36,27,1,9.00,1,'2026-06-03 21:49:12','2026-06-03 21:49:12'),(88,1,36,28,1,9.00,1,'2026-06-03 21:49:12','2026-06-03 21:49:12'),(89,1,36,29,1,9.00,1,'2026-06-03 21:49:12','2026-06-03 21:49:12'),(90,1,36,30,1,9.00,1,'2026-06-03 21:49:12','2026-06-03 21:49:12'),(91,3,36,25,1,NULL,1,'2026-06-03 21:49:12','2026-06-03 21:49:12'),(92,3,36,26,1,NULL,1,'2026-06-03 21:49:12','2026-06-03 21:49:12'),(93,3,36,27,1,NULL,1,'2026-06-03 21:49:12','2026-06-03 21:49:12'),(94,3,36,28,1,NULL,1,'2026-06-03 21:49:12','2026-06-03 21:49:12'),(95,3,36,29,1,NULL,1,'2026-06-03 21:49:12','2026-06-03 21:49:12'),(96,3,36,30,1,NULL,1,'2026-06-03 21:49:12','2026-06-03 21:49:12'),(97,1,41,55,1,9.00,1,'2026-06-03 21:49:18','2026-06-03 21:49:18'),(98,1,41,56,1,9.00,1,'2026-06-03 21:49:18','2026-06-03 21:49:18'),(99,1,41,57,1,9.00,1,'2026-06-03 21:49:18','2026-06-03 21:49:18'),(100,1,41,58,1,9.00,1,'2026-06-03 21:49:18','2026-06-03 21:49:18'),(101,1,41,59,1,9.00,1,'2026-06-03 21:49:18','2026-06-03 21:49:18'),(102,1,41,60,1,9.00,1,'2026-06-03 21:49:18','2026-06-03 21:49:18'),(103,3,41,55,1,NULL,1,'2026-06-03 21:49:18','2026-06-03 21:49:18'),(104,3,41,56,1,NULL,1,'2026-06-03 21:49:18','2026-06-03 21:49:18'),(105,3,41,57,1,NULL,1,'2026-06-03 21:49:18','2026-06-03 21:49:18'),(106,3,41,58,1,NULL,1,'2026-06-03 21:49:18','2026-06-03 21:49:18'),(107,3,41,59,1,NULL,1,'2026-06-03 21:49:18','2026-06-03 21:49:18'),(108,3,41,60,1,NULL,1,'2026-06-03 21:49:18','2026-06-03 21:49:18'),(109,1,38,37,1,10.00,1,'2026-06-03 21:49:28','2026-06-03 21:49:28'),(110,1,38,38,1,10.00,1,'2026-06-03 21:49:28','2026-06-03 21:49:28'),(111,1,38,39,1,10.00,1,'2026-06-03 21:49:28','2026-06-03 21:49:28'),(112,1,38,40,1,10.00,1,'2026-06-03 21:49:28','2026-06-03 21:49:28'),(113,1,38,41,1,10.00,1,'2026-06-03 21:49:28','2026-06-03 21:49:28'),(114,1,38,42,1,10.00,1,'2026-06-03 21:49:28','2026-06-03 21:49:28'),(115,3,38,37,1,NULL,1,'2026-06-03 21:49:28','2026-06-03 21:49:28'),(116,3,38,38,1,NULL,1,'2026-06-03 21:49:28','2026-06-03 21:49:28'),(117,3,38,39,1,NULL,1,'2026-06-03 21:49:28','2026-06-03 21:49:28'),(118,3,38,40,1,NULL,1,'2026-06-03 21:49:28','2026-06-03 21:49:28'),(119,3,38,41,1,NULL,1,'2026-06-03 21:49:28','2026-06-03 21:49:28'),(120,3,38,42,1,NULL,1,'2026-06-03 21:49:28','2026-06-03 21:49:28'),(193,1,48,67,1,9.00,1,'2026-06-04 09:38:47','2026-06-04 09:38:47'),(194,1,48,68,1,9.00,1,'2026-06-04 09:38:47','2026-06-04 09:38:47'),(195,1,48,69,1,9.00,1,'2026-06-04 09:38:48','2026-06-04 09:38:48'),(196,1,48,70,1,9.00,1,'2026-06-04 09:38:48','2026-06-04 09:38:48'),(197,1,48,71,1,9.00,1,'2026-06-04 09:38:48','2026-06-04 09:38:48'),(198,1,48,72,1,9.00,1,'2026-06-04 09:38:48','2026-06-04 09:38:48'),(199,3,48,67,1,NULL,1,'2026-06-04 09:38:48','2026-06-04 09:38:48'),(200,3,48,68,1,NULL,1,'2026-06-04 09:38:48','2026-06-04 09:38:48'),(201,3,48,69,1,NULL,1,'2026-06-04 09:38:49','2026-06-04 09:38:49'),(202,3,48,70,1,NULL,1,'2026-06-04 09:38:49','2026-06-04 09:38:49'),(203,3,48,71,1,NULL,1,'2026-06-04 09:38:49','2026-06-04 09:38:49'),(204,3,48,72,1,NULL,1,'2026-06-04 09:38:49','2026-06-04 09:38:49'),(421,1,47,61,1,9.00,1,'2026-06-05 18:33:28','2026-06-05 18:33:28'),(422,1,47,62,1,9.00,1,'2026-06-05 18:33:28','2026-06-05 18:33:28'),(423,1,47,63,1,9.00,1,'2026-06-05 18:33:28','2026-06-05 18:33:28'),(424,1,47,64,1,9.00,1,'2026-06-05 18:33:28','2026-06-05 18:33:28'),(425,1,47,65,1,9.00,1,'2026-06-05 18:33:28','2026-06-05 18:33:28'),(426,1,47,66,1,9.00,1,'2026-06-05 18:33:28','2026-06-05 18:33:28'),(427,3,47,61,1,NULL,1,'2026-06-05 18:33:28','2026-06-05 18:33:28'),(428,3,47,62,1,NULL,1,'2026-06-05 18:33:28','2026-06-05 18:33:28'),(429,3,47,63,1,NULL,1,'2026-06-05 18:33:28','2026-06-05 18:33:28'),(430,3,47,64,1,NULL,1,'2026-06-05 18:33:28','2026-06-05 18:33:28'),(431,3,47,65,1,NULL,1,'2026-06-05 18:33:28','2026-06-05 18:33:28'),(432,3,47,66,1,NULL,1,'2026-06-05 18:33:28','2026-06-05 18:33:28'),(433,1,82,310,1,9.00,1,'2026-06-05 18:42:06','2026-06-05 18:42:06'),(434,1,82,311,1,9.00,1,'2026-06-05 18:42:06','2026-06-05 18:42:06'),(435,1,82,312,1,9.00,1,'2026-06-05 18:42:06','2026-06-05 18:42:06'),(436,1,82,313,1,9.00,1,'2026-06-05 18:42:06','2026-06-05 18:42:06'),(437,1,82,314,1,9.00,1,'2026-06-05 18:42:06','2026-06-05 18:42:06'),(438,1,82,315,1,9.00,1,'2026-06-05 18:42:06','2026-06-05 18:42:06'),(439,3,82,310,1,NULL,1,'2026-06-05 18:42:06','2026-06-05 18:42:06'),(440,3,82,311,1,NULL,1,'2026-06-05 18:42:06','2026-06-05 18:42:06'),(441,3,82,312,1,NULL,1,'2026-06-05 18:42:06','2026-06-05 18:42:06'),(442,3,82,313,1,NULL,1,'2026-06-05 18:42:06','2026-06-05 18:42:06'),(443,3,82,314,1,NULL,1,'2026-06-05 18:42:06','2026-06-05 18:42:06'),(444,3,82,315,1,NULL,1,'2026-06-05 18:42:06','2026-06-05 18:42:06'),(445,1,81,304,1,8.00,1,'2026-06-05 18:42:39','2026-06-05 18:42:39'),(446,1,81,305,1,8.00,1,'2026-06-05 18:42:39','2026-06-05 18:42:39'),(447,1,81,306,1,8.00,1,'2026-06-05 18:42:40','2026-06-05 18:42:40'),(448,1,81,307,1,8.00,1,'2026-06-05 18:42:40','2026-06-05 18:42:40'),(449,1,81,308,1,8.00,1,'2026-06-05 18:42:40','2026-06-05 18:42:40'),(450,1,81,309,1,8.00,1,'2026-06-05 18:42:40','2026-06-05 18:42:40'),(451,3,81,304,1,NULL,1,'2026-06-05 18:42:40','2026-06-05 18:42:40'),(452,3,81,305,1,NULL,1,'2026-06-05 18:42:40','2026-06-05 18:42:40'),(453,3,81,306,1,NULL,1,'2026-06-05 18:42:40','2026-06-05 18:42:40'),(454,3,81,307,1,NULL,1,'2026-06-05 18:42:40','2026-06-05 18:42:40'),(455,3,81,308,1,NULL,1,'2026-06-05 18:42:40','2026-06-05 18:42:40'),(456,3,81,309,1,NULL,1,'2026-06-05 18:42:41','2026-06-05 18:42:41'),(457,1,86,334,1,9.00,1,'2026-06-06 15:45:52','2026-06-06 15:45:52'),(458,1,86,335,1,7.00,1,'2026-06-06 15:45:52','2026-06-06 15:45:52'),(459,1,86,336,1,8.00,1,'2026-06-06 15:45:52','2026-06-06 15:45:52'),(460,1,86,337,1,9.00,1,'2026-06-06 15:45:52','2026-06-06 15:45:52'),(461,1,86,338,1,9.00,1,'2026-06-06 15:45:52','2026-06-06 15:45:52'),(462,1,86,339,1,9.00,1,'2026-06-06 15:45:52','2026-06-06 15:45:52'),(463,3,86,334,1,NULL,1,'2026-06-06 15:45:52','2026-06-06 15:45:52'),(464,3,86,335,1,NULL,1,'2026-06-06 15:45:52','2026-06-06 15:45:52'),(465,3,86,336,1,NULL,1,'2026-06-06 15:45:52','2026-06-06 15:45:52'),(466,3,86,337,1,NULL,1,'2026-06-06 15:45:52','2026-06-06 15:45:52'),(467,3,86,338,1,NULL,1,'2026-06-06 15:45:52','2026-06-06 15:45:52'),(468,3,86,339,1,NULL,1,'2026-06-06 15:45:52','2026-06-06 15:45:52'),(541,1,44,7,1,9.00,1,'2026-06-09 19:05:30','2026-06-09 19:05:30'),(542,1,44,8,1,9.00,1,'2026-06-09 19:05:30','2026-06-09 19:05:30'),(543,1,44,9,1,9.00,1,'2026-06-09 19:05:30','2026-06-09 19:05:30'),(544,1,44,10,1,9.00,1,'2026-06-09 19:05:30','2026-06-09 19:05:30'),(545,1,44,11,1,9.00,1,'2026-06-09 19:05:30','2026-06-09 19:05:30'),(546,1,44,12,1,9.00,1,'2026-06-09 19:05:30','2026-06-09 19:05:30'),(547,6,44,7,1,NULL,1,'2026-06-09 19:05:30','2026-06-09 19:05:30'),(548,6,44,8,1,NULL,1,'2026-06-09 19:05:30','2026-06-09 19:05:30'),(549,6,44,9,1,NULL,1,'2026-06-09 19:05:30','2026-06-09 19:05:30'),(550,6,44,10,1,NULL,1,'2026-06-09 19:05:30','2026-06-09 19:05:30'),(551,6,44,11,1,NULL,1,'2026-06-09 19:05:30','2026-06-09 19:05:30'),(552,6,44,12,1,NULL,1,'2026-06-09 19:05:30','2026-06-09 19:05:30'),(553,3,44,7,1,NULL,1,'2026-06-09 19:05:30','2026-06-09 19:05:30'),(554,3,44,8,1,NULL,1,'2026-06-09 19:05:30','2026-06-09 19:05:30'),(555,3,44,9,1,NULL,1,'2026-06-09 19:05:30','2026-06-09 19:05:30'),(556,3,44,10,1,NULL,1,'2026-06-09 19:05:30','2026-06-09 19:05:30'),(557,3,44,11,1,NULL,1,'2026-06-09 19:05:30','2026-06-09 19:05:30'),(558,3,44,12,1,NULL,1,'2026-06-09 19:05:30','2026-06-09 19:05:30'),(597,1,93,508,1,9.00,1,'2026-06-09 19:46:41','2026-06-09 19:46:41'),(598,1,93,509,1,9.00,1,'2026-06-09 19:46:41','2026-06-09 19:46:41'),(599,1,93,510,1,9.00,1,'2026-06-09 19:46:41','2026-06-09 19:46:41'),(600,1,93,511,1,9.00,1,'2026-06-09 19:46:41','2026-06-09 19:46:41'),(601,1,93,512,1,9.00,1,'2026-06-09 19:46:41','2026-06-09 19:46:41'),(602,1,93,513,1,9.00,1,'2026-06-09 19:46:41','2026-06-09 19:46:41'),(603,6,93,508,1,NULL,1,'2026-06-09 19:46:41','2026-06-09 19:46:41'),(604,6,93,509,1,NULL,1,'2026-06-09 19:46:42','2026-06-09 19:46:42'),(605,6,93,510,1,NULL,1,'2026-06-09 19:46:42','2026-06-09 19:46:42'),(606,6,93,511,1,NULL,1,'2026-06-09 19:46:42','2026-06-09 19:46:42'),(607,6,93,512,1,NULL,1,'2026-06-09 19:46:42','2026-06-09 19:46:42'),(608,6,93,513,1,NULL,1,'2026-06-09 19:46:42','2026-06-09 19:46:42'),(609,3,93,508,1,NULL,1,'2026-06-09 19:46:42','2026-06-09 19:46:42'),(610,3,93,509,1,NULL,1,'2026-06-09 19:46:42','2026-06-09 19:46:42'),(611,3,93,510,1,NULL,1,'2026-06-09 19:46:42','2026-06-09 19:46:42'),(612,3,93,511,1,NULL,1,'2026-06-09 19:46:42','2026-06-09 19:46:42'),(613,3,93,512,1,NULL,1,'2026-06-09 19:46:42','2026-06-09 19:46:42'),(614,3,93,513,1,NULL,1,'2026-06-09 19:46:42','2026-06-09 19:46:42'),(651,1,111,595,1,9.00,1,'2026-06-09 21:24:23','2026-06-09 21:24:23'),(652,1,111,675,1,9.00,1,'2026-06-09 21:24:23','2026-06-09 21:24:23'),(653,1,111,755,1,9.00,1,'2026-06-09 21:24:23','2026-06-09 21:24:23'),(654,1,111,835,1,9.00,1,'2026-06-09 21:24:23','2026-06-09 21:24:23'),(655,1,111,915,1,9.00,1,'2026-06-09 21:24:23','2026-06-09 21:24:23'),(656,1,111,995,1,9.00,1,'2026-06-09 21:24:23','2026-06-09 21:24:23'),(657,6,111,595,1,NULL,1,'2026-06-09 21:24:23','2026-06-09 21:24:23'),(658,6,111,675,1,NULL,1,'2026-06-09 21:24:23','2026-06-09 21:24:23'),(659,6,111,755,1,NULL,1,'2026-06-09 21:24:23','2026-06-09 21:24:23'),(660,6,111,835,1,NULL,1,'2026-06-09 21:24:23','2026-06-09 21:24:23'),(661,6,111,915,1,NULL,1,'2026-06-09 21:24:23','2026-06-09 21:24:23'),(662,6,111,995,1,NULL,1,'2026-06-09 21:24:23','2026-06-09 21:24:23'),(663,3,111,595,1,NULL,1,'2026-06-09 21:24:23','2026-06-09 21:24:23'),(664,3,111,675,1,NULL,1,'2026-06-09 21:24:23','2026-06-09 21:24:23'),(665,3,111,755,1,NULL,1,'2026-06-09 21:24:23','2026-06-09 21:24:23'),(666,3,111,835,1,NULL,1,'2026-06-09 21:24:23','2026-06-09 21:24:23'),(667,3,111,915,1,NULL,1,'2026-06-09 21:24:24','2026-06-09 21:24:24'),(668,3,111,995,1,NULL,1,'2026-06-09 21:24:24','2026-06-09 21:24:24'),(669,1,60,611,1,8.00,1,'2026-06-09 21:24:30','2026-06-09 21:24:30'),(670,1,60,691,1,8.00,1,'2026-06-09 21:24:30','2026-06-09 21:24:30'),(671,1,60,771,1,8.00,1,'2026-06-09 21:24:30','2026-06-09 21:24:30'),(672,1,60,851,1,8.00,1,'2026-06-09 21:24:31','2026-06-09 21:24:31'),(673,1,60,931,1,8.00,1,'2026-06-09 21:24:31','2026-06-09 21:24:31'),(674,1,60,1011,1,8.00,1,'2026-06-09 21:24:31','2026-06-09 21:24:31'),(675,6,60,611,1,NULL,1,'2026-06-09 21:24:31','2026-06-09 21:24:31'),(676,6,60,691,1,NULL,1,'2026-06-09 21:24:31','2026-06-09 21:24:31'),(677,6,60,771,1,NULL,1,'2026-06-09 21:24:31','2026-06-09 21:24:31'),(678,6,60,851,1,NULL,1,'2026-06-09 21:24:31','2026-06-09 21:24:31'),(679,6,60,931,1,NULL,1,'2026-06-09 21:24:31','2026-06-09 21:24:31'),(680,6,60,1011,1,NULL,1,'2026-06-09 21:24:31','2026-06-09 21:24:31'),(681,3,60,611,1,NULL,1,'2026-06-09 21:24:31','2026-06-09 21:24:31'),(682,3,60,691,1,NULL,1,'2026-06-09 21:24:31','2026-06-09 21:24:31'),(683,3,60,771,1,NULL,1,'2026-06-09 21:24:31','2026-06-09 21:24:31'),(684,3,60,851,1,NULL,1,'2026-06-09 21:24:31','2026-06-09 21:24:31'),(685,3,60,931,1,NULL,1,'2026-06-09 21:24:31','2026-06-09 21:24:31'),(686,3,60,1011,1,NULL,1,'2026-06-09 21:24:31','2026-06-09 21:24:31'),(687,1,107,571,1,9.00,1,'2026-06-09 21:24:38','2026-06-09 21:24:38'),(688,1,107,651,1,9.00,1,'2026-06-09 21:24:38','2026-06-09 21:24:38'),(689,1,107,731,1,9.00,1,'2026-06-09 21:24:38','2026-06-09 21:24:38'),(690,1,107,811,1,9.00,1,'2026-06-09 21:24:38','2026-06-09 21:24:38'),(691,1,107,891,1,9.00,1,'2026-06-09 21:24:38','2026-06-09 21:24:38'),(692,1,107,971,1,9.00,1,'2026-06-09 21:24:38','2026-06-09 21:24:38'),(693,6,107,571,1,NULL,1,'2026-06-09 21:24:38','2026-06-09 21:24:38'),(694,6,107,651,1,NULL,1,'2026-06-09 21:24:39','2026-06-09 21:24:39'),(695,6,107,731,1,NULL,1,'2026-06-09 21:24:39','2026-06-09 21:24:39'),(696,6,107,811,1,NULL,1,'2026-06-09 21:24:39','2026-06-09 21:24:39'),(697,6,107,891,1,NULL,1,'2026-06-09 21:24:39','2026-06-09 21:24:39'),(698,6,107,971,1,NULL,1,'2026-06-09 21:24:39','2026-06-09 21:24:39'),(699,3,107,571,1,NULL,1,'2026-06-09 21:24:39','2026-06-09 21:24:39'),(700,3,107,651,1,NULL,1,'2026-06-09 21:24:39','2026-06-09 21:24:39'),(701,3,107,731,1,NULL,1,'2026-06-09 21:24:39','2026-06-09 21:24:39'),(702,3,107,811,1,NULL,1,'2026-06-09 21:24:39','2026-06-09 21:24:39'),(703,3,107,891,1,NULL,1,'2026-06-09 21:24:39','2026-06-09 21:24:39'),(704,3,107,971,1,NULL,1,'2026-06-09 21:24:39','2026-06-09 21:24:39'),(705,1,108,577,1,9.00,1,'2026-06-09 21:24:49','2026-06-09 21:24:49'),(706,1,108,657,1,9.00,1,'2026-06-09 21:24:49','2026-06-09 21:24:49'),(707,1,108,737,1,9.00,1,'2026-06-09 21:24:49','2026-06-09 21:24:49'),(708,1,108,817,1,9.00,1,'2026-06-09 21:24:49','2026-06-09 21:24:49'),(709,1,108,897,1,9.00,1,'2026-06-09 21:24:49','2026-06-09 21:24:49'),(710,1,108,977,1,9.00,1,'2026-06-09 21:24:49','2026-06-09 21:24:49'),(711,6,108,577,1,NULL,1,'2026-06-09 21:24:49','2026-06-09 21:24:49'),(712,6,108,657,1,NULL,1,'2026-06-09 21:24:49','2026-06-09 21:24:49'),(713,6,108,737,1,NULL,1,'2026-06-09 21:24:49','2026-06-09 21:24:49'),(714,6,108,817,1,NULL,1,'2026-06-09 21:24:49','2026-06-09 21:24:49'),(715,6,108,897,1,NULL,1,'2026-06-09 21:24:49','2026-06-09 21:24:49'),(716,6,108,977,1,NULL,1,'2026-06-09 21:24:49','2026-06-09 21:24:49'),(717,3,108,577,1,NULL,1,'2026-06-09 21:24:49','2026-06-09 21:24:49'),(718,3,108,657,1,NULL,1,'2026-06-09 21:24:49','2026-06-09 21:24:49'),(719,3,108,737,1,NULL,1,'2026-06-09 21:24:49','2026-06-09 21:24:49'),(720,3,108,817,1,NULL,1,'2026-06-09 21:24:49','2026-06-09 21:24:49'),(721,3,108,897,1,NULL,1,'2026-06-09 21:24:49','2026-06-09 21:24:49'),(722,3,108,977,1,NULL,1,'2026-06-09 21:24:49','2026-06-09 21:24:49'),(723,1,110,589,1,8.00,1,'2026-06-09 21:25:06','2026-06-09 21:25:06'),(724,1,110,669,1,8.00,1,'2026-06-09 21:25:06','2026-06-09 21:25:06'),(725,1,110,749,1,8.00,1,'2026-06-09 21:25:06','2026-06-09 21:25:06'),(726,1,110,829,1,8.00,1,'2026-06-09 21:25:06','2026-06-09 21:25:06'),(727,1,110,909,1,8.00,1,'2026-06-09 21:25:06','2026-06-09 21:25:06'),(728,1,110,989,1,8.00,1,'2026-06-09 21:25:06','2026-06-09 21:25:06'),(729,6,110,589,1,NULL,1,'2026-06-09 21:25:06','2026-06-09 21:25:06'),(730,6,110,669,1,NULL,1,'2026-06-09 21:25:06','2026-06-09 21:25:06'),(731,6,110,749,1,NULL,1,'2026-06-09 21:25:06','2026-06-09 21:25:06'),(732,6,110,829,1,NULL,1,'2026-06-09 21:25:06','2026-06-09 21:25:06'),(733,6,110,909,1,NULL,1,'2026-06-09 21:25:06','2026-06-09 21:25:06'),(734,6,110,989,1,NULL,1,'2026-06-09 21:25:06','2026-06-09 21:25:06'),(735,3,110,589,1,NULL,1,'2026-06-09 21:25:06','2026-06-09 21:25:06'),(736,3,110,669,1,NULL,1,'2026-06-09 21:25:06','2026-06-09 21:25:06'),(737,3,110,749,1,NULL,1,'2026-06-09 21:25:06','2026-06-09 21:25:06'),(738,3,110,829,1,NULL,1,'2026-06-09 21:25:06','2026-06-09 21:25:06'),(739,3,110,909,1,NULL,1,'2026-06-09 21:25:06','2026-06-09 21:25:06'),(740,3,110,989,1,NULL,1,'2026-06-09 21:25:06','2026-06-09 21:25:06'),(741,1,112,601,1,10.00,1,'2026-06-09 21:25:23','2026-06-09 21:25:23'),(742,1,112,681,1,10.00,1,'2026-06-09 21:25:23','2026-06-09 21:25:23'),(743,1,112,761,1,10.00,1,'2026-06-09 21:25:23','2026-06-09 21:25:23'),(744,1,112,841,1,10.00,1,'2026-06-09 21:25:23','2026-06-09 21:25:23'),(745,1,112,921,1,10.00,1,'2026-06-09 21:25:23','2026-06-09 21:25:23'),(746,1,112,1001,1,10.00,1,'2026-06-09 21:25:23','2026-06-09 21:25:23'),(747,6,112,601,1,NULL,1,'2026-06-09 21:25:23','2026-06-09 21:25:23'),(748,6,112,681,1,NULL,1,'2026-06-09 21:25:23','2026-06-09 21:25:23'),(749,6,112,761,1,NULL,1,'2026-06-09 21:25:23','2026-06-09 21:25:23'),(750,6,112,841,1,NULL,1,'2026-06-09 21:25:23','2026-06-09 21:25:23'),(751,6,112,921,1,NULL,1,'2026-06-09 21:25:23','2026-06-09 21:25:23'),(752,6,112,1001,1,NULL,1,'2026-06-09 21:25:23','2026-06-09 21:25:23'),(753,3,112,601,1,NULL,1,'2026-06-09 21:25:23','2026-06-09 21:25:23'),(754,3,112,681,1,NULL,1,'2026-06-09 21:25:23','2026-06-09 21:25:23'),(755,3,112,761,1,NULL,1,'2026-06-09 21:25:23','2026-06-09 21:25:23'),(756,3,112,841,1,NULL,1,'2026-06-09 21:25:23','2026-06-09 21:25:23'),(757,3,112,921,1,NULL,1,'2026-06-09 21:25:23','2026-06-09 21:25:23'),(758,3,112,1001,1,NULL,1,'2026-06-09 21:25:23','2026-06-09 21:25:23'),(759,1,346,526,1,8.00,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(760,1,346,527,1,8.00,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(761,1,346,528,1,8.00,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(762,1,346,529,1,8.00,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(763,1,346,530,1,8.00,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(764,1,346,531,1,8.00,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(765,6,346,526,1,NULL,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(766,6,346,527,1,NULL,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(767,6,346,528,1,NULL,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(768,6,346,529,1,NULL,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(769,6,346,530,1,NULL,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(770,6,346,531,1,NULL,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(771,3,346,526,1,NULL,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(772,3,346,527,1,NULL,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(773,3,346,528,1,NULL,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(774,3,346,529,1,NULL,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(775,3,346,530,1,NULL,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(776,3,346,531,1,NULL,1,'2026-06-10 04:54:04','2026-06-10 04:54:04');
/*!40000 ALTER TABLE `calificaciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `calificaciones_artes`
--

DROP TABLE IF EXISTS `calificaciones_artes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `calificaciones_artes` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `alumno_id` int(10) unsigned NOT NULL,
  `asignacion_id` int(10) unsigned NOT NULL,
  `periodo` tinyint(3) unsigned NOT NULL COMMENT '1 al 6',
  `calificacion` tinyint(3) unsigned DEFAULT NULL,
  `capturado_por` int(10) unsigned NOT NULL,
  `capturado_en` datetime NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_calificacion_artes` (`alumno_id`,`asignacion_id`,`periodo`),
  KEY `asignacion_id` (`asignacion_id`),
  KEY `capturado_por` (`capturado_por`),
  CONSTRAINT `calificaciones_artes_ibfk_1` FOREIGN KEY (`alumno_id`) REFERENCES `alumnos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `calificaciones_artes_ibfk_2` FOREIGN KEY (`asignacion_id`) REFERENCES `asignaciones` (`id`) ON DELETE CASCADE,
  CONSTRAINT `calificaciones_artes_ibfk_3` FOREIGN KEY (`capturado_por`) REFERENCES `profesores` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `calificaciones_artes`
--

LOCK TABLES `calificaciones_artes` WRITE;
/*!40000 ALTER TABLE `calificaciones_artes` DISABLE KEYS */;
INSERT INTO `calificaciones_artes` VALUES (2,1,47,1,9,1,'2026-06-02 16:33:42','2026-06-02 16:33:42'),(3,1,48,1,8,1,'2026-06-02 16:33:42','2026-06-02 16:33:42'),(6,1,47,2,8,1,'2026-06-02 16:37:45','2026-06-02 16:37:45'),(7,1,48,2,7,1,'2026-06-02 16:37:45','2026-06-02 16:37:45'),(9,1,47,3,9,1,'2026-06-02 16:37:45','2026-06-02 16:37:45'),(10,1,48,3,8,1,'2026-06-02 16:37:45','2026-06-02 16:37:45'),(12,1,47,4,8,1,'2026-06-02 16:37:45','2026-06-02 16:37:45'),(13,1,48,4,7,1,'2026-06-02 16:37:45','2026-06-02 16:37:45'),(15,1,47,5,9,1,'2026-06-02 16:37:45','2026-06-02 16:37:45'),(16,1,48,5,8,1,'2026-06-02 16:37:45','2026-06-02 16:37:45'),(18,1,47,6,8,1,'2026-06-02 16:37:45','2026-06-02 16:37:45'),(19,1,48,6,7,1,'2026-06-02 16:37:45','2026-06-02 16:37:45');
/*!40000 ALTER TABLE `calificaciones_artes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `calificaciones_backup`
--

DROP TABLE IF EXISTS `calificaciones_backup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `calificaciones_backup` (
  `id` int(10) unsigned NOT NULL DEFAULT 0,
  `alumno_id` int(10) unsigned NOT NULL,
  `asignacion_id` int(10) unsigned NOT NULL,
  `aspecto_id` int(10) unsigned NOT NULL,
  `periodo` tinyint(3) unsigned NOT NULL,
  `calificacion` decimal(5,2) DEFAULT NULL,
  `capturado_por` int(10) unsigned NOT NULL,
  `capturado_en` datetime NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `calificaciones_backup`
--

LOCK TABLES `calificaciones_backup` WRITE;
/*!40000 ALTER TABLE `calificaciones_backup` DISABLE KEYS */;
/*!40000 ALTER TABLE `calificaciones_backup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `calificaciones_disciplina`
--

DROP TABLE IF EXISTS `calificaciones_disciplina`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `calificaciones_disciplina` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `alumno_id` int(10) unsigned NOT NULL,
  `aspecto_id` int(10) unsigned NOT NULL,
  `periodo` tinyint(3) unsigned NOT NULL,
  `calificacion` decimal(5,2) DEFAULT NULL,
  `capturado_por` int(10) unsigned NOT NULL,
  `capturado_en` datetime NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_cali_disciplina` (`alumno_id`,`aspecto_id`,`periodo`),
  KEY `fk_cali_disciplina_aspecto` (`aspecto_id`),
  KEY `fk_cali_disciplina_prof` (`capturado_por`),
  CONSTRAINT `fk_cali_disciplina_alumno` FOREIGN KEY (`alumno_id`) REFERENCES `alumnos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cali_disciplina_aspecto` FOREIGN KEY (`aspecto_id`) REFERENCES `asignacion_disciplina_aspectos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cali_disciplina_prof` FOREIGN KEY (`capturado_por`) REFERENCES `profesores` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `calificaciones_disciplina`
--

LOCK TABLES `calificaciones_disciplina` WRITE;
/*!40000 ALTER TABLE `calificaciones_disciplina` DISABLE KEYS */;
/*!40000 ALTER TABLE `calificaciones_disciplina` ENABLE KEYS */;
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
  UNIQUE KEY `uk_calificacion_ingles` (`alumno_id`,`aspecto_id`,`periodo`),
  KEY `fk_cali_aspecto` (`aspecto_id`),
  KEY `fk_cali_prof` (`capturado_por`),
  CONSTRAINT `fk_cali_alumno` FOREIGN KEY (`alumno_id`) REFERENCES `alumnos` (`id`),
  CONSTRAINT `fk_cali_aspecto` FOREIGN KEY (`aspecto_id`) REFERENCES `asignacion_ingles_aspectos` (`id`),
  CONSTRAINT `fk_cali_prof` FOREIGN KEY (`capturado_por`) REFERENCES `profesores` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=68 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `calificaciones_ingles`
--

LOCK TABLES `calificaciones_ingles` WRITE;
/*!40000 ALTER TABLE `calificaciones_ingles` DISABLE KEYS */;
INSERT INTO `calificaciones_ingles` VALUES (36,1,169,1,9,4,'2026-06-02 15:21:56','2026-06-03 21:03:40'),(37,1,170,1,8,4,'2026-06-02 15:21:56','2026-06-03 21:03:41'),(38,1,171,1,9,4,'2026-06-02 15:21:56','2026-06-03 21:03:40'),(39,1,172,1,7,4,'2026-06-02 15:21:56','2026-06-03 21:03:41'),(40,1,173,1,9,4,'2026-06-02 15:21:56','2026-06-03 21:03:41'),(41,1,174,1,8,4,'2026-06-02 15:21:56','2026-06-03 21:03:40'),(42,1,175,1,8,4,'2026-06-02 15:21:56','2026-06-03 21:03:41'),(43,1,176,1,7,4,'2026-06-02 15:21:56','2026-06-03 21:03:41'),(44,3,169,1,NULL,4,'2026-06-02 15:21:56','2026-06-03 21:03:41'),(45,3,170,1,NULL,4,'2026-06-02 15:21:56','2026-06-03 21:03:41'),(46,3,171,1,NULL,4,'2026-06-02 15:21:56','2026-06-03 21:03:41'),(47,3,172,1,NULL,4,'2026-06-02 15:21:56','2026-06-03 21:03:41'),(48,3,173,1,NULL,4,'2026-06-02 15:21:56','2026-06-03 21:03:41'),(49,3,174,1,NULL,4,'2026-06-02 15:21:56','2026-06-03 21:03:41'),(50,3,175,1,NULL,4,'2026-06-02 15:21:56','2026-06-03 21:03:41'),(51,3,176,1,NULL,4,'2026-06-02 15:21:56','2026-06-03 21:03:41');
/*!40000 ALTER TABLE `calificaciones_ingles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `calificaciones_old`
--

DROP TABLE IF EXISTS `calificaciones_old`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `calificaciones_old` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `alumno_id` int(10) unsigned NOT NULL,
  `asignacion_id` int(10) unsigned NOT NULL,
  `periodo` tinyint(3) unsigned NOT NULL COMMENT '1 al 6',
  `calificacion` tinyint(3) unsigned DEFAULT NULL COMMENT 'Entero, NULL = sin capturar',
  `capturado_por` int(10) unsigned NOT NULL COMMENT 'profesor_id',
  `capturado_en` datetime NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_calificacion` (`alumno_id`,`asignacion_id`,`periodo`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `calificaciones_old`
--

LOCK TABLES `calificaciones_old` WRITE;
/*!40000 ALTER TABLE `calificaciones_old` DISABLE KEYS */;
INSERT INTO `calificaciones_old` VALUES (1,1,10,1,10,1,'2026-05-26 17:03:06','2026-05-26 17:03:06'),(2,3,10,1,10,1,'2026-05-26 17:03:06','2026-05-26 17:03:06'),(3,1,4,1,10,1,'2026-05-26 19:53:44','2026-05-26 19:53:44'),(4,3,4,1,10,1,'2026-05-26 19:53:44','2026-05-26 19:53:44'),(5,1,12,1,10,1,'2026-05-26 19:53:54','2026-05-26 19:53:54'),(6,3,12,1,10,1,'2026-05-26 19:53:54','2026-05-26 19:53:54'),(7,1,6,1,10,1,'2026-05-26 19:54:12','2026-05-26 19:54:12'),(8,3,6,1,9,1,'2026-05-26 19:54:12','2026-05-26 19:54:12'),(9,1,7,1,10,1,'2026-05-26 19:54:26','2026-05-26 19:54:26'),(10,3,7,1,10,1,'2026-05-26 19:54:26','2026-05-26 19:54:26'),(11,1,2,1,9,1,'2026-05-26 19:54:34','2026-05-26 19:54:34'),(12,3,2,1,9,1,'2026-05-26 19:54:34','2026-05-26 19:54:34'),(13,1,11,1,9,1,'2026-05-26 19:54:45','2026-05-26 19:54:45'),(14,3,11,1,9,1,'2026-05-26 19:54:45','2026-05-26 19:54:45'),(15,1,13,1,8,1,'2026-05-26 19:54:56','2026-05-26 19:54:56'),(16,3,13,1,9,1,'2026-05-26 19:54:56','2026-05-26 19:54:56'),(17,1,9,1,9,1,'2026-05-26 19:55:03','2026-05-26 19:55:03'),(18,3,9,1,8,1,'2026-05-26 19:55:03','2026-05-26 19:55:03'),(21,1,39,1,9,1,'2026-06-02 15:24:57','2026-06-02 15:24:57'),(22,3,39,1,NULL,1,'2026-06-02 15:24:57','2026-06-02 15:24:57'),(23,1,43,1,8,1,'2026-06-02 15:25:03','2026-06-02 15:25:03'),(24,3,43,1,NULL,1,'2026-06-02 15:25:03','2026-06-02 15:25:03'),(25,1,38,1,7,1,'2026-06-02 15:25:13','2026-06-02 15:25:13'),(26,3,38,1,NULL,1,'2026-06-02 15:25:13','2026-06-02 15:25:13'),(27,1,40,1,10,1,'2026-06-02 15:25:21','2026-06-02 15:25:21'),(28,3,40,1,NULL,1,'2026-06-02 15:25:21','2026-06-02 15:25:21'),(29,1,36,1,9,1,'2026-06-02 15:25:34','2026-06-02 15:25:34'),(30,3,36,1,NULL,1,'2026-06-02 15:25:34','2026-06-02 15:25:34'),(31,1,41,1,8,1,'2026-06-02 15:25:40','2026-06-02 15:25:40'),(32,3,41,1,NULL,1,'2026-06-02 15:25:40','2026-06-02 15:25:40');
/*!40000 ALTER TABLE `calificaciones_old` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ciclos_escolares`
--

LOCK TABLES `ciclos_escolares` WRITE;
/*!40000 ALTER TABLE `ciclos_escolares` DISABLE KEYS */;
INSERT INTO `ciclos_escolares` VALUES (1,'2025 - 2026','2025-09-01','2026-07-15',1,'2026-05-21 03:46:30'),(4,'2024-2025','2024-08-15','2025-07-15',0,'2026-06-09 18:20:56');
/*!40000 ALTER TABLE `ciclos_escolares` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `documentos_alumnos`
--

DROP TABLE IF EXISTS `documentos_alumnos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `documentos_alumnos` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `alumno_id` int(10) unsigned NOT NULL,
  `tipo_documento` enum('acta_nacimiento','comprobante_domicilio','ine_padre','ine_madre','fotografia','boleta_anterior','certificado_preescolar','certificado_primaria','carta_buena_conducta','carta_no_adeudo','contrato_adhesion','reglamento_escolar','curp_tutor','curp_alumno','ficha_inscripcion') NOT NULL,
  `nombre_archivo` varchar(255) NOT NULL,
  `ruta_archivo` varchar(500) NOT NULL,
  `tamano` int(10) unsigned DEFAULT NULL,
  `observaciones` text DEFAULT NULL,
  `subido_por` int(10) unsigned NOT NULL COMMENT 'user_id del padre/tutor',
  `fecha_subida` datetime NOT NULL DEFAULT current_timestamp(),
  `activo` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_alumno_documento` (`alumno_id`,`tipo_documento`),
  KEY `subido_por` (`subido_por`),
  CONSTRAINT `documentos_alumnos_ibfk_1` FOREIGN KEY (`alumno_id`) REFERENCES `alumnos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `documentos_alumnos_ibfk_2` FOREIGN KEY (`subido_por`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documentos_alumnos`
--

LOCK TABLES `documentos_alumnos` WRITE;
/*!40000 ALTER TABLE `documentos_alumnos` DISABLE KEYS */;
INSERT INTO `documentos_alumnos` VALUES (1,1,'acta_nacimiento','acta_nacimiento_prueba.pdf','uploads/documentos/1_acta_nacimiento_1780331558.pdf',16974,'',2,'2026-06-01 10:32:38',1);
/*!40000 ALTER TABLE `documentos_alumnos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `grados_materias`
--

DROP TABLE IF EXISTS `grados_materias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `grados_materias` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `seccion` enum('maternal','preescolar','primaria','secundaria') NOT NULL,
  `grado` tinyint(3) unsigned NOT NULL,
  `materia_id` int(10) unsigned NOT NULL,
  `campo_formativo_id` int(10) unsigned DEFAULT NULL,
  `orden` tinyint(3) unsigned DEFAULT 0 COMMENT 'Orden en boleta',
  `activo` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_grado_materia` (`seccion`,`grado`,`materia_id`),
  KEY `materia_id` (`materia_id`),
  KEY `idx_campo_formativo` (`campo_formativo_id`),
  CONSTRAINT `grados_materias_ibfk_1` FOREIGN KEY (`materia_id`) REFERENCES `materias` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1017 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `grados_materias`
--

LOCK TABLES `grados_materias` WRITE;
/*!40000 ALTER TABLE `grados_materias` DISABLE KEYS */;
INSERT INTO `grados_materias` VALUES (167,'primaria',3,27,NULL,21,1),(168,'primaria',4,27,NULL,21,1),(169,'primaria',3,28,NULL,22,1),(170,'primaria',4,28,NULL,22,1),(171,'primaria',3,29,NULL,23,1),(172,'primaria',4,29,NULL,23,1),(182,'primaria',5,27,NULL,21,1),(184,'primaria',5,28,NULL,22,1),(186,'primaria',5,29,NULL,23,1),(188,'primaria',5,30,NULL,24,1),(198,'secundaria',1,27,NULL,21,1),(199,'secundaria',2,27,NULL,21,1),(200,'secundaria',3,27,NULL,21,1),(201,'secundaria',1,28,NULL,22,1),(202,'secundaria',2,28,NULL,22,1),(203,'secundaria',3,28,NULL,22,1),(204,'secundaria',1,29,NULL,23,1),(205,'secundaria',2,29,NULL,23,1),(206,'secundaria',3,29,NULL,23,1),(207,'secundaria',1,30,NULL,24,1),(208,'secundaria',2,30,NULL,24,1),(209,'secundaria',3,30,NULL,24,1),(289,'primaria',6,28,1,22,1),(290,'primaria',6,30,1,24,1),(291,'primaria',6,27,4,21,1),(292,'primaria',6,29,4,23,1),(293,'primaria',6,14,4,0,1),(294,'primaria',6,6,1,0,1),(295,'primaria',6,10,2,0,1),(415,'primaria',3,278,1,0,1),(416,'primaria',3,279,1,0,1),(417,'primaria',3,280,1,0,1),(418,'primaria',3,281,1,0,1),(419,'primaria',3,282,1,0,1),(420,'primaria',4,278,1,0,1),(421,'primaria',4,279,1,0,1),(422,'primaria',4,280,1,0,1),(423,'primaria',4,281,1,0,1),(424,'primaria',4,282,1,0,1),(425,'primaria',5,278,1,0,1),(426,'primaria',5,279,1,0,1),(427,'primaria',5,280,1,0,1),(428,'primaria',5,281,1,0,1),(429,'primaria',5,282,1,0,1),(430,'primaria',6,278,1,0,1),(431,'primaria',6,279,1,0,1),(432,'primaria',6,280,1,0,1),(433,'primaria',6,281,1,0,1),(434,'primaria',6,282,1,0,1),(435,'secundaria',1,278,1,0,1),(436,'secundaria',1,279,1,0,1),(437,'secundaria',1,280,1,0,1),(438,'secundaria',1,281,1,0,1),(439,'secundaria',1,282,1,0,1),(440,'secundaria',2,278,1,0,1),(441,'secundaria',2,279,1,0,1),(442,'secundaria',2,280,1,0,1),(443,'secundaria',2,281,1,0,1),(444,'secundaria',2,282,1,0,1),(445,'secundaria',3,278,1,0,1),(446,'secundaria',3,279,1,0,1),(447,'secundaria',3,280,1,0,1),(448,'secundaria',3,281,1,0,1),(449,'secundaria',3,282,1,0,1),(452,'primaria',3,285,1,0,1),(453,'primaria',4,285,1,0,1),(454,'primaria',5,285,1,0,1),(455,'primaria',6,285,1,0,1),(458,'primaria',3,286,1,0,1),(459,'primaria',4,286,1,0,1),(460,'primaria',5,286,1,0,1),(461,'primaria',6,286,1,0,1),(464,'primaria',3,287,1,0,1),(465,'primaria',4,287,1,0,1),(466,'primaria',5,287,1,0,1),(467,'primaria',6,287,1,0,1),(470,'primaria',3,288,1,0,1),(471,'primaria',4,288,1,0,1),(472,'primaria',5,288,1,0,1),(473,'primaria',6,288,1,0,1),(476,'primaria',3,289,1,0,1),(477,'primaria',4,289,1,0,1),(478,'primaria',5,289,1,0,1),(479,'primaria',6,289,1,0,1),(482,'primaria',3,290,1,0,1),(483,'primaria',4,290,1,0,1),(484,'primaria',5,290,1,0,1),(485,'primaria',6,290,1,0,1),(513,'secundaria',1,285,1,0,1),(514,'secundaria',2,285,1,0,1),(515,'secundaria',3,285,1,0,1),(516,'secundaria',1,286,1,0,1),(517,'secundaria',2,286,1,0,1),(518,'secundaria',3,286,1,0,1),(519,'secundaria',1,287,1,0,1),(520,'secundaria',2,287,1,0,1),(521,'secundaria',3,287,1,0,1),(522,'secundaria',1,288,1,0,1),(523,'secundaria',2,288,1,0,1),(524,'secundaria',3,288,1,0,1),(525,'secundaria',1,289,1,0,1),(526,'secundaria',2,289,1,0,1),(527,'secundaria',3,289,1,0,1),(528,'secundaria',1,290,1,0,1),(529,'secundaria',2,290,1,0,1),(530,'secundaria',3,290,1,0,1),(791,'secundaria',1,300,2,1,1),(792,'secundaria',2,300,2,2,1),(793,'secundaria',3,300,2,3,1),(794,'secundaria',1,301,2,4,1),(795,'secundaria',2,301,2,5,1),(796,'secundaria',3,301,2,6,1),(797,'secundaria',1,302,2,7,1),(798,'secundaria',2,302,2,8,1),(799,'secundaria',3,302,2,9,1),(800,'primaria',5,299,NULL,1,1),(801,'primaria',6,299,NULL,2,1),(878,'primaria',2,1,1,7,1),(879,'primaria',2,290,1,0,1),(880,'primaria',2,279,1,0,1),(881,'primaria',2,278,1,0,1),(882,'primaria',2,18,1,0,1),(883,'primaria',2,21,1,0,1),(884,'primaria',2,20,1,0,1),(885,'primaria',2,22,1,0,1),(886,'primaria',2,19,1,0,1),(887,'primaria',2,287,1,0,1),(888,'primaria',2,23,1,0,1),(889,'primaria',2,289,1,0,1),(890,'primaria',2,9,2,1,1),(891,'primaria',2,14,4,2,1),(892,'primaria',2,13,3,3,1),(893,'primaria',2,3,NULL,4,1),(894,'primaria',2,11,3,5,1),(895,'primaria',2,12,3,6,1),(896,'primaria',2,5,2,8,1),(897,'primaria',2,16,4,9,1),(898,'primaria',2,10,2,10,1),(899,'primaria',2,15,4,11,1),(900,'primaria',2,4,1,20,1),(901,'primaria',2,27,4,21,1),(902,'primaria',2,28,1,22,1),(996,'primaria',1,298,NULL,20,1),(997,'primaria',1,9,2,5,1),(998,'primaria',1,297,NULL,19,1),(999,'primaria',1,13,3,7,1),(1000,'primaria',1,1,1,1,1),(1001,'primaria',1,5,2,4,1),(1002,'primaria',1,16,4,10,1),(1003,'primaria',1,15,4,9,1),(1004,'primaria',1,21,1,16,1),(1005,'primaria',1,279,1,11,1),(1006,'primaria',1,19,1,14,1),(1007,'primaria',1,23,1,18,1),(1008,'primaria',1,278,1,12,1),(1009,'primaria',1,22,1,17,1),(1010,'primaria',1,20,1,15,1),(1011,'primaria',1,18,1,13,1),(1012,'primaria',1,4,1,2,1),(1013,'primaria',1,28,1,3,1),(1014,'primaria',1,27,1,3,1),(1015,'primaria',1,14,4,8,1),(1016,'primaria',1,10,2,6,1);
/*!40000 ALTER TABLE `grados_materias` ENABLE KEYS */;
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
  `es_disciplina` tinyint(1) NOT NULL DEFAULT 0,
  `es_ausencias` tinyint(1) NOT NULL DEFAULT 0,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_materia_campo` (`campo_formativo_id`),
  CONSTRAINT `fk_materia_campo` FOREIGN KEY (`campo_formativo_id`) REFERENCES `campos_formativos` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=304 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `materias`
--

LOCK TABLES `materias` WRITE;
/*!40000 ALTER TABLE `materias` DISABLE KEYS */;
INSERT INTO `materias` VALUES (1,'Lengua Materna',1,0,0,0,0,0,1,'2026-06-09 12:20:56'),(2,'Lengua Materna',1,0,0,0,0,0,1,'2026-05-21 21:47:08'),(3,'Francés',1,0,0,0,0,0,1,'2026-06-09 12:20:56'),(4,'Artes',1,0,1,0,0,0,1,'2026-06-09 12:20:56'),(5,'Matemáticas',2,0,0,0,0,0,1,'2026-06-09 12:20:56'),(6,'Francés',NULL,0,0,0,0,0,1,'2026-05-24 10:26:38'),(8,'Matemáticas',2,0,0,0,0,0,1,'2026-05-24 10:26:38'),(9,'Ciencias Naturales',2,0,0,0,0,0,1,'2026-05-24 10:26:38'),(10,'Tecnología',2,0,0,0,0,0,1,'2026-05-24 10:26:38'),(11,'Geografía',3,0,0,0,0,0,1,'2026-05-24 10:26:38'),(12,'Historia',3,0,0,0,0,0,1,'2026-05-24 10:26:38'),(13,'F.C. y E.',NULL,0,0,0,0,0,1,'2026-05-24 10:26:38'),(14,'Educación Física',4,0,0,0,0,0,1,'2026-05-24 10:26:38'),(15,'Vida Saludable',4,0,0,0,0,0,1,'2026-05-24 10:26:38'),(16,'Socioemocional',4,0,0,0,0,0,1,'2026-05-24 10:26:38'),(17,'Higiene',NULL,0,0,1,0,0,1,'2026-05-24 10:26:38'),(18,'Writing',1,1,0,0,0,0,1,'2026-06-09 12:20:56'),(19,'Reading',1,1,0,0,0,0,1,'2026-06-09 12:20:56'),(20,'Vocabulary',1,1,0,0,0,0,1,'2026-06-09 12:20:56'),(21,'Grammar',1,1,0,0,0,0,1,'2026-06-09 12:20:56'),(22,'Spelling',1,1,0,0,0,0,1,'2026-06-09 12:20:56'),(23,'Science',1,1,0,0,0,0,1,'2026-06-09 12:20:56'),(27,'Música',4,0,1,0,0,0,1,'2026-05-29 20:39:47'),(28,'Danza',1,0,1,0,0,0,1,'2026-05-29 20:39:47'),(29,'Teatro',4,0,1,0,0,0,1,'2026-05-29 20:39:47'),(30,'Dibujo',1,0,1,0,0,0,1,'2026-05-29 20:39:47'),(278,'Speaking',1,1,0,0,0,0,1,'2026-06-03 20:05:55'),(279,'Listening',1,1,0,0,0,0,1,'2026-06-03 20:05:55'),(280,'Reading',1,1,0,0,0,0,1,'2026-06-03 20:05:55'),(281,'Writing',1,1,0,0,0,0,1,'2026-06-03 20:05:55'),(282,'Grammar',1,1,0,0,0,0,1,'2026-06-03 20:05:55'),(285,'Vocabulary',1,1,0,0,0,0,1,'2026-06-04 17:04:04'),(286,'Spelling',1,1,0,0,0,0,1,'2026-06-04 17:04:04'),(287,'Phonetics',1,1,0,0,0,0,1,'2026-06-04 17:04:04'),(288,'Science',1,1,0,0,0,0,1,'2026-06-04 17:04:04'),(289,'Social Studies',1,1,0,0,0,0,1,'2026-06-04 17:04:04'),(290,'Literature',1,1,0,0,0,0,1,'2026-06-04 17:04:04'),(297,'Disciplina',NULL,0,0,0,1,0,1,'2026-06-06 15:32:47'),(298,'Ausencias',NULL,0,0,0,0,1,1,'2026-06-06 15:32:48'),(299,'Laboratorio',NULL,0,0,0,0,0,1,'2026-06-08 16:48:57'),(300,'Física',2,0,0,0,0,0,1,'2026-06-09 12:01:58'),(301,'Química',2,0,0,0,0,0,1,'2026-06-09 12:01:58'),(302,'Biología',2,0,0,0,0,0,1,'2026-06-09 12:01:58'),(303,'Laboratorio',NULL,0,0,0,0,0,1,'2026-06-09 12:01:58');
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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `periodos_apertura`
--

LOCK TABLES `periodos_apertura` WRITE;
/*!40000 ALTER TABLE `periodos_apertura` DISABLE KEYS */;
INSERT INTO `periodos_apertura` VALUES (1,1,1,1,'2026-06-06 15:45:38',NULL),(4,1,2,0,'2026-06-05 18:07:11','2026-06-05 18:07:31');
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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `profesores`
--

LOCK TABLES `profesores` WRITE;
/*!40000 ALTER TABLE `profesores` DISABLE KEYS */;
INSERT INTO `profesores` VALUES (1,12,'Sughey Adriana','Moreno','Arellano','MOAS820608MMSRRG04','1982-06-08','femenino','titular','7773220180','adriana23@gmail.com',1,'2026-05-24 10:06:41'),(2,13,'Ana','Izquierdo','Bello',NULL,'1970-03-09','femenino','titular',NULL,NULL,1,'2026-05-28 07:28:10'),(3,14,'Mateo Adrian','Fuentes','Moreno',NULL,'2001-09-11','masculino','frances','7773220180',NULL,1,'2026-05-30 11:50:29'),(4,15,'Mateo Adrian','Fuentes','Moreno',NULL,'2001-09-11','masculino','titular','7773220180',NULL,1,'2026-05-30 11:55:05'),(5,16,'Angel David','Fuentes','Moreno',NULL,'2000-09-13','masculino','cocurricular',NULL,NULL,1,'2026-06-02 16:44:31'),(6,17,'Alejandor','Moreno','Arellano',NULL,'2000-07-27','masculino','cocurricular',NULL,NULL,1,'2026-06-02 18:04:51');
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
) ENGINE=InnoDB AUTO_INCREMENT=102 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'superadmin','$2y$10$F6bwXR9C73lmTlUAnxlme.9YDF/FLiccDp/zhLJeBzOeD6xkJPb4e',1,1,'2026-05-15 16:47:22'),(2,'morarejavieromar','$2y$10$5AIH2lcLCnlsXDyCDwafsusbSqViH.HnaSCui3SmTj5e7A9FeEY3G',2,1,'2026-05-15 17:24:12'),(4,'mormonamy','$2y$10$hhXxSIEyaxL.8BY51BXZBuHQ0oPFOLE8W3p/guM8kRFMRKAqzytX.',3,1,'2026-05-15 17:50:28'),(6,'leelynamy','$2y$10$.JpZmEjxJ2dWhk7ykonxbOZ6pXjf/JSDaSo7Bfygcde8jNIb/duLW',2,1,'2026-05-15 18:07:36'),(8,'sanarameribe','$2y$10$Z4lY3VuYUmszJhY.gfqNv.260KIJQ3I8K7Q0v9H68twC.ET0h/HMe',3,1,'2026-05-16 19:16:27'),(9,'morareanamaria','$2y$10$vwkjxH1RtOR2tSBRIUg3tudBhom1B5k5pNqppqTP84kTNjLdcqX2q',3,1,'2026-05-17 09:56:31'),(10,'morareanamaria1','$2y$10$Z7YbL3/8mWB6cyMPW1BbWelnmD27Ouob4A700062F3xdN1gzUjUci',3,1,'2026-05-17 10:02:47'),(12,'moraresugheyadriana','$2y$10$wCXHc2t1ecZEMh9uwl5SO.ULqtmRSBssZQoife.VZLux/8L7e1iq6',4,1,'2026-05-24 10:06:41'),(13,'izqbelana','$2y$10$P4xBHRGg.WPp3tI.Zgbs7u8Mx/AVZNctHbfaTo3YZu/LGwFjfsTgW',4,1,'2026-05-28 07:28:10'),(14,'fuemormateoadrian','$2y$10$ioHpNE3WYc8zJNMsMaK6y.Q3eDmM6G3HVR8Zh6Lw/to6tofzI8Ece',4,1,'2026-05-30 11:50:29'),(15,'fuemormateoadrian1','$2y$10$Yi2nriutVa0AYopqXgLNkeonb3VY8jW7mCvtzF32REnnIC8nWnGri',4,1,'2026-05-30 11:55:05'),(16,'fuemorangeldavid','$2y$10$JGP2ysYIC90mQyvQ0nSgUOYNd8EGUWMaRrBbj3Qrfym8S4B/u55Iu',4,1,'2026-06-02 16:44:31'),(17,'morarealejandor','$2y$10$NHEKDxW0CTNQHnSJTpkkV.nsTMFa.JjKaLMUz1QLQj.BXi.3pxPwK',4,1,'2026-06-02 18:04:51'),(100,'alumno_temp_1','',4,1,'2026-06-09 12:20:56'),(101,'alumno_temp_2','',4,1,'2026-06-09 12:20:56');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios_permisos`
--

DROP TABLE IF EXISTS `usuarios_permisos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usuarios_permisos` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `seccion` enum('maternal','preescolar','primaria','secundaria') NOT NULL,
  `materia_id` int(10) unsigned NOT NULL,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_permiso` (`user_id`,`seccion`,`materia_id`),
  KEY `materia_id` (`materia_id`),
  CONSTRAINT `usuarios_permisos_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `usuarios_permisos_ibfk_2` FOREIGN KEY (`materia_id`) REFERENCES `materias` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios_permisos`
--

LOCK TABLES `usuarios_permisos` WRITE;
/*!40000 ALTER TABLE `usuarios_permisos` DISABLE KEYS */;
/*!40000 ALTER TABLE `usuarios_permisos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'escuela'
--
