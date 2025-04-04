--Creacion de los indices 
--1. Indice en la tabla de inscripcion 
--BUSQUEDAS DE INSCRIPCIONES POR CLIENTE
--Inscripciones se unen con cliente y pagos
CREATE INDEX idx_Inscripcion_ClienteID
ON INSCRIPCION (ClienteID);
--beneficio
SELECT C.Nombre, C.Apellido, I.FechaInicio, I.Mensualidad 
FROM INSCRIPCION I
JOIN CLIENTE C ON I.ClienteID = C.ClienteID;

--2. Índice en PAGOS para búsquedas por InscripcionID y Fecha
CREATE INDEX idx_Pagos_Inscripcion_Fecha 
ON PAGOS(InscripcionID, Fecha);
-- beneficio
SELECT * FROM PAGOS 
WHERE InscripcionID = 40 AND Fecha BETWEEN '2024-07-22' AND '2024-07-22';

--3. Índice en ASISTENCIA para búsquedas rápidas por InscripcionID y Fecha
CREATE INDEX idx_Asistencia_Inscripcion_Fecha 
ON ASISTENCIA(InscripcionID, Fecha);
-- beneficio
SELECT * FROM ASISTENCIA 
WHERE InscripcionID = 10 AND Fecha = '2024-07-22';

--4 Índice en CLIENTE para acelerar búsquedas por teléfono
CREATE INDEX idx_Cliente_Telefono 
ON CLIENTE(Telefono);
-- beneficio
SELECT * FROM CLIENTE WHERE Telefono = 123456789;