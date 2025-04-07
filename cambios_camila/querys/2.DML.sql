USE Gym

-- 1.Clientes
INSERT INTO CLIENTES(CI, Nombre, Apellido, Telefono)
VALUES ();
GO
SELECT * FROM CLIENTES;

-- 2.Servicios
INSERT INTO SERVICIOS(Nombre, HoraInicio, HoraFin)
VALUES ();
GO
SELECT * FROM SERVICIOS;

-- 3.Descuentos
INSERT INTO DESCUENTOS(Nombre, Porcentaje, FechaInicio, FechaFin)
VALUES ();
GO
SELECT * FROM DESCUENTOS;

-- revisar que los ID referenciados existan en su tabla correspondiente, consistencia de los datos y revisar las opciones disponibles y condiciones en columnas con CHECK
-- 4.Inscripcion
INSERT INTO INSCRIPCION(ClienteID, CantidadMeses, FechaInicio, DescuentoID)
VALUES ();
GO
SELECT * FROM INSCRIPCION;

-- 5.Inventario
INSERT INTO INVENTARIO(ServicioID, Nombre, Cantidad, Estado, FechaAdquision)
VALUES ();
GO
SELECT * FROM INVENTARIO;

-- 6.Entrenadores
INSERT INTO ENTRENADORES(ServicioID, CI, Nombre, Apellido, Telefono, FechaInicio, Sueldo, Turno, Estado) -- FechaFin no se incluye porque no hay entrenadores depedidos
VALUES ();
GO
SELECT * FROM ENTRENADORES;

-- 7.Asistencia
INSERT INTO ASISTENCIA(InscripcionID, ServicioID, Fecha, HoraIngreso)
VALUES ();
GO
SELECT * FROM ASISTENCIA;

-- 8.Pagos
INSERT INTO PAGOS(InscripcionID, Fecha, Monto)
VALUES ();
GO
SELECT * FROM PAGOS;

/*
RESUMEN DE CHECKS POR TABLA
--1.
CI		  > 0
Telefono  between 30000000 AND 79999999

--2.
HoraInicio between '06:00:00' AND '23:00:00'
HoraFin    between '06:00:00' AND '23:00:00' AND HoraFin > HoraInicio

--3.
FechaFin   > FechaInicio
*(Estado es DEFAULT activo)

--4.
CantidadMeses between  1 AND 12
*(DescuentoID puede ser NULL)

--5.
Cantidad > 0
Estado IN ('Nuevo', 'En Uso', 'Mantenimiento', 'Mal Estado', 'Descontinuado')

--6.
CI > 0
Telefono  between 30000000 AND 79999999
FechaFin > FechaInicio

--7.
HoraIngreso between '06:00:00' AND '23:00:00'

--8.
Monto >= 250
*/