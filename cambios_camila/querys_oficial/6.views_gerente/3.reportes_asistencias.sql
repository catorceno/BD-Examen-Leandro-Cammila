USE Gym;
GO

-- 1.Asitencias por hora (para que el gerente pueda ver en que horas hay mas asistencias)
CREATE VIEW vw_asistenciasPorHora AS
	SELECT 
		CAST(DATEPART(HOUR, HoraIngreso) AS VARCHAR) + ':00' AS Hora,
		COUNT(AsistenciaID) AS Asistencias
	FROM ASISTENCIA
	GROUP BY DATEPART(HOUR, HoraIngreso)
SELECT * FROM vw_asistenciasPorHora

-- 2.Que servicios son mas populares de acuerdo a la asistencia
CREATE VIEW vw_rankingServicios AS
	SELECT
		s.Nombre as Servicio,
		COUNT(a.AsistenciaID) as Asistencias
	FROM ASISTENCIA a
	INNER JOIN INSCRIPCION i ON i.InscripcionID = a.InscripcionID
	INNER JOIN SERVICIOS s ON s.ServicioID = a.ServicioID
	GROUP BY a.ServicioID, s.Nombre
SELECT * FROM vw_asistenciasPorHora
ORDER BY Hora ASC
SELECT * FROM vw_rankingServicios
ORDER BY Asistencias DESC
