USE Gym;
GO

-- 1.Asitencias por hora (para que el gerente pueda ver en que horas hay mas asistencias)
CREATE VIEW vw_asistenciasPorHora AS
	SELECT 
		CAST(DATEPART(HOUR, HoraIngreso) AS VARCHAR) + ':00' AS Hora,
		COUNT(AsistenciaID) AS Asistencias
	FROM ASISTENCIA
	GROUP BY DATEPART(HOUR, HoraIngreso)

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
SELECT * FROM vw_rankingServicios
ORDER BY Asistencias DESC

-- 2. O que servicios son mas populares y hora mas concurrida por servicio (nose si sea muy útil)
WITH AsistenciasPorHora AS (
    SELECT 
        s.ServicioID,
        s.Nombre AS Servicio,
		CAST(DATEPART(HOUR, a.HoraIngreso) AS VARCHAR) + ':00' AS Hora,
        COUNT(a.AsistenciaID) AS Asistencias,
        ROW_NUMBER() OVER (PARTITION BY s.ServicioID ORDER BY COUNT(a.AsistenciaID) DESC) AS rn
    FROM ASISTENCIA a
    INNER JOIN INSCRIPCION i ON i.InscripcionID = a.InscripcionID
    INNER JOIN SERVICIOS s ON s.ServicioID = a.ServicioID
    GROUP BY s.ServicioID, s.Nombre, DATEPART(HOUR, a.HoraIngreso)
)
SELECT 
    s.Nombre AS Servicio,
    COUNT(a.AsistenciaID) AS TotalAsistencias,
    aph.Hora AS HoraMasConcurrida
FROM ASISTENCIA a
INNER JOIN INSCRIPCION i ON i.InscripcionID = a.InscripcionID
INNER JOIN SERVICIOS s ON s.ServicioID = a.ServicioID
LEFT JOIN (
    SELECT ServicioID, Hora
    FROM AsistenciasPorHora
    WHERE rn = 1
) aph ON aph.ServicioID = s.ServicioID
GROUP BY s.ServicioID, s.Nombre, aph.Hora
ORDER BY TotalAsistencias DESC;

-- 3.Asistencias en tiempos de descuento (para ver las asistencias de acuerdo al descuento con que se hizo la inscripcion? nose si sea muy útil)
CREATE VIEW vw_asistenciasPorDescuentos AS
	SELECT
		CASE WHEN i.DescuentoID IS NOT NULL AND d.Estado = 'Activo' THEN d.Nombre
		ELSE 'Sin Descuento'
		END Descuento,
		COUNT(a.AsistenciaID) as CantidadAsistencias
	FROM ASISTENCIA a
	INNER JOIN INSCRIPCION i ON i.InscripcionID = a.InscripcionID
	LEFT JOIN DESCUENTOS d ON d.DescuentoID = i.DescuentoID
	GROUP BY d.Nombre, i.DescuentoID, d.Estado
SELECT * FROM vw_asistenciasPorDescuentos
