USE Gym;
GO

-- =========================================
-- Author:      Camila Catorceno
-- Create date: 2025-04-05
-- Description: Boton Nuevo Cliente
-- =========================================
CREATE PROCEDURE sp_inscribir_nuevo_cliente
    @CI INT,
    @Nombre NVARCHAR(50),
    @Apellido NVARCHAR(50),
    @Telefono INT,
    @CantidadMeses INT,
    @FechaInicio DATE,
    @Descuento NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF EXISTS (SELECT 1 FROM CLIENTES WHERE CI = @CI)
        BEGIN
            THROW 50001, 'Ya existe un cliente con ese CI.', 1;
        END

        INSERT INTO CLIENTES(CI, Nombre, Apellido, Telefono)
        VALUES (@CI, @Nombre, @Apellido, @Telefono);

        DECLARE @ClienteID INT = SCOPE_IDENTITY();
        DECLARE @DescuentoID INT;

        IF @Descuento IS NULL OR @Descuento = ''
        BEGIN
            SET @DescuentoID = NULL;
        END
        ELSE
        BEGIN
            SET @DescuentoID = (SELECT DescuentoID FROM DESCUENTOS WHERE Nombre = @Descuento);
        END

        INSERT INTO INSCRIPCION(ClienteID, CantidadMeses, FechaInicio, DescuentoID)
        VALUES (@ClienteID, @CantidadMeses, @FechaInicio, @DescuentoID);

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
-- Create date: 2025-04-05
-- Description: Boton Cliente Existente
-- =========================================
CREATE PROCEDURE sp_inscribir_cliente_existente
    @CI INT,
    @CantidadMeses INT,
    @FechaInicio DATE,
    @Descuento NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF NOT EXISTS (SELECT 1 FROM CLIENTES WHERE CI = @CI)
        BEGIN
            THROW 50002, 'No existe un cliente con ese CI.', 1;
        END
        
        DECLARE @ClienteID INT = (SELECT ClienteID FROM CLIENTES WHERE CI = @CI); 
        
        IF EXISTS (
            SELECT TOP 1 InscripcionID 
            FROM INSCRIPCION 
            WHERE ClienteID = @ClienteID AND FechaFin > GETDATE() 
            ORDER BY InscripcionID DESC
        )
        BEGIN
            THROW 50003, 'El cliente ya tiene una inscripción activa.', 1;
        END
        
        DECLARE @DescuentoID INT;
        IF @Descuento IS NULL OR @Descuento = ''
        BEGIN
            SET @DescuentoID = NULL;
        END
        ELSE
        BEGIN
            SET @DescuentoID = (SELECT DescuentoID FROM DESCUENTOS WHERE Nombre = @Descuento);
        END
        
        INSERT INTO INSCRIPCION(ClienteID, CantidadMeses, FechaInicio, DescuentoID)
        VALUES (@ClienteID, @CantidadMeses, @FechaInicio, @DescuentoID);
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END