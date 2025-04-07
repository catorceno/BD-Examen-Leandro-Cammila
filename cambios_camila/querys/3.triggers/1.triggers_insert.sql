USE Gym;

-- 1.Calcular el precio total de la inscripcion
CREATE TRIGGER trg_calcular_total
ON INSCRIPCION
AFTER INSERT
AS
BEGIN
    UPDATE i
    SET Total = i.Subtotal * (1 - d.Porcentaje / 100.0)
    FROM INSCRIPCION i
    INNER JOIN inserted ins ON i.InscripcionID = ins.InscripcionID
    INNER JOIN DESCUENTOS d ON ins.DescuentoID = d.DescuentoID
    WHERE ins.DescuentoID IS NOT NULL; -- calcular Total con descuento

    UPDATE i
    SET Total = i.Subtotal
    FROM INSCRIPCION i
    INNER JOIN inserted ins ON i.InscripcionID = ins.InscripcionID
    WHERE ins.DescuentoID IS NULL; -- calcular sin descuento
END

-- 2.Prevenir inscripciones duplicadas (tomando en cuenta el uso solo atraves de GUI)
CREATE TRIGGER trg_prevenir_inscripciones_duplicadas
ON INSCRIPCION
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @last_day_inscripcion DATE = (
		SELECT TOP 1 i.FechaFin
		FROM INSCRIPCION i
		INNER JOIN inserted ON i.ClienteID = inserted.ClienteID
		ORDER BY i.InscripcionID DESC
	)

	IF (SELECT FechaInicio FROM inserted) < @last_day_inscripcion
    BEGIN
        RAISERROR ('El cliente ya tiene una inscripción activa.', 16, 1);
        ROLLBACK TRANSACTION;
    END
	ELSE
	BEGIN
		INSERT INTO INSCRIPCION (ClienteID, CantidadMeses, FechaInicio, DescuentoID)
		SELECT ClienteID, CantidadMeses, FechaInicio, DescuentoID
		FROM inserted;
	END
END;

/*CREATE TRIGGER trg_prevenir_inscripciones_duplicadas
ON INSCRIPCION
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @last_day_inscripcion DATE = (
		SELECT TOP 1 FechaFin
		FROM INSCRIPCION i
		INNER JOIN inserted ON i.ClienteID = inserted.ClienteID
		ORDER BY InscripcionID DESC
	)

	IF EXISTS (
		SELECT 1
		FROM inserted
		WHERE inserted.FechaInicio < @last_day_inscripcion
	)
    BEGIN
        RAISERROR ('El cliente ya tiene una inscripción activa.', 16, 1);
        ROLLBACK TRANSACTION;
    END
	ELSE
	BEGIN
		INSERT INTO INSCRIPCION (ClienteID, CantidadMeses, FechaInicio, DescuentoID)
		SELECT ClienteID, CantidadMeses, FechaInicio, DescuentoID
		FROM inserted;
	END
END;*/


