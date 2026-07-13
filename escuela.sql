-- MariaDB dump 10.19  Distrib 10.4.28-MariaDB, for osx10.10 (x86_64)
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
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alumnos`
--

LOCK TABLES `alumnos` WRITE;
/*!40000 ALTER TABLE `alumnos` DISABLE KEYS */;
INSERT INTO `alumnos` VALUES (1,4,NULL,'Amy','Moreno','Montes','MOMA191006MMSRNMA5','2019-10-06','2026-05-15','femenino','estudiante',1,'A','primaria',1,'2026-05-15 17:50:28','regular',0.00,0.00),(3,8,'CEFSAMX20260517000001','Meribe','Sanchez','Aranda','MOMA191006MMSRNMA9','2018-12-13','2026-05-16','femenino','estudiante',1,'A','primaria',1,'2026-05-16 19:16:27','regular',0.00,0.00),(5,10,'CEFMAAM20260517000001','Ana Maria','Moreno','Arellano','MOAJ000516HMNRRV09','2021-01-28','2026-05-17','femenino','estudiante',2,'A','preescolar',1,'2026-05-17 10:02:47','regular',0.00,0.00),(6,100,'2024001','PENDIENTE','PENDIENTE','PENDIENTE','PEND0001010101','2000-01-01','2024-08-15','otro','estudiante',1,'A','primaria',0,'2026-06-09 12:20:57','baja',0.00,0.00),(7,101,'2024002','PENDIENTE','PENDIENTE','PENDIENTE','PEND0001010102','2000-01-01','2024-08-15','otro','estudiante',1,'B','primaria',0,'2026-06-09 12:20:57','baja',0.00,0.00),(8,113,'CEFGDJX20260703000001','Julia Andrea','Garcia','Diaz','MAPE010712MPLTRL05','2026-07-03','2026-07-03','femenino','estudiante',1,'A','primaria',1,'2026-07-03 12:32:36','regular',0.00,0.00),(9,114,'CEFPCJX20260703000001','Jesus','Perez','Cortes','MAPE010712MPLTRL15','2019-01-28','2026-07-03','masculino','estudiante',1,'A','primaria',1,'2026-07-03 12:34:12','reinscripcion',0.00,0.00);
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
INSERT INTO `artes_subcomponentes` VALUES (1,'Danza',2,1,'2026-05-22 06:22:09'),(2,'Teatro',3,1,'2026-05-22 06:22:09'),(3,'Dibujo',5,0,'2026-05-22 06:22:09'),(4,'Música',4,1,'2026-05-22 06:22:09'),(5,'Artes',1,1,'2026-05-22 06:22:09');
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
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_asig_subcomp` (`asignacion_id`,`subcomponente_id`),
  UNIQUE KEY `uk_asig_sub` (`asignacion_id`,`subcomponente_id`),
  KEY `fk_asigArtes_sub` (`subcomponente_id`),
  CONSTRAINT `fk_asigArtes_asig` FOREIGN KEY (`asignacion_id`) REFERENCES `asignaciones` (`id`),
  CONSTRAINT `fk_asigArtes_sub` FOREIGN KEY (`subcomponente_id`) REFERENCES `artes_subcomponentes` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignacion_artes`
--

LOCK TABLES `asignacion_artes` WRITE;
/*!40000 ALTER TABLE `asignacion_artes` DISABLE KEYS */;
INSERT INTO `asignacion_artes` VALUES (27,416,1,1);
/*!40000 ALTER TABLE `asignacion_artes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `asignacion_artes_aspectos`
--

DROP TABLE IF EXISTS `asignacion_artes_aspectos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `asignacion_artes_aspectos` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `asignacion_id` int(10) unsigned NOT NULL COMMENT 'FK → asignaciones.id',
  `subcomponente_id` int(10) unsigned NOT NULL COMMENT 'FK → artes_subcomponentes.id',
  `nombre` varchar(50) NOT NULL,
  `porcentaje` decimal(5,2) NOT NULL DEFAULT 0.00,
  `orden` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_artes_aspecto` (`asignacion_id`,`subcomponente_id`,`nombre`),
  KEY `fk_artesasp_asig` (`asignacion_id`),
  KEY `fk_artesasp_sub` (`subcomponente_id`),
  CONSTRAINT `fk_artesasp_asig` FOREIGN KEY (`asignacion_id`) REFERENCES `asignaciones` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_artesasp_sub` FOREIGN KEY (`subcomponente_id`) REFERENCES `artes_subcomponentes` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=55 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignacion_artes_aspectos`
--

