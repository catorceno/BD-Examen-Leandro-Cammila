USE Gym;
GO

-- reporte inscripciones y descuentos
CREATE VIEW vw_inscripcionesDescuentos AS
	SELECT 
		SUM(CASE WHEN DescuentoID IS NOT NULL THEN 1 ELSE 0 END) as InscConDescuento,
		SUM(CASE WHEN DescuentoID IS NULL THEN 1 ELSE 0 END) as InscSinDescuento
	FROM INSCRIPCION i
CREATE VIEW vw_inscripcionesDescuentosDetalle AS
	SELECT
		d.Nombre as Descuento,
		d.Porcentaje,
		COUNT(*) as CantidadInsc,
		CAST(SUM(i.Total) AS VARCHAR) + ' Bs.' as Total
	FROM INSCRIPCION i
	LEFT JOIN DESCUENTOS d ON i.DescuentoID = d.DescuentoID
	GROUP BY i.DescuentoID, d.Nombre, d.Porcentaje
SELECT * FROM vw_inscripcionesDescuentos
SELECT * FROM vw_inscripcionesDescuentosDetalle