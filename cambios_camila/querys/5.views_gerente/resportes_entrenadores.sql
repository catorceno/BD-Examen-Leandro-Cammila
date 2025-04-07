USE Gym;

-- reporte entrenadores
CREATE VIEW vw_totalSueldos AS -- suma de sueldo por servicio y el total de gasto por sueldos
	SELECT SUM(Sueldo) as Total FROM ENTRENADORES
CREATE VIEW vw_totalSueldosDetalle AS
	SELECT
		s.Nombre as Servicio,
		CAST(SUM(e.Sueldo) AS VARCHAR) + ' Bs.' as APagar
	FROM ENTRENADORES e
	INNER JOIN SERVICIOS s ON s.ServicioID = e.ServicioID
	GROUP BY e.ServicioID, s.Nombre
	ORDER BY APagar DESC
SELECT * FROM vw_totalSueldos
SELECT * FROM vw_totalSueldosDetalle

CREATE VIEW vw_aPagarHoy AS -- entrenadores a pagar hoy
	SELECT
		CI,
		Nombre,
		Apellido,
		Turno,
		CAST(Sueldo AS VARCHAR) + ' Bs.' as Sueldo
	FROM ENTRENADORES
	WHERE Estado = 'Activo'
	AND FechaInicio = CAST(GETDATE() AS DATE)
SELECT * FROM vw_aPagarHoy