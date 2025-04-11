USE Gym;
GO

-- =========================================
-- Author:      Camila Catorceno
-- Create date: 2025-04-06
-- Description: Boton Agregar Pago
-- =========================================
CREATE PROCEDURE sp_agregar_pago
    @CI INT,
    @Fecha DATE,
    @Monto INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF NOT EXISTS (SELECT 1 FROM CLIENTES WHERE CI = @CI)
        BEGIN
            THROW 50004, 'No existe un cliente con ese CI.', 1;
        END

        DECLARE @ClienteID INT = (SELECT ClienteID FROM CLIENTES WHERE CI = @CI);		
        
        IF NOT EXISTS (
            SELECT TOP 1 InscripcionID 
            FROM INSCRIPCION 
            WHERE ClienteID = @ClienteID AND FechaFin > GETDATE() 
            ORDER BY InscripcionID DESC
        )
        BEGIN
            THROW 50005, 'El cliente no tiene una inscripción activa.', 1;
        END

        DECLARE 
            @InscripcionID INT,
            @FechaInicio DATE,
            @FechaFin DATE,
            @Total DECIMAL(10,2),
            @TotalPagos DECIMAL(10,2);

        -- Obtener los detalles de la inscripción vigente
        SELECT TOP 1 
            @InscripcionID = InscripcionID,
            @FechaInicio = FechaInicio,
            @FechaFin = FechaFin,
            @Total = Total
        FROM INSCRIPCION
        WHERE ClienteID = @ClienteID AND FechaFin > GETDATE()
        ORDER BY InscripcionID DESC;
        
        SELECT @TotalPagos = ISNULL(SUM(Monto), 0)
        FROM PAGOS
        WHERE InscripcionID = @InscripcionID;
        
        IF @TotalPagos >= @Total
        BEGIN
            THROW 50006, 'El cliente ya ha saldado toda su deuda. No se puede realizar más pagos.', 1;
        END
        
        IF @Fecha < @FechaInicio OR @Fecha > @FechaFin
        BEGIN
            DECLARE @msg NVARCHAR(200) = 'La fecha del pago debe estar dentro del rango de la inscripción vigente. Rango: ' 
                                         + CONVERT(NVARCHAR(10), @FechaInicio, 23) + ' y ' 
                                         + CONVERT(NVARCHAR(10), @FechaFin, 23) + '.';
            THROW 50007, @msg, 1;
        END

        INSERT INTO PAGOS(InscripcionID, Fecha, Monto)
        VALUES (@InscripcionID, @Fecha, @Monto);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END

-- =========================================
-- Author:      Camila Catorceno
-- Create date: 2025-04-06
-- Description: Boton Buscar Pagos
-- =========================================
CREATE PROCEDURE sp_buscar_pagos
    @CI INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF NOT EXISTS (SELECT 1 FROM CLIENTES WHERE CI = @CI)
        BEGIN
            THROW 50008, 'No existe un cliente con ese CI.', 1;
        END

        DECLARE @InscripcionID INT = (
            SELECT TOP 1 InscripcionID 
            FROM INSCRIPCION 
            WHERE ClienteID = (SELECT ClienteID FROM CLIENTES WHERE CI = @CI)
            ORDER BY InscripcionID DESC
        );
        
        SELECT c.CI, c.Nombre, c.Apellido, p.Fecha AS FechaPago, p.Monto
        FROM PAGOS p
        INNER JOIN INSCRIPCION i ON p.InscripcionID = i.InscripcionID
        INNER JOIN CLIENTES c ON i.ClienteID = c.ClienteID
        WHERE p.InscripcionID = @InscripcionID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END

-- 3.Consultar Deuda
CREATE PROCEDURE sp_consultar_deuda
    @CI INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF NOT EXISTS (SELECT 1 FROM CLIENTES WHERE CI = @CI)
        BEGIN
            THROW 50009, 'No existe un cliente con ese CI.', 1;
        END

        DECLARE @InscripcionID INT = (
            SELECT TOP 1 InscripcionID 
            FROM INSCRIPCION 
            WHERE ClienteID = (SELECT ClienteID FROM CLIENTES WHERE CI = @CI)
            ORDER BY InscripcionID DESC
        );
        
        SELECT c.CI, c.Nombre, c.Apellido, c.Telefono, 
               i.FechaInicio AS FechaInscripcion, i.FechaFin, i.Total,  
               SUM(p.Monto) AS MontoPagado, (i.Total - SUM(p.Monto)) AS Deuda
        FROM PAGOS p
        INNER JOIN INSCRIPCION i ON i.InscripcionID = p.InscripcionID
        INNER JOIN CLIENTES c ON i.ClienteID = c.ClienteID
        WHERE p.InscripcionID = @InscripcionID
        GROUP BY c.CI, c.Nombre, c.Apellido, c.Telefono, i.FechaInicio, i.FechaFin, i.Total;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
