USE Gym;
GO

-- reporte asistencias
-- que servicios son mas populares
CREATE VIEW vw_rankingServicios AS
	SELECT
		s.Nombre as Servicio,
		COUNT(a.AsistenciaID) as Asistencias
	FROM ASISTENCIA a
	INNER JOIN INSCRIPCION i ON i.InscripcionID = a.InscripcionID
	INNER JOIN SERVICIOS s ON s.ServicioID = a.ServicioID
	GROUP BY a.ServicioID, s.Nombre
	ORDER BY Asistencias DESC
SELECT * FROM vw_rankingServicios
-- que servicios son mas populares y hora mas concurrida por servicio
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

-- assitencias por hora, ¿order by asistencias desc?
CREATE VIEW vw_asistenciasPorHora AS
	SELECT 
		CAST(DATEPART(HOUR, HoraIngreso) AS VARCHAR) + ':00' AS Hora,
		COUNT(AsistenciaID) AS Asistencias
	FROM ASISTENCIA
	GROUP BY DATEPART(HOUR, HoraIngreso)
	ORDER BY Hora;
SELECT * FROM vw_asistenciasPorHora

-- asistencias en tiempos de descuento
CREATE VIEW vw_asistenciasDetalle AS

SELECT
	CASE WHEN i.DescuentoID IS NOT NULL AND d.Estado = 'Activo' THEN d.Nombre
	ELSE 'Sin Descuento'
	END Descuento,
	COUNT(a.AsistenciaID) as CantidadAsistencias
FROM ASISTENCIA a
INNER JOIN INSCRIPCION i ON i.InscripcionID = a.InscripcionID
LEFT JOIN DESCUENTOS d ON d.DescuentoID = i.DescuentoID
GROUP BY d.Nombre, i.DescuentoID, d.Estado


SELECT *
FROM ASISTENCIA



CREATE VIEW V_InscripcionConDescuento AS
SELECT
  i.InscripcionID,
  i.ClienteID,
  i.CantidadMeses,
  i.Mensualidad,
  i.Subtotal,
  d.DescuentoID,
  d.Nombre     AS DescuentoNombre,
  d.Porcentaje,
  -- Si no hay descuento, asumimos 0%
  COALESCE(d.Porcentaje, 0) AS PorcAplicado,
  -- Total efectivo pagado
  i.Subtotal * (1.0 - COALESCE(d.Porcentaje,0) / 100.0) AS TotalConDescuento
FROM INSCRIPCION i
LEFT JOIN DESCUENTOS d
  ON i.DescuentoID = d.DescuentoID;
GO


-- promedio de asistencias para el inscripciones con y sin descuento
WITH AsistCount AS (
  SELECT
    a.InscripcionID,
    COUNT(*) AS TotalAsistencias
  FROM ASISTENCIA a
  GROUP BY a.InscripcionID
)
SELECT
  CASE WHEN v.DescuentoID IS NULL THEN 'Sin Descuento' ELSE 'Con Descuento' END AS TipoInscripcion,
  AVG(ac.TotalAsistencias) AS PromedioAsistencias
FROM V_InscripcionConDescuento v
LEFT JOIN AsistCount ac
  ON v.InscripcionID = ac.InscripcionID
GROUP BY CASE WHEN v.DescuentoID IS NULL THEN 'Sin Descuento' ELSE 'Con Descuento' END;


-- cantidad de inscripciones y el ingreso total para inscripciones con y sin descuento
SELECT
  CASE WHEN DescuentoID IS NULL THEN 'Sin Descuento' ELSE 'Con Descuento' END AS TipoInscripcion,
  COUNT(*) AS CantidadInscripciones,
  SUM(TotalConDescuento) AS IngresoTotal
FROM V_InscripcionConDescuento
GROUP BY CASE WHEN DescuentoID IS NULL THEN 'Sin Descuento' ELSE 'Con Descuento' END;

-- reporte mas completo: por cada descuento, la cantidad de inscritos, el ingreso generado y el promedio de asistencias(de inscripciones con ese descuento?) aumentar para que muestre de los de Sin descuento
SELECT
  d.Nombre        AS Descuento,
  d.Porcentaje,
  COUNT(v.InscripcionID)   AS CantidadInscritos,
  SUM(v.TotalConDescuento) AS IngresoGenerado,
  AVG(ac.TotalAsistencias) AS PromedioAsistencias
FROM DESCUENTOS d
LEFT JOIN V_InscripcionConDescuento v
  ON d.DescuentoID = v.DescuentoID
LEFT JOIN (
  SELECT InscripcionID, COUNT(*) AS TotalAsistencias
  FROM ASISTENCIA
  GROUP BY InscripcionID
) ac
  ON v.InscripcionID = ac.InscripcionID
