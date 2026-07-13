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
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignacion_artes_aspectos`
--

LOCK TABLES `asignacion_artes_aspectos` WRITE;
/*!40000 ALTER TABLE `asignacion_artes_aspectos` DISABLE KEYS */;
INSERT INTO `asignacion_artes_aspectos` VALUES (1,416,1,'Examen',50.00,1,1),(2,416,1,'Tareas',10.00,2,1),(3,416,1,'Participación',10.00,3,1),(4,416,1,'Evaluación Parcial',10.00,4,1),(5,416,1,'Proyecto',10.00,5,1),(6,416,1,'Trabajo y Exposiciones',10.00,6,1);
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
) ENGINE=InnoDB AUTO_INCREMENT=2241 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignacion_aspectos`
--

LOCK TABLES `asignacion_aspectos` WRITE;
/*!40000 ALTER TABLE `asignacion_aspectos` DISABLE KEYS */;
INSERT INTO `asignacion_aspectos` VALUES (1,113,'Examen',50.00,1,1),(2,148,'Examen',50.00,1,1),(3,163,'Examen',50.00,1,1),(4,200,'Examen',50.00,1,1),(5,231,'Examen',50.00,1,1),(6,314,'Examen',50.00,1,1),(7,315,'Examen',50.00,1,1),(8,316,'Examen',50.00,1,1),(10,149,'Examen',50.00,1,1),(11,164,'Examen',50.00,1,1),(12,150,'Examen',50.00,1,1),(13,165,'Examen',50.00,1,1),(14,201,'Examen',50.00,1,1),(15,232,'Examen',50.00,1,1),(16,93,'Examen',50.00,1,1),(17,116,'Examen',50.00,1,1),(18,142,'Examen',50.00,1,1),(19,145,'Examen',50.00,1,1),(20,202,'Examen',50.00,1,1),(21,233,'Examen',50.00,1,1),(22,310,'Examen',50.00,1,1),(23,311,'Examen',50.00,1,1),(24,312,'Examen',50.00,1,1),(26,455,'Examen',50.00,1,1),(27,456,'Examen',50.00,1,1),(28,465,'Examen',50.00,1,1),(29,466,'Examen',50.00,1,1),(30,467,'Examen',50.00,1,1),(31,468,'Examen',50.00,1,1),(32,477,'Examen',50.00,1,1),(33,478,'Examen',50.00,1,1),(34,479,'Examen',50.00,1,1),(35,480,'Examen',50.00,1,1),(36,489,'Examen',50.00,1,1),(37,490,'Examen',50.00,1,1),(38,491,'Examen',50.00,1,1),(39,492,'Examen',50.00,1,1),(40,501,'Examen',50.00,1,1),(41,502,'Examen',50.00,1,1),(42,503,'Examen',50.00,1,1),(43,504,'Examen',50.00,1,1),(45,94,'Examen',50.00,1,1),(46,117,'Examen',50.00,1,1),(47,151,'Examen',50.00,1,1),(48,166,'Examen',50.00,1,1),(49,203,'Examen',50.00,1,1),(50,234,'Examen',50.00,1,1),(51,272,'Examen',50.00,1,1),(52,273,'Examen',50.00,1,1),(53,274,'Examen',50.00,1,1),(54,95,'Examen',50.00,1,1),(55,118,'Examen',50.00,1,1),(56,152,'Examen',50.00,1,1),(57,167,'Examen',50.00,1,1),(59,77,'Examen',50.00,1,1),(60,98,'Examen',50.00,1,1),(61,121,'Examen',50.00,1,1),(62,204,'Examen',50.00,1,1),(63,235,'Examen',50.00,1,1),(64,264,'Examen',50.00,1,1),(65,265,'Examen',50.00,1,1),(67,84,'Examen',50.00,1,1),(68,99,'Examen',50.00,1,1),(69,122,'Examen',50.00,1,1),(70,154,'Examen',50.00,1,1),(71,169,'Examen',50.00,1,1),(72,205,'Examen',50.00,1,1),(73,236,'Examen',50.00,1,1),(74,307,'Examen',50.00,1,1),(75,308,'Examen',50.00,1,1),(76,100,'Examen',50.00,1,1),(77,123,'Examen',50.00,1,1),(78,155,'Examen',50.00,1,1),(79,170,'Examen',50.00,1,1),(80,206,'Examen',50.00,1,1),(81,237,'Examen',50.00,1,1),(82,101,'Examen',50.00,1,1),(83,124,'Examen',50.00,1,1),(84,156,'Examen',50.00,1,1),(85,171,'Examen',50.00,1,1),(86,207,'Examen',50.00,1,1),(87,238,'Examen',50.00,1,1),(89,78,'Examen',50.00,1,1),(90,102,'Examen',50.00,1,1),(91,125,'Examen',50.00,1,1),(92,157,'Examen',50.00,1,1),(93,172,'Examen',50.00,1,1),(94,208,'Examen',50.00,1,1),(95,239,'Examen',50.00,1,1),(96,268,'Examen',50.00,1,1),(97,269,'Examen',50.00,1,1),(99,83,'Examen',50.00,1,1),(100,103,'Examen',50.00,1,1),(101,126,'Examen',50.00,1,1),(102,158,'Examen',50.00,1,1),(103,173,'Examen',50.00,1,1),(104,209,'Examen',50.00,1,1),(105,240,'Examen',50.00,1,1),(106,305,'Examen',50.00,1,1),(107,306,'Examen',50.00,1,1),(109,79,'Examen',50.00,1,1),(110,104,'Examen',50.00,1,1),(111,127,'Examen',50.00,1,1),(112,159,'Examen',50.00,1,1),(113,174,'Examen',50.00,1,1),(114,210,'Examen',50.00,1,1),(115,241,'Examen',50.00,1,1),(116,281,'Examen',50.00,1,1),(117,282,'Examen',50.00,1,1),(119,80,'Examen',50.00,1,1),(120,105,'Examen',50.00,1,1),(121,128,'Examen',50.00,1,1),(122,211,'Examen',50.00,1,1),(123,242,'Examen',50.00,1,1),(124,279,'Examen',50.00,1,1),(125,280,'Examen',50.00,1,1),(126,106,'Examen',50.00,1,1),(127,129,'Examen',50.00,1,1),(149,448,'Examen',50.00,1,1),(150,449,'Examen',50.00,1,1),(151,450,'Examen',50.00,1,1),(152,457,'Examen',50.00,1,1),(153,458,'Examen',50.00,1,1),(154,459,'Examen',50.00,1,1),(155,460,'Examen',50.00,1,1),(156,469,'Examen',50.00,1,1),(157,470,'Examen',50.00,1,1),(158,471,'Examen',50.00,1,1),(159,472,'Examen',50.00,1,1),(160,481,'Examen',50.00,1,1),(161,482,'Examen',50.00,1,1),(162,483,'Examen',50.00,1,1),(163,484,'Examen',50.00,1,1),(164,493,'Examen',50.00,1,1),(165,494,'Examen',50.00,1,1),(166,495,'Examen',50.00,1,1),(167,496,'Examen',50.00,1,1),(168,505,'Examen',50.00,1,1),(169,506,'Examen',50.00,1,1),(170,507,'Examen',50.00,1,1),(171,508,'Examen',50.00,1,1),(172,513,'Examen',50.00,1,1),(173,514,'Examen',50.00,1,1),(174,515,'Examen',50.00,1,1),(175,516,'Examen',50.00,1,1),(176,521,'Examen',50.00,1,1),(177,522,'Examen',50.00,1,1),(178,523,'Examen',50.00,1,1),(179,524,'Examen',50.00,1,1),(180,529,'Examen',50.00,1,1),(181,530,'Examen',50.00,1,1),(182,531,'Examen',50.00,1,1),(183,532,'Examen',50.00,1,1),(185,452,'Examen',50.00,1,1),(186,453,'Examen',50.00,1,1),(187,454,'Examen',50.00,1,1),(188,461,'Examen',50.00,1,1),(189,462,'Examen',50.00,1,1),(190,463,'Examen',50.00,1,1),(191,464,'Examen',50.00,1,1),(192,473,'Examen',50.00,1,1),(193,474,'Examen',50.00,1,1),(194,475,'Examen',50.00,1,1),(195,476,'Examen',50.00,1,1),(196,485,'Examen',50.00,1,1),(197,486,'Examen',50.00,1,1),(198,487,'Examen',50.00,1,1),(199,488,'Examen',50.00,1,1),(200,497,'Examen',50.00,1,1),(201,498,'Examen',50.00,1,1),(202,499,'Examen',50.00,1,1),(203,500,'Examen',50.00,1,1),(204,509,'Examen',50.00,1,1),(205,510,'Examen',50.00,1,1),(206,511,'Examen',50.00,1,1),(207,512,'Examen',50.00,1,1),(208,517,'Examen',50.00,1,1),(209,518,'Examen',50.00,1,1),(210,519,'Examen',50.00,1,1),(211,520,'Examen',50.00,1,1),(212,525,'Examen',50.00,1,1),(213,526,'Examen',50.00,1,1),(214,527,'Examen',50.00,1,1),(215,528,'Examen',50.00,1,1),(216,533,'Examen',50.00,1,1),(217,534,'Examen',50.00,1,1),(218,535,'Examen',50.00,1,1),(219,536,'Examen',50.00,1,1),(221,419,'Examen',50.00,1,1),(222,420,'Examen',50.00,1,1),(223,421,'Examen',50.00,1,1),(225,423,'Examen',50.00,1,1),(226,424,'Examen',50.00,1,1),(227,425,'Examen',50.00,1,1),(229,427,'Examen',50.00,1,1),(230,428,'Examen',50.00,1,1),(231,429,'Examen',50.00,1,1),(233,431,'Examen',50.00,1,1),(234,432,'Examen',50.00,1,1),(235,433,'Examen',50.00,1,1),(237,435,'Examen',50.00,1,1),(238,436,'Examen',50.00,1,1),(239,437,'Examen',50.00,1,1),(241,439,'Examen',50.00,1,1),(242,440,'Examen',50.00,1,1),(243,441,'Examen',50.00,1,1),(245,443,'Examen',50.00,1,1),(246,444,'Examen',50.00,1,1),(247,445,'Examen',50.00,1,1),(249,577,'Examen',50.00,1,1),(250,578,'Examen',50.00,1,1),(251,579,'Examen',50.00,1,1),(253,88,'Examen',50.00,1,1),(254,266,'Examen',50.00,1,1),(255,267,'Examen',50.00,1,1),(257,89,'Examen',50.00,1,1),(258,262,'Examen',50.00,1,1),(259,263,'Examen',50.00,1,1),(260,113,'Tareas',10.00,2,1),(261,148,'Tareas',10.00,2,1),(262,163,'Tareas',10.00,2,1),(263,200,'Tareas',10.00,2,1),(264,231,'Tareas',10.00,2,1),(265,314,'Tareas',10.00,2,1),(266,315,'Tareas',10.00,2,1),(267,316,'Tareas',10.00,2,1),(269,149,'Tareas',10.00,2,1),(270,164,'Tareas',10.00,2,1),(271,150,'Tareas',10.00,2,1),(272,165,'Tareas',10.00,2,1),(273,201,'Tareas',10.00,2,1),(274,232,'Tareas',10.00,2,1),(275,93,'Tareas',10.00,2,1),(276,116,'Tareas',10.00,2,1),(277,142,'Tareas',10.00,2,1),(278,145,'Tareas',10.00,2,1),(279,202,'Tareas',10.00,2,1),(280,233,'Tareas',10.00,2,1),(281,310,'Tareas',10.00,2,1),(282,311,'Tareas',10.00,2,1),(283,312,'Tareas',10.00,2,1),(285,455,'Tareas',10.00,2,1),(286,456,'Tareas',10.00,2,1),(287,465,'Tareas',10.00,2,1),(288,466,'Tareas',10.00,2,1),(289,467,'Tareas',10.00,2,1),(290,468,'Tareas',10.00,2,1),(291,477,'Tareas',10.00,2,1),(292,478,'Tareas',10.00,2,1),(293,479,'Tareas',10.00,2,1),(294,480,'Tareas',10.00,2,1),(295,489,'Tareas',10.00,2,1),(296,490,'Tareas',10.00,2,1),(297,491,'Tareas',10.00,2,1),(298,492,'Tareas',10.00,2,1),(299,501,'Tareas',10.00,2,1),(300,502,'Tareas',10.00,2,1),(301,503,'Tareas',10.00,2,1),(302,504,'Tareas',10.00,2,1),(304,94,'Tareas',10.00,2,1),(305,117,'Tareas',10.00,2,1),(306,151,'Tareas',10.00,2,1),(307,166,'Tareas',10.00,2,1),(308,203,'Tareas',10.00,2,1),(309,234,'Tareas',10.00,2,1),(310,272,'Tareas',10.00,2,1),(311,273,'Tareas',10.00,2,1),(312,274,'Tareas',10.00,2,1),(313,95,'Tareas',10.00,2,1),(314,118,'Tareas',10.00,2,1),(315,152,'Tareas',10.00,2,1),(316,167,'Tareas',10.00,2,1),(318,77,'Tareas',10.00,2,1),(319,98,'Tareas',10.00,2,1),(320,121,'Tareas',10.00,2,1),(321,204,'Tareas',10.00,2,1),(322,235,'Tareas',10.00,2,1),(323,264,'Tareas',10.00,2,1),(324,265,'Tareas',10.00,2,1),(326,84,'Tareas',10.00,2,1),(327,99,'Tareas',10.00,2,1),(328,122,'Tareas',10.00,2,1),(329,154,'Tareas',10.00,2,1),(330,169,'Tareas',10.00,2,1),(331,205,'Tareas',10.00,2,1),(332,236,'Tareas',10.00,2,1),(333,307,'Tareas',10.00,2,1),(334,308,'Tareas',10.00,2,1),(335,100,'Tareas',10.00,2,1),(336,123,'Tareas',10.00,2,1),(337,155,'Tareas',10.00,2,1),(338,170,'Tareas',10.00,2,1),(339,206,'Tareas',10.00,2,1),(340,237,'Tareas',10.00,2,1),(341,101,'Tareas',10.00,2,1),(342,124,'Tareas',10.00,2,1),(343,156,'Tareas',10.00,2,1),(344,171,'Tareas',10.00,2,1),(345,207,'Tareas',10.00,2,1),(346,238,'Tareas',10.00,2,1),(348,78,'Tareas',10.00,2,1),(349,102,'Tareas',10.00,2,1),(350,125,'Tareas',10.00,2,1),(351,157,'Tareas',10.00,2,1),(352,172,'Tareas',10.00,2,1),(353,208,'Tareas',10.00,2,1),(354,239,'Tareas',10.00,2,1),(355,268,'Tareas',10.00,2,1),(356,269,'Tareas',10.00,2,1),(358,83,'Tareas',10.00,2,1),(359,103,'Tareas',10.00,2,1),(360,126,'Tareas',10.00,2,1),(361,158,'Tareas',10.00,2,1),(362,173,'Tareas',10.00,2,1),(363,209,'Tareas',10.00,2,1),(364,240,'Tareas',10.00,2,1),(365,305,'Tareas',10.00,2,1),(366,306,'Tareas',10.00,2,1),(368,79,'Tareas',10.00,2,1),(369,104,'Tareas',10.00,2,1),(370,127,'Tareas',10.00,2,1),(371,159,'Tareas',10.00,2,1),(372,174,'Tareas',10.00,2,1),(373,210,'Tareas',10.00,2,1),(374,241,'Tareas',10.00,2,1),(375,281,'Tareas',10.00,2,1),(376,282,'Tareas',10.00,2,1),(378,80,'Tareas',10.00,2,1),(379,105,'Tareas',10.00,2,1),(380,128,'Tareas',10.00,2,1),(381,211,'Tareas',10.00,2,1),(382,242,'Tareas',10.00,2,1),(383,279,'Tareas',10.00,2,1),(384,280,'Tareas',10.00,2,1),(385,106,'Tareas',10.00,2,1),(386,129,'Tareas',10.00,2,1),(408,448,'Tareas',10.00,2,1),(409,449,'Tareas',10.00,2,1),(410,450,'Tareas',10.00,2,1),(411,457,'Tareas',10.00,2,1),(412,458,'Tareas',10.00,2,1),(413,459,'Tareas',10.00,2,1),(414,460,'Tareas',10.00,2,1),(415,469,'Tareas',10.00,2,1),(416,470,'Tareas',10.00,2,1),(417,471,'Tareas',10.00,2,1),(418,472,'Tareas',10.00,2,1),(419,481,'Tareas',10.00,2,1),(420,482,'Tareas',10.00,2,1),(421,483,'Tareas',10.00,2,1),(422,484,'Tareas',10.00,2,1),(423,493,'Tareas',10.00,2,1),(424,494,'Tareas',10.00,2,1),(425,495,'Tareas',10.00,2,1),(426,496,'Tareas',10.00,2,1),(427,505,'Tareas',10.00,2,1),(428,506,'Tareas',10.00,2,1),(429,507,'Tareas',10.00,2,1),(430,508,'Tareas',10.00,2,1),(431,513,'Tareas',10.00,2,1),(432,514,'Tareas',10.00,2,1),(433,515,'Tareas',10.00,2,1),(434,516,'Tareas',10.00,2,1),(435,521,'Tareas',10.00,2,1),(436,522,'Tareas',10.00,2,1),(437,523,'Tareas',10.00,2,1),(438,524,'Tareas',10.00,2,1),(439,529,'Tareas',10.00,2,1),(440,530,'Tareas',10.00,2,1),(441,531,'Tareas',10.00,2,1),(442,532,'Tareas',10.00,2,1),(444,452,'Tareas',10.00,2,1),(445,453,'Tareas',10.00,2,1),(446,454,'Tareas',10.00,2,1),(447,461,'Tareas',10.00,2,1),(448,462,'Tareas',10.00,2,1),(449,463,'Tareas',10.00,2,1),(450,464,'Tareas',10.00,2,1),(451,473,'Tareas',10.00,2,1),(452,474,'Tareas',10.00,2,1),(453,475,'Tareas',10.00,2,1),(454,476,'Tareas',10.00,2,1),(455,485,'Tareas',10.00,2,1),(456,486,'Tareas',10.00,2,1),(457,487,'Tareas',10.00,2,1),(458,488,'Tareas',10.00,2,1),(459,497,'Tareas',10.00,2,1),(460,498,'Tareas',10.00,2,1),(461,499,'Tareas',10.00,2,1),(462,500,'Tareas',10.00,2,1),(463,509,'Tareas',10.00,2,1),(464,510,'Tareas',10.00,2,1),(465,511,'Tareas',10.00,2,1),(466,512,'Tareas',10.00,2,1),(467,517,'Tareas',10.00,2,1),(468,518,'Tareas',10.00,2,1),(469,519,'Tareas',10.00,2,1),(470,520,'Tareas',10.00,2,1),(471,525,'Tareas',10.00,2,1),(472,526,'Tareas',10.00,2,1),(473,527,'Tareas',10.00,2,1),(474,528,'Tareas',10.00,2,1),(475,533,'Tareas',10.00,2,1),(476,534,'Tareas',10.00,2,1),(477,535,'Tareas',10.00,2,1),(478,536,'Tareas',10.00,2,1),(480,419,'Tareas',10.00,2,1),(481,420,'Tareas',10.00,2,1),(482,421,'Tareas',10.00,2,1),(484,423,'Tareas',10.00,2,1),(485,424,'Tareas',10.00,2,1),(486,425,'Tareas',10.00,2,1),(488,427,'Tareas',10.00,2,1),(489,428,'Tareas',10.00,2,1),(490,429,'Tareas',10.00,2,1),(492,431,'Tareas',10.00,2,1),(493,432,'Tareas',10.00,2,1),(494,433,'Tareas',10.00,2,1),(496,435,'Tareas',10.00,2,1),(497,436,'Tareas',10.00,2,1),(498,437,'Tareas',10.00,2,1),(500,439,'Tareas',10.00,2,1),(501,440,'Tareas',10.00,2,1),(502,441,'Tareas',10.00,2,1),(504,443,'Tareas',10.00,2,1),(505,444,'Tareas',10.00,2,1),(506,445,'Tareas',10.00,2,1),(508,577,'Tareas',10.00,2,1),(509,578,'Tareas',10.00,2,1),(510,579,'Tareas',10.00,2,1),(512,88,'Tareas',10.00,2,1),(513,266,'Tareas',10.00,2,1),(514,267,'Tareas',10.00,2,1),(516,89,'Tareas',10.00,2,1),(517,262,'Tareas',10.00,2,1),(518,263,'Tareas',10.00,2,1),(519,113,'Participación',10.00,3,1),(520,148,'Participación',10.00,3,1),(521,163,'Participación',10.00,3,1),(522,200,'Participación',10.00,3,1),(523,231,'Participación',10.00,3,1),(524,314,'Participación',10.00,3,1),(525,315,'Participación',10.00,3,1),(526,316,'Participación',10.00,3,1),(528,149,'Participación',10.00,3,1),(529,164,'Participación',10.00,3,1),(530,150,'Participación',10.00,3,1),(531,165,'Participación',10.00,3,1),(532,201,'Participación',10.00,3,1),(533,232,'Participación',10.00,3,1),(534,93,'Participación',10.00,3,1),(535,116,'Participación',10.00,3,1),(536,142,'Participación',10.00,3,1),(537,145,'Participación',10.00,3,1),(538,202,'Participación',10.00,3,1),(539,233,'Participación',10.00,3,1),(540,310,'Participación',10.00,3,1),(541,311,'Participación',10.00,3,1),(542,312,'Participación',10.00,3,1),(544,455,'Participación',10.00,3,1),(545,456,'Participación',10.00,3,1),(546,465,'Participación',10.00,3,1),(547,466,'Participación',10.00,3,1),(548,467,'Participación',10.00,3,1),(549,468,'Participación',10.00,3,1),(550,477,'Participación',10.00,3,1),(551,478,'Participación',10.00,3,1),(552,479,'Participación',10.00,3,1),(553,480,'Participación',10.00,3,1),(554,489,'Participación',10.00,3,1),(555,490,'Participación',10.00,3,1),(556,491,'Participación',10.00,3,1),(557,492,'Participación',10.00,3,1),(558,501,'Participación',10.00,3,1),(559,502,'Participación',10.00,3,1),(560,503,'Participación',10.00,3,1),(561,504,'Participación',10.00,3,1),(563,94,'Participación',10.00,3,1),(564,117,'Participación',10.00,3,1),(565,151,'Participación',10.00,3,1),(566,166,'Participación',10.00,3,1),(567,203,'Participación',10.00,3,1),(568,234,'Participación',10.00,3,1),(569,272,'Participación',10.00,3,1),(570,273,'Participación',10.00,3,1),(571,274,'Participación',10.00,3,1),(572,95,'Participación',10.00,3,1),(573,118,'Participación',10.00,3,1),(574,152,'Participación',10.00,3,1),(575,167,'Participación',10.00,3,1),(577,77,'Participación',10.00,3,1),(578,98,'Participación',10.00,3,1),(579,121,'Participación',10.00,3,1),(580,204,'Participación',10.00,3,1),(581,235,'Participación',10.00,3,1),(582,264,'Participación',10.00,3,1),(583,265,'Participación',10.00,3,1),(585,84,'Participación',10.00,3,1),(586,99,'Participación',10.00,3,1),(587,122,'Participación',10.00,3,1),(588,154,'Participación',10.00,3,1),(589,169,'Participación',10.00,3,1),(590,205,'Participación',10.00,3,1),(591,236,'Participación',10.00,3,1),(592,307,'Participación',10.00,3,1),(593,308,'Participación',10.00,3,1),(594,100,'Participación',10.00,3,1),(595,123,'Participación',10.00,3,1),(596,155,'Participación',10.00,3,1),(597,170,'Participación',10.00,3,1),(598,206,'Participación',10.00,3,1),(599,237,'Participación',10.00,3,1),(600,101,'Participación',10.00,3,1),(601,124,'Participación',10.00,3,1),(602,156,'Participación',10.00,3,1),(603,171,'Participación',10.00,3,1),(604,207,'Participación',10.00,3,1),(605,238,'Participación',10.00,3,1),(607,78,'Participación',10.00,3,1),(608,102,'Participación',10.00,3,1),(609,125,'Participación',10.00,3,1),(610,157,'Participación',10.00,3,1),(611,172,'Participación',10.00,3,1),(612,208,'Participación',10.00,3,1),(613,239,'Participación',10.00,3,1),(614,268,'Participación',10.00,3,1),(615,269,'Participación',10.00,3,1),(617,83,'Participación',10.00,3,1),(618,103,'Participación',10.00,3,1),(619,126,'Participación',10.00,3,1),(620,158,'Participación',10.00,3,1),(621,173,'Participación',10.00,3,1),(622,209,'Participación',10.00,3,1),(623,240,'Participación',10.00,3,1),(624,305,'Participación',10.00,3,1),(625,306,'Participación',10.00,3,1),(627,79,'Participación',10.00,3,1),(628,104,'Participación',10.00,3,1),(629,127,'Participación',10.00,3,1),(630,159,'Participación',10.00,3,1),(631,174,'Participación',10.00,3,1),(632,210,'Participación',10.00,3,1),(633,241,'Participación',10.00,3,1),(634,281,'Participación',10.00,3,1),(635,282,'Participación',10.00,3,1),(637,80,'Participación',10.00,3,1),(638,105,'Participación',10.00,3,1),(639,128,'Participación',10.00,3,1),(640,211,'Participación',10.00,3,1),(641,242,'Participación',10.00,3,1),(642,279,'Participación',10.00,3,1),(643,280,'Participación',10.00,3,1),(644,106,'Participación',10.00,3,1),(645,129,'Participación',10.00,3,1),(667,448,'Participación',10.00,3,1),(668,449,'Participación',10.00,3,1),(669,450,'Participación',10.00,3,1),(670,457,'Participación',10.00,3,1),(671,458,'Participación',10.00,3,1),(672,459,'Participación',10.00,3,1),(673,460,'Participación',10.00,3,1),(674,469,'Participación',10.00,3,1),(675,470,'Participación',10.00,3,1),(676,471,'Participación',10.00,3,1),(677,472,'Participación',10.00,3,1),(678,481,'Participación',10.00,3,1),(679,482,'Participación',10.00,3,1),(680,483,'Participación',10.00,3,1),(681,484,'Participación',10.00,3,1),(682,493,'Participación',10.00,3,1),(683,494,'Participación',10.00,3,1),(684,495,'Participación',10.00,3,1),(685,496,'Participación',10.00,3,1),(686,505,'Participación',10.00,3,1),(687,506,'Participación',10.00,3,1),(688,507,'Participación',10.00,3,1),(689,508,'Participación',10.00,3,1),(690,513,'Participación',10.00,3,1),(691,514,'Participación',10.00,3,1),(692,515,'Participación',10.00,3,1),(693,516,'Participación',10.00,3,1),(694,521,'Participación',10.00,3,1),(695,522,'Participación',10.00,3,1),(696,523,'Participación',10.00,3,1),(697,524,'Participación',10.00,3,1),(698,529,'Participación',10.00,3,1),(699,530,'Participación',10.00,3,1),(700,531,'Participación',10.00,3,1),(701,532,'Participación',10.00,3,1),(703,452,'Participación',10.00,3,1),(704,453,'Participación',10.00,3,1),(705,454,'Participación',10.00,3,1),(706,461,'Participación',10.00,3,1),(707,462,'Participación',10.00,3,1),(708,463,'Participación',10.00,3,1),(709,464,'Participación',10.00,3,1),(710,473,'Participación',10.00,3,1),(711,474,'Participación',10.00,3,1),(712,475,'Participación',10.00,3,1),(713,476,'Participación',10.00,3,1),(714,485,'Participación',10.00,3,1),(715,486,'Participación',10.00,3,1),(716,487,'Participación',10.00,3,1),(717,488,'Participación',10.00,3,1),(718,497,'Participación',10.00,3,1),(719,498,'Participación',10.00,3,1),(720,499,'Participación',10.00,3,1),(721,500,'Participación',10.00,3,1),(722,509,'Participación',10.00,3,1),(723,510,'Participación',10.00,3,1),(724,511,'Participación',10.00,3,1),(725,512,'Participación',10.00,3,1),(726,517,'Participación',10.00,3,1),(727,518,'Participación',10.00,3,1),(728,519,'Participación',10.00,3,1),(729,520,'Participación',10.00,3,1),(730,525,'Participación',10.00,3,1),(731,526,'Participación',10.00,3,1),(732,527,'Participación',10.00,3,1),(733,528,'Participación',10.00,3,1),(734,533,'Participación',10.00,3,1),(735,534,'Participación',10.00,3,1),(736,535,'Participación',10.00,3,1),(737,536,'Participación',10.00,3,1),(739,419,'Participación',10.00,3,1),(740,420,'Participación',10.00,3,1),(741,421,'Participación',10.00,3,1),(743,423,'Participación',10.00,3,1),(744,424,'Participación',10.00,3,1),(745,425,'Participación',10.00,3,1),(747,427,'Participación',10.00,3,1),(748,428,'Participación',10.00,3,1),(749,429,'Participación',10.00,3,1),(751,431,'Participación',10.00,3,1),(752,432,'Participación',10.00,3,1),(753,433,'Participación',10.00,3,1),(755,435,'Participación',10.00,3,1),(756,436,'Participación',10.00,3,1),(757,437,'Participación',10.00,3,1),(759,439,'Participación',10.00,3,1),(760,440,'Participación',10.00,3,1),(761,441,'Participación',10.00,3,1),(763,443,'Participación',10.00,3,1),(764,444,'Participación',10.00,3,1),(765,445,'Participación',10.00,3,1),(767,577,'Participación',10.00,3,1),(768,578,'Participación',10.00,3,1),(769,579,'Participación',10.00,3,1),(771,88,'Participación',10.00,3,1),(772,266,'Participación',10.00,3,1),(773,267,'Participación',10.00,3,1),(775,89,'Participación',10.00,3,1),(776,262,'Participación',10.00,3,1),(777,263,'Participación',10.00,3,1),(778,113,'Evaluación Parcial',10.00,4,1),(779,148,'Evaluación Parcial',10.00,4,1),(780,163,'Evaluación Parcial',10.00,4,1),(781,200,'Evaluación Parcial',10.00,4,1),(782,231,'Evaluación Parcial',10.00,4,1),(783,314,'Evaluación Parcial',10.00,4,1),(784,315,'Evaluación Parcial',10.00,4,1),(785,316,'Evaluación Parcial',10.00,4,1),(787,149,'Evaluación Parcial',10.00,4,1),(788,164,'Evaluación Parcial',10.00,4,1),(789,150,'Evaluación Parcial',10.00,4,1),(790,165,'Evaluación Parcial',10.00,4,1),(791,201,'Evaluación Parcial',10.00,4,1),(792,232,'Evaluación Parcial',10.00,4,1),(793,93,'Evaluación Parcial',10.00,4,1),(794,116,'Evaluación Parcial',10.00,4,1),(795,142,'Evaluación Parcial',10.00,4,1),(796,145,'Evaluación Parcial',10.00,4,1),(797,202,'Evaluación Parcial',10.00,4,1),(798,233,'Evaluación Parcial',10.00,4,1),(799,310,'Evaluación Parcial',10.00,4,1),(800,311,'Evaluación Parcial',10.00,4,1),(801,312,'Evaluación Parcial',10.00,4,1),(803,455,'Evaluación Parcial',10.00,4,1),(804,456,'Evaluación Parcial',10.00,4,1),(805,465,'Evaluación Parcial',10.00,4,1),(806,466,'Evaluación Parcial',10.00,4,1),(807,467,'Evaluación Parcial',10.00,4,1),(808,468,'Evaluación Parcial',10.00,4,1),(809,477,'Evaluación Parcial',10.00,4,1),(810,478,'Evaluación Parcial',10.00,4,1),(811,479,'Evaluación Parcial',10.00,4,1),(812,480,'Evaluación Parcial',10.00,4,1),(813,489,'Evaluación Parcial',10.00,4,1),(814,490,'Evaluación Parcial',10.00,4,1),(815,491,'Evaluación Parcial',10.00,4,1),(816,492,'Evaluación Parcial',10.00,4,1),(817,501,'Evaluación Parcial',10.00,4,1),(818,502,'Evaluación Parcial',10.00,4,1),(819,503,'Evaluación Parcial',10.00,4,1),(820,504,'Evaluación Parcial',10.00,4,1),(822,94,'Evaluación Parcial',10.00,4,1),(823,117,'Evaluación Parcial',10.00,4,1),(824,151,'Evaluación Parcial',10.00,4,1),(825,166,'Evaluación Parcial',10.00,4,1),(826,203,'Evaluación Parcial',10.00,4,1),(827,234,'Evaluación Parcial',10.00,4,1),(828,272,'Evaluación Parcial',10.00,4,1),(829,273,'Evaluación Parcial',10.00,4,1),(830,274,'Evaluación Parcial',10.00,4,1),(831,95,'Evaluación Parcial',10.00,4,1),(832,118,'Evaluación Parcial',10.00,4,1),(833,152,'Evaluación Parcial',10.00,4,1),(834,167,'Evaluación Parcial',10.00,4,1),(836,77,'Evaluación Parcial',10.00,4,1),(837,98,'Evaluación Parcial',10.00,4,1),(838,121,'Evaluación Parcial',10.00,4,1),(839,204,'Evaluación Parcial',10.00,4,1),(840,235,'Evaluación Parcial',10.00,4,1),(841,264,'Evaluación Parcial',10.00,4,1),(842,265,'Evaluación Parcial',10.00,4,1),(844,84,'Evaluación Parcial',10.00,4,1),(845,99,'Evaluación Parcial',10.00,4,1),(846,122,'Evaluación Parcial',10.00,4,1),(847,154,'Evaluación Parcial',10.00,4,1),(848,169,'Evaluación Parcial',10.00,4,1),(849,205,'Evaluación Parcial',10.00,4,1),(850,236,'Evaluación Parcial',10.00,4,1),(851,307,'Evaluación Parcial',10.00,4,1),(852,308,'Evaluación Parcial',10.00,4,1),(853,100,'Evaluación Parcial',10.00,4,1),(854,123,'Evaluación Parcial',10.00,4,1),(855,155,'Evaluación Parcial',10.00,4,1),(856,170,'Evaluación Parcial',10.00,4,1),(857,206,'Evaluación Parcial',10.00,4,1),(858,237,'Evaluación Parcial',10.00,4,1),(859,101,'Evaluación Parcial',10.00,4,1),(860,124,'Evaluación Parcial',10.00,4,1),(861,156,'Evaluación Parcial',10.00,4,1),(862,171,'Evaluación Parcial',10.00,4,1),(863,207,'Evaluación Parcial',10.00,4,1),(864,238,'Evaluación Parcial',10.00,4,1),(866,78,'Evaluación Parcial',10.00,4,1),(867,102,'Evaluación Parcial',10.00,4,1),(868,125,'Evaluación Parcial',10.00,4,1),(869,157,'Evaluación Parcial',10.00,4,1),(870,172,'Evaluación Parcial',10.00,4,1),(871,208,'Evaluación Parcial',10.00,4,1),(872,239,'Evaluación Parcial',10.00,4,1),(873,268,'Evaluación Parcial',10.00,4,1),(874,269,'Evaluación Parcial',10.00,4,1),(876,83,'Evaluación Parcial',10.00,4,1),(877,103,'Evaluación Parcial',10.00,4,1),(878,126,'Evaluación Parcial',10.00,4,1),(879,158,'Evaluación Parcial',10.00,4,1),(880,173,'Evaluación Parcial',10.00,4,1),(881,209,'Evaluación Parcial',10.00,4,1),(882,240,'Evaluación Parcial',10.00,4,1),(883,305,'Evaluación Parcial',10.00,4,1),(884,306,'Evaluación Parcial',10.00,4,1),(886,79,'Evaluación Parcial',10.00,4,1),(887,104,'Evaluación Parcial',10.00,4,1),(888,127,'Evaluación Parcial',10.00,4,1),(889,159,'Evaluación Parcial',10.00,4,1),(890,174,'Evaluación Parcial',10.00,4,1),(891,210,'Evaluación Parcial',10.00,4,1),(892,241,'Evaluación Parcial',10.00,4,1),(893,281,'Evaluación Parcial',10.00,4,1),(894,282,'Evaluación Parcial',10.00,4,1),(896,80,'Evaluación Parcial',10.00,4,1),(897,105,'Evaluación Parcial',10.00,4,1),(898,128,'Evaluación Parcial',10.00,4,1),(899,211,'Evaluación Parcial',10.00,4,1),(900,242,'Evaluación Parcial',10.00,4,1),(901,279,'Evaluación Parcial',10.00,4,1),(902,280,'Evaluación Parcial',10.00,4,1),(903,106,'Evaluación Parcial',10.00,4,1),(904,129,'Evaluación Parcial',10.00,4,1),(926,448,'Evaluación Parcial',10.00,4,1),(927,449,'Evaluación Parcial',10.00,4,1),(928,450,'Evaluación Parcial',10.00,4,1),(929,457,'Evaluación Parcial',10.00,4,1),(930,458,'Evaluación Parcial',10.00,4,1),(931,459,'Evaluación Parcial',10.00,4,1),(932,460,'Evaluación Parcial',10.00,4,1),(933,469,'Evaluación Parcial',10.00,4,1),(934,470,'Evaluación Parcial',10.00,4,1),(935,471,'Evaluación Parcial',10.00,4,1),(936,472,'Evaluación Parcial',10.00,4,1),(937,481,'Evaluación Parcial',10.00,4,1),(938,482,'Evaluación Parcial',10.00,4,1),(939,483,'Evaluación Parcial',10.00,4,1),(940,484,'Evaluación Parcial',10.00,4,1),(941,493,'Evaluación Parcial',10.00,4,1),(942,494,'Evaluación Parcial',10.00,4,1),(943,495,'Evaluación Parcial',10.00,4,1),(944,496,'Evaluación Parcial',10.00,4,1),(945,505,'Evaluación Parcial',10.00,4,1),(946,506,'Evaluación Parcial',10.00,4,1),(947,507,'Evaluación Parcial',10.00,4,1),(948,508,'Evaluación Parcial',10.00,4,1),(949,513,'Evaluación Parcial',10.00,4,1),(950,514,'Evaluación Parcial',10.00,4,1),(951,515,'Evaluación Parcial',10.00,4,1),(952,516,'Evaluación Parcial',10.00,4,1),(953,521,'Evaluación Parcial',10.00,4,1),(954,522,'Evaluación Parcial',10.00,4,1),(955,523,'Evaluación Parcial',10.00,4,1),(956,524,'Evaluación Parcial',10.00,4,1),(957,529,'Evaluación Parcial',10.00,4,1),(958,530,'Evaluación Parcial',10.00,4,1),(959,531,'Evaluación Parcial',10.00,4,1),(960,532,'Evaluación Parcial',10.00,4,1),(962,452,'Evaluación Parcial',10.00,4,1),(963,453,'Evaluación Parcial',10.00,4,1),(964,454,'Evaluación Parcial',10.00,4,1),(965,461,'Evaluación Parcial',10.00,4,1),(966,462,'Evaluación Parcial',10.00,4,1),(967,463,'Evaluación Parcial',10.00,4,1),(968,464,'Evaluación Parcial',10.00,4,1),(969,473,'Evaluación Parcial',10.00,4,1),(970,474,'Evaluación Parcial',10.00,4,1),(971,475,'Evaluación Parcial',10.00,4,1),(972,476,'Evaluación Parcial',10.00,4,1),(973,485,'Evaluación Parcial',10.00,4,1),(974,486,'Evaluación Parcial',10.00,4,1),(975,487,'Evaluación Parcial',10.00,4,1),(976,488,'Evaluación Parcial',10.00,4,1),(977,497,'Evaluación Parcial',10.00,4,1),(978,498,'Evaluación Parcial',10.00,4,1),(979,499,'Evaluación Parcial',10.00,4,1),(980,500,'Evaluación Parcial',10.00,4,1),(981,509,'Evaluación Parcial',10.00,4,1),(982,510,'Evaluación Parcial',10.00,4,1),(983,511,'Evaluación Parcial',10.00,4,1),(984,512,'Evaluación Parcial',10.00,4,1),(985,517,'Evaluación Parcial',10.00,4,1),(986,518,'Evaluación Parcial',10.00,4,1),(987,519,'Evaluación Parcial',10.00,4,1),(988,520,'Evaluación Parcial',10.00,4,1),(989,525,'Evaluación Parcial',10.00,4,1),(990,526,'Evaluación Parcial',10.00,4,1),(991,527,'Evaluación Parcial',10.00,4,1),(992,528,'Evaluación Parcial',10.00,4,1),(993,533,'Evaluación Parcial',10.00,4,1),(994,534,'Evaluación Parcial',10.00,4,1),(995,535,'Evaluación Parcial',10.00,4,1),(996,536,'Evaluación Parcial',10.00,4,1),(998,419,'Evaluación Parcial',10.00,4,1),(999,420,'Evaluación Parcial',10.00,4,1),(1000,421,'Evaluación Parcial',10.00,4,1),(1002,423,'Evaluación Parcial',10.00,4,1),(1003,424,'Evaluación Parcial',10.00,4,1),(1004,425,'Evaluación Parcial',10.00,4,1),(1006,427,'Evaluación Parcial',10.00,4,1),(1007,428,'Evaluación Parcial',10.00,4,1),(1008,429,'Evaluación Parcial',10.00,4,1),(1010,431,'Evaluación Parcial',10.00,4,1),(1011,432,'Evaluación Parcial',10.00,4,1),(1012,433,'Evaluación Parcial',10.00,4,1),(1014,435,'Evaluación Parcial',10.00,4,1),(1015,436,'Evaluación Parcial',10.00,4,1),(1016,437,'Evaluación Parcial',10.00,4,1),(1018,439,'Evaluación Parcial',10.00,4,1),(1019,440,'Evaluación Parcial',10.00,4,1),(1020,441,'Evaluación Parcial',10.00,4,1),(1022,443,'Evaluación Parcial',10.00,4,1),(1023,444,'Evaluación Parcial',10.00,4,1),(1024,445,'Evaluación Parcial',10.00,4,1),(1026,577,'Evaluación Parcial',10.00,4,1),(1027,578,'Evaluación Parcial',10.00,4,1),(1028,579,'Evaluación Parcial',10.00,4,1),(1030,88,'Evaluación Parcial',10.00,4,1),(1031,266,'Evaluación Parcial',10.00,4,1),(1032,267,'Evaluación Parcial',10.00,4,1),(1034,89,'Evaluación Parcial',10.00,4,1),(1035,262,'Evaluación Parcial',10.00,4,1),(1036,263,'Evaluación Parcial',10.00,4,1),(1037,113,'Proyecto',10.00,5,1),(1038,148,'Proyecto',10.00,5,1),(1039,163,'Proyecto',10.00,5,1),(1040,200,'Proyecto',10.00,5,1),(1041,231,'Proyecto',10.00,5,1),(1042,314,'Proyecto',10.00,5,1),(1043,315,'Proyecto',10.00,5,1),(1044,316,'Proyecto',10.00,5,1),(1046,149,'Proyecto',10.00,5,1),(1047,164,'Proyecto',10.00,5,1),(1048,150,'Proyecto',10.00,5,1),(1049,165,'Proyecto',10.00,5,1),(1050,201,'Proyecto',10.00,5,1),(1051,232,'Proyecto',10.00,5,1),(1052,93,'Proyecto',10.00,5,1),(1053,116,'Proyecto',10.00,5,1),(1054,142,'Proyecto',10.00,5,1),(1055,145,'Proyecto',10.00,5,1),(1056,202,'Proyecto',10.00,5,1),(1057,233,'Proyecto',10.00,5,1),(1058,310,'Proyecto',10.00,5,1),(1059,311,'Proyecto',10.00,5,1),(1060,312,'Proyecto',10.00,5,1),(1062,455,'Proyecto',10.00,5,1),(1063,456,'Proyecto',10.00,5,1),(1064,465,'Proyecto',10.00,5,1),(1065,466,'Proyecto',10.00,5,1),(1066,467,'Proyecto',10.00,5,1),(1067,468,'Proyecto',10.00,5,1),(1068,477,'Proyecto',10.00,5,1),(1069,478,'Proyecto',10.00,5,1),(1070,479,'Proyecto',10.00,5,1),(1071,480,'Proyecto',10.00,5,1),(1072,489,'Proyecto',10.00,5,1),(1073,490,'Proyecto',10.00,5,1),(1074,491,'Proyecto',10.00,5,1),(1075,492,'Proyecto',10.00,5,1),(1076,501,'Proyecto',10.00,5,1),(1077,502,'Proyecto',10.00,5,1),(1078,503,'Proyecto',10.00,5,1),(1079,504,'Proyecto',10.00,5,1),(1081,94,'Proyecto',10.00,5,1),(1082,117,'Proyecto',10.00,5,1),(1083,151,'Proyecto',10.00,5,1),(1084,166,'Proyecto',10.00,5,1),(1085,203,'Proyecto',10.00,5,1),(1086,234,'Proyecto',10.00,5,1),(1087,272,'Proyecto',10.00,5,1),(1088,273,'Proyecto',10.00,5,1),(1089,274,'Proyecto',10.00,5,1),(1090,95,'Proyecto',10.00,5,1),(1091,118,'Proyecto',10.00,5,1),(1092,152,'Proyecto',10.00,5,1),(1093,167,'Proyecto',10.00,5,1),(1095,77,'Proyecto',10.00,5,1),(1096,98,'Proyecto',10.00,5,1),(1097,121,'Proyecto',10.00,5,1),(1098,204,'Proyecto',10.00,5,1),(1099,235,'Proyecto',10.00,5,1),(1100,264,'Proyecto',10.00,5,1),(1101,265,'Proyecto',10.00,5,1),(1103,84,'Proyecto',10.00,5,1),(1104,99,'Proyecto',10.00,5,1),(1105,122,'Proyecto',10.00,5,1),(1106,154,'Proyecto',10.00,5,1),(1107,169,'Proyecto',10.00,5,1),(1108,205,'Proyecto',10.00,5,1),(1109,236,'Proyecto',10.00,5,1),(1110,307,'Proyecto',10.00,5,1),(1111,308,'Proyecto',10.00,5,1),(1112,100,'Proyecto',10.00,5,1),(1113,123,'Proyecto',10.00,5,1),(1114,155,'Proyecto',10.00,5,1),(1115,170,'Proyecto',10.00,5,1),(1116,206,'Proyecto',10.00,5,1),(1117,237,'Proyecto',10.00,5,1),(1118,101,'Proyecto',10.00,5,1),(1119,124,'Proyecto',10.00,5,1),(1120,156,'Proyecto',10.00,5,1),(1121,171,'Proyecto',10.00,5,1),(1122,207,'Proyecto',10.00,5,1),(1123,238,'Proyecto',10.00,5,1),(1125,78,'Proyecto',10.00,5,1),(1126,102,'Proyecto',10.00,5,1),(1127,125,'Proyecto',10.00,5,1),(1128,157,'Proyecto',10.00,5,1),(1129,172,'Proyecto',10.00,5,1),(1130,208,'Proyecto',10.00,5,1),(1131,239,'Proyecto',10.00,5,1),(1132,268,'Proyecto',10.00,5,1),(1133,269,'Proyecto',10.00,5,1),(1135,83,'Proyecto',10.00,5,1),(1136,103,'Proyecto',10.00,5,1),(1137,126,'Proyecto',10.00,5,1),(1138,158,'Proyecto',10.00,5,1),(1139,173,'Proyecto',10.00,5,1),(1140,209,'Proyecto',10.00,5,1),(1141,240,'Proyecto',10.00,5,1),(1142,305,'Proyecto',10.00,5,1),(1143,306,'Proyecto',10.00,5,1),(1145,79,'Proyecto',10.00,5,1),(1146,104,'Proyecto',10.00,5,1),(1147,127,'Proyecto',10.00,5,1),(1148,159,'Proyecto',10.00,5,1),(1149,174,'Proyecto',10.00,5,1),(1150,210,'Proyecto',10.00,5,1),(1151,241,'Proyecto',10.00,5,1),(1152,281,'Proyecto',10.00,5,1),(1153,282,'Proyecto',10.00,5,1),(1155,80,'Proyecto',10.00,5,1),(1156,105,'Proyecto',10.00,5,1),(1157,128,'Proyecto',10.00,5,1),(1158,211,'Proyecto',10.00,5,1),(1159,242,'Proyecto',10.00,5,1),(1160,279,'Proyecto',10.00,5,1),(1161,280,'Proyecto',10.00,5,1),(1162,106,'Proyecto',10.00,5,1),(1163,129,'Proyecto',10.00,5,1),(1185,448,'Proyecto',10.00,5,1),(1186,449,'Proyecto',10.00,5,1),(1187,450,'Proyecto',10.00,5,1),(1188,457,'Proyecto',10.00,5,1),(1189,458,'Proyecto',10.00,5,1),(1190,459,'Proyecto',10.00,5,1),(1191,460,'Proyecto',10.00,5,1),(1192,469,'Proyecto',10.00,5,1),(1193,470,'Proyecto',10.00,5,1),(1194,471,'Proyecto',10.00,5,1),(1195,472,'Proyecto',10.00,5,1),(1196,481,'Proyecto',10.00,5,1),(1197,482,'Proyecto',10.00,5,1),(1198,483,'Proyecto',10.00,5,1),(1199,484,'Proyecto',10.00,5,1),(1200,493,'Proyecto',10.00,5,1),(1201,494,'Proyecto',10.00,5,1),(1202,495,'Proyecto',10.00,5,1),(1203,496,'Proyecto',10.00,5,1),(1204,505,'Proyecto',10.00,5,1),(1205,506,'Proyecto',10.00,5,1),(1206,507,'Proyecto',10.00,5,1),(1207,508,'Proyecto',10.00,5,1),(1208,513,'Proyecto',10.00,5,1),(1209,514,'Proyecto',10.00,5,1),(1210,515,'Proyecto',10.00,5,1),(1211,516,'Proyecto',10.00,5,1),(1212,521,'Proyecto',10.00,5,1),(1213,522,'Proyecto',10.00,5,1),(1214,523,'Proyecto',10.00,5,1),(1215,524,'Proyecto',10.00,5,1),(1216,529,'Proyecto',10.00,5,1),(1217,530,'Proyecto',10.00,5,1),(1218,531,'Proyecto',10.00,5,1),(1219,532,'Proyecto',10.00,5,1),(1221,452,'Proyecto',10.00,5,1),(1222,453,'Proyecto',10.00,5,1),(1223,454,'Proyecto',10.00,5,1),(1224,461,'Proyecto',10.00,5,1),(1225,462,'Proyecto',10.00,5,1),(1226,463,'Proyecto',10.00,5,1),(1227,464,'Proyecto',10.00,5,1),(1228,473,'Proyecto',10.00,5,1),(1229,474,'Proyecto',10.00,5,1),(1230,475,'Proyecto',10.00,5,1),(1231,476,'Proyecto',10.00,5,1),(1232,485,'Proyecto',10.00,5,1),(1233,486,'Proyecto',10.00,5,1),(1234,487,'Proyecto',10.00,5,1),(1235,488,'Proyecto',10.00,5,1),(1236,497,'Proyecto',10.00,5,1),(1237,498,'Proyecto',10.00,5,1),(1238,499,'Proyecto',10.00,5,1),(1239,500,'Proyecto',10.00,5,1),(1240,509,'Proyecto',10.00,5,1),(1241,510,'Proyecto',10.00,5,1),(1242,511,'Proyecto',10.00,5,1),(1243,512,'Proyecto',10.00,5,1),(1244,517,'Proyecto',10.00,5,1),(1245,518,'Proyecto',10.00,5,1),(1246,519,'Proyecto',10.00,5,1),(1247,520,'Proyecto',10.00,5,1),(1248,525,'Proyecto',10.00,5,1),(1249,526,'Proyecto',10.00,5,1),(1250,527,'Proyecto',10.00,5,1),(1251,528,'Proyecto',10.00,5,1),(1252,533,'Proyecto',10.00,5,1),(1253,534,'Proyecto',10.00,5,1),(1254,535,'Proyecto',10.00,5,1),(1255,536,'Proyecto',10.00,5,1),(1257,419,'Proyecto',10.00,5,1),(1258,420,'Proyecto',10.00,5,1),(1259,421,'Proyecto',10.00,5,1),(1261,423,'Proyecto',10.00,5,1),(1262,424,'Proyecto',10.00,5,1),(1263,425,'Proyecto',10.00,5,1),(1265,427,'Proyecto',10.00,5,1),(1266,428,'Proyecto',10.00,5,1),(1267,429,'Proyecto',10.00,5,1),(1269,431,'Proyecto',10.00,5,1),(1270,432,'Proyecto',10.00,5,1),(1271,433,'Proyecto',10.00,5,1),(1273,435,'Proyecto',10.00,5,1),(1274,436,'Proyecto',10.00,5,1),(1275,437,'Proyecto',10.00,5,1),(1277,439,'Proyecto',10.00,5,1),(1278,440,'Proyecto',10.00,5,1),(1279,441,'Proyecto',10.00,5,1),(1281,443,'Proyecto',10.00,5,1),(1282,444,'Proyecto',10.00,5,1),(1283,445,'Proyecto',10.00,5,1),(1285,577,'Proyecto',10.00,5,1),(1286,578,'Proyecto',10.00,5,1),(1287,579,'Proyecto',10.00,5,1),(1289,88,'Proyecto',10.00,5,1),(1290,266,'Proyecto',10.00,5,1),(1291,267,'Proyecto',10.00,5,1),(1293,89,'Proyecto',10.00,5,1),(1294,262,'Proyecto',10.00,5,1),(1295,263,'Proyecto',10.00,5,1),(1296,113,'Trabajo y Exposiciones',10.00,6,1),(1297,148,'Trabajo y Exposiciones',10.00,6,1),(1298,163,'Trabajo y Exposiciones',10.00,6,1),(1299,200,'Trabajo y Exposiciones',10.00,6,1),(1300,231,'Trabajo y Exposiciones',10.00,6,1),(1301,314,'Trabajo y Exposiciones',10.00,6,1),(1302,315,'Trabajo y Exposiciones',10.00,6,1),(1303,316,'Trabajo y Exposiciones',10.00,6,1),(1305,149,'Trabajo y Exposiciones',10.00,6,1),(1306,164,'Trabajo y Exposiciones',10.00,6,1),(1307,150,'Trabajo y Exposiciones',10.00,6,1),(1308,165,'Trabajo y Exposiciones',10.00,6,1),(1309,201,'Trabajo y Exposiciones',10.00,6,1),(1310,232,'Trabajo y Exposiciones',10.00,6,1),(1311,93,'Trabajo y Exposiciones',10.00,6,1),(1312,116,'Trabajo y Exposiciones',10.00,6,1),(1313,142,'Trabajo y Exposiciones',10.00,6,1),(1314,145,'Trabajo y Exposiciones',10.00,6,1),(1315,202,'Trabajo y Exposiciones',10.00,6,1),(1316,233,'Trabajo y Exposiciones',10.00,6,1),(1317,310,'Trabajo y Exposiciones',10.00,6,1),(1318,311,'Trabajo y Exposiciones',10.00,6,1),(1319,312,'Trabajo y Exposiciones',10.00,6,1),(1321,455,'Trabajo y Exposiciones',10.00,6,1),(1322,456,'Trabajo y Exposiciones',10.00,6,1),(1323,465,'Trabajo y Exposiciones',10.00,6,1),(1324,466,'Trabajo y Exposiciones',10.00,6,1),(1325,467,'Trabajo y Exposiciones',10.00,6,1),(1326,468,'Trabajo y Exposiciones',10.00,6,1),(1327,477,'Trabajo y Exposiciones',10.00,6,1),(1328,478,'Trabajo y Exposiciones',10.00,6,1),(1329,479,'Trabajo y Exposiciones',10.00,6,1),(1330,480,'Trabajo y Exposiciones',10.00,6,1),(1331,489,'Trabajo y Exposiciones',10.00,6,1),(1332,490,'Trabajo y Exposiciones',10.00,6,1),(1333,491,'Trabajo y Exposiciones',10.00,6,1),(1334,492,'Trabajo y Exposiciones',10.00,6,1),(1335,501,'Trabajo y Exposiciones',10.00,6,1),(1336,502,'Trabajo y Exposiciones',10.00,6,1),(1337,503,'Trabajo y Exposiciones',10.00,6,1),(1338,504,'Trabajo y Exposiciones',10.00,6,1),(1340,94,'Trabajo y Exposiciones',10.00,6,1),(1341,117,'Trabajo y Exposiciones',10.00,6,1),(1342,151,'Trabajo y Exposiciones',10.00,6,1),(1343,166,'Trabajo y Exposiciones',10.00,6,1),(1344,203,'Trabajo y Exposiciones',10.00,6,1),(1345,234,'Trabajo y Exposiciones',10.00,6,1),(1346,272,'Trabajo y Exposiciones',10.00,6,1),(1347,273,'Trabajo y Exposiciones',10.00,6,1),(1348,274,'Trabajo y Exposiciones',10.00,6,1),(1349,95,'Trabajo y Exposiciones',10.00,6,1),(1350,118,'Trabajo y Exposiciones',10.00,6,1),(1351,152,'Trabajo y Exposiciones',10.00,6,1),(1352,167,'Trabajo y Exposiciones',10.00,6,1),(1354,77,'Trabajo y Exposiciones',10.00,6,1),(1355,98,'Trabajo y Exposiciones',10.00,6,1),(1356,121,'Trabajo y Exposiciones',10.00,6,1),(1357,204,'Trabajo y Exposiciones',10.00,6,1),(1358,235,'Trabajo y Exposiciones',10.00,6,1),(1359,264,'Trabajo y Exposiciones',10.00,6,1),(1360,265,'Trabajo y Exposiciones',10.00,6,1),(1362,84,'Trabajo y Exposiciones',10.00,6,1),(1363,99,'Trabajo y Exposiciones',10.00,6,1),(1364,122,'Trabajo y Exposiciones',10.00,6,1),(1365,154,'Trabajo y Exposiciones',10.00,6,1),(1366,169,'Trabajo y Exposiciones',10.00,6,1),(1367,205,'Trabajo y Exposiciones',10.00,6,1),(1368,236,'Trabajo y Exposiciones',10.00,6,1),(1369,307,'Trabajo y Exposiciones',10.00,6,1),(1370,308,'Trabajo y Exposiciones',10.00,6,1),(1371,100,'Trabajo y Exposiciones',10.00,6,1),(1372,123,'Trabajo y Exposiciones',10.00,6,1),(1373,155,'Trabajo y Exposiciones',10.00,6,1),(1374,170,'Trabajo y Exposiciones',10.00,6,1),(1375,206,'Trabajo y Exposiciones',10.00,6,1),(1376,237,'Trabajo y Exposiciones',10.00,6,1),(1377,101,'Trabajo y Exposiciones',10.00,6,1),(1378,124,'Trabajo y Exposiciones',10.00,6,1),(1379,156,'Trabajo y Exposiciones',10.00,6,1),(1380,171,'Trabajo y Exposiciones',10.00,6,1),(1381,207,'Trabajo y Exposiciones',10.00,6,1),(1382,238,'Trabajo y Exposiciones',10.00,6,1),(1384,78,'Trabajo y Exposiciones',10.00,6,1),(1385,102,'Trabajo y Exposiciones',10.00,6,1),(1386,125,'Trabajo y Exposiciones',10.00,6,1),(1387,157,'Trabajo y Exposiciones',10.00,6,1),(1388,172,'Trabajo y Exposiciones',10.00,6,1),(1389,208,'Trabajo y Exposiciones',10.00,6,1),(1390,239,'Trabajo y Exposiciones',10.00,6,1),(1391,268,'Trabajo y Exposiciones',10.00,6,1),(1392,269,'Trabajo y Exposiciones',10.00,6,1),(1394,83,'Trabajo y Exposiciones',10.00,6,1),(1395,103,'Trabajo y Exposiciones',10.00,6,1),(1396,126,'Trabajo y Exposiciones',10.00,6,1),(1397,158,'Trabajo y Exposiciones',10.00,6,1),(1398,173,'Trabajo y Exposiciones',10.00,6,1),(1399,209,'Trabajo y Exposiciones',10.00,6,1),(1400,240,'Trabajo y Exposiciones',10.00,6,1),(1401,305,'Trabajo y Exposiciones',10.00,6,1),(1402,306,'Trabajo y Exposiciones',10.00,6,1),(1404,79,'Trabajo y Exposiciones',10.00,6,1),(1405,104,'Trabajo y Exposiciones',10.00,6,1),(1406,127,'Trabajo y Exposiciones',10.00,6,1),(1407,159,'Trabajo y Exposiciones',10.00,6,1),(1408,174,'Trabajo y Exposiciones',10.00,6,1),(1409,210,'Trabajo y Exposiciones',10.00,6,1),(1410,241,'Trabajo y Exposiciones',10.00,6,1),(1411,281,'Trabajo y Exposiciones',10.00,6,1),(1412,282,'Trabajo y Exposiciones',10.00,6,1),(1414,80,'Trabajo y Exposiciones',10.00,6,1),(1415,105,'Trabajo y Exposiciones',10.00,6,1),(1416,128,'Trabajo y Exposiciones',10.00,6,1),(1417,211,'Trabajo y Exposiciones',10.00,6,1),(1418,242,'Trabajo y Exposiciones',10.00,6,1),(1419,279,'Trabajo y Exposiciones',10.00,6,1),(1420,280,'Trabajo y Exposiciones',10.00,6,1),(1421,106,'Trabajo y Exposiciones',10.00,6,1),(1422,129,'Trabajo y Exposiciones',10.00,6,1),(1444,448,'Trabajo y Exposiciones',10.00,6,1),(1445,449,'Trabajo y Exposiciones',10.00,6,1),(1446,450,'Trabajo y Exposiciones',10.00,6,1),(1447,457,'Trabajo y Exposiciones',10.00,6,1),(1448,458,'Trabajo y Exposiciones',10.00,6,1),(1449,459,'Trabajo y Exposiciones',10.00,6,1),(1450,460,'Trabajo y Exposiciones',10.00,6,1),(1451,469,'Trabajo y Exposiciones',10.00,6,1),(1452,470,'Trabajo y Exposiciones',10.00,6,1),(1453,471,'Trabajo y Exposiciones',10.00,6,1),(1454,472,'Trabajo y Exposiciones',10.00,6,1),(1455,481,'Trabajo y Exposiciones',10.00,6,1),(1456,482,'Trabajo y Exposiciones',10.00,6,1),(1457,483,'Trabajo y Exposiciones',10.00,6,1),(1458,484,'Trabajo y Exposiciones',10.00,6,1),(1459,493,'Trabajo y Exposiciones',10.00,6,1),(1460,494,'Trabajo y Exposiciones',10.00,6,1),(1461,495,'Trabajo y Exposiciones',10.00,6,1),(1462,496,'Trabajo y Exposiciones',10.00,6,1),(1463,505,'Trabajo y Exposiciones',10.00,6,1),(1464,506,'Trabajo y Exposiciones',10.00,6,1),(1465,507,'Trabajo y Exposiciones',10.00,6,1),(1466,508,'Trabajo y Exposiciones',10.00,6,1),(1467,513,'Trabajo y Exposiciones',10.00,6,1),(1468,514,'Trabajo y Exposiciones',10.00,6,1),(1469,515,'Trabajo y Exposiciones',10.00,6,1),(1470,516,'Trabajo y Exposiciones',10.00,6,1),(1471,521,'Trabajo y Exposiciones',10.00,6,1),(1472,522,'Trabajo y Exposiciones',10.00,6,1),(1473,523,'Trabajo y Exposiciones',10.00,6,1),(1474,524,'Trabajo y Exposiciones',10.00,6,1),(1475,529,'Trabajo y Exposiciones',10.00,6,1),(1476,530,'Trabajo y Exposiciones',10.00,6,1),(1477,531,'Trabajo y Exposiciones',10.00,6,1),(1478,532,'Trabajo y Exposiciones',10.00,6,1),(1480,452,'Trabajo y Exposiciones',10.00,6,1),(1481,453,'Trabajo y Exposiciones',10.00,6,1),(1482,454,'Trabajo y Exposiciones',10.00,6,1),(1483,461,'Trabajo y Exposiciones',10.00,6,1),(1484,462,'Trabajo y Exposiciones',10.00,6,1),(1485,463,'Trabajo y Exposiciones',10.00,6,1),(1486,464,'Trabajo y Exposiciones',10.00,6,1),(1487,473,'Trabajo y Exposiciones',10.00,6,1),(1488,474,'Trabajo y Exposiciones',10.00,6,1),(1489,475,'Trabajo y Exposiciones',10.00,6,1),(1490,476,'Trabajo y Exposiciones',10.00,6,1),(1491,485,'Trabajo y Exposiciones',10.00,6,1),(1492,486,'Trabajo y Exposiciones',10.00,6,1),(1493,487,'Trabajo y Exposiciones',10.00,6,1),(1494,488,'Trabajo y Exposiciones',10.00,6,1),(1495,497,'Trabajo y Exposiciones',10.00,6,1),(1496,498,'Trabajo y Exposiciones',10.00,6,1),(1497,499,'Trabajo y Exposiciones',10.00,6,1),(1498,500,'Trabajo y Exposiciones',10.00,6,1),(1499,509,'Trabajo y Exposiciones',10.00,6,1),(1500,510,'Trabajo y Exposiciones',10.00,6,1),(1501,511,'Trabajo y Exposiciones',10.00,6,1),(1502,512,'Trabajo y Exposiciones',10.00,6,1),(1503,517,'Trabajo y Exposiciones',10.00,6,1),(1504,518,'Trabajo y Exposiciones',10.00,6,1),(1505,519,'Trabajo y Exposiciones',10.00,6,1),(1506,520,'Trabajo y Exposiciones',10.00,6,1),(1507,525,'Trabajo y Exposiciones',10.00,6,1),(1508,526,'Trabajo y Exposiciones',10.00,6,1),(1509,527,'Trabajo y Exposiciones',10.00,6,1),(1510,528,'Trabajo y Exposiciones',10.00,6,1),(1511,533,'Trabajo y Exposiciones',10.00,6,1),(1512,534,'Trabajo y Exposiciones',10.00,6,1),(1513,535,'Trabajo y Exposiciones',10.00,6,1),(1514,536,'Trabajo y Exposiciones',10.00,6,1),(1516,419,'Trabajo y Exposiciones',10.00,6,1),(1517,420,'Trabajo y Exposiciones',10.00,6,1),(1518,421,'Trabajo y Exposiciones',10.00,6,1),(1520,423,'Trabajo y Exposiciones',10.00,6,1),(1521,424,'Trabajo y Exposiciones',10.00,6,1),(1522,425,'Trabajo y Exposiciones',10.00,6,1),(1524,427,'Trabajo y Exposiciones',10.00,6,1),(1525,428,'Trabajo y Exposiciones',10.00,6,1),(1526,429,'Trabajo y Exposiciones',10.00,6,1),(1528,431,'Trabajo y Exposiciones',10.00,6,1),(1529,432,'Trabajo y Exposiciones',10.00,6,1),(1530,433,'Trabajo y Exposiciones',10.00,6,1),(1532,435,'Trabajo y Exposiciones',10.00,6,1),(1533,436,'Trabajo y Exposiciones',10.00,6,1),(1534,437,'Trabajo y Exposiciones',10.00,6,1),(1536,439,'Trabajo y Exposiciones',10.00,6,1),(1537,440,'Trabajo y Exposiciones',10.00,6,1),(1538,441,'Trabajo y Exposiciones',10.00,6,1),(1540,443,'Trabajo y Exposiciones',10.00,6,1),(1541,444,'Trabajo y Exposiciones',10.00,6,1),(1542,445,'Trabajo y Exposiciones',10.00,6,1),(1544,577,'Trabajo y Exposiciones',10.00,6,1),(1545,578,'Trabajo y Exposiciones',10.00,6,1),(1546,579,'Trabajo y Exposiciones',10.00,6,1),(1548,88,'Trabajo y Exposiciones',10.00,6,1),(1549,266,'Trabajo y Exposiciones',10.00,6,1),(1550,267,'Trabajo y Exposiciones',10.00,6,1),(1552,89,'Trabajo y Exposiciones',10.00,6,1),(1553,262,'Trabajo y Exposiciones',10.00,6,1),(1554,263,'Trabajo y Exposiciones',10.00,6,1),(2048,580,'Examen',50.00,1,1),(2049,589,'Examen',50.00,1,1),(2050,592,'Examen',50.00,1,1),(2051,593,'Examen',50.00,1,1),(2052,594,'Examen',50.00,1,1),(2053,595,'Examen',50.00,1,1),(2054,596,'Examen',50.00,1,1),(2055,597,'Examen',50.00,1,1),(2056,590,'Examen',50.00,1,1),(2057,591,'Examen',50.00,1,1),(2058,581,'Examen',50.00,1,1),(2059,582,'Examen',50.00,1,1),(2060,583,'Examen',50.00,1,1),(2061,584,'Examen',50.00,1,1),(2062,585,'Examen',50.00,1,1),(2063,586,'Examen',50.00,1,1),(2064,587,'Examen',50.00,1,1),(2065,588,'Examen',50.00,1,1),(2066,598,'Examen',50.00,1,1),(2067,599,'Examen',50.00,1,1),(2080,580,'Tareas',10.00,2,1),(2081,589,'Tareas',10.00,2,1),(2082,592,'Tareas',10.00,2,1),(2083,593,'Tareas',10.00,2,1),(2084,594,'Tareas',10.00,2,1),(2085,595,'Tareas',10.00,2,1),(2086,596,'Tareas',10.00,2,1),(2087,597,'Tareas',10.00,2,1),(2088,590,'Tareas',10.00,2,1),(2089,591,'Tareas',10.00,2,1),(2090,581,'Tareas',10.00,2,1),(2091,582,'Tareas',10.00,2,1),(2092,583,'Tareas',10.00,2,1),(2093,584,'Tareas',10.00,2,1),(2094,585,'Tareas',10.00,2,1),(2095,586,'Tareas',10.00,2,1),(2096,587,'Tareas',10.00,2,1),(2097,588,'Tareas',10.00,2,1),(2098,598,'Tareas',10.00,2,1),(2099,599,'Tareas',10.00,2,1),(2111,580,'Participación',10.00,3,1),(2112,589,'Participación',10.00,3,1),(2113,592,'Participación',10.00,3,1),(2114,593,'Participación',10.00,3,1),(2115,594,'Participación',10.00,3,1),(2116,595,'Participación',10.00,3,1),(2117,596,'Participación',10.00,3,1),(2118,597,'Participación',10.00,3,1),(2119,590,'Participación',10.00,3,1),(2120,591,'Participación',10.00,3,1),(2121,581,'Participación',10.00,3,1),(2122,582,'Participación',10.00,3,1),(2123,583,'Participación',10.00,3,1),(2124,584,'Participación',10.00,3,1),(2125,585,'Participación',10.00,3,1),(2126,586,'Participación',10.00,3,1),(2127,587,'Participación',10.00,3,1),(2128,588,'Participación',10.00,3,1),(2129,598,'Participación',10.00,3,1),(2130,599,'Participación',10.00,3,1),(2142,580,'Evaluación Parcial',10.00,4,1),(2143,589,'Evaluación Parcial',10.00,4,1),(2144,592,'Evaluación Parcial',10.00,4,1),(2145,593,'Evaluación Parcial',10.00,4,1),(2146,594,'Evaluación Parcial',10.00,4,1),(2147,595,'Evaluación Parcial',10.00,4,1),(2148,596,'Evaluación Parcial',10.00,4,1),(2149,597,'Evaluación Parcial',10.00,4,1),(2150,590,'Evaluación Parcial',10.00,4,1),(2151,591,'Evaluación Parcial',10.00,4,1),(2152,581,'Evaluación Parcial',10.00,4,1),(2153,582,'Evaluación Parcial',10.00,4,1),(2154,583,'Evaluación Parcial',10.00,4,1),(2155,584,'Evaluación Parcial',10.00,4,1),(2156,585,'Evaluación Parcial',10.00,4,1),(2157,586,'Evaluación Parcial',10.00,4,1),(2158,587,'Evaluación Parcial',10.00,4,1),(2159,588,'Evaluación Parcial',10.00,4,1),(2160,598,'Evaluación Parcial',10.00,4,1),(2161,599,'Evaluación Parcial',10.00,4,1),(2173,580,'Proyecto',10.00,5,1),(2174,589,'Proyecto',10.00,5,1),(2175,592,'Proyecto',10.00,5,1),(2176,593,'Proyecto',10.00,5,1),(2177,594,'Proyecto',10.00,5,1),(2178,595,'Proyecto',10.00,5,1),(2179,596,'Proyecto',10.00,5,1),(2180,597,'Proyecto',10.00,5,1),(2181,590,'Proyecto',10.00,5,1),(2182,591,'Proyecto',10.00,5,1),(2183,581,'Proyecto',10.00,5,1),(2184,582,'Proyecto',10.00,5,1),(2185,583,'Proyecto',10.00,5,1),(2186,584,'Proyecto',10.00,5,1),(2187,585,'Proyecto',10.00,5,1),(2188,586,'Proyecto',10.00,5,1),(2189,587,'Proyecto',10.00,5,1),(2190,588,'Proyecto',10.00,5,1),(2191,598,'Proyecto',10.00,5,1),(2192,599,'Proyecto',10.00,5,1),(2204,580,'Trabajo y Exposiciones',10.00,6,1),(2205,589,'Trabajo y Exposiciones',10.00,6,1),(2206,592,'Trabajo y Exposiciones',10.00,6,1),(2207,593,'Trabajo y Exposiciones',10.00,6,1),(2208,594,'Trabajo y Exposiciones',10.00,6,1),(2209,595,'Trabajo y Exposiciones',10.00,6,1),(2210,596,'Trabajo y Exposiciones',10.00,6,1),(2211,597,'Trabajo y Exposiciones',10.00,6,1),(2212,590,'Trabajo y Exposiciones',10.00,6,1),(2213,591,'Trabajo y Exposiciones',10.00,6,1),(2214,581,'Trabajo y Exposiciones',10.00,6,1),(2215,582,'Trabajo y Exposiciones',10.00,6,1),(2216,583,'Trabajo y Exposiciones',10.00,6,1),(2217,584,'Trabajo y Exposiciones',10.00,6,1),(2218,585,'Trabajo y Exposiciones',10.00,6,1),(2219,586,'Trabajo y Exposiciones',10.00,6,1),(2220,587,'Trabajo y Exposiciones',10.00,6,1),(2221,588,'Trabajo y Exposiciones',10.00,6,1),(2222,598,'Trabajo y Exposiciones',10.00,6,1),(2223,599,'Trabajo y Exposiciones',10.00,6,1),(2235,600,'Examen',50.00,1,1),(2236,600,'Tareas',10.00,2,1),(2237,600,'Participación',10.00,3,1),(2238,600,'Evaluación Parcial',10.00,4,1),(2239,600,'Proyecto',10.00,5,1),(2240,600,'Trabajo y Exposiciones',10.00,6,1);
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
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignacion_disciplina_aspectos`
--

LOCK TABLES `asignacion_disciplina_aspectos` WRITE;
/*!40000 ALTER TABLE `asignacion_disciplina_aspectos` DISABLE KEYS */;
INSERT INTO `asignacion_disciplina_aspectos` VALUES (1,NULL,1,'primaria','Examen',50.00,1,1),(2,NULL,1,'primaria','Tareas',10.00,2,1),(3,NULL,1,'primaria','Participación',10.00,3,1),(4,NULL,1,'primaria','Evaluación Parcial',10.00,4,1),(5,NULL,1,'primaria','Proyecto',10.00,5,1),(6,NULL,1,'primaria','Trabajo y Exposiciones',10.00,6,1),(7,NULL,1,'primaria','Promedio',0.00,7,1),(8,86,1,'primaria','Examen',50.00,1,1),(9,88,1,'primaria','Examen',50.00,1,1),(10,266,1,'primaria','Examen',50.00,1,1),(11,267,1,'primaria','Examen',50.00,1,1),(15,86,1,'primaria','Tareas',10.00,2,1),(16,88,1,'primaria','Tareas',10.00,2,1),(17,266,1,'primaria','Tareas',10.00,2,1),(18,267,1,'primaria','Tareas',10.00,2,1),(22,86,1,'primaria','Participación',10.00,3,1),(23,88,1,'primaria','Participación',10.00,3,1),(24,266,1,'primaria','Participación',10.00,3,1),(25,267,1,'primaria','Participación',10.00,3,1),(29,86,1,'primaria','Evaluación Parcial',10.00,4,1),(30,88,1,'primaria','Evaluación Parcial',10.00,4,1),(31,266,1,'primaria','Evaluación Parcial',10.00,4,1),(32,267,1,'primaria','Evaluación Parcial',10.00,4,1),(36,86,1,'primaria','Proyecto',10.00,5,1),(37,88,1,'primaria','Proyecto',10.00,5,1),(38,266,1,'primaria','Proyecto',10.00,5,1),(39,267,1,'primaria','Proyecto',10.00,5,1),(43,86,1,'primaria','Trabajo y Exposiciones',10.00,6,1),(44,88,1,'primaria','Trabajo y Exposiciones',10.00,6,1),(45,266,1,'primaria','Trabajo y Exposiciones',10.00,6,1),(46,267,1,'primaria','Trabajo y Exposiciones',10.00,6,1),(47,598,1,'primaria','Examen',50.00,1,1),(48,598,1,'primaria','Tareas',10.00,2,1),(49,598,1,'primaria','Participación',10.00,3,1),(50,598,1,'primaria','Evaluación Parcial',10.00,4,1),(51,598,1,'primaria','Proyecto',10.00,5,1),(52,598,1,'primaria','Trabajo y Exposiciones',10.00,6,1);
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
) ENGINE=InnoDB AUTO_INCREMENT=1129 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignacion_ingles_aspectos`
--

LOCK TABLES `asignacion_ingles_aspectos` WRITE;
/*!40000 ALTER TABLE `asignacion_ingles_aspectos` DISABLE KEYS */;
INSERT INTO `asignacion_ingles_aspectos` VALUES (169,NULL,1,'primaria','Listening',0.00,0,1),(170,NULL,1,'primaria','Speaking',0.00,0,1),(171,NULL,1,'primaria','Reading',0.00,0,1),(172,NULL,1,'primaria','Writing',0.00,0,1),(173,NULL,1,'primaria','Vocabulary',0.00,0,1),(174,NULL,1,'primaria','Grammar',0.00,0,1),(175,NULL,1,'primaria','Spelling',0.00,0,1),(176,NULL,1,'primaria','Science',0.00,0,1),(177,44,1,'primaria','Listening',0.00,0,1),(178,44,1,'primaria','Speaking',0.00,0,1),(179,44,1,'primaria','Reading',0.00,0,1),(180,44,1,'primaria','Writing',0.00,0,1),(181,44,1,'primaria','Vocabulary',0.00,0,1),(182,44,1,'primaria','Grammar',0.00,0,1),(183,44,1,'primaria','Spelling',0.00,0,1),(184,44,1,'primaria','Science',0.00,0,1),(193,NULL,1,'primaria','Listening',0.00,0,1),(194,NULL,1,'primaria','Speaking',0.00,0,1),(195,NULL,1,'primaria','Reading',0.00,0,1),(196,NULL,1,'primaria','Writing',0.00,0,1),(197,NULL,1,'primaria','Vocabulary',0.00,0,1),(198,NULL,1,'primaria','Grammar',0.00,0,1),(199,NULL,1,'primaria','Spelling',0.00,0,1),(200,NULL,1,'primaria','Science',0.00,0,1),(201,NULL,1,'primaria','Listening',0.00,0,1),(202,NULL,1,'primaria','Speaking',0.00,0,1),(203,NULL,1,'primaria','Reading',0.00,0,1),(204,NULL,1,'primaria','Writing',0.00,0,1),(205,NULL,1,'primaria','Vocabulary',0.00,0,1),(206,NULL,1,'primaria','Grammar',0.00,0,1),(207,NULL,1,'primaria','Spelling',0.00,0,1),(208,NULL,1,'primaria','Phonetics',0.00,0,1),(209,NULL,1,'primaria','Science',0.00,0,1),(210,NULL,2,'primaria','Listening',0.00,0,1),(211,NULL,2,'primaria','Speaking',0.00,0,1),(212,NULL,2,'primaria','Reading',0.00,0,1),(213,NULL,2,'primaria','Writing',0.00,0,1),(214,NULL,2,'primaria','Vocabulary',0.00,0,1),(215,NULL,2,'primaria','Grammar',0.00,0,1),(216,NULL,2,'primaria','Spelling',0.00,0,1),(217,NULL,2,'primaria','Phonetics',0.00,0,1),(218,NULL,2,'primaria','Science',0.00,0,1),(219,NULL,3,'primaria','Listening',0.00,0,1),(220,NULL,3,'primaria','Speaking',0.00,0,1),(221,NULL,3,'primaria','Reading',0.00,0,1),(222,NULL,3,'primaria','Writing',0.00,0,1),(223,NULL,3,'primaria','Vocabulary',0.00,0,1),(224,NULL,3,'primaria','Grammar',0.00,0,1),(225,NULL,3,'primaria','Spelling',0.00,0,1),(226,NULL,3,'primaria','Phonetics',0.00,0,1),(227,NULL,3,'primaria','Science',0.00,0,1),(228,NULL,4,'primaria','Listening',0.00,0,1),(229,NULL,4,'primaria','Speaking',0.00,0,1),(230,NULL,4,'primaria','Reading',0.00,0,1),(231,NULL,4,'primaria','Writing',0.00,0,1),(232,NULL,4,'primaria','Vocabulary',0.00,0,1),(233,NULL,4,'primaria','Grammar',0.00,0,1),(234,NULL,4,'primaria','Spelling',0.00,0,1),(235,NULL,4,'primaria','Phonetics',0.00,0,1),(236,NULL,4,'primaria','Science',0.00,0,1),(237,NULL,5,'primaria','Listening',0.00,0,1),(238,NULL,5,'primaria','Speaking',0.00,0,1),(239,NULL,5,'primaria','Reading',0.00,0,1),(240,NULL,5,'primaria','Writing',0.00,0,1),(241,NULL,5,'primaria','Vocabulary',0.00,0,1),(242,NULL,5,'primaria','Grammar',0.00,0,1),(243,NULL,5,'primaria','Spelling',0.00,0,1),(244,NULL,5,'primaria','Phonetics',0.00,0,1),(245,NULL,5,'primaria','Science',0.00,0,1),(246,NULL,5,'primaria','Social Studies',0.00,0,1),(247,NULL,5,'primaria','Literature',0.00,0,1),(248,NULL,6,'primaria','Listening',0.00,0,1),(249,NULL,6,'primaria','Speaking',0.00,0,1),(250,NULL,6,'primaria','Reading',0.00,0,1),(251,NULL,6,'primaria','Writing',0.00,0,1),(252,NULL,6,'primaria','Vocabulary',0.00,0,1),(253,NULL,6,'primaria','Grammar',0.00,0,1),(254,NULL,6,'primaria','Spelling',0.00,0,1),(255,NULL,6,'primaria','Phonetics',0.00,0,1),(256,NULL,6,'primaria','Science',0.00,0,1),(257,NULL,6,'primaria','Social Studies',0.00,0,1),(258,NULL,6,'primaria','Literature',0.00,0,1),(259,NULL,1,'secundaria','Listening',0.00,0,1),(260,NULL,1,'secundaria','Speaking',0.00,0,1),(261,NULL,1,'secundaria','Reading',0.00,0,1),(262,NULL,1,'secundaria','Writing',0.00,0,1),(263,NULL,1,'secundaria','Vocabulary',0.00,0,1),(264,NULL,1,'secundaria','Grammar',0.00,0,1),(265,NULL,1,'secundaria','Spelling',0.00,0,1),(266,NULL,1,'secundaria','Phonetics',0.00,0,1),(267,NULL,1,'secundaria','Science',0.00,0,1),(268,NULL,1,'secundaria','Social Studies',0.00,0,1),(269,NULL,1,'secundaria','Literature',0.00,0,1),(270,NULL,2,'secundaria','Listening',0.00,0,1),(271,NULL,2,'secundaria','Speaking',0.00,0,1),(272,NULL,2,'secundaria','Reading',0.00,0,1),(273,NULL,2,'secundaria','Writing',0.00,0,1),(274,NULL,2,'secundaria','Vocabulary',0.00,0,1),(275,NULL,2,'secundaria','Grammar',0.00,0,1),(276,NULL,2,'secundaria','Spelling',0.00,0,1),(277,NULL,2,'secundaria','Phonetics',0.00,0,1),(278,NULL,2,'secundaria','Science',0.00,0,1),(279,NULL,2,'secundaria','Social Studies',0.00,0,1),(280,NULL,2,'secundaria','Literature',0.00,0,1),(281,NULL,3,'secundaria','Listening',0.00,0,1),(282,NULL,3,'secundaria','Speaking',0.00,0,1),(283,NULL,3,'secundaria','Reading',0.00,0,1),(284,NULL,3,'secundaria','Writing',0.00,0,1),(285,NULL,3,'secundaria','Vocabulary',0.00,0,1),(286,NULL,3,'secundaria','Grammar',0.00,0,1),(287,NULL,3,'secundaria','Spelling',0.00,0,1),(288,NULL,3,'secundaria','Phonetics',0.00,0,1),(289,NULL,3,'secundaria','Science',0.00,0,1),(290,NULL,3,'secundaria','Social Studies',0.00,0,1),(291,NULL,3,'secundaria','Literature',0.00,0,1),(292,NULL,1,'primaria','Listening',0.00,0,1),(293,NULL,1,'primaria','Speaking',0.00,0,1),(294,NULL,1,'primaria','Reading',0.00,0,1),(295,NULL,1,'primaria','Writing',0.00,0,1),(296,NULL,1,'primaria','Vocabulary',0.00,0,1),(297,NULL,1,'primaria','Grammar',0.00,0,1),(298,NULL,1,'primaria','Spelling',0.00,0,1),(299,NULL,1,'primaria','Phonetics',0.00,0,1),(300,NULL,1,'primaria','Science',0.00,0,1),(301,NULL,2,'primaria','Listening',0.00,0,1),(302,NULL,2,'primaria','Speaking',0.00,0,1),(303,NULL,2,'primaria','Reading',0.00,0,1),(304,NULL,2,'primaria','Writing',0.00,0,1),(305,NULL,2,'primaria','Vocabulary',0.00,0,1),(306,NULL,2,'primaria','Grammar',0.00,0,1),(307,NULL,2,'primaria','Spelling',0.00,0,1),(308,NULL,2,'primaria','Phonetics',0.00,0,1),(309,NULL,2,'primaria','Science',0.00,0,1),(310,NULL,3,'primaria','Listening',0.00,0,1),(311,NULL,3,'primaria','Speaking',0.00,0,1),(312,NULL,3,'primaria','Reading',0.00,0,1),(313,NULL,3,'primaria','Writing',0.00,0,1),(314,NULL,3,'primaria','Vocabulary',0.00,0,1),(315,NULL,3,'primaria','Grammar',0.00,0,1),(316,NULL,3,'primaria','Spelling',0.00,0,1),(317,NULL,3,'primaria','Phonetics',0.00,0,1),(318,NULL,3,'primaria','Science',0.00,0,1),(319,NULL,4,'primaria','Listening',0.00,0,1),(320,NULL,4,'primaria','Speaking',0.00,0,1),(321,NULL,4,'primaria','Reading',0.00,0,1),(322,NULL,4,'primaria','Writing',0.00,0,1),(323,NULL,4,'primaria','Vocabulary',0.00,0,1),(324,NULL,4,'primaria','Grammar',0.00,0,1),(325,NULL,4,'primaria','Spelling',0.00,0,1),(326,NULL,4,'primaria','Phonetics',0.00,0,1),(327,NULL,4,'primaria','Science',0.00,0,1),(328,NULL,5,'primaria','Listening',0.00,0,1),(329,NULL,5,'primaria','Speaking',0.00,0,1),(330,NULL,5,'primaria','Reading',0.00,0,1),(331,NULL,5,'primaria','Writing',0.00,0,1),(332,NULL,5,'primaria','Vocabulary',0.00,0,1),(333,NULL,5,'primaria','Grammar',0.00,0,1),(334,NULL,5,'primaria','Spelling',0.00,0,1),(335,NULL,5,'primaria','Phonetics',0.00,0,1),(336,NULL,5,'primaria','Science',0.00,0,1),(337,NULL,5,'primaria','Social Studies',0.00,0,1),(338,NULL,5,'primaria','Literature',0.00,0,1),(339,NULL,6,'primaria','Listening',0.00,0,1),(340,NULL,6,'primaria','Speaking',0.00,0,1),(341,NULL,6,'primaria','Reading',0.00,0,1),(342,NULL,6,'primaria','Writing',0.00,0,1),(343,NULL,6,'primaria','Vocabulary',0.00,0,1),(344,NULL,6,'primaria','Grammar',0.00,0,1),(345,NULL,6,'primaria','Spelling',0.00,0,1),(346,NULL,6,'primaria','Phonetics',0.00,0,1),(347,NULL,6,'primaria','Science',0.00,0,1),(348,NULL,6,'primaria','Social Studies',0.00,0,1),(349,NULL,6,'primaria','Literature',0.00,0,1),(350,NULL,1,'secundaria','Listening',0.00,0,1),(351,NULL,1,'secundaria','Speaking',0.00,0,1),(352,NULL,1,'secundaria','Reading',0.00,0,1),(353,NULL,1,'secundaria','Writing',0.00,0,1),(354,NULL,1,'secundaria','Vocabulary',0.00,0,1),(355,NULL,1,'secundaria','Grammar',0.00,0,1),(356,NULL,1,'secundaria','Spelling',0.00,0,1),(357,NULL,1,'secundaria','Phonetics',0.00,0,1),(358,NULL,1,'secundaria','Science',0.00,0,1),(359,NULL,1,'secundaria','Social Studies',0.00,0,1),(360,NULL,1,'secundaria','Literature',0.00,0,1),(361,NULL,2,'secundaria','Listening',0.00,0,1),(362,NULL,2,'secundaria','Speaking',0.00,0,1),(363,NULL,2,'secundaria','Reading',0.00,0,1),(364,NULL,2,'secundaria','Writing',0.00,0,1),(365,NULL,2,'secundaria','Vocabulary',0.00,0,1),(366,NULL,2,'secundaria','Grammar',0.00,0,1),(367,NULL,2,'secundaria','Spelling',0.00,0,1),(368,NULL,2,'secundaria','Phonetics',0.00,0,1),(369,NULL,2,'secundaria','Science',0.00,0,1),(370,NULL,2,'secundaria','Social Studies',0.00,0,1),(371,NULL,2,'secundaria','Literature',0.00,0,1),(372,NULL,3,'secundaria','Listening',0.00,0,1),(373,NULL,3,'secundaria','Speaking',0.00,0,1),(374,NULL,3,'secundaria','Reading',0.00,0,1),(375,NULL,3,'secundaria','Writing',0.00,0,1),(376,NULL,3,'secundaria','Vocabulary',0.00,0,1),(377,NULL,3,'secundaria','Grammar',0.00,0,1),(378,NULL,3,'secundaria','Spelling',0.00,0,1),(379,NULL,3,'secundaria','Phonetics',0.00,0,1),(380,NULL,3,'secundaria','Science',0.00,0,1),(381,NULL,3,'secundaria','Social Studies',0.00,0,1),(382,NULL,3,'secundaria','Literature',0.00,0,1),(383,149,2,'primaria','Listening',0.00,1,1),(384,149,2,'primaria','Speaking',0.00,2,1),(385,149,2,'primaria','Writing',0.00,3,1),(386,149,2,'primaria','Reading',0.00,4,1),(387,149,2,'primaria','Vocabulary',0.00,5,1),(388,149,2,'primaria','Grammar',0.00,6,1),(389,149,2,'primaria','Spelling',0.00,7,1),(390,149,2,'primaria','Science',0.00,8,1),(391,164,2,'primaria','Listening',0.00,1,1),(392,164,2,'primaria','Speaking',0.00,2,1),(393,164,2,'primaria','Writing',0.00,3,1),(394,164,2,'primaria','Reading',0.00,4,1),(395,164,2,'primaria','Vocabulary',0.00,5,1),(396,164,2,'primaria','Grammar',0.00,6,1),(397,164,2,'primaria','Spelling',0.00,7,1),(398,164,2,'primaria','Science',0.00,8,1),(399,123,1,'primaria','Grammar',50.00,1,1),(400,123,1,'primaria','Speaking',20.00,2,1),(401,123,1,'primaria','Listening',10.00,3,1),(402,123,1,'primaria','Reading',10.00,4,1),(403,123,1,'primaria','Writing',10.00,5,1),(1024,581,1,'primaria','Listening',0.00,0,1),(1025,581,1,'primaria','Speaking',0.00,1,1),(1026,581,1,'primaria','Reading',0.00,2,1),(1027,581,1,'primaria','Writing',0.00,3,1),(1028,581,1,'primaria','Vocabulary',0.00,4,1),(1029,581,1,'primaria','Grammar',0.00,5,1),(1030,581,1,'primaria','Spelling',0.00,6,1),(1080,582,1,'primaria','Listening',0.00,0,1),(1081,582,1,'primaria','Speaking',0.00,1,1),(1082,582,1,'primaria','Reading',0.00,2,1),(1083,582,1,'primaria','Writing',0.00,3,1),(1084,582,1,'primaria','Vocabulary',0.00,4,1),(1085,582,1,'primaria','Grammar',0.00,5,1),(1086,582,1,'primaria','Spelling',0.00,6,1),(1087,583,1,'primaria','Listening',0.00,0,1),(1088,583,1,'primaria','Speaking',0.00,1,1),(1089,583,1,'primaria','Reading',0.00,2,1),(1090,583,1,'primaria','Writing',0.00,3,1),(1091,583,1,'primaria','Vocabulary',0.00,4,1),(1092,583,1,'primaria','Grammar',0.00,5,1),(1093,583,1,'primaria','Spelling',0.00,6,1),(1094,584,1,'primaria','Listening',0.00,0,1),(1095,584,1,'primaria','Speaking',0.00,1,1),(1096,584,1,'primaria','Reading',0.00,2,1),(1097,584,1,'primaria','Writing',0.00,3,1),(1098,584,1,'primaria','Vocabulary',0.00,4,1),(1099,584,1,'primaria','Grammar',0.00,5,1),(1100,584,1,'primaria','Spelling',0.00,6,1),(1101,585,1,'primaria','Listening',0.00,0,1),(1102,585,1,'primaria','Speaking',0.00,1,1),(1103,585,1,'primaria','Reading',0.00,2,1),(1104,585,1,'primaria','Writing',0.00,3,1),(1105,585,1,'primaria','Vocabulary',0.00,4,1),(1106,585,1,'primaria','Grammar',0.00,5,1),(1107,585,1,'primaria','Spelling',0.00,6,1),(1108,586,1,'primaria','Listening',0.00,0,1),(1109,586,1,'primaria','Speaking',0.00,1,1),(1110,586,1,'primaria','Reading',0.00,2,1),(1111,586,1,'primaria','Writing',0.00,3,1),(1112,586,1,'primaria','Vocabulary',0.00,4,1),(1113,586,1,'primaria','Grammar',0.00,5,1),(1114,586,1,'primaria','Spelling',0.00,6,1),(1115,587,1,'primaria','Listening',0.00,0,1),(1116,587,1,'primaria','Speaking',0.00,1,1),(1117,587,1,'primaria','Reading',0.00,2,1),(1118,587,1,'primaria','Writing',0.00,3,1),(1119,587,1,'primaria','Vocabulary',0.00,4,1),(1120,587,1,'primaria','Grammar',0.00,5,1),(1121,587,1,'primaria','Spelling',0.00,6,1),(1122,588,1,'primaria','Listening',0.00,0,1),(1123,588,1,'primaria','Speaking',0.00,1,1),(1124,588,1,'primaria','Reading',0.00,2,1),(1125,588,1,'primaria','Writing',0.00,3,1),(1126,588,1,'primaria','Vocabulary',0.00,4,1),(1127,588,1,'primaria','Grammar',0.00,5,1),(1128,588,1,'primaria','Spelling',0.00,6,1);
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
) ENGINE=InnoDB AUTO_INCREMENT=191 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignacion_maestros`
--

LOCK TABLES `asignacion_maestros` WRITE;
/*!40000 ALTER TABLE `asignacion_maestros` DISABLE KEYS */;
INSERT INTO `asignacion_maestros` VALUES (29,36,1,1,0,'2026-05-30 19:43:36',1),(30,38,1,1,0,'2026-05-30 19:43:36',1),(33,41,1,1,0,'2026-05-30 19:43:36',1),(34,43,1,1,0,'2026-05-30 19:43:36',1),(65,86,1,1,0,'2026-06-06 15:43:05',1),(66,87,1,1,0,'2026-06-06 15:43:05',1),(87,346,1,1,0,'2026-06-09 20:39:27',1),(93,416,5,0,0,'2026-06-18 11:16:53',1),(95,44,1,1,0,'2026-07-09 10:39:06',1),(159,580,1,1,0,'2026-07-13 13:34:49',1),(160,314,1,1,0,'2026-07-13 13:34:49',1),(161,581,3,1,0,'2026-07-13 13:37:10',1),(169,582,3,1,0,'2026-07-13 13:39:49',1),(170,583,4,1,0,'2026-07-13 13:39:54',1),(171,584,4,1,0,'2026-07-13 13:39:59',1),(172,585,4,1,0,'2026-07-13 13:40:05',1),(173,586,4,1,0,'2026-07-13 13:40:17',1),(174,587,4,1,0,'2026-07-13 13:40:40',1),(175,588,4,1,0,'2026-07-13 13:41:01',1),(176,581,5,0,1,'2026-07-13 13:44:15',1),(177,582,5,0,1,'2026-07-13 13:44:15',1),(178,583,5,0,1,'2026-07-13 13:44:15',1),(179,584,5,0,1,'2026-07-13 13:44:15',1),(180,585,5,0,1,'2026-07-13 13:44:15',1),(181,586,5,0,1,'2026-07-13 13:44:15',1),(182,587,5,0,1,'2026-07-13 13:44:15',1),(183,588,5,0,1,'2026-07-13 13:44:15',1);
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
) ENGINE=InnoDB AUTO_INCREMENT=601 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignaciones`
--

LOCK TABLES `asignaciones` WRITE;
/*!40000 ALTER TABLE `asignaciones` DISABLE KEYS */;
INSERT INTO `asignaciones` VALUES (77,1,9,2,'primaria',1,'B',5,1,'2026-06-05 18:40:26','2026-07-12 20:48:43'),(78,1,13,3,'primaria',1,'B',7,1,'2026-06-05 18:40:26','2026-07-12 20:48:43'),(79,1,15,4,'primaria',1,'B',9,1,'2026-06-05 18:40:26','2026-07-12 20:48:43'),(80,1,16,4,'primaria',1,'B',10,1,'2026-06-05 18:40:26','2026-07-12 20:48:43'),(83,1,14,4,'primaria',1,'B',8,1,'2026-06-05 18:41:30','2026-07-12 20:48:43'),(84,1,10,2,'primaria',1,'B',6,1,'2026-06-05 18:41:30','2026-07-12 20:48:43'),(88,1,297,NULL,'primaria',1,'B',19,1,'2026-06-06 15:43:57','2026-07-12 20:48:43'),(89,1,298,NULL,'primaria',1,'B',20,1,'2026-06-06 15:43:57','2026-07-12 20:48:43'),(93,4,4,1,'primaria',1,'A',4,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(94,4,5,2,'primaria',1,'A',5,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(95,4,6,2,'primaria',1,'A',6,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(98,4,9,3,'primaria',1,'A',9,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(99,4,10,3,'primaria',1,'A',10,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(100,4,11,4,'primaria',1,'A',11,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(101,4,12,4,'primaria',1,'A',12,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(102,4,13,4,'primaria',1,'A',13,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(103,4,14,NULL,'primaria',1,'A',14,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(104,4,15,NULL,'primaria',1,'A',15,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(105,4,16,1,'primaria',1,'A',16,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(106,4,17,1,'primaria',1,'A',17,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(113,4,1,1,'primaria',1,'B',1,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(116,4,4,1,'primaria',1,'B',4,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(117,4,5,2,'primaria',1,'B',5,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(118,4,6,2,'primaria',1,'B',6,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(121,4,9,3,'primaria',1,'B',9,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(122,4,10,3,'primaria',1,'B',10,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(123,4,11,4,'primaria',1,'B',11,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(124,4,12,4,'primaria',1,'B',12,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(125,4,13,4,'primaria',1,'B',13,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(126,4,14,NULL,'primaria',1,'B',14,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(127,4,15,NULL,'primaria',1,'B',15,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(128,4,16,1,'primaria',1,'B',16,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(129,4,17,1,'primaria',1,'B',17,1,'2026-06-09 12:20:56','2026-07-12 20:48:43'),(142,4,4,1,'primaria',2,'A',4,1,'2026-06-09 12:30:30','2026-07-12 20:48:43'),(145,4,4,1,'primaria',2,'B',4,1,'2026-06-09 12:30:30','2026-07-12 20:48:43'),(148,4,1,1,'primaria',2,'A',1,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(149,4,2,1,'primaria',2,'A',2,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(150,4,3,1,'primaria',2,'A',3,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(151,4,5,2,'primaria',2,'A',5,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(152,4,6,2,'primaria',2,'A',6,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(154,4,10,3,'primaria',2,'A',8,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(155,4,11,4,'primaria',2,'A',9,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(156,4,12,4,'primaria',2,'A',10,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(157,4,13,4,'primaria',2,'A',11,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(158,4,14,NULL,'primaria',2,'A',12,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(159,4,15,NULL,'primaria',2,'A',13,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(163,4,1,1,'primaria',2,'B',1,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(164,4,2,1,'primaria',2,'B',2,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(165,4,3,1,'primaria',2,'B',3,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(166,4,5,2,'primaria',2,'B',5,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(167,4,6,2,'primaria',2,'B',6,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(169,4,10,3,'primaria',2,'B',8,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(170,4,11,4,'primaria',2,'B',9,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(171,4,12,4,'primaria',2,'B',10,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(172,4,13,4,'primaria',2,'B',11,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(173,4,14,NULL,'primaria',2,'B',12,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(174,4,15,NULL,'primaria',2,'B',13,1,'2026-06-09 12:34:08','2026-07-12 20:48:43'),(200,1,1,1,'primaria',2,'A',7,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(201,1,3,NULL,'primaria',2,'A',0,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(202,1,4,1,'primaria',2,'A',21,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(203,1,5,2,'primaria',2,'A',8,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(204,1,9,2,'primaria',2,'A',1,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(205,1,10,2,'primaria',2,'A',10,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(206,1,11,3,'primaria',2,'A',5,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(207,1,12,3,'primaria',2,'A',6,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(208,1,13,3,'primaria',2,'A',3,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(209,1,14,4,'primaria',2,'A',2,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(210,1,15,4,'primaria',2,'A',11,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(211,1,16,4,'primaria',2,'A',9,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(231,1,1,1,'primaria',2,'B',7,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(232,1,3,NULL,'primaria',2,'B',0,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(233,1,4,1,'primaria',2,'B',21,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(234,1,5,2,'primaria',2,'B',8,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(235,1,9,2,'primaria',2,'B',1,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(236,1,10,2,'primaria',2,'B',10,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(237,1,11,3,'primaria',2,'B',5,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(238,1,12,3,'primaria',2,'B',6,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(239,1,13,3,'primaria',2,'B',3,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(240,1,14,4,'primaria',2,'B',2,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(241,1,15,4,'primaria',2,'B',11,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(242,1,16,4,'primaria',2,'B',9,1,'2026-06-09 12:47:42','2026-07-12 20:48:43'),(262,1,298,NULL,'primaria',1,'C',20,1,'2026-06-09 19:04:03','2026-07-12 20:48:43'),(263,1,298,NULL,'primaria',1,'D',20,1,'2026-06-09 19:04:03','2026-07-12 20:48:43'),(264,1,9,2,'primaria',1,'C',5,1,'2026-06-09 19:04:03','2026-07-12 20:48:43'),(265,1,9,2,'primaria',1,'D',5,1,'2026-06-09 19:04:03','2026-07-12 20:48:43'),(266,1,297,NULL,'primaria',1,'C',19,1,'2026-06-09 19:04:03','2026-07-12 20:48:43'),(267,1,297,NULL,'primaria',1,'D',19,1,'2026-06-09 19:04:03','2026-07-12 20:48:43'),(268,1,13,3,'primaria',1,'C',7,1,'2026-06-09 19:04:03','2026-07-12 20:48:43'),(269,1,13,3,'primaria',1,'D',7,1,'2026-06-09 19:04:03','2026-07-12 20:48:43'),(272,1,5,2,'primaria',1,'B',4,1,'2026-06-09 19:04:03','2026-07-12 20:48:43'),(273,1,5,2,'primaria',1,'C',4,1,'2026-06-09 19:04:03','2026-07-12 20:48:43'),(274,1,5,2,'primaria',1,'D',4,1,'2026-06-09 19:04:03','2026-07-12 20:48:43'),(279,1,16,4,'primaria',1,'C',10,1,'2026-06-09 19:04:04','2026-07-12 20:48:43'),(280,1,16,4,'primaria',1,'D',10,1,'2026-06-09 19:04:04','2026-07-12 20:48:43'),(281,1,15,4,'primaria',1,'C',9,1,'2026-06-09 19:04:04','2026-07-12 20:48:43'),(282,1,15,4,'primaria',1,'D',9,1,'2026-06-09 19:04:04','2026-07-12 20:48:43'),(305,1,14,4,'primaria',1,'C',8,1,'2026-06-09 19:04:04','2026-07-12 20:48:43'),(306,1,14,4,'primaria',1,'D',8,1,'2026-06-09 19:04:04','2026-07-12 20:48:43'),(307,1,10,2,'primaria',1,'C',6,1,'2026-06-09 19:04:04','2026-07-12 20:48:43'),(308,1,10,2,'primaria',1,'D',6,1,'2026-06-09 19:04:04','2026-07-12 20:48:43'),(310,1,4,1,'primaria',1,'B',21,1,'2026-06-09 19:35:09','2026-07-12 20:48:43'),(311,1,4,1,'primaria',1,'C',21,1,'2026-06-09 19:35:09','2026-07-12 20:48:43'),(312,1,4,1,'primaria',1,'D',21,1,'2026-06-09 19:35:09','2026-07-12 20:48:43'),(314,1,1,1,'primaria',1,'B',1,1,'2026-06-09 19:35:29','2026-07-12 20:48:43'),(315,1,1,1,'primaria',1,'C',1,1,'2026-06-09 19:35:29','2026-07-12 20:48:43'),(316,1,1,1,'primaria',1,'D',1,1,'2026-06-09 19:35:29','2026-07-12 20:48:43'),(419,1,278,1,'primaria',1,'B',2,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(420,1,278,1,'primaria',1,'C',2,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(421,1,278,1,'primaria',1,'D',2,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(423,1,279,1,'primaria',1,'B',1,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(424,1,279,1,'primaria',1,'C',1,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(425,1,279,1,'primaria',1,'D',1,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(427,1,280,1,'primaria',1,'B',12,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(428,1,280,1,'primaria',1,'C',12,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(429,1,280,1,'primaria',1,'D',12,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(431,1,281,1,'primaria',1,'B',13,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(432,1,281,1,'primaria',1,'C',13,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(433,1,281,1,'primaria',1,'D',13,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(435,1,282,1,'primaria',1,'B',14,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(436,1,282,1,'primaria',1,'C',14,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(437,1,282,1,'primaria',1,'D',14,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(439,1,285,1,'primaria',1,'B',15,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(440,1,285,1,'primaria',1,'C',15,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(441,1,285,1,'primaria',1,'D',15,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(443,1,286,1,'primaria',1,'B',16,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(444,1,286,1,'primaria',1,'C',16,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(445,1,286,1,'primaria',1,'D',16,1,'2026-06-18 05:48:54','2026-07-12 20:48:43'),(448,1,27,1,'primaria',1,'B',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(449,1,27,1,'primaria',1,'C',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(450,1,27,1,'primaria',1,'D',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(452,1,28,1,'primaria',1,'B',23,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(453,1,28,1,'primaria',1,'C',23,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(454,1,28,1,'primaria',1,'D',23,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(455,1,4,1,'primaria',2,'C',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(456,1,4,1,'primaria',2,'D',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(457,1,27,1,'primaria',2,'A',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(458,1,27,1,'primaria',2,'B',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(459,1,27,1,'primaria',2,'C',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(460,1,27,1,'primaria',2,'D',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(461,1,28,1,'primaria',2,'A',23,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(462,1,28,1,'primaria',2,'B',23,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(463,1,28,1,'primaria',2,'C',23,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(464,1,28,1,'primaria',2,'D',23,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(465,1,4,1,'primaria',3,'A',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(466,1,4,1,'primaria',3,'B',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(467,1,4,1,'primaria',3,'C',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(468,1,4,1,'primaria',3,'D',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(469,1,27,1,'primaria',3,'A',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(470,1,27,1,'primaria',3,'B',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(471,1,27,1,'primaria',3,'C',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(472,1,27,1,'primaria',3,'D',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(473,1,28,1,'primaria',3,'A',23,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(474,1,28,1,'primaria',3,'B',23,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(475,1,28,1,'primaria',3,'C',23,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(476,1,28,1,'primaria',3,'D',23,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(477,1,4,1,'primaria',4,'A',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(478,1,4,1,'primaria',4,'B',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(479,1,4,1,'primaria',4,'C',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(480,1,4,1,'primaria',4,'D',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(481,1,27,1,'primaria',4,'A',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(482,1,27,1,'primaria',4,'B',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(483,1,27,1,'primaria',4,'C',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(484,1,27,1,'primaria',4,'D',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(485,1,28,1,'primaria',4,'A',23,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(486,1,28,1,'primaria',4,'B',23,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(487,1,28,1,'primaria',4,'C',23,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(488,1,28,1,'primaria',4,'D',23,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(489,1,4,1,'primaria',5,'A',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(490,1,4,1,'primaria',5,'B',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(491,1,4,1,'primaria',5,'C',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(492,1,4,1,'primaria',5,'D',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(493,1,27,1,'primaria',5,'A',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(494,1,27,1,'primaria',5,'B',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(495,1,27,1,'primaria',5,'C',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(496,1,27,1,'primaria',5,'D',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(497,1,29,1,'primaria',5,'A',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(498,1,29,1,'primaria',5,'B',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(499,1,29,1,'primaria',5,'C',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(500,1,29,1,'primaria',5,'D',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(501,1,4,1,'primaria',6,'A',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(502,1,4,1,'primaria',6,'B',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(503,1,4,1,'primaria',6,'C',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(504,1,4,1,'primaria',6,'D',21,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(505,1,27,1,'primaria',6,'A',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(506,1,27,1,'primaria',6,'B',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(507,1,27,1,'primaria',6,'C',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(508,1,27,1,'primaria',6,'D',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(509,1,29,1,'primaria',6,'A',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(510,1,29,1,'primaria',6,'B',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(511,1,29,1,'primaria',6,'C',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(512,1,29,1,'primaria',6,'D',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(513,1,27,1,'secundaria',1,'A',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(514,1,27,1,'secundaria',1,'B',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(515,1,27,1,'secundaria',1,'C',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(516,1,27,1,'secundaria',1,'D',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(517,1,29,1,'secundaria',1,'A',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(518,1,29,1,'secundaria',1,'B',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(519,1,29,1,'secundaria',1,'C',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(520,1,29,1,'secundaria',1,'D',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(521,1,27,1,'secundaria',2,'A',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(522,1,27,1,'secundaria',2,'B',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(523,1,27,1,'secundaria',2,'C',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(524,1,27,1,'secundaria',2,'D',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(525,1,29,1,'secundaria',2,'A',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(526,1,29,1,'secundaria',2,'B',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(527,1,29,1,'secundaria',2,'C',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(528,1,29,1,'secundaria',2,'D',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(529,1,27,1,'secundaria',3,'A',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(530,1,27,1,'secundaria',3,'B',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(531,1,27,1,'secundaria',3,'C',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(532,1,27,1,'secundaria',3,'D',22,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(533,1,29,1,'secundaria',3,'A',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(534,1,29,1,'secundaria',3,'B',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(535,1,29,1,'secundaria',3,'C',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(536,1,29,1,'secundaria',3,'D',24,1,'2026-06-18 06:09:02','2026-07-12 20:48:43'),(577,1,288,1,'primaria',1,'B',17,1,'2026-07-13 01:29:36','2026-07-13 07:29:36'),(578,1,288,1,'primaria',1,'C',17,1,'2026-07-13 01:29:36','2026-07-13 07:29:36'),(579,1,288,1,'primaria',1,'D',17,1,'2026-07-13 01:29:36','2026-07-13 07:29:36'),(580,1,1,1,'primaria',1,'A',1,1,'2026-07-13 11:52:43','2026-07-13 17:52:43'),(581,1,278,1,'primaria',1,'A',2,1,'2026-07-13 11:52:43','2026-07-13 17:52:43'),(582,1,279,1,'primaria',1,'A',3,1,'2026-07-13 11:52:43','2026-07-13 17:52:43'),(583,1,280,1,'primaria',1,'A',4,1,'2026-07-13 11:52:43','2026-07-13 17:52:43'),(584,1,281,1,'primaria',1,'A',5,1,'2026-07-13 11:52:43','2026-07-13 17:52:43'),(585,1,282,1,'primaria',1,'A',6,1,'2026-07-13 11:52:43','2026-07-13 17:52:43'),(586,1,285,1,'primaria',1,'A',7,1,'2026-07-13 11:52:43','2026-07-13 17:52:43'),(587,1,286,1,'primaria',1,'A',8,1,'2026-07-13 11:52:43','2026-07-13 17:52:43'),(588,1,288,1,'primaria',1,'A',9,1,'2026-07-13 11:52:43','2026-07-13 17:52:43'),(589,1,4,1,'primaria',1,'A',10,1,'2026-07-13 11:52:43','2026-07-13 17:52:43'),(590,1,27,1,'primaria',1,'A',11,1,'2026-07-13 11:52:43','2026-07-13 17:52:43'),(591,1,28,1,'primaria',1,'A',12,1,'2026-07-13 11:52:43','2026-07-13 17:52:43'),(592,1,5,2,'primaria',1,'A',13,1,'2026-07-13 11:52:43','2026-07-13 17:52:43'),(593,1,9,2,'primaria',1,'A',14,1,'2026-07-13 11:52:43','2026-07-13 17:52:43'),(594,1,13,3,'primaria',1,'A',15,1,'2026-07-13 11:52:43','2026-07-13 17:52:43'),(595,1,14,4,'primaria',1,'A',16,1,'2026-07-13 11:52:43','2026-07-13 17:52:43'),(596,1,15,4,'primaria',1,'A',17,1,'2026-07-13 11:52:43','2026-07-13 17:52:43'),(597,1,16,4,'primaria',1,'A',18,1,'2026-07-13 11:52:43','2026-07-13 17:52:43'),(598,1,297,NULL,'primaria',1,'A',19,1,'2026-07-13 11:52:43','2026-07-13 17:52:43'),(599,1,298,NULL,'primaria',1,'A',20,1,'2026-07-13 11:52:43','2026-07-13 17:52:43'),(600,1,10,2,'primaria',1,'A',6,1,'2026-07-13 13:03:42','2026-07-13 19:03:42');
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
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ausencias`
--

LOCK TABLES `ausencias` WRITE;
/*!40000 ALTER TABLE `ausencias` DISABLE KEYS */;
INSERT INTO `ausencias` VALUES (1,8,1,1,1,1,'2026-07-12 19:04:32','2026-07-13 12:00:27'),(2,1,1,1,0,1,'2026-07-12 19:04:32','2026-07-13 12:00:27'),(3,9,1,1,0,1,'2026-07-12 19:04:32','2026-07-13 12:00:27'),(4,3,1,1,0,1,'2026-07-12 19:04:32','2026-07-13 12:00:27'),(17,8,1,2,2,1,'2026-07-13 13:16:08','2026-07-13 13:16:08'),(18,1,1,2,0,1,'2026-07-13 13:16:08','2026-07-13 13:16:08'),(19,9,1,2,0,1,'2026-07-13 13:16:08','2026-07-13 13:16:08'),(20,3,1,2,0,1,'2026-07-13 13:16:08','2026-07-13 13:16:08');
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
) ENGINE=InnoDB AUTO_INCREMENT=4357 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `calificaciones`
--

LOCK TABLES `calificaciones` WRITE;
/*!40000 ALTER TABLE `calificaciones` DISABLE KEYS */;
INSERT INTO `calificaciones` VALUES (3229,8,580,2048,1,9.00,1,'2026-07-13 11:58:21','2026-07-13 11:58:21'),(3230,8,580,2080,1,9.00,1,'2026-07-13 11:58:21','2026-07-13 11:58:21'),(3231,8,580,2111,1,9.00,1,'2026-07-13 11:58:21','2026-07-13 11:58:21'),(3232,8,580,2142,1,9.00,1,'2026-07-13 11:58:21','2026-07-13 11:58:21'),(3233,8,580,2173,1,9.00,1,'2026-07-13 11:58:21','2026-07-13 11:58:21'),(3234,8,580,2204,1,9.00,1,'2026-07-13 11:58:21','2026-07-13 11:58:21'),(3235,1,580,2048,1,NULL,1,'2026-07-13 11:58:21','2026-07-13 11:58:21'),(3236,1,580,2080,1,NULL,1,'2026-07-13 11:58:21','2026-07-13 11:58:21'),(3237,1,580,2111,1,NULL,1,'2026-07-13 11:58:21','2026-07-13 11:58:21'),(3238,1,580,2142,1,NULL,1,'2026-07-13 11:58:21','2026-07-13 11:58:21'),(3239,1,580,2173,1,NULL,1,'2026-07-13 11:58:21','2026-07-13 11:58:21'),(3240,1,580,2204,1,NULL,1,'2026-07-13 11:58:21','2026-07-13 11:58:21'),(3241,9,580,2048,1,NULL,1,'2026-07-13 11:58:21','2026-07-13 11:58:21'),(3242,9,580,2080,1,NULL,1,'2026-07-13 11:58:21','2026-07-13 11:58:21'),(3243,9,580,2111,1,NULL,1,'2026-07-13 11:58:21','2026-07-13 11:58:21'),(3244,9,580,2142,1,NULL,1,'2026-07-13 11:58:21','2026-07-13 11:58:21'),(3245,9,580,2173,1,NULL,1,'2026-07-13 11:58:21','2026-07-13 11:58:21'),(3246,9,580,2204,1,NULL,1,'2026-07-13 11:58:21','2026-07-13 11:58:21'),(3247,3,580,2048,1,NULL,1,'2026-07-13 11:58:21','2026-07-13 11:58:21'),(3248,3,580,2080,1,NULL,1,'2026-07-13 11:58:21','2026-07-13 11:58:21'),(3249,3,580,2111,1,NULL,1,'2026-07-13 11:58:21','2026-07-13 11:58:21'),(3250,3,580,2142,1,NULL,1,'2026-07-13 11:58:21','2026-07-13 11:58:21'),(3251,3,580,2173,1,NULL,1,'2026-07-13 11:58:21','2026-07-13 11:58:21'),(3252,3,580,2204,1,NULL,1,'2026-07-13 11:58:21','2026-07-13 11:58:21'),(3253,8,592,2050,1,10.00,1,'2026-07-13 11:58:31','2026-07-13 11:58:31'),(3254,8,592,2082,1,10.00,1,'2026-07-13 11:58:31','2026-07-13 11:58:31'),(3255,8,592,2113,1,10.00,1,'2026-07-13 11:58:31','2026-07-13 11:58:31'),(3256,8,592,2144,1,10.00,1,'2026-07-13 11:58:31','2026-07-13 11:58:31'),(3257,8,592,2175,1,10.00,1,'2026-07-13 11:58:31','2026-07-13 11:58:31'),(3258,8,592,2206,1,10.00,1,'2026-07-13 11:58:31','2026-07-13 11:58:31'),(3259,1,592,2050,1,NULL,1,'2026-07-13 11:58:31','2026-07-13 11:58:31'),(3260,1,592,2082,1,NULL,1,'2026-07-13 11:58:31','2026-07-13 11:58:31'),(3261,1,592,2113,1,NULL,1,'2026-07-13 11:58:31','2026-07-13 11:58:31'),(3262,1,592,2144,1,NULL,1,'2026-07-13 11:58:31','2026-07-13 11:58:31'),(3263,1,592,2175,1,NULL,1,'2026-07-13 11:58:31','2026-07-13 11:58:31'),(3264,1,592,2206,1,NULL,1,'2026-07-13 11:58:31','2026-07-13 11:58:31'),(3265,9,592,2050,1,NULL,1,'2026-07-13 11:58:31','2026-07-13 11:58:31'),(3266,9,592,2082,1,NULL,1,'2026-07-13 11:58:32','2026-07-13 11:58:32'),(3267,9,592,2113,1,NULL,1,'2026-07-13 11:58:32','2026-07-13 11:58:32'),(3268,9,592,2144,1,NULL,1,'2026-07-13 11:58:32','2026-07-13 11:58:32'),(3269,9,592,2175,1,NULL,1,'2026-07-13 11:58:32','2026-07-13 11:58:32'),(3270,9,592,2206,1,NULL,1,'2026-07-13 11:58:32','2026-07-13 11:58:32'),(3271,3,592,2050,1,NULL,1,'2026-07-13 11:58:32','2026-07-13 11:58:32'),(3272,3,592,2082,1,NULL,1,'2026-07-13 11:58:32','2026-07-13 11:58:32'),(3273,3,592,2113,1,NULL,1,'2026-07-13 11:58:32','2026-07-13 11:58:32'),(3274,3,592,2144,1,NULL,1,'2026-07-13 11:58:32','2026-07-13 11:58:32'),(3275,3,592,2175,1,NULL,1,'2026-07-13 11:58:32','2026-07-13 11:58:32'),(3276,3,592,2206,1,NULL,1,'2026-07-13 11:58:32','2026-07-13 11:58:32'),(3301,8,593,2051,1,10.00,1,'2026-07-13 11:58:52','2026-07-13 11:58:52'),(3302,8,593,2083,1,10.00,1,'2026-07-13 11:58:52','2026-07-13 11:58:52'),(3303,8,593,2114,1,10.00,1,'2026-07-13 11:58:52','2026-07-13 11:58:52'),(3304,8,593,2145,1,10.00,1,'2026-07-13 11:58:52','2026-07-13 11:58:52'),(3305,8,593,2176,1,10.00,1,'2026-07-13 11:58:52','2026-07-13 11:58:52'),(3306,8,593,2207,1,10.00,1,'2026-07-13 11:58:52','2026-07-13 11:58:52'),(3307,1,593,2051,1,NULL,1,'2026-07-13 11:58:52','2026-07-13 11:58:52'),(3308,1,593,2083,1,NULL,1,'2026-07-13 11:58:52','2026-07-13 11:58:52'),(3309,1,593,2114,1,NULL,1,'2026-07-13 11:58:52','2026-07-13 11:58:52'),(3310,1,593,2145,1,NULL,1,'2026-07-13 11:58:52','2026-07-13 11:58:52'),(3311,1,593,2176,1,NULL,1,'2026-07-13 11:58:52','2026-07-13 11:58:52'),(3312,1,593,2207,1,NULL,1,'2026-07-13 11:58:52','2026-07-13 11:58:52'),(3313,9,593,2051,1,NULL,1,'2026-07-13 11:58:52','2026-07-13 11:58:52'),(3314,9,593,2083,1,NULL,1,'2026-07-13 11:58:52','2026-07-13 11:58:52'),(3315,9,593,2114,1,NULL,1,'2026-07-13 11:58:52','2026-07-13 11:58:52'),(3316,9,593,2145,1,NULL,1,'2026-07-13 11:58:52','2026-07-13 11:58:52'),(3317,9,593,2176,1,NULL,1,'2026-07-13 11:58:52','2026-07-13 11:58:52'),(3318,9,593,2207,1,NULL,1,'2026-07-13 11:58:53','2026-07-13 11:58:53'),(3319,3,593,2051,1,NULL,1,'2026-07-13 11:58:53','2026-07-13 11:58:53'),(3320,3,593,2083,1,NULL,1,'2026-07-13 11:58:53','2026-07-13 11:58:53'),(3321,3,593,2114,1,NULL,1,'2026-07-13 11:58:53','2026-07-13 11:58:53'),(3322,3,593,2145,1,NULL,1,'2026-07-13 11:58:53','2026-07-13 11:58:53'),(3323,3,593,2176,1,NULL,1,'2026-07-13 11:58:53','2026-07-13 11:58:53'),(3324,3,593,2207,1,NULL,1,'2026-07-13 11:58:53','2026-07-13 11:58:53'),(3325,8,594,2052,1,9.00,1,'2026-07-13 11:59:02','2026-07-13 11:59:02'),(3326,8,594,2084,1,9.00,1,'2026-07-13 11:59:02','2026-07-13 11:59:02'),(3327,8,594,2115,1,9.00,1,'2026-07-13 11:59:02','2026-07-13 11:59:02'),(3328,8,594,2146,1,9.00,1,'2026-07-13 11:59:02','2026-07-13 11:59:02'),(3329,8,594,2177,1,9.00,1,'2026-07-13 11:59:02','2026-07-13 11:59:02'),(3330,8,594,2208,1,9.00,1,'2026-07-13 11:59:02','2026-07-13 11:59:02'),(3331,1,594,2052,1,NULL,1,'2026-07-13 11:59:02','2026-07-13 11:59:02'),(3332,1,594,2084,1,NULL,1,'2026-07-13 11:59:02','2026-07-13 11:59:02'),(3333,1,594,2115,1,NULL,1,'2026-07-13 11:59:02','2026-07-13 11:59:02'),(3334,1,594,2146,1,NULL,1,'2026-07-13 11:59:02','2026-07-13 11:59:02'),(3335,1,594,2177,1,NULL,1,'2026-07-13 11:59:02','2026-07-13 11:59:02'),(3336,1,594,2208,1,NULL,1,'2026-07-13 11:59:02','2026-07-13 11:59:02'),(3337,9,594,2052,1,NULL,1,'2026-07-13 11:59:02','2026-07-13 11:59:02'),(3338,9,594,2084,1,NULL,1,'2026-07-13 11:59:02','2026-07-13 11:59:02'),(3339,9,594,2115,1,NULL,1,'2026-07-13 11:59:02','2026-07-13 11:59:02'),(3340,9,594,2146,1,NULL,1,'2026-07-13 11:59:02','2026-07-13 11:59:02'),(3341,9,594,2177,1,NULL,1,'2026-07-13 11:59:02','2026-07-13 11:59:02'),(3342,9,594,2208,1,NULL,1,'2026-07-13 11:59:02','2026-07-13 11:59:02'),(3343,3,594,2052,1,NULL,1,'2026-07-13 11:59:02','2026-07-13 11:59:02'),(3344,3,594,2084,1,NULL,1,'2026-07-13 11:59:02','2026-07-13 11:59:02'),(3345,3,594,2115,1,NULL,1,'2026-07-13 11:59:02','2026-07-13 11:59:02'),(3346,3,594,2146,1,NULL,1,'2026-07-13 11:59:02','2026-07-13 11:59:02'),(3347,3,594,2177,1,NULL,1,'2026-07-13 11:59:02','2026-07-13 11:59:02'),(3348,3,594,2208,1,NULL,1,'2026-07-13 11:59:02','2026-07-13 11:59:02'),(3349,8,595,2053,1,9.00,1,'2026-07-13 11:59:33','2026-07-13 11:59:33'),(3350,8,595,2085,1,9.00,1,'2026-07-13 11:59:33','2026-07-13 11:59:33'),(3351,8,595,2116,1,9.00,1,'2026-07-13 11:59:33','2026-07-13 11:59:33'),(3352,8,595,2147,1,9.00,1,'2026-07-13 11:59:33','2026-07-13 11:59:33'),(3353,8,595,2178,1,9.00,1,'2026-07-13 11:59:33','2026-07-13 11:59:33'),(3354,8,595,2209,1,9.00,1,'2026-07-13 11:59:33','2026-07-13 11:59:33'),(3355,1,595,2053,1,NULL,1,'2026-07-13 11:59:33','2026-07-13 11:59:33'),(3356,1,595,2085,1,NULL,1,'2026-07-13 11:59:33','2026-07-13 11:59:33'),(3357,1,595,2116,1,NULL,1,'2026-07-13 11:59:33','2026-07-13 11:59:33'),(3358,1,595,2147,1,NULL,1,'2026-07-13 11:59:33','2026-07-13 11:59:33'),(3359,1,595,2178,1,NULL,1,'2026-07-13 11:59:33','2026-07-13 11:59:33'),(3360,1,595,2209,1,NULL,1,'2026-07-13 11:59:33','2026-07-13 11:59:33'),(3361,9,595,2053,1,NULL,1,'2026-07-13 11:59:33','2026-07-13 11:59:33'),(3362,9,595,2085,1,NULL,1,'2026-07-13 11:59:33','2026-07-13 11:59:33'),(3363,9,595,2116,1,NULL,1,'2026-07-13 11:59:33','2026-07-13 11:59:33'),(3364,9,595,2147,1,NULL,1,'2026-07-13 11:59:33','2026-07-13 11:59:33'),(3365,9,595,2178,1,NULL,1,'2026-07-13 11:59:33','2026-07-13 11:59:33'),(3366,9,595,2209,1,NULL,1,'2026-07-13 11:59:33','2026-07-13 11:59:33'),(3367,3,595,2053,1,NULL,1,'2026-07-13 11:59:33','2026-07-13 11:59:33'),(3368,3,595,2085,1,NULL,1,'2026-07-13 11:59:33','2026-07-13 11:59:33'),(3369,3,595,2116,1,NULL,1,'2026-07-13 11:59:33','2026-07-13 11:59:33'),(3370,3,595,2147,1,NULL,1,'2026-07-13 11:59:33','2026-07-13 11:59:33'),(3371,3,595,2178,1,NULL,1,'2026-07-13 11:59:33','2026-07-13 11:59:33'),(3372,3,595,2209,1,NULL,1,'2026-07-13 11:59:33','2026-07-13 11:59:33'),(3373,8,596,2054,1,8.00,1,'2026-07-13 11:59:48','2026-07-13 11:59:48'),(3374,8,596,2086,1,8.00,1,'2026-07-13 11:59:48','2026-07-13 11:59:48'),(3375,8,596,2117,1,8.00,1,'2026-07-13 11:59:48','2026-07-13 11:59:48'),(3376,8,596,2148,1,8.00,1,'2026-07-13 11:59:48','2026-07-13 11:59:48'),(3377,8,596,2179,1,8.00,1,'2026-07-13 11:59:48','2026-07-13 11:59:48'),(3378,8,596,2210,1,8.00,1,'2026-07-13 11:59:48','2026-07-13 11:59:48'),(3379,1,596,2054,1,NULL,1,'2026-07-13 11:59:48','2026-07-13 11:59:48'),(3380,1,596,2086,1,NULL,1,'2026-07-13 11:59:48','2026-07-13 11:59:48'),(3381,1,596,2117,1,NULL,1,'2026-07-13 11:59:48','2026-07-13 11:59:48'),(3382,1,596,2148,1,NULL,1,'2026-07-13 11:59:48','2026-07-13 11:59:48'),(3383,1,596,2179,1,NULL,1,'2026-07-13 11:59:48','2026-07-13 11:59:48'),(3384,1,596,2210,1,NULL,1,'2026-07-13 11:59:48','2026-07-13 11:59:48'),(3385,9,596,2054,1,NULL,1,'2026-07-13 11:59:48','2026-07-13 11:59:48'),(3386,9,596,2086,1,NULL,1,'2026-07-13 11:59:48','2026-07-13 11:59:48'),(3387,9,596,2117,1,NULL,1,'2026-07-13 11:59:48','2026-07-13 11:59:48'),(3388,9,596,2148,1,NULL,1,'2026-07-13 11:59:48','2026-07-13 11:59:48'),(3389,9,596,2179,1,NULL,1,'2026-07-13 11:59:48','2026-07-13 11:59:48'),(3390,9,596,2210,1,NULL,1,'2026-07-13 11:59:48','2026-07-13 11:59:48'),(3391,3,596,2054,1,NULL,1,'2026-07-13 11:59:48','2026-07-13 11:59:48'),(3392,3,596,2086,1,NULL,1,'2026-07-13 11:59:48','2026-07-13 11:59:48'),(3393,3,596,2117,1,NULL,1,'2026-07-13 11:59:48','2026-07-13 11:59:48'),(3394,3,596,2148,1,NULL,1,'2026-07-13 11:59:48','2026-07-13 11:59:48'),(3395,3,596,2179,1,NULL,1,'2026-07-13 11:59:48','2026-07-13 11:59:48'),(3396,3,596,2210,1,NULL,1,'2026-07-13 11:59:48','2026-07-13 11:59:48'),(3397,8,597,2055,1,9.00,1,'2026-07-13 11:59:54','2026-07-13 11:59:54'),(3398,8,597,2087,1,9.00,1,'2026-07-13 11:59:54','2026-07-13 11:59:54'),(3399,8,597,2118,1,9.00,1,'2026-07-13 11:59:54','2026-07-13 11:59:54'),(3400,8,597,2149,1,9.00,1,'2026-07-13 11:59:54','2026-07-13 11:59:54'),(3401,8,597,2180,1,9.00,1,'2026-07-13 11:59:54','2026-07-13 11:59:54'),(3402,8,597,2211,1,9.00,1,'2026-07-13 11:59:54','2026-07-13 11:59:54'),(3403,1,597,2055,1,NULL,1,'2026-07-13 11:59:54','2026-07-13 11:59:54'),(3404,1,597,2087,1,NULL,1,'2026-07-13 11:59:54','2026-07-13 11:59:54'),(3405,1,597,2118,1,NULL,1,'2026-07-13 11:59:54','2026-07-13 11:59:54'),(3406,1,597,2149,1,NULL,1,'2026-07-13 11:59:54','2026-07-13 11:59:54'),(3407,1,597,2180,1,NULL,1,'2026-07-13 11:59:54','2026-07-13 11:59:54'),(3408,1,597,2211,1,NULL,1,'2026-07-13 11:59:54','2026-07-13 11:59:54'),(3409,9,597,2055,1,NULL,1,'2026-07-13 11:59:54','2026-07-13 11:59:54'),(3410,9,597,2087,1,NULL,1,'2026-07-13 11:59:54','2026-07-13 11:59:54'),(3411,9,597,2118,1,NULL,1,'2026-07-13 11:59:54','2026-07-13 11:59:54'),(3412,9,597,2149,1,NULL,1,'2026-07-13 11:59:54','2026-07-13 11:59:54'),(3413,9,597,2180,1,NULL,1,'2026-07-13 11:59:54','2026-07-13 11:59:54'),(3414,9,597,2211,1,NULL,1,'2026-07-13 11:59:54','2026-07-13 11:59:54'),(3415,3,597,2055,1,NULL,1,'2026-07-13 11:59:54','2026-07-13 11:59:54'),(3416,3,597,2087,1,NULL,1,'2026-07-13 11:59:54','2026-07-13 11:59:54'),(3417,3,597,2118,1,NULL,1,'2026-07-13 11:59:54','2026-07-13 11:59:54'),(3418,3,597,2149,1,NULL,1,'2026-07-13 11:59:54','2026-07-13 11:59:54'),(3419,3,597,2180,1,NULL,1,'2026-07-13 11:59:54','2026-07-13 11:59:54'),(3420,3,597,2211,1,NULL,1,'2026-07-13 11:59:54','2026-07-13 11:59:54'),(3421,8,589,2049,1,9.00,1,'2026-07-13 12:00:00','2026-07-13 12:00:00'),(3422,8,589,2081,1,9.00,1,'2026-07-13 12:00:00','2026-07-13 12:00:00'),(3423,8,589,2112,1,9.00,1,'2026-07-13 12:00:00','2026-07-13 12:00:00'),(3424,8,589,2143,1,9.00,1,'2026-07-13 12:00:00','2026-07-13 12:00:00'),(3425,8,589,2174,1,9.00,1,'2026-07-13 12:00:00','2026-07-13 12:00:00'),(3426,8,589,2205,1,9.00,1,'2026-07-13 12:00:00','2026-07-13 12:00:00'),(3427,1,589,2049,1,NULL,1,'2026-07-13 12:00:00','2026-07-13 12:00:00'),(3428,1,589,2081,1,NULL,1,'2026-07-13 12:00:00','2026-07-13 12:00:00'),(3429,1,589,2112,1,NULL,1,'2026-07-13 12:00:00','2026-07-13 12:00:00'),(3430,1,589,2143,1,NULL,1,'2026-07-13 12:00:00','2026-07-13 12:00:00'),(3431,1,589,2174,1,NULL,1,'2026-07-13 12:00:00','2026-07-13 12:00:00'),(3432,1,589,2205,1,NULL,1,'2026-07-13 12:00:00','2026-07-13 12:00:00'),(3433,9,589,2049,1,NULL,1,'2026-07-13 12:00:00','2026-07-13 12:00:00'),(3434,9,589,2081,1,NULL,1,'2026-07-13 12:00:00','2026-07-13 12:00:00'),(3435,9,589,2112,1,NULL,1,'2026-07-13 12:00:00','2026-07-13 12:00:00'),(3436,9,589,2143,1,NULL,1,'2026-07-13 12:00:00','2026-07-13 12:00:00'),(3437,9,589,2174,1,NULL,1,'2026-07-13 12:00:00','2026-07-13 12:00:00'),(3438,9,589,2205,1,NULL,1,'2026-07-13 12:00:00','2026-07-13 12:00:00'),(3439,3,589,2049,1,NULL,1,'2026-07-13 12:00:00','2026-07-13 12:00:00'),(3440,3,589,2081,1,NULL,1,'2026-07-13 12:00:00','2026-07-13 12:00:00'),(3441,3,589,2112,1,NULL,1,'2026-07-13 12:00:00','2026-07-13 12:00:00'),(3442,3,589,2143,1,NULL,1,'2026-07-13 12:00:00','2026-07-13 12:00:00'),(3443,3,589,2174,1,NULL,1,'2026-07-13 12:00:00','2026-07-13 12:00:00'),(3444,3,589,2205,1,NULL,1,'2026-07-13 12:00:00','2026-07-13 12:00:00'),(3445,8,590,2056,1,7.00,1,'2026-07-13 12:00:08','2026-07-13 12:00:08'),(3446,8,590,2088,1,7.00,1,'2026-07-13 12:00:08','2026-07-13 12:00:08'),(3447,8,590,2119,1,7.00,1,'2026-07-13 12:00:08','2026-07-13 12:00:08'),(3448,8,590,2150,1,7.00,1,'2026-07-13 12:00:08','2026-07-13 12:00:08'),(3449,8,590,2181,1,7.00,1,'2026-07-13 12:00:08','2026-07-13 12:00:08'),(3450,8,590,2212,1,7.00,1,'2026-07-13 12:00:08','2026-07-13 12:00:08'),(3451,1,590,2056,1,NULL,1,'2026-07-13 12:00:08','2026-07-13 12:00:08'),(3452,1,590,2088,1,NULL,1,'2026-07-13 12:00:08','2026-07-13 12:00:08'),(3453,1,590,2119,1,NULL,1,'2026-07-13 12:00:08','2026-07-13 12:00:08'),(3454,1,590,2150,1,NULL,1,'2026-07-13 12:00:08','2026-07-13 12:00:08'),(3455,1,590,2181,1,NULL,1,'2026-07-13 12:00:08','2026-07-13 12:00:08'),(3456,1,590,2212,1,NULL,1,'2026-07-13 12:00:08','2026-07-13 12:00:08'),(3457,9,590,2056,1,NULL,1,'2026-07-13 12:00:08','2026-07-13 12:00:08'),(3458,9,590,2088,1,NULL,1,'2026-07-13 12:00:08','2026-07-13 12:00:08'),(3459,9,590,2119,1,NULL,1,'2026-07-13 12:00:08','2026-07-13 12:00:08'),(3460,9,590,2150,1,NULL,1,'2026-07-13 12:00:08','2026-07-13 12:00:08'),(3461,9,590,2181,1,NULL,1,'2026-07-13 12:00:08','2026-07-13 12:00:08'),(3462,9,590,2212,1,NULL,1,'2026-07-13 12:00:08','2026-07-13 12:00:08'),(3463,3,590,2056,1,NULL,1,'2026-07-13 12:00:08','2026-07-13 12:00:08'),(3464,3,590,2088,1,NULL,1,'2026-07-13 12:00:08','2026-07-13 12:00:08'),(3465,3,590,2119,1,NULL,1,'2026-07-13 12:00:08','2026-07-13 12:00:08'),(3466,3,590,2150,1,NULL,1,'2026-07-13 12:00:08','2026-07-13 12:00:08'),(3467,3,590,2181,1,NULL,1,'2026-07-13 12:00:08','2026-07-13 12:00:08'),(3468,3,590,2212,1,NULL,1,'2026-07-13 12:00:08','2026-07-13 12:00:08'),(3469,8,591,2057,1,9.00,1,'2026-07-13 12:00:15','2026-07-13 12:00:15'),(3470,8,591,2089,1,9.00,1,'2026-07-13 12:00:15','2026-07-13 12:00:15'),(3471,8,591,2120,1,9.00,1,'2026-07-13 12:00:15','2026-07-13 12:00:15'),(3472,8,591,2151,1,9.00,1,'2026-07-13 12:00:15','2026-07-13 12:00:15'),(3473,8,591,2182,1,9.00,1,'2026-07-13 12:00:15','2026-07-13 12:00:15'),(3474,8,591,2213,1,9.00,1,'2026-07-13 12:00:15','2026-07-13 12:00:15'),(3475,1,591,2057,1,NULL,1,'2026-07-13 12:00:15','2026-07-13 12:00:15'),(3476,1,591,2089,1,NULL,1,'2026-07-13 12:00:15','2026-07-13 12:00:15'),(3477,1,591,2120,1,NULL,1,'2026-07-13 12:00:15','2026-07-13 12:00:15'),(3478,1,591,2151,1,NULL,1,'2026-07-13 12:00:15','2026-07-13 12:00:15'),(3479,1,591,2182,1,NULL,1,'2026-07-13 12:00:15','2026-07-13 12:00:15'),(3480,1,591,2213,1,NULL,1,'2026-07-13 12:00:15','2026-07-13 12:00:15'),(3481,9,591,2057,1,NULL,1,'2026-07-13 12:00:15','2026-07-13 12:00:15'),(3482,9,591,2089,1,NULL,1,'2026-07-13 12:00:15','2026-07-13 12:00:15'),(3483,9,591,2120,1,NULL,1,'2026-07-13 12:00:15','2026-07-13 12:00:15'),(3484,9,591,2151,1,NULL,1,'2026-07-13 12:00:15','2026-07-13 12:00:15'),(3485,9,591,2182,1,NULL,1,'2026-07-13 12:00:15','2026-07-13 12:00:15'),(3486,9,591,2213,1,NULL,1,'2026-07-13 12:00:15','2026-07-13 12:00:15'),(3487,3,591,2057,1,NULL,1,'2026-07-13 12:00:15','2026-07-13 12:00:15'),(3488,3,591,2089,1,NULL,1,'2026-07-13 12:00:15','2026-07-13 12:00:15'),(3489,3,591,2120,1,NULL,1,'2026-07-13 12:00:15','2026-07-13 12:00:15'),(3490,3,591,2151,1,NULL,1,'2026-07-13 12:00:15','2026-07-13 12:00:15'),(3491,3,591,2182,1,NULL,1,'2026-07-13 12:00:15','2026-07-13 12:00:15'),(3492,3,591,2213,1,NULL,1,'2026-07-13 12:00:16','2026-07-13 12:00:16'),(3493,8,581,2058,1,9.00,1,'2026-07-13 12:00:36','2026-07-13 12:00:36'),(3494,8,581,2090,1,9.00,1,'2026-07-13 12:00:36','2026-07-13 12:00:36'),(3495,8,581,2121,1,9.00,1,'2026-07-13 12:00:36','2026-07-13 12:00:36'),(3496,8,581,2152,1,9.00,1,'2026-07-13 12:00:36','2026-07-13 12:00:36'),(3497,8,581,2183,1,9.00,1,'2026-07-13 12:00:36','2026-07-13 12:00:36'),(3498,8,581,2214,1,9.00,1,'2026-07-13 12:00:36','2026-07-13 12:00:36'),(3499,1,581,2058,1,NULL,1,'2026-07-13 12:00:36','2026-07-13 12:00:36'),(3500,1,581,2090,1,NULL,1,'2026-07-13 12:00:36','2026-07-13 12:00:36'),(3501,1,581,2121,1,NULL,1,'2026-07-13 12:00:36','2026-07-13 12:00:36'),(3502,1,581,2152,1,NULL,1,'2026-07-13 12:00:36','2026-07-13 12:00:36'),(3503,1,581,2183,1,NULL,1,'2026-07-13 12:00:36','2026-07-13 12:00:36'),(3504,1,581,2214,1,NULL,1,'2026-07-13 12:00:36','2026-07-13 12:00:36'),(3505,9,581,2058,1,NULL,1,'2026-07-13 12:00:36','2026-07-13 12:00:36'),(3506,9,581,2090,1,NULL,1,'2026-07-13 12:00:36','2026-07-13 12:00:36'),(3507,9,581,2121,1,NULL,1,'2026-07-13 12:00:36','2026-07-13 12:00:36'),(3508,9,581,2152,1,NULL,1,'2026-07-13 12:00:36','2026-07-13 12:00:36'),(3509,9,581,2183,1,NULL,1,'2026-07-13 12:00:36','2026-07-13 12:00:36'),(3510,9,581,2214,1,NULL,1,'2026-07-13 12:00:36','2026-07-13 12:00:36'),(3511,3,581,2058,1,NULL,1,'2026-07-13 12:00:36','2026-07-13 12:00:36'),(3512,3,581,2090,1,NULL,1,'2026-07-13 12:00:36','2026-07-13 12:00:36'),(3513,3,581,2121,1,NULL,1,'2026-07-13 12:00:36','2026-07-13 12:00:36'),(3514,3,581,2152,1,NULL,1,'2026-07-13 12:00:36','2026-07-13 12:00:36'),(3515,3,581,2183,1,NULL,1,'2026-07-13 12:00:36','2026-07-13 12:00:36'),(3516,3,581,2214,1,NULL,1,'2026-07-13 12:00:36','2026-07-13 12:00:36'),(3517,8,582,2059,1,10.00,1,'2026-07-13 12:00:45','2026-07-13 12:00:45'),(3518,8,582,2091,1,10.00,1,'2026-07-13 12:00:45','2026-07-13 12:00:45'),(3519,8,582,2122,1,10.00,1,'2026-07-13 12:00:45','2026-07-13 12:00:45'),(3520,8,582,2153,1,10.00,1,'2026-07-13 12:00:45','2026-07-13 12:00:45'),(3521,8,582,2184,1,10.00,1,'2026-07-13 12:00:45','2026-07-13 12:00:45'),(3522,8,582,2215,1,10.00,1,'2026-07-13 12:00:45','2026-07-13 12:00:45'),(3523,1,582,2059,1,NULL,1,'2026-07-13 12:00:45','2026-07-13 12:00:45'),(3524,1,582,2091,1,NULL,1,'2026-07-13 12:00:45','2026-07-13 12:00:45'),(3525,1,582,2122,1,NULL,1,'2026-07-13 12:00:45','2026-07-13 12:00:45'),(3526,1,582,2153,1,NULL,1,'2026-07-13 12:00:45','2026-07-13 12:00:45'),(3527,1,582,2184,1,NULL,1,'2026-07-13 12:00:45','2026-07-13 12:00:45'),(3528,1,582,2215,1,NULL,1,'2026-07-13 12:00:45','2026-07-13 12:00:45'),(3529,9,582,2059,1,NULL,1,'2026-07-13 12:00:45','2026-07-13 12:00:45'),(3530,9,582,2091,1,NULL,1,'2026-07-13 12:00:45','2026-07-13 12:00:45'),(3531,9,582,2122,1,NULL,1,'2026-07-13 12:00:45','2026-07-13 12:00:45'),(3532,9,582,2153,1,NULL,1,'2026-07-13 12:00:45','2026-07-13 12:00:45'),(3533,9,582,2184,1,NULL,1,'2026-07-13 12:00:45','2026-07-13 12:00:45'),(3534,9,582,2215,1,NULL,1,'2026-07-13 12:00:45','2026-07-13 12:00:45'),(3535,3,582,2059,1,NULL,1,'2026-07-13 12:00:45','2026-07-13 12:00:45'),(3536,3,582,2091,1,NULL,1,'2026-07-13 12:00:45','2026-07-13 12:00:45'),(3537,3,582,2122,1,NULL,1,'2026-07-13 12:00:45','2026-07-13 12:00:45'),(3538,3,582,2153,1,NULL,1,'2026-07-13 12:00:45','2026-07-13 12:00:45'),(3539,3,582,2184,1,NULL,1,'2026-07-13 12:00:45','2026-07-13 12:00:45'),(3540,3,582,2215,1,NULL,1,'2026-07-13 12:00:45','2026-07-13 12:00:45'),(3541,8,583,2060,1,9.00,1,'2026-07-13 12:00:51','2026-07-13 12:00:51'),(3542,8,583,2092,1,9.00,1,'2026-07-13 12:00:51','2026-07-13 12:00:51'),(3543,8,583,2123,1,9.00,1,'2026-07-13 12:00:51','2026-07-13 12:00:51'),(3544,8,583,2154,1,9.00,1,'2026-07-13 12:00:51','2026-07-13 12:00:51'),(3545,8,583,2185,1,9.00,1,'2026-07-13 12:00:51','2026-07-13 12:00:51'),(3546,8,583,2216,1,9.00,1,'2026-07-13 12:00:51','2026-07-13 12:00:51'),(3547,1,583,2060,1,NULL,1,'2026-07-13 12:00:51','2026-07-13 12:00:51'),(3548,1,583,2092,1,NULL,1,'2026-07-13 12:00:51','2026-07-13 12:00:51'),(3549,1,583,2123,1,NULL,1,'2026-07-13 12:00:51','2026-07-13 12:00:51'),(3550,1,583,2154,1,NULL,1,'2026-07-13 12:00:51','2026-07-13 12:00:51'),(3551,1,583,2185,1,NULL,1,'2026-07-13 12:00:51','2026-07-13 12:00:51'),(3552,1,583,2216,1,NULL,1,'2026-07-13 12:00:51','2026-07-13 12:00:51'),(3553,9,583,2060,1,NULL,1,'2026-07-13 12:00:51','2026-07-13 12:00:51'),(3554,9,583,2092,1,NULL,1,'2026-07-13 12:00:51','2026-07-13 12:00:51'),(3555,9,583,2123,1,NULL,1,'2026-07-13 12:00:51','2026-07-13 12:00:51'),(3556,9,583,2154,1,NULL,1,'2026-07-13 12:00:51','2026-07-13 12:00:51'),(3557,9,583,2185,1,NULL,1,'2026-07-13 12:00:51','2026-07-13 12:00:51'),(3558,9,583,2216,1,NULL,1,'2026-07-13 12:00:51','2026-07-13 12:00:51'),(3559,3,583,2060,1,NULL,1,'2026-07-13 12:00:51','2026-07-13 12:00:51'),(3560,3,583,2092,1,NULL,1,'2026-07-13 12:00:51','2026-07-13 12:00:51'),(3561,3,583,2123,1,NULL,1,'2026-07-13 12:00:51','2026-07-13 12:00:51'),(3562,3,583,2154,1,NULL,1,'2026-07-13 12:00:51','2026-07-13 12:00:51'),(3563,3,583,2185,1,NULL,1,'2026-07-13 12:00:51','2026-07-13 12:00:51'),(3564,3,583,2216,1,NULL,1,'2026-07-13 12:00:51','2026-07-13 12:00:51'),(3565,8,584,2061,1,8.00,1,'2026-07-13 12:00:57','2026-07-13 12:00:57'),(3566,8,584,2093,1,8.00,1,'2026-07-13 12:00:57','2026-07-13 12:00:57'),(3567,8,584,2124,1,8.00,1,'2026-07-13 12:00:57','2026-07-13 12:00:57'),(3568,8,584,2155,1,8.00,1,'2026-07-13 12:00:57','2026-07-13 12:00:57'),(3569,8,584,2186,1,8.00,1,'2026-07-13 12:00:57','2026-07-13 12:00:57'),(3570,8,584,2217,1,8.00,1,'2026-07-13 12:00:57','2026-07-13 12:00:57'),(3571,1,584,2061,1,NULL,1,'2026-07-13 12:00:57','2026-07-13 12:00:57'),(3572,1,584,2093,1,NULL,1,'2026-07-13 12:00:57','2026-07-13 12:00:57'),(3573,1,584,2124,1,NULL,1,'2026-07-13 12:00:57','2026-07-13 12:00:57'),(3574,1,584,2155,1,NULL,1,'2026-07-13 12:00:58','2026-07-13 12:00:58'),(3575,1,584,2186,1,NULL,1,'2026-07-13 12:00:58','2026-07-13 12:00:58'),(3576,1,584,2217,1,NULL,1,'2026-07-13 12:00:58','2026-07-13 12:00:58'),(3577,9,584,2061,1,NULL,1,'2026-07-13 12:00:58','2026-07-13 12:00:58'),(3578,9,584,2093,1,NULL,1,'2026-07-13 12:00:58','2026-07-13 12:00:58'),(3579,9,584,2124,1,NULL,1,'2026-07-13 12:00:58','2026-07-13 12:00:58'),(3580,9,584,2155,1,NULL,1,'2026-07-13 12:00:58','2026-07-13 12:00:58'),(3581,9,584,2186,1,NULL,1,'2026-07-13 12:00:58','2026-07-13 12:00:58'),(3582,9,584,2217,1,NULL,1,'2026-07-13 12:00:58','2026-07-13 12:00:58'),(3583,3,584,2061,1,NULL,1,'2026-07-13 12:00:58','2026-07-13 12:00:58'),(3584,3,584,2093,1,NULL,1,'2026-07-13 12:00:58','2026-07-13 12:00:58'),(3585,3,584,2124,1,NULL,1,'2026-07-13 12:00:58','2026-07-13 12:00:58'),(3586,3,584,2155,1,NULL,1,'2026-07-13 12:00:58','2026-07-13 12:00:58'),(3587,3,584,2186,1,NULL,1,'2026-07-13 12:00:58','2026-07-13 12:00:58'),(3588,3,584,2217,1,NULL,1,'2026-07-13 12:00:58','2026-07-13 12:00:58'),(3589,8,585,2062,1,7.00,1,'2026-07-13 12:01:04','2026-07-13 12:01:04'),(3590,8,585,2094,1,7.00,1,'2026-07-13 12:01:04','2026-07-13 12:01:04'),(3591,8,585,2125,1,7.00,1,'2026-07-13 12:01:04','2026-07-13 12:01:04'),(3592,8,585,2156,1,7.00,1,'2026-07-13 12:01:04','2026-07-13 12:01:04'),(3593,8,585,2187,1,7.00,1,'2026-07-13 12:01:04','2026-07-13 12:01:04'),(3594,8,585,2218,1,7.00,1,'2026-07-13 12:01:04','2026-07-13 12:01:04'),(3595,1,585,2062,1,NULL,1,'2026-07-13 12:01:04','2026-07-13 12:01:04'),(3596,1,585,2094,1,NULL,1,'2026-07-13 12:01:04','2026-07-13 12:01:04'),(3597,1,585,2125,1,NULL,1,'2026-07-13 12:01:04','2026-07-13 12:01:04'),(3598,1,585,2156,1,NULL,1,'2026-07-13 12:01:04','2026-07-13 12:01:04'),(3599,1,585,2187,1,NULL,1,'2026-07-13 12:01:04','2026-07-13 12:01:04'),(3600,1,585,2218,1,NULL,1,'2026-07-13 12:01:04','2026-07-13 12:01:04'),(3601,9,585,2062,1,NULL,1,'2026-07-13 12:01:04','2026-07-13 12:01:04'),(3602,9,585,2094,1,NULL,1,'2026-07-13 12:01:04','2026-07-13 12:01:04'),(3603,9,585,2125,1,NULL,1,'2026-07-13 12:01:04','2026-07-13 12:01:04'),(3604,9,585,2156,1,NULL,1,'2026-07-13 12:01:04','2026-07-13 12:01:04'),(3605,9,585,2187,1,NULL,1,'2026-07-13 12:01:04','2026-07-13 12:01:04'),(3606,9,585,2218,1,NULL,1,'2026-07-13 12:01:04','2026-07-13 12:01:04'),(3607,3,585,2062,1,NULL,1,'2026-07-13 12:01:04','2026-07-13 12:01:04'),(3608,3,585,2094,1,NULL,1,'2026-07-13 12:01:04','2026-07-13 12:01:04'),(3609,3,585,2125,1,NULL,1,'2026-07-13 12:01:04','2026-07-13 12:01:04'),(3610,3,585,2156,1,NULL,1,'2026-07-13 12:01:04','2026-07-13 12:01:04'),(3611,3,585,2187,1,NULL,1,'2026-07-13 12:01:04','2026-07-13 12:01:04'),(3612,3,585,2218,1,NULL,1,'2026-07-13 12:01:04','2026-07-13 12:01:04'),(3613,8,586,2063,1,7.00,1,'2026-07-13 12:01:10','2026-07-13 12:01:10'),(3614,8,586,2095,1,7.00,1,'2026-07-13 12:01:10','2026-07-13 12:01:10'),(3615,8,586,2126,1,7.00,1,'2026-07-13 12:01:10','2026-07-13 12:01:10'),(3616,8,586,2157,1,7.00,1,'2026-07-13 12:01:10','2026-07-13 12:01:10'),(3617,8,586,2188,1,7.00,1,'2026-07-13 12:01:10','2026-07-13 12:01:10'),(3618,8,586,2219,1,7.00,1,'2026-07-13 12:01:10','2026-07-13 12:01:10'),(3619,1,586,2063,1,NULL,1,'2026-07-13 12:01:10','2026-07-13 12:01:10'),(3620,1,586,2095,1,NULL,1,'2026-07-13 12:01:10','2026-07-13 12:01:10'),(3621,1,586,2126,1,NULL,1,'2026-07-13 12:01:10','2026-07-13 12:01:10'),(3622,1,586,2157,1,NULL,1,'2026-07-13 12:01:10','2026-07-13 12:01:10'),(3623,1,586,2188,1,NULL,1,'2026-07-13 12:01:10','2026-07-13 12:01:10'),(3624,1,586,2219,1,NULL,1,'2026-07-13 12:01:10','2026-07-13 12:01:10'),(3625,9,586,2063,1,NULL,1,'2026-07-13 12:01:10','2026-07-13 12:01:10'),(3626,9,586,2095,1,NULL,1,'2026-07-13 12:01:10','2026-07-13 12:01:10'),(3627,9,586,2126,1,NULL,1,'2026-07-13 12:01:10','2026-07-13 12:01:10'),(3628,9,586,2157,1,NULL,1,'2026-07-13 12:01:10','2026-07-13 12:01:10'),(3629,9,586,2188,1,NULL,1,'2026-07-13 12:01:10','2026-07-13 12:01:10'),(3630,9,586,2219,1,NULL,1,'2026-07-13 12:01:10','2026-07-13 12:01:10'),(3631,3,586,2063,1,NULL,1,'2026-07-13 12:01:10','2026-07-13 12:01:10'),(3632,3,586,2095,1,NULL,1,'2026-07-13 12:01:10','2026-07-13 12:01:10'),(3633,3,586,2126,1,NULL,1,'2026-07-13 12:01:10','2026-07-13 12:01:10'),(3634,3,586,2157,1,NULL,1,'2026-07-13 12:01:10','2026-07-13 12:01:10'),(3635,3,586,2188,1,NULL,1,'2026-07-13 12:01:10','2026-07-13 12:01:10'),(3636,3,586,2219,1,NULL,1,'2026-07-13 12:01:10','2026-07-13 12:01:10'),(3637,8,587,2064,1,7.00,1,'2026-07-13 12:01:16','2026-07-13 12:01:16'),(3638,8,587,2096,1,7.00,1,'2026-07-13 12:01:16','2026-07-13 12:01:16'),(3639,8,587,2127,1,7.00,1,'2026-07-13 12:01:16','2026-07-13 12:01:16'),(3640,8,587,2158,1,7.00,1,'2026-07-13 12:01:16','2026-07-13 12:01:16'),(3641,8,587,2189,1,7.00,1,'2026-07-13 12:01:16','2026-07-13 12:01:16'),(3642,8,587,2220,1,7.00,1,'2026-07-13 12:01:16','2026-07-13 12:01:16'),(3643,1,587,2064,1,NULL,1,'2026-07-13 12:01:16','2026-07-13 12:01:16'),(3644,1,587,2096,1,NULL,1,'2026-07-13 12:01:16','2026-07-13 12:01:16'),(3645,1,587,2127,1,NULL,1,'2026-07-13 12:01:16','2026-07-13 12:01:16'),(3646,1,587,2158,1,NULL,1,'2026-07-13 12:01:16','2026-07-13 12:01:16'),(3647,1,587,2189,1,NULL,1,'2026-07-13 12:01:16','2026-07-13 12:01:16'),(3648,1,587,2220,1,NULL,1,'2026-07-13 12:01:16','2026-07-13 12:01:16'),(3649,9,587,2064,1,NULL,1,'2026-07-13 12:01:16','2026-07-13 12:01:16'),(3650,9,587,2096,1,NULL,1,'2026-07-13 12:01:16','2026-07-13 12:01:16'),(3651,9,587,2127,1,NULL,1,'2026-07-13 12:01:16','2026-07-13 12:01:16'),(3652,9,587,2158,1,NULL,1,'2026-07-13 12:01:16','2026-07-13 12:01:16'),(3653,9,587,2189,1,NULL,1,'2026-07-13 12:01:16','2026-07-13 12:01:16'),(3654,9,587,2220,1,NULL,1,'2026-07-13 12:01:16','2026-07-13 12:01:16'),(3655,3,587,2064,1,NULL,1,'2026-07-13 12:01:16','2026-07-13 12:01:16'),(3656,3,587,2096,1,NULL,1,'2026-07-13 12:01:16','2026-07-13 12:01:16'),(3657,3,587,2127,1,NULL,1,'2026-07-13 12:01:16','2026-07-13 12:01:16'),(3658,3,587,2158,1,NULL,1,'2026-07-13 12:01:16','2026-07-13 12:01:16'),(3659,3,587,2189,1,NULL,1,'2026-07-13 12:01:16','2026-07-13 12:01:16'),(3660,3,587,2220,1,NULL,1,'2026-07-13 12:01:16','2026-07-13 12:01:16'),(3661,8,588,2065,1,9.00,1,'2026-07-13 12:01:22','2026-07-13 12:01:22'),(3662,8,588,2097,1,9.00,1,'2026-07-13 12:01:22','2026-07-13 12:01:22'),(3663,8,588,2128,1,9.00,1,'2026-07-13 12:01:22','2026-07-13 12:01:22'),(3664,8,588,2159,1,9.00,1,'2026-07-13 12:01:22','2026-07-13 12:01:22'),(3665,8,588,2190,1,9.00,1,'2026-07-13 12:01:22','2026-07-13 12:01:22'),(3666,8,588,2221,1,9.00,1,'2026-07-13 12:01:23','2026-07-13 12:01:23'),(3667,1,588,2065,1,NULL,1,'2026-07-13 12:01:23','2026-07-13 12:01:23'),(3668,1,588,2097,1,NULL,1,'2026-07-13 12:01:23','2026-07-13 12:01:23'),(3669,1,588,2128,1,NULL,1,'2026-07-13 12:01:23','2026-07-13 12:01:23'),(3670,1,588,2159,1,NULL,1,'2026-07-13 12:01:23','2026-07-13 12:01:23'),(3671,1,588,2190,1,NULL,1,'2026-07-13 12:01:23','2026-07-13 12:01:23'),(3672,1,588,2221,1,NULL,1,'2026-07-13 12:01:23','2026-07-13 12:01:23'),(3673,9,588,2065,1,NULL,1,'2026-07-13 12:01:23','2026-07-13 12:01:23'),(3674,9,588,2097,1,NULL,1,'2026-07-13 12:01:23','2026-07-13 12:01:23'),(3675,9,588,2128,1,NULL,1,'2026-07-13 12:01:23','2026-07-13 12:01:23'),(3676,9,588,2159,1,NULL,1,'2026-07-13 12:01:23','2026-07-13 12:01:23'),(3677,9,588,2190,1,NULL,1,'2026-07-13 12:01:23','2026-07-13 12:01:23'),(3678,9,588,2221,1,NULL,1,'2026-07-13 12:01:23','2026-07-13 12:01:23'),(3679,3,588,2065,1,NULL,1,'2026-07-13 12:01:23','2026-07-13 12:01:23'),(3680,3,588,2097,1,NULL,1,'2026-07-13 12:01:23','2026-07-13 12:01:23'),(3681,3,588,2128,1,NULL,1,'2026-07-13 12:01:23','2026-07-13 12:01:23'),(3682,3,588,2159,1,NULL,1,'2026-07-13 12:01:23','2026-07-13 12:01:23'),(3683,3,588,2190,1,NULL,1,'2026-07-13 12:01:23','2026-07-13 12:01:23'),(3684,3,588,2221,1,NULL,1,'2026-07-13 12:01:23','2026-07-13 12:01:23'),(3685,8,600,2235,1,9.00,1,'2026-07-13 13:04:09','2026-07-13 13:04:09'),(3686,8,600,2236,1,9.00,1,'2026-07-13 13:04:09','2026-07-13 13:04:09'),(3687,8,600,2237,1,9.00,1,'2026-07-13 13:04:09','2026-07-13 13:04:09'),(3688,8,600,2238,1,9.00,1,'2026-07-13 13:04:09','2026-07-13 13:04:09'),(3689,8,600,2239,1,9.00,1,'2026-07-13 13:04:09','2026-07-13 13:04:09'),(3690,8,600,2240,1,9.00,1,'2026-07-13 13:04:09','2026-07-13 13:04:09'),(3691,1,600,2235,1,NULL,1,'2026-07-13 13:04:09','2026-07-13 13:04:09'),(3692,1,600,2236,1,NULL,1,'2026-07-13 13:04:09','2026-07-13 13:04:09'),(3693,1,600,2237,1,NULL,1,'2026-07-13 13:04:09','2026-07-13 13:04:09'),(3694,1,600,2238,1,NULL,1,'2026-07-13 13:04:09','2026-07-13 13:04:09'),(3695,1,600,2239,1,NULL,1,'2026-07-13 13:04:09','2026-07-13 13:04:09'),(3696,1,600,2240,1,NULL,1,'2026-07-13 13:04:09','2026-07-13 13:04:09'),(3697,9,600,2235,1,NULL,1,'2026-07-13 13:04:09','2026-07-13 13:04:09'),(3698,9,600,2236,1,NULL,1,'2026-07-13 13:04:09','2026-07-13 13:04:09'),(3699,9,600,2237,1,NULL,1,'2026-07-13 13:04:09','2026-07-13 13:04:09'),(3700,9,600,2238,1,NULL,1,'2026-07-13 13:04:09','2026-07-13 13:04:09'),(3701,9,600,2239,1,NULL,1,'2026-07-13 13:04:09','2026-07-13 13:04:09'),(3702,9,600,2240,1,NULL,1,'2026-07-13 13:04:09','2026-07-13 13:04:09'),(3703,3,600,2235,1,NULL,1,'2026-07-13 13:04:09','2026-07-13 13:04:09'),(3704,3,600,2236,1,NULL,1,'2026-07-13 13:04:09','2026-07-13 13:04:09'),(3705,3,600,2237,1,NULL,1,'2026-07-13 13:04:09','2026-07-13 13:04:09'),(3706,3,600,2238,1,NULL,1,'2026-07-13 13:04:09','2026-07-13 13:04:09'),(3707,3,600,2239,1,NULL,1,'2026-07-13 13:04:09','2026-07-13 13:04:09'),(3708,3,600,2240,1,NULL,1,'2026-07-13 13:04:09','2026-07-13 13:04:09'),(3709,8,580,2048,2,8.00,1,'2026-07-13 13:13:42','2026-07-13 13:13:42'),(3710,8,580,2080,2,8.00,1,'2026-07-13 13:13:42','2026-07-13 13:13:42'),(3711,8,580,2111,2,8.00,1,'2026-07-13 13:13:42','2026-07-13 13:13:42'),(3712,8,580,2142,2,8.00,1,'2026-07-13 13:13:42','2026-07-13 13:13:42'),(3713,8,580,2173,2,8.00,1,'2026-07-13 13:13:42','2026-07-13 13:13:42'),(3714,8,580,2204,2,8.00,1,'2026-07-13 13:13:42','2026-07-13 13:13:42'),(3715,1,580,2048,2,NULL,1,'2026-07-13 13:13:42','2026-07-13 13:13:42'),(3716,1,580,2080,2,NULL,1,'2026-07-13 13:13:42','2026-07-13 13:13:42'),(3717,1,580,2111,2,NULL,1,'2026-07-13 13:13:42','2026-07-13 13:13:42'),(3718,1,580,2142,2,NULL,1,'2026-07-13 13:13:43','2026-07-13 13:13:43'),(3719,1,580,2173,2,NULL,1,'2026-07-13 13:13:43','2026-07-13 13:13:43'),(3720,1,580,2204,2,NULL,1,'2026-07-13 13:13:43','2026-07-13 13:13:43'),(3721,9,580,2048,2,NULL,1,'2026-07-13 13:13:43','2026-07-13 13:13:43'),(3722,9,580,2080,2,NULL,1,'2026-07-13 13:13:43','2026-07-13 13:13:43'),(3723,9,580,2111,2,NULL,1,'2026-07-13 13:13:43','2026-07-13 13:13:43'),(3724,9,580,2142,2,NULL,1,'2026-07-13 13:13:43','2026-07-13 13:13:43'),(3725,9,580,2173,2,NULL,1,'2026-07-13 13:13:43','2026-07-13 13:13:43'),(3726,9,580,2204,2,NULL,1,'2026-07-13 13:13:43','2026-07-13 13:13:43'),(3727,3,580,2048,2,NULL,1,'2026-07-13 13:13:43','2026-07-13 13:13:43'),(3728,3,580,2080,2,NULL,1,'2026-07-13 13:13:43','2026-07-13 13:13:43'),(3729,3,580,2111,2,NULL,1,'2026-07-13 13:13:43','2026-07-13 13:13:43'),(3730,3,580,2142,2,NULL,1,'2026-07-13 13:13:44','2026-07-13 13:13:44'),(3731,3,580,2173,2,NULL,1,'2026-07-13 13:13:44','2026-07-13 13:13:44'),(3732,3,580,2204,2,NULL,1,'2026-07-13 13:13:44','2026-07-13 13:13:44'),(3757,8,592,2050,2,9.00,1,'2026-07-13 13:13:53','2026-07-13 13:13:53'),(3758,8,592,2082,2,9.00,1,'2026-07-13 13:13:53','2026-07-13 13:13:53'),(3759,8,592,2113,2,9.00,1,'2026-07-13 13:13:53','2026-07-13 13:13:53'),(3760,8,592,2144,2,9.00,1,'2026-07-13 13:13:53','2026-07-13 13:13:53'),(3761,8,592,2175,2,9.00,1,'2026-07-13 13:13:53','2026-07-13 13:13:53'),(3762,8,592,2206,2,9.00,1,'2026-07-13 13:13:53','2026-07-13 13:13:53'),(3763,1,592,2050,2,NULL,1,'2026-07-13 13:13:53','2026-07-13 13:13:53'),(3764,1,592,2082,2,NULL,1,'2026-07-13 13:13:54','2026-07-13 13:13:54'),(3765,1,592,2113,2,NULL,1,'2026-07-13 13:13:54','2026-07-13 13:13:54'),(3766,1,592,2144,2,NULL,1,'2026-07-13 13:13:54','2026-07-13 13:13:54'),(3767,1,592,2175,2,NULL,1,'2026-07-13 13:13:54','2026-07-13 13:13:54'),(3768,1,592,2206,2,NULL,1,'2026-07-13 13:13:54','2026-07-13 13:13:54'),(3769,9,592,2050,2,NULL,1,'2026-07-13 13:13:54','2026-07-13 13:13:54'),(3770,9,592,2082,2,NULL,1,'2026-07-13 13:13:54','2026-07-13 13:13:54'),(3771,9,592,2113,2,NULL,1,'2026-07-13 13:13:54','2026-07-13 13:13:54'),(3772,9,592,2144,2,NULL,1,'2026-07-13 13:13:54','2026-07-13 13:13:54'),(3773,9,592,2175,2,NULL,1,'2026-07-13 13:13:54','2026-07-13 13:13:54'),(3774,9,592,2206,2,NULL,1,'2026-07-13 13:13:54','2026-07-13 13:13:54'),(3775,3,592,2050,2,NULL,1,'2026-07-13 13:13:54','2026-07-13 13:13:54'),(3776,3,592,2082,2,NULL,1,'2026-07-13 13:13:54','2026-07-13 13:13:54'),(3777,3,592,2113,2,NULL,1,'2026-07-13 13:13:54','2026-07-13 13:13:54'),(3778,3,592,2144,2,NULL,1,'2026-07-13 13:13:54','2026-07-13 13:13:54'),(3779,3,592,2175,2,NULL,1,'2026-07-13 13:13:55','2026-07-13 13:13:55'),(3780,3,592,2206,2,NULL,1,'2026-07-13 13:13:55','2026-07-13 13:13:55'),(3781,8,593,2051,2,9.00,1,'2026-07-13 13:14:03','2026-07-13 13:14:03'),(3782,8,593,2083,2,8.00,1,'2026-07-13 13:14:03','2026-07-13 13:14:03'),(3783,8,593,2114,2,8.00,1,'2026-07-13 13:14:03','2026-07-13 13:14:03'),(3784,8,593,2145,2,8.00,1,'2026-07-13 13:14:03','2026-07-13 13:14:03'),(3785,8,593,2176,2,9.00,1,'2026-07-13 13:14:03','2026-07-13 13:14:03'),(3786,8,593,2207,2,9.00,1,'2026-07-13 13:14:03','2026-07-13 13:14:03'),(3787,1,593,2051,2,NULL,1,'2026-07-13 13:14:03','2026-07-13 13:14:03'),(3788,1,593,2083,2,NULL,1,'2026-07-13 13:14:03','2026-07-13 13:14:03'),(3789,1,593,2114,2,NULL,1,'2026-07-13 13:14:03','2026-07-13 13:14:03'),(3790,1,593,2145,2,NULL,1,'2026-07-13 13:14:03','2026-07-13 13:14:03'),(3791,1,593,2176,2,NULL,1,'2026-07-13 13:14:03','2026-07-13 13:14:03'),(3792,1,593,2207,2,NULL,1,'2026-07-13 13:14:03','2026-07-13 13:14:03'),(3793,9,593,2051,2,NULL,1,'2026-07-13 13:14:03','2026-07-13 13:14:03'),(3794,9,593,2083,2,NULL,1,'2026-07-13 13:14:03','2026-07-13 13:14:03'),(3795,9,593,2114,2,NULL,1,'2026-07-13 13:14:03','2026-07-13 13:14:03'),(3796,9,593,2145,2,NULL,1,'2026-07-13 13:14:03','2026-07-13 13:14:03'),(3797,9,593,2176,2,NULL,1,'2026-07-13 13:14:04','2026-07-13 13:14:04'),(3798,9,593,2207,2,NULL,1,'2026-07-13 13:14:04','2026-07-13 13:14:04'),(3799,3,593,2051,2,NULL,1,'2026-07-13 13:14:04','2026-07-13 13:14:04'),(3800,3,593,2083,2,NULL,1,'2026-07-13 13:14:04','2026-07-13 13:14:04'),(3801,3,593,2114,2,NULL,1,'2026-07-13 13:14:04','2026-07-13 13:14:04'),(3802,3,593,2145,2,NULL,1,'2026-07-13 13:14:04','2026-07-13 13:14:04'),(3803,3,593,2176,2,NULL,1,'2026-07-13 13:14:04','2026-07-13 13:14:04'),(3804,3,593,2207,2,NULL,1,'2026-07-13 13:14:04','2026-07-13 13:14:04'),(3829,8,600,2235,2,10.00,1,'2026-07-13 13:14:23','2026-07-13 13:14:23'),(3830,8,600,2236,2,10.00,1,'2026-07-13 13:14:23','2026-07-13 13:14:23'),(3831,8,600,2237,2,10.00,1,'2026-07-13 13:14:23','2026-07-13 13:14:23'),(3832,8,600,2238,2,10.00,1,'2026-07-13 13:14:23','2026-07-13 13:14:23'),(3833,8,600,2239,2,10.00,1,'2026-07-13 13:14:23','2026-07-13 13:14:23'),(3834,8,600,2240,2,10.00,1,'2026-07-13 13:14:23','2026-07-13 13:14:23'),(3835,1,600,2235,2,NULL,1,'2026-07-13 13:14:23','2026-07-13 13:14:23'),(3836,1,600,2236,2,NULL,1,'2026-07-13 13:14:23','2026-07-13 13:14:23'),(3837,1,600,2237,2,NULL,1,'2026-07-13 13:14:23','2026-07-13 13:14:23'),(3838,1,600,2238,2,NULL,1,'2026-07-13 13:14:23','2026-07-13 13:14:23'),(3839,1,600,2239,2,NULL,1,'2026-07-13 13:14:23','2026-07-13 13:14:23'),(3840,1,600,2240,2,NULL,1,'2026-07-13 13:14:23','2026-07-13 13:14:23'),(3841,9,600,2235,2,NULL,1,'2026-07-13 13:14:23','2026-07-13 13:14:23'),(3842,9,600,2236,2,NULL,1,'2026-07-13 13:14:23','2026-07-13 13:14:23'),(3843,9,600,2237,2,NULL,1,'2026-07-13 13:14:23','2026-07-13 13:14:23'),(3844,9,600,2238,2,NULL,1,'2026-07-13 13:14:23','2026-07-13 13:14:23'),(3845,9,600,2239,2,NULL,1,'2026-07-13 13:14:23','2026-07-13 13:14:23'),(3846,9,600,2240,2,NULL,1,'2026-07-13 13:14:24','2026-07-13 13:14:24'),(3847,3,600,2235,2,NULL,1,'2026-07-13 13:14:24','2026-07-13 13:14:24'),(3848,3,600,2236,2,NULL,1,'2026-07-13 13:14:24','2026-07-13 13:14:24'),(3849,3,600,2237,2,NULL,1,'2026-07-13 13:14:24','2026-07-13 13:14:24'),(3850,3,600,2238,2,NULL,1,'2026-07-13 13:14:24','2026-07-13 13:14:24'),(3851,3,600,2239,2,NULL,1,'2026-07-13 13:14:24','2026-07-13 13:14:24'),(3852,3,600,2240,2,NULL,1,'2026-07-13 13:14:24','2026-07-13 13:14:24'),(3877,8,594,2052,2,10.00,1,'2026-07-13 13:14:35','2026-07-13 13:14:35'),(3878,8,594,2084,2,10.00,1,'2026-07-13 13:14:35','2026-07-13 13:14:35'),(3879,8,594,2115,2,10.00,1,'2026-07-13 13:14:35','2026-07-13 13:14:35'),(3880,8,594,2146,2,10.00,1,'2026-07-13 13:14:35','2026-07-13 13:14:35'),(3881,8,594,2177,2,10.00,1,'2026-07-13 13:14:35','2026-07-13 13:14:35'),(3882,8,594,2208,2,10.00,1,'2026-07-13 13:14:35','2026-07-13 13:14:35'),(3883,1,594,2052,2,NULL,1,'2026-07-13 13:14:35','2026-07-13 13:14:35'),(3884,1,594,2084,2,NULL,1,'2026-07-13 13:14:36','2026-07-13 13:14:36'),(3885,1,594,2115,2,NULL,1,'2026-07-13 13:14:36','2026-07-13 13:14:36'),(3886,1,594,2146,2,NULL,1,'2026-07-13 13:14:36','2026-07-13 13:14:36'),(3887,1,594,2177,2,NULL,1,'2026-07-13 13:14:36','2026-07-13 13:14:36'),(3888,1,594,2208,2,NULL,1,'2026-07-13 13:14:36','2026-07-13 13:14:36'),(3889,9,594,2052,2,NULL,1,'2026-07-13 13:14:36','2026-07-13 13:14:36'),(3890,9,594,2084,2,NULL,1,'2026-07-13 13:14:36','2026-07-13 13:14:36'),(3891,9,594,2115,2,NULL,1,'2026-07-13 13:14:36','2026-07-13 13:14:36'),(3892,9,594,2146,2,NULL,1,'2026-07-13 13:14:36','2026-07-13 13:14:36'),(3893,9,594,2177,2,NULL,1,'2026-07-13 13:14:36','2026-07-13 13:14:36'),(3894,9,594,2208,2,NULL,1,'2026-07-13 13:14:36','2026-07-13 13:14:36'),(3895,3,594,2052,2,NULL,1,'2026-07-13 13:14:36','2026-07-13 13:14:36'),(3896,3,594,2084,2,NULL,1,'2026-07-13 13:14:36','2026-07-13 13:14:36'),(3897,3,594,2115,2,NULL,1,'2026-07-13 13:14:36','2026-07-13 13:14:36'),(3898,3,594,2146,2,NULL,1,'2026-07-13 13:14:36','2026-07-13 13:14:36'),(3899,3,594,2177,2,NULL,1,'2026-07-13 13:14:36','2026-07-13 13:14:36'),(3900,3,594,2208,2,NULL,1,'2026-07-13 13:14:36','2026-07-13 13:14:36'),(3901,8,595,2053,2,8.00,1,'2026-07-13 13:14:47','2026-07-13 13:14:47'),(3902,8,595,2085,2,8.00,1,'2026-07-13 13:14:47','2026-07-13 13:14:47'),(3903,8,595,2116,2,8.00,1,'2026-07-13 13:14:47','2026-07-13 13:14:47'),(3904,8,595,2147,2,8.00,1,'2026-07-13 13:14:47','2026-07-13 13:14:47'),(3905,8,595,2178,2,8.00,1,'2026-07-13 13:14:47','2026-07-13 13:14:47'),(3906,8,595,2209,2,8.00,1,'2026-07-13 13:14:47','2026-07-13 13:14:47'),(3907,1,595,2053,2,NULL,1,'2026-07-13 13:14:47','2026-07-13 13:14:47'),(3908,1,595,2085,2,NULL,1,'2026-07-13 13:14:47','2026-07-13 13:14:47'),(3909,1,595,2116,2,NULL,1,'2026-07-13 13:14:47','2026-07-13 13:14:47'),(3910,1,595,2147,2,NULL,1,'2026-07-13 13:14:47','2026-07-13 13:14:47'),(3911,1,595,2178,2,NULL,1,'2026-07-13 13:14:47','2026-07-13 13:14:47'),(3912,1,595,2209,2,NULL,1,'2026-07-13 13:14:47','2026-07-13 13:14:47'),(3913,9,595,2053,2,NULL,1,'2026-07-13 13:14:47','2026-07-13 13:14:47'),(3914,9,595,2085,2,NULL,1,'2026-07-13 13:14:48','2026-07-13 13:14:48'),(3915,9,595,2116,2,NULL,1,'2026-07-13 13:14:48','2026-07-13 13:14:48'),(3916,9,595,2147,2,NULL,1,'2026-07-13 13:14:48','2026-07-13 13:14:48'),(3917,9,595,2178,2,NULL,1,'2026-07-13 13:14:48','2026-07-13 13:14:48'),(3918,9,595,2209,2,NULL,1,'2026-07-13 13:14:48','2026-07-13 13:14:48'),(3919,3,595,2053,2,NULL,1,'2026-07-13 13:14:48','2026-07-13 13:14:48'),(3920,3,595,2085,2,NULL,1,'2026-07-13 13:14:48','2026-07-13 13:14:48'),(3921,3,595,2116,2,NULL,1,'2026-07-13 13:14:48','2026-07-13 13:14:48'),(3922,3,595,2147,2,NULL,1,'2026-07-13 13:14:48','2026-07-13 13:14:48'),(3923,3,595,2178,2,NULL,1,'2026-07-13 13:14:48','2026-07-13 13:14:48'),(3924,3,595,2209,2,NULL,1,'2026-07-13 13:14:48','2026-07-13 13:14:48'),(3925,8,596,2054,2,9.00,1,'2026-07-13 13:14:56','2026-07-13 13:14:56'),(3926,8,596,2086,2,9.00,1,'2026-07-13 13:14:56','2026-07-13 13:14:56'),(3927,8,596,2117,2,9.00,1,'2026-07-13 13:14:57','2026-07-13 13:14:57'),(3928,8,596,2148,2,9.00,1,'2026-07-13 13:14:57','2026-07-13 13:14:57'),(3929,8,596,2179,2,9.00,1,'2026-07-13 13:14:57','2026-07-13 13:14:57'),(3930,8,596,2210,2,9.00,1,'2026-07-13 13:14:57','2026-07-13 13:14:57'),(3931,1,596,2054,2,NULL,1,'2026-07-13 13:14:57','2026-07-13 13:14:57'),(3932,1,596,2086,2,NULL,1,'2026-07-13 13:14:57','2026-07-13 13:14:57'),(3933,1,596,2117,2,NULL,1,'2026-07-13 13:14:57','2026-07-13 13:14:57'),(3934,1,596,2148,2,NULL,1,'2026-07-13 13:14:57','2026-07-13 13:14:57'),(3935,1,596,2179,2,NULL,1,'2026-07-13 13:14:57','2026-07-13 13:14:57'),(3936,1,596,2210,2,NULL,1,'2026-07-13 13:14:58','2026-07-13 13:14:58'),(3937,9,596,2054,2,NULL,1,'2026-07-13 13:14:58','2026-07-13 13:14:58'),(3938,9,596,2086,2,NULL,1,'2026-07-13 13:14:58','2026-07-13 13:14:58'),(3939,9,596,2117,2,NULL,1,'2026-07-13 13:14:58','2026-07-13 13:14:58'),(3940,9,596,2148,2,NULL,1,'2026-07-13 13:14:58','2026-07-13 13:14:58'),(3941,9,596,2179,2,NULL,1,'2026-07-13 13:14:58','2026-07-13 13:14:58'),(3942,9,596,2210,2,NULL,1,'2026-07-13 13:14:58','2026-07-13 13:14:58'),(3943,3,596,2054,2,NULL,1,'2026-07-13 13:14:58','2026-07-13 13:14:58'),(3944,3,596,2086,2,NULL,1,'2026-07-13 13:14:58','2026-07-13 13:14:58'),(3945,3,596,2117,2,NULL,1,'2026-07-13 13:14:58','2026-07-13 13:14:58'),(3946,3,596,2148,2,NULL,1,'2026-07-13 13:14:58','2026-07-13 13:14:58'),(3947,3,596,2179,2,NULL,1,'2026-07-13 13:14:58','2026-07-13 13:14:58'),(3948,3,596,2210,2,NULL,1,'2026-07-13 13:14:58','2026-07-13 13:14:58'),(3973,8,597,2055,2,10.00,1,'2026-07-13 13:15:15','2026-07-13 13:15:15'),(3974,8,597,2087,2,10.00,1,'2026-07-13 13:15:15','2026-07-13 13:15:15'),(3975,8,597,2118,2,10.00,1,'2026-07-13 13:15:15','2026-07-13 13:15:15'),(3976,8,597,2149,2,10.00,1,'2026-07-13 13:15:15','2026-07-13 13:15:15'),(3977,8,597,2180,2,10.00,1,'2026-07-13 13:15:15','2026-07-13 13:15:15'),(3978,8,597,2211,2,10.00,1,'2026-07-13 13:15:15','2026-07-13 13:15:15'),(3979,1,597,2055,2,NULL,1,'2026-07-13 13:15:15','2026-07-13 13:15:15'),(3980,1,597,2087,2,NULL,1,'2026-07-13 13:15:15','2026-07-13 13:15:15'),(3981,1,597,2118,2,NULL,1,'2026-07-13 13:15:15','2026-07-13 13:15:15'),(3982,1,597,2149,2,NULL,1,'2026-07-13 13:15:15','2026-07-13 13:15:15'),(3983,1,597,2180,2,NULL,1,'2026-07-13 13:15:15','2026-07-13 13:15:15'),(3984,1,597,2211,2,NULL,1,'2026-07-13 13:15:15','2026-07-13 13:15:15'),(3985,9,597,2055,2,NULL,1,'2026-07-13 13:15:15','2026-07-13 13:15:15'),(3986,9,597,2087,2,NULL,1,'2026-07-13 13:15:15','2026-07-13 13:15:15'),(3987,9,597,2118,2,NULL,1,'2026-07-13 13:15:15','2026-07-13 13:15:15'),(3988,9,597,2149,2,NULL,1,'2026-07-13 13:15:15','2026-07-13 13:15:15'),(3989,9,597,2180,2,NULL,1,'2026-07-13 13:15:15','2026-07-13 13:15:15'),(3990,9,597,2211,2,NULL,1,'2026-07-13 13:15:15','2026-07-13 13:15:15'),(3991,3,597,2055,2,NULL,1,'2026-07-13 13:15:15','2026-07-13 13:15:15'),(3992,3,597,2087,2,NULL,1,'2026-07-13 13:15:15','2026-07-13 13:15:15'),(3993,3,597,2118,2,NULL,1,'2026-07-13 13:15:15','2026-07-13 13:15:15'),(3994,3,597,2149,2,NULL,1,'2026-07-13 13:15:15','2026-07-13 13:15:15'),(3995,3,597,2180,2,NULL,1,'2026-07-13 13:15:15','2026-07-13 13:15:15'),(3996,3,597,2211,2,NULL,1,'2026-07-13 13:15:15','2026-07-13 13:15:15'),(3997,8,589,2049,2,9.00,1,'2026-07-13 13:15:22','2026-07-13 13:15:22'),(3998,8,589,2081,2,9.00,1,'2026-07-13 13:15:22','2026-07-13 13:15:22'),(3999,8,589,2112,2,9.00,1,'2026-07-13 13:15:22','2026-07-13 13:15:22'),(4000,8,589,2143,2,9.00,1,'2026-07-13 13:15:22','2026-07-13 13:15:22'),(4001,8,589,2174,2,9.00,1,'2026-07-13 13:15:22','2026-07-13 13:15:22'),(4002,8,589,2205,2,9.00,1,'2026-07-13 13:15:22','2026-07-13 13:15:22'),(4003,1,589,2049,2,NULL,1,'2026-07-13 13:15:22','2026-07-13 13:15:22'),(4004,1,589,2081,2,NULL,1,'2026-07-13 13:15:22','2026-07-13 13:15:22'),(4005,1,589,2112,2,NULL,1,'2026-07-13 13:15:22','2026-07-13 13:15:22'),(4006,1,589,2143,2,NULL,1,'2026-07-13 13:15:22','2026-07-13 13:15:22'),(4007,1,589,2174,2,NULL,1,'2026-07-13 13:15:22','2026-07-13 13:15:22'),(4008,1,589,2205,2,NULL,1,'2026-07-13 13:15:22','2026-07-13 13:15:22'),(4009,9,589,2049,2,NULL,1,'2026-07-13 13:15:22','2026-07-13 13:15:22'),(4010,9,589,2081,2,NULL,1,'2026-07-13 13:15:22','2026-07-13 13:15:22'),(4011,9,589,2112,2,NULL,1,'2026-07-13 13:15:22','2026-07-13 13:15:22'),(4012,9,589,2143,2,NULL,1,'2026-07-13 13:15:22','2026-07-13 13:15:22'),(4013,9,589,2174,2,NULL,1,'2026-07-13 13:15:22','2026-07-13 13:15:22'),(4014,9,589,2205,2,NULL,1,'2026-07-13 13:15:22','2026-07-13 13:15:22'),(4015,3,589,2049,2,NULL,1,'2026-07-13 13:15:22','2026-07-13 13:15:22'),(4016,3,589,2081,2,NULL,1,'2026-07-13 13:15:22','2026-07-13 13:15:22'),(4017,3,589,2112,2,NULL,1,'2026-07-13 13:15:22','2026-07-13 13:15:22'),(4018,3,589,2143,2,NULL,1,'2026-07-13 13:15:22','2026-07-13 13:15:22'),(4019,3,589,2174,2,NULL,1,'2026-07-13 13:15:23','2026-07-13 13:15:23'),(4020,3,589,2205,2,NULL,1,'2026-07-13 13:15:23','2026-07-13 13:15:23'),(4045,8,590,2056,2,10.00,1,'2026-07-13 13:15:34','2026-07-13 13:15:34'),(4046,8,590,2088,2,10.00,1,'2026-07-13 13:15:34','2026-07-13 13:15:34'),(4047,8,590,2119,2,10.00,1,'2026-07-13 13:15:35','2026-07-13 13:15:35'),(4048,8,590,2150,2,10.00,1,'2026-07-13 13:15:35','2026-07-13 13:15:35'),(4049,8,590,2181,2,10.00,1,'2026-07-13 13:15:35','2026-07-13 13:15:35'),(4050,8,590,2212,2,10.00,1,'2026-07-13 13:15:35','2026-07-13 13:15:35'),(4051,1,590,2056,2,NULL,1,'2026-07-13 13:15:36','2026-07-13 13:15:36'),(4052,1,590,2088,2,NULL,1,'2026-07-13 13:15:36','2026-07-13 13:15:36'),(4053,1,590,2119,2,NULL,1,'2026-07-13 13:15:36','2026-07-13 13:15:36'),(4054,1,590,2150,2,NULL,1,'2026-07-13 13:15:36','2026-07-13 13:15:36'),(4055,1,590,2181,2,NULL,1,'2026-07-13 13:15:37','2026-07-13 13:15:37'),(4056,1,590,2212,2,NULL,1,'2026-07-13 13:15:37','2026-07-13 13:15:37'),(4057,9,590,2056,2,NULL,1,'2026-07-13 13:15:37','2026-07-13 13:15:37'),(4058,9,590,2088,2,NULL,1,'2026-07-13 13:15:37','2026-07-13 13:15:37'),(4059,9,590,2119,2,NULL,1,'2026-07-13 13:15:37','2026-07-13 13:15:37'),(4060,9,590,2150,2,NULL,1,'2026-07-13 13:15:37','2026-07-13 13:15:37'),(4061,9,590,2181,2,NULL,1,'2026-07-13 13:15:37','2026-07-13 13:15:37'),(4062,9,590,2212,2,NULL,1,'2026-07-13 13:15:38','2026-07-13 13:15:38'),(4063,3,590,2056,2,NULL,1,'2026-07-13 13:15:38','2026-07-13 13:15:38'),(4064,3,590,2088,2,NULL,1,'2026-07-13 13:15:38','2026-07-13 13:15:38'),(4065,3,590,2119,2,NULL,1,'2026-07-13 13:15:38','2026-07-13 13:15:38'),(4066,3,590,2150,2,NULL,1,'2026-07-13 13:15:38','2026-07-13 13:15:38'),(4067,3,590,2181,2,NULL,1,'2026-07-13 13:15:38','2026-07-13 13:15:38'),(4068,3,590,2212,2,NULL,1,'2026-07-13 13:15:38','2026-07-13 13:15:38'),(4093,8,591,2057,2,9.00,1,'2026-07-13 13:15:44','2026-07-13 13:15:44'),(4094,8,591,2089,2,9.00,1,'2026-07-13 13:15:44','2026-07-13 13:15:44'),(4095,8,591,2120,2,9.00,1,'2026-07-13 13:15:45','2026-07-13 13:15:45'),(4096,8,591,2151,2,9.00,1,'2026-07-13 13:15:45','2026-07-13 13:15:45'),(4097,8,591,2182,2,9.00,1,'2026-07-13 13:15:45','2026-07-13 13:15:45'),(4098,8,591,2213,2,9.00,1,'2026-07-13 13:15:45','2026-07-13 13:15:45'),(4099,1,591,2057,2,NULL,1,'2026-07-13 13:15:45','2026-07-13 13:15:45'),(4100,1,591,2089,2,NULL,1,'2026-07-13 13:15:45','2026-07-13 13:15:45'),(4101,1,591,2120,2,NULL,1,'2026-07-13 13:15:45','2026-07-13 13:15:45'),(4102,1,591,2151,2,NULL,1,'2026-07-13 13:15:45','2026-07-13 13:15:45'),(4103,1,591,2182,2,NULL,1,'2026-07-13 13:15:45','2026-07-13 13:15:45'),(4104,1,591,2213,2,NULL,1,'2026-07-13 13:15:45','2026-07-13 13:15:45'),(4105,9,591,2057,2,NULL,1,'2026-07-13 13:15:45','2026-07-13 13:15:45'),(4106,9,591,2089,2,NULL,1,'2026-07-13 13:15:45','2026-07-13 13:15:45'),(4107,9,591,2120,2,NULL,1,'2026-07-13 13:15:45','2026-07-13 13:15:45'),(4108,9,591,2151,2,NULL,1,'2026-07-13 13:15:45','2026-07-13 13:15:45'),(4109,9,591,2182,2,NULL,1,'2026-07-13 13:15:45','2026-07-13 13:15:45'),(4110,9,591,2213,2,NULL,1,'2026-07-13 13:15:46','2026-07-13 13:15:46'),(4111,3,591,2057,2,NULL,1,'2026-07-13 13:15:46','2026-07-13 13:15:46'),(4112,3,591,2089,2,NULL,1,'2026-07-13 13:15:46','2026-07-13 13:15:46'),(4113,3,591,2120,2,NULL,1,'2026-07-13 13:15:46','2026-07-13 13:15:46'),(4114,3,591,2151,2,NULL,1,'2026-07-13 13:15:46','2026-07-13 13:15:46'),(4115,3,591,2182,2,NULL,1,'2026-07-13 13:15:46','2026-07-13 13:15:46'),(4116,3,591,2213,2,NULL,1,'2026-07-13 13:15:46','2026-07-13 13:15:46'),(4117,8,588,2065,2,9.00,1,'2026-07-13 13:16:41','2026-07-13 13:16:41'),(4118,8,588,2097,2,9.00,1,'2026-07-13 13:16:41','2026-07-13 13:16:41'),(4119,8,588,2128,2,9.00,1,'2026-07-13 13:16:41','2026-07-13 13:16:41'),(4120,8,588,2159,2,9.00,1,'2026-07-13 13:16:41','2026-07-13 13:16:41'),(4121,8,588,2190,2,9.00,1,'2026-07-13 13:16:41','2026-07-13 13:16:41'),(4122,8,588,2221,2,9.00,1,'2026-07-13 13:16:41','2026-07-13 13:16:41'),(4123,1,588,2065,2,NULL,1,'2026-07-13 13:16:41','2026-07-13 13:16:41'),(4124,1,588,2097,2,NULL,1,'2026-07-13 13:16:41','2026-07-13 13:16:41'),(4125,1,588,2128,2,NULL,1,'2026-07-13 13:16:41','2026-07-13 13:16:41'),(4126,1,588,2159,2,NULL,1,'2026-07-13 13:16:41','2026-07-13 13:16:41'),(4127,1,588,2190,2,NULL,1,'2026-07-13 13:16:41','2026-07-13 13:16:41'),(4128,1,588,2221,2,NULL,1,'2026-07-13 13:16:41','2026-07-13 13:16:41'),(4129,9,588,2065,2,NULL,1,'2026-07-13 13:16:41','2026-07-13 13:16:41'),(4130,9,588,2097,2,NULL,1,'2026-07-13 13:16:41','2026-07-13 13:16:41'),(4131,9,588,2128,2,NULL,1,'2026-07-13 13:16:42','2026-07-13 13:16:42'),(4132,9,588,2159,2,NULL,1,'2026-07-13 13:16:42','2026-07-13 13:16:42'),(4133,9,588,2190,2,NULL,1,'2026-07-13 13:16:42','2026-07-13 13:16:42'),(4134,9,588,2221,2,NULL,1,'2026-07-13 13:16:42','2026-07-13 13:16:42'),(4135,3,588,2065,2,NULL,1,'2026-07-13 13:16:42','2026-07-13 13:16:42'),(4136,3,588,2097,2,NULL,1,'2026-07-13 13:16:42','2026-07-13 13:16:42'),(4137,3,588,2128,2,NULL,1,'2026-07-13 13:16:42','2026-07-13 13:16:42'),(4138,3,588,2159,2,NULL,1,'2026-07-13 13:16:42','2026-07-13 13:16:42'),(4139,3,588,2190,2,NULL,1,'2026-07-13 13:16:42','2026-07-13 13:16:42'),(4140,3,588,2221,2,NULL,1,'2026-07-13 13:16:42','2026-07-13 13:16:42'),(4141,8,581,2058,2,9.00,1,'2026-07-13 13:16:48','2026-07-13 13:16:48'),(4142,8,581,2090,2,9.00,1,'2026-07-13 13:16:48','2026-07-13 13:16:48'),(4143,8,581,2121,2,9.00,1,'2026-07-13 13:16:48','2026-07-13 13:16:48'),(4144,8,581,2152,2,9.00,1,'2026-07-13 13:16:48','2026-07-13 13:16:48'),(4145,8,581,2183,2,9.00,1,'2026-07-13 13:16:48','2026-07-13 13:16:48'),(4146,8,581,2214,2,9.00,1,'2026-07-13 13:16:48','2026-07-13 13:16:48'),(4147,1,581,2058,2,NULL,1,'2026-07-13 13:16:48','2026-07-13 13:16:48'),(4148,1,581,2090,2,NULL,1,'2026-07-13 13:16:48','2026-07-13 13:16:48'),(4149,1,581,2121,2,NULL,1,'2026-07-13 13:16:48','2026-07-13 13:16:48'),(4150,1,581,2152,2,NULL,1,'2026-07-13 13:16:48','2026-07-13 13:16:48'),(4151,1,581,2183,2,NULL,1,'2026-07-13 13:16:48','2026-07-13 13:16:48'),(4152,1,581,2214,2,NULL,1,'2026-07-13 13:16:48','2026-07-13 13:16:48'),(4153,9,581,2058,2,NULL,1,'2026-07-13 13:16:48','2026-07-13 13:16:48'),(4154,9,581,2090,2,NULL,1,'2026-07-13 13:16:48','2026-07-13 13:16:48'),(4155,9,581,2121,2,NULL,1,'2026-07-13 13:16:48','2026-07-13 13:16:48'),(4156,9,581,2152,2,NULL,1,'2026-07-13 13:16:48','2026-07-13 13:16:48'),(4157,9,581,2183,2,NULL,1,'2026-07-13 13:16:48','2026-07-13 13:16:48'),(4158,9,581,2214,2,NULL,1,'2026-07-13 13:16:48','2026-07-13 13:16:48'),(4159,3,581,2058,2,NULL,1,'2026-07-13 13:16:48','2026-07-13 13:16:48'),(4160,3,581,2090,2,NULL,1,'2026-07-13 13:16:48','2026-07-13 13:16:48'),(4161,3,581,2121,2,NULL,1,'2026-07-13 13:16:48','2026-07-13 13:16:48'),(4162,3,581,2152,2,NULL,1,'2026-07-13 13:16:48','2026-07-13 13:16:48'),(4163,3,581,2183,2,NULL,1,'2026-07-13 13:16:49','2026-07-13 13:16:49'),(4164,3,581,2214,2,NULL,1,'2026-07-13 13:16:49','2026-07-13 13:16:49'),(4165,8,582,2059,2,8.00,1,'2026-07-13 13:17:02','2026-07-13 13:17:02'),(4166,8,582,2091,2,8.00,1,'2026-07-13 13:17:02','2026-07-13 13:17:02'),(4167,8,582,2122,2,8.00,1,'2026-07-13 13:17:02','2026-07-13 13:17:02'),(4168,8,582,2153,2,8.00,1,'2026-07-13 13:17:02','2026-07-13 13:17:02'),(4169,8,582,2184,2,8.00,1,'2026-07-13 13:17:02','2026-07-13 13:17:02'),(4170,8,582,2215,2,8.00,1,'2026-07-13 13:17:02','2026-07-13 13:17:02'),(4171,1,582,2059,2,NULL,1,'2026-07-13 13:17:02','2026-07-13 13:17:02'),(4172,1,582,2091,2,NULL,1,'2026-07-13 13:17:02','2026-07-13 13:17:02'),(4173,1,582,2122,2,NULL,1,'2026-07-13 13:17:02','2026-07-13 13:17:02'),(4174,1,582,2153,2,NULL,1,'2026-07-13 13:17:02','2026-07-13 13:17:02'),(4175,1,582,2184,2,NULL,1,'2026-07-13 13:17:02','2026-07-13 13:17:02'),(4176,1,582,2215,2,NULL,1,'2026-07-13 13:17:02','2026-07-13 13:17:02'),(4177,9,582,2059,2,NULL,1,'2026-07-13 13:17:02','2026-07-13 13:17:02'),(4178,9,582,2091,2,NULL,1,'2026-07-13 13:17:02','2026-07-13 13:17:02'),(4179,9,582,2122,2,NULL,1,'2026-07-13 13:17:02','2026-07-13 13:17:02'),(4180,9,582,2153,2,NULL,1,'2026-07-13 13:17:02','2026-07-13 13:17:02'),(4181,9,582,2184,2,NULL,1,'2026-07-13 13:17:02','2026-07-13 13:17:02'),(4182,9,582,2215,2,NULL,1,'2026-07-13 13:17:02','2026-07-13 13:17:02'),(4183,3,582,2059,2,NULL,1,'2026-07-13 13:17:02','2026-07-13 13:17:02'),(4184,3,582,2091,2,NULL,1,'2026-07-13 13:17:02','2026-07-13 13:17:02'),(4185,3,582,2122,2,NULL,1,'2026-07-13 13:17:02','2026-07-13 13:17:02'),(4186,3,582,2153,2,NULL,1,'2026-07-13 13:17:02','2026-07-13 13:17:02'),(4187,3,582,2184,2,NULL,1,'2026-07-13 13:17:02','2026-07-13 13:17:02'),(4188,3,582,2215,2,NULL,1,'2026-07-13 13:17:02','2026-07-13 13:17:02'),(4189,8,583,2060,2,9.00,1,'2026-07-13 13:17:08','2026-07-13 13:17:08'),(4190,8,583,2092,2,9.00,1,'2026-07-13 13:17:08','2026-07-13 13:17:08'),(4191,8,583,2123,2,9.00,1,'2026-07-13 13:17:08','2026-07-13 13:17:08'),(4192,8,583,2154,2,9.00,1,'2026-07-13 13:17:08','2026-07-13 13:17:08'),(4193,8,583,2185,2,9.00,1,'2026-07-13 13:17:08','2026-07-13 13:17:08'),(4194,8,583,2216,2,9.00,1,'2026-07-13 13:17:08','2026-07-13 13:17:08'),(4195,1,583,2060,2,NULL,1,'2026-07-13 13:17:08','2026-07-13 13:17:08'),(4196,1,583,2092,2,NULL,1,'2026-07-13 13:17:08','2026-07-13 13:17:08'),(4197,1,583,2123,2,NULL,1,'2026-07-13 13:17:08','2026-07-13 13:17:08'),(4198,1,583,2154,2,NULL,1,'2026-07-13 13:17:08','2026-07-13 13:17:08'),(4199,1,583,2185,2,NULL,1,'2026-07-13 13:17:08','2026-07-13 13:17:08'),(4200,1,583,2216,2,NULL,1,'2026-07-13 13:17:08','2026-07-13 13:17:08'),(4201,9,583,2060,2,NULL,1,'2026-07-13 13:17:08','2026-07-13 13:17:08'),(4202,9,583,2092,2,NULL,1,'2026-07-13 13:17:08','2026-07-13 13:17:08'),(4203,9,583,2123,2,NULL,1,'2026-07-13 13:17:08','2026-07-13 13:17:08'),(4204,9,583,2154,2,NULL,1,'2026-07-13 13:17:08','2026-07-13 13:17:08'),(4205,9,583,2185,2,NULL,1,'2026-07-13 13:17:08','2026-07-13 13:17:08'),(4206,9,583,2216,2,NULL,1,'2026-07-13 13:17:08','2026-07-13 13:17:08'),(4207,3,583,2060,2,NULL,1,'2026-07-13 13:17:08','2026-07-13 13:17:08'),(4208,3,583,2092,2,NULL,1,'2026-07-13 13:17:08','2026-07-13 13:17:08'),(4209,3,583,2123,2,NULL,1,'2026-07-13 13:17:08','2026-07-13 13:17:08'),(4210,3,583,2154,2,NULL,1,'2026-07-13 13:17:08','2026-07-13 13:17:08'),(4211,3,583,2185,2,NULL,1,'2026-07-13 13:17:08','2026-07-13 13:17:08'),(4212,3,583,2216,2,NULL,1,'2026-07-13 13:17:08','2026-07-13 13:17:08'),(4213,8,584,2061,2,10.00,1,'2026-07-13 13:17:16','2026-07-13 13:17:16'),(4214,8,584,2093,2,10.00,1,'2026-07-13 13:17:16','2026-07-13 13:17:16'),(4215,8,584,2124,2,10.00,1,'2026-07-13 13:17:16','2026-07-13 13:17:16'),(4216,8,584,2155,2,10.00,1,'2026-07-13 13:17:16','2026-07-13 13:17:16'),(4217,8,584,2186,2,10.00,1,'2026-07-13 13:17:16','2026-07-13 13:17:16'),(4218,8,584,2217,2,10.00,1,'2026-07-13 13:17:16','2026-07-13 13:17:16'),(4219,1,584,2061,2,NULL,1,'2026-07-13 13:17:16','2026-07-13 13:17:16'),(4220,1,584,2093,2,NULL,1,'2026-07-13 13:17:16','2026-07-13 13:17:16'),(4221,1,584,2124,2,NULL,1,'2026-07-13 13:17:16','2026-07-13 13:17:16'),(4222,1,584,2155,2,NULL,1,'2026-07-13 13:17:16','2026-07-13 13:17:16'),(4223,1,584,2186,2,NULL,1,'2026-07-13 13:17:16','2026-07-13 13:17:16'),(4224,1,584,2217,2,NULL,1,'2026-07-13 13:17:16','2026-07-13 13:17:16'),(4225,9,584,2061,2,NULL,1,'2026-07-13 13:17:16','2026-07-13 13:17:16'),(4226,9,584,2093,2,NULL,1,'2026-07-13 13:17:16','2026-07-13 13:17:16'),(4227,9,584,2124,2,NULL,1,'2026-07-13 13:17:16','2026-07-13 13:17:16'),(4228,9,584,2155,2,NULL,1,'2026-07-13 13:17:16','2026-07-13 13:17:16'),(4229,9,584,2186,2,NULL,1,'2026-07-13 13:17:16','2026-07-13 13:17:16'),(4230,9,584,2217,2,NULL,1,'2026-07-13 13:17:16','2026-07-13 13:17:16'),(4231,3,584,2061,2,NULL,1,'2026-07-13 13:17:16','2026-07-13 13:17:16'),(4232,3,584,2093,2,NULL,1,'2026-07-13 13:17:16','2026-07-13 13:17:16'),(4233,3,584,2124,2,NULL,1,'2026-07-13 13:17:16','2026-07-13 13:17:16'),(4234,3,584,2155,2,NULL,1,'2026-07-13 13:17:16','2026-07-13 13:17:16'),(4235,3,584,2186,2,NULL,1,'2026-07-13 13:17:16','2026-07-13 13:17:16'),(4236,3,584,2217,2,NULL,1,'2026-07-13 13:17:16','2026-07-13 13:17:16'),(4237,8,585,2062,2,9.00,1,'2026-07-13 13:17:23','2026-07-13 13:17:23'),(4238,8,585,2094,2,9.00,1,'2026-07-13 13:17:23','2026-07-13 13:17:23'),(4239,8,585,2125,2,9.00,1,'2026-07-13 13:17:23','2026-07-13 13:17:23'),(4240,8,585,2156,2,9.00,1,'2026-07-13 13:17:23','2026-07-13 13:17:23'),(4241,8,585,2187,2,9.00,1,'2026-07-13 13:17:23','2026-07-13 13:17:23'),(4242,8,585,2218,2,9.00,1,'2026-07-13 13:17:23','2026-07-13 13:17:23'),(4243,1,585,2062,2,NULL,1,'2026-07-13 13:17:23','2026-07-13 13:17:23'),(4244,1,585,2094,2,NULL,1,'2026-07-13 13:17:23','2026-07-13 13:17:23'),(4245,1,585,2125,2,NULL,1,'2026-07-13 13:17:23','2026-07-13 13:17:23'),(4246,1,585,2156,2,NULL,1,'2026-07-13 13:17:23','2026-07-13 13:17:23'),(4247,1,585,2187,2,NULL,1,'2026-07-13 13:17:23','2026-07-13 13:17:23'),(4248,1,585,2218,2,NULL,1,'2026-07-13 13:17:23','2026-07-13 13:17:23'),(4249,9,585,2062,2,NULL,1,'2026-07-13 13:17:23','2026-07-13 13:17:23'),(4250,9,585,2094,2,NULL,1,'2026-07-13 13:17:23','2026-07-13 13:17:23'),(4251,9,585,2125,2,NULL,1,'2026-07-13 13:17:23','2026-07-13 13:17:23'),(4252,9,585,2156,2,NULL,1,'2026-07-13 13:17:23','2026-07-13 13:17:23'),(4253,9,585,2187,2,NULL,1,'2026-07-13 13:17:23','2026-07-13 13:17:23'),(4254,9,585,2218,2,NULL,1,'2026-07-13 13:17:23','2026-07-13 13:17:23'),(4255,3,585,2062,2,NULL,1,'2026-07-13 13:17:23','2026-07-13 13:17:23'),(4256,3,585,2094,2,NULL,1,'2026-07-13 13:17:23','2026-07-13 13:17:23'),(4257,3,585,2125,2,NULL,1,'2026-07-13 13:17:23','2026-07-13 13:17:23'),(4258,3,585,2156,2,NULL,1,'2026-07-13 13:17:23','2026-07-13 13:17:23'),(4259,3,585,2187,2,NULL,1,'2026-07-13 13:17:23','2026-07-13 13:17:23'),(4260,3,585,2218,2,NULL,1,'2026-07-13 13:17:23','2026-07-13 13:17:23'),(4261,8,586,2063,2,10.00,1,'2026-07-13 13:17:30','2026-07-13 13:17:30'),(4262,8,586,2095,2,10.00,1,'2026-07-13 13:17:30','2026-07-13 13:17:30'),(4263,8,586,2126,2,10.00,1,'2026-07-13 13:17:30','2026-07-13 13:17:30'),(4264,8,586,2157,2,10.00,1,'2026-07-13 13:17:31','2026-07-13 13:17:31'),(4265,8,586,2188,2,10.00,1,'2026-07-13 13:17:31','2026-07-13 13:17:31'),(4266,8,586,2219,2,10.00,1,'2026-07-13 13:17:31','2026-07-13 13:17:31'),(4267,1,586,2063,2,NULL,1,'2026-07-13 13:17:31','2026-07-13 13:17:31'),(4268,1,586,2095,2,NULL,1,'2026-07-13 13:17:31','2026-07-13 13:17:31'),(4269,1,586,2126,2,NULL,1,'2026-07-13 13:17:31','2026-07-13 13:17:31'),(4270,1,586,2157,2,NULL,1,'2026-07-13 13:17:31','2026-07-13 13:17:31'),(4271,1,586,2188,2,NULL,1,'2026-07-13 13:17:32','2026-07-13 13:17:32'),(4272,1,586,2219,2,NULL,1,'2026-07-13 13:17:32','2026-07-13 13:17:32'),(4273,9,586,2063,2,NULL,1,'2026-07-13 13:17:33','2026-07-13 13:17:33'),(4274,9,586,2095,2,NULL,1,'2026-07-13 13:17:33','2026-07-13 13:17:33'),(4275,9,586,2126,2,NULL,1,'2026-07-13 13:17:34','2026-07-13 13:17:34'),(4276,9,586,2157,2,NULL,1,'2026-07-13 13:17:35','2026-07-13 13:17:35'),(4277,9,586,2188,2,NULL,1,'2026-07-13 13:17:35','2026-07-13 13:17:35'),(4278,9,586,2219,2,NULL,1,'2026-07-13 13:17:35','2026-07-13 13:17:35'),(4279,3,586,2063,2,NULL,1,'2026-07-13 13:17:35','2026-07-13 13:17:35'),(4280,3,586,2095,2,NULL,1,'2026-07-13 13:17:35','2026-07-13 13:17:35'),(4281,3,586,2126,2,NULL,1,'2026-07-13 13:17:36','2026-07-13 13:17:36'),(4282,3,586,2157,2,NULL,1,'2026-07-13 13:17:36','2026-07-13 13:17:36'),(4283,3,586,2188,2,NULL,1,'2026-07-13 13:17:36','2026-07-13 13:17:36'),(4284,3,586,2219,2,NULL,1,'2026-07-13 13:17:36','2026-07-13 13:17:36'),(4309,8,587,2064,2,9.00,1,'2026-07-13 13:17:45','2026-07-13 13:17:45'),(4310,8,587,2096,2,9.00,1,'2026-07-13 13:17:45','2026-07-13 13:17:45'),(4311,8,587,2127,2,9.00,1,'2026-07-13 13:17:45','2026-07-13 13:17:45'),(4312,8,587,2158,2,9.00,1,'2026-07-13 13:17:45','2026-07-13 13:17:45'),(4313,8,587,2189,2,9.00,1,'2026-07-13 13:17:45','2026-07-13 13:17:45'),(4314,8,587,2220,2,9.00,1,'2026-07-13 13:17:45','2026-07-13 13:17:45'),(4315,1,587,2064,2,NULL,1,'2026-07-13 13:17:45','2026-07-13 13:17:45'),(4316,1,587,2096,2,NULL,1,'2026-07-13 13:17:45','2026-07-13 13:17:45'),(4317,1,587,2127,2,NULL,1,'2026-07-13 13:17:45','2026-07-13 13:17:45'),(4318,1,587,2158,2,NULL,1,'2026-07-13 13:17:45','2026-07-13 13:17:45'),(4319,1,587,2189,2,NULL,1,'2026-07-13 13:17:45','2026-07-13 13:17:45'),(4320,1,587,2220,2,NULL,1,'2026-07-13 13:17:45','2026-07-13 13:17:45'),(4321,9,587,2064,2,NULL,1,'2026-07-13 13:17:45','2026-07-13 13:17:45'),(4322,9,587,2096,2,NULL,1,'2026-07-13 13:17:45','2026-07-13 13:17:45'),(4323,9,587,2127,2,NULL,1,'2026-07-13 13:17:45','2026-07-13 13:17:45'),(4324,9,587,2158,2,NULL,1,'2026-07-13 13:17:45','2026-07-13 13:17:45'),(4325,9,587,2189,2,NULL,1,'2026-07-13 13:17:45','2026-07-13 13:17:45'),(4326,9,587,2220,2,NULL,1,'2026-07-13 13:17:45','2026-07-13 13:17:45'),(4327,3,587,2064,2,NULL,1,'2026-07-13 13:17:45','2026-07-13 13:17:45'),(4328,3,587,2096,2,NULL,1,'2026-07-13 13:17:45','2026-07-13 13:17:45'),(4329,3,587,2127,2,NULL,1,'2026-07-13 13:17:45','2026-07-13 13:17:45'),(4330,3,587,2158,2,NULL,1,'2026-07-13 13:17:45','2026-07-13 13:17:45'),(4331,3,587,2189,2,NULL,1,'2026-07-13 13:17:45','2026-07-13 13:17:45'),(4332,3,587,2220,2,NULL,1,'2026-07-13 13:17:45','2026-07-13 13:17:45');
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
) ENGINE=InnoDB AUTO_INCREMENT=121 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `calificaciones_disciplina`
--

LOCK TABLES `calificaciones_disciplina` WRITE;
/*!40000 ALTER TABLE `calificaciones_disciplina` DISABLE KEYS */;
INSERT INTO `calificaciones_disciplina` VALUES (1,8,8,1,10.00,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(2,8,15,1,10.00,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(3,8,22,1,10.00,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(4,8,29,1,10.00,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(5,8,36,1,10.00,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(6,8,43,1,10.00,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(7,1,8,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(8,1,15,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(9,1,22,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(10,1,29,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(11,1,36,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(12,1,43,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(13,9,8,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(14,9,15,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(15,9,22,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(16,9,29,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(17,9,36,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(18,9,43,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(19,3,8,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(20,3,15,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(21,3,22,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(22,3,29,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(23,3,36,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(24,3,43,1,NULL,1,'2026-07-12 19:02:53','2026-07-12 19:02:53'),(49,8,47,1,10.00,1,'2026-07-13 12:00:24','2026-07-13 12:00:24'),(50,8,48,1,10.00,1,'2026-07-13 12:00:24','2026-07-13 12:00:24'),(51,8,49,1,10.00,1,'2026-07-13 12:00:24','2026-07-13 12:00:24'),(52,8,50,1,10.00,1,'2026-07-13 12:00:24','2026-07-13 12:00:24'),(53,8,51,1,10.00,1,'2026-07-13 12:00:24','2026-07-13 12:00:24'),(54,8,52,1,10.00,1,'2026-07-13 12:00:24','2026-07-13 12:00:24'),(55,1,47,1,NULL,1,'2026-07-13 12:00:24','2026-07-13 12:00:24'),(56,1,48,1,NULL,1,'2026-07-13 12:00:24','2026-07-13 12:00:24'),(57,1,49,1,NULL,1,'2026-07-13 12:00:24','2026-07-13 12:00:24'),(58,1,50,1,NULL,1,'2026-07-13 12:00:24','2026-07-13 12:00:24'),(59,1,51,1,NULL,1,'2026-07-13 12:00:24','2026-07-13 12:00:24'),(60,1,52,1,NULL,1,'2026-07-13 12:00:24','2026-07-13 12:00:24'),(61,9,47,1,NULL,1,'2026-07-13 12:00:24','2026-07-13 12:00:24'),(62,9,48,1,NULL,1,'2026-07-13 12:00:24','2026-07-13 12:00:24'),(63,9,49,1,NULL,1,'2026-07-13 12:00:24','2026-07-13 12:00:24'),(64,9,50,1,NULL,1,'2026-07-13 12:00:24','2026-07-13 12:00:24'),(65,9,51,1,NULL,1,'2026-07-13 12:00:24','2026-07-13 12:00:24'),(66,9,52,1,NULL,1,'2026-07-13 12:00:24','2026-07-13 12:00:24'),(67,3,47,1,NULL,1,'2026-07-13 12:00:24','2026-07-13 12:00:24'),(68,3,48,1,NULL,1,'2026-07-13 12:00:24','2026-07-13 12:00:24'),(69,3,49,1,NULL,1,'2026-07-13 12:00:24','2026-07-13 12:00:24'),(70,3,50,1,NULL,1,'2026-07-13 12:00:24','2026-07-13 12:00:24'),(71,3,51,1,NULL,1,'2026-07-13 12:00:24','2026-07-13 12:00:24'),(72,3,52,1,NULL,1,'2026-07-13 12:00:24','2026-07-13 12:00:24'),(73,8,47,2,10.00,1,'2026-07-13 13:15:58','2026-07-13 13:15:58'),(74,8,48,2,10.00,1,'2026-07-13 13:15:58','2026-07-13 13:15:58'),(75,8,49,2,10.00,1,'2026-07-13 13:15:58','2026-07-13 13:15:58'),(76,8,50,2,10.00,1,'2026-07-13 13:15:58','2026-07-13 13:15:58'),(77,8,51,2,10.00,1,'2026-07-13 13:15:58','2026-07-13 13:15:58'),(78,8,52,2,10.00,1,'2026-07-13 13:15:58','2026-07-13 13:15:58'),(79,1,47,2,NULL,1,'2026-07-13 13:15:58','2026-07-13 13:15:58'),(80,1,48,2,NULL,1,'2026-07-13 13:15:58','2026-07-13 13:15:58'),(81,1,49,2,NULL,1,'2026-07-13 13:15:58','2026-07-13 13:15:58'),(82,1,50,2,NULL,1,'2026-07-13 13:15:58','2026-07-13 13:15:58'),(83,1,51,2,NULL,1,'2026-07-13 13:15:58','2026-07-13 13:15:58'),(84,1,52,2,NULL,1,'2026-07-13 13:15:58','2026-07-13 13:15:58'),(85,9,47,2,NULL,1,'2026-07-13 13:15:59','2026-07-13 13:15:59'),(86,9,48,2,NULL,1,'2026-07-13 13:15:59','2026-07-13 13:15:59'),(87,9,49,2,NULL,1,'2026-07-13 13:15:59','2026-07-13 13:15:59'),(88,9,50,2,NULL,1,'2026-07-13 13:15:59','2026-07-13 13:15:59'),(89,9,51,2,NULL,1,'2026-07-13 13:15:59','2026-07-13 13:15:59'),(90,9,52,2,NULL,1,'2026-07-13 13:15:59','2026-07-13 13:15:59'),(91,3,47,2,NULL,1,'2026-07-13 13:15:59','2026-07-13 13:15:59'),(92,3,48,2,NULL,1,'2026-07-13 13:15:59','2026-07-13 13:15:59'),(93,3,49,2,NULL,1,'2026-07-13 13:15:59','2026-07-13 13:15:59'),(94,3,50,2,NULL,1,'2026-07-13 13:15:59','2026-07-13 13:15:59'),(95,3,51,2,NULL,1,'2026-07-13 13:15:59','2026-07-13 13:15:59'),(96,3,52,2,NULL,1,'2026-07-13 13:15:59','2026-07-13 13:15:59');
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
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `config_aspectos_global`
--

LOCK TABLES `config_aspectos_global` WRITE;
/*!40000 ALTER TABLE `config_aspectos_global` DISABLE KEYS */;
INSERT INTO `config_aspectos_global` VALUES (1,'primaria','Examen',50.00,1,0,1,'2026-06-14 22:47:27'),(2,'primaria','Tareas',10.00,2,0,1,'2026-06-14 22:47:27'),(3,'primaria','Participación',10.00,3,0,1,'2026-06-14 22:47:27'),(4,'primaria','Evaluación Parcial',10.00,4,0,1,'2026-06-14 22:47:27'),(5,'primaria','Proyecto',10.00,5,0,1,'2026-06-14 22:47:27'),(6,'primaria','Trabajo y Exposiciones',10.00,6,0,1,'2026-06-14 22:47:27'),(7,'secundaria','Examen',50.00,1,0,1,'2026-06-14 22:47:27'),(8,'secundaria','Tareas',10.00,2,0,1,'2026-06-14 22:47:27'),(9,'secundaria','Participación',10.00,3,0,1,'2026-06-14 22:47:27'),(10,'secundaria','Evaluación Parcial',10.00,4,0,1,'2026-06-14 22:47:27'),(11,'secundaria','Proyecto',10.00,5,0,1,'2026-06-14 22:47:27'),(12,'secundaria','Trabajo y Exposiciones',10.00,6,0,1,'2026-06-14 22:47:27'),(20,'preescolar','Examen',50.00,1,0,1,'2026-07-13 07:57:26'),(21,'preescolar','Tareas',10.00,2,0,1,'2026-07-13 07:57:26'),(22,'preescolar','Participación',10.00,3,0,1,'2026-07-13 07:57:26'),(23,'preescolar','Evaluación Parcial',10.00,4,0,1,'2026-07-13 07:57:26'),(24,'preescolar','Proyecto',10.00,5,0,1,'2026-07-13 07:57:26'),(25,'preescolar','Trabajo y Exposiciones',10.00,6,0,1,'2026-07-13 07:57:26'),(26,'maternal','Examen',50.00,1,0,1,'2026-07-13 07:57:26'),(27,'maternal','Tareas',10.00,2,0,1,'2026-07-13 07:57:26'),(28,'maternal','Participación',10.00,3,0,1,'2026-07-13 07:57:26'),(29,'maternal','Evaluación Parcial',10.00,4,0,1,'2026-07-13 07:57:26'),(30,'maternal','Proyecto',10.00,5,0,1,'2026-07-13 07:57:26'),(31,'maternal','Trabajo y Exposiciones',10.00,6,0,1,'2026-07-13 07:57:26');
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
) ENGINE=InnoDB AUTO_INCREMENT=1184 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `grados_materias`
--

LOCK TABLES `grados_materias` WRITE;
/*!40000 ALTER TABLE `grados_materias` DISABLE KEYS */;
INSERT INTO `grados_materias` VALUES (293,'primaria',6,14,4,0,1),(294,'primaria',6,3,1,0,1),(295,'primaria',6,10,2,0,1),(791,'secundaria',1,300,2,1,1),(792,'secundaria',2,300,2,2,1),(793,'secundaria',3,300,2,3,1),(794,'secundaria',1,301,2,4,1),(795,'secundaria',2,301,2,5,1),(796,'secundaria',3,301,2,6,1),(797,'secundaria',1,302,2,7,1),(798,'secundaria',2,302,2,8,1),(799,'secundaria',3,302,2,9,1),(800,'primaria',5,299,NULL,1,1),(801,'primaria',6,299,NULL,2,1),(878,'primaria',2,1,1,7,1),(890,'primaria',2,9,2,1,1),(891,'primaria',2,14,4,2,1),(892,'primaria',2,13,3,3,1),(893,'primaria',2,3,NULL,4,1),(894,'primaria',2,11,3,5,1),(895,'primaria',2,12,3,6,1),(896,'primaria',2,5,2,8,1),(897,'primaria',2,16,4,9,1),(898,'primaria',2,10,2,10,1),(899,'primaria',2,15,4,11,1),(900,'primaria',2,4,1,21,1),(1026,'primaria',2,27,1,22,1),(1027,'primaria',2,28,1,23,1),(1028,'primaria',3,4,1,21,1),(1029,'primaria',3,27,1,22,1),(1030,'primaria',3,28,1,23,1),(1031,'primaria',4,4,1,21,1),(1032,'primaria',4,27,1,22,1),(1033,'primaria',4,28,1,23,1),(1034,'primaria',5,4,1,21,1),(1035,'primaria',5,27,1,22,1),(1036,'primaria',5,29,1,24,1),(1037,'primaria',6,4,1,21,1),(1038,'primaria',6,27,1,22,1),(1039,'primaria',6,29,1,24,1),(1040,'secundaria',1,27,1,22,1),(1041,'secundaria',1,29,1,24,1),(1042,'secundaria',2,27,1,22,1),(1043,'secundaria',2,29,1,24,1),(1044,'secundaria',3,27,1,22,1),(1045,'secundaria',3,29,1,24,1),(1160,'primaria',1,13,3,7,1),(1161,'primaria',1,1,1,1,1),(1162,'primaria',1,5,2,4,1),(1163,'primaria',1,16,4,10,1),(1164,'primaria',1,15,4,9,1),(1165,'primaria',1,9,2,5,1),(1166,'primaria',1,282,1,14,1),(1167,'primaria',1,279,1,11,1),(1168,'primaria',1,280,1,12,1),(1169,'primaria',1,288,1,17,1),(1170,'primaria',1,278,1,10,1),(1171,'primaria',1,286,1,16,1),(1172,'primaria',1,285,1,15,1),(1173,'primaria',1,281,1,13,1),(1174,'primaria',1,4,1,21,1),(1175,'primaria',1,28,1,23,1),(1176,'primaria',1,27,1,22,1),(1177,'primaria',1,14,4,8,1),(1178,'primaria',1,10,2,6,1),(1179,'primaria',1,297,NULL,19,1),(1180,'primaria',1,298,NULL,20,1);
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

-- Dump completed on 2026-07-13 13:46:28
