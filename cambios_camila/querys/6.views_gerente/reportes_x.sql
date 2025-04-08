USE Gym;
GO

-- reporte mas completo: por cada descuento, la cantidad de inscritos, el ingreso generado y el promedio de asistencias(de inscripciones con ese descuento?) aumentar para que muestre de los de Sin descuento (no se que tan útil sea)
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