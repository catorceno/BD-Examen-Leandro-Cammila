USE Gym;

-- Reporte del estado de las maquinas
CREATE VIEW vw_reportEstadoMaquinas AS
	SELECT 
		SUM(CASE WHEN Estado = 'Nuevo' THEN 1 ELSE 0 END) AS Nuevo,
		SUM(CASE WHEN Estado = 'En Uso' THEN 1 ELSE 0 END) AS En_Uso,
		SUM(CASE WHEN Estado = 'Mantenimiento' THEN 1 ELSE 0 END) AS Mantenimiento,
		SUM(CASE WHEN Estado = 'Mal Estado' THEN 1 ELSE 0 END) AS Mal_Estado,
		SUM(CASE WHEN Estado = 'Descontinuado' THEN 1 ELSE 0 END) AS Descontinuado
	FROM INVENTARIO;
SELECT * FROM vw_reportEstadoMaquinas

-- Reporte de inscripciones de los ultimos 6 meses
CREATE VIEW vw_reportLastInscriptions AS
	SELECT InscripcionID, c.Nombre, c.Apellido, CantidadMeses, Mensualidad, PrecioTotal, FechaInicio, FechaFin
	FROM INSCRIPCION i
	INNER JOIN CLIENTE c ON i.ClienteID = c.ClienteID
	WHERE FechaInicio >= DATEADD(MONTH, -6, GETDATE())
SELECT * FROM vw_reportLastInscriptions

-- Reporte de las asistencias del ultimo mes
CREATE VIEW vw_asistenciaLastMonth AS
	SELECT a.AsistenciaID, a.InscripcionID, s.Nombre as NombreServicio, a.Fecha, a.HoraIngreso
	FROM ASISTENCIA a
	INNER JOIN SERVICIO s ON a.ServicioID = s.ServicioID
	WHERE Fecha >= DATEADD(MONTH, -1, GETDATE())
SELECT * FROM vw_asistenciaLastMonth

-- Reporte de los top 10 clientes mas frecuentes
CREATE VIEW vw_clienteTop AS
	SELECT TOP 10
		c.ClienteID,
		c.Nombre,
		c.Apellido,
		COUNT(i.InscripcionID) AS CantidadInscripciones
	FROM CLIENTE c
	JOIN INSCRIPCION i ON c.ClienteID = i.ClienteID
	GROUP BY c.ClienteID, c.Nombre, c.Apellido
	ORDER BY CantidadInscripciones DESC;
SELECT * FROM vw_clienteTop