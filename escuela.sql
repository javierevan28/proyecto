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
  `estatus` enum('nuevo_ingreso','reinscripcion','regular','baja') NOT NULL DEFAULT 'regular' COMMENT 'Estatus del alumno',
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  UNIQUE KEY `curp` (`curp`),
  UNIQUE KEY `matricula` (`matricula`),
  KEY `idx_estatus` (`estatus`),
  CONSTRAINT `alumnos_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alumnos`
--

LOCK TABLES `alumnos` WRITE;
/*!40000 ALTER TABLE `alumnos` DISABLE KEYS */;
INSERT INTO `alumnos` VALUES (1,4,NULL,'Amy','Moreno','Montes','MOMA191006MMSRNMA5','2019-10-06','femenino','estudiante',1,'A','primaria',1,'2026-05-15 17:50:28','regular'),(3,8,'CEFSAMX20260517000001','Meribe','Sanchez','Aranda','MOMA191006MMSRNMA9','2018-12-13','femenino','estudiante',1,'A','primaria',1,'2026-05-16 19:16:27','regular'),(5,10,'CEFMAAM20260517000001','Ana Maria','Moreno','Arellano','MOAJ000516HMNRRV09','2021-01-28','femenino','estudiante',2,'A','preescolar',1,'2026-05-17 10:02:47','regular');
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
) ENGINE=InnoDB AUTO_INCREMENT=130 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignacion_aspectos`
--

LOCK TABLES `asignacion_aspectos` WRITE;
/*!40000 ALTER TABLE `asignacion_aspectos` DISABLE KEYS */;
INSERT INTO `asignacion_aspectos` VALUES (1,39,'Examen',50.00,1,1),(2,39,'Tareas',10.00,2,1),(3,39,'Participación',10.00,3,1),(4,39,'Evaluación Parcial',10.00,4,1),(5,39,'Proyecto',10.00,5,1),(6,39,'Trabajo y Exposiciones',10.00,6,1),(7,44,'Examen',50.00,1,1),(8,44,'Tareas',10.00,2,1),(9,44,'Participación',10.00,3,1),(10,44,'Evaluación Parcial',10.00,4,1),(11,44,'Proyecto',10.00,5,1),(12,44,'Trabajo y Exposiciones',10.00,6,1),(13,46,'Examen',50.00,1,1),(14,46,'Tareas',10.00,2,1),(15,46,'Participación',10.00,3,1),(16,46,'Evaluación Parcial',10.00,4,1),(17,46,'Proyecto',10.00,5,1),(18,46,'Trabajo y Exposiciones',10.00,6,1),(19,40,'Examen',50.00,1,1),(20,40,'Tareas',10.00,2,1),(21,40,'Participación',10.00,3,1),(22,40,'Evaluación Parcial',10.00,4,1),(23,40,'Proyecto',10.00,5,1),(24,40,'Trabajo y Exposiciones',10.00,6,1),(25,36,'Examen',50.00,1,1),(26,36,'Tareas',10.00,2,1),(27,36,'Participación',10.00,3,1),(28,36,'Evaluación Parcial',10.00,4,1),(29,36,'Proyecto',10.00,5,1),(30,36,'Trabajo y Exposiciones',10.00,6,1),(31,42,'Examen',50.00,1,1),(32,42,'Tareas',10.00,2,1),(33,42,'Participación',10.00,3,1),(34,42,'Evaluación Parcial',10.00,4,1),(35,42,'Proyecto',10.00,5,1),(36,42,'Trabajo y Exposiciones',10.00,6,1),(37,38,'Examen',50.00,1,1),(38,38,'Tareas',10.00,2,1),(39,38,'Participación',10.00,3,1),(40,38,'Evaluación Parcial',10.00,4,1),(41,38,'Proyecto',10.00,5,1),(42,38,'Trabajo y Exposiciones',10.00,6,1),(43,37,'Examen',50.00,1,1),(44,37,'Tareas',10.00,2,1),(45,37,'Participación',10.00,3,1),(46,37,'Evaluación Parcial',10.00,4,1),(47,37,'Proyecto',10.00,5,1),(48,37,'Trabajo y Exposiciones',10.00,6,1),(49,43,'Examen',50.00,1,1),(50,43,'Tareas',10.00,2,1),(51,43,'Participación',10.00,3,1),(52,43,'Evaluación Parcial',10.00,4,1),(53,43,'Proyecto',10.00,5,1),(54,43,'Trabajo y Exposiciones',10.00,6,1),(55,41,'Examen',50.00,1,1),(56,41,'Tareas',10.00,2,1),(57,41,'Participación',10.00,3,1),(58,41,'Evaluación Parcial',10.00,4,1),(59,41,'Proyecto',10.00,5,1),(60,41,'Trabajo y Exposiciones',10.00,6,1),(61,47,'Examen',50.00,1,1),(62,47,'Tareas',10.00,2,1),(63,47,'Participación',10.00,3,1),(64,47,'Evaluación Parcial',10.00,4,1),(65,47,'Proyecto',10.00,5,1),(66,47,'Trabajo y Exposiciones',10.00,6,1),(67,48,'Examen',50.00,1,1),(68,48,'Tareas',10.00,2,1),(69,48,'Participación',10.00,3,1),(70,48,'Evaluación Parcial',10.00,4,1),(71,48,'Proyecto',10.00,5,1),(72,48,'Trabajo y Exposiciones',10.00,6,1),(73,45,'Examen',50.00,1,1),(74,45,'Tareas',10.00,2,1),(75,45,'Participación',10.00,3,1),(76,45,'Evaluación Parcial',10.00,4,1),(77,45,'Proyecto',10.00,5,1),(78,45,'Trabajo y Exposiciones',10.00,6,1);
/*!40000 ALTER TABLE `asignacion_aspectos` ENABLE KEYS */;
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
  `orden` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'Orden en la boleta',
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_ingles_aspecto` (`asignacion_id`,`nombre`),
  CONSTRAINT `fk_asigIngles_asig` FOREIGN KEY (`asignacion_id`) REFERENCES `asignaciones` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=185 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignacion_ingles_aspectos`
--

LOCK TABLES `asignacion_ingles_aspectos` WRITE;
/*!40000 ALTER TABLE `asignacion_ingles_aspectos` DISABLE KEYS */;
INSERT INTO `asignacion_ingles_aspectos` VALUES (169,NULL,1,'primaria','Listening',0,1),(170,NULL,1,'primaria','Speaking',0,1),(171,NULL,1,'primaria','Reading',0,1),(172,NULL,1,'primaria','Writing',0,1),(173,NULL,1,'primaria','Vocabulary',0,1),(174,NULL,1,'primaria','Grammar',0,1),(175,NULL,1,'primaria','Spelling',0,1),(176,NULL,1,'primaria','Science',0,1),(177,44,1,'primaria','Listening',0,1),(178,44,1,'primaria','Speaking',0,1),(179,44,1,'primaria','Reading',0,1),(180,44,1,'primaria','Writing',0,1),(181,44,1,'primaria','Vocabulary',0,1),(182,44,1,'primaria','Grammar',0,1),(183,44,1,'primaria','Spelling',0,1),(184,44,1,'primaria','Science',0,1);
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
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignacion_maestros`
--

LOCK TABLES `asignacion_maestros` WRITE;
/*!40000 ALTER TABLE `asignacion_maestros` DISABLE KEYS */;
INSERT INTO `asignacion_maestros` VALUES (29,36,1,1,0,'2026-05-30 19:43:36',1),(30,38,1,1,0,'2026-05-30 19:43:36',1),(31,39,1,1,0,'2026-05-30 19:43:36',1),(32,40,1,1,0,'2026-05-30 19:43:36',1),(33,41,1,1,0,'2026-05-30 19:43:36',1),(34,43,1,1,0,'2026-05-30 19:43:36',1),(35,44,4,0,0,'2026-05-30 20:24:31',1),(36,46,5,0,0,'2026-06-02 17:10:34',1);
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
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignaciones`
--

LOCK TABLES `asignaciones` WRITE;
/*!40000 ALTER TABLE `asignaciones` DISABLE KEYS */;
INSERT INTO `asignaciones` VALUES (36,1,9,2,'primaria',1,'A',0,1,'2026-05-30 19:43:36'),(37,1,14,4,'primaria',1,'A',0,1,'2026-05-30 19:43:36'),(38,1,13,3,'primaria',1,'A',0,1,'2026-05-30 19:43:36'),(39,1,2,1,'primaria',1,'A',0,1,'2026-05-30 19:43:36'),(40,1,8,2,'primaria',1,'A',0,1,'2026-05-30 19:43:36'),(41,1,16,4,'primaria',1,'A',0,1,'2026-05-30 19:43:36'),(42,1,10,2,'primaria',1,'A',0,1,'2026-05-30 19:43:36'),(43,1,15,4,'primaria',1,'A',0,1,'2026-05-30 19:43:36'),(44,1,5,1,'primaria',1,'A',0,1,'2026-05-30 20:24:31'),(45,1,29,4,'primaria',1,'A',0,1,'2026-06-02 16:00:31'),(46,1,7,1,'primaria',1,'A',0,1,'2026-06-02 16:00:31'),(47,1,27,4,'primaria',1,'A',0,1,'2026-06-02 16:00:31'),(48,1,28,1,'primaria',1,'A',0,1,'2026-06-02 16:00:31');
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
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `calificaciones`
--

LOCK TABLES `calificaciones` WRITE;
/*!40000 ALTER TABLE `calificaciones` DISABLE KEYS */;
INSERT INTO `calificaciones` VALUES (1,1,40,19,1,9.00,1,'2026-06-03 15:33:29','2026-06-03 15:33:29'),(2,1,40,20,1,9.00,1,'2026-06-03 15:33:29','2026-06-03 15:33:29'),(3,1,40,21,1,9.00,1,'2026-06-03 15:33:29','2026-06-03 15:33:29'),(4,1,40,22,1,9.00,1,'2026-06-03 15:33:29','2026-06-03 15:33:29'),(5,1,40,23,1,9.00,1,'2026-06-03 15:33:29','2026-06-03 15:33:29'),(6,1,40,24,1,9.00,1,'2026-06-03 15:33:29','2026-06-03 15:33:29'),(7,3,40,19,1,NULL,1,'2026-06-03 15:33:29','2026-06-03 15:33:29'),(8,3,40,20,1,NULL,1,'2026-06-03 15:33:29','2026-06-03 15:33:29'),(9,3,40,21,1,NULL,1,'2026-06-03 15:33:29','2026-06-03 15:33:29'),(10,3,40,22,1,NULL,1,'2026-06-03 15:33:29','2026-06-03 15:33:29'),(11,3,40,23,1,NULL,1,'2026-06-03 15:33:29','2026-06-03 15:33:29'),(12,3,40,24,1,NULL,1,'2026-06-03 15:33:29','2026-06-03 15:33:29');
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
INSERT INTO `calificaciones_artes` VALUES (1,1,46,1,10,1,'2026-06-02 16:33:42','2026-06-02 16:33:42'),(2,1,47,1,9,1,'2026-06-02 16:33:42','2026-06-02 16:33:42'),(3,1,48,1,8,1,'2026-06-02 16:33:42','2026-06-02 16:33:42'),(5,1,46,2,9,1,'2026-06-02 16:37:45','2026-06-02 16:37:45'),(6,1,47,2,8,1,'2026-06-02 16:37:45','2026-06-02 16:37:45'),(7,1,48,2,7,1,'2026-06-02 16:37:45','2026-06-02 16:37:45'),(8,1,46,3,10,1,'2026-06-02 16:37:45','2026-06-02 16:37:45'),(9,1,47,3,9,1,'2026-06-02 16:37:45','2026-06-02 16:37:45'),(10,1,48,3,8,1,'2026-06-02 16:37:45','2026-06-02 16:37:45'),(11,1,46,4,9,1,'2026-06-02 16:37:45','2026-06-02 16:37:45'),(12,1,47,4,8,1,'2026-06-02 16:37:45','2026-06-02 16:37:45'),(13,1,48,4,7,1,'2026-06-02 16:37:45','2026-06-02 16:37:45'),(14,1,46,5,10,1,'2026-06-02 16:37:45','2026-06-02 16:37:45'),(15,1,47,5,9,1,'2026-06-02 16:37:45','2026-06-02 16:37:45'),(16,1,48,5,8,1,'2026-06-02 16:37:45','2026-06-02 16:37:45'),(17,1,46,6,9,1,'2026-06-02 16:37:45','2026-06-02 16:37:45'),(18,1,47,6,8,1,'2026-06-02 16:37:45','2026-06-02 16:37:45'),(19,1,48,6,7,1,'2026-06-02 16:37:45','2026-06-02 16:37:45');
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
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `calificaciones_ingles`
--

LOCK TABLES `calificaciones_ingles` WRITE;
/*!40000 ALTER TABLE `calificaciones_ingles` DISABLE KEYS */;
INSERT INTO `calificaciones_ingles` VALUES (36,1,169,1,9,4,'2026-06-02 15:21:56','2026-06-02 15:21:56'),(37,1,170,1,8,4,'2026-06-02 15:21:56','2026-06-02 15:21:56'),(38,1,171,1,9,4,'2026-06-02 15:21:56','2026-06-02 15:21:56'),(39,1,172,1,7,4,'2026-06-02 15:21:56','2026-06-02 15:21:56'),(40,1,173,1,9,4,'2026-06-02 15:21:56','2026-06-02 15:21:56'),(41,1,174,1,8,4,'2026-06-02 15:21:56','2026-06-02 15:21:56'),(42,1,175,1,8,4,'2026-06-02 15:21:56','2026-06-02 15:21:56'),(43,1,176,1,7,4,'2026-06-02 15:21:56','2026-06-02 15:21:56'),(44,3,169,1,NULL,4,'2026-06-02 15:21:56','2026-06-02 15:21:56'),(45,3,170,1,NULL,4,'2026-06-02 15:21:56','2026-06-02 15:21:56'),(46,3,171,1,NULL,4,'2026-06-02 15:21:56','2026-06-02 15:21:56'),(47,3,172,1,NULL,4,'2026-06-02 15:21:56','2026-06-02 15:21:56'),(48,3,173,1,NULL,4,'2026-06-02 15:21:56','2026-06-02 15:21:56'),(49,3,174,1,NULL,4,'2026-06-02 15:21:56','2026-06-02 15:21:56'),(50,3,175,1,NULL,4,'2026-06-02 15:21:56','2026-06-02 15:21:56'),(51,3,176,1,NULL,4,'2026-06-02 15:21:56','2026-06-02 15:21:56');
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
) ENGINE=InnoDB AUTO_INCREMENT=312 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `grados_materias`
--

LOCK TABLES `grados_materias` WRITE;
/*!40000 ALTER TABLE `grados_materias` DISABLE KEYS */;
INSERT INTO `grados_materias` VALUES (130,'primaria',2,9,NULL,1,1),(131,'primaria',2,14,NULL,2,1),(132,'primaria',2,13,NULL,3,1),(133,'primaria',2,6,NULL,4,1),(134,'primaria',2,11,NULL,5,1),(135,'primaria',2,12,NULL,6,1),(136,'primaria',2,2,NULL,7,1),(137,'primaria',2,8,NULL,8,1),(138,'primaria',2,16,NULL,9,1),(139,'primaria',2,10,NULL,10,1),(140,'primaria',2,15,NULL,11,1),(159,'primaria',2,7,NULL,20,1),(161,'primaria',2,27,NULL,21,1),(163,'primaria',2,28,NULL,22,1),(165,'primaria',3,7,NULL,20,1),(166,'primaria',4,7,NULL,20,1),(167,'primaria',3,27,NULL,21,1),(168,'primaria',4,27,NULL,21,1),(169,'primaria',3,28,NULL,22,1),(170,'primaria',4,28,NULL,22,1),(171,'primaria',3,29,NULL,23,1),(172,'primaria',4,29,NULL,23,1),(180,'primaria',5,7,NULL,20,1),(182,'primaria',5,27,NULL,21,1),(184,'primaria',5,28,NULL,22,1),(186,'primaria',5,29,NULL,23,1),(188,'primaria',5,30,NULL,24,1),(195,'secundaria',1,7,NULL,20,1),(196,'secundaria',2,7,NULL,20,1),(197,'secundaria',3,7,NULL,20,1),(198,'secundaria',1,27,NULL,21,1),(199,'secundaria',2,27,NULL,21,1),(200,'secundaria',3,27,NULL,21,1),(201,'secundaria',1,28,NULL,22,1),(202,'secundaria',2,28,NULL,22,1),(203,'secundaria',3,28,NULL,22,1),(204,'secundaria',1,29,NULL,23,1),(205,'secundaria',2,29,NULL,23,1),(206,'secundaria',3,29,NULL,23,1),(207,'secundaria',1,30,NULL,24,1),(208,'secundaria',2,30,NULL,24,1),(209,'secundaria',3,30,NULL,24,1),(268,'primaria',1,9,NULL,1,1),(269,'primaria',1,13,NULL,3,1),(270,'primaria',1,2,NULL,4,1),(271,'primaria',1,8,NULL,5,1),(272,'primaria',1,16,NULL,6,1),(273,'primaria',1,15,NULL,8,1),(275,'primaria',1,5,NULL,0,1),(283,'primaria',1,7,NULL,20,1),(284,'primaria',1,28,NULL,22,1),(285,'primaria',1,27,NULL,21,1),(286,'primaria',1,14,NULL,2,1),(287,'primaria',1,10,NULL,7,1),(288,'primaria',6,7,1,20,1),(289,'primaria',6,28,1,22,1),(290,'primaria',6,30,1,24,1),(291,'primaria',6,27,4,21,1),(292,'primaria',6,29,4,23,1),(293,'primaria',6,14,4,0,1),(294,'primaria',6,6,1,0,1),(295,'primaria',6,10,2,0,1);
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
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_materia_campo` (`campo_formativo_id`),
  CONSTRAINT `fk_materia_campo` FOREIGN KEY (`campo_formativo_id`) REFERENCES `campos_formativos` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=163 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `materias`
--

LOCK TABLES `materias` WRITE;
/*!40000 ALTER TABLE `materias` DISABLE KEYS */;
INSERT INTO `materias` VALUES (2,'Lengua Materna',1,0,0,0,1,'2026-05-21 21:47:08'),(5,'Inglés',1,1,0,0,1,'2026-05-24 10:26:38'),(6,'Francés',1,0,0,0,1,'2026-05-24 10:26:38'),(7,'Artes',1,0,1,0,1,'2026-05-24 10:26:38'),(8,'Matemáticas',2,0,0,0,1,'2026-05-24 10:26:38'),(9,'Ciencias Naturales',2,0,0,0,1,'2026-05-24 10:26:38'),(10,'Tecnología',2,0,0,0,1,'2026-05-24 10:26:38'),(11,'Geografía',3,0,0,0,1,'2026-05-24 10:26:38'),(12,'Historia',3,0,0,0,1,'2026-05-24 10:26:38'),(13,'F.C. y E.',3,0,0,0,1,'2026-05-24 10:26:38'),(14,'Educación Física',4,0,0,0,1,'2026-05-24 10:26:38'),(15,'Vida Saludable',4,0,0,0,1,'2026-05-24 10:26:38'),(16,'Socioemocional',4,0,0,0,1,'2026-05-24 10:26:38'),(17,'Higiene',NULL,0,0,1,1,'2026-05-24 10:26:38'),(27,'Música',4,0,1,0,1,'2026-05-29 20:39:47'),(28,'Danza',1,0,1,0,1,'2026-05-29 20:39:47'),(29,'Teatro',4,0,1,0,1,'2026-05-29 20:39:47'),(30,'Dibujo',1,0,1,0,1,'2026-05-29 20:39:47'),(73,'English 1 - Speaking',1,1,0,0,1,'2026-06-03 19:20:17'),(74,'English 1 - Listening',1,1,0,0,1,'2026-06-03 19:20:17'),(75,'English 1 - Reading',1,1,0,0,1,'2026-06-03 19:20:17'),(76,'English 1 - Writing',1,1,0,0,1,'2026-06-03 19:20:17'),(77,'English 1 - Grammar',1,1,0,0,1,'2026-06-03 19:20:17'),(78,'English 2 - Speaking',1,1,0,0,1,'2026-06-03 19:20:17'),(79,'English 2 - Listening',1,1,0,0,1,'2026-06-03 19:20:17'),(80,'English 2 - Reading',1,1,0,0,1,'2026-06-03 19:20:17'),(81,'English 2 - Writing',1,1,0,0,1,'2026-06-03 19:20:17'),(82,'English 2 - Grammar',1,1,0,0,1,'2026-06-03 19:20:17'),(83,'English 3 - Speaking',1,1,0,0,1,'2026-06-03 19:20:17'),(84,'English 3 - Listening',1,1,0,0,1,'2026-06-03 19:20:17'),(85,'English 3 - Reading',1,1,0,0,1,'2026-06-03 19:20:17'),(86,'English 3 - Writing',1,1,0,0,1,'2026-06-03 19:20:17'),(87,'English 3 - Grammar',1,1,0,0,1,'2026-06-03 19:20:17'),(88,'English 4 - Speaking',1,1,0,0,1,'2026-06-03 19:20:17'),(89,'English 4 - Listening',1,1,0,0,1,'2026-06-03 19:20:17'),(90,'English 4 - Reading',1,1,0,0,1,'2026-06-03 19:20:17'),(91,'English 4 - Writing',1,1,0,0,1,'2026-06-03 19:20:17'),(92,'English 4 - Grammar',1,1,0,0,1,'2026-06-03 19:20:17'),(93,'English 5 - Speaking',1,1,0,0,1,'2026-06-03 19:20:17'),(94,'English 5 - Listening',1,1,0,0,1,'2026-06-03 19:20:17'),(95,'English 5 - Reading',1,1,0,0,1,'2026-06-03 19:20:17'),(96,'English 5 - Writing',1,1,0,0,1,'2026-06-03 19:20:17'),(97,'English 5 - Grammar',1,1,0,0,1,'2026-06-03 19:20:17'),(98,'English 6 - Speaking',1,1,0,0,1,'2026-06-03 19:20:17'),(99,'English 6 - Listening',1,1,0,0,1,'2026-06-03 19:20:17'),(100,'English 6 - Reading',1,1,0,0,1,'2026-06-03 19:20:17'),(101,'English 6 - Writing',1,1,0,0,1,'2026-06-03 19:20:17'),(102,'English 6 - Grammar',1,1,0,0,1,'2026-06-03 19:20:17'),(103,'English 1 Sec - Speaking',1,1,0,0,1,'2026-06-03 19:20:17'),(104,'English 1 Sec - Listening',1,1,0,0,1,'2026-06-03 19:20:17'),(105,'English 1 Sec - Reading',1,1,0,0,1,'2026-06-03 19:20:17'),(106,'English 1 Sec - Writing',1,1,0,0,1,'2026-06-03 19:20:17'),(107,'English 1 Sec - Grammar',1,1,0,0,1,'2026-06-03 19:20:17'),(108,'English 2 Sec - Speaking',1,1,0,0,1,'2026-06-03 19:20:17'),(109,'English 2 Sec - Listening',1,1,0,0,1,'2026-06-03 19:20:17'),(110,'English 2 Sec - Reading',1,1,0,0,1,'2026-06-03 19:20:17'),(111,'English 2 Sec - Writing',1,1,0,0,1,'2026-06-03 19:20:17'),(112,'English 2 Sec - Grammar',1,1,0,0,1,'2026-06-03 19:20:17'),(113,'English 3 Sec - Speaking',1,1,0,0,1,'2026-06-03 19:20:18'),(114,'English 3 Sec - Listening',1,1,0,0,1,'2026-06-03 19:20:18'),(115,'English 3 Sec - Reading',1,1,0,0,1,'2026-06-03 19:20:18'),(116,'English 3 Sec - Writing',1,1,0,0,1,'2026-06-03 19:20:18'),(117,'English 3 Sec - Grammar',1,1,0,0,1,'2026-06-03 19:20:18'),(118,'English 1 - Speaking',1,1,0,0,1,'2026-06-03 19:24:04'),(119,'English 1 - Listening',1,1,0,0,1,'2026-06-03 19:24:04'),(120,'English 1 - Reading',1,1,0,0,1,'2026-06-03 19:24:04'),(121,'English 1 - Writing',1,1,0,0,1,'2026-06-03 19:24:04'),(122,'English 1 - Grammar',1,1,0,0,1,'2026-06-03 19:24:04'),(123,'English 2 - Speaking',1,1,0,0,1,'2026-06-03 19:24:04'),(124,'English 2 - Listening',1,1,0,0,1,'2026-06-03 19:24:04'),(125,'English 2 - Reading',1,1,0,0,1,'2026-06-03 19:24:04'),(126,'English 2 - Writing',1,1,0,0,1,'2026-06-03 19:24:04'),(127,'English 2 - Grammar',1,1,0,0,1,'2026-06-03 19:24:04'),(128,'English 3 - Speaking',1,1,0,0,1,'2026-06-03 19:24:04'),(129,'English 3 - Listening',1,1,0,0,1,'2026-06-03 19:24:04'),(130,'English 3 - Reading',1,1,0,0,1,'2026-06-03 19:24:04'),(131,'English 3 - Writing',1,1,0,0,1,'2026-06-03 19:24:04'),(132,'English 3 - Grammar',1,1,0,0,1,'2026-06-03 19:24:04'),(133,'English 4 - Speaking',1,1,0,0,1,'2026-06-03 19:24:04'),(134,'English 4 - Listening',1,1,0,0,1,'2026-06-03 19:24:04'),(135,'English 4 - Reading',1,1,0,0,1,'2026-06-03 19:24:04'),(136,'English 4 - Writing',1,1,0,0,1,'2026-06-03 19:24:04'),(137,'English 4 - Grammar',1,1,0,0,1,'2026-06-03 19:24:04'),(138,'English 5 - Speaking',1,1,0,0,1,'2026-06-03 19:24:04'),(139,'English 5 - Listening',1,1,0,0,1,'2026-06-03 19:24:04'),(140,'English 5 - Reading',1,1,0,0,1,'2026-06-03 19:24:04'),(141,'English 5 - Writing',1,1,0,0,1,'2026-06-03 19:24:04'),(142,'English 5 - Grammar',1,1,0,0,1,'2026-06-03 19:24:04'),(143,'English 6 - Speaking',1,1,0,0,1,'2026-06-03 19:24:04'),(144,'English 6 - Listening',1,1,0,0,1,'2026-06-03 19:24:04'),(145,'English 6 - Reading',1,1,0,0,1,'2026-06-03 19:24:04'),(146,'English 6 - Writing',1,1,0,0,1,'2026-06-03 19:24:04'),(147,'English 6 - Grammar',1,1,0,0,1,'2026-06-03 19:24:04'),(148,'English 1 Sec - Speaking',1,1,0,0,1,'2026-06-03 19:24:04'),(149,'English 1 Sec - Listening',1,1,0,0,1,'2026-06-03 19:24:04'),(150,'English 1 Sec - Reading',1,1,0,0,1,'2026-06-03 19:24:04'),(151,'English 1 Sec - Writing',1,1,0,0,1,'2026-06-03 19:24:04'),(152,'English 1 Sec - Grammar',1,1,0,0,1,'2026-06-03 19:24:04'),(153,'English 2 Sec - Speaking',1,1,0,0,1,'2026-06-03 19:24:04'),(154,'English 2 Sec - Listening',1,1,0,0,1,'2026-06-03 19:24:04'),(155,'English 2 Sec - Reading',1,1,0,0,1,'2026-06-03 19:24:04'),(156,'English 2 Sec - Writing',1,1,0,0,1,'2026-06-03 19:24:04'),(157,'English 2 Sec - Grammar',1,1,0,0,1,'2026-06-03 19:24:04'),(158,'English 3 Sec - Speaking',1,1,0,0,1,'2026-06-03 19:24:05'),(159,'English 3 Sec - Listening',1,1,0,0,1,'2026-06-03 19:24:05'),(160,'English 3 Sec - Reading',1,1,0,0,1,'2026-06-03 19:24:05'),(161,'English 3 Sec - Writing',1,1,0,0,1,'2026-06-03 19:24:05'),(162,'English 3 Sec - Grammar',1,1,0,0,1,'2026-06-03 19:24:05');
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
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'superadmin','$2y$10$F6bwXR9C73lmTlUAnxlme.9YDF/FLiccDp/zhLJeBzOeD6xkJPb4e',1,1,'2026-05-15 16:47:22'),(2,'morarejavieromar','$2y$10$5AIH2lcLCnlsXDyCDwafsusbSqViH.HnaSCui3SmTj5e7A9FeEY3G',2,1,'2026-05-15 17:24:12'),(4,'mormonamy','$2y$10$hhXxSIEyaxL.8BY51BXZBuHQ0oPFOLE8W3p/guM8kRFMRKAqzytX.',3,1,'2026-05-15 17:50:28'),(6,'leelynamy','$2y$10$.JpZmEjxJ2dWhk7ykonxbOZ6pXjf/JSDaSo7Bfygcde8jNIb/duLW',2,1,'2026-05-15 18:07:36'),(8,'sanarameribe','$2y$10$Z4lY3VuYUmszJhY.gfqNv.260KIJQ3I8K7Q0v9H68twC.ET0h/HMe',3,1,'2026-05-16 19:16:27'),(9,'morareanamaria','$2y$10$vwkjxH1RtOR2tSBRIUg3tudBhom1B5k5pNqppqTP84kTNjLdcqX2q',3,1,'2026-05-17 09:56:31'),(10,'morareanamaria1','$2y$10$Z7YbL3/8mWB6cyMPW1BbWelnmD27Ouob4A700062F3xdN1gzUjUci',3,1,'2026-05-17 10:02:47'),(12,'moraresugheyadriana','$2y$10$wCXHc2t1ecZEMh9uwl5SO.ULqtmRSBssZQoife.VZLux/8L7e1iq6',4,1,'2026-05-24 10:06:41'),(13,'izqbelana','$2y$10$P4xBHRGg.WPp3tI.Zgbs7u8Mx/AVZNctHbfaTo3YZu/LGwFjfsTgW',4,1,'2026-05-28 07:28:10'),(14,'fuemormateoadrian','$2y$10$ioHpNE3WYc8zJNMsMaK6y.Q3eDmM6G3HVR8Zh6Lw/to6tofzI8Ece',4,1,'2026-05-30 11:50:29'),(15,'fuemormateoadrian1','$2y$10$Yi2nriutVa0AYopqXgLNkeonb3VY8jW7mCvtzF32REnnIC8nWnGri',4,1,'2026-05-30 11:55:05'),(16,'fuemorangeldavid','$2y$10$JGP2ysYIC90mQyvQ0nSgUOYNd8EGUWMaRrBbj3Qrfym8S4B/u55Iu',4,1,'2026-06-02 16:44:31'),(17,'morarealejandor','$2y$10$NHEKDxW0CTNQHnSJTpkkV.nsTMFa.JjKaLMUz1QLQj.BXi.3pxPwK',4,1,'2026-06-02 18:04:51');
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

-- Dump completed on 2026-06-03 19:28:51
