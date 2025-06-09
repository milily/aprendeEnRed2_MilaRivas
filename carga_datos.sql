-- Poblar tabla: estados_inscripcion
INSERT INTO estados_inscripcion (nombre) VALUES
('inscrito'),
('en_progreso'),
('completado'),
('cancelado');

-- Poblar tabla: profesores
INSERT INTO profesores (nombre, email, especialidad, fecha_ingreso) VALUES
('Ana García', 'ana.garcia@aprendeenred.com', 'Matemáticas', '2022-01-10'),
('Luis Torres', 'luis.torres@aprendeenred.com', 'Programación', '2021-09-15'),
('Carla Méndez', 'carla.mendez@aprendeenred.com', 'Historia', '2020-03-22');

-- Poblar tabla: materias
INSERT INTO materias (nombre, descripcion) VALUES
('Álgebra Básica', 'Fundamentos del álgebra para estudiantes principiantes'),
('Programación en Python', 'Curso introductorio a Python y lógica de programación'),
('Historia Contemporánea', 'Estudio de los eventos globales del siglo XX');

-- Poblar tabla: profesor_materia
INSERT INTO profesor_materia (profesor_id, materia_id) VALUES
(1, 1), -- Ana enseña Álgebra
(2, 2), -- Luis enseña Python
(3, 3), -- Carla enseña Historia
(2, 1); -- Luis también enseña Álgebra

-- Poblar tabla: cursos
INSERT INTO cursos (titulo, descripcion, materia_id, fecha_inicio, fecha_fin) VALUES
('Álgebra Nivel 1', 'Curso de introducción al álgebra', 1, '2024-02-01', '2024-04-30'),
('Álgebra Nivel 2', 'Curso intermedio de álgebra', 1, '2024-05-01', '2024-07-31'),
('Python para Principiantes', 'Aprende Python desde cero', 2, '2024-01-15', '2024-03-15'),
('Python Avanzado', 'Temas avanzados de Python', 2, '2024-04-01', '2024-06-30'),
('Historia del Siglo XX', 'Guerras, revoluciones y cambios sociales', 3, '2024-03-01', '2024-05-31');

-- Poblar tabla: estudiantes
INSERT INTO estudiantes (nombre, email, fecha_registro, activo) VALUES
('María López', 'maria.lopez@correo.com', '2024-01-05', 1),
('Juan Pérez', 'juan.perez@correo.com', '2024-01-10', 1),
('Laura Sánchez', 'laura.sanchez@correo.com', '2024-01-15', 1),
('Pedro Fernández', 'pedro.fernandez@correo.com', '2024-01-20', 1),
('Sofía Gómez', 'sofia.gomez@correo.com', '2024-01-25', 1),
('Andrés Ruiz', 'andres.ruiz@correo.com', '2024-01-30', 0),
('Carmen Díaz', 'carmen.diaz@correo.com', '2024-02-01', 1),
('Diego Castro', 'diego.castro@correo.com', '2024-02-05', 1),
('Valeria Romero', 'valeria.romero@correo.com', '2024-02-10', 1),
('Tomás Herrera', 'tomas.herrera@correo.com', '2024-02-15', 1);

-- Poblar tabla: inscripciones
INSERT INTO inscripciones (estudiante_id, curso_id, fecha_inscripcion, estado_id) VALUES
(1, 1, '2024-02-01', 1), -- inscrito
(2, 1, '2024-02-02', 2), -- en progreso
(3, 2, '2024-05-01', 1),
(4, 3, '2024-01-20', 3), -- completado
(5, 3, '2024-01-21', 2),
(6, 4, '2024-04-01', 1),
(7, 5, '2024-03-01', 1),
(8, 5, '2024-03-02', 1),
(9, 2, '2024-05-02', 4), -- cancelado
(10, 4, '2024-04-03', 1);

-- Usuarios
INSERT INTO usuarios (email, password_hash, rol) VALUES
('admin@plataforma.com', 'hashadmin', 'admin'),
('maria.lopez@correo.com', 'hash123', 'estudiante'),
('luis.torres@aprendeenred.com', 'hash456', 'profesor');

-- Pagos
INSERT INTO pagos (inscripcion_id, monto, fecha_pago, metodo_pago) VALUES
(1, 100.00, '2024-02-02', 'tarjeta'),
(2, 100.00, '2024-02-03', 'transferencia'),
(3, 120.00, '2024-05-02', 'tarjeta');

-- Certificados (uno manual como ejemplo)
INSERT INTO certificados (estudiante_id, curso_id, fecha_emision, codigo_certificado) VALUES
(4, 3, '2024-03-01', 'CERT-4-3-20240301');
