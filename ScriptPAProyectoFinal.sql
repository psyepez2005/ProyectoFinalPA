-- Crear el esquema si no existe
CREATE SCHEMA IF NOT EXISTS proyecto;
USE proyecto;

-- Crear tabla de universidades 
CREATE TABLE universidades (
  id_universidad INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(255) UNIQUE
);

-- Crear tabla de articulos
CREATE TABLE articulos (
  id_articulo INT AUTO_INCREMENT PRIMARY KEY,
  AÑO INT,
  TIPO TEXT,
  `NOMBRE UNIVERSIDAD` TEXT,
  `TIPO FINANCIAMIENTO` TEXT,
  `PROVINCIA UNIVERSIDAD` TEXT,
  `BASE DATOS INDEXADA` TEXT,
  `NOMBRE REVISTA` TEXT,
  `NOMBRE ARTICULO` TEXT,
  `CAMPO AMPLIO` TEXT,
  `CAMPO ESPECIFICO` TEXT,
  `CAMPO DETALLADO` TEXT,
  id_universidad INT,
  CONSTRAINT fk_articulo_universidad FOREIGN KEY (id_universidad) REFERENCES universidades(id_universidad)
);

-- Crear tabla de docentes
CREATE TABLE docentes (
  id_docente INT AUTO_INCREMENT PRIMARY KEY,
  AÑO INT,
  CODIGO_IES INT,
  NOMBRE_IES TEXT,
  SEXO TEXT,
  DISCAPACIDAD TEXT,
  ETNIA TEXT,
  NACIONALIDAD TEXT,
  NIVEL_FORMACION TEXT,
  RELACION_IES TEXT,
  TIEMPO_DEDICACION TEXT,
  NIVEL TEXT,
  GRADO TEXT,
  TOTAL INT,
  id_universidad INT,
  CONSTRAINT fk_docente_universidad FOREIGN KEY (id_universidad) REFERENCES universidades(id_universidad)
);

-- Crear tabla de matriculas
CREATE TABLE matriculas (
  id_matricula INT AUTO_INCREMENT PRIMARY KEY,
  AÑO INT,
  NOMBRE_IES TEXT,
  TIPO_FINANCIAMIENTO TEXT,
  NOMBRE_CARRERA TEXT,
  NIVEL_FORMACION TEXT,
  MODALIDAD TEXT,
  CAMPO_AMPLIO TEXT,
  CAMPO_ESPECIFICO TEXT,
  CAMPO_DETALLADO TEXT,
  TIPO_SEDE TEXT,
  PROVINCIA_SEDE TEXT,
  CANTON_SEDE TEXT,
  SEXO TEXT,
  ETNIA TEXT,
  PUEBLO_NACIONALIDAD TEXT,
  DISCAPACIDAD TEXT,
  PROVINCIA_RESIDENCIA TEXT,
  CANTON_RESIDENCIA TEXT,
  TOTAL INT,
  id_universidad INT,
  CONSTRAINT fk_matricula_universidad FOREIGN KEY (id_universidad) REFERENCES universidades(id_universidad)
);

-- Insertar universidades únicas normalizadas
INSERT INTO universidades (nombre)
SELECT DISTINCT UPPER(TRIM(`NOMBRE_IES`)) FROM docentes
UNION
SELECT DISTINCT UPPER(TRIM(`NOMBRE UNIVERSIDAD`)) FROM articulos
UNION
SELECT DISTINCT UPPER(TRIM(`NOMBRE_IES`)) FROM matriculas;

-- Asignar ID universidad a docentes
UPDATE docentes d
JOIN universidades u ON UPPER(TRIM(d.NOMBRE_IES)) = u.nombre
SET d.id_universidad = u.id_universidad;

-- Asignar ID universidad a articulos
UPDATE articulos a
JOIN universidades u ON UPPER(TRIM(a.`NOMBRE UNIVERSIDAD`)) = u.nombre
SET a.id_universidad = u.id_universidad;

-- Asignar ID universidad a matriculas
UPDATE matriculas m
JOIN universidades u ON UPPER(TRIM(m.NOMBRE_IES)) = u.nombre
SET m.id_universidad = u.id_universidad;

-- Verificación de registros no asignados
SELECT COUNT(*) AS docentes_sin_universidad FROM docentes WHERE id_universidad IS NULL;
SELECT COUNT(*) AS articulos_sin_universidad FROM articulos WHERE id_universidad IS NULL;
SELECT COUNT(*) AS matriculas_sin_universidad FROM matriculas WHERE id_universidad IS NULL;


-- Quitar el modo seguro
SET SQL_SAFE_UPDATES = 0;
 
 -- Seleccionar todos los datos de las tablas 
 SELECT * FROM articulos;

 SELECT total FROM docentes;

 SELECT * FROM matriculas;
 
 SELECT * FROM universidades;
 
 
 SHOW VARIABLES LIKE 'secure_file_priv';
 
 -- Muestra el nivel de formación por docentes de cada universidad 
SELECT 
  u.nombre AS universidad, 
  d.NIVEL_FORMACION, 
  SUM(d.TOTAL) AS total_docentes
FROM docentes d
JOIN universidades u ON d.id_universidad = u.id_universidad
GROUP BY u.nombre, d.NIVEL_FORMACION
ORDER BY total_docentes DESC;

-- Muestra el promedio de matriculados por sexo de cada provincia
SELECT 
  m.PROVINCIA_SEDE, 
  m.SEXO, 
  AVG(m.TOTAL) AS promedio_matriculados
FROM matriculas m
GROUP BY m.PROVINCIA_SEDE, m.SEXO
ORDER BY promedio_matriculados DESC;

-- Muestra cuantos articulos tiene cada universidad
SELECT 
  u.nombre AS universidad, 
  a.`BASE DATOS INDEXADA`, 
  COUNT(*) AS total_articulos
FROM articulos a
JOIN universidades u ON a.id_universidad = u.id_universidad
GROUP BY u.nombre, a.`BASE DATOS INDEXADA`
ORDER BY total_articulos DESC;

-- Muestra las matriculas por etnias
SELECT 
  ETNIA, 
  SUM(TOTAL) AS total_matriculados
FROM matriculas
GROUP BY ETNIA
ORDER BY total_matriculados DESC;

-- Mostrar un conteo de todos los docentes hombres y mujeres ordenados por año
SELECT 
  `AÑO`, 
  SUM(CASE WHEN UPPER(TRIM(SEXO)) = 'hombre' THEN TOTAL ELSE 0 END) AS total_hombres,
  SUM(CASE WHEN UPPER(TRIM(SEXO)) = 'mujer' THEN TOTAL ELSE 0 END) AS total_mujeres
FROM docentes
GROUP BY `AÑO`
ORDER BY `AÑO`