WHERE d.Estado = 'Activo'
GROUP BY d.Nombre, d.Porcentaje
ORDER BY d.Porcentaje DESC;

-- borrar
SELECT
  FORMAT(i.FechaInicio, 'yyyy-MM')               AS Mes,
  CASE 
    WHEN v.DescuentoID IS NULL THEN 'Sin Descuento'
    ELSE 'Con Descuento'
  END                                             AS TipoInscripcion,
  COUNT(*)                                       AS CantidadInscripciones,
  SUM(v.TotalConDescuento)                       AS IngresoTotal,
  AVG(ac.TotalAsistencias)                       AS PromedioAsistencias
FROM V_InscripcionConDescuento v
JOIN INSCRIPCION i
  ON v.InscripcionID = i.InscripcionID
LEFT JOIN (
  SELECT InscripcionID, COUNT(*) AS TotalAsistencias
  FROM ASISTENCIA
  GROUP BY InscripcionID
) ac
  ON v.InscripcionID = ac.InscripcionID
GROUP BY
  FORMAT(i.FechaInicio, 'yyyy-MM'),
  CASE WHEN v.DescuentoID IS NULL THEN 'Sin Descuento' ELSE 'Con Descuento' END
ORDER BY
  Mes,
  TipoInscripcion;

-- revisar
DECLARE @StartDate DATE = '2025-01-01',
        @EndDate   DATE = '2025-12-31';
WITH InscripcionesPeriodo AS (
  -- Todas las inscripciones iniciadas en el periodo
  SELECT 
    InscripcionID, 
    ClienteID, 
    FechaFin, 
    DescuentoID
  FROM INSCRIPCION
  WHERE FechaInicio BETWEEN @StartDate AND @EndDate
),
Renovaciones AS (
  -- Para cada inscripción, contamos si hay una “renovación” posterior
  SELECT
    p.InscripcionID,
    CASE 
      WHEN p.DescuentoID IS NULL THEN 'Sin Descuento'
      ELSE 'Con Descuento'
    END                              AS Tipo,
    COUNT(n.InscripcionID)           AS Renovaciones
  FROM InscripcionesPeriodo p
  LEFT JOIN INSCRIPCION n
    ON n.ClienteID = p.ClienteID
    AND n.FechaInicio > p.FechaFin   -- renovó tras vencer
  GROUP BY
    p.InscripcionID,
    CASE WHEN p.DescuentoID IS NULL THEN 'Sin Descuento' ELSE 'Con Descuento' END
)
SELECT
  Tipo,
  COUNT(*)                                        AS TotalInscripciones,
  SUM(CASE WHEN Renovaciones > 0 THEN 1 ELSE 0 END) AS Renovaron,
  CAST(
    SUM(CASE WHEN Renovaciones > 0 THEN 1 ELSE 0 END) * 100.0
    / COUNT(*)
    AS DECIMAL(5,2)
  )                                               AS PorcentajeRenovacion
FROM Renovaciones
GROUP BY Tipo;






-- reporte ingresos
	-- que mes se genero mas
	-- cuantos clientes nuevos hubos el ultimo semestre
	-- numero de inscripciones con descuentos aplicados y conteo de todos mostrando el nombre

CREATE VIEW vw_movimientoUltimoSemetre AS
-- cantidad inscripciones por mes en el último semestre
	SELECT FORMAT(i.FechaInicio, 'yyyy-MM') AS Mes, COUNT(*) AS CantidadInscripciones
	FROM INSCRIPCION i
	WHERE i.FechaInicio >= DATEADD(MONTH, -6, CAST(GETDATE() AS DATE))
	GROUP BY FORMAT(i.FechaInicio, 'yyyy-MM')
	ORDER BY Mes;
-- cuantas inscripciones hubo el ultimo semestre
	SELECT COUNT(*) as TotalInscripciones
	FROM INSCRIPCION i
	INNER JOIN CLIENTES c ON c.ClienteID = i.ClienteID
	WHERE i.FechaInicio >= CAST(DATEADD(MONTH, -6, GETDATE())AS DATE)

-- total ingresos por mes del ultimo semestre
	SELECT FORMAT(Fecha, 'yyyy-MM') AS Mes, COUNT(*) AS IngresosPorMes
	FROM PAGOS
	WHERE Fecha >= DATEADD(MONTH, -6, CAST(GETDATE() AS DATE))
	GROUP BY FORMAT(Fecha, 'yyyy-MM')
	ORDER BY Mes;
-- total ingresos del ultimo semestre
	SELECT SUM(Monto) as IngresoTotal
	FROM PAGOS
	WHERE Fecha >= DATEADD(MONTH, -6, CAST(GETDATE() AS DATE))