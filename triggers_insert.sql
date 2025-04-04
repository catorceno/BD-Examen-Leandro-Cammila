USE Gym;
--CREACION DE LOS SEGUNDOS TRIGGERS 
-- 1.Calcular TotalFinal de PAGOS con el descuento (si aplica) y determinar el descuento como Desactivo
CREATE TRIGGER trg_CalcularTotalFinal
ON PAGOS
AFTER INSERT
AS
BEGIN
    DECLARE @DescuentoID INT, @FechaFin DATE, @Estado NVARCHAR(50);

    -- Obtener el DescuentoID y la FechaFin del descuento aplicado
    SELECT @DescuentoID = i.DescuentoID, @FechaFin = d.FechaFin
    FROM inserted i
    LEFT JOIN DESCUENTOS d ON i.DescuentoID = d.DescuentoID;

    -- Si se aplicó un descuento y la FechaFin ya pasó, desactivar el descuento y quitarlo del pago
    IF @DescuentoID IS NOT NULL AND @FechaFin < GETDATE()
    BEGIN
        UPDATE d
        SET Estado = 'Desactivo'
        FROM DESCUENTOS d
        WHERE d.DescuentoID = @DescuentoID;
        
        UPDATE p
        SET p.DescuentoID = NULL
        FROM PAGOS p
        INNER JOIN inserted i ON p.PagoID = i.PagoID
        WHERE i.DescuentoID = @DescuentoID;

        PRINT 'Descuento no válido. El descuento ha sido desactivado y removido del pago.';
    END

    -- Calcular el TotalFinal, considerando solo los descuentos vigentes
    UPDATE p
    SET TotalFinal = 
        CASE 
            WHEN i.DescuentoID IS NOT NULL AND d.FechaFin >= GETDATE() THEN i.Total * (1 - d.Porcentaje / 100)
            ELSE i.Total
        END
    FROM PAGOS p
    INNER JOIN inserted i ON p.PagoID = i.PagoID
    LEFT JOIN DESCUENTOS d ON i.DescuentoID = d.DescuentoID;
END;

-- 2.Evitar pagos duplicados
CREATE TRIGGER trg_PreventDuplicatePayments
ON PAGOS
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM PAGOS p
        JOIN inserted i ON p.InscripcionID = i.InscripcionID
        WHERE YEAR(p.Fecha) = YEAR(i.Fecha) 
        AND MONTH(p.Fecha) = MONTH(i.Fecha)
    )
    BEGIN
        RAISERROR ('El cliente ya ha realizado el pago de este mes.', 16, 1);
        ROLLBACK TRANSACTION;
    END
	ELSE
	BEGIN
		INSERT INTO PAGOS (InscripcionID, Fecha, Total, DescuentoID)
		SELECT InscripcionID, Fecha, Total, DescuentoID
		FROM inserted;
	END
END;

-- 3.Evitar inscripciones duplicadas
CREATE TRIGGER trg_PreventDuplicateInscription
ON INSCRIPCION
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSCRIPCION i
        JOIN inserted ins ON i.ClienteID = ins.ClienteID
        WHERE GETDATE() BETWEEN i.FechaInicio AND i.FechaFin
    )
    BEGIN
        RAISERROR ('El cliente ya tiene una inscripción activa.', 16, 1);
        ROLLBACK TRANSACTION;
    END
	ELSE
	BEGIN
		INSERT INTO INSCRIPCION (ClienteID, CantidadMeses, FechaInicio, Mensualidad)
		SELECT ClienteID, CantidadMeses, FechaInicio, Mensualidad
		FROM inserted;
	END
END;