LOCK TABLES `asignacion_artes_aspectos` WRITE;
/*!40000 ALTER TABLE `asignacion_artes_aspectos` DISABLE KEYS */;
INSERT INTO `asignacion_artes_aspectos` VALUES (1,416,5,'Examen',50.00,1,1),(2,416,5,'Tareas',10.00,2,1),(3,416,5,'Participación',10.00,3,1),(4,416,5,'Evaluación Parcial',10.00,4,1),(5,416,5,'Proyecto',10.00,5,1),(6,416,5,'Trabajo y Exposiciones',10.00,6,1),(7,416,1,'Examen',50.00,1,1),(8,416,1,'Tareas',10.00,2,1),(9,416,1,'Participación',10.00,3,1),(10,416,1,'Evaluación Parcial',10.00,4,1),(11,416,1,'Proyecto',10.00,5,1),(12,416,1,'Trabajo y Exposiciones',10.00,6,1),(13,416,4,'Examen',50.00,1,1),(14,416,4,'Tareas',10.00,2,1),(15,416,4,'Participación',10.00,3,1),(16,416,4,'Evaluación Parcial',10.00,4,1),(17,416,4,'Proyecto',10.00,5,1),(18,416,4,'Trabajo y Exposiciones',10.00,6,1);
/*!40000 ALTER TABLE `asignacion_artes_aspectos` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=2669 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignacion_aspectos`
--

LOCK TABLES `asignacion_aspectos` WRITE;
/*!40000 ALTER TABLE `asignacion_aspectos` DISABLE KEYS */;
INSERT INTO `asignacion_aspectos` VALUES (7,44,'Examen',50.00,1,1),(8,44,'Tareas',10.00,2,1),(9,44,'Participación',10.00,3,1),(10,44,'Evaluación Parcial',10.00,4,1),(11,44,'Proyecto',10.00,5,1),(12,44,'Trabajo y Exposiciones',10.00,6,1),(25,36,'Examen',50.00,1,1),(26,36,'Tareas',10.00,2,1),(27,36,'Participación',10.00,3,1),(28,36,'Evaluación Parcial',10.00,4,1),(29,36,'Proyecto',10.00,5,1),(30,36,'Trabajo y Exposiciones',10.00,6,1),(37,38,'Examen',50.00,1,1),(38,38,'Tareas',10.00,2,1),(39,38,'Participación',10.00,3,1),(40,38,'Evaluación Parcial',10.00,4,1),(41,38,'Proyecto',10.00,5,1),(42,38,'Trabajo y Exposiciones',10.00,6,1),(49,43,'Examen',50.00,1,1),(50,43,'Tareas',10.00,2,1),(51,43,'Participación',10.00,3,1),(52,43,'Evaluación Parcial',10.00,4,1),(53,43,'Proyecto',10.00,5,1),(54,43,'Trabajo y Exposiciones',10.00,6,1),(55,41,'Examen',50.00,1,1),(56,41,'Tareas',10.00,2,1),(57,41,'Participación',10.00,3,1),(58,41,'Evaluación Parcial',10.00,4,1),(59,41,'Proyecto',10.00,5,1),(60,41,'Trabajo y Exposiciones',10.00,6,1),(280,77,'Examen',50.00,1,1),(281,77,'Tareas',10.00,2,1),(282,77,'Participación',10.00,3,1),(283,77,'Evaluación Parcial',10.00,4,1),(284,77,'Proyecto',10.00,5,1),(285,77,'Trabajo y Exposiciones',10.00,6,1),(286,78,'Examen',50.00,1,1),(287,78,'Tareas',10.00,2,1),(288,78,'Participación',10.00,3,1),(289,78,'Evaluación Parcial',10.00,4,1),(290,78,'Proyecto',10.00,5,1),(291,78,'Trabajo y Exposiciones',10.00,6,1),(292,79,'Examen',50.00,1,1),(293,79,'Tareas',10.00,2,1),(294,79,'Participación',10.00,3,1),(295,79,'Evaluación Parcial',10.00,4,1),(296,79,'Proyecto',10.00,5,1),(297,79,'Trabajo y Exposiciones',10.00,6,1),(298,80,'Examen',50.00,1,1),(299,80,'Tareas',10.00,2,1),(300,80,'Participación',10.00,3,1),(301,80,'Evaluación Parcial',10.00,4,1),(302,80,'Proyecto',10.00,5,1),(303,80,'Trabajo y Exposiciones',10.00,6,1),(304,81,'Examen',50.00,1,1),(305,81,'Tareas',10.00,2,1),(306,81,'Participación',10.00,3,1),(307,81,'Evaluación Parcial',10.00,4,1),(308,81,'Proyecto',10.00,5,1),(309,81,'Trabajo y Exposiciones',10.00,6,1),(310,82,'Examen',50.00,1,1),(311,82,'Tareas',10.00,2,1),(312,82,'Participación',10.00,3,1),(313,82,'Evaluación Parcial',10.00,4,1),(314,82,'Proyecto',10.00,5,1),(315,82,'Trabajo y Exposiciones',10.00,6,1),(316,83,'Examen',50.00,1,1),(317,83,'Tareas',10.00,2,1),(318,83,'Participación',10.00,3,1),(319,83,'Evaluación Parcial',10.00,4,1),(320,83,'Proyecto',10.00,5,1),(321,83,'Trabajo y Exposiciones',10.00,6,1),(322,84,'Examen',50.00,1,1),(323,84,'Tareas',10.00,2,1),(324,84,'Participación',10.00,3,1),(325,84,'Evaluación Parcial',10.00,4,1),(326,84,'Proyecto',10.00,5,1),(327,84,'Trabajo y Exposiciones',10.00,6,1),(334,86,'Examen',50.00,1,1),(335,86,'Tareas',10.00,2,1),(336,86,'Participación',10.00,3,1),(337,86,'Evaluación Parcial',10.00,4,1),(338,86,'Proyecto',10.00,5,1),(339,86,'Trabajo y Exposiciones',10.00,6,1),(340,87,'Examen',50.00,1,1),(341,87,'Tareas',10.00,2,1),(342,87,'Participación',10.00,3,1),(343,87,'Evaluación Parcial',10.00,4,1),(344,87,'Proyecto',10.00,5,1),(345,87,'Trabajo y Exposiciones',10.00,6,1),(346,88,'Examen',50.00,1,1),(347,88,'Tareas',10.00,2,1),(348,88,'Participación',10.00,3,1),(349,88,'Evaluación Parcial',10.00,4,1),(350,88,'Proyecto',10.00,5,1),(351,88,'Trabajo y Exposiciones',10.00,6,1),(352,89,'Examen',50.00,1,1),(353,89,'Tareas',10.00,2,1),(354,89,'Participación',10.00,3,1),(355,89,'Evaluación Parcial',10.00,4,1),(356,89,'Proyecto',10.00,5,1),(357,89,'Trabajo y Exposiciones',10.00,6,1),(358,264,'Examen',50.00,1,1),(359,264,'Tareas',10.00,2,1),(360,264,'Participación',10.00,3,1),(361,264,'Evaluación Parcial',10.00,4,1),(362,264,'Proyecto',10.00,5,1),(363,264,'Trabajo y Exposiciones',10.00,6,1),(364,265,'Examen',50.00,1,1),(365,265,'Tareas',10.00,2,1),(366,265,'Participación',10.00,3,1),(367,265,'Evaluación Parcial',10.00,4,1),(368,265,'Proyecto',10.00,5,1),(369,265,'Trabajo y Exposiciones',10.00,6,1),(370,268,'Examen',50.00,1,1),(371,268,'Tareas',10.00,2,1),(372,268,'Participación',10.00,3,1),(373,268,'Evaluación Parcial',10.00,4,1),(374,268,'Proyecto',10.00,5,1),(375,268,'Trabajo y Exposiciones',10.00,6,1),(376,269,'Examen',50.00,1,1),(377,269,'Tareas',10.00,2,1),(378,269,'Participación',10.00,3,1),(379,269,'Evaluación Parcial',10.00,4,1),(380,269,'Proyecto',10.00,5,1),(381,269,'Trabajo y Exposiciones',10.00,6,1),(394,272,'Examen',50.00,1,1),(395,272,'Tareas',10.00,2,1),(396,272,'Participación',10.00,3,1),(397,272,'Evaluación Parcial',10.00,4,1),(398,272,'Proyecto',10.00,5,1),(399,272,'Trabajo y Exposiciones',10.00,6,1),(400,273,'Examen',50.00,1,1),(401,273,'Tareas',10.00,2,1),(402,273,'Participación',10.00,3,1),(403,273,'Evaluación Parcial',10.00,4,1),(404,273,'Proyecto',10.00,5,1),(405,273,'Trabajo y Exposiciones',10.00,6,1),(406,274,'Examen',50.00,1,1),(407,274,'Tareas',10.00,2,1),(408,274,'Participación',10.00,3,1),(409,274,'Evaluación Parcial',10.00,4,1),(410,274,'Proyecto',10.00,5,1),(411,274,'Trabajo y Exposiciones',10.00,6,1),(436,279,'Examen',50.00,1,1),(437,279,'Tareas',10.00,2,1),(438,279,'Participación',10.00,3,1),(439,279,'Evaluación Parcial',10.00,4,1),(440,279,'Proyecto',10.00,5,1),(441,279,'Trabajo y Exposiciones',10.00,6,1),(442,280,'Examen',50.00,1,1),(443,280,'Tareas',10.00,2,1),(444,280,'Participación',10.00,3,1),(445,280,'Evaluación Parcial',10.00,4,1),(446,280,'Proyecto',10.00,5,1),(447,280,'Trabajo y Exposiciones',10.00,6,1),(448,281,'Examen',50.00,1,1),(449,281,'Tareas',10.00,2,1),(450,281,'Participación',10.00,3,1),(451,281,'Evaluación Parcial',10.00,4,1),(452,281,'Proyecto',10.00,5,1),(453,281,'Trabajo y Exposiciones',10.00,6,1),(454,282,'Examen',50.00,1,1),(455,282,'Tareas',10.00,2,1),(456,282,'Participación',10.00,3,1),(457,282,'Evaluación Parcial',10.00,4,1),(458,282,'Proyecto',10.00,5,1),(459,282,'Trabajo y Exposiciones',10.00,6,1),(466,307,'Examen',50.00,1,1),(467,307,'Tareas',10.00,2,1),(468,307,'Participación',10.00,3,1),(469,307,'Evaluación Parcial',10.00,4,1),(470,307,'Proyecto',10.00,5,1),(471,307,'Trabajo y Exposiciones',10.00,6,1),(472,308,'Examen',50.00,1,1),(473,308,'Tareas',10.00,2,1),(474,308,'Participación',10.00,3,1),(475,308,'Evaluación Parcial',10.00,4,1),(476,308,'Proyecto',10.00,5,1),(477,308,'Trabajo y Exposiciones',10.00,6,1),(484,314,'Examen',50.00,1,1),(485,314,'Tareas',10.00,2,1),(486,314,'Participación',10.00,3,1),(487,314,'Evaluación Parcial',10.00,4,1),(488,314,'Proyecto',10.00,5,1),(489,314,'Trabajo y Exposiciones',10.00,6,1),(490,315,'Examen',50.00,1,1),(491,315,'Tareas',10.00,2,1),(492,315,'Participación',10.00,3,1),(493,315,'Evaluación Parcial',10.00,4,1),(494,315,'Proyecto',10.00,5,1),(495,315,'Trabajo y Exposiciones',10.00,6,1),(496,316,'Examen',50.00,1,1),(497,316,'Tareas',10.00,2,1),(498,316,'Participación',10.00,3,1),(499,316,'Evaluación Parcial',10.00,4,1),(500,316,'Proyecto',10.00,5,1),(501,316,'Trabajo y Exposiciones',10.00,6,1),(508,93,'Examen',50.00,1,1),(509,93,'Tareas',10.00,2,1),(510,93,'Participación',10.00,3,1),(511,93,'Evaluación Parcial',10.00,4,1),(512,93,'Proyecto',10.00,5,1),(513,93,'Trabajo y Exposiciones',10.00,6,1),(526,346,'Examen',50.00,1,1),(527,346,'Tareas',10.00,2,1),(528,346,'Participación',10.00,3,1),(529,346,'Evaluación Parcial',10.00,4,1),(530,346,'Proyecto',10.00,5,1),(531,346,'Trabajo y Exposiciones',10.00,6,1),(1084,113,'Examen',50.00,1,1),(1085,113,'Tareas',10.00,2,1),(1086,113,'Participación',10.00,3,1),(1087,113,'Proyecto',10.00,4,1),(1089,113,'Evaluación Parcial',10.00,5,1),(1090,113,'Trabajo y Exposiciones',10.00,6,1),(1091,266,'Examen',50.00,1,1),(1092,267,'Examen',50.00,1,1),(1094,266,'Tareas',10.00,2,1),(1095,267,'Tareas',10.00,2,1),(1097,266,'Participación',10.00,3,1),(1098,267,'Participación',10.00,3,1),(1100,266,'Evaluación Parcial',10.00,4,1),(1101,267,'Evaluación Parcial',10.00,4,1),(1103,266,'Proyecto',10.00,5,1),(1104,267,'Proyecto',10.00,5,1),(1106,266,'Trabajo y Exposiciones',10.00,6,1),(1107,267,'Trabajo y Exposiciones',10.00,6,1),(1109,148,'Examen',50.00,1,1),(1110,163,'Examen',50.00,1,1),(1111,200,'Examen',50.00,1,1),(1112,231,'Examen',50.00,1,1),(1113,150,'Examen',50.00,1,1),(1114,165,'Examen',50.00,1,1),(1115,201,'Examen',50.00,1,1),(1116,232,'Examen',50.00,1,1),(1117,94,'Examen',50.00,1,1),(1118,117,'Examen',50.00,1,1),(1119,151,'Examen',50.00,1,1),(1120,166,'Examen',50.00,1,1),(1121,203,'Examen',50.00,1,1),(1122,234,'Examen',50.00,1,1),(1123,98,'Examen',50.00,1,1),(1124,121,'Examen',50.00,1,1),(1125,204,'Examen',50.00,1,1),(1126,235,'Examen',50.00,1,1),(1127,99,'Examen',50.00,1,1),(1128,122,'Examen',50.00,1,1),(1129,154,'Examen',50.00,1,1),(1130,169,'Examen',50.00,1,1),(1131,205,'Examen',50.00,1,1),(1132,236,'Examen',50.00,1,1),(1133,100,'Examen',50.00,1,1),(1134,123,'Examen',50.00,1,1),(1135,155,'Examen',50.00,1,1),(1136,170,'Examen',50.00,1,1),(1137,206,'Examen',50.00,1,1),(1138,237,'Examen',50.00,1,1),(1139,101,'Examen',50.00,1,1),(1140,124,'Examen',50.00,1,1),(1141,156,'Examen',50.00,1,1),(1142,171,'Examen',50.00,1,1),(1143,207,'Examen',50.00,1,1),(1144,238,'Examen',50.00,1,1),(1145,102,'Examen',50.00,1,1),(1146,125,'Examen',50.00,1,1),(1147,157,'Examen',50.00,1,1),(1148,172,'Examen',50.00,1,1),(1149,208,'Examen',50.00,1,1),(1150,239,'Examen',50.00,1,1),(1151,103,'Examen',50.00,1,1),(1152,126,'Examen',50.00,1,1),(1153,158,'Examen',50.00,1,1),(1154,173,'Examen',50.00,1,1),(1155,209,'Examen',50.00,1,1),(1156,240,'Examen',50.00,1,1),(1159,104,'Examen',50.00,1,1),(1160,127,'Examen',50.00,1,1),(1161,159,'Examen',50.00,1,1),(1162,174,'Examen',50.00,1,1),(1163,210,'Examen',50.00,1,1),(1164,241,'Examen',50.00,1,1),(1165,105,'Examen',50.00,1,1),(1166,128,'Examen',50.00,1,1),(1167,211,'Examen',50.00,1,1),(1168,242,'Examen',50.00,1,1),(1169,106,'Examen',50.00,1,1),(1170,129,'Examen',50.00,1,1),(1172,148,'Tareas',10.00,2,1),(1173,163,'Tareas',10.00,2,1),(1174,200,'Tareas',10.00,2,1),(1175,231,'Tareas',10.00,2,1),(1176,150,'Tareas',10.00,2,1),(1177,165,'Tareas',10.00,2,1),(1178,201,'Tareas',10.00,2,1),(1179,232,'Tareas',10.00,2,1),(1180,94,'Tareas',10.00,2,1),(1181,117,'Tareas',10.00,2,1),(1182,151,'Tareas',10.00,2,1),(1183,166,'Tareas',10.00,2,1),(1184,203,'Tareas',10.00,2,1),(1185,234,'Tareas',10.00,2,1),(1186,98,'Tareas',10.00,2,1),(1187,121,'Tareas',10.00,2,1),(1188,204,'Tareas',10.00,2,1),(1189,235,'Tareas',10.00,2,1),(1190,99,'Tareas',10.00,2,1),(1191,122,'Tareas',10.00,2,1),(1192,154,'Tareas',10.00,2,1),(1193,169,'Tareas',10.00,2,1),(1194,205,'Tareas',10.00,2,1),(1195,236,'Tareas',10.00,2,1),(1196,100,'Tareas',10.00,2,1),(1197,123,'Tareas',10.00,2,1),(1198,155,'Tareas',10.00,2,1),(1199,170,'Tareas',10.00,2,1),(1200,206,'Tareas',10.00,2,1),(1201,237,'Tareas',10.00,2,1),(1202,101,'Tareas',10.00,2,1),(1203,124,'Tareas',10.00,2,1),(1204,156,'Tareas',10.00,2,1),(1205,171,'Tareas',10.00,2,1),(1206,207,'Tareas',10.00,2,1),(1207,238,'Tareas',10.00,2,1),(1208,102,'Tareas',10.00,2,1),(1209,125,'Tareas',10.00,2,1),(1210,157,'Tareas',10.00,2,1),(1211,172,'Tareas',10.00,2,1),(1212,208,'Tareas',10.00,2,1),(1213,239,'Tareas',10.00,2,1),(1214,103,'Tareas',10.00,2,1),(1215,126,'Tareas',10.00,2,1),(1216,158,'Tareas',10.00,2,1),(1217,173,'Tareas',10.00,2,1),(1218,209,'Tareas',10.00,2,1),(1219,240,'Tareas',10.00,2,1),(1222,104,'Tareas',10.00,2,1),(1223,127,'Tareas',10.00,2,1),(1224,159,'Tareas',10.00,2,1),(1225,174,'Tareas',10.00,2,1),(1226,210,'Tareas',10.00,2,1),(1227,241,'Tareas',10.00,2,1),(1228,105,'Tareas',10.00,2,1),(1229,128,'Tareas',10.00,2,1),(1230,211,'Tareas',10.00,2,1),(1231,242,'Tareas',10.00,2,1),(1232,106,'Tareas',10.00,2,1),(1233,129,'Tareas',10.00,2,1),(1235,148,'Participación',10.00,3,1),(1236,163,'Participación',10.00,3,1),(1237,200,'Participación',10.00,3,1),(1238,231,'Participación',10.00,3,1),(1239,150,'Participación',10.00,3,1),(1240,165,'Participación',10.00,3,1),(1241,201,'Participación',10.00,3,1),(1242,232,'Participación',10.00,3,1),(1243,94,'Participación',10.00,3,1),(1244,117,'Participación',10.00,3,1),(1245,151,'Participación',10.00,3,1),(1246,166,'Participación',10.00,3,1),(1247,203,'Participación',10.00,3,1),(1248,234,'Participación',10.00,3,1),(1249,98,'Participación',10.00,3,1),(1250,121,'Participación',10.00,3,1),(1251,204,'Participación',10.00,3,1),(1252,235,'Participación',10.00,3,1),(1253,99,'Participación',10.00,3,1),(1254,122,'Participación',10.00,3,1),(1255,154,'Participación',10.00,3,1),(1256,169,'Participación',10.00,3,1),(1257,205,'Participación',10.00,3,1),(1258,236,'Participación',10.00,3,1),(1259,100,'Participación',10.00,3,1),(1260,123,'Participación',10.00,3,1),(1261,155,'Participación',10.00,3,1),(1262,170,'Participación',10.00,3,1),(1263,206,'Participación',10.00,3,1),(1264,237,'Participación',10.00,3,1),(1265,101,'Participación',10.00,3,1),(1266,124,'Participación',10.00,3,1),(1267,156,'Participación',10.00,3,1),(1268,171,'Participación',10.00,3,1),(1269,207,'Participación',10.00,3,1),(1270,238,'Participación',10.00,3,1),(1271,102,'Participación',10.00,3,1),(1272,125,'Participación',10.00,3,1),(1273,157,'Participación',10.00,3,1),(1274,172,'Participación',10.00,3,1),(1275,208,'Participación',10.00,3,1),(1276,239,'Participación',10.00,3,1),(1277,103,'Participación',10.00,3,1),(1278,126,'Participación',10.00,3,1),(1279,158,'Participación',10.00,3,1),(1280,173,'Participación',10.00,3,1),(1281,209,'Participación',10.00,3,1),(1282,240,'Participación',10.00,3,1),(1283,104,'Participación',10.00,3,1),(1284,127,'Participación',10.00,3,1),(1285,159,'Participación',10.00,3,1),(1286,174,'Participación',10.00,3,1),(1287,210,'Participación',10.00,3,1),(1288,241,'Participación',10.00,3,1),(1289,105,'Participación',10.00,3,1),(1290,128,'Participación',10.00,3,1),(1291,211,'Participación',10.00,3,1),(1292,242,'Participación',10.00,3,1),(1293,106,'Participación',10.00,3,1),(1294,129,'Participación',10.00,3,1),(1298,148,'Evaluación Parcial',10.00,4,1),(1299,163,'Evaluación Parcial',10.00,4,1),(1300,200,'Evaluación Parcial',10.00,4,1),(1301,231,'Evaluación Parcial',10.00,4,1),(1302,150,'Evaluación Parcial',10.00,4,1),(1303,165,'Evaluación Parcial',10.00,4,1),(1304,201,'Evaluación Parcial',10.00,4,1),(1305,232,'Evaluación Parcial',10.00,4,1),(1306,94,'Evaluación Parcial',10.00,4,1),(1307,117,'Evaluación Parcial',10.00,4,1),(1308,151,'Evaluación Parcial',10.00,4,1),(1309,166,'Evaluación Parcial',10.00,4,1),(1310,203,'Evaluación Parcial',10.00,4,1),(1311,234,'Evaluación Parcial',10.00,4,1),(1312,98,'Evaluación Parcial',10.00,4,1),(1313,121,'Evaluación Parcial',10.00,4,1),(1314,204,'Evaluación Parcial',10.00,4,1),(1315,235,'Evaluación Parcial',10.00,4,1),(1316,99,'Evaluación Parcial',10.00,4,1),(1317,122,'Evaluación Parcial',10.00,4,1),(1318,154,'Evaluación Parcial',10.00,4,1),(1319,169,'Evaluación Parcial',10.00,4,1),(1320,205,'Evaluación Parcial',10.00,4,1),(1321,236,'Evaluación Parcial',10.00,4,1),(1322,100,'Evaluación Parcial',10.00,4,1),(1323,123,'Evaluación Parcial',10.00,4,1),(1324,155,'Evaluación Parcial',10.00,4,1),(1325,170,'Evaluación Parcial',10.00,4,1),(1326,206,'Evaluación Parcial',10.00,4,1),(1327,237,'Evaluación Parcial',10.00,4,1),(1328,101,'Evaluación Parcial',10.00,4,1),(1329,124,'Evaluación Parcial',10.00,4,1),(1330,156,'Evaluación Parcial',10.00,4,1),(1331,171,'Evaluación Parcial',10.00,4,1),(1332,207,'Evaluación Parcial',10.00,4,1),(1333,238,'Evaluación Parcial',10.00,4,1),(1334,102,'Evaluación Parcial',10.00,4,1),(1335,125,'Evaluación Parcial',10.00,4,1),(1336,157,'Evaluación Parcial',10.00,4,1),(1337,172,'Evaluación Parcial',10.00,4,1),(1338,208,'Evaluación Parcial',10.00,4,1),(1339,239,'Evaluación Parcial',10.00,4,1),(1340,103,'Evaluación Parcial',10.00,4,1),(1341,126,'Evaluación Parcial',10.00,4,1),(1342,158,'Evaluación Parcial',10.00,4,1),(1343,173,'Evaluación Parcial',10.00,4,1),(1344,209,'Evaluación Parcial',10.00,4,1),(1345,240,'Evaluación Parcial',10.00,4,1),(1348,104,'Evaluación Parcial',10.00,4,1),(1349,127,'Evaluación Parcial',10.00,4,1),(1350,159,'Evaluación Parcial',10.00,4,1),(1351,174,'Evaluación Parcial',10.00,4,1),(1352,210,'Evaluación Parcial',10.00,4,1),(1353,241,'Evaluación Parcial',10.00,4,1),(1354,105,'Evaluación Parcial',10.00,4,1),(1355,128,'Evaluación Parcial',10.00,4,1),(1356,211,'Evaluación Parcial',10.00,4,1),(1357,242,'Evaluación Parcial',10.00,4,1),(1358,106,'Evaluación Parcial',10.00,4,1),(1359,129,'Evaluación Parcial',10.00,4,1),(1361,148,'Proyecto',10.00,5,1),(1362,163,'Proyecto',10.00,5,1),(1363,200,'Proyecto',10.00,5,1),(1364,231,'Proyecto',10.00,5,1),(1365,150,'Proyecto',10.00,5,1),(1366,165,'Proyecto',10.00,5,1),(1367,201,'Proyecto',10.00,5,1),(1368,232,'Proyecto',10.00,5,1),(1369,94,'Proyecto',10.00,5,1),(1370,117,'Proyecto',10.00,5,1),(1371,151,'Proyecto',10.00,5,1),(1372,166,'Proyecto',10.00,5,1),(1373,203,'Proyecto',10.00,5,1),(1374,234,'Proyecto',10.00,5,1),(1375,98,'Proyecto',10.00,5,1),(1376,121,'Proyecto',10.00,5,1),(1377,204,'Proyecto',10.00,5,1),(1378,235,'Proyecto',10.00,5,1),(1379,99,'Proyecto',10.00,5,1),(1380,122,'Proyecto',10.00,5,1),(1381,154,'Proyecto',10.00,5,1),(1382,169,'Proyecto',10.00,5,1),(1383,205,'Proyecto',10.00,5,1),(1384,236,'Proyecto',10.00,5,1),(1385,100,'Proyecto',10.00,5,1),(1386,123,'Proyecto',10.00,5,1),(1387,155,'Proyecto',10.00,5,1),(1388,170,'Proyecto',10.00,5,1),(1389,206,'Proyecto',10.00,5,1),(1390,237,'Proyecto',10.00,5,1),(1391,101,'Proyecto',10.00,5,1),(1392,124,'Proyecto',10.00,5,1),(1393,156,'Proyecto',10.00,5,1),(1394,171,'Proyecto',10.00,5,1),(1395,207,'Proyecto',10.00,5,1),(1396,238,'Proyecto',10.00,5,1),(1397,102,'Proyecto',10.00,5,1),(1398,125,'Proyecto',10.00,5,1),(1399,157,'Proyecto',10.00,5,1),(1400,172,'Proyecto',10.00,5,1),(1401,208,'Proyecto',10.00,5,1),(1402,239,'Proyecto',10.00,5,1),(1403,103,'Proyecto',10.00,5,1),(1404,126,'Proyecto',10.00,5,1),(1405,158,'Proyecto',10.00,5,1),(1406,173,'Proyecto',10.00,5,1),(1407,209,'Proyecto',10.00,5,1),(1408,240,'Proyecto',10.00,5,1),(1411,104,'Proyecto',10.00,5,1),(1412,127,'Proyecto',10.00,5,1),(1413,159,'Proyecto',10.00,5,1),(1414,174,'Proyecto',10.00,5,1),(1415,210,'Proyecto',10.00,5,1),(1416,241,'Proyecto',10.00,5,1),(1417,105,'Proyecto',10.00,5,1),(1418,128,'Proyecto',10.00,5,1),(1419,211,'Proyecto',10.00,5,1),(1420,242,'Proyecto',10.00,5,1),(1421,106,'Proyecto',10.00,5,1),(1422,129,'Proyecto',10.00,5,1),(1424,148,'Trabajo y Exposiciones',10.00,6,1),(1425,163,'Trabajo y Exposiciones',10.00,6,1),(1426,200,'Trabajo y Exposiciones',10.00,6,1),(1427,231,'Trabajo y Exposiciones',10.00,6,1),(1428,150,'Trabajo y Exposiciones',10.00,6,1),(1429,165,'Trabajo y Exposiciones',10.00,6,1),(1430,201,'Trabajo y Exposiciones',10.00,6,1),(1431,232,'Trabajo y Exposiciones',10.00,6,1),(1432,94,'Trabajo y Exposiciones',10.00,6,1),(1433,117,'Trabajo y Exposiciones',10.00,6,1),(1434,151,'Trabajo y Exposiciones',10.00,6,1),(1435,166,'Trabajo y Exposiciones',10.00,6,1),(1436,203,'Trabajo y Exposiciones',10.00,6,1),(1437,234,'Trabajo y Exposiciones',10.00,6,1),(1438,98,'Trabajo y Exposiciones',10.00,6,1),(1439,121,'Trabajo y Exposiciones',10.00,6,1),(1440,204,'Trabajo y Exposiciones',10.00,6,1),(1441,235,'Trabajo y Exposiciones',10.00,6,1),(1442,99,'Trabajo y Exposiciones',10.00,6,1),(1443,122,'Trabajo y Exposiciones',10.00,6,1),(1444,154,'Trabajo y Exposiciones',10.00,6,1),(1445,169,'Trabajo y Exposiciones',10.00,6,1),(1446,205,'Trabajo y Exposiciones',10.00,6,1),(1447,236,'Trabajo y Exposiciones',10.00,6,1),(1448,100,'Trabajo y Exposiciones',10.00,6,1),(1449,123,'Trabajo y Exposiciones',10.00,6,1),(1450,155,'Trabajo y Exposiciones',10.00,6,1),(1451,170,'Trabajo y Exposiciones',10.00,6,1),(1452,206,'Trabajo y Exposiciones',10.00,6,1),(1453,237,'Trabajo y Exposiciones',10.00,6,1),(1454,101,'Trabajo y Exposiciones',10.00,6,1),(1455,124,'Trabajo y Exposiciones',10.00,6,1),(1456,156,'Trabajo y Exposiciones',10.00,6,1),(1457,171,'Trabajo y Exposiciones',10.00,6,1),(1458,207,'Trabajo y Exposiciones',10.00,6,1),(1459,238,'Trabajo y Exposiciones',10.00,6,1),(1460,102,'Trabajo y Exposiciones',10.00,6,1),(1461,125,'Trabajo y Exposiciones',10.00,6,1),(1462,157,'Trabajo y Exposiciones',10.00,6,1),(1463,172,'Trabajo y Exposiciones',10.00,6,1),(1464,208,'Trabajo y Exposiciones',10.00,6,1),(1465,239,'Trabajo y Exposiciones',10.00,6,1),(1466,103,'Trabajo y Exposiciones',10.00,6,1),(1467,126,'Trabajo y Exposiciones',10.00,6,1),(1468,158,'Trabajo y Exposiciones',10.00,6,1),(1469,173,'Trabajo y Exposiciones',10.00,6,1),(1470,209,'Trabajo y Exposiciones',10.00,6,1),(1471,240,'Trabajo y Exposiciones',10.00,6,1),(1474,104,'Trabajo y Exposiciones',10.00,6,1),(1475,127,'Trabajo y Exposiciones',10.00,6,1),(1476,159,'Trabajo y Exposiciones',10.00,6,1),(1477,174,'Trabajo y Exposiciones',10.00,6,1),(1478,210,'Trabajo y Exposiciones',10.00,6,1),(1479,241,'Trabajo y Exposiciones',10.00,6,1),(1480,105,'Trabajo y Exposiciones',10.00,6,1),(1481,128,'Trabajo y Exposiciones',10.00,6,1),(1482,211,'Trabajo y Exposiciones',10.00,6,1),(1483,242,'Trabajo y Exposiciones',10.00,6,1),(1484,106,'Trabajo y Exposiciones',10.00,6,1),(1485,129,'Trabajo y Exposiciones',10.00,6,1),(1487,305,'Examen',50.00,1,1),(1488,305,'Tareas',10.00,2,1),(1489,305,'Participación',10.00,3,1),(1490,305,'Evaluación Parcial',10.00,4,1),(1491,305,'Proyecto',10.00,5,1),(1492,305,'Trabajo y Exposiciones',10.00,6,1),(1493,306,'Examen',50.00,1,1),(1494,306,'Tareas',10.00,2,1),(1495,306,'Participación',10.00,3,1),(1496,306,'Evaluación Parcial',10.00,4,1),(1497,306,'Proyecto',10.00,5,1),(1498,306,'Trabajo y Exposiciones',10.00,6,1),(1499,416,'Examen',50.00,1,1),(1500,310,'Examen',50.00,1,1),(1501,311,'Examen',50.00,1,1),(1502,312,'Examen',50.00,1,1),(1503,418,'Examen',50.00,1,1),(1504,419,'Examen',50.00,1,1),(1505,420,'Examen',50.00,1,1),(1506,421,'Examen',50.00,1,1),(1507,422,'Examen',50.00,1,1),(1508,423,'Examen',50.00,1,1),(1509,424,'Examen',50.00,1,1),(1510,425,'Examen',50.00,1,1),(1511,426,'Examen',50.00,1,1),(1512,427,'Examen',50.00,1,1),(1513,428,'Examen',50.00,1,1),(1514,429,'Examen',50.00,1,1),(1515,430,'Examen',50.00,1,1),(1516,431,'Examen',50.00,1,1),(1517,432,'Examen',50.00,1,1),(1518,433,'Examen',50.00,1,1),(1519,434,'Examen',50.00,1,1),(1520,435,'Examen',50.00,1,1),(1521,436,'Examen',50.00,1,1),(1522,437,'Examen',50.00,1,1),(1523,438,'Examen',50.00,1,1),(1524,439,'Examen',50.00,1,1),(1525,440,'Examen',50.00,1,1),(1526,441,'Examen',50.00,1,1),(1527,442,'Examen',50.00,1,1),(1528,443,'Examen',50.00,1,1),(1529,444,'Examen',50.00,1,1),(1530,445,'Examen',50.00,1,1),(1562,416,'Tareas',10.00,2,1),(1563,310,'Tareas',10.00,2,1),(1564,311,'Tareas',10.00,2,1),(1565,312,'Tareas',10.00,2,1),(1566,418,'Tareas',10.00,2,1),(1567,419,'Tareas',10.00,2,1),(1568,420,'Tareas',10.00,2,1),(1569,421,'Tareas',10.00,2,1),(1570,422,'Tareas',10.00,2,1),(1571,423,'Tareas',10.00,2,1),(1572,424,'Tareas',10.00,2,1),(1573,425,'Tareas',10.00,2,1),(1574,426,'Tareas',10.00,2,1),(1575,427,'Tareas',10.00,2,1),(1576,428,'Tareas',10.00,2,1),(1577,429,'Tareas',10.00,2,1),(1578,430,'Tareas',10.00,2,1),(1579,431,'Tareas',10.00,2,1),(1580,432,'Tareas',10.00,2,1),(1581,433,'Tareas',10.00,2,1),(1582,434,'Tareas',10.00,2,1),(1583,435,'Tareas',10.00,2,1),(1584,436,'Tareas',10.00,2,1),(1585,437,'Tareas',10.00,2,1),(1586,438,'Tareas',10.00,2,1),(1587,439,'Tareas',10.00,2,1),(1588,440,'Tareas',10.00,2,1),(1589,441,'Tareas',10.00,2,1),(1590,442,'Tareas',10.00,2,1),(1591,443,'Tareas',10.00,2,1),(1592,444,'Tareas',10.00,2,1),(1593,445,'Tareas',10.00,2,1),(1625,416,'Participación',10.00,3,1),(1626,310,'Participación',10.00,3,1),(1627,311,'Participación',10.00,3,1),(1628,312,'Participación',10.00,3,1),(1629,418,'Participación',10.00,3,1),(1630,419,'Participación',10.00,3,1),(1631,420,'Participación',10.00,3,1),(1632,421,'Participación',10.00,3,1),(1633,422,'Participación',10.00,3,1),(1634,423,'Participación',10.00,3,1),(1635,424,'Participación',10.00,3,1),(1636,425,'Participación',10.00,3,1),(1637,426,'Participación',10.00,3,1),(1638,427,'Participación',10.00,3,1),(1639,428,'Participación',10.00,3,1),(1640,429,'Participación',10.00,3,1),(1641,430,'Participación',10.00,3,1),(1642,431,'Participación',10.00,3,1),(1643,432,'Participación',10.00,3,1),(1644,433,'Participación',10.00,3,1),(1645,434,'Participación',10.00,3,1),(1646,435,'Participación',10.00,3,1),(1647,436,'Participación',10.00,3,1),(1648,437,'Participación',10.00,3,1),(1649,438,'Participación',10.00,3,1),(1650,439,'Participación',10.00,3,1),(1651,440,'Participación',10.00,3,1),(1652,441,'Participación',10.00,3,1),(1653,442,'Participación',10.00,3,1),(1654,443,'Participación',10.00,3,1),(1655,444,'Participación',10.00,3,1),(1656,445,'Participación',10.00,3,1),(1688,416,'Evaluación Parcial',10.00,4,1),(1689,310,'Evaluación Parcial',10.00,4,1),(1690,311,'Evaluación Parcial',10.00,4,1),(1691,312,'Evaluación Parcial',10.00,4,1),(1692,418,'Evaluación Parcial',10.00,4,1),(1693,419,'Evaluación Parcial',10.00,4,1),(1694,420,'Evaluación Parcial',10.00,4,1),(1695,421,'Evaluación Parcial',10.00,4,1),(1696,422,'Evaluación Parcial',10.00,4,1),(1697,423,'Evaluación Parcial',10.00,4,1),(1698,424,'Evaluación Parcial',10.00,4,1),(1699,425,'Evaluación Parcial',10.00,4,1),(1700,426,'Evaluación Parcial',10.00,4,1),(1701,427,'Evaluación Parcial',10.00,4,1),(1702,428,'Evaluación Parcial',10.00,4,1),(1703,429,'Evaluación Parcial',10.00,4,1),(1704,430,'Evaluación Parcial',10.00,4,1),(1705,431,'Evaluación Parcial',10.00,4,1),(1706,432,'Evaluación Parcial',10.00,4,1),(1707,433,'Evaluación Parcial',10.00,4,1),(1708,434,'Evaluación Parcial',10.00,4,1),(1709,435,'Evaluación Parcial',10.00,4,1),(1710,436,'Evaluación Parcial',10.00,4,1),(1711,437,'Evaluación Parcial',10.00,4,1),(1712,438,'Evaluación Parcial',10.00,4,1),(1713,439,'Evaluación Parcial',10.00,4,1),(1714,440,'Evaluación Parcial',10.00,4,1),(1715,441,'Evaluación Parcial',10.00,4,1),(1716,442,'Evaluación Parcial',10.00,4,1),(1717,443,'Evaluación Parcial',10.00,4,1),(1718,444,'Evaluación Parcial',10.00,4,1),(1719,445,'Evaluación Parcial',10.00,4,1),(1751,416,'Proyecto',10.00,5,1),(1752,310,'Proyecto',10.00,5,1),(1753,311,'Proyecto',10.00,5,1),(1754,312,'Proyecto',10.00,5,1),(1755,418,'Proyecto',10.00,5,1),(1756,419,'Proyecto',10.00,5,1),(1757,420,'Proyecto',10.00,5,1),(1758,421,'Proyecto',10.00,5,1),(1759,422,'Proyecto',10.00,5,1),(1760,423,'Proyecto',10.00,5,1),(1761,424,'Proyecto',10.00,5,1),(1762,425,'Proyecto',10.00,5,1),(1763,426,'Proyecto',10.00,5,1),(1764,427,'Proyecto',10.00,5,1),(1765,428,'Proyecto',10.00,5,1),(1766,429,'Proyecto',10.00,5,1),(1767,430,'Proyecto',10.00,5,1),(1768,431,'Proyecto',10.00,5,1),(1769,432,'Proyecto',10.00,5,1),(1770,433,'Proyecto',10.00,5,1),(1771,434,'Proyecto',10.00,5,1),(1772,435,'Proyecto',10.00,5,1),(1773,436,'Proyecto',10.00,5,1),(1774,437,'Proyecto',10.00,5,1),(1775,438,'Proyecto',10.00,5,1),(1776,439,'Proyecto',10.00,5,1),(1777,440,'Proyecto',10.00,5,1),(1778,441,'Proyecto',10.00,5,1),(1779,442,'Proyecto',10.00,5,1),(1780,443,'Proyecto',10.00,5,1),(1781,444,'Proyecto',10.00,5,1),(1782,445,'Proyecto',10.00,5,1),(1814,416,'Trabajo y Exposiciones',10.00,6,1),(1815,310,'Trabajo y Exposiciones',10.00,6,1),(1816,311,'Trabajo y Exposiciones',10.00,6,1),(1817,312,'Trabajo y Exposiciones',10.00,6,1),(1818,418,'Trabajo y Exposiciones',10.00,6,1),(1819,419,'Trabajo y Exposiciones',10.00,6,1),(1820,420,'Trabajo y Exposiciones',10.00,6,1),(1821,421,'Trabajo y Exposiciones',10.00,6,1),(1822,422,'Trabajo y Exposiciones',10.00,6,1),(1823,423,'Trabajo y Exposiciones',10.00,6,1),(1824,424,'Trabajo y Exposiciones',10.00,6,1),(1825,425,'Trabajo y Exposiciones',10.00,6,1),(1826,426,'Trabajo y Exposiciones',10.00,6,1),(1827,427,'Trabajo y Exposiciones',10.00,6,1),(1828,428,'Trabajo y Exposiciones',10.00,6,1),(1829,429,'Trabajo y Exposiciones',10.00,6,1),(1830,430,'Trabajo y Exposiciones',10.00,6,1),(1831,431,'Trabajo y Exposiciones',10.00,6,1),(1832,432,'Trabajo y Exposiciones',10.00,6,1),(1833,433,'Trabajo y Exposiciones',10.00,6,1),(1834,434,'Trabajo y Exposiciones',10.00,6,1),(1835,435,'Trabajo y Exposiciones',10.00,6,1),(1836,436,'Trabajo y Exposiciones',10.00,6,1),(1837,437,'Trabajo y Exposiciones',10.00,6,1),(1838,438,'Trabajo y Exposiciones',10.00,6,1),(1839,439,'Trabajo y Exposiciones',10.00,6,1),(1840,440,'Trabajo y Exposiciones',10.00,6,1),(1841,441,'Trabajo y Exposiciones',10.00,6,1),(1842,442,'Trabajo y Exposiciones',10.00,6,1),(1843,443,'Trabajo y Exposiciones',10.00,6,1),(1844,444,'Trabajo y Exposiciones',10.00,6,1),(1845,445,'Trabajo y Exposiciones',10.00,6,1),(1877,202,'Examen',50.00,1,1),(1878,233,'Examen',50.00,1,1),(1879,455,'Examen',50.00,1,1),(1880,456,'Examen',50.00,1,1),(1881,465,'Examen',50.00,1,1),(1882,466,'Examen',50.00,1,1),(1883,467,'Examen',50.00,1,1),(1884,468,'Examen',50.00,1,1),(1885,477,'Examen',50.00,1,1),(1886,478,'Examen',50.00,1,1),(1887,479,'Examen',50.00,1,1),(1888,480,'Examen',50.00,1,1),(1889,489,'Examen',50.00,1,1),(1890,490,'Examen',50.00,1,1),(1891,491,'Examen',50.00,1,1),(1892,492,'Examen',50.00,1,1),(1893,501,'Examen',50.00,1,1),(1894,502,'Examen',50.00,1,1),(1895,503,'Examen',50.00,1,1),(1896,504,'Examen',50.00,1,1),(1897,202,'Tareas',10.00,2,1),(1898,233,'Tareas',10.00,2,1),(1899,455,'Tareas',10.00,2,1),(1900,456,'Tareas',10.00,2,1),(1901,465,'Tareas',10.00,2,1),(1902,466,'Tareas',10.00,2,1),(1903,467,'Tareas',10.00,2,1),(1904,468,'Tareas',10.00,2,1),(1905,477,'Tareas',10.00,2,1),(1906,478,'Tareas',10.00,2,1),(1907,479,'Tareas',10.00,2,1),(1908,480,'Tareas',10.00,2,1),(1909,489,'Tareas',10.00,2,1),(1910,490,'Tareas',10.00,2,1),(1911,491,'Tareas',10.00,2,1),(1912,492,'Tareas',10.00,2,1),(1913,501,'Tareas',10.00,2,1),(1914,502,'Tareas',10.00,2,1),(1915,503,'Tareas',10.00,2,1),(1916,504,'Tareas',10.00,2,1),(1917,202,'Participación',10.00,3,1),(1918,233,'Participación',10.00,3,1),(1919,455,'Participación',10.00,3,1),(1920,456,'Participación',10.00,3,1),(1921,465,'Participación',10.00,3,1),(1922,466,'Participación',10.00,3,1),(1923,467,'Participación',10.00,3,1),(1924,468,'Participación',10.00,3,1),(1925,477,'Participación',10.00,3,1),(1926,478,'Participación',10.00,3,1),(1927,479,'Participación',10.00,3,1),(1928,480,'Participación',10.00,3,1),(1929,489,'Participación',10.00,3,1),(1930,490,'Participación',10.00,3,1),(1931,491,'Participación',10.00,3,1),(1932,492,'Participación',10.00,3,1),(1933,501,'Participación',10.00,3,1),(1934,502,'Participación',10.00,3,1),(1935,503,'Participación',10.00,3,1),(1936,504,'Participación',10.00,3,1),(1937,202,'Evaluación Parcial',10.00,4,1),(1938,233,'Evaluación Parcial',10.00,4,1),(1939,455,'Evaluación Parcial',10.00,4,1),(1940,456,'Evaluación Parcial',10.00,4,1),(1941,465,'Evaluación Parcial',10.00,4,1),(1942,466,'Evaluación Parcial',10.00,4,1),(1943,467,'Evaluación Parcial',10.00,4,1),(1944,468,'Evaluación Parcial',10.00,4,1),(1945,477,'Evaluación Parcial',10.00,4,1),(1946,478,'Evaluación Parcial',10.00,4,1),(1947,479,'Evaluación Parcial',10.00,4,1),(1948,480,'Evaluación Parcial',10.00,4,1),(1949,489,'Evaluación Parcial',10.00,4,1),(1950,490,'Evaluación Parcial',10.00,4,1),(1951,491,'Evaluación Parcial',10.00,4,1),(1952,492,'Evaluación Parcial',10.00,4,1),(1953,501,'Evaluación Parcial',10.00,4,1),(1954,502,'Evaluación Parcial',10.00,4,1),(1955,503,'Evaluación Parcial',10.00,4,1),(1956,504,'Evaluación Parcial',10.00,4,1),(1957,202,'Proyecto',10.00,5,1),(1958,233,'Proyecto',10.00,5,1),(1959,455,'Proyecto',10.00,5,1),(1960,456,'Proyecto',10.00,5,1),(1961,465,'Proyecto',10.00,5,1),(1962,466,'Proyecto',10.00,5,1),(1963,467,'Proyecto',10.00,5,1),(1964,468,'Proyecto',10.00,5,1),(1965,477,'Proyecto',10.00,5,1),(1966,478,'Proyecto',10.00,5,1),(1967,479,'Proyecto',10.00,5,1),(1968,480,'Proyecto',10.00,5,1),(1969,489,'Proyecto',10.00,5,1),(1970,490,'Proyecto',10.00,5,1),(1971,491,'Proyecto',10.00,5,1),(1972,492,'Proyecto',10.00,5,1),(1973,501,'Proyecto',10.00,5,1),(1974,502,'Proyecto',10.00,5,1),(1975,503,'Proyecto',10.00,5,1),(1976,504,'Proyecto',10.00,5,1),(1977,202,'Trabajo y Exposiciones',10.00,6,1),(1978,233,'Trabajo y Exposiciones',10.00,6,1),(1979,455,'Trabajo y Exposiciones',10.00,6,1),(1980,456,'Trabajo y Exposiciones',10.00,6,1),(1981,465,'Trabajo y Exposiciones',10.00,6,1),(1982,466,'Trabajo y Exposiciones',10.00,6,1),(1983,467,'Trabajo y Exposiciones',10.00,6,1),(1984,468,'Trabajo y Exposiciones',10.00,6,1),(1985,477,'Trabajo y Exposiciones',10.00,6,1),(1986,478,'Trabajo y Exposiciones',10.00,6,1),(1987,479,'Trabajo y Exposiciones',10.00,6,1),(1988,480,'Trabajo y Exposiciones',10.00,6,1),(1989,489,'Trabajo y Exposiciones',10.00,6,1),(1990,490,'Trabajo y Exposiciones',10.00,6,1),(1991,491,'Trabajo y Exposiciones',10.00,6,1),(1992,492,'Trabajo y Exposiciones',10.00,6,1),(1993,501,'Trabajo y Exposiciones',10.00,6,1),(1994,502,'Trabajo y Exposiciones',10.00,6,1),(1995,503,'Trabajo y Exposiciones',10.00,6,1),(1996,504,'Trabajo y Exposiciones',10.00,6,1),(1997,447,'Examen',50.00,1,1),(1998,448,'Examen',50.00,1,1),(1999,449,'Examen',50.00,1,1),(2000,450,'Examen',50.00,1,1),(2001,457,'Examen',50.00,1,1),(2002,458,'Examen',50.00,1,1),(2003,459,'Examen',50.00,1,1),(2004,460,'Examen',50.00,1,1),(2005,469,'Examen',50.00,1,1),(2006,470,'Examen',50.00,1,1),(2007,471,'Examen',50.00,1,1),(2008,472,'Examen',50.00,1,1),(2009,481,'Examen',50.00,1,1),(2010,482,'Examen',50.00,1,1),(2011,483,'Examen',50.00,1,1),(2012,484,'Examen',50.00,1,1),(2013,493,'Examen',50.00,1,1),(2014,494,'Examen',50.00,1,1),(2015,495,'Examen',50.00,1,1),(2016,496,'Examen',50.00,1,1),(2017,505,'Examen',50.00,1,1),(2018,506,'Examen',50.00,1,1),(2019,507,'Examen',50.00,1,1),(2020,508,'Examen',50.00,1,1),(2021,513,'Examen',50.00,1,1),(2022,514,'Examen',50.00,1,1),(2023,515,'Examen',50.00,1,1),(2024,516,'Examen',50.00,1,1),(2025,521,'Examen',50.00,1,1),(2026,522,'Examen',50.00,1,1),(2027,523,'Examen',50.00,1,1),(2028,524,'Examen',50.00,1,1),(2029,529,'Examen',50.00,1,1),(2030,530,'Examen',50.00,1,1),(2031,531,'Examen',50.00,1,1),(2032,532,'Examen',50.00,1,1),(2033,447,'Tareas',10.00,2,1),(2034,448,'Tareas',10.00,2,1),(2035,449,'Tareas',10.00,2,1),(2036,450,'Tareas',10.00,2,1),(2037,457,'Tareas',10.00,2,1),(2038,458,'Tareas',10.00,2,1),(2039,459,'Tareas',10.00,2,1),(2040,460,'Tareas',10.00,2,1),(2041,469,'Tareas',10.00,2,1),(2042,470,'Tareas',10.00,2,1),(2043,471,'Tareas',10.00,2,1),(2044,472,'Tareas',10.00,2,1),(2045,481,'Tareas',10.00,2,1),(2046,482,'Tareas',10.00,2,1),(2047,483,'Tareas',10.00,2,1),(2048,484,'Tareas',10.00,2,1),(2049,493,'Tareas',10.00,2,1),(2050,494,'Tareas',10.00,2,1),(2051,495,'Tareas',10.00,2,1),(2052,496,'Tareas',10.00,2,1),(2053,505,'Tareas',10.00,2,1),(2054,506,'Tareas',10.00,2,1),(2055,507,'Tareas',10.00,2,1),(2056,508,'Tareas',10.00,2,1),(2057,513,'Tareas',10.00,2,1),(2058,514,'Tareas',10.00,2,1),(2059,515,'Tareas',10.00,2,1),(2060,516,'Tareas',10.00,2,1),(2061,521,'Tareas',10.00,2,1),(2062,522,'Tareas',10.00,2,1),(2063,523,'Tareas',10.00,2,1),(2064,524,'Tareas',10.00,2,1),(2065,529,'Tareas',10.00,2,1),(2066,530,'Tareas',10.00,2,1),(2067,531,'Tareas',10.00,2,1),(2068,532,'Tareas',10.00,2,1),(2069,447,'Participación',10.00,3,1),(2070,448,'Participación',10.00,3,1),(2071,449,'Participación',10.00,3,1),(2072,450,'Participación',10.00,3,1),(2073,457,'Participación',10.00,3,1),(2074,458,'Participación',10.00,3,1),(2075,459,'Participación',10.00,3,1),(2076,460,'Participación',10.00,3,1),(2077,469,'Participación',10.00,3,1),(2078,470,'Participación',10.00,3,1),(2079,471,'Participación',10.00,3,1),(2080,472,'Participación',10.00,3,1),(2081,481,'Participación',10.00,3,1),(2082,482,'Participación',10.00,3,1),(2083,483,'Participación',10.00,3,1),(2084,484,'Participación',10.00,3,1),(2085,493,'Participación',10.00,3,1),(2086,494,'Participación',10.00,3,1),(2087,495,'Participación',10.00,3,1),(2088,496,'Participación',10.00,3,1),(2089,505,'Participación',10.00,3,1),(2090,506,'Participación',10.00,3,1),(2091,507,'Participación',10.00,3,1),(2092,508,'Participación',10.00,3,1),(2093,513,'Participación',10.00,3,1),(2094,514,'Participación',10.00,3,1),(2095,515,'Participación',10.00,3,1),(2096,516,'Participación',10.00,3,1),(2097,521,'Participación',10.00,3,1),(2098,522,'Participación',10.00,3,1),(2099,523,'Participación',10.00,3,1),(2100,524,'Participación',10.00,3,1),(2101,529,'Participación',10.00,3,1),(2102,530,'Participación',10.00,3,1),(2103,531,'Participación',10.00,3,1),(2104,532,'Participación',10.00,3,1),(2105,447,'Evaluación Parcial',10.00,4,1),(2106,448,'Evaluación Parcial',10.00,4,1),(2107,449,'Evaluación Parcial',10.00,4,1),(2108,450,'Evaluación Parcial',10.00,4,1),(2109,457,'Evaluación Parcial',10.00,4,1),(2110,458,'Evaluación Parcial',10.00,4,1),(2111,459,'Evaluación Parcial',10.00,4,1),(2112,460,'Evaluación Parcial',10.00,4,1),(2113,469,'Evaluación Parcial',10.00,4,1),(2114,470,'Evaluación Parcial',10.00,4,1),(2115,471,'Evaluación Parcial',10.00,4,1),(2116,472,'Evaluación Parcial',10.00,4,1),(2117,481,'Evaluación Parcial',10.00,4,1),(2118,482,'Evaluación Parcial',10.00,4,1),(2119,483,'Evaluación Parcial',10.00,4,1),(2120,484,'Evaluación Parcial',10.00,4,1),(2121,493,'Evaluación Parcial',10.00,4,1),(2122,494,'Evaluación Parcial',10.00,4,1),(2123,495,'Evaluación Parcial',10.00,4,1),(2124,496,'Evaluación Parcial',10.00,4,1),(2125,505,'Evaluación Parcial',10.00,4,1),(2126,506,'Evaluación Parcial',10.00,4,1),(2127,507,'Evaluación Parcial',10.00,4,1),(2128,508,'Evaluación Parcial',10.00,4,1),(2129,513,'Evaluación Parcial',10.00,4,1),(2130,514,'Evaluación Parcial',10.00,4,1),(2131,515,'Evaluación Parcial',10.00,4,1),(2132,516,'Evaluación Parcial',10.00,4,1),(2133,521,'Evaluación Parcial',10.00,4,1),(2134,522,'Evaluación Parcial',10.00,4,1),(2135,523,'Evaluación Parcial',10.00,4,1),(2136,524,'Evaluación Parcial',10.00,4,1),(2137,529,'Evaluación Parcial',10.00,4,1),(2138,530,'Evaluación Parcial',10.00,4,1),(2139,531,'Evaluación Parcial',10.00,4,1),(2140,532,'Evaluación Parcial',10.00,4,1),(2141,447,'Proyecto',10.00,5,1),(2142,448,'Proyecto',10.00,5,1),(2143,449,'Proyecto',10.00,5,1),(2144,450,'Proyecto',10.00,5,1),(2145,457,'Proyecto',10.00,5,1),(2146,458,'Proyecto',10.00,5,1),(2147,459,'Proyecto',10.00,5,1),(2148,460,'Proyecto',10.00,5,1),(2149,469,'Proyecto',10.00,5,1),(2150,470,'Proyecto',10.00,5,1),(2151,471,'Proyecto',10.00,5,1),(2152,472,'Proyecto',10.00,5,1),(2153,481,'Proyecto',10.00,5,1),(2154,482,'Proyecto',10.00,5,1),(2155,483,'Proyecto',10.00,5,1),(2156,484,'Proyecto',10.00,5,1),(2157,493,'Proyecto',10.00,5,1),(2158,494,'Proyecto',10.00,5,1),(2159,495,'Proyecto',10.00,5,1),(2160,496,'Proyecto',10.00,5,1),(2161,505,'Proyecto',10.00,5,1),(2162,506,'Proyecto',10.00,5,1),(2163,507,'Proyecto',10.00,5,1),(2164,508,'Proyecto',10.00,5,1),(2165,513,'Proyecto',10.00,5,1),(2166,514,'Proyecto',10.00,5,1),(2167,515,'Proyecto',10.00,5,1),(2168,516,'Proyecto',10.00,5,1),(2169,521,'Proyecto',10.00,5,1),(2170,522,'Proyecto',10.00,5,1),(2171,523,'Proyecto',10.00,5,1),(2172,524,'Proyecto',10.00,5,1),(2173,529,'Proyecto',10.00,5,1),(2174,530,'Proyecto',10.00,5,1),(2175,531,'Proyecto',10.00,5,1),(2176,532,'Proyecto',10.00,5,1),(2177,447,'Trabajo y Exposiciones',10.00,6,1),(2178,448,'Trabajo y Exposiciones',10.00,6,1),(2179,449,'Trabajo y Exposiciones',10.00,6,1),(2180,450,'Trabajo y Exposiciones',10.00,6,1),(2181,457,'Trabajo y Exposiciones',10.00,6,1),(2182,458,'Trabajo y Exposiciones',10.00,6,1),(2183,459,'Trabajo y Exposiciones',10.00,6,1),(2184,460,'Trabajo y Exposiciones',10.00,6,1),(2185,469,'Trabajo y Exposiciones',10.00,6,1),(2186,470,'Trabajo y Exposiciones',10.00,6,1),(2187,471,'Trabajo y Exposiciones',10.00,6,1),(2188,472,'Trabajo y Exposiciones',10.00,6,1),(2189,481,'Trabajo y Exposiciones',10.00,6,1),(2190,482,'Trabajo y Exposiciones',10.00,6,1),(2191,483,'Trabajo y Exposiciones',10.00,6,1),(2192,484,'Trabajo y Exposiciones',10.00,6,1),(2193,493,'Trabajo y Exposiciones',10.00,6,1),(2194,494,'Trabajo y Exposiciones',10.00,6,1),(2195,495,'Trabajo y Exposiciones',10.00,6,1),(2196,496,'Trabajo y Exposiciones',10.00,6,1),(2197,505,'Trabajo y Exposiciones',10.00,6,1),(2198,506,'Trabajo y Exposiciones',10.00,6,1),(2199,507,'Trabajo y Exposiciones',10.00,6,1),(2200,508,'Trabajo y Exposiciones',10.00,6,1),(2201,513,'Trabajo y Exposiciones',10.00,6,1),(2202,514,'Trabajo y Exposiciones',10.00,6,1),(2203,515,'Trabajo y Exposiciones',10.00,6,1),(2204,516,'Trabajo y Exposiciones',10.00,6,1),(2205,521,'Trabajo y Exposiciones',10.00,6,1),(2206,522,'Trabajo y Exposiciones',10.00,6,1),(2207,523,'Trabajo y Exposiciones',10.00,6,1),(2208,524,'Trabajo y Exposiciones',10.00,6,1),(2209,529,'Trabajo y Exposiciones',10.00,6,1),(2210,530,'Trabajo y Exposiciones',10.00,6,1),(2211,531,'Trabajo y Exposiciones',10.00,6,1),(2212,532,'Trabajo y Exposiciones',10.00,6,1),(2213,451,'Examen',50.00,1,1),(2214,452,'Examen',50.00,1,1),(2215,453,'Examen',50.00,1,1),(2216,454,'Examen',50.00,1,1),(2217,461,'Examen',50.00,1,1),(2218,462,'Examen',50.00,1,1),(2219,463,'Examen',50.00,1,1),(2220,464,'Examen',50.00,1,1),(2221,473,'Examen',50.00,1,1),(2222,474,'Examen',50.00,1,1),(2223,475,'Examen',50.00,1,1),(2224,476,'Examen',50.00,1,1),(2225,485,'Examen',50.00,1,1),(2226,486,'Examen',50.00,1,1),(2227,487,'Examen',50.00,1,1),(2228,488,'Examen',50.00,1,1),(2229,451,'Tareas',10.00,2,1),(2230,452,'Tareas',10.00,2,1),(2231,453,'Tareas',10.00,2,1),(2232,454,'Tareas',10.00,2,1),(2233,461,'Tareas',10.00,2,1),(2234,462,'Tareas',10.00,2,1),(2235,463,'Tareas',10.00,2,1),(2236,464,'Tareas',10.00,2,1),(2237,473,'Tareas',10.00,2,1),(2238,474,'Tareas',10.00,2,1),(2239,475,'Tareas',10.00,2,1),(2240,476,'Tareas',10.00,2,1),(2241,485,'Tareas',10.00,2,1),(2242,486,'Tareas',10.00,2,1),(2243,487,'Tareas',10.00,2,1),(2244,488,'Tareas',10.00,2,1),(2245,451,'Participación',10.00,3,1),(2246,452,'Participación',10.00,3,1),(2247,453,'Participación',10.00,3,1),(2248,454,'Participación',10.00,3,1),(2249,461,'Participación',10.00,3,1),(2250,462,'Participación',10.00,3,1),(2251,463,'Participación',10.00,3,1),(2252,464,'Participación',10.00,3,1),(2253,473,'Participación',10.00,3,1),(2254,474,'Participación',10.00,3,1),(2255,475,'Participación',10.00,3,1),(2256,476,'Participación',10.00,3,1),(2257,485,'Participación',10.00,3,1),(2258,486,'Participación',10.00,3,1),(2259,487,'Participación',10.00,3,1),(2260,488,'Participación',10.00,3,1),(2261,451,'Evaluación Parcial',10.00,4,1),(2262,452,'Evaluación Parcial',10.00,4,1),(2263,453,'Evaluación Parcial',10.00,4,1),(2264,454,'Evaluación Parcial',10.00,4,1),(2265,461,'Evaluación Parcial',10.00,4,1),(2266,462,'Evaluación Parcial',10.00,4,1),(2267,463,'Evaluación Parcial',10.00,4,1),(2268,464,'Evaluación Parcial',10.00,4,1),(2269,473,'Evaluación Parcial',10.00,4,1),(2270,474,'Evaluación Parcial',10.00,4,1),(2271,475,'Evaluación Parcial',10.00,4,1),(2272,476,'Evaluación Parcial',10.00,4,1),(2273,485,'Evaluación Parcial',10.00,4,1),(2274,486,'Evaluación Parcial',10.00,4,1),(2275,487,'Evaluación Parcial',10.00,4,1),(2276,488,'Evaluación Parcial',10.00,4,1),(2277,451,'Proyecto',10.00,5,1),(2278,452,'Proyecto',10.00,5,1),(2279,453,'Proyecto',10.00,5,1),(2280,454,'Proyecto',10.00,5,1),(2281,461,'Proyecto',10.00,5,1),(2282,462,'Proyecto',10.00,5,1),(2283,463,'Proyecto',10.00,5,1),(2284,464,'Proyecto',10.00,5,1),(2285,473,'Proyecto',10.00,5,1),(2286,474,'Proyecto',10.00,5,1),(2287,475,'Proyecto',10.00,5,1),(2288,476,'Proyecto',10.00,5,1),(2289,485,'Proyecto',10.00,5,1),(2290,486,'Proyecto',10.00,5,1),(2291,487,'Proyecto',10.00,5,1),(2292,488,'Proyecto',10.00,5,1),(2293,451,'Trabajo y Exposiciones',10.00,6,1),(2294,452,'Trabajo y Exposiciones',10.00,6,1),(2295,453,'Trabajo y Exposiciones',10.00,6,1),(2296,454,'Trabajo y Exposiciones',10.00,6,1),(2297,461,'Trabajo y Exposiciones',10.00,6,1),(2298,462,'Trabajo y Exposiciones',10.00,6,1),(2299,463,'Trabajo y Exposiciones',10.00,6,1),(2300,464,'Trabajo y Exposiciones',10.00,6,1),(2301,473,'Trabajo y Exposiciones',10.00,6,1),(2302,474,'Trabajo y Exposiciones',10.00,6,1),(2303,475,'Trabajo y Exposiciones',10.00,6,1),(2304,476,'Trabajo y Exposiciones',10.00,6,1),(2305,485,'Trabajo y Exposiciones',10.00,6,1),(2306,486,'Trabajo y Exposiciones',10.00,6,1),(2307,487,'Trabajo y Exposiciones',10.00,6,1),(2308,488,'Trabajo y Exposiciones',10.00,6,1),(2309,497,'Examen',50.00,1,1),(2310,498,'Examen',50.00,1,1),(2311,499,'Examen',50.00,1,1),(2312,500,'Examen',50.00,1,1),(2313,509,'Examen',50.00,1,1),(2314,510,'Examen',50.00,1,1),(2315,511,'Examen',50.00,1,1),(2316,512,'Examen',50.00,1,1),(2317,517,'Examen',50.00,1,1),(2318,518,'Examen',50.00,1,1),(2319,519,'Examen',50.00,1,1),(2320,520,'Examen',50.00,1,1),(2321,525,'Examen',50.00,1,1),(2322,526,'Examen',50.00,1,1),(2323,527,'Examen',50.00,1,1),(2324,528,'Examen',50.00,1,1),(2325,533,'Examen',50.00,1,1),(2326,534,'Examen',50.00,1,1),(2327,535,'Examen',50.00,1,1),(2328,536,'Examen',50.00,1,1),(2329,497,'Tareas',10.00,2,1),(2330,498,'Tareas',10.00,2,1),(2331,499,'Tareas',10.00,2,1),(2332,500,'Tareas',10.00,2,1),(2333,509,'Tareas',10.00,2,1),(2334,510,'Tareas',10.00,2,1),(2335,511,'Tareas',10.00,2,1),(2336,512,'Tareas',10.00,2,1),(2337,517,'Tareas',10.00,2,1),(2338,518,'Tareas',10.00,2,1),(2339,519,'Tareas',10.00,2,1),(2340,520,'Tareas',10.00,2,1),(2341,525,'Tareas',10.00,2,1),(2342,526,'Tareas',10.00,2,1),(2343,527,'Tareas',10.00,2,1),(2344,528,'Tareas',10.00,2,1),(2345,533,'Tareas',10.00,2,1),(2346,534,'Tareas',10.00,2,1),(2347,535,'Tareas',10.00,2,1),(2348,536,'Tareas',10.00,2,1),(2349,497,'Participación',10.00,3,1),(2350,498,'Participación',10.00,3,1),(2351,499,'Participación',10.00,3,1),(2352,500,'Participación',10.00,3,1),(2353,509,'Participación',10.00,3,1),(2354,510,'Participación',10.00,3,1),(2355,511,'Participación',10.00,3,1),(2356,512,'Participación',10.00,3,1),(2357,517,'Participación',10.00,3,1),(2358,518,'Participación',10.00,3,1),(2359,519,'Participación',10.00,3,1),(2360,520,'Participación',10.00,3,1),(2361,525,'Participación',10.00,3,1),(2362,526,'Participación',10.00,3,1),(2363,527,'Participación',10.00,3,1),(2364,528,'Participación',10.00,3,1),(2365,533,'Participación',10.00,3,1),(2366,534,'Participación',10.00,3,1),(2367,535,'Participación',10.00,3,1),(2368,536,'Participación',10.00,3,1),(2369,497,'Evaluación Parcial',10.00,4,1),(2370,498,'Evaluación Parcial',10.00,4,1),(2371,499,'Evaluación Parcial',10.00,4,1),(2372,500,'Evaluación Parcial',10.00,4,1),(2373,509,'Evaluación Parcial',10.00,4,1),(2374,510,'Evaluación Parcial',10.00,4,1),(2375,511,'Evaluación Parcial',10.00,4,1),(2376,512,'Evaluación Parcial',10.00,4,1),(2377,517,'Evaluación Parcial',10.00,4,1),(2378,518,'Evaluación Parcial',10.00,4,1),(2379,519,'Evaluación Parcial',10.00,4,1),(2380,520,'Evaluación Parcial',10.00,4,1),(2381,525,'Evaluación Parcial',10.00,4,1),(2382,526,'Evaluación Parcial',10.00,4,1),(2383,527,'Evaluación Parcial',10.00,4,1),(2384,528,'Evaluación Parcial',10.00,4,1),(2385,533,'Evaluación Parcial',10.00,4,1),(2386,534,'Evaluación Parcial',10.00,4,1),(2387,535,'Evaluación Parcial',10.00,4,1),(2388,536,'Evaluación Parcial',10.00,4,1),(2389,497,'Proyecto',10.00,5,1),(2390,498,'Proyecto',10.00,5,1),(2391,499,'Proyecto',10.00,5,1),(2392,500,'Proyecto',10.00,5,1),(2393,509,'Proyecto',10.00,5,1),(2394,510,'Proyecto',10.00,5,1),(2395,511,'Proyecto',10.00,5,1),(2396,512,'Proyecto',10.00,5,1),(2397,517,'Proyecto',10.00,5,1),(2398,518,'Proyecto',10.00,5,1),(2399,519,'Proyecto',10.00,5,1),(2400,520,'Proyecto',10.00,5,1),(2401,525,'Proyecto',10.00,5,1),(2402,526,'Proyecto',10.00,5,1),(2403,527,'Proyecto',10.00,5,1),(2404,528,'Proyecto',10.00,5,1),(2405,533,'Proyecto',10.00,5,1),(2406,534,'Proyecto',10.00,5,1),(2407,535,'Proyecto',10.00,5,1),(2408,536,'Proyecto',10.00,5,1),(2409,497,'Trabajo y Exposiciones',10.00,6,1),(2410,498,'Trabajo y Exposiciones',10.00,6,1),(2411,499,'Trabajo y Exposiciones',10.00,6,1),(2412,500,'Trabajo y Exposiciones',10.00,6,1),(2413,509,'Trabajo y Exposiciones',10.00,6,1),(2414,510,'Trabajo y Exposiciones',10.00,6,1),(2415,511,'Trabajo y Exposiciones',10.00,6,1),(2416,512,'Trabajo y Exposiciones',10.00,6,1),(2417,517,'Trabajo y Exposiciones',10.00,6,1),(2418,518,'Trabajo y Exposiciones',10.00,6,1),(2419,519,'Trabajo y Exposiciones',10.00,6,1),(2420,520,'Trabajo y Exposiciones',10.00,6,1),(2421,525,'Trabajo y Exposiciones',10.00,6,1),(2422,526,'Trabajo y Exposiciones',10.00,6,1),(2423,527,'Trabajo y Exposiciones',10.00,6,1),(2424,528,'Trabajo y Exposiciones',10.00,6,1),(2425,533,'Trabajo y Exposiciones',10.00,6,1),(2426,534,'Trabajo y Exposiciones',10.00,6,1),(2427,535,'Trabajo y Exposiciones',10.00,6,1),(2428,536,'Trabajo y Exposiciones',10.00,6,1),(2453,541,'Examen',50.00,1,1),(2454,542,'Examen',50.00,1,1),(2455,543,'Examen',50.00,1,1),(2456,544,'Examen',50.00,1,1),(2457,545,'Examen',50.00,1,1),(2458,546,'Examen',50.00,1,1),(2459,547,'Examen',50.00,1,1),(2460,548,'Examen',50.00,1,1),(2461,549,'Examen',50.00,1,1),(2462,550,'Examen',50.00,1,1),(2463,551,'Examen',50.00,1,1),(2464,552,'Examen',50.00,1,1),(2465,553,'Examen',50.00,1,1),(2466,554,'Examen',50.00,1,1),(2467,555,'Examen',50.00,1,1),(2468,556,'Examen',50.00,1,1),(2469,557,'Examen',50.00,1,1),(2470,558,'Examen',50.00,1,1),(2471,559,'Examen',50.00,1,1),(2472,560,'Examen',50.00,1,1),(2473,561,'Examen',50.00,1,1),(2474,562,'Examen',50.00,1,1),(2475,563,'Examen',50.00,1,1),(2476,564,'Examen',50.00,1,1),(2484,541,'Tareas',10.00,2,1),(2485,542,'Tareas',10.00,2,1),(2486,543,'Tareas',10.00,2,1),(2487,544,'Tareas',10.00,2,1),(2488,545,'Tareas',10.00,2,1),(2489,546,'Tareas',10.00,2,1),(2490,547,'Tareas',10.00,2,1),(2491,548,'Tareas',10.00,2,1),(2492,549,'Tareas',10.00,2,1),(2493,550,'Tareas',10.00,2,1),(2494,551,'Tareas',10.00,2,1),(2495,552,'Tareas',10.00,2,1),(2496,553,'Tareas',10.00,2,1),(2497,554,'Tareas',10.00,2,1),(2498,555,'Tareas',10.00,2,1),(2499,556,'Tareas',10.00,2,1),(2500,557,'Tareas',10.00,2,1),(2501,558,'Tareas',10.00,2,1),(2502,559,'Tareas',10.00,2,1),(2503,560,'Tareas',10.00,2,1),(2504,561,'Tareas',10.00,2,1),(2505,562,'Tareas',10.00,2,1),(2506,563,'Tareas',10.00,2,1),(2507,564,'Tareas',10.00,2,1),(2515,541,'Participación',10.00,3,1),(2516,542,'Participación',10.00,3,1),(2517,543,'Participación',10.00,3,1),(2518,544,'Participación',10.00,3,1),(2519,545,'Participación',10.00,3,1),(2520,546,'Participación',10.00,3,1),(2521,547,'Participación',10.00,3,1),(2522,548,'Participación',10.00,3,1),(2523,549,'Participación',10.00,3,1),(2524,550,'Participación',10.00,3,1),(2525,551,'Participación',10.00,3,1),(2526,552,'Participación',10.00,3,1),(2527,553,'Participación',10.00,3,1),(2528,554,'Participación',10.00,3,1),(2529,555,'Participación',10.00,3,1),(2530,556,'Participación',10.00,3,1),(2531,557,'Participación',10.00,3,1),(2532,558,'Participación',10.00,3,1),(2533,559,'Participación',10.00,3,1),(2534,560,'Participación',10.00,3,1),(2535,561,'Participación',10.00,3,1),(2536,562,'Participación',10.00,3,1),(2537,563,'Participación',10.00,3,1),(2538,564,'Participación',10.00,3,1),(2546,541,'Evaluación Parcial',10.00,4,1),(2547,542,'Evaluación Parcial',10.00,4,1),(2548,543,'Evaluación Parcial',10.00,4,1),(2549,544,'Evaluación Parcial',10.00,4,1),(2550,545,'Evaluación Parcial',10.00,4,1),(2551,546,'Evaluación Parcial',10.00,4,1),(2552,547,'Evaluación Parcial',10.00,4,1),(2553,548,'Evaluación Parcial',10.00,4,1),(2554,549,'Evaluación Parcial',10.00,4,1),(2555,550,'Evaluación Parcial',10.00,4,1),(2556,551,'Evaluación Parcial',10.00,4,1),(2557,552,'Evaluación Parcial',10.00,4,1),(2558,553,'Evaluación Parcial',10.00,4,1),(2559,554,'Evaluación Parcial',10.00,4,1),(2560,555,'Evaluación Parcial',10.00,4,1),(2561,556,'Evaluación Parcial',10.00,4,1),(2562,557,'Evaluación Parcial',10.00,4,1),(2563,558,'Evaluación Parcial',10.00,4,1),(2564,559,'Evaluación Parcial',10.00,4,1),(2565,560,'Evaluación Parcial',10.00,4,1),(2566,561,'Evaluación Parcial',10.00,4,1),(2567,562,'Evaluación Parcial',10.00,4,1),(2568,563,'Evaluación Parcial',10.00,4,1),(2569,564,'Evaluación Parcial',10.00,4,1),(2577,541,'Proyecto',10.00,5,1),(2578,542,'Proyecto',10.00,5,1),(2579,543,'Proyecto',10.00,5,1),(2580,544,'Proyecto',10.00,5,1),(2581,545,'Proyecto',10.00,5,1),(2582,546,'Proyecto',10.00,5,1),(2583,547,'Proyecto',10.00,5,1),(2584,548,'Proyecto',10.00,5,1),(2585,549,'Proyecto',10.00,5,1),(2586,550,'Proyecto',10.00,5,1),(2587,551,'Proyecto',10.00,5,1),(2588,552,'Proyecto',10.00,5,1),(2589,553,'Proyecto',10.00,5,1),(2590,554,'Proyecto',10.00,5,1),(2591,555,'Proyecto',10.00,5,1),(2592,556,'Proyecto',10.00,5,1),(2593,557,'Proyecto',10.00,5,1),(2594,558,'Proyecto',10.00,5,1),(2595,559,'Proyecto',10.00,5,1),(2596,560,'Proyecto',10.00,5,1),(2597,561,'Proyecto',10.00,5,1),(2598,562,'Proyecto',10.00,5,1),(2599,563,'Proyecto',10.00,5,1),(2600,564,'Proyecto',10.00,5,1),(2608,541,'Trabajo y Exposiciones',10.00,6,1),(2609,542,'Trabajo y Exposiciones',10.00,6,1),(2610,543,'Trabajo y Exposiciones',10.00,6,1),(2611,544,'Trabajo y Exposiciones',10.00,6,1),(2612,545,'Trabajo y Exposiciones',10.00,6,1),(2613,546,'Trabajo y Exposiciones',10.00,6,1),(2614,547,'Trabajo y Exposiciones',10.00,6,1),(2615,548,'Trabajo y Exposiciones',10.00,6,1),(2616,549,'Trabajo y Exposiciones',10.00,6,1),(2617,550,'Trabajo y Exposiciones',10.00,6,1),(2618,551,'Trabajo y Exposiciones',10.00,6,1),(2619,552,'Trabajo y Exposiciones',10.00,6,1),(2620,553,'Trabajo y Exposiciones',10.00,6,1),(2621,554,'Trabajo y Exposiciones',10.00,6,1),(2622,555,'Trabajo y Exposiciones',10.00,6,1),(2623,556,'Trabajo y Exposiciones',10.00,6,1),(2624,557,'Trabajo y Exposiciones',10.00,6,1),(2625,558,'Trabajo y Exposiciones',10.00,6,1),(2626,559,'Trabajo y Exposiciones',10.00,6,1),(2627,560,'Trabajo y Exposiciones',10.00,6,1),(2628,561,'Trabajo y Exposiciones',10.00,6,1),(2629,562,'Trabajo y Exposiciones',10.00,6,1),(2630,563,'Trabajo y Exposiciones',10.00,6,1),(2631,564,'Trabajo y Exposiciones',10.00,6,1);
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
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignacion_disciplina_aspectos`
--

LOCK TABLES `asignacion_disciplina_aspectos` WRITE;
/*!40000 ALTER TABLE `asignacion_disciplina_aspectos` DISABLE KEYS */;
INSERT INTO `asignacion_disciplina_aspectos` VALUES (1,NULL,1,'primaria','Examen',50.00,1,1),(2,NULL,1,'primaria','Tareas',10.00,2,1),(3,NULL,1,'primaria','Participación',10.00,3,1),(4,NULL,1,'primaria','Evaluación Parcial',10.00,4,1),(5,NULL,1,'primaria','Proyecto',10.00,5,1),(6,NULL,1,'primaria','Trabajo y Exposiciones',10.00,6,1),(7,NULL,1,'primaria','Promedio',0.00,7,1),(8,86,1,'primaria','Examen',50.00,1,1),(9,88,1,'primaria','Examen',50.00,1,1),(10,266,1,'primaria','Examen',50.00,1,1),(11,267,1,'primaria','Examen',50.00,1,1),(15,86,1,'primaria','Tareas',10.00,2,1),(16,88,1,'primaria','Tareas',10.00,2,1),(17,266,1,'primaria','Tareas',10.00,2,1),(18,267,1,'primaria','Tareas',10.00,2,1),(22,86,1,'primaria','Participación',10.00,3,1),(23,88,1,'primaria','Participación',10.00,3,1),(24,266,1,'primaria','Participación',10.00,3,1),(25,267,1,'primaria','Participación',10.00,3,1),(29,86,1,'primaria','Evaluación Parcial',10.00,4,1),(30,88,1,'primaria','Evaluación Parcial',10.00,4,1),(31,266,1,'primaria','Evaluación Parcial',10.00,4,1),(32,267,1,'primaria','Evaluación Parcial',10.00,4,1),(36,86,1,'primaria','Proyecto',10.00,5,1),(37,88,1,'primaria','Proyecto',10.00,5,1),(38,266,1,'primaria','Proyecto',10.00,5,1),(39,267,1,'primaria','Proyecto',10.00,5,1),(43,86,1,'primaria','Trabajo y Exposiciones',10.00,6,1),(44,88,1,'primaria','Trabajo y Exposiciones',10.00,6,1),(45,266,1,'primaria','Trabajo y Exposiciones',10.00,6,1),(46,267,1,'primaria','Trabajo y Exposiciones',10.00,6,1);
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
INSERT INTO `asignacion_ingles_aspectos` VALUES (169,NULL,1,'primaria','Listening',0.00,0,1),(170,NULL,1,'primaria','Speaking',0.00,0,1),(171,NULL,1,'primaria','Reading',0.00,0,1),(172,NULL,1,'primaria','Writing',0.00,0,1),(173,NULL,1,'primaria','Vocabulary',0.00,0,1),(174,NULL,1,'primaria','Grammar',0.00,0,1),(175,NULL,1,'primaria','Spelling',0.00,0,1),(176,NULL,1,'primaria','Science',0.00,0,1),(177,44,1,'primaria','Listening',0.00,0,1),(178,44,1,'primaria','Speaking',0.00,0,1),(179,44,1,'primaria','Reading',0.00,0,1),(180,44,1,'primaria','Writing',0.00,0,1),(181,44,1,'primaria','Vocabulary',0.00,0,1),(182,44,1,'primaria','Grammar',0.00,0,1),(183,44,1,'primaria','Spelling',0.00,0,1),(184,44,1,'primaria','Science',0.00,0,1),(193,NULL,1,'primaria','Listening',0.00,0,1),(194,NULL,1,'primaria','Speaking',0.00,0,1),(195,NULL,1,'primaria','Reading',0.00,0,1),(196,NULL,1,'primaria','Writing',0.00,0,1),(197,NULL,1,'primaria','Vocabulary',0.00,0,1),(198,NULL,1,'primaria','Grammar',0.00,0,1),(199,NULL,1,'primaria','Spelling',0.00,0,1),(200,NULL,1,'primaria','Science',0.00,0,1),(201,NULL,1,'primaria','Listening',0.00,0,1),(202,NULL,1,'primaria','Speaking',0.00,0,1),(203,NULL,1,'primaria','Reading',0.00,0,1),(204,NULL,1,'primaria','Writing',0.00,0,1),(205,NULL,1,'primaria','Vocabulary',0.00,0,1),(206,NULL,1,'primaria','Grammar',0.00,0,1),(207,NULL,1,'primaria','Spelling',0.00,0,1),(208,NULL,1,'primaria','Phonetics',0.00,0,1),(209,NULL,1,'primaria','Science',0.00,0,1),(210,NULL,2,'primaria','Listening',0.00,0,1),(211,NULL,2,'primaria','Speaking',0.00,0,1),(212,NULL,2,'primaria','Reading',0.00,0,1),(213,NULL,2,'primaria','Writing',0.00,0,1),(214,NULL,2,'primaria','Vocabulary',0.00,0,1),(215,NULL,2,'primaria','Grammar',0.00,0,1),(216,NULL,2,'primaria','Spelling',0.00,0,1),(217,NULL,2,'primaria','Phonetics',0.00,0,1),(218,NULL,2,'primaria','Science',0.00,0,1),(219,NULL,3,'primaria','Listening',0.00,0,1),(220,NULL,3,'primaria','Speaking',0.00,0,1),(221,NULL,3,'primaria','Reading',0.00,0,1),(222,NULL,3,'primaria','Writing',0.00,0,1),(223,NULL,3,'primaria','Vocabulary',0.00,0,1),(224,NULL,3,'primaria','Grammar',0.00,0,1),(225,NULL,3,'primaria','Spelling',0.00,0,1),(226,NULL,3,'primaria','Phonetics',0.00,0,1),(227,NULL,3,'primaria','Science',0.00,0,1),(228,NULL,4,'primaria','Listening',0.00,0,1),(229,NULL,4,'primaria','Speaking',0.00,0,1),(230,NULL,4,'primaria','Reading',0.00,0,1),(231,NULL,4,'primaria','Writing',0.00,0,1),(232,NULL,4,'primaria','Vocabulary',0.00,0,1),(233,NULL,4,'primaria','Grammar',0.00,0,1),(234,NULL,4,'primaria','Spelling',0.00,0,1),(235,NULL,4,'primaria','Phonetics',0.00,0,1),(236,NULL,4,'primaria','Science',0.00,0,1),(237,NULL,5,'primaria','Listening',0.00,0,1),(238,NULL,5,'primaria','Speaking',0.00,0,1),(239,NULL,5,'primaria','Reading',0.00,0,1),(240,NULL,5,'primaria','Writing',0.00,0,1),(241,NULL,5,'primaria','Vocabulary',0.00,0,1),(242,NULL,5,'primaria','Grammar',0.00,0,1),(243,NULL,5,'primaria','Spelling',0.00,0,1),(244,NULL,5,'primaria','Phonetics',0.00,0,1),(245,NULL,5,'primaria','Science',0.00,0,1),(246,NULL,5,'primaria','Social Studies',0.00,0,1),(247,NULL,5,'primaria','Literature',0.00,0,1),(248,NULL,6,'primaria','Listening',0.00,0,1),(249,NULL,6,'primaria','Speaking',0.00,0,1),(250,NULL,6,'primaria','Reading',0.00,0,1),(251,NULL,6,'primaria','Writing',0.00,0,1),(252,NULL,6,'primaria','Vocabulary',0.00,0,1),(253,NULL,6,'primaria','Grammar',0.00,0,1),(254,NULL,6,'primaria','Spelling',0.00,0,1),(255,NULL,6,'primaria','Phonetics',0.00,0,1),(256,NULL,6,'primaria','Science',0.00,0,1),(257,NULL,6,'primaria','Social Studies',0.00,0,1),(258,NULL,6,'primaria','Literature',0.00,0,1),(259,NULL,1,'secundaria','Listening',0.00,0,1),(260,NULL,1,'secundaria','Speaking',0.00,0,1),(261,NULL,1,'secundaria','Reading',0.00,0,1),(262,NULL,1,'secundaria','Writing',0.00,0,1),(263,NULL,1,'secundaria','Vocabulary',0.00,0,1),(264,NULL,1,'secundaria','Grammar',0.00,0,1),(265,NULL,1,'secundaria','Spelling',0.00,0,1),(266,NULL,1,'secundaria','Phonetics',0.00,0,1),(267,NULL,1,'secundaria','Science',0.00,0,1),(268,NULL,1,'secundaria','Social Studies',0.00,0,1),(269,NULL,1,'secundaria','Literature',0.00,0,1),(270,NULL,2,'secundaria','Listening',0.00,0,1),(271,NULL,2,'secundaria','Speaking',0.00,0,1),(272,NULL,2,'secundaria','Reading',0.00,0,1),(273,NULL,2,'secundaria','Writing',0.00,0,1),(274,NULL,2,'secundaria','Vocabulary',0.00,0,1),(275,NULL,2,'secundaria','Grammar',0.00,0,1),(276,NULL,2,'secundaria','Spelling',0.00,0,1),(277,NULL,2,'secundaria','Phonetics',0.00,0,1),(278,NULL,2,'secundaria','Science',0.00,0,1),(279,NULL,2,'secundaria','Social Studies',0.00,0,1),(280,NULL,2,'secundaria','Literature',0.00,0,1),(281,NULL,3,'secundaria','Listening',0.00,0,1),(282,NULL,3,'secundaria','Speaking',0.00,0,1),(283,NULL,3,'secundaria','Reading',0.00,0,1),(284,NULL,3,'secundaria','Writing',0.00,0,1),(285,NULL,3,'secundaria','Vocabulary',0.00,0,1),(286,NULL,3,'secundaria','Grammar',0.00,0,1),(287,NULL,3,'secundaria','Spelling',0.00,0,1),(288,NULL,3,'secundaria','Phonetics',0.00,0,1),(289,NULL,3,'secundaria','Science',0.00,0,1),(290,NULL,3,'secundaria','Social Studies',0.00,0,1),(291,NULL,3,'secundaria','Literature',0.00,0,1),(292,NULL,1,'primaria','Listening',0.00,0,1),(293,NULL,1,'primaria','Speaking',0.00,0,1),(294,NULL,1,'primaria','Reading',0.00,0,1),(295,NULL,1,'primaria','Writing',0.00,0,1),(296,NULL,1,'primaria','Vocabulary',0.00,0,1),(297,NULL,1,'primaria','Grammar',0.00,0,1),(298,NULL,1,'primaria','Spelling',0.00,0,1),(299,NULL,1,'primaria','Phonetics',0.00,0,1),(300,NULL,1,'primaria','Science',0.00,0,1),(301,NULL,2,'primaria','Listening',0.00,0,1),(302,NULL,2,'primaria','Speaking',0.00,0,1),(303,NULL,2,'primaria','Reading',0.00,0,1),(304,NULL,2,'primaria','Writing',0.00,0,1),(305,NULL,2,'primaria','Vocabulary',0.00,0,1),(306,NULL,2,'primaria','Grammar',0.00,0,1),(307,NULL,2,'primaria','Spelling',0.00,0,1),(308,NULL,2,'primaria','Phonetics',0.00,0,1),(309,NULL,2,'primaria','Science',0.00,0,1),(310,NULL,3,'primaria','Listening',0.00,0,1),(311,NULL,3,'primaria','Speaking',0.00,0,1),(312,NULL,3,'primaria','Reading',0.00,0,1),(313,NULL,3,'primaria','Writing',0.00,0,1),(314,NULL,3,'primaria','Vocabulary',0.00,0,1),(315,NULL,3,'primaria','Grammar',0.00,0,1),(316,NULL,3,'primaria','Spelling',0.00,0,1),(317,NULL,3,'primaria','Phonetics',0.00,0,1),(318,NULL,3,'primaria','Science',0.00,0,1),(319,NULL,4,'primaria','Listening',0.00,0,1),(320,NULL,4,'primaria','Speaking',0.00,0,1),(321,NULL,4,'primaria','Reading',0.00,0,1),(322,NULL,4,'primaria','Writing',0.00,0,1),(323,NULL,4,'primaria','Vocabulary',0.00,0,1),(324,NULL,4,'primaria','Grammar',0.00,0,1),(325,NULL,4,'primaria','Spelling',0.00,0,1),(326,NULL,4,'primaria','Phonetics',0.00,0,1),(327,NULL,4,'primaria','Science',0.00,0,1),(328,NULL,5,'primaria','Listening',0.00,0,1),(329,NULL,5,'primaria','Speaking',0.00,0,1),(330,NULL,5,'primaria','Reading',0.00,0,1),(331,NULL,5,'primaria','Writing',0.00,0,1),(332,NULL,5,'primaria','Vocabulary',0.00,0,1),(333,NULL,5,'primaria','Grammar',0.00,0,1),(334,NULL,5,'primaria','Spelling',0.00,0,1),(335,NULL,5,'primaria','Phonetics',0.00,0,1),(336,NULL,5,'primaria','Science',0.00,0,1),(337,NULL,5,'primaria','Social Studies',0.00,0,1),(338,NULL,5,'primaria','Literature',0.00,0,1),(339,NULL,6,'primaria','Listening',0.00,0,1),(340,NULL,6,'primaria','Speaking',0.00,0,1),(341,NULL,6,'primaria','Reading',0.00,0,1),(342,NULL,6,'primaria','Writing',0.00,0,1),(343,NULL,6,'primaria','Vocabulary',0.00,0,1),(344,NULL,6,'primaria','Grammar',0.00,0,1),(345,NULL,6,'primaria','Spelling',0.00,0,1),(346,NULL,6,'primaria','Phonetics',0.00,0,1),(347,NULL,6,'primaria','Science',0.00,0,1),(348,NULL,6,'primaria','Social Studies',0.00,0,1),(349,NULL,6,'primaria','Literature',0.00,0,1),(350,NULL,1,'secundaria','Listening',0.00,0,1),(351,NULL,1,'secundaria','Speaking',0.00,0,1),(352,NULL,1,'secundaria','Reading',0.00,0,1),(353,NULL,1,'secundaria','Writing',0.00,0,1),(354,NULL,1,'secundaria','Vocabulary',0.00,0,1),(355,NULL,1,'secundaria','Grammar',0.00,0,1),(356,NULL,1,'secundaria','Spelling',0.00,0,1),(357,NULL,1,'secundaria','Phonetics',0.00,0,1),(358,NULL,1,'secundaria','Science',0.00,0,1),(359,NULL,1,'secundaria','Social Studies',0.00,0,1),(360,NULL,1,'secundaria','Literature',0.00,0,1),(361,NULL,2,'secundaria','Listening',0.00,0,1),(362,NULL,2,'secundaria','Speaking',0.00,0,1),(363,NULL,2,'secundaria','Reading',0.00,0,1),(364,NULL,2,'secundaria','Writing',0.00,0,1),(365,NULL,2,'secundaria','Vocabulary',0.00,0,1),(366,NULL,2,'secundaria','Grammar',0.00,0,1),(367,NULL,2,'secundaria','Spelling',0.00,0,1),(368,NULL,2,'secundaria','Phonetics',0.00,0,1),(369,NULL,2,'secundaria','Science',0.00,0,1),(370,NULL,2,'secundaria','Social Studies',0.00,0,1),(371,NULL,2,'secundaria','Literature',0.00,0,1),(372,NULL,3,'secundaria','Listening',0.00,0,1),(373,NULL,3,'secundaria','Speaking',0.00,0,1),(374,NULL,3,'secundaria','Reading',0.00,0,1),(375,NULL,3,'secundaria','Writing',0.00,0,1),(376,NULL,3,'secundaria','Vocabulary',0.00,0,1),(377,NULL,3,'secundaria','Grammar',0.00,0,1),(378,NULL,3,'secundaria','Spelling',0.00,0,1),(379,NULL,3,'secundaria','Phonetics',0.00,0,1),(380,NULL,3,'secundaria','Science',0.00,0,1),(381,NULL,3,'secundaria','Social Studies',0.00,0,1),(382,NULL,3,'secundaria','Literature',0.00,0,1),(383,149,2,'primaria','Listening',0.00,1,1),(384,149,2,'primaria','Speaking',0.00,2,1),(385,149,2,'primaria','Writing',0.00,3,1),(386,149,2,'primaria','Reading',0.00,4,1),(387,149,2,'primaria','Vocabulary',0.00,5,1),(388,149,2,'primaria','Grammar',0.00,6,1),(389,149,2,'primaria','Spelling',0.00,7,1),(390,149,2,'primaria','Science',0.00,8,1),(391,164,2,'primaria','Listening',0.00,1,1),(392,164,2,'primaria','Speaking',0.00,2,1),(393,164,2,'primaria','Writing',0.00,3,1),(394,164,2,'primaria','Reading',0.00,4,1),(395,164,2,'primaria','Vocabulary',0.00,5,1),(396,164,2,'primaria','Grammar',0.00,6,1),(397,164,2,'primaria','Spelling',0.00,7,1),(398,164,2,'primaria','Science',0.00,8,1),(399,123,1,'primaria','Grammar',50.00,1,1),(400,123,1,'primaria','Speaking',20.00,2,1),(401,123,1,'primaria','Listening',10.00,3,1),(402,123,1,'primaria','Reading',10.00,4,1),(403,123,1,'primaria','Writing',10.00,5,1);
/*!40000 ALTER TABLE `asignacion_ingles_aspectos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `asignacion_ingles_maestros`
--

