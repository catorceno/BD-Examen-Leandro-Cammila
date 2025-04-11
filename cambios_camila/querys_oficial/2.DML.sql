USE Gym;
GO

-- 1.Clientes
INSERT INTO CLIENTES (CI, Nombre, Apellido, Telefono)
VALUES
	(12345678, 'Juan', 'Pérez', 76543210),
	(23456789, 'Ana', 'Martínez', 75432109),
	(34567890, 'Carlos', 'López', 74321098),
	(45678901, 'Laura', 'González', 73210987),
	(56789012, 'Diego', 'Fernández', 72109876),
	(67890123, 'Marta', 'Rodríguez', 71098765),
	(78901234, 'Pedro', 'Hernández', 70987654),
	(89012345, 'Luis', 'Torres', 69876543),
	(90123456, 'Elena', 'Jiménez', 68765432),
	(91234567, 'Fernando', 'Vargas', 67654321),
	(10234567, 'Gloria', 'Castro', 66543210);
SELECT * FROM CLIENTES;

-- 2.Servicios
INSERT INTO SERVICIOS(Nombre, HoraInicio, HoraFin)
VALUES 
	('Pesas', '06:00:00', '23:00:00'), 
	('Cardio', '06:00:00', '23:00:00'),
	('Boxeo', '17:00:00', '19:00:00'),
	('Zumba', '17:00:00', '19:00:00');
SELECT * FROM SERVICIOS

-- 3.Descuentos
INSERT INTO DESCUENTOS (Nombre, Porcentaje, FechaInicio, FechaFin)
VALUES
	('Cliente Frecuente', 15, '2025-01-01', '2025-06-30'),
	('Promoción Año Nuevo', 20, '2024-01-01', '2025-01-31'),
	('Descuento Estudiantil', 25, '2025-02-01', '2025-04-30');
SELECT * FROM DESCUENTOS

-- 4.Inscripcion
INSERT INTO INSCRIPCION (ClienteID, CantidadMeses, FechaInicio, DescuentoID)
VALUES
	(1, 3, '2025-01-01', NULL),
	(2, 6, '2025-02-15', 1),
	(3, 12, '2025-03-10', NULL),
	(4, 9, '2025-04-01', 2),
	(5, 1, '2025-05-20', NULL),
	(6, 2, '2025-06-05', 3),
	(7, 8, '2025-07-15', NULL),
	(8, 5, '2025-08-10', 1),
	(9, 11, '2025-09-05', NULL),
	(10, 4, '2025-10-01', 3);
SELECT * FROM INSCRIPCION;

-- 5.Inventario
INSERT INTO INVENTARIO (Nombre, Cantidad, Estado, FechaAdquisicion, ServicioID)
VALUES
	('Stepper', 3, 'En Uso', '2022-06-15', 2),  
	('Elíptica', 10, 'En Uso', '2021-08-20', 2),  
	('Bicicleta Estática', 10, 'En Uso', '2020-05-10', 2),  
	('Caminadora', 10, 'Nuevo', '2023-02-01', 2),  
	('Máquina Escalera', 4, 'En Uso', '2019-09-10', 2);  

-- MAQUINAS DE PESAS
INSERT INTO INVENTARIO (Nombre, Cantidad, Estado, FechaAdquisicion, ServicioID)
VALUES
-- Maquinas Pecho
('Pres Inclinado', 2, 'En Uso', '2020-04-15', 3),  
('Pres Declinado', 2, 'En Uso', '2020-04-15', 3),  
('Máquina de Fondos Asistidos', 1, 'Nuevo', '2023-06-10', 3),  
('Pec Deck', 3, 'En Uso', '2021-03-12', 3),  
('Prensa de Pecho', 2, 'Nuevo', '2023-07-25', 3),

-- Maquinas Tríceps
('Máquina de Fondo de Tríceps', 2, 'En Uso', '2019-10-05', 3),  
('Máquina de Tríceps Sentado', 2, 'Nuevo', '2023-03-18', 3),  
('Extensión de Tríceps', 2, 'En Uso', '2021-07-22', 3),  
('Máquina de Tríceps en Polea', 4, 'En Uso', '2020-09-30', 3),  

-- Maquinas Bíceps
('Máquina de Extensión de Brazos', 2, 'Nuevo', '2022-12-14', 3),  
('Curl Predicador', 3, 'En Uso', '2021-05-30', 3),  
('Rack de Mancuernas', 3, 'En Uso', '2020-06-22', 3),  
('Rack de Barras', 3, 'Nuevo', '2023-08-15', 3),  

-- Maquinas Pierna
('Máquina Smith', 3, 'En Uso', '2020-12-10', 3),  
('Prensa de Pierna', 3, 'Nuevo', '2023-04-05', 3),  
('Extensiones', 3, 'En Uso', '2021-02-14', 3),  
('Sissy Squat', 3, 'En Uso', '2021-11-20', 3),  
('Máquina Patada de Glúteo', 2, 'En Uso', '2019-05-10', 3),  
('Máquina de Hip Thrust', 3, 'Nuevo', '2023-01-20', 3),  
('Máquina Femoral', 3, 'En Uso', '2020-07-08', 3),  

-- Maquinas Espalda
('Lat Pulldown', 5, 'En Uso', '2019-12-10', 3),  
('Máquina de Remos', 5, 'En Uso', '2020-05-25', 3),  
('Máquina de Remo Sentado', 2, 'En Uso', '2021-09-18', 3),  
('Máquina de Remo Polea', 3, 'En Uso', '2020-06-30', 3),  
('Máquina de Pull Over', 3, 'En Uso', '2022-02-12', 3),  
('Máquina de Peso Muerto Asistido', 3, 'Nuevo', '2023-05-10', 3),  

-- Maquinas Hombro
('Prensa de Hombro', 2, 'En Uso', '2021-04-05', 3),  
('Máquina de Remo Alto', 2, 'En Uso', '2020-09-15', 3),  
('Shoulder Press Machine', 3, 'Nuevo', '2023-02-18', 3),  
('Lateral Raise Machine', 3, 'En Uso', '2021-08-22', 3),  
('Front Raise Machine', 3, 'Nuevo', '2023-06-05', 3),  
('Poleas Ajustables', 5, 'En Uso', '2020-03-11', 3);  

-- MAQUINAS PARA BOXEO
INSERT INTO INVENTARIO (Nombre, Cantidad, Estado, FechaAdquisicion, ServicioID)
VALUES
	('Pares de Guantes de Boxeo', 20, 'Nuevo', '2023-01-01', 4),  
	('Saco de Boxeo Pesado', 4, 'En Uso', '2021-07-15', 4),  
	('Escaladora o Stepper', 10, 'En Uso', '2020-05-10', 4),  
	('Pera Locomotora', 5, 'En Uso', '2022-10-20', 4),  
	('Manoplas de Entrenador', 10, 'Nuevo', '2023-03-25', 4);  

-- MAQUINAS PARA ZUMBA
INSERT INTO INVENTARIO (Nombre, Cantidad, Estado, FechaAdquisicion, ServicioID)
VALUES
	('Parlantes JBL', 2, 'En Uso', '2021-06-15', 1);
SELECT * FROM INVENTARIO

-- 6.Entrenadores
INSERT INTO ENTRENADORES (ServicioID, CI, Nombre, Apellido, Telefono, FechaInicio, Sueldo, Turno) 
VALUES 
	(1, 14320145, 'Carlos', 'López', 31234567, '2023-01-01', 1500, 'Mañana'),
	(2, 15234897, 'Ana', 'Martínez', 34567890, '2023-02-01', 1600, 'Mañana'),
	(1, 20771568, 'Luis', 'Hernández', 37894567, '2023-03-01', 1550, 'Tarde'),
	(2, 10254712, 'Marta', 'Torres', 38912345, '2023-04-01', 1400, 'Tarde'),
	(3, 54891023, 'Diego', 'Fernández', 41234567, '2023-06-01', 1450, 'Tarde'),
	(4, 10457812, 'Laura', 'Jiménez', 45678901, '2023-07-01', 1450, 'Tarde'),
	(1, 10236478, 'Pedro', 'Martínez', 47812345, '2023-08-01', 1450, 'Noche'),
	(2, 11554936, 'Marta', 'Rodríguez', 48956789, '2023-09-01', 1400, 'Noche');
SELECT * FROM ENTRENADORES;

-- 7.Asistencia

INSERT INTO ASISTENCIA (InscripcionID, ServicioID, Fecha, HoraIngreso) 
VALUES 
    (1, 1, '2024-01-06', '15:15:00'),
    (2, 2, '2024-02-11', '10:20:00'),
    (3, 3, '2024-03-16', '17:02:00'),
    (4, 4, '2024-04-21', '17:30:00'),
    (5, 1, '2024-05-26', '15:35:00'),
    (6, 2, '2024-06-02', '10:25:00'),
    (7, 3, '2024-07-11', '17:05:00'),
    (8, 4, '2024-08-16', '17:00:00'),
    (9, 1, '2024-09-21', '07:55:00'),
    (10, 2, '2024-10-06', '10:10:00');
SELECT * FROM ASISTENCIA

-- 8.Pagos
INSERT INTO PAGOS (InscripcionID, Fecha, Monto) 
VALUES
    (1, '2025-04-01', 1500),
    (2, '2025-04-02', 750),
    (3, '2025-04-03', 3000),
    (4, '2025-04-04', 2250),
    (5, '2025-04-05', 1200),
    (6, '2025-04-06', 900),
    (7, '2025-04-07', 800),
    (8, '2025-04-08', 2500),
    (9, '2025-04-09', 1700),
    (10, '2025-04-10', 2000);
SELECT * FROM PAGOS