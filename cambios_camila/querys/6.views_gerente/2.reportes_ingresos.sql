USE Gym;
GO

-- 1.Total del ultimo semestre
CREATE VIEW vw_ingresosUltimoSemestre AS
	SELECT SUM(Monto) as TotalIngresos
	FROM PAGOS
	WHERE Fecha >= DATEADD(MONTH, -6, CAST(GETDATE() AS DATE))

-- 2.Total ingresos por mes del ultimo semestre
CREATE VIEW vw_ingresosPorMes AS
	SELECT
		FORMAT(p.Fecha, 'yyyy-MM') as Mes,
		CAST(SUM(p.Monto) AS VARCHAR) + ' Bs.' as Ingresos
	FROM PAGOS p
	WHERE p.Fecha >= DATEADD(MONTH, -6, CAST(GETDATE() AS DATE))
	GROUP BY FORMAT(p.Fecha, 'yyyy-MM')
SELECT * FROM vw_ingresosUltimoSemestre
SELECT * FROM vw_ingresosPorMes