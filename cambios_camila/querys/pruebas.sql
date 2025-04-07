USE Gym;
GO
SELECT * FROM DESCUENTOS
INSERT INTO DESCUENTOS(Nombre, Porcentaje, FechaInicio, FechaFin)

SELECT * FROM SERVICIOS
INSERT INTO SERVICIOS(Nombre, HoraInicio, HoraFin)
VALUES ('servicio1', '12:00', '23:00')

VALUES ('descuento1', 10, '2025-03-01', '2025-06-01')

------------ PARA ROL RECEPCIONISTA ------------
---------------- EN INSCRIPCION ----------------
-- 1.Boton Nuevo Cliente
EXEC sp_inscribir_nuevo_cliente 8673023, 'Camila', 'Catorceno', 76468333, 3, '2025-04-04', NULL
SELECT * FROM CLIENTES ORDER BY ClienteID DESC
SELECT * FROM INSCRIPCION ORDER BY InscripcionID DESC

-- 1.Boton Cliente Existente
EXEC sp_inscribir_cliente_existente 8673023, 4, '2025-01-04', NULL
SELECT * FROM INSCRIPCION ORDER BY InscripcionID DESC -- vamos en 22

------------------ EN PAGOS ------------------
-- 1.Boton Agregar Pago
EXEC sp_agregar_pago 8673023, '2025-02-04', 250
SELECT * FROM PAGOS ORDER BY PagoID DESC

-- 2.Boton Buscar Pagos
EXEC sp_buscar_pagos 8673021

-- 3.Consultar Deuda
EXEC sp_consultar_deuda 8673021

---------------- EN ASISTENCIA ----------------
-- 1.Boton Agregar Asistencia
EXEC sp_agregar_asistencia  
SELECT * FROM ASISTENCIA ORDER BY AsistenciaID DESC

-- 2.Boton Buscar Asistencias
EXEC sp_buscar_asistencias 


SELECT * FROM CLIENTES
SELECT * FROM INSCRIPCION