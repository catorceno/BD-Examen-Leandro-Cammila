USE Gym

-- 1.
INSERT INTO CLIENTE (Nombre, Apellido, Telefono)
VALUES
	('Juan', 'P�rez', 123456789),
	('Mar�a', 'L�pez', 987654321),
	('Carlos', 'G�mez', 654123987),
	('Ana', 'Torres', 321654987),
	('Luis', 'Hern�ndez', 741852963),
	('Marta', 'Rodr�guez', 852963741),
	('Pedro', 'Mart�nez', 963852741),
	('Laura', 'Jim�nez', 147258369),
	('Sof�a', 'Gonz�lez', 369852147),
	('Diego', 'Fern�ndez', 258963147), --10
	('Luc�a', 'Morales', 111222333),
	('Tom�s', 'Vargas', 222333444),
	('Valentina', 'Silva', 333444555),
	('Emiliano', 'Ramos', 444555666),
	('Camila', 'Navarro', 555666777),
	('Gabriel', 'Castro', 666777888),
	('Renata', 'Figueroa', 777888999),
	('Mateo', 'Reyes', 888999000),
	('Isidora', 'Paredes', 999000111),
	('Agust�n', 'Pe�a', 101112131), --20
	('Florencia', 'Mora', 121314151),
	('Benjam�n', 'Ruiz', 131415161),
	('Josefina', 'Salinas', 141516171),
	('Mart�n', 'Acu�a', 151617181),
	('Antonia', 'Carrillo', 161718191),
	('Dami�n', 'Ortega', 171819201),
	('Amanda', 'Fuentes', 181920211),
	('Vicente', 'Gallardo', 192021221),
	('Fernanda', 'Pino', 202122232),
	('Le�n', 'Mendoza', 212223242), --30
	('Jose', 'Araya', 222324252),
	('Mariana', 'C�ceres', 232425262),
	('Iker', 'Soto', 242526272),
	('Amelia', 'Meza', 252627282),
	('Juli�n', 'Vergara', 262728292),
	('Bianca', 'Espinoza', 272829303),
	('Crist�bal', 'Vald�s', 282930313),
	('Emilia', 'Zamora', 293031323),
	('Santiago', 'Olivares', 303132333),
	('M�a', 'Aguilera', 313233343); --40
SELECT * FROM CLIENTE

-- 2.
INSERT INTO SERVICIO (Nombre, HoraInicio, HoraFin)
VALUES 
	('Pesas', '06:00:00', '23:00:00'), 
	('Cardio', '06:00:00', '23:00:00'),
	('Boxeo', '17:00:00', '19:00:00'),
	('Zumba', '17:00:00', '19:00:00')
SELECT * FROM SERVICIO 

-- 3.
INSERT INTO INSCRIPCION (ClienteID, CantidadMeses, FechaInicio)
VALUES 
	(1, 1, '2024-01-05'),
	(2, 1, '2024-02-10'),
	(3, 1, '2024-03-15'),
	(4, 1, '2024-04-20'),
	(5, 1, '2024-05-25'),
	(6, 1, '2024-06-01'),
	(7, 1, '2024-07-10'),
	(8, 1, '2024-08-15'),
	(9, 1, '2024-09-20'),
	(10, 1, '2024-10-05'),
	(11, 1, '2024-11-10'),
	(12, 1, '2024-11-15'),
	(13, 1, '2024-11-20'),
	(14, 1, '2024-11-25'),
	(15, 1, '2024-11-30'),
	(16, 1, '2024-12-05'),
	(17, 1, '2024-12-10'),
	(18, 1, '2024-12-15'),
	(19, 1, '2024-12-20'),
	(20, 1, '2024-12-25'),
	(21, 1, '2025-01-01'),
	(22, 1, '2025-01-05'),
	(23, 1, '2025-01-10'),
	(24, 1, '2025-01-15'),
	(25, 1, '2025-01-20'),
	(26, 1, '2025-01-25'),
	(27, 1, '2025-01-30'),
	(28, 1, '2025-02-04'),
	(29, 1, '2025-02-09'),
	(30, 1, '2025-02-14'),
	(31, 1, '2025-02-19'),
	(32, 1, '2025-02-24'),
	(33, 1, '2025-03-01'),
	(34, 1, '2025-03-06'),
	(35, 1, '2025-03-11'),
	(36, 1, '2025-03-16'),
	(37, 1, '2025-03-21'),
	(38, 1, '2025-03-26'),
	(39, 1, '2025-03-31'),
	(40, 1, '2025-04-03');
SELECT * FROM INSCRIPCION

-- 4.
INSERT INTO PAGOS (InscripcionID, Fecha, Total, DescuentoID, TotalFinal)
VALUES 
	(1, '2024-01-05', 250, NULL, 250),
	(2, '2024-02-10', 250, NULL, 250),
	(3, '2024-03-15', 250, NULL, 250),
	(4, '2024-04-20', 250, NULL, 250),
	(5, '2024-05-25', 250, NULL, 250),
	(6, '2024-06-01', 250, NULL, 250),
	(7, '2024-07-10', 250, NULL, 250),
	(8, '2024-08-15', 250, NULL, 250),
	(9, '2024-09-20', 250, NULL, 250),
	(10, '2024-10-05', 250, NULL, 250),
	(11, '2024-11-10', 250, NULL, 250),
	(12, '2024-11-15', 250, NULL, 250),
	(13, '2024-11-20', 250, NULL, 250),
	(14, '2024-11-25', 250, NULL, 250),
	(15, '2024-11-30', 250, NULL, 250),
	(16, '2024-12-05', 250, NULL, 250),
	(17, '2024-12-10', 250, NULL, 250),
	(18, '2024-12-15', 250, NULL, 250),
	(19, '2024-12-20', 250, NULL, 250),
	(20, '2024-12-25', 250, NULL, 250),
	(21, '2025-01-01', 250, NULL, 250),
	(22, '2025-01-05', 250, NULL, 250),
	(23, '2025-01-10', 250, NULL, 250),
	(24, '2025-01-15', 250, NULL, 250),
	(25, '2025-01-20', 250, NULL, 250),
	(26, '2025-01-25', 250, NULL, 250),
	(27, '2025-01-30', 250, NULL, 250),
	(28, '2025-02-04', 250, NULL, 250),
	(29, '2025-02-09', 250, NULL, 250),
	(30, '2025-02-14', 250, NULL, 250),
	(31, '2025-02-19', 250, NULL, 250),
	(32, '2025-02-24', 250, NULL, 250),
	(33, '2025-03-01', 250, NULL, 250),
	(34, '2025-03-06', 250, NULL, 250),
	(35, '2025-03-11', 250, NULL, 250),
	(36, '2025-03-16', 250, NULL, 250),
	(37, '2025-03-21', 250, NULL, 250),
	(38, '2025-03-26', 250, NULL, 250),
	(39, '2025-03-31', 250, NULL, 250),
	(40, '2025-04-03', 250, NULL, 250);
SELECT * FROM PAGOS 

-- 5.
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
	(10, 2, '2024-10-06', '10:10:00'),
	(11, 1, '2024-11-11', '08:10:00'),
	(12, 2, '2024-11-16', '09:20:00'),
	(13, 3, '2024-11-21', '17:10:00'),
	(14, 4, '2024-11-26', '18:00:00'),
	(15, 1, '2024-12-01', '07:45:00'),
	(16, 2, '2024-12-06', '11:15:00'),
	(17, 3, '2024-12-11', '17:05:00'),
	(18, 4, '2024-12-16', '17:45:00'),
	(19, 1, '2024-12-21', '14:10:00'),
	(20, 2, '2024-12-26', '12:30:00'),
	(21, 3, '2025-01-02', '17:20:00'),
	(22, 4, '2025-01-06', '17:40:00'),
	(23, 1, '2025-01-11', '15:00:00'),
	(24, 2, '2025-01-16', '08:45:00'),
	(25, 3, '2025-01-21', '18:10:00'),
	(26, 4, '2025-01-26', '18:20:00'),
	(27, 1, '2025-01-31', '16:10:00'),
	(28, 2, '2025-02-05', '09:05:00'),
	(29, 3, '2025-02-10', '17:15:00'),
	(30, 4, '2025-02-15', '18:05:00'),
	(31, 1, '2025-02-20', '10:50:00'),
	(32, 2, '2025-02-25', '11:00:00'),
	(33, 3, '2025-03-02', '17:25:00'),
	(34, 4, '2025-03-07', '17:35:00'),
	(35, 1, '2025-03-12', '15:55:00'),
	(36, 2, '2025-03-17', '10:45:00'),
	(37, 3, '2025-03-22', '17:10:00'),
	(38, 4, '2025-03-27', '17:50:00'),
	(39, 1, '2025-04-01', '14:30:00'),
	(40, 2, '2025-04-04', '09:30:00');
SELECT * FROM ASISTENCIA 

-- 6.
INSERT INTO ENTRENADORES (ServicioID, Nombre, Apellido, Telefono, Correo, FechaInicio, Sueldo, Turno)
VALUES 
(1, 'Carlos', 'L�pez', 123789456, 'carlos@entrenador.com', '2023-01-01', 1500, 'Ma�ana'),
(2, 'Ana', 'Mart�nez', 987321654, 'ana@entrenador.com', '2023-02-01', 1600, 'Ma�ana'),
(1, 'Luis', 'Hern�ndez', 741963852, 'luis@entrenador.com', '2023-03-01', 1550, 'Tarde'),
(2, 'Marta', 'Torres', 852741963, 'marta@entrenador.com', '2023-04-01', 1400, 'Tarde'),
(3, 'Diego', 'Fern�ndez', 741852963, 'diego@entrenador.com', '2023-06-01', 1450, 'Tarde'),
(4, 'Laura', 'Jim�nez', 963852741, 'laura@entrenador.com', '2023-07-01', 1450, 'Tarde'),
(1, 'Pedro', 'Mart�nez', 852963741, 'pedro@entrenador.com', '2023-08-01', 1450, 'Noche'),
(2, 'Marta', 'Rodr�guez', 321654987, 'marta@entrenador.com', '2023-09-01', 1400, 'Noche')
SELECT * FROM ENTRENADORES

-- 7.
INSERT INTO INVENTARIO (Nombre, Cantidad, Estado, FechaAdquisicion, ServicioID)
VALUES
-- MAQUINAS PARA CARDIO
('Stepper', 3, 'En Uso', '2022-06-15', 2),  
('El�ptica', 10, 'En Uso', '2021-08-20', 2),  
('Bicicleta Est�tica', 10, 'En Uso', '2020-05-10', 2),  
('Caminadora', 10, 'Nuevo', '2023-02-01', 2),  
('M�quina Escalera', 4, 'En Uso', '2019-09-10', 2),
-- MAQUINAS DE PESAS
-- Maquinas Pecho
('Pres Inclinado', 2, 'En Uso', '2020-04-15', 3),  
('Pres Declinado', 2, 'En Uso', '2020-04-15', 3),  
('M�quina de Fondos Asistidos', 1, 'Nuevo', '2023-06-10', 3),  
('Pec Deck', 3, 'En Uso', '2021-03-12', 3),  
('Prensa de Pecho', 2, 'Nuevo', '2023-07-25', 3),
-- Maquinas Tr�ceps
('M�quina de Fondo de Tr�ceps', 2, 'En Uso', '2019-10-05', 3),  
('M�quina de Tr�ceps Sentado', 2, 'Nuevo', '2023-03-18', 3),  
('Extensi�n de Tr�ceps', 2, 'En Uso', '2021-07-22', 3),  
('M�quina de Tr�ceps en Polea', 4, 'En Uso', '2020-09-30', 3),  
-- Maquinas B�ceps
('M�quina de Extensi�n de Brazos', 2, 'Nuevo', '2022-12-14', 3),  
('Curl Predicador', 3, 'En Uso', '2021-05-30', 3),  
('Rack de Mancuernas', 3, 'En Uso', '2020-06-22', 3),  
('Rack de Barras', 3, 'Nuevo', '2023-08-15', 3),  
-- Maquinas Pierna
('M�quina Smith', 3, 'En Uso', '2020-12-10', 3),  
('Prensa de Pierna', 3, 'Nuevo', '2023-04-05', 3),  
('Extensiones', 3, 'En Uso', '2021-02-14', 3),  
('Sissy Squat', 3, 'En Uso', '2021-11-20', 3),  
('M�quina Patada de Gl�teo', 2, 'En Uso', '2019-05-10', 3),  
('M�quina de Hip Thrust', 3, 'Nuevo', '2023-01-20', 3),  
('M�quina Femoral', 3, 'En Uso', '2020-07-08', 3),  
-- Maquinas Espalda
('Lat Pulldown', 5, 'En Uso', '2019-12-10', 3),  
('M�quina de Remos', 5, 'En Uso', '2020-05-25', 3),  
('M�quina de Remo Sentado', 2, 'En Uso', '2021-09-18', 3),  
('M�quina de Remo Polea', 3, 'En Uso', '2020-06-30', 3),  
('M�quina de Pull Over', 3, 'En Uso', '2022-02-12', 3),  
('M�quina de Peso Muerto Asistido', 3, 'Nuevo', '2023-05-10', 3),  
-- Maquinas Hombro
('Prensa de Hombro', 2, 'En Uso', '2021-04-05', 3),  
('M�quina de Remo Alto', 2, 'En Uso', '2020-09-15', 3),  
('Shoulder Press Machine', 3, 'Nuevo', '2023-02-18', 3),  
('Lateral Raise Machine', 3, 'En Uso', '2021-08-22', 3),  
('Front Raise Machine', 3, 'Nuevo', '2023-06-05', 3),  
('Poleas Ajustables', 5, 'En Uso', '2020-03-11', 3),
-- MAQUINAS PARA BOXEO
('Pares de Guantes de Boxeo', 20, 'Nuevo', '2023-01-01', 4),  
('Saco de Boxeo Pesado', 4, 'En Uso', '2021-07-15', 4),  
('Escaladora o Stepper', 10, 'En Uso', '2020-05-10', 4),  
('Pera Locomotora', 5, 'En Uso', '2022-10-20', 4),  
('Manoplas de Entrenador', 10, 'Nuevo', '2023-03-25', 4), 
-- MAQUINAS PARA ZUMBA
('Parlantes JBL', 2, 'En Uso', '2021-06-15', 1);

INSERT INTO DESCUENTOS (Nombre, Porcentaje, FechaInicio, FechaFin)
VALUES
	('Cliente Frecuente', 15, '2025-01-01', '2025-06-30'),
	('Promoci�n A�o Nuevo', 20, '2024-01-01', '2025-01-31'),
	('Descuento Estudiantil', 25, '2025-02-01', '2025-04-30');

SELECT * FROM DESCUENTOS
