USE Gym;
GO

-- 1.Reporte Top 10 Clientes
CREATE VIEW vw_clientesTop AS
	SELECT
		TOP 10
		c.CI,
		c.Nombre,
		c.Apellido,
		SUM(i.CantidadMeses) as CantidadMeses,
		COUNT(i.InscripcionID) as CantidadInsc,
		CAST(SUM(i.Total) AS VARCHAR) + ' Bs.' as Total,
		MAX(i.FechaInicio) as FechaUltimaInsc,
		MAX(i.FechaFin) as FechaFinUltimaInsc,
		CASE WHEN GETDATE() < MAX(i.FechaFin) THEN 'Activo'
		ELSE 'Desactivo'
		END EstadoInsc
	FROM INSCRIPCION i
	INNER JOIN CLIENTES c ON c.ClienteID = i.ClienteID
	GROUP BY i.ClienteID, c.CI, c.Nombre, c.Apellido
	ORDER BY CantidadMeses DESC
SELECT * FROM vw_clientesTop

-- 2.Reporte Inventario (cuantas maquinas hay en cada categoria de Estado)
CREATE VIEW vw_reporteEstadoMaquinas AS
	SELECT 
		SUM(CASE WHEN Estado = 'Nuevo' THEN 1 ELSE 0 END) AS Nuevo,
		SUM(CASE WHEN Estado = 'En Uso' THEN 1 ELSE 0 END) AS En_Uso,
		SUM(CASE WHEN Estado = 'Mantenimiento' THEN 1 ELSE 0 END) AS Mantenimiento,
		SUM(CASE WHEN Estado = 'Mal Estado' THEN 1 ELSE 0 END) AS Mal_Estado,
		SUM(CASE WHEN Estado = 'Descontinuado' THEN 1 ELSE 0 END) AS Descontinuado
	FROM INVENTARIO;
CREATE VIEW vw_reporteEstadoMaquinasDetalle AS 
	WITH CTE_Nuevo AS (
		SELECT Nombre AS Nuevo,
			   ROW_NUMBER() OVER (ORDER BY Nombre) AS rn
		FROM INVENTARIO
		WHERE Estado = 'Nuevo'
	),
	CTE_EnUso AS (
		SELECT Nombre AS EnUso,
			   ROW_NUMBER() OVER (ORDER BY Nombre) AS rn
		FROM INVENTARIO
		WHERE Estado = 'En Uso'
	),
	CTE_Mantenimiento AS (
		SELECT Nombre AS Mantenimiento,
			   ROW_NUMBER() OVER (ORDER BY Nombre) AS rn
		FROM INVENTARIO
		WHERE Estado = 'Mantenimiento'
	),
	CTE_MalEstado AS (
		SELECT Nombre AS MalEstado,
			   ROW_NUMBER() OVER (ORDER BY Nombre) AS rn
		FROM INVENTARIO
		WHERE Estado = 'Mal Estado'
	),
	CTE_Descontinuado AS (
		SELECT Nombre AS Descontinuado,
			   ROW_NUMBER() OVER (ORDER BY Nombre) AS rn
		FROM INVENTARIO
		WHERE Estado = 'Descontinuado'
	)
	SELECT 
		COALESCE(n.rn, e.rn, m.rn, me.rn, d.rn) AS row_num,
		n.Nuevo,
		e.EnUso,
		m.Mantenimiento,
		me.MalEstado,
		d.Descontinuado
	FROM CTE_Nuevo n
	FULL OUTER JOIN CTE_EnUso e ON n.rn = e.rn
	FULL OUTER JOIN CTE_Mantenimiento m ON COALESCE(n.rn, e.rn) = m.rn
	FULL OUTER JOIN CTE_MalEstado me ON COALESCE(n.rn, e.rn, m.rn) = me.rn
	FULL OUTER JOIN CTE_Descontinuado d ON COALESCE(n.rn, e.rn, m.rn, me.rn) = d.rn
SELECT * FROM vw_reportEstadoMaquinas
SELECT * FROM vw_reporteEstadoMaquinasDetalle
ORDER BY row_num;
