-- Crear base de datos
CREATE DATABASE aprende_en_red;

-- Usar la base de datos
USE aprende_en_red;

-- Tabla: estudiantes
CREATE TABLE estudiantes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    fecha_registro DATE NOT NULL,
    activo TINYINT(1) DEFAULT 1
);

-- Tabla: profesores
CREATE TABLE profesores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    especialidad VARCHAR(100),
    fecha_ingreso DATE
);

-- Tabla: materias (normalizada, sin FK directa)
CREATE TABLE materias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(1000)
);

-- Tabla intermedia: profesor_materia
CREATE TABLE profesor_materia (
    profesor_id INT NOT NULL,
    materia_id INT NOT NULL,
    PRIMARY KEY (profesor_id, materia_id),
    FOREIGN KEY (profesor_id) REFERENCES profesores(id),
    FOREIGN KEY (materia_id) REFERENCES materias(id)
);

-- Tabla: cursos
CREATE TABLE cursos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    descripcion VARCHAR(1000),
    materia_id INT NOT NULL,
    fecha_inicio DATE,
    fecha_fin DATE,
    FOREIGN KEY (materia_id) REFERENCES materias(id)
);

-- Tabla: estados_inscripcion
CREATE TABLE estados_inscripcion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL UNIQUE
);

-- Tabla: inscripciones
CREATE TABLE inscripciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    estudiante_id INT NOT NULL,
    curso_id INT NOT NULL,
    fecha_inscripcion DATE NOT NULL,
    estado_id INT,
    FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id),
    FOREIGN KEY (curso_id) REFERENCES cursos(id),
    FOREIGN KEY (estado_id) REFERENCES estados_inscripcion(id),
    UNIQUE(estudiante_id, curso_id)
);

-- Tabla: pagos
CREATE TABLE pagos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    inscripcion_id INT NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    fecha_pago DATE NOT NULL,
    metodo_pago VARCHAR(50),
    FOREIGN KEY (inscripcion_id) REFERENCES inscripciones(id)
);

-- Tabla: certificados
CREATE TABLE certificados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    estudiante_id INT NOT NULL,
    curso_id INT NOT NULL,
    fecha_emision DATE NOT NULL,
    codigo_certificado VARCHAR(100) UNIQUE,
    FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id),
    FOREIGN KEY (curso_id) REFERENCES cursos(id)
);

-- Tabla: usuarios
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    rol ENUM('admin','estudiante','profesor') DEFAULT 'estudiante'
);


-- ========================================
-- VISTAS
-- ========================================

-- Vista: vista_estudiantes_inscripciones
CREATE VIEW vista_estudiantes_inscripciones AS
SELECT 
  e.nombre AS estudiante,
  c.titulo AS curso,
  ei.nombre AS estado,
  i.fecha_inscripcion
FROM inscripciones i
JOIN estudiantes e ON e.id = i.estudiante_id
JOIN cursos c ON c.id = i.curso_id
JOIN estados_inscripcion ei ON ei.id = i.estado_id;

-- Vista: vista_cursos_materias
CREATE VIEW vista_cursos_materias AS
SELECT 
  c.titulo,
  c.descripcion,
  m.nombre AS materia,
  m.descripcion AS descripcion_materia,
  p.nombre AS profesor
FROM cursos c
JOIN materias m ON m.id = c.materia_id
JOIN profesor_materia pm ON pm.materia_id = m.id
JOIN profesores p ON p.id = pm.profesor_id;

-- Vista: vista_pagado_por_estudiante
CREATE VIEW vista_pagado_por_estudiante AS
SELECT 
  e.nombre AS estudiante,
  SUM(p.monto) AS total_pagado
FROM pagos p
JOIN inscripciones i ON p.inscripcion_id = i.id
JOIN estudiantes e ON i.estudiante_id = e.id
GROUP BY e.nombre;

-- Vista: vista_certificados_emitidos
CREATE VIEW vista_certificados_emitidos AS
SELECT 
  e.nombre AS estudiante,
  c.titulo AS curso,
  cert.fecha_emision,
  cert.codigo_certificado
FROM certificados cert
JOIN estudiantes e ON e.id = cert.estudiante_id
JOIN cursos c ON c.id = cert.curso_id;

-- Vista: vista_usuarios_roles
CREATE VIEW vista_usuarios_roles AS
SELECT 
  email,
  rol
FROM usuarios;

-- ========================================
-- FUNCIONES
-- ========================================

DELIMITER //
CREATE FUNCTION obtener_cantidad_inscripciones_por_estudiante(id_est INT)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total
  FROM inscripciones
  WHERE estudiante_id = id_est;
  RETURN total;
END;
//
DELIMITER ;

DELIMITER //
CREATE FUNCTION obtener_total_pagado_por_estudiante(est_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  DECLARE total DECIMAL(10,2);
  SELECT SUM(p.monto)
  INTO total
  FROM pagos p
  JOIN inscripciones i ON i.id = p.inscripcion_id
  WHERE i.estudiante_id = est_id;
  RETURN IFNULL(total, 0.00);
END;
//
DELIMITER ;

-- ========================================
-- STORED PROCEDURES
-- ========================================

DELIMITER //
CREATE PROCEDURE sp_actualizar_estado_inscripcion(
  IN insc_id INT,
  IN nuevo_estado INT
)
BEGIN
  UPDATE inscripciones
  SET estado_id = nuevo_estado
  WHERE id = insc_id;
END;
//
DELIMITER ;

-- ========================================
-- TRIGGERS
-- ========================================

DELIMITER //
CREATE TRIGGER trg_evitar_doble_inscripcion
BEFORE INSERT ON inscripciones
FOR EACH ROW
BEGIN
  IF EXISTS (
    SELECT 1 FROM inscripciones
    WHERE estudiante_id = NEW.estudiante_id
      AND curso_id = NEW.curso_id
  ) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'El estudiante ya está inscrito en este curso';
  END IF;
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_generar_certificado
AFTER UPDATE ON inscripciones
FOR EACH ROW
BEGIN
  IF NEW.estado_id = 3 AND OLD.estado_id != 3 THEN
    INSERT INTO certificados (estudiante_id, curso_id, fecha_emision, codigo_certificado)
    VALUES (
      NEW.estudiante_id,
      NEW.curso_id,
      CURDATE(),
      CONCAT('CERT-', NEW.estudiante_id, '-', NEW.curso_id, '-', DATE_FORMAT(CURDATE(),'%Y%m%d'))
    );
  END IF;
END;
//
DELIMITER ;