DROP TABLE IF EXISTS `asignacion_ingles_maestros`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `asignacion_ingles_maestros` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `asignacion_id` int(10) unsigned NOT NULL,
  `subcomponente_id` int(10) unsigned NOT NULL,
  `profesor_id` int(10) unsigned NOT NULL,
  `es_titular` tinyint(1) DEFAULT 0,
  `orden` tinyint(3) unsigned DEFAULT 0,
  `activo` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_ing_maestro` (`asignacion_id`,`subcomponente_id`,`profesor_id`),
  KEY `subcomponente_id` (`subcomponente_id`),
  KEY `profesor_id` (`profesor_id`),
  CONSTRAINT `asignacion_ingles_maestros_ibfk_1` FOREIGN KEY (`asignacion_id`) REFERENCES `asignaciones` (`id`) ON DELETE CASCADE,
  CONSTRAINT `asignacion_ingles_maestros_ibfk_2` FOREIGN KEY (`subcomponente_id`) REFERENCES `ingles_subcomponentes` (`id`),
  CONSTRAINT `asignacion_ingles_maestros_ibfk_3` FOREIGN KEY (`profesor_id`) REFERENCES `profesores` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignacion_ingles_maestros`
--

LOCK TABLES `asignacion_ingles_maestros` WRITE;
/*!40000 ALTER TABLE `asignacion_ingles_maestros` DISABLE KEYS */;
/*!40000 ALTER TABLE `asignacion_ingles_maestros` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `asignacion_ingles_sub_aspectos`
--

DROP TABLE IF EXISTS `asignacion_ingles_sub_aspectos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `asignacion_ingles_sub_aspectos` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `asignacion_id` int(10) unsigned NOT NULL,
  `subcomponente_id` int(10) unsigned NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `porcentaje` decimal(5,2) NOT NULL DEFAULT 0.00,
  `orden` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_ing_sub_asp` (`asignacion_id`,`subcomponente_id`,`nombre`),
  KEY `fk_ingsubasp_sub` (`subcomponente_id`),
  CONSTRAINT `fk_ingsubasp_asig` FOREIGN KEY (`asignacion_id`) REFERENCES `asignaciones` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ingsubasp_sub` FOREIGN KEY (`subcomponente_id`) REFERENCES `ingles_subcomponentes` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignacion_ingles_sub_aspectos`
--

LOCK TABLES `asignacion_ingles_sub_aspectos` WRITE;
/*!40000 ALTER TABLE `asignacion_ingles_sub_aspectos` DISABLE KEYS */;
/*!40000 ALTER TABLE `asignacion_ingles_sub_aspectos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `asignacion_ingles_subs`
--

DROP TABLE IF EXISTS `asignacion_ingles_subs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `asignacion_ingles_subs` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `asignacion_id` int(10) unsigned NOT NULL COMMENT 'FK → asignaciones.id (materia Inglés)',
  `subcomponente_id` int(10) unsigned NOT NULL COMMENT 'FK → ingles_subcomponentes.id',
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_ing_sub` (`asignacion_id`,`subcomponente_id`),
  KEY `fk_ingsub_asig` (`asignacion_id`),
  KEY `fk_ingsub_sub` (`subcomponente_id`),
  CONSTRAINT `fk_ingsub_asig` FOREIGN KEY (`asignacion_id`) REFERENCES `asignaciones` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ingsub_sub` FOREIGN KEY (`subcomponente_id`) REFERENCES `ingles_subcomponentes` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignacion_ingles_subs`
--

LOCK TABLES `asignacion_ingles_subs` WRITE;
/*!40000 ALTER TABLE `asignacion_ingles_subs` DISABLE KEYS */;
/*!40000 ALTER TABLE `asignacion_ingles_subs` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=96 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignacion_maestros`
--

LOCK TABLES `asignacion_maestros` WRITE;
/*!40000 ALTER TABLE `asignacion_maestros` DISABLE KEYS */;
INSERT INTO `asignacion_maestros` VALUES (29,36,1,1,0,'2026-05-30 19:43:36',1),(30,38,1,1,0,'2026-05-30 19:43:36',1),(33,41,1,1,0,'2026-05-30 19:43:36',1),(34,43,1,1,0,'2026-05-30 19:43:36',1),(61,77,1,0,0,'2026-06-05 18:40:26',1),(62,78,1,0,0,'2026-06-05 18:40:26',1),(63,79,1,0,0,'2026-06-05 18:40:26',1),(64,80,1,0,0,'2026-06-05 18:40:26',1),(65,86,1,1,0,'2026-06-06 15:43:05',1),(66,87,1,1,0,'2026-06-06 15:43:05',1),(67,88,4,1,0,'2026-06-06 15:43:57',1),(68,89,4,1,0,'2026-06-06 15:43:57',1),(87,346,1,1,0,'2026-06-09 20:39:27',1),(93,416,5,0,0,'2026-06-18 11:16:53',1),(95,44,1,1,0,'2026-07-09 10:39:06',1);
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
  `grupo` varchar(10) NOT NULL DEFAULT 'A',
  `orden` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'Orden en la boleta',
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_asignacion` (`ciclo_id`,`materia_id`,`seccion`,`grado`,`grupo`),
  KEY `fk_asig_materia` (`materia_id`),
  KEY `fk_asig_campo` (`campo_formativo_id`),
  CONSTRAINT `fk_asig_campo` FOREIGN KEY (`campo_formativo_id`) REFERENCES `campos_formativos` (`id`),
  CONSTRAINT `fk_asig_ciclo` FOREIGN KEY (`ciclo_id`) REFERENCES `ciclos_escolares` (`id`),
  CONSTRAINT `fk_asig_materia` FOREIGN KEY (`materia_id`) REFERENCES `materias` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=576 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignaciones`
--

LOCK TABLES `asignaciones` WRITE;
/*!40000 ALTER TABLE `asignaciones` DISABLE KEYS */;
INSERT INTO `asignaciones` VALUES (36,1,9,2,'primaria',1,'A',5,1,'2026-05-30 19:43:36','2026-07-12 20:48:43'),(38,1,13,NULL,'primaria',1,'A',7,1,'2026-05-30 19:43:36','2026-07-12 20:48:43'),(41,1,16,4,'primaria',1,'A',10,1,'2026-05-30 19:43:36','2026-07-12 20:48:43'),(43,1,15,4,'primaria',1,'A',9,1,'2026-05-30 19:43:36','2026-07-12 20:48:43'),(44,1,5,2,'primaria',1,'A',4,1,'2026-05-30 20:24:31','2026-07-12 20:48:43'),(77,1,9,2,'primaria',1,'B',5,1,'2026-06-05 18:40:26','2026-07-12 20:48:43'),(78,1,13,3,'primaria',1,'B',7,1,'2026-06-05 18:40:26','2026-07-12 20:48:43'),(79,1,15,4,'primaria',1,'B',9,1,'2026-06-05 18:40:26','2026-07-12 20:48:43'),(80,1,16,4,'primaria',1,'B',10,1,'2026-06-05 18:40:26','2026-07-12 20:48:43'),(81,1,14,4,'primaria',1,'A',8,1,'2026-06-05 18:41:18','2026-07-12 20:48:43'),(82,1,10,2,'primaria',1,'A',6,1,'2026-06-05 18:41:18','2026-07-12 20:48:43'),(83,1,14,4,'primaria',1,'B',8,1,'2026-06-05 18:41:30','2026-07-12 20:48:43'),(84,1,10,2,'primaria',1,'B',6,1,'2026-06-05 18:41:30','2026-07-12 20:48:43'),(86,1,297,NULL,'primaria',1,'A',19,1,'2026-06-06 15:43:05','2026-07-12 20:48:43'),(87,1,298,NULL,'primaria',1,'A',20,1,'2026-06-06 15:43:05','2026-07-12 20:48:43'),(88,1,297,NULL,'primaria',1,'B',19,1,'2026-06-06 15:43:57','2026-07-12 20:48:43'),(89,1,298,NULL,'primaria',1,'B',20,1,'2026-06-06 15:43:57','2026-07-12 20:48:43'),(93,4,4,1,'primaria',1,'A',4,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(94,4,5,2,'primaria',1,'A',5,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(95,4,6,2,'primaria',1,'A',6,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(98,4,9,3,'primaria',1,'A',9,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(99,4,10,3,'primaria',1,'A',10,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(100,4,11,4,'primaria',1,'A',11,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(101,4,12,4,'primaria',1,'A',12,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(102,4,13,4,'primaria',1,'A',13,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(103,4,14,NULL,'primaria',1,'A',14,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(104,4,15,NULL,'primaria',1,'A',15,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(105,4,16,1,'primaria',1,'A',16,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(106,4,17,1,'primaria',1,'A',17,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(113,4,1,1,'primaria',1,'B',1,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(116,4,4,1,'primaria',1,'B',4,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(117,4,5,2,'primaria',1,'B',5,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(118,4,6,2,'primaria',1,'B',6,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(121,4,9,3,'primaria',1,'B',9,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(122,4,10,3,'primaria',1,'B',10,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(123,4,11,4,'primaria',1,'B',11,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(124,4,12,4,'primaria',1,'B',12,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(125,4,13,4,'primaria',1,'B',13,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(126,4,14,NULL,'primaria',1,'B',14,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(127,4,15,NULL,'primaria',1,'B',15,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(128,4,16,1,'primaria',1,'B',16,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(129,4,17,1,'primaria',1,'B',17,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(142,4,4,1,'primaria',2,'A',4,1,'2026-06-09 12:30:30','2026-07-12 20:48:43'),(145,4,4,1,'primaria',2,'B',4,1,'2026-06-09 12:30:30','2026-07-12 20:48:43'),(148,4,1,1,'primaria',2,'A',1,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(149,4,2,1,'primaria',2,'A',2,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(150,4,3,1,'primaria',2,'A',3,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(151,4,5,2,'primaria',2,'A',5,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(152,4,6,2,'primaria',2,'A',6,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(154,4,10,3,'primaria',2,'A',8,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(155,4,11,4,'primaria',2,'A',9,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(156,4,12,4,'primaria',2,'A',10,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(157,4,13,4,'primaria',2,'A',11,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(158,4,14,NULL,'primaria',2,'A',12,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(159,4,15,NULL,'primaria',2,'A',13,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(163,4,1,1,'primaria',2,'B',1,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(164,4,2,1,'primaria',2,'B',2,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(165,4,3,1,'primaria',2,'B',3,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(166,4,5,2,'primaria',2,'B',5,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(167,4,6,2,'primaria',2,'B',6,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(169,4,10,3,'primaria',2,'B',8,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(170,4,11,4,'primaria',2,'B',9,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(171,4,12,4,'primaria',2,'B',10,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(172,4,13,4,'primaria',2,'B',11,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(173,4,14,NULL,'primaria',2,'B',12,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(174,4,15,NULL,'primaria',2,'B',13,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(200,1,1,1,'primaria',2,'A',7,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(201,1,3,NULL,'primaria',2,'A',0,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(202,1,4,1,'primaria',2,'A',21,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(203,1,5,2,'primaria',2,'A',8,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(204,1,9,2,'primaria',2,'A',1,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(205,1,10,2,'primaria',2,'A',10,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(206,1,11,3,'primaria',2,'A',5,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(207,1,12,3,'primaria',2,'A',6,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(208,1,13,3,'primaria',2,'A',3,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(209,1,14,4,'primaria',2,'A',2,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(210,1,15,4,'primaria',2,'A',11,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(211,1,16,4,'primaria',2,'A',9,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(231,1,1,1,'primaria',2,'B',7,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(232,1,3,NULL,'primaria',2,'B',0,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(233,1,4,1,'primaria',2,'B',21,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(234,1,5,2,'primaria',2,'B',8,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(235,1,9,2,'primaria',2,'B',1,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(236,1,10,2,'primaria',2,'B',10,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(237,1,11,3,'primaria',2,'B',5,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(238,1,12,3,'primaria',2,'B',6,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(239,1,13,3,'primaria',2,'B',3,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(240,1,14,4,'primaria',2,'B',2,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(241,1,15,4,'primaria',2,'B',11,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(242,1,16,4,'primaria',2,'B',9,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(262,1,298,NULL,'primaria',1,'C',20,1,'2026-06-09 19:04:03','2026-07-12 20:48:43'),(263,1,298,NULL,'primaria',1,'D',20,1,'2026-06-09 19:04:03','2026-07-12 20:48:43'),(264,1,9,2,'primaria',1,'C',5,1,'2026-06-09 19:04:03','2026-07-12 20:48:43'),(265,1,9,2,'primaria',1,'D',5,1,'2026-06-09 19:04:03','2026-07-12 20:48:43'),(266,1,297,NULL,'primaria',1,'C',19,1,'2026-06-09 19:04:03','2026-07-12 20:48:43'),(267,1,297,NULL,'primaria',1,'D',19,1,'2026-06-09 19:04:03','2026-07-12 20:48:43'),(268,1,13,3,'primaria',1,'C',7,1,'2026-06-09 19:04:03','2026-07-12 20:48:43'),(269,1,13,3,'primaria',1,'D',7,1,'2026-06-09 19:04:03','2026-07-12 20:48:43'),(272,1,5,2,'primaria',1,'B',4,1,'2026-06-09 19:04:03','2026-07-12 20:48:43'),(273,1,5,2,'primaria',1,'C',4,1,'2026-06-09 19:04:03','2026-07-12 20:48:43'),(274,1,5,2,'primaria',1,'D',4,1,'2026-06-09 19:04:03','2026-07-12 20:48:43'),(279,1,16,4,'primaria',1,'C',10,1,'2026-06-09 19:04:04','2026-07-12 20:48:43'),(280,1,16,4,'primaria',1,'D',10,1,'2026-06-09 19:04:04','2026-07-12 20:48:43'),(281,1,15,4,'primaria',1,'C',9,1,'2026-06-09 19:04:04','2026-07-12 20:48:43'),(282,1,15,4,'primaria',1,'D',9,1,'2026-06-09 19:04:04','2026-07-12 20:48:43'),(305,1,14,4,'primaria',1,'C',8,1,'2026-06-09 19:04:04','2026-07-12 20:48:43'),(306,1,14,4,'primaria',1,'D',8,1,'2026-06-09 19:04:04','2026-07-12 20:48:43'),(307,1,10,2,'primaria',1,'C',6,1,'2026-06-09 19:04:04','2026-07-12 20:48:43'),(308,1,10,2,'primaria',1,'D',6,1,'2026-06-09 19:04:04','2026-07-12 20:48:43'),(310,1,4,1,'primaria',1,'B',21,1,'2026-06-09 19:35:09','2026-07-12 20:48:43'),(311,1,4,1,'primaria',1,'C',21,1,'2026-06-09 19:35:09','2026-07-12 20:48:43'),(312,1,4,1,'primaria',1,'D',21,1,'2026-06-09 19:35:09','2026-07-12 20:48:43'),(314,1,1,1,'primaria',1,'B',1,1,'2026-06-09 19:35:29','2026-07-12 20:48:43'),(315,1,1,1,'primaria',1,'C',1,1,'2026-06-09 19:35:29','2026-07-12 20:48:43'),(316,1,1,1,'primaria',1,'D',1,1,'2026-06-09 19:35:29','2026-07-12 20:48:43'),(346,1,1,1,'primaria',1,'A',1,1,'2026-06-09 20:39:27','2026-07-12 20:48:43'),(416,1,4,1,'primaria',1,'A',21,1,'2026-06-16 22:36:31','2026-07-12 20:48:43'),(418,1,278,1,'primaria',1,'A',2,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(419,1,278,1,'primaria',1,'B',2,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(420,1,278,1,'primaria',1,'C',2,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(421,1,278,1,'primaria',1,'D',2,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(422,1,279,1,'primaria',1,'A',1,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(423,1,279,1,'primaria',1,'B',1,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(424,1,279,1,'primaria',1,'C',1,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(425,1,279,1,'primaria',1,'D',1,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(426,1,280,1,'primaria',1,'A',12,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(427,1,280,1,'primaria',1,'B',12,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(428,1,280,1,'primaria',1,'C',12,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(429,1,280,1,'primaria',1,'D',12,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(430,1,281,1,'primaria',1,'A',13,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(431,1,281,1,'primaria',1,'B',13,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(432,1,281,1,'primaria',1,'C',13,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(433,1,281,1,'primaria',1,'D',13,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(434,1,282,1,'primaria',1,'A',14,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(435,1,282,1,'primaria',1,'B',14,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(436,1,282,1,'primaria',1,'C',14,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(437,1,282,1,'primaria',1,'D',14,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(438,1,285,1,'primaria',1,'A',15,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(439,1,285,1,'primaria',1,'B',15,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(440,1,285,1,'primaria',1,'C',15,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(441,1,285,1,'primaria',1,'D',15,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(442,1,286,1,'primaria',1,'A',16,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(443,1,286,1,'primaria',1,'B',16,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(444,1,286,1,'primaria',1,'C',16,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(445,1,286,1,'primaria',1,'D',16,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(447,1,27,1,'primaria',1,'A',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(448,1,27,1,'primaria',1,'B',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(449,1,27,1,'primaria',1,'C',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(450,1,27,1,'primaria',1,'D',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(451,1,28,1,'primaria',1,'A',23,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(452,1,28,1,'primaria',1,'B',23,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(453,1,28,1,'primaria',1,'C',23,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(454,1,28,1,'primaria',1,'D',23,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(455,1,4,1,'primaria',2,'C',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(456,1,4,1,'primaria',2,'D',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(457,1,27,1,'primaria',2,'A',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(458,1,27,1,'primaria',2,'B',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(459,1,27,1,'primaria',2,'C',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(460,1,27,1,'primaria',2,'D',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(461,1,28,1,'primaria',2,'A',23,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(462,1,28,1,'primaria',2,'B',23,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(463,1,28,1,'primaria',2,'C',23,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(464,1,28,1,'primaria',2,'D',23,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(465,1,4,1,'primaria',3,'A',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(466,1,4,1,'primaria',3,'B',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(467,1,4,1,'primaria',3,'C',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(468,1,4,1,'primaria',3,'D',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(469,1,27,1,'primaria',3,'A',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(470,1,27,1,'primaria',3,'B',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(471,1,27,1,'primaria',3,'C',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(472,1,27,1,'primaria',3,'D',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(473,1,28,1,'primaria',3,'A',23,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(474,1,28,1,'primaria',3,'B',23,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(475,1,28,1,'primaria',3,'C',23,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(476,1,28,1,'primaria',3,'D',23,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(477,1,4,1,'primaria',4,'A',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(478,1,4,1,'primaria',4,'B',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(479,1,4,1,'primaria',4,'C',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(480,1,4,1,'primaria',4,'D',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(481,1,27,1,'primaria',4,'A',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(482,1,27,1,'primaria',4,'B',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(483,1,27,1,'primaria',4,'C',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(484,1,27,1,'primaria',4,'D',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(485,1,28,1,'primaria',4,'A',23,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(486,1,28,1,'primaria',4,'B',23,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(487,1,28,1,'primaria',4,'C',23,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(488,1,28,1,'primaria',4,'D',23,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(489,1,4,1,'primaria',5,'A',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(490,1,4,1,'primaria',5,'B',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(491,1,4,1,'primaria',5,'C',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(492,1,4,1,'primaria',5,'D',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(493,1,27,1,'primaria',5,'A',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(494,1,27,1,'primaria',5,'B',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(495,1,27,1,'primaria',5,'C',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(496,1,27,1,'primaria',5,'D',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(497,1,29,1,'primaria',5,'A',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(498,1,29,1,'primaria',5,'B',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(499,1,29,1,'primaria',5,'C',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(500,1,29,1,'primaria',5,'D',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(501,1,4,1,'primaria',6,'A',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(502,1,4,1,'primaria',6,'B',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(503,1,4,1,'primaria',6,'C',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(504,1,4,1,'primaria',6,'D',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(505,1,27,1,'primaria',6,'A',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(506,1,27,1,'primaria',6,'B',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(507,1,27,1,'primaria',6,'C',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(508,1,27,1,'primaria',6,'D',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(509,1,29,1,'primaria',6,'A',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(510,1,29,1,'primaria',6,'B',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(511,1,29,1,'primaria',6,'C',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(512,1,29,1,'primaria',6,'D',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(513,1,27,1,'secundaria',1,'A',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(514,1,27,1,'secundaria',1,'B',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(515,1,27,1,'secundaria',1,'C',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(516,1,27,1,'secundaria',1,'D',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(517,1,29,1,'secundaria',1,'A',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(518,1,29,1,'secundaria',1,'B',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(519,1,29,1,'secundaria',1,'C',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(520,1,29,1,'secundaria',1,'D',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(521,1,27,1,'secundaria',2,'A',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(522,1,27,1,'secundaria',2,'B',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(523,1,27,1,'secundaria',2,'C',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(524,1,27,1,'secundaria',2,'D',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(525,1,29,1,'secundaria',2,'A',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(526,1,29,1,'secundaria',2,'B',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(527,1,29,1,'secundaria',2,'C',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(528,1,29,1,'secundaria',2,'D',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(529,1,27,1,'secundaria',3,'A',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(530,1,27,1,'secundaria',3,'B',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(531,1,27,1,'secundaria',3,'C',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(532,1,27,1,'secundaria',3,'D',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(533,1,29,1,'secundaria',3,'A',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(534,1,29,1,'secundaria',3,'B',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(535,1,29,1,'secundaria',3,'C',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(536,1,29,1,'secundaria',3,'D',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(541,1,18,NULL,'primaria',1,'A',3,1,'2026-07-12 14:47:51','2026-07-12 20:48:43'),(542,1,18,NULL,'primaria',1,'B',3,1,'2026-07-12 14:47:51','2026-07-12 20:48:43'),(543,1,18,NULL,'primaria',1,'C',3,1,'2026-07-12 14:47:51','2026-07-12 20:48:43'),(544,1,18,NULL,'primaria',1,'D',3,1,'2026-07-12 14:47:51','2026-07-12 20:48:43'),(545,1,19,NULL,'primaria',1,'A',4,1,'2026-07-12 14:47:51','2026-07-12 20:48:43'),(546,1,19,NULL,'primaria',1,'B',4,1,'2026-07-12 14:47:51','2026-07-12 20:48:43'),(547,1,19,NULL,'primaria',1,'C',4,1,'2026-07-12 14:47:51','2026-07-12 20:48:43'),(548,1,19,NULL,'primaria',1,'D',4,1,'2026-07-12 14:47:51','2026-07-12 20:48:43'),(549,1,20,NULL,'primaria',1,'A',5,1,'2026-07-12 14:47:51','2026-07-12 20:48:43'),(550,1,20,NULL,'primaria',1,'B',5,1,'2026-07-12 14:47:51','2026-07-12 20:48:43'),(551,1,20,NULL,'primaria',1,'C',5,1,'2026-07-12 14:47:51','2026-07-12 20:48:43'),(552,1,20,NULL,'primaria',1,'D',5,1,'2026-07-12 14:47:51','2026-07-12 20:48:43'),(553,1,21,NULL,'primaria',1,'A',6,1,'2026-07-12 14:47:51','2026-07-12 20:48:43'),(554,1,21,NULL,'primaria',1,'B',6,1,'2026-07-12 14:47:51','2026-07-12 20:48:43'),(555,1,21,NULL,'primaria',1,'C',6,1,'2026-07-12 14:47:51','2026-07-12 20:48:43'),(556,1,21,NULL,'primaria',1,'D',6,1,'2026-07-12 14:47:51','2026-07-12 20:48:43'),(557,1,22,NULL,'primaria',1,'A',7,1,'2026-07-12 14:47:51','2026-07-12 20:48:43'),(558,1,22,NULL,'primaria',1,'B',7,1,'2026-07-12 14:47:51','2026-07-12 20:48:43'),(559,1,22,NULL,'primaria',1,'C',7,1,'2026-07-12 14:47:51','2026-07-12 20:48:43'),(560,1,22,NULL,'primaria',1,'D',7,1,'2026-07-12 14:47:51','2026-07-12 20:48:43'),(561,1,23,NULL,'primaria',1,'A',8,1,'2026-07-12 14:47:51','2026-07-12 20:48:43'),(562,1,23,NULL,'primaria',1,'B',8,1,'2026-07-12 14:47:51','2026-07-12 20:48:43'),(563,1,23,NULL,'primaria',1,'C',8,1,'2026-07-12 14:47:51','2026-07-12 20:48:43'),(564,1,23,NULL,'primaria',1,'D',8,1,'2026-07-12 14:47:51','2026-07-12 20:48:43');
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
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ausencias`
--

LOCK TABLES `ausencias` WRITE;
/*!40000 ALTER TABLE `ausencias` DISABLE KEYS */;
INSERT INTO `ausencias` VALUES (1,8,1,1,1,1,'2026-07-12 19:04:32','2026-07-12 21:15:32'),(2,1,1,1,0,1,'2026-07-12 19:04:32','2026-07-12 21:15:32'),(3,9,1,1,0,1,'2026-07-12 19:04:32','2026-07-12 21:15:32'),(4,3,1,1,0,1,'2026-07-12 19:04:32','2026-07-12 21:15:32');
/*!40000 ALTER TABLE `ausencias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bajas_alumnos`
--

DROP TABLE IF EXISTS `bajas_alumnos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bajas_alumnos` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `alumno_id` int(10) unsigned NOT NULL,
  `motivo` text DEFAULT NULL,
  `fecha_baja` datetime NOT NULL DEFAULT current_timestamp(),
  `dado_por` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `alumno_id` (`alumno_id`),
  KEY `dado_por` (`dado_por`),
  CONSTRAINT `bajas_alumnos_ibfk_1` FOREIGN KEY (`alumno_id`) REFERENCES `alumnos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `bajas_alumnos_ibfk_2` FOREIGN KEY (`dado_por`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bajas_alumnos`
--

LOCK TABLES `bajas_alumnos` WRITE;
/*!40000 ALTER TABLE `bajas_alumnos` DISABLE KEYS */;
/*!40000 ALTER TABLE `bajas_alumnos` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=2454 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `calificaciones`
--

LOCK TABLES `calificaciones` WRITE;
/*!40000 ALTER TABLE `calificaciones` DISABLE KEYS */;
INSERT INTO `calificaciones` VALUES (61,1,43,49,1,9.00,1,'2026-06-03 21:48:46','2026-07-09 10:42:46'),(62,1,43,50,1,8.00,1,'2026-06-03 21:48:46','2026-07-09 10:42:46'),(63,1,43,51,1,9.00,1,'2026-06-03 21:48:46','2026-07-09 10:42:46'),(64,1,43,52,1,8.00,1,'2026-06-03 21:48:47','2026-07-09 10:42:46'),(65,1,43,53,1,9.00,1,'2026-06-03 21:48:47','2026-07-09 10:42:46'),(66,1,43,54,1,8.00,1,'2026-06-03 21:48:47','2026-07-09 10:42:46'),(67,3,43,49,1,NULL,1,'2026-06-03 21:48:47','2026-07-09 10:42:46'),(68,3,43,50,1,NULL,1,'2026-06-03 21:48:48','2026-07-09 10:42:46'),(69,3,43,51,1,NULL,1,'2026-06-03 21:48:48','2026-07-09 10:42:46'),(70,3,43,52,1,NULL,1,'2026-06-03 21:48:48','2026-07-09 10:42:46'),(71,3,43,53,1,NULL,1,'2026-06-03 21:48:48','2026-07-09 10:42:46'),(72,3,43,54,1,NULL,1,'2026-06-03 21:48:48','2026-07-09 10:42:46'),(85,1,36,25,1,9.00,1,'2026-06-03 21:49:12','2026-07-09 10:41:53'),(86,1,36,26,1,9.00,1,'2026-06-03 21:49:12','2026-07-09 10:41:53'),(87,1,36,27,1,9.00,1,'2026-06-03 21:49:12','2026-07-09 10:41:53'),(88,1,36,28,1,9.00,1,'2026-06-03 21:49:12','2026-07-09 10:41:53'),(89,1,36,29,1,9.00,1,'2026-06-03 21:49:12','2026-07-09 10:41:53'),(90,1,36,30,1,9.00,1,'2026-06-03 21:49:12','2026-07-09 10:41:53'),(91,3,36,25,1,NULL,1,'2026-06-03 21:49:12','2026-07-09 10:41:53'),(92,3,36,26,1,NULL,1,'2026-06-03 21:49:12','2026-07-09 10:41:53'),(93,3,36,27,1,NULL,1,'2026-06-03 21:49:12','2026-07-09 10:41:53'),(94,3,36,28,1,NULL,1,'2026-06-03 21:49:12','2026-07-09 10:41:53'),(95,3,36,29,1,NULL,1,'2026-06-03 21:49:12','2026-07-09 10:41:53'),(96,3,36,30,1,NULL,1,'2026-06-03 21:49:12','2026-07-09 10:41:53'),(97,1,41,55,1,9.00,1,'2026-06-03 21:49:18','2026-07-09 10:43:16'),(98,1,41,56,1,9.00,1,'2026-06-03 21:49:18','2026-07-09 10:43:16'),(99,1,41,57,1,9.00,1,'2026-06-03 21:49:18','2026-07-09 10:43:17'),(100,1,41,58,1,9.00,1,'2026-06-03 21:49:18','2026-07-09 10:43:17'),(101,1,41,59,1,9.00,1,'2026-06-03 21:49:18','2026-07-09 10:43:17'),(102,1,41,60,1,9.00,1,'2026-06-03 21:49:18','2026-07-09 10:43:17'),(103,3,41,55,1,NULL,1,'2026-06-03 21:49:18','2026-07-09 10:43:17'),(104,3,41,56,1,NULL,1,'2026-06-03 21:49:18','2026-07-09 10:43:17'),(105,3,41,57,1,NULL,1,'2026-06-03 21:49:18','2026-07-09 10:43:17'),(106,3,41,58,1,NULL,1,'2026-06-03 21:49:18','2026-07-09 10:43:17'),(107,3,41,59,1,NULL,1,'2026-06-03 21:49:18','2026-07-09 10:43:18'),(108,3,41,60,1,NULL,1,'2026-06-03 21:49:18','2026-07-09 10:43:18'),(109,1,38,37,1,10.00,1,'2026-06-03 21:49:28','2026-07-09 10:42:17'),(110,1,38,38,1,10.00,1,'2026-06-03 21:49:28','2026-07-09 10:42:17'),(111,1,38,39,1,10.00,1,'2026-06-03 21:49:28','2026-07-09 10:42:17'),(112,1,38,40,1,10.00,1,'2026-06-03 21:49:28','2026-07-09 10:42:17'),(113,1,38,41,1,10.00,1,'2026-06-03 21:49:28','2026-07-09 10:42:17'),(114,1,38,42,1,10.00,1,'2026-06-03 21:49:28','2026-07-09 10:42:17'),(115,3,38,37,1,NULL,1,'2026-06-03 21:49:28','2026-07-09 10:42:17'),(116,3,38,38,1,NULL,1,'2026-06-03 21:49:28','2026-07-09 10:42:17'),(117,3,38,39,1,NULL,1,'2026-06-03 21:49:28','2026-07-09 10:42:17'),(118,3,38,40,1,NULL,1,'2026-06-03 21:49:28','2026-07-09 10:42:17'),(119,3,38,41,1,NULL,1,'2026-06-03 21:49:28','2026-07-09 10:42:17'),(120,3,38,42,1,NULL,1,'2026-06-03 21:49:28','2026-07-09 10:42:17'),(433,1,82,310,1,9.00,1,'2026-06-05 18:42:06','2026-06-05 18:42:06'),(434,1,82,311,1,9.00,1,'2026-06-05 18:42:06','2026-06-05 18:42:06'),(435,1,82,312,1,9.00,1,'2026-06-05 18:42:06','2026-06-05 18:42:06'),(436,1,82,313,1,9.00,1,'2026-06-05 18:42:06','2026-06-05 18:42:06'),(437,1,82,314,1,9.00,1,'2026-06-05 18:42:06','2026-06-05 18:42:06'),(438,1,82,315,1,9.00,1,'2026-06-05 18:42:06','2026-06-05 18:42:06'),(439,3,82,310,1,NULL,1,'2026-06-05 18:42:06','2026-06-05 18:42:06'),(440,3,82,311,1,NULL,1,'2026-06-05 18:42:06','2026-06-05 18:42:06'),(441,3,82,312,1,NULL,1,'2026-06-05 18:42:06','2026-06-05 18:42:06'),(442,3,82,313,1,NULL,1,'2026-06-05 18:42:06','2026-06-05 18:42:06'),(443,3,82,314,1,NULL,1,'2026-06-05 18:42:06','2026-06-05 18:42:06'),(444,3,82,315,1,NULL,1,'2026-06-05 18:42:06','2026-06-05 18:42:06'),(445,1,81,304,1,8.00,1,'2026-06-05 18:42:39','2026-06-05 18:42:39'),(446,1,81,305,1,8.00,1,'2026-06-05 18:42:39','2026-06-05 18:42:39'),(447,1,81,306,1,8.00,1,'2026-06-05 18:42:40','2026-06-05 18:42:40'),(448,1,81,307,1,8.00,1,'2026-06-05 18:42:40','2026-06-05 18:42:40'),(449,1,81,308,1,8.00,1,'2026-06-05 18:42:40','2026-06-05 18:42:40'),(450,1,81,309,1,8.00,1,'2026-06-05 18:42:40','2026-06-05 18:42:40'),(451,3,81,304,1,NULL,1,'2026-06-05 18:42:40','2026-06-05 18:42:40'),(452,3,81,305,1,NULL,1,'2026-06-05 18:42:40','2026-06-05 18:42:40'),(453,3,81,306,1,NULL,1,'2026-06-05 18:42:40','2026-06-05 18:42:40'),(454,3,81,307,1,NULL,1,'2026-06-05 18:42:40','2026-06-05 18:42:40'),(455,3,81,308,1,NULL,1,'2026-06-05 18:42:40','2026-06-05 18:42:40'),(456,3,81,309,1,NULL,1,'2026-06-05 18:42:41','2026-06-05 18:42:41'),(457,1,86,334,1,9.00,1,'2026-06-06 15:45:52','2026-06-06 15:45:52'),(458,1,86,335,1,7.00,1,'2026-06-06 15:45:52','2026-06-06 15:45:52'),(459,1,86,336,1,8.00,1,'2026-06-06 15:45:52','2026-06-06 15:45:52'),(460,1,86,337,1,9.00,1,'2026-06-06 15:45:52','2026-06-06 15:45:52'),(461,1,86,338,1,9.00,1,'2026-06-06 15:45:52','2026-06-06 15:45:52'),(462,1,86,339,1,9.00,1,'2026-06-06 15:45:52','2026-06-06 15:45:52'),(463,3,86,334,1,NULL,1,'2026-06-06 15:45:52','2026-06-06 15:45:52'),(464,3,86,335,1,NULL,1,'2026-06-06 15:45:52','2026-06-06 15:45:52'),(465,3,86,336,1,NULL,1,'2026-06-06 15:45:52','2026-06-06 15:45:52'),(466,3,86,337,1,NULL,1,'2026-06-06 15:45:52','2026-06-06 15:45:52'),(467,3,86,338,1,NULL,1,'2026-06-06 15:45:52','2026-06-06 15:45:52'),(468,3,86,339,1,NULL,1,'2026-06-06 15:45:52','2026-06-06 15:45:52'),(541,1,44,7,1,9.00,1,'2026-06-09 19:05:30','2026-07-09 10:41:08'),(542,1,44,8,1,9.00,1,'2026-06-09 19:05:30','2026-07-09 10:41:08'),(543,1,44,9,1,9.00,1,'2026-06-09 19:05:30','2026-07-09 10:41:08'),(544,1,44,10,1,9.00,1,'2026-06-09 19:05:30','2026-07-09 10:41:08'),(545,1,44,11,1,9.00,1,'2026-06-09 19:05:30','2026-07-09 10:41:08'),(546,1,44,12,1,9.00,1,'2026-06-09 19:05:30','2026-07-09 10:41:08'),(547,6,44,7,1,NULL,1,'2026-06-09 19:05:30','2026-06-09 19:05:30'),(548,6,44,8,1,NULL,1,'2026-06-09 19:05:30','2026-06-09 19:05:30'),(549,6,44,9,1,NULL,1,'2026-06-09 19:05:30','2026-06-09 19:05:30'),(550,6,44,10,1,NULL,1,'2026-06-09 19:05:30','2026-06-09 19:05:30'),(551,6,44,11,1,NULL,1,'2026-06-09 19:05:30','2026-06-09 19:05:30'),(552,6,44,12,1,NULL,1,'2026-06-09 19:05:30','2026-06-09 19:05:30'),(553,3,44,7,1,NULL,1,'2026-06-09 19:05:30','2026-07-09 10:41:08'),(554,3,44,8,1,NULL,1,'2026-06-09 19:05:30','2026-07-09 10:41:08'),(555,3,44,9,1,NULL,1,'2026-06-09 19:05:30','2026-07-09 10:41:08'),(556,3,44,10,1,NULL,1,'2026-06-09 19:05:30','2026-07-09 10:41:08'),(557,3,44,11,1,NULL,1,'2026-06-09 19:05:30','2026-07-09 10:41:08'),(558,3,44,12,1,NULL,1,'2026-06-09 19:05:30','2026-07-09 10:41:08'),(603,6,93,508,1,NULL,1,'2026-06-09 19:46:41','2026-06-09 19:46:41'),(604,6,93,509,1,NULL,1,'2026-06-09 19:46:42','2026-06-09 19:46:42'),(605,6,93,510,1,NULL,1,'2026-06-09 19:46:42','2026-06-09 19:46:42'),(606,6,93,511,1,NULL,1,'2026-06-09 19:46:42','2026-06-09 19:46:42'),(607,6,93,512,1,NULL,1,'2026-06-09 19:46:42','2026-06-09 19:46:42'),(608,6,93,513,1,NULL,1,'2026-06-09 19:46:42','2026-06-09 19:46:42'),(759,1,346,526,1,8.00,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(760,1,346,527,1,8.00,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(761,1,346,528,1,8.00,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(762,1,346,529,1,8.00,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(763,1,346,530,1,8.00,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(764,1,346,531,1,8.00,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(765,6,346,526,1,NULL,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(766,6,346,527,1,NULL,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(767,6,346,528,1,NULL,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(768,6,346,529,1,NULL,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(769,6,346,530,1,NULL,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(770,6,346,531,1,NULL,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(771,3,346,526,1,NULL,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(772,3,346,527,1,NULL,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(773,3,346,528,1,NULL,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(774,3,346,529,1,NULL,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(775,3,346,530,1,NULL,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(776,3,346,531,1,NULL,1,'2026-06-10 04:54:04','2026-06-10 04:54:04'),(777,8,447,1997,1,8.00,1,'2026-07-03 13:14:09','2026-07-12 21:15:10'),(778,8,447,2033,1,8.00,1,'2026-07-03 13:14:09','2026-07-12 21:15:10'),(779,8,447,2069,1,8.00,1,'2026-07-03 13:14:09','2026-07-12 21:15:10'),(780,8,447,2105,1,8.00,1,'2026-07-03 13:14:09','2026-07-12 21:15:10'),(781,8,447,2141,1,8.00,1,'2026-07-03 13:14:09','2026-07-12 21:15:10'),(782,8,447,2177,1,8.00,1,'2026-07-03 13:14:09','2026-07-12 21:15:10'),(783,1,447,1997,1,NULL,1,'2026-07-03 13:14:09','2026-07-03 13:14:09'),(784,1,447,2033,1,NULL,1,'2026-07-03 13:14:09','2026-07-03 13:14:09'),(785,1,447,2069,1,NULL,1,'2026-07-03 13:14:09','2026-07-03 13:14:09'),(786,1,447,2105,1,NULL,1,'2026-07-03 13:14:09','2026-07-03 13:14:09'),(787,1,447,2141,1,NULL,1,'2026-07-03 13:14:09','2026-07-03 13:14:09'),(788,1,447,2177,1,NULL,1,'2026-07-03 13:14:09','2026-07-03 13:14:09'),(789,6,447,1997,1,NULL,1,'2026-07-03 13:14:09','2026-07-03 13:14:09'),(790,6,447,2033,1,NULL,1,'2026-07-03 13:14:09','2026-07-03 13:14:09'),(791,6,447,2069,1,NULL,1,'2026-07-03 13:14:09','2026-07-03 13:14:09'),(792,6,447,2105,1,NULL,1,'2026-07-03 13:14:10','2026-07-03 13:14:10'),(793,6,447,2141,1,NULL,1,'2026-07-03 13:14:10','2026-07-03 13:14:10'),(794,6,447,2177,1,NULL,1,'2026-07-03 13:14:10','2026-07-03 13:14:10'),(795,9,447,1997,1,NULL,1,'2026-07-03 13:14:10','2026-07-03 13:14:10'),(796,9,447,2033,1,NULL,1,'2026-07-03 13:14:10','2026-07-03 13:14:10'),(797,9,447,2069,1,NULL,1,'2026-07-03 13:14:10','2026-07-03 13:14:10'),(798,9,447,2105,1,NULL,1,'2026-07-03 13:14:10','2026-07-03 13:14:10'),(799,9,447,2141,1,NULL,1,'2026-07-03 13:14:10','2026-07-03 13:14:10'),(800,9,447,2177,1,NULL,1,'2026-07-03 13:14:10','2026-07-03 13:14:10'),(801,3,447,1997,1,NULL,1,'2026-07-03 13:14:10','2026-07-03 13:14:10'),(802,3,447,2033,1,NULL,1,'2026-07-03 13:14:10','2026-07-03 13:14:10'),(803,3,447,2069,1,NULL,1,'2026-07-03 13:14:10','2026-07-03 13:14:10'),(804,3,447,2105,1,NULL,1,'2026-07-03 13:14:10','2026-07-03 13:14:10'),(805,3,447,2141,1,NULL,1,'2026-07-03 13:14:10','2026-07-03 13:14:10'),(806,3,447,2177,1,NULL,1,'2026-07-03 13:14:10','2026-07-03 13:14:10'),(807,8,346,526,1,9.00,1,'2026-07-03 13:31:06','2026-07-03 13:31:06'),(808,8,346,527,1,9.00,1,'2026-07-03 13:31:06','2026-07-03 13:31:06'),(809,8,346,528,1,9.00,1,'2026-07-03 13:31:06','2026-07-03 13:31:06'),(810,8,346,529,1,9.00,1,'2026-07-03 13:31:06','2026-07-03 13:31:06'),(811,8,346,530,1,9.00,1,'2026-07-03 13:31:06','2026-07-03 13:31:06'),(812,8,346,531,1,9.00,1,'2026-07-03 13:31:06','2026-07-03 13:31:06'),(825,9,346,526,1,NULL,1,'2026-07-03 13:31:06','2026-07-03 13:31:06'),(826,9,346,527,1,NULL,1,'2026-07-03 13:31:06','2026-07-03 13:31:06'),(827,9,346,528,1,NULL,1,'2026-07-03 13:31:06','2026-07-03 13:31:06'),(828,9,346,529,1,NULL,1,'2026-07-03 13:31:06','2026-07-03 13:31:06'),(829,9,346,530,1,NULL,1,'2026-07-03 13:31:06','2026-07-03 13:31:06'),(830,9,346,531,1,NULL,1,'2026-07-03 13:31:06','2026-07-03 13:31:06'),(837,8,44,7,1,8.00,1,'2026-07-09 10:41:08','2026-07-09 10:41:08'),(838,8,44,8,1,8.00,1,'2026-07-09 10:41:08','2026-07-09 10:41:08'),(839,8,44,9,1,8.00,1,'2026-07-09 10:41:08','2026-07-09 10:41:08'),(840,8,44,10,1,8.00,1,'2026-07-09 10:41:08','2026-07-09 10:41:08'),(841,8,44,11,1,8.00,1,'2026-07-09 10:41:08','2026-07-09 10:41:08'),(842,8,44,12,1,8.00,1,'2026-07-09 10:41:08','2026-07-09 10:41:08'),(849,9,44,7,1,NULL,1,'2026-07-09 10:41:08','2026-07-09 10:41:08'),(850,9,44,8,1,NULL,1,'2026-07-09 10:41:08','2026-07-09 10:41:08'),(851,9,44,9,1,NULL,1,'2026-07-09 10:41:08','2026-07-09 10:41:08'),(852,9,44,10,1,NULL,1,'2026-07-09 10:41:08','2026-07-09 10:41:08'),(853,9,44,11,1,NULL,1,'2026-07-09 10:41:08','2026-07-09 10:41:08'),(854,9,44,12,1,NULL,1,'2026-07-09 10:41:08','2026-07-09 10:41:08'),(861,8,36,25,1,8.00,1,'2026-07-09 10:41:53','2026-07-09 10:41:53'),(862,8,36,26,1,9.00,1,'2026-07-09 10:41:53','2026-07-09 10:41:53'),(863,8,36,27,1,8.00,1,'2026-07-09 10:41:53','2026-07-09 10:41:53'),(864,8,36,28,1,9.00,1,'2026-07-09 10:41:53','2026-07-09 10:41:53'),(865,8,36,29,1,8.00,1,'2026-07-09 10:41:53','2026-07-09 10:41:53'),(866,8,36,30,1,9.00,1,'2026-07-09 10:41:53','2026-07-09 10:41:53'),(873,9,36,25,1,NULL,1,'2026-07-09 10:41:53','2026-07-09 10:41:53'),(874,9,36,26,1,NULL,1,'2026-07-09 10:41:53','2026-07-09 10:41:53'),(875,9,36,27,1,NULL,1,'2026-07-09 10:41:53','2026-07-09 10:41:53'),(876,9,36,28,1,NULL,1,'2026-07-09 10:41:53','2026-07-09 10:41:53'),(877,9,36,29,1,NULL,1,'2026-07-09 10:41:53','2026-07-09 10:41:53'),(878,9,36,30,1,NULL,1,'2026-07-09 10:41:53','2026-07-09 10:41:53'),(885,8,38,37,1,10.00,1,'2026-07-09 10:42:17','2026-07-09 10:42:17'),(886,8,38,38,1,10.00,1,'2026-07-09 10:42:17','2026-07-09 10:42:17'),(887,8,38,39,1,10.00,1,'2026-07-09 10:42:17','2026-07-09 10:42:17'),(888,8,38,40,1,10.00,1,'2026-07-09 10:42:17','2026-07-09 10:42:17'),(889,8,38,41,1,10.00,1,'2026-07-09 10:42:17','2026-07-09 10:42:17'),(890,8,38,42,1,10.00,1,'2026-07-09 10:42:17','2026-07-09 10:42:17'),(897,9,38,37,1,NULL,1,'2026-07-09 10:42:17','2026-07-09 10:42:17'),(898,9,38,38,1,NULL,1,'2026-07-09 10:42:17','2026-07-09 10:42:17'),(899,9,38,39,1,NULL,1,'2026-07-09 10:42:17','2026-07-09 10:42:17'),(900,9,38,40,1,NULL,1,'2026-07-09 10:42:17','2026-07-09 10:42:17'),(901,9,38,41,1,NULL,1,'2026-07-09 10:42:17','2026-07-09 10:42:17'),(902,9,38,42,1,NULL,1,'2026-07-09 10:42:17','2026-07-09 10:42:17'),(909,8,43,49,1,9.00,1,'2026-07-09 10:42:46','2026-07-09 10:42:46'),(910,8,43,50,1,9.00,1,'2026-07-09 10:42:46','2026-07-09 10:42:46'),(911,8,43,51,1,9.00,1,'2026-07-09 10:42:46','2026-07-09 10:42:46'),(912,8,43,52,1,9.00,1,'2026-07-09 10:42:46','2026-07-09 10:42:46'),(913,8,43,53,1,9.00,1,'2026-07-09 10:42:46','2026-07-09 10:42:46'),(914,8,43,54,1,9.00,1,'2026-07-09 10:42:46','2026-07-09 10:42:46'),(921,9,43,49,1,NULL,1,'2026-07-09 10:42:46','2026-07-09 10:42:46'),(922,9,43,50,1,NULL,1,'2026-07-09 10:42:46','2026-07-09 10:42:46'),(923,9,43,51,1,NULL,1,'2026-07-09 10:42:46','2026-07-09 10:42:46'),(924,9,43,52,1,NULL,1,'2026-07-09 10:42:46','2026-07-09 10:42:46'),(925,9,43,53,1,NULL,1,'2026-07-09 10:42:46','2026-07-09 10:42:46'),(926,9,43,54,1,NULL,1,'2026-07-09 10:42:46','2026-07-09 10:42:46'),(933,8,41,55,1,10.00,1,'2026-07-09 10:43:13','2026-07-09 10:43:15'),(934,8,41,56,1,10.00,1,'2026-07-09 10:43:13','2026-07-09 10:43:16'),(935,8,41,57,1,10.00,1,'2026-07-09 10:43:13','2026-07-09 10:43:16'),(936,8,41,58,1,10.00,1,'2026-07-09 10:43:13','2026-07-09 10:43:16'),(937,8,41,59,1,10.00,1,'2026-07-09 10:43:13','2026-07-09 10:43:16'),(938,8,41,60,1,10.00,1,'2026-07-09 10:43:13','2026-07-09 10:43:16'),(945,9,41,55,1,NULL,1,'2026-07-09 10:43:14','2026-07-09 10:43:17'),(946,9,41,56,1,NULL,1,'2026-07-09 10:43:14','2026-07-09 10:43:17'),(947,9,41,57,1,NULL,1,'2026-07-09 10:43:14','2026-07-09 10:43:17'),(948,9,41,58,1,NULL,1,'2026-07-09 10:43:14','2026-07-09 10:43:17'),(949,9,41,59,1,NULL,1,'2026-07-09 10:43:14','2026-07-09 10:43:17'),(950,9,41,60,1,NULL,1,'2026-07-09 10:43:14','2026-07-09 10:43:17'),(1029,8,451,2213,1,7.00,1,'2026-07-09 11:47:54','2026-07-09 11:48:54'),(1030,8,451,2229,1,7.00,1,'2026-07-09 11:47:54','2026-07-09 11:48:54'),(1031,8,451,2245,1,7.00,1,'2026-07-09 11:47:54','2026-07-09 11:48:54'),(1032,8,451,2261,1,7.00,1,'2026-07-09 11:47:54','2026-07-09 11:48:54'),(1033,8,451,2277,1,7.00,1,'2026-07-09 11:47:54','2026-07-09 11:48:54'),(1034,8,451,2293,1,7.00,1,'2026-07-09 11:47:54','2026-07-09 11:48:54'),(1035,1,451,2213,1,NULL,1,'2026-07-09 11:47:54','2026-07-09 11:47:54'),(1036,1,451,2229,1,NULL,1,'2026-07-09 11:47:54','2026-07-09 11:47:54'),(1037,1,451,2245,1,NULL,1,'2026-07-09 11:47:54','2026-07-09 11:47:54'),(1038,1,451,2261,1,NULL,1,'2026-07-09 11:47:54','2026-07-09 11:47:54'),(1039,1,451,2277,1,NULL,1,'2026-07-09 11:47:54','2026-07-09 11:47:54'),(1040,1,451,2293,1,NULL,1,'2026-07-09 11:47:54','2026-07-09 11:47:54'),(1041,9,451,2213,1,NULL,1,'2026-07-09 11:47:54','2026-07-09 11:47:54'),(1042,9,451,2229,1,NULL,1,'2026-07-09 11:47:54','2026-07-09 11:47:54'),(1043,9,451,2245,1,NULL,1,'2026-07-09 11:47:54','2026-07-09 11:47:54'),(1044,9,451,2261,1,NULL,1,'2026-07-09 11:47:54','2026-07-09 11:47:54'),(1045,9,451,2277,1,NULL,1,'2026-07-09 11:47:54','2026-07-09 11:47:54'),(1046,9,451,2293,1,NULL,1,'2026-07-09 11:47:54','2026-07-09 11:47:54'),(1047,3,451,2213,1,NULL,1,'2026-07-09 11:47:54','2026-07-09 11:47:54'),(1048,3,451,2229,1,NULL,1,'2026-07-09 11:47:54','2026-07-09 11:47:54'),(1049,3,451,2245,1,NULL,1,'2026-07-09 11:47:54','2026-07-09 11:47:54'),(1050,3,451,2261,1,NULL,1,'2026-07-09 11:47:54','2026-07-09 11:47:54'),(1051,3,451,2277,1,NULL,1,'2026-07-09 11:47:54','2026-07-09 11:47:54'),(1052,3,451,2293,1,NULL,1,'2026-07-09 11:47:54','2026-07-09 11:47:54'),(1125,1,416,1499,1,9.00,1,'2026-07-09 12:26:26','2026-07-09 12:26:26'),(1126,1,416,1562,1,9.00,1,'2026-07-09 12:26:26','2026-07-09 12:26:26'),(1127,1,416,1625,1,9.00,1,'2026-07-09 12:26:26','2026-07-09 12:26:26'),(1128,1,416,1688,1,9.00,1,'2026-07-09 12:26:26','2026-07-09 12:26:26'),(1129,1,416,1751,1,9.00,1,'2026-07-09 12:26:26','2026-07-09 12:26:26'),(1130,1,416,1814,1,9.00,1,'2026-07-09 12:26:26','2026-07-09 12:26:26'),(1131,3,416,1499,1,NULL,1,'2026-07-09 12:26:26','2026-07-09 12:26:26'),(1132,3,416,1562,1,NULL,1,'2026-07-09 12:26:26','2026-07-09 12:26:26'),(1133,3,416,1625,1,NULL,1,'2026-07-09 12:26:26','2026-07-09 12:26:26'),(1134,3,416,1688,1,NULL,1,'2026-07-09 12:26:26','2026-07-09 12:26:26'),(1135,3,416,1751,1,NULL,1,'2026-07-09 12:26:26','2026-07-09 12:26:26'),(1136,3,416,1814,1,NULL,1,'2026-07-09 12:26:26','2026-07-09 12:26:26'),(1137,8,416,1499,1,6.00,1,'2026-07-09 12:26:26','2026-07-09 12:26:26'),(1138,8,416,1562,1,6.00,1,'2026-07-09 12:26:26','2026-07-09 12:26:26'),(1139,8,416,1625,1,6.00,1,'2026-07-09 12:26:26','2026-07-09 12:26:26'),(1140,8,416,1688,1,6.00,1,'2026-07-09 12:26:26','2026-07-09 12:26:26'),(1141,8,416,1751,1,6.00,1,'2026-07-09 12:26:26','2026-07-09 12:26:26'),(1142,8,416,1814,1,6.00,1,'2026-07-09 12:26:26','2026-07-09 12:26:26'),(1143,9,416,1499,1,NULL,1,'2026-07-09 12:26:26','2026-07-09 12:26:26'),(1144,9,416,1562,1,NULL,1,'2026-07-09 12:26:26','2026-07-09 12:26:26'),(1145,9,416,1625,1,NULL,1,'2026-07-09 12:26:26','2026-07-09 12:26:26'),(1146,9,416,1688,1,NULL,1,'2026-07-09 12:26:26','2026-07-09 12:26:26'),(1147,9,416,1751,1,NULL,1,'2026-07-09 12:26:26','2026-07-09 12:26:26'),(1148,9,416,1814,1,NULL,1,'2026-07-09 12:26:26','2026-07-09 12:26:26'),(1162,1,418,1503,1,NULL,1,'2026-07-09 12:37:45','2026-07-09 12:37:45'),(1163,1,418,1566,1,NULL,1,'2026-07-09 12:37:45','2026-07-09 12:37:45'),(1164,1,418,1629,1,NULL,1,'2026-07-09 12:37:45','2026-07-09 12:37:45'),(1165,1,418,1692,1,NULL,1,'2026-07-09 12:37:45','2026-07-09 12:37:45'),(1166,1,418,1755,1,NULL,1,'2026-07-09 12:37:45','2026-07-09 12:37:45'),(1167,1,418,1818,1,NULL,1,'2026-07-09 12:37:45','2026-07-09 12:37:45'),(1168,9,418,1503,1,NULL,1,'2026-07-09 12:37:45','2026-07-09 12:37:45'),(1169,9,418,1566,1,NULL,1,'2026-07-09 12:37:45','2026-07-09 12:37:45'),(1170,9,418,1629,1,NULL,1,'2026-07-09 12:37:45','2026-07-09 12:37:45'),(1171,9,418,1692,1,NULL,1,'2026-07-09 12:37:45','2026-07-09 12:37:45'),(1172,9,418,1755,1,NULL,1,'2026-07-09 12:37:45','2026-07-09 12:37:45'),(1173,9,418,1818,1,NULL,1,'2026-07-09 12:37:45','2026-07-09 12:37:45'),(1174,3,418,1503,1,NULL,1,'2026-07-09 12:37:45','2026-07-09 12:37:45'),(1175,3,418,1566,1,NULL,1,'2026-07-09 12:37:45','2026-07-09 12:37:45'),(1176,3,418,1629,1,NULL,1,'2026-07-09 12:37:45','2026-07-09 12:37:45'),(1177,3,418,1692,1,NULL,1,'2026-07-09 12:37:45','2026-07-09 12:37:45'),(1178,3,418,1755,1,NULL,1,'2026-07-09 12:37:45','2026-07-09 12:37:45'),(1179,3,418,1818,1,NULL,1,'2026-07-09 12:37:45','2026-07-09 12:37:45'),(1186,1,422,1507,1,NULL,1,'2026-07-09 12:38:02','2026-07-09 12:38:02'),(1187,1,422,1570,1,NULL,1,'2026-07-09 12:38:02','2026-07-09 12:38:02'),(1188,1,422,1633,1,NULL,1,'2026-07-09 12:38:02','2026-07-09 12:38:02'),(1189,1,422,1696,1,NULL,1,'2026-07-09 12:38:02','2026-07-09 12:38:02'),(1190,1,422,1759,1,NULL,1,'2026-07-09 12:38:02','2026-07-09 12:38:02'),(1191,1,422,1822,1,NULL,1,'2026-07-09 12:38:02','2026-07-09 12:38:02'),(1192,9,422,1507,1,NULL,1,'2026-07-09 12:38:02','2026-07-09 12:38:02'),(1193,9,422,1570,1,NULL,1,'2026-07-09 12:38:02','2026-07-09 12:38:02'),(1194,9,422,1633,1,NULL,1,'2026-07-09 12:38:02','2026-07-09 12:38:02'),(1195,9,422,1696,1,NULL,1,'2026-07-09 12:38:02','2026-07-09 12:38:02'),(1196,9,422,1759,1,NULL,1,'2026-07-09 12:38:02','2026-07-09 12:38:02'),(1197,9,422,1822,1,NULL,1,'2026-07-09 12:38:02','2026-07-09 12:38:02'),(1198,3,422,1507,1,NULL,1,'2026-07-09 12:38:02','2026-07-09 12:38:02'),(1199,3,422,1570,1,NULL,1,'2026-07-09 12:38:02','2026-07-09 12:38:02'),(1200,3,422,1633,1,NULL,1,'2026-07-09 12:38:02','2026-07-09 12:38:02'),(1201,3,422,1696,1,NULL,1,'2026-07-09 12:38:02','2026-07-09 12:38:02'),(1202,3,422,1759,1,NULL,1,'2026-07-09 12:38:02','2026-07-09 12:38:02'),(1203,3,422,1822,1,NULL,1,'2026-07-09 12:38:02','2026-07-09 12:38:02'),(1210,1,426,1511,1,NULL,1,'2026-07-09 12:38:22','2026-07-09 12:38:22'),(1211,1,426,1574,1,NULL,1,'2026-07-09 12:38:22','2026-07-09 12:38:22'),(1212,1,426,1637,1,NULL,1,'2026-07-09 12:38:22','2026-07-09 12:38:22'),(1213,1,426,1700,1,NULL,1,'2026-07-09 12:38:22','2026-07-09 12:38:22'),(1214,1,426,1763,1,NULL,1,'2026-07-09 12:38:22','2026-07-09 12:38:22'),(1215,1,426,1826,1,NULL,1,'2026-07-09 12:38:22','2026-07-09 12:38:22'),(1216,9,426,1511,1,NULL,1,'2026-07-09 12:38:22','2026-07-09 12:38:22'),(1217,9,426,1574,1,NULL,1,'2026-07-09 12:38:22','2026-07-09 12:38:22'),(1218,9,426,1637,1,NULL,1,'2026-07-09 12:38:22','2026-07-09 12:38:22'),(1219,9,426,1700,1,NULL,1,'2026-07-09 12:38:22','2026-07-09 12:38:22'),(1220,9,426,1763,1,NULL,1,'2026-07-09 12:38:22','2026-07-09 12:38:22'),(1221,9,426,1826,1,NULL,1,'2026-07-09 12:38:22','2026-07-09 12:38:22'),(1222,3,426,1511,1,NULL,1,'2026-07-09 12:38:22','2026-07-09 12:38:22'),(1223,3,426,1574,1,NULL,1,'2026-07-09 12:38:22','2026-07-09 12:38:22'),(1224,3,426,1637,1,NULL,1,'2026-07-09 12:38:22','2026-07-09 12:38:22'),(1225,3,426,1700,1,NULL,1,'2026-07-09 12:38:22','2026-07-09 12:38:22'),(1226,3,426,1763,1,NULL,1,'2026-07-09 12:38:22','2026-07-09 12:38:22'),(1227,3,426,1826,1,NULL,1,'2026-07-09 12:38:22','2026-07-09 12:38:22'),(1258,1,430,1515,1,NULL,1,'2026-07-09 12:39:04','2026-07-09 12:39:04'),(1259,1,430,1578,1,NULL,1,'2026-07-09 12:39:04','2026-07-09 12:39:04'),(1260,1,430,1641,1,NULL,1,'2026-07-09 12:39:04','2026-07-09 12:39:04'),(1261,1,430,1704,1,NULL,1,'2026-07-09 12:39:04','2026-07-09 12:39:04'),(1262,1,430,1767,1,NULL,1,'2026-07-09 12:39:04','2026-07-09 12:39:04'),(1263,1,430,1830,1,NULL,1,'2026-07-09 12:39:04','2026-07-09 12:39:04'),(1264,9,430,1515,1,NULL,1,'2026-07-09 12:39:04','2026-07-09 12:39:04'),(1265,9,430,1578,1,NULL,1,'2026-07-09 12:39:04','2026-07-09 12:39:04'),(1266,9,430,1641,1,NULL,1,'2026-07-09 12:39:04','2026-07-09 12:39:04'),(1267,9,430,1704,1,NULL,1,'2026-07-09 12:39:04','2026-07-09 12:39:04'),(1268,9,430,1767,1,NULL,1,'2026-07-09 12:39:04','2026-07-09 12:39:04'),(1269,9,430,1830,1,NULL,1,'2026-07-09 12:39:04','2026-07-09 12:39:04'),(1270,3,430,1515,1,NULL,1,'2026-07-09 12:39:04','2026-07-09 12:39:04'),(1271,3,430,1578,1,NULL,1,'2026-07-09 12:39:04','2026-07-09 12:39:04'),(1272,3,430,1641,1,NULL,1,'2026-07-09 12:39:04','2026-07-09 12:39:04'),(1273,3,430,1704,1,NULL,1,'2026-07-09 12:39:04','2026-07-09 12:39:04'),(1274,3,430,1767,1,NULL,1,'2026-07-09 12:39:04','2026-07-09 12:39:04'),(1275,3,430,1830,1,NULL,1,'2026-07-09 12:39:04','2026-07-09 12:39:04'),(1282,1,434,1519,1,NULL,1,'2026-07-09 12:39:20','2026-07-09 12:39:20'),(1283,1,434,1582,1,NULL,1,'2026-07-09 12:39:20','2026-07-09 12:39:20'),(1284,1,434,1645,1,NULL,1,'2026-07-09 12:39:20','2026-07-09 12:39:20'),(1285,1,434,1708,1,NULL,1,'2026-07-09 12:39:20','2026-07-09 12:39:20'),(1286,1,434,1771,1,NULL,1,'2026-07-09 12:39:20','2026-07-09 12:39:20'),(1287,1,434,1834,1,NULL,1,'2026-07-09 12:39:20','2026-07-09 12:39:20'),(1288,9,434,1519,1,NULL,1,'2026-07-09 12:39:20','2026-07-09 12:39:20'),(1289,9,434,1582,1,NULL,1,'2026-07-09 12:39:20','2026-07-09 12:39:20'),(1290,9,434,1645,1,NULL,1,'2026-07-09 12:39:20','2026-07-09 12:39:20'),(1291,9,434,1708,1,NULL,1,'2026-07-09 12:39:20','2026-07-09 12:39:20'),(1292,9,434,1771,1,NULL,1,'2026-07-09 12:39:20','2026-07-09 12:39:20'),(1293,9,434,1834,1,NULL,1,'2026-07-09 12:39:20','2026-07-09 12:39:20'),(1294,3,434,1519,1,NULL,1,'2026-07-09 12:39:20','2026-07-09 12:39:20'),(1295,3,434,1582,1,NULL,1,'2026-07-09 12:39:20','2026-07-09 12:39:20'),(1296,3,434,1645,1,NULL,1,'2026-07-09 12:39:20','2026-07-09 12:39:20'),(1297,3,434,1708,1,NULL,1,'2026-07-09 12:39:20','2026-07-09 12:39:20'),(1298,3,434,1771,1,NULL,1,'2026-07-09 12:39:20','2026-07-09 12:39:20'),(1299,3,434,1834,1,NULL,1,'2026-07-09 12:39:20','2026-07-09 12:39:20'),(1306,1,438,1523,1,NULL,1,'2026-07-09 12:39:37','2026-07-09 12:39:37'),(1307,1,438,1586,1,NULL,1,'2026-07-09 12:39:37','2026-07-09 12:39:37'),(1308,1,438,1649,1,NULL,1,'2026-07-09 12:39:37','2026-07-09 12:39:37'),(1309,1,438,1712,1,NULL,1,'2026-07-09 12:39:37','2026-07-09 12:39:37'),(1310,1,438,1775,1,NULL,1,'2026-07-09 12:39:37','2026-07-09 12:39:37'),(1311,1,438,1838,1,NULL,1,'2026-07-09 12:39:37','2026-07-09 12:39:37'),(1312,9,438,1523,1,NULL,1,'2026-07-09 12:39:37','2026-07-09 12:39:37'),(1313,9,438,1586,1,NULL,1,'2026-07-09 12:39:37','2026-07-09 12:39:37'),(1314,9,438,1649,1,NULL,1,'2026-07-09 12:39:37','2026-07-09 12:39:37'),(1315,9,438,1712,1,NULL,1,'2026-07-09 12:39:37','2026-07-09 12:39:37'),(1316,9,438,1775,1,NULL,1,'2026-07-09 12:39:37','2026-07-09 12:39:37'),(1317,9,438,1838,1,NULL,1,'2026-07-09 12:39:37','2026-07-09 12:39:37'),(1318,3,438,1523,1,NULL,1,'2026-07-09 12:39:37','2026-07-09 12:39:37'),(1319,3,438,1586,1,NULL,1,'2026-07-09 12:39:37','2026-07-09 12:39:37'),(1320,3,438,1649,1,NULL,1,'2026-07-09 12:39:37','2026-07-09 12:39:37'),(1321,3,438,1712,1,NULL,1,'2026-07-09 12:39:37','2026-07-09 12:39:37'),(1322,3,438,1775,1,NULL,1,'2026-07-09 12:39:37','2026-07-09 12:39:37'),(1323,3,438,1838,1,NULL,1,'2026-07-09 12:39:37','2026-07-09 12:39:37'),(1330,1,442,1527,1,NULL,1,'2026-07-09 12:39:46','2026-07-09 12:39:46'),(1331,1,442,1590,1,NULL,1,'2026-07-09 12:39:46','2026-07-09 12:39:46'),(1332,1,442,1653,1,NULL,1,'2026-07-09 12:39:46','2026-07-09 12:39:46'),(1333,1,442,1716,1,NULL,1,'2026-07-09 12:39:46','2026-07-09 12:39:46'),(1334,1,442,1779,1,NULL,1,'2026-07-09 12:39:46','2026-07-09 12:39:46'),(1335,1,442,1842,1,NULL,1,'2026-07-09 12:39:46','2026-07-09 12:39:46'),(1336,9,442,1527,1,NULL,1,'2026-07-09 12:39:46','2026-07-09 12:39:46'),(1337,9,442,1590,1,NULL,1,'2026-07-09 12:39:46','2026-07-09 12:39:46'),(1338,9,442,1653,1,NULL,1,'2026-07-09 12:39:46','2026-07-09 12:39:46'),(1339,9,442,1716,1,NULL,1,'2026-07-09 12:39:46','2026-07-09 12:39:46'),(1340,9,442,1779,1,NULL,1,'2026-07-09 12:39:46','2026-07-09 12:39:46'),(1341,9,442,1842,1,NULL,1,'2026-07-09 12:39:46','2026-07-09 12:39:46'),(1342,3,442,1527,1,NULL,1,'2026-07-09 12:39:46','2026-07-09 12:39:46'),(1343,3,442,1590,1,NULL,1,'2026-07-09 12:39:46','2026-07-09 12:39:46'),(1344,3,442,1653,1,NULL,1,'2026-07-09 12:39:46','2026-07-09 12:39:46'),(1345,3,442,1716,1,NULL,1,'2026-07-09 12:39:46','2026-07-09 12:39:46'),(1346,3,442,1779,1,NULL,1,'2026-07-09 12:39:46','2026-07-09 12:39:46'),(1347,3,442,1842,1,NULL,1,'2026-07-09 12:39:46','2026-07-09 12:39:46'),(1909,8,418,1692,1,9.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(1910,8,418,1503,1,9.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(1911,8,418,1629,1,9.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(1912,8,418,1755,1,9.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(1913,8,418,1566,1,9.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(1914,8,418,1818,1,9.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(1945,8,422,1696,1,10.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(1946,8,422,1507,1,10.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(1947,8,422,1633,1,10.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(1948,8,422,1759,1,10.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(1949,8,422,1570,1,10.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(1950,8,422,1822,1,10.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(1981,8,426,1700,1,8.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(1982,8,426,1511,1,8.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(1983,8,426,1637,1,8.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(1984,8,426,1763,1,8.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(1985,8,426,1574,1,8.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(1986,8,426,1826,1,8.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(2017,8,430,1704,1,10.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(2018,8,430,1515,1,10.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(2019,8,430,1641,1,10.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(2020,8,430,1767,1,10.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(2021,8,430,1578,1,10.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(2022,8,430,1830,1,10.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(2053,8,434,1708,1,9.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(2054,8,434,1519,1,9.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(2055,8,434,1645,1,9.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(2056,8,434,1771,1,9.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(2057,8,434,1582,1,9.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(2058,8,434,1834,1,9.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(2089,8,438,1712,1,10.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(2090,8,438,1523,1,10.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(2091,8,438,1649,1,10.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(2092,8,438,1775,1,10.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(2093,8,438,1586,1,10.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(2094,8,438,1838,1,10.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(2125,8,442,1716,1,8.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(2126,8,442,1527,1,8.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(2127,8,442,1653,1,8.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(2128,8,442,1779,1,8.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(2129,8,442,1590,1,8.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(2130,8,442,1842,1,8.00,1,'2026-07-12 15:02:53','2026-07-12 15:02:53'),(2177,8,561,2566,1,9.00,1,'2026-07-12 15:13:44','2026-07-12 15:21:10'),(2178,8,561,2473,1,9.00,1,'2026-07-12 15:13:44','2026-07-12 15:13:44'),(2179,8,561,2535,1,9.00,1,'2026-07-12 15:13:44','2026-07-12 15:13:44'),(2180,8,561,2597,1,9.00,1,'2026-07-12 15:13:44','2026-07-12 15:13:44'),(2181,8,561,2504,1,9.00,1,'2026-07-12 15:13:44','2026-07-12 15:21:10'),(2182,8,561,2628,1,9.00,1,'2026-07-12 15:13:44','2026-07-12 15:21:10'),(2208,8,561,2473,4,NULL,1,'2026-07-12 15:20:17','2026-07-12 15:20:17'),(2209,8,561,2504,4,NULL,1,'2026-07-12 15:20:17','2026-07-12 15:20:17'),(2210,8,561,2535,4,NULL,1,'2026-07-12 15:20:17','2026-07-12 15:20:17'),(2211,8,561,2566,4,NULL,1,'2026-07-12 15:20:17','2026-07-12 15:20:17'),(2212,8,561,2597,4,NULL,1,'2026-07-12 15:20:17','2026-07-12 15:20:17'),(2213,8,561,2628,4,NULL,1,'2026-07-12 15:20:17','2026-07-12 15:20:17'),(2214,1,561,2473,4,NULL,1,'2026-07-12 15:20:17','2026-07-12 15:20:17'),(2215,1,561,2504,4,NULL,1,'2026-07-12 15:20:17','2026-07-12 15:20:17'),(2216,1,561,2535,4,NULL,1,'2026-07-12 15:20:17','2026-07-12 15:20:17'),(2217,1,561,2566,4,NULL,1,'2026-07-12 15:20:17','2026-07-12 15:20:17'),(2218,1,561,2597,4,NULL,1,'2026-07-12 15:20:17','2026-07-12 15:20:17'),(2219,1,561,2628,4,NULL,1,'2026-07-12 15:20:17','2026-07-12 15:20:17'),(2220,9,561,2473,4,NULL,1,'2026-07-12 15:20:17','2026-07-12 15:20:17'),(2221,9,561,2504,4,NULL,1,'2026-07-12 15:20:17','2026-07-12 15:20:17'),(2222,9,561,2535,4,NULL,1,'2026-07-12 15:20:17','2026-07-12 15:20:17'),(2223,9,561,2566,4,NULL,1,'2026-07-12 15:20:17','2026-07-12 15:20:17'),(2224,9,561,2597,4,NULL,1,'2026-07-12 15:20:17','2026-07-12 15:20:17'),(2225,9,561,2628,4,NULL,1,'2026-07-12 15:20:17','2026-07-12 15:20:17'),(2226,3,561,2473,4,NULL,1,'2026-07-12 15:20:17','2026-07-12 15:20:17'),(2227,3,561,2504,4,NULL,1,'2026-07-12 15:20:17','2026-07-12 15:20:17'),(2228,3,561,2535,4,NULL,1,'2026-07-12 15:20:17','2026-07-12 15:20:17'),(2229,3,561,2566,4,NULL,1,'2026-07-12 15:20:17','2026-07-12 15:20:17'),(2230,3,561,2597,4,NULL,1,'2026-07-12 15:20:17','2026-07-12 15:20:17'),(2231,3,561,2628,4,NULL,1,'2026-07-12 15:20:17','2026-07-12 15:20:17'),(2232,8,561,2473,5,NULL,1,'2026-07-12 15:20:29','2026-07-12 15:20:29'),(2233,8,561,2504,5,NULL,1,'2026-07-12 15:20:29','2026-07-12 15:20:29'),(2234,8,561,2535,5,NULL,1,'2026-07-12 15:20:29','2026-07-12 15:20:29'),(2235,8,561,2566,5,NULL,1,'2026-07-12 15:20:29','2026-07-12 15:20:29'),(2236,8,561,2597,5,NULL,1,'2026-07-12 15:20:29','2026-07-12 15:20:29'),(2237,8,561,2628,5,NULL,1,'2026-07-12 15:20:29','2026-07-12 15:20:29'),(2238,1,561,2473,5,NULL,1,'2026-07-12 15:20:29','2026-07-12 15:20:29'),(2239,1,561,2504,5,NULL,1,'2026-07-12 15:20:29','2026-07-12 15:20:29'),(2240,1,561,2535,5,NULL,1,'2026-07-12 15:20:29','2026-07-12 15:20:29'),(2241,1,561,2566,5,NULL,1,'2026-07-12 15:20:29','2026-07-12 15:20:29'),(2242,1,561,2597,5,NULL,1,'2026-07-12 15:20:29','2026-07-12 15:20:29'),(2243,1,561,2628,5,NULL,1,'2026-07-12 15:20:29','2026-07-12 15:20:29'),(2244,9,561,2473,5,NULL,1,'2026-07-12 15:20:29','2026-07-12 15:20:29'),(2245,9,561,2504,5,NULL,1,'2026-07-12 15:20:29','2026-07-12 15:20:29'),(2246,9,561,2535,5,NULL,1,'2026-07-12 15:20:29','2026-07-12 15:20:29'),(2247,9,561,2566,5,NULL,1,'2026-07-12 15:20:29','2026-07-12 15:20:29'),(2248,9,561,2597,5,NULL,1,'2026-07-12 15:20:29','2026-07-12 15:20:29'),(2249,9,561,2628,5,NULL,1,'2026-07-12 15:20:29','2026-07-12 15:20:29'),(2250,3,561,2473,5,NULL,1,'2026-07-12 15:20:29','2026-07-12 15:20:29'),(2251,3,561,2504,5,NULL,1,'2026-07-12 15:20:29','2026-07-12 15:20:29'),(2252,3,561,2535,5,NULL,1,'2026-07-12 15:20:29','2026-07-12 15:20:29'),(2253,3,561,2566,5,NULL,1,'2026-07-12 15:20:29','2026-07-12 15:20:29'),(2254,3,561,2597,5,NULL,1,'2026-07-12 15:20:29','2026-07-12 15:20:29'),(2255,3,561,2628,5,NULL,1,'2026-07-12 15:20:29','2026-07-12 15:20:29'),(2256,8,561,2473,6,NULL,1,'2026-07-12 15:20:34','2026-07-12 15:20:34'),(2257,8,561,2504,6,NULL,1,'2026-07-12 15:20:34','2026-07-12 15:20:34'),(2258,8,561,2535,6,NULL,1,'2026-07-12 15:20:34','2026-07-12 15:20:34'),(2259,8,561,2566,6,NULL,1,'2026-07-12 15:20:34','2026-07-12 15:20:34'),(2260,8,561,2597,6,NULL,1,'2026-07-12 15:20:35','2026-07-12 15:20:35'),(2261,8,561,2628,6,NULL,1,'2026-07-12 15:20:35','2026-07-12 15:20:35'),(2262,1,561,2473,6,NULL,1,'2026-07-12 15:20:35','2026-07-12 15:20:35'),(2263,1,561,2504,6,NULL,1,'2026-07-12 15:20:35','2026-07-12 15:20:35'),(2264,1,561,2535,6,NULL,1,'2026-07-12 15:20:35','2026-07-12 15:20:35'),(2265,1,561,2566,6,NULL,1,'2026-07-12 15:20:35','2026-07-12 15:20:35'),(2266,1,561,2597,6,NULL,1,'2026-07-12 15:20:35','2026-07-12 15:20:35'),(2267,1,561,2628,6,NULL,1,'2026-07-12 15:20:35','2026-07-12 15:20:35'),(2268,9,561,2473,6,NULL,1,'2026-07-12 15:20:35','2026-07-12 15:20:35'),(2269,9,561,2504,6,NULL,1,'2026-07-12 15:20:35','2026-07-12 15:20:35'),(2270,9,561,2535,6,NULL,1,'2026-07-12 15:20:35','2026-07-12 15:20:35'),(2271,9,561,2566,6,NULL,1,'2026-07-12 15:20:35','2026-07-12 15:20:35'),(2272,9,561,2597,6,NULL,1,'2026-07-12 15:20:35','2026-07-12 15:20:35'),(2273,9,561,2628,6,NULL,1,'2026-07-12 15:20:35','2026-07-12 15:20:35'),(2274,3,561,2473,6,NULL,1,'2026-07-12 15:20:35','2026-07-12 15:20:35'),(2275,3,561,2504,6,NULL,1,'2026-07-12 15:20:35','2026-07-12 15:20:35'),(2276,3,561,2535,6,NULL,1,'2026-07-12 15:20:35','2026-07-12 15:20:35'),(2277,3,561,2566,6,NULL,1,'2026-07-12 15:20:35','2026-07-12 15:20:35'),(2278,3,561,2597,6,NULL,1,'2026-07-12 15:20:35','2026-07-12 15:20:35'),(2279,3,561,2628,6,NULL,1,'2026-07-12 15:20:35','2026-07-12 15:20:35'),(2286,1,561,2473,1,NULL,1,'2026-07-12 15:21:10','2026-07-12 15:21:10'),(2287,1,561,2504,1,NULL,1,'2026-07-12 15:21:10','2026-07-12 15:21:10'),(2288,1,561,2535,1,NULL,1,'2026-07-12 15:21:10','2026-07-12 15:21:10'),(2289,1,561,2566,1,NULL,1,'2026-07-12 15:21:10','2026-07-12 15:21:10'),(2290,1,561,2597,1,NULL,1,'2026-07-12 15:21:10','2026-07-12 15:21:10'),(2291,1,561,2628,1,NULL,1,'2026-07-12 15:21:10','2026-07-12 15:21:10'),(2292,9,561,2473,1,NULL,1,'2026-07-12 15:21:10','2026-07-12 15:21:10'),(2293,9,561,2504,1,NULL,1,'2026-07-12 15:21:10','2026-07-12 15:21:10'),(2294,9,561,2535,1,NULL,1,'2026-07-12 15:21:10','2026-07-12 15:21:10'),(2295,9,561,2566,1,NULL,1,'2026-07-12 15:21:10','2026-07-12 15:21:10'),(2296,9,561,2597,1,NULL,1,'2026-07-12 15:21:10','2026-07-12 15:21:10'),(2297,9,561,2628,1,NULL,1,'2026-07-12 15:21:10','2026-07-12 15:21:10'),(2298,3,561,2473,1,NULL,1,'2026-07-12 15:21:10','2026-07-12 15:21:10'),(2299,3,561,2504,1,NULL,1,'2026-07-12 15:21:10','2026-07-12 15:21:10'),(2300,3,561,2535,1,NULL,1,'2026-07-12 15:21:10','2026-07-12 15:21:10'),(2301,3,561,2566,1,NULL,1,'2026-07-12 15:21:10','2026-07-12 15:21:10'),(2302,3,561,2597,1,NULL,1,'2026-07-12 15:21:10','2026-07-12 15:21:10'),(2303,3,561,2628,1,NULL,1,'2026-07-12 15:21:10','2026-07-12 15:21:10'),(2304,8,418,1503,2,NULL,1,'2026-07-12 15:47:47','2026-07-12 15:47:47'),(2305,8,418,1566,2,NULL,1,'2026-07-12 15:47:47','2026-07-12 15:47:47'),(2306,8,418,1629,2,NULL,1,'2026-07-12 15:47:47','2026-07-12 15:47:47'),(2307,8,418,1692,2,NULL,1,'2026-07-12 15:47:47','2026-07-12 15:47:47'),(2308,8,418,1755,2,NULL,1,'2026-07-12 15:47:47','2026-07-12 15:47:47'),(2309,8,418,1818,2,NULL,1,'2026-07-12 15:47:47','2026-07-12 15:47:47'),(2310,1,418,1503,2,NULL,1,'2026-07-12 15:47:47','2026-07-12 15:47:47'),(2311,1,418,1566,2,NULL,1,'2026-07-12 15:47:47','2026-07-12 15:47:47'),(2312,1,418,1629,2,NULL,1,'2026-07-12 15:47:47','2026-07-12 15:47:47'),(2313,1,418,1692,2,NULL,1,'2026-07-12 15:47:47','2026-07-12 15:47:47'),(2314,1,418,1755,2,NULL,1,'2026-07-12 15:47:47','2026-07-12 15:47:47'),(2315,1,418,1818,2,NULL,1,'2026-07-12 15:47:47','2026-07-12 15:47:47'),(2316,9,418,1503,2,NULL,1,'2026-07-12 15:47:47','2026-07-12 15:47:47'),(2317,9,418,1566,2,NULL,1,'2026-07-12 15:47:47','2026-07-12 15:47:47'),(2318,9,418,1629,2,NULL,1,'2026-07-12 15:47:47','2026-07-12 15:47:47'),(2319,9,418,1692,2,NULL,1,'2026-07-12 15:47:47','2026-07-12 15:47:47'),(2320,9,418,1755,2,NULL,1,'2026-07-12 15:47:48','2026-07-12 15:47:48'),(2321,9,418,1818,2,NULL,1,'2026-07-12 15:47:48','2026-07-12 15:47:48'),(2322,3,418,1503,2,NULL,1,'2026-07-12 15:47:48','2026-07-12 15:47:48'),(2323,3,418,1566,2,NULL,1,'2026-07-12 15:47:48','2026-07-12 15:47:48'),(2324,3,418,1629,2,NULL,1,'2026-07-12 15:47:48','2026-07-12 15:47:48'),(2325,3,418,1692,2,NULL,1,'2026-07-12 15:47:48','2026-07-12 15:47:48'),(2326,3,418,1755,2,NULL,1,'2026-07-12 15:47:48','2026-07-12 15:47:48'),(2327,3,418,1818,2,NULL,1,'2026-07-12 15:47:48','2026-07-12 15:47:48'),(2328,8,418,1503,3,NULL,1,'2026-07-12 15:47:56','2026-07-12 15:47:56'),(2329,8,418,1566,3,NULL,1,'2026-07-12 15:47:56','2026-07-12 15:47:56'),(2330,8,418,1629,3,NULL,1,'2026-07-12 15:47:56','2026-07-12 15:47:56'),(2331,8,418,1692,3,NULL,1,'2026-07-12 15:47:56','2026-07-12 15:47:56'),(2332,8,418,1755,3,NULL,1,'2026-07-12 15:47:56','2026-07-12 15:47:56'),(2333,8,418,1818,3,NULL,1,'2026-07-12 15:47:56','2026-07-12 15:47:56'),(2334,1,418,1503,3,NULL,1,'2026-07-12 15:47:56','2026-07-12 15:47:56'),(2335,1,418,1566,3,NULL,1,'2026-07-12 15:47:56','2026-07-12 15:47:56'),(2336,1,418,1629,3,NULL,1,'2026-07-12 15:47:56','2026-07-12 15:47:56'),(2337,1,418,1692,3,NULL,1,'2026-07-12 15:47:56','2026-07-12 15:47:56'),(2338,1,418,1755,3,NULL,1,'2026-07-12 15:47:56','2026-07-12 15:47:56'),(2339,1,418,1818,3,NULL,1,'2026-07-12 15:47:56','2026-07-12 15:47:56'),(2340,9,418,1503,3,NULL,1,'2026-07-12 15:47:56','2026-07-12 15:47:56'),(2341,9,418,1566,3,NULL,1,'2026-07-12 15:47:56','2026-07-12 15:47:56'),(2342,9,418,1629,3,NULL,1,'2026-07-12 15:47:56','2026-07-12 15:47:56'),(2343,9,418,1692,3,NULL,1,'2026-07-12 15:47:56','2026-07-12 15:47:56'),(2344,9,418,1755,3,NULL,1,'2026-07-12 15:47:56','2026-07-12 15:47:56'),(2345,9,418,1818,3,NULL,1,'2026-07-12 15:47:56','2026-07-12 15:47:56'),(2346,3,418,1503,3,NULL,1,'2026-07-12 15:47:56','2026-07-12 15:47:56'),(2347,3,418,1566,3,NULL,1,'2026-07-12 15:47:56','2026-07-12 15:47:56'),(2348,3,418,1629,3,NULL,1,'2026-07-12 15:47:56','2026-07-12 15:47:56'),(2349,3,418,1692,3,NULL,1,'2026-07-12 15:47:56','2026-07-12 15:47:56'),(2350,3,418,1755,3,NULL,1,'2026-07-12 15:47:56','2026-07-12 15:47:56'),(2351,3,418,1818,3,NULL,1,'2026-07-12 15:47:56','2026-07-12 15:47:56'),(2382,8,93,508,1,9.00,1,'2026-07-12 23:12:28','2026-07-12 23:12:40'),(2383,8,93,509,1,9.00,1,'2026-07-12 23:12:28','2026-07-12 23:12:40'),(2384,8,93,510,1,9.00,1,'2026-07-12 23:12:28','2026-07-12 23:12:40'),(2385,8,93,511,1,9.00,1,'2026-07-12 23:12:28','2026-07-12 23:12:40'),(2386,8,93,512,1,9.00,1,'2026-07-12 23:12:28','2026-07-12 23:12:40'),(2387,8,93,513,1,9.00,1,'2026-07-12 23:12:28','2026-07-12 23:12:40'),(2388,1,93,508,1,NULL,1,'2026-07-12 23:12:28','2026-07-12 23:12:28'),(2389,1,93,509,1,NULL,1,'2026-07-12 23:12:28','2026-07-12 23:12:28'),(2390,1,93,510,1,NULL,1,'2026-07-12 23:12:28','2026-07-12 23:12:28'),(2391,1,93,511,1,NULL,1,'2026-07-12 23:12:28','2026-07-12 23:12:28'),(2392,1,93,512,1,NULL,1,'2026-07-12 23:12:28','2026-07-12 23:12:28'),(2393,1,93,513,1,NULL,1,'2026-07-12 23:12:28','2026-07-12 23:12:28'),(2394,9,93,508,1,NULL,1,'2026-07-12 23:12:28','2026-07-12 23:12:28'),(2395,9,93,509,1,NULL,1,'2026-07-12 23:12:28','2026-07-12 23:12:28'),(2396,9,93,510,1,NULL,1,'2026-07-12 23:12:28','2026-07-12 23:12:28'),(2397,9,93,511,1,NULL,1,'2026-07-12 23:12:28','2026-07-12 23:12:28'),(2398,9,93,512,1,NULL,1,'2026-07-12 23:12:28','2026-07-12 23:12:28'),(2399,9,93,513,1,NULL,1,'2026-07-12 23:12:28','2026-07-12 23:12:28'),(2400,3,93,508,1,NULL,1,'2026-07-12 23:12:28','2026-07-12 23:12:28'),(2401,3,93,509,1,NULL,1,'2026-07-12 23:12:28','2026-07-12 23:12:28'),(2402,3,93,510,1,NULL,1,'2026-07-12 23:12:28','2026-07-12 23:12:28'),(2403,3,93,511,1,NULL,1,'2026-07-12 23:12:28','2026-07-12 23:12:28'),(2404,3,93,512,1,NULL,1,'2026-07-12 23:12:28','2026-07-12 23:12:28'),(2405,3,93,513,1,NULL,1,'2026-07-12 23:12:28','2026-07-12 23:12:28');
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
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `calificaciones_disciplina`
--

LOCK TABLES `calificaciones_disciplina` WRITE;
/*!40000 ALTER TABLE `calificaciones_disciplina` DISABLE KEYS */;
INSERT INTO `calificaciones_disciplina` VALUES (1,8,8,1,10.00,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(2,8,15,1,10.00,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(3,8,22,1,10.00,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(4,8,29,1,10.00,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(5,8,36,1,10.00,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(6,8,43,1,10.00,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(7,1,8,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(8,1,15,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(9,1,22,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(10,1,29,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(11,1,36,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(12,1,43,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(13,9,8,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(14,9,15,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(15,9,22,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(16,9,29,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(17,9,36,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(18,9,43,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(19,3,8,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(20,3,15,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(21,3,22,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(22,3,29,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(23,3,36,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(24,3,43,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53');
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
-- Table structure for table `config_aspectos_global`
--

DROP TABLE IF EXISTS `config_aspectos_global`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `config_aspectos_global` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `seccion` enum('maternal','preescolar','primaria','secundaria') NOT NULL,
  `nombre_aspecto` varchar(50) NOT NULL,
  `porcentaje_default` decimal(5,2) NOT NULL,
  `orden_default` tinyint(3) unsigned NOT NULL,
  `aplica_ausencias` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Si aplica a materias tipo ausencias',
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_seccion_aspecto` (`seccion`,`nombre_aspecto`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `config_aspectos_global`
--

LOCK TABLES `config_aspectos_global` WRITE;
/*!40000 ALTER TABLE `config_aspectos_global` DISABLE KEYS */;
INSERT INTO `config_aspectos_global` VALUES (1,'primaria','Examen',50.00,1,0,1,'2026-06-14 22:47:27'),(2,'primaria','Tareas',10.00,2,0,1,'2026-06-14 22:47:27'),(3,'primaria','Participación',10.00,3,0,1,'2026-06-14 22:47:27'),(4,'primaria','Evaluación Parcial',10.00,4,0,1,'2026-06-14 22:47:27'),(5,'primaria','Proyecto',10.00,5,0,1,'2026-06-14 22:47:27'),(6,'primaria','Trabajo y Exposiciones',10.00,6,0,1,'2026-06-14 22:47:27'),(7,'secundaria','Examen',50.00,1,0,1,'2026-06-14 22:47:27'),(8,'secundaria','Tareas',10.00,2,0,1,'2026-06-14 22:47:27'),(9,'secundaria','Participación',10.00,3,0,1,'2026-06-14 22:47:27'),(10,'secundaria','Evaluación Parcial',10.00,4,0,1,'2026-06-14 22:47:27'),(11,'secundaria','Proyecto',10.00,5,0,1,'2026-06-14 22:47:27'),(12,'secundaria','Trabajo y Exposiciones',10.00,6,0,1,'2026-06-14 22:47:27'),(13,'preescolar','Participación en Clase',25.00,1,0,1,'2026-06-14 22:47:27'),(14,'preescolar','Tareas y Actividades',25.00,2,0,1,'2026-06-14 22:47:27'),(15,'preescolar','Trabajo en Equipo',25.00,3,0,1,'2026-06-14 22:47:27'),(16,'preescolar','Creatividad y Expresión',25.00,4,0,1,'2026-06-14 22:47:27'),(17,'maternal','Desarrollo Psicomotor',0.00,1,0,1,'2026-06-14 22:47:27'),(18,'maternal','Desarrollo Socioemocional',0.00,2,0,1,'2026-06-14 22:47:27'),(19,'maternal','Lenguaje y Comunicación',0.00,3,0,1,'2026-06-14 22:47:27');
/*!40000 ALTER TABLE `config_aspectos_global` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `config_aspectos_por_grado`
--

DROP TABLE IF EXISTS `config_aspectos_por_grado`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `config_aspectos_por_grado` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `seccion` enum('maternal','preescolar','primaria','secundaria') NOT NULL,
  `grado` tinyint(3) unsigned NOT NULL,
  `nombre_aspecto` varchar(50) NOT NULL,
  `porcentaje` decimal(5,2) NOT NULL,
  `orden` tinyint(3) unsigned NOT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_grado_aspecto` (`seccion`,`grado`,`nombre_aspecto`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `config_aspectos_por_grado`
--

LOCK TABLES `config_aspectos_por_grado` WRITE;
/*!40000 ALTER TABLE `config_aspectos_por_grado` DISABLE KEYS */;
INSERT INTO `config_aspectos_por_grado` VALUES (1,'primaria',6,'Examen',60.00,1,1,'2026-06-14 22:47:27'),(2,'primaria',6,'Tareas',10.00,2,1,'2026-06-14 22:47:27'),(3,'primaria',6,'Participación',10.00,3,1,'2026-06-14 22:47:27'),(4,'primaria',6,'Evaluación Parcial',10.00,4,1,'2026-06-14 22:47:27'),(5,'primaria',6,'Proyecto',5.00,5,1,'2026-06-14 22:47:27'),(6,'primaria',6,'Trabajo y Exposiciones',5.00,6,1,'2026-06-14 22:47:27'),(13,'secundaria',3,'Examen',60.00,1,1,'2026-06-15 00:20:50'),(14,'secundaria',3,'Tareas',10.00,2,1,'2026-06-15 00:20:50'),(15,'secundaria',3,'Participación',10.00,3,1,'2026-06-15 00:20:50'),(16,'secundaria',3,'Evaluación Parcial',10.00,4,1,'2026-06-15 00:20:50'),(17,'secundaria',3,'Proyecto',5.00,5,1,'2026-06-15 00:20:50'),(18,'secundaria',3,'Trabajo y Exposiciones',5.00,6,1,'2026-06-15 00:20:50');
/*!40000 ALTER TABLE `config_aspectos_por_grado` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=1140 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `grados_materias`
--

LOCK TABLES `grados_materias` WRITE;
/*!40000 ALTER TABLE `grados_materias` DISABLE KEYS */;
INSERT INTO `grados_materias` VALUES (293,'primaria',6,14,4,0,1),(294,'primaria',6,3,1,0,1),(295,'primaria',6,10,2,0,1),(791,'secundaria',1,300,2,1,1),(792,'secundaria',2,300,2,2,1),(793,'secundaria',3,300,2,3,1),(794,'secundaria',1,301,2,4,1),(795,'secundaria',2,301,2,5,1),(796,'secundaria',3,301,2,6,1),(797,'secundaria',1,302,2,7,1),(798,'secundaria',2,302,2,8,1),(799,'secundaria',3,302,2,9,1),(800,'primaria',5,299,NULL,1,1),(801,'primaria',6,299,NULL,2,1),(878,'primaria',2,1,1,7,1),(890,'primaria',2,9,2,1,1),(891,'primaria',2,14,4,2,1),(892,'primaria',2,13,3,3,1),(893,'primaria',2,3,NULL,4,1),(894,'primaria',2,11,3,5,1),(895,'primaria',2,12,3,6,1),(896,'primaria',2,5,2,8,1),(897,'primaria',2,16,4,9,1),(898,'primaria',2,10,2,10,1),(899,'primaria',2,15,4,11,1),(900,'primaria',2,4,1,21,1),(1026,'primaria',2,27,1,22,1),(1027,'primaria',2,28,1,23,1),(1028,'primaria',3,4,1,21,1),(1029,'primaria',3,27,1,22,1),(1030,'primaria',3,28,1,23,1),(1031,'primaria',4,4,1,21,1),(1032,'primaria',4,27,1,22,1),(1033,'primaria',4,28,1,23,1),(1034,'primaria',5,4,1,21,1),(1035,'primaria',5,27,1,22,1),(1036,'primaria',5,29,1,24,1),(1037,'primaria',6,4,1,21,1),(1038,'primaria',6,27,1,22,1),(1039,'primaria',6,29,1,24,1),(1040,'secundaria',1,27,1,22,1),(1041,'secundaria',1,29,1,24,1),(1042,'secundaria',2,27,1,22,1),(1043,'secundaria',2,29,1,24,1),(1044,'secundaria',3,27,1,22,1),(1045,'secundaria',3,29,1,24,1),(1118,'primaria',1,13,3,7,1),(1119,'primaria',1,1,1,1,1),(1120,'primaria',1,5,2,4,1),(1121,'primaria',1,16,4,10,1),(1122,'primaria',1,15,4,9,1),(1123,'primaria',1,9,2,5,1),(1124,'primaria',1,282,1,14,1),(1125,'primaria',1,279,1,11,1),(1126,'primaria',1,280,1,12,1),(1127,'primaria',1,278,1,10,1),(1128,'primaria',1,286,1,16,1),(1129,'primaria',1,285,1,15,1),(1130,'primaria',1,281,1,13,1),(1131,'primaria',1,4,1,21,1),(1132,'primaria',1,28,1,23,1),(1133,'primaria',1,27,1,22,1),(1134,'primaria',1,14,4,8,1),(1137,'primaria',1,23,1,8,1),(1138,'primaria',1,297,NULL,19,1),(1139,'primaria',1,298,NULL,20,1);
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `grupo_titular`
--

LOCK TABLES `grupo_titular` WRITE;
/*!40000 ALTER TABLE `grupo_titular` DISABLE KEYS */;
INSERT INTO `grupo_titular` VALUES (1,1,346,1,'primaria',1,'A','2026-07-12 17:48:26'),(2,1,113,1,'primaria',1,'B','2026-07-12 17:49:05');
/*!40000 ALTER TABLE `grupo_titular` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `grupos`
--

DROP TABLE IF EXISTS `grupos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `grupos` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `seccion` enum('maternal','preescolar','primaria','secundaria') NOT NULL,
  `grado` tinyint(3) unsigned NOT NULL,
  `nombre` varchar(10) NOT NULL,
  `orden` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_grupo` (`seccion`,`grado`,`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `grupos`
--

LOCK TABLES `grupos` WRITE;
/*!40000 ALTER TABLE `grupos` DISABLE KEYS */;
INSERT INTO `grupos` VALUES (1,'primaria',1,'A',1,1,'2026-06-14 23:25:59'),(2,'primaria',1,'B',2,1,'2026-06-14 23:25:59'),(3,'primaria',1,'C',3,1,'2026-06-14 23:25:59'),(4,'primaria',1,'D',4,1,'2026-06-14 23:25:59'),(5,'primaria',2,'A',1,1,'2026-06-14 23:25:59'),(6,'primaria',2,'B',2,1,'2026-06-14 23:25:59'),(7,'primaria',2,'C',3,1,'2026-06-14 23:25:59'),(8,'primaria',2,'D',4,1,'2026-06-14 23:25:59'),(9,'primaria',3,'A',1,1,'2026-06-14 23:25:59'),(10,'primaria',3,'B',2,1,'2026-06-14 23:25:59'),(11,'primaria',3,'C',3,1,'2026-06-14 23:25:59'),(12,'primaria',3,'D',4,1,'2026-06-14 23:25:59'),(13,'primaria',4,'A',1,1,'2026-06-14 23:25:59'),(14,'primaria',4,'B',2,1,'2026-06-14 23:25:59'),(15,'primaria',4,'C',3,1,'2026-06-14 23:25:59'),(16,'primaria',4,'D',4,1,'2026-06-14 23:25:59'),(17,'primaria',5,'A',1,1,'2026-06-14 23:25:59'),(18,'primaria',5,'B',2,1,'2026-06-14 23:25:59'),(19,'primaria',5,'C',3,1,'2026-06-14 23:25:59'),(20,'primaria',5,'D',4,1,'2026-06-14 23:25:59'),(21,'primaria',6,'A',1,1,'2026-06-14 23:25:59'),(22,'primaria',6,'B',2,1,'2026-06-14 23:25:59'),(23,'primaria',6,'C',3,1,'2026-06-14 23:25:59'),(24,'primaria',6,'D',4,1,'2026-06-14 23:25:59'),(25,'secundaria',1,'A',1,1,'2026-06-14 23:25:59'),(26,'secundaria',1,'B',2,1,'2026-06-14 23:25:59'),(27,'secundaria',1,'C',3,1,'2026-06-14 23:25:59'),(28,'secundaria',1,'D',4,1,'2026-06-14 23:25:59'),(29,'secundaria',2,'A',1,1,'2026-06-14 23:25:59'),(30,'secundaria',2,'B',2,1,'2026-06-14 23:25:59'),(31,'secundaria',2,'C',3,1,'2026-06-14 23:25:59'),(32,'secundaria',2,'D',4,1,'2026-06-14 23:25:59'),(33,'secundaria',3,'A',1,1,'2026-06-14 23:25:59'),(34,'secundaria',3,'B',2,1,'2026-06-14 23:25:59'),(35,'secundaria',3,'C',3,1,'2026-06-14 23:25:59'),(36,'secundaria',3,'D',4,1,'2026-06-14 23:25:59'),(37,'preescolar',1,'A',1,1,'2026-06-14 23:25:59'),(38,'preescolar',1,'B',2,1,'2026-06-14 23:25:59'),(39,'preescolar',1,'C',3,1,'2026-06-14 23:25:59'),(40,'preescolar',1,'D',4,1,'2026-06-14 23:25:59'),(41,'preescolar',2,'A',1,1,'2026-06-14 23:25:59'),(42,'preescolar',2,'B',2,1,'2026-06-14 23:25:59'),(43,'preescolar',2,'C',3,1,'2026-06-14 23:25:59'),(44,'preescolar',2,'D',4,1,'2026-06-14 23:25:59'),(45,'preescolar',3,'A',1,1,'2026-06-14 23:25:59'),(46,'preescolar',3,'B',2,1,'2026-06-14 23:25:59'),(47,'preescolar',3,'C',3,1,'2026-06-14 23:25:59'),(48,'preescolar',3,'D',4,1,'2026-06-14 23:25:59'),(49,'maternal',1,'A',1,1,'2026-06-14 23:26:00'),(50,'maternal',1,'B',2,1,'2026-06-14 23:26:00'),(51,'maternal',1,'C',3,1,'2026-06-14 23:26:00'),(52,'maternal',1,'D',4,1,'2026-06-14 23:26:00'),(53,'maternal',2,'A',1,1,'2026-06-14 23:26:00'),(54,'maternal',2,'B',2,1,'2026-06-14 23:26:00'),(55,'maternal',2,'C',3,1,'2026-06-14 23:26:00'),(56,'maternal',2,'D',4,1,'2026-06-14 23:26:00'),(57,'maternal',3,'A',1,1,'2026-06-14 23:26:00'),(58,'maternal',3,'B',2,1,'2026-06-14 23:26:00'),(59,'maternal',3,'C',3,1,'2026-06-14 23:26:00'),(60,'maternal',3,'D',4,1,'2026-06-14 23:26:00');
/*!40000 ALTER TABLE `grupos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `grupos_catalogo`
--

DROP TABLE IF EXISTS `grupos_catalogo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `grupos_catalogo` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `seccion` enum('maternal','preescolar','primaria','secundaria') NOT NULL,
  `grado` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `nombre` varchar(10) NOT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_grupo` (`seccion`,`grado`,`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=66 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `grupos_catalogo`
--

LOCK TABLES `grupos_catalogo` WRITE;
/*!40000 ALTER TABLE `grupos_catalogo` DISABLE KEYS */;
INSERT INTO `grupos_catalogo` VALUES (1,'secundaria',1,'A',1),(2,'secundaria',1,'B',1),(5,'secundaria',2,'A',1),(6,'secundaria',2,'B',1),(9,'secundaria',3,'A',1),(10,'secundaria',3,'B',1),(13,'preescolar',1,'A',1),(14,'preescolar',1,'B',1),(15,'preescolar',1,'C',1),(16,'preescolar',1,'D',1),(17,'preescolar',2,'A',1),(18,'preescolar',2,'B',1),(19,'preescolar',2,'C',1),(20,'preescolar',2,'D',1),(21,'preescolar',3,'A',1),(22,'preescolar',3,'B',1),(23,'preescolar',3,'C',1),(24,'preescolar',3,'D',1),(25,'maternal',1,'A',1),(37,'primaria',1,'A',1),(38,'primaria',1,'B',1),(39,'primaria',1,'C',1),(40,'primaria',1,'D',1),(41,'primaria',2,'A',1),(42,'primaria',2,'B',1),(45,'primaria',3,'A',1),(46,'primaria',3,'B',1),(49,'primaria',4,'A',1),(50,'primaria',4,'B',1),(51,'primaria',4,'C',1),(52,'primaria',4,'D',1),(53,'primaria',5,'A',1),(54,'primaria',5,'B',1),(55,'primaria',5,'C',1),(56,'primaria',5,'D',1),(57,'primaria',6,'A',1),(58,'primaria',6,'B',1),(59,'primaria',6,'C',1),(60,'primaria',6,'D',1),(61,'primaria',2,'C',1),(62,'primaria',2,'D',1),(63,'primaria',3,'C',1),(64,'primaria',3,'D',1);
/*!40000 ALTER TABLE `grupos_catalogo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ingles_subcomponentes`
--

DROP TABLE IF EXISTS `ingles_subcomponentes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ingles_subcomponentes` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(80) NOT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ingles_subcomponentes`
--

LOCK TABLES `ingles_subcomponentes` WRITE;
/*!40000 ALTER TABLE `ingles_subcomponentes` DISABLE KEYS */;
INSERT INTO `ingles_subcomponentes` VALUES (1,'Listening',1),(2,'Speaking',1),(3,'Writing',1),(4,'Reading',1),(5,'Vocabulary',1),(6,'Grammar',1),(7,'Spelling',1),(8,'Science',1),(9,'Phonetics',1),(10,'Social Studies',1),(11,'Literature',1);
/*!40000 ALTER TABLE `ingles_subcomponentes` ENABLE KEYS */;
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
  `grupo_visual` varchar(30) DEFAULT NULL COMMENT 'base|ciencias|ingles|artes|cocurriculares|higiene|disciplina|ausencias',
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_materia_campo` (`campo_formativo_id`),
  CONSTRAINT `fk_materia_campo` FOREIGN KEY (`campo_formativo_id`) REFERENCES `campos_formativos` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=308 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `materias`
--

LOCK TABLES `materias` WRITE;
/*!40000 ALTER TABLE `materias` DISABLE KEYS */;
INSERT INTO `materias` VALUES (1,'Lengua Materna',1,0,0,0,0,0,'base',1,'2026-06-09 12:20:56'),(3,'Francés',NULL,0,0,0,0,0,'cocurriculares',1,'2026-06-09 12:20:56'),(4,'Artes',1,0,1,0,0,0,'artes',1,'2026-06-09 12:20:56'),(5,'Matemáticas',2,0,0,0,0,0,'base',1,'2026-06-09 12:20:56'),(9,'Ciencias Naturales',2,0,0,0,0,0,'ciencias',1,'2026-05-24 10:26:38'),(10,'Tecnología',2,0,0,0,0,0,'cocurriculares',1,'2026-05-24 10:26:38'),(11,'Geografía',3,0,0,0,0,0,'base',1,'2026-05-24 10:26:38'),(12,'Historia',3,0,0,0,0,0,'base',1,'2026-05-24 10:26:38'),(13,'Formación Cívica y Ética',3,0,0,0,0,0,'base',1,'2026-05-24 10:26:38'),(14,'Educación Física',4,0,0,0,0,0,'cocurriculares',1,'2026-05-24 10:26:38'),(15,'Vida Saludable',4,0,0,0,0,0,'base',1,'2026-05-24 10:26:38'),(16,'Socioemocional',4,0,0,0,0,0,'base',1,'2026-05-24 10:26:38'),(17,'Higiene',NULL,0,0,1,0,0,'higiene',1,'2026-05-24 10:26:38'),(18,'Writing',1,1,0,0,0,0,'ingles',0,'2026-06-09 12:20:56'),(19,'Reading',1,1,0,0,0,0,'ingles',0,'2026-06-09 12:20:56'),(20,'Vocabulary',1,1,0,0,0,0,'ingles',0,'2026-06-09 12:20:56'),(21,'Grammar',1,1,0,0,0,0,'ingles',0,'2026-06-09 12:20:56'),(22,'Spelling',1,1,0,0,0,0,'ingles',0,'2026-06-09 12:20:56'),(23,'Science',1,1,0,0,0,0,'ingles',0,'2026-06-09 12:20:56'),(27,'Música',4,0,1,0,0,0,'artes',1,'2026-05-29 20:39:47'),(28,'Danza',1,0,1,0,0,0,'artes',1,'2026-05-29 20:39:47'),(29,'Teatro',4,0,1,0,0,0,'artes',1,'2026-05-29 20:39:47'),(30,'Dibujo',1,0,1,0,0,0,'artes',0,'2026-05-29 20:39:47'),(278,'Speaking',1,1,0,0,0,0,'ingles',1,'2026-06-03 20:05:55'),(279,'Listening',1,1,0,0,0,0,'ingles',1,'2026-06-03 20:05:55'),(280,'Reading',1,1,0,0,0,0,'ingles',1,'2026-06-03 20:05:55'),(281,'Writing',1,1,0,0,0,0,'ingles',1,'2026-06-03 20:05:55'),(282,'Grammar',1,1,0,0,0,0,'ingles',1,'2026-06-03 20:05:55'),(285,'Vocabulary',1,1,0,0,0,0,'ingles',1,'2026-06-04 17:04:04'),(286,'Spelling',1,1,0,0,0,0,'ingles',1,'2026-06-04 17:04:04'),(287,'Phonetics',1,1,0,0,0,0,'ingles',1,'2026-06-04 17:04:04'),(288,'Science',1,1,0,0,0,0,'ingles',1,'2026-06-04 17:04:04'),(289,'Social Studies',1,1,0,0,0,0,'ingles',1,'2026-06-04 17:04:04'),(290,'Literature',1,1,0,0,0,0,'ingles',1,'2026-06-04 17:04:04'),(297,'Disciplina',NULL,0,0,0,1,0,'disciplina',1,'2026-06-06 15:32:47'),(298,'Ausencias',NULL,0,0,0,0,1,'ausencias',1,'2026-06-06 15:32:48'),(299,'Laboratorio',NULL,0,0,0,0,0,'cocurriculares',1,'2026-06-08 16:48:57'),(300,'Física',2,0,0,0,0,0,'ciencias',1,'2026-06-09 12:01:58'),(301,'Química',2,0,0,0,0,0,'ciencias',1,'2026-06-09 12:01:58'),(302,'Biología',2,0,0,0,0,0,'ciencias',1,'2026-06-09 12:01:58'),(304,'Entidad donde Vivo',3,0,0,0,0,0,'base',1,'2026-06-14 12:33:19');
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
INSERT INTO `padre_alumno` VALUES (1,1),(1,3),(2,5),(3,9),(7,8);
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
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `padres`
--

LOCK TABLES `padres` WRITE;
/*!40000 ALTER TABLE `padres` DISABLE KEYS */;
INSERT INTO `padres` VALUES (1,2,'Javier Omar','Moreno','Arellano','masculino','7773220180','7772517476','jomaevan13@gmail.com','MOAJ880128HMSRRV03','2026-05-15 17:24:12'),(2,6,'Amy','Lee','Lynn','femenino','7773220180','7772517476','jomaevan18@gmail.com','MOMA191006MMSRNMA9','2026-05-15 18:07:36'),(3,102,'MARIA MONSERRAT','DIAZ','MEJíA','femenino','7772201708','','monchstar_2@hotmail.es','DIMM870318MDFZJN08','2026-06-23 10:18:36'),(5,109,'Perla','Lopez','Diaz','femenino','7771234567','7771234569','perladia@gmail.com','LOHR950324HDFRNS08','2026-07-03 12:27:08'),(7,112,'Perla','Lopez','Diaz','femenino','7771234567','7771234569','perladia@gmail.com','LOHR950324HDFRNS09','2026-07-03 12:32:36');
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
INSERT INTO `profesores` VALUES (1,12,'Sughey Adriana','Moreno','Arellano','MOAS820608MMSRRG04','1982-06-08','femenino','titular','7773220180','adriana23@gmail.com',1,'2026-05-24 10:06:41'),(2,13,'Ana','Izquierdo','Bello',NULL,'1970-03-09','femenino','titular',NULL,NULL,1,'2026-05-28 07:28:10'),(3,14,'Mateo Adrian','Fuentes','Moreno',NULL,'2001-09-11','masculino','frances','7773220180',NULL,1,'2026-05-30 11:50:29'),(4,15,'Mateo','Fuentes','Moreno','','2001-09-11','masculino','titular','7773220180','',1,'2026-05-30 11:55:05'),(5,16,'Angel David','Fuentes','Moreno',NULL,'2000-09-13','masculino','cocurricular',NULL,NULL,1,'2026-06-02 16:44:31'),(6,17,'Javier Alejandro','Moreno','Arellano','MOAS820608MMSRRG89','2000-07-27','masculino','cocurricular','2203591435','jomaevan13@gmail.com',1,'2026-06-02 18:04:51');
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
) ENGINE=InnoDB AUTO_INCREMENT=115 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'superadmin','$2y$10$F6bwXR9C73lmTlUAnxlme.9YDF/FLiccDp/zhLJeBzOeD6xkJPb4e',1,1,'2026-05-15 16:47:22'),(2,'morarejavieromar','$2y$10$5AIH2lcLCnlsXDyCDwafsusbSqViH.HnaSCui3SmTj5e7A9FeEY3G',2,1,'2026-05-15 17:24:12'),(4,'mormonamy','$2y$10$hhXxSIEyaxL.8BY51BXZBuHQ0oPFOLE8W3p/guM8kRFMRKAqzytX.',3,1,'2026-05-15 17:50:28'),(6,'leelynamy','$2y$10$.JpZmEjxJ2dWhk7ykonxbOZ6pXjf/JSDaSo7Bfygcde8jNIb/duLW',2,1,'2026-05-15 18:07:36'),(8,'sanarameribe','$2y$10$Z4lY3VuYUmszJhY.gfqNv.260KIJQ3I8K7Q0v9H68twC.ET0h/HMe',3,1,'2026-05-16 19:16:27'),(9,'morareanamaria','$2y$10$vwkjxH1RtOR2tSBRIUg3tudBhom1B5k5pNqppqTP84kTNjLdcqX2q',3,1,'2026-05-17 09:56:31'),(10,'morareanamaria1','$2y$10$Z7YbL3/8mWB6cyMPW1BbWelnmD27Ouob4A700062F3xdN1gzUjUci',3,1,'2026-05-17 10:02:47'),(12,'moraresugheyadriana','$2y$10$wCXHc2t1ecZEMh9uwl5SO.ULqtmRSBssZQoife.VZLux/8L7e1iq6',4,1,'2026-05-24 10:06:41'),(13,'izqbelana','$2y$10$P4xBHRGg.WPp3tI.Zgbs7u8Mx/AVZNctHbfaTo3YZu/LGwFjfsTgW',4,1,'2026-05-28 07:28:10'),(14,'fuemormateoadrian','$2y$10$ioHpNE3WYc8zJNMsMaK6y.Q3eDmM6G3HVR8Zh6Lw/to6tofzI8Ece',4,1,'2026-05-30 11:50:29'),(15,'fuemormateoadrian1','$2y$10$Yi2nriutVa0AYopqXgLNkeonb3VY8jW7mCvtzF32REnnIC8nWnGri',4,1,'2026-05-30 11:55:05'),(16,'fuemorangeldavid','$2y$10$JGP2ysYIC90mQyvQ0nSgUOYNd8EGUWMaRrBbj3Qrfym8S4B/u55Iu',4,1,'2026-06-02 16:44:31'),(17,'morarealejandor','$2y$10$NHEKDxW0CTNQHnSJTpkkV.nsTMFa.JjKaLMUz1QLQj.BXi.3pxPwK',4,1,'2026-06-02 18:04:51'),(100,'alumno_temp_1','',3,0,'2026-06-09 12:20:56'),(101,'alumno_temp_2','',3,0,'2026-06-09 12:20:56'),(102,'diamejmariamonserrat','$2y$10$LGluuF2hAH5wg7n/8ekzkOPoOQrLn1SbmPwTPyYVBs5JET1DFtpsW',2,1,'2026-06-23 10:18:36'),(109,'lopdiaperla','$2y$10$KnC.xApyMsBWKp3JIQCyPONHzzigA09yDpF5gj5gVqrHrCTBvwsA.',2,1,'2026-07-03 12:27:08'),(112,'lopdiaperla1','$2y$10$AYXTv3TkZm1KuFoYCaQ.NexVwPINizj.QHh.oFQzlK3sdTy0H3VTC',2,1,'2026-07-03 12:32:36'),(113,'gardiajulia','$2y$10$fUnJgyVQlIw1lWfDLV23zeKEr/Q9FeylpsRznLOcLJqgJXgvr8fvu',3,1,'2026-07-03 12:32:36'),(114,'percorjesus','$2y$10$h6AFWzbRE7h7MEJbmDfHG.YDWa.dUjPHZUHUsF9/D7Fj6PMtSfO5.',3,1,'2026-07-03 12:34:12');
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
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-12 23:19:00
