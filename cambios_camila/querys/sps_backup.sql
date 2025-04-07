USE Gym;
GO

-- 1.Boton Nuevo Cliente
ALTER PROCEDURE sp_inscribir_nuevo_cliente
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
        -- Relanza el error original para que la aplicación lo capture
        THROW;
    END CATCH
END

-- 2.Boton Cliente Existente
ALTER PROCEDURE sp_inscribir_cliente_existente
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

------------------ EN PAGOS ------------------
-- 1.Boton Agregar Pago
ALTER PROCEDURE sp_agregar_pago
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

-- 2.Boton Buscar Pagos
ALTER PROCEDURE sp_buscar_pagos
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

---------------- EN ASISTENCIA ----------------
-- 1.Boton Agregar Asistencia
CREATE PROCEDURE sp_agregar_asistencia
    @CI INT,
    @Servicio NVARCHAR(50),
    @Fecha DATE,
    @HoraIngreso TIME
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF NOT EXISTS (SELECT 1 FROM CLIENTES WHERE CI = @CI)
        BEGIN
            THROW 50010, 'No existe un cliente con ese CI.', 1;
        END

        DECLARE @InscripcionID INT = (
            SELECT TOP 1 InscripcionID 
            FROM INSCRIPCION 
            WHERE ClienteID = (SELECT ClienteID FROM CLIENTES WHERE CI = @CI) 
              AND FechaFin > GETDATE() 
            ORDER BY InscripcionID DESC
        );
        
        IF @InscripcionID IS NULL
        BEGIN
            THROW 50011, 'El cliente no tiene una inscripción activa.', 1;
        END

        IF EXISTS (SELECT 1 FROM ASISTENCIA WHERE InscripcionID = @InscripcionID AND Fecha = @Fecha)
        BEGIN
            THROW 50012, 'El cliente ya asistió hoy al gimnasio.', 1;
        END

        DECLARE 
            @FechaInicio DATE, 
            @FechaFin DATE,  
            @ServicioID INT, 
            @HoraInicio TIME(0), 
            @HoraFin TIME(0);

        SELECT @FechaInicio = FechaInicio, @FechaFin = FechaFin
        FROM INSCRIPCION
        WHERE InscripcionID = @InscripcionID;
        
        IF @Fecha < @FechaInicio OR @Fecha > @FechaFin
        BEGIN
            DECLARE @msg NVARCHAR(200) = 'La fecha de la asistencia debe estar dentro del rango de la inscripción vigente. Rango: ' 
                                         + CONVERT(NVARCHAR(10), @FechaInicio, 23) + ' y ' 
                                         + CONVERT(NVARCHAR(10), @FechaFin, 23) + '.';
            THROW 50013, @msg, 1;
        END

        SELECT @ServicioID = ServicioID, @HoraInicio = HoraInicio, @HoraFin = HoraFin
        FROM SERVICIOS
        WHERE Nombre = @Servicio;
        
        IF @HoraIngreso < @HoraInicio OR @HoraIngreso > DATEADD(MINUTE, -55, @HoraFin)
        BEGIN
            DECLARE @msg2 NVARCHAR(200) = 'La hora de la asistencia debe ser al menos 55 minutos antes del cierre del servicio. Rango: ' 
                                          + CONVERT(NVARCHAR(8), @HoraInicio, 108) + ' - ' 
                                          + CONVERT(NVARCHAR(8), @HoraFin, 108) + '.';
            THROW 50014, @msg2, 1;
        END

        INSERT INTO ASISTENCIA(InscripcionID, ServicioID, Fecha, HoraIngreso)
        VALUES (@InscripcionID, @ServicioID, @Fecha, @HoraIngreso);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END

-- 2.Boton Buscar Asistencias
CREATE PROCEDURE sp_buscar_asistencias
    @CI INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF NOT EXISTS (SELECT 1 FROM CLIENTES WHERE CI = @CI)
        BEGIN
            THROW 50015, 'No existe un cliente con ese CI.', 1;
        END

        DECLARE @InscripcionID INT = (
            SELECT TOP 1 InscripcionID 
            FROM INSCRIPCION 
            WHERE ClienteID = (SELECT ClienteID FROM CLIENTES WHERE CI = @CI)
            ORDER BY InscripcionID DESC
        );
        
        SELECT c.CI, c.Nombre, c.Apellido, s.Nombre AS Servicio, a.Fecha, a.HoraIngreso
        FROM ASISTENCIA a
        INNER JOIN INSCRIPCION i ON a.InscripcionID = i.InscripcionID
        INNER JOIN CLIENTES c ON i.ClienteID = c.ClienteID
        INNER JOIN SERVICIOS s ON a.ServicioID = s.ServicioID
        WHERE a.InscripcionID = @InscripcionID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END




/*
BACKUP VERSION ANTERIOR
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
	BEGIN TRANSACTION
	BEGIN TRY
		IF EXISTS (SELECT 1 FROM CLIENTES WHERE CI = @CI)
		BEGIN
			RAISERROR('Ya existe un cliente con ese CI.', 16, 1);
			ROLLBACK;
		END

		INSERT INTO CLIENTES(CI, Nombre, Apellido, Telefono)
		VALUES (@CI, @Nombre, @Apellido, @Telefono);

		DECLARE @ClienteID INT = SCOPE_IDENTITY();
		DECLARE @DescuentoID INT;
			IF @Descuento IS NULL
			BEGIN
				SET @DescuentoID = NULL;
			END
			ELSE
			BEGIN
				SET @DescuentoID = (SELECT DescuentoID FROM DESCUENTOS WHERE Nombre = @Descuento)
			END
		INSERT INTO INSCRIPCION(ClienteID, CantidadMeses, FechaInicio, DescuentoID)
		VALUES (@ClienteID, @CantidadMeses, @FechaInicio, @DescuentoID);

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK;
		DECLARE @error_msg NVARCHAR(4000) =	ERROR_MESSAGE();
		RAISERROR(@error_msg, 16, 1)
	END CATCH
END

-- 2.Boton Cliente Existente
ALTER PROCEDURE sp_inscribir_cliente_existente
@CI INT,
@CantidadMeses INT,
@FechaInicio DATE,
@Descuento NVARCHAR(50)
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM CLIENTES WHERE CI = @CI) -- si no existe el cliente
		BEGIN
			RAISERROR('No existe un cliente con ese CI.', 16, 1);
			ROLLBACK;
		END
		
		DECLARE @ClienteID INT = (SELECT ClienteID FROM CLIENTES WHERE CI = @CI) 
		
		IF EXISTS (SELECT TOP 1 InscripcionID FROM INSCRIPCION WHERE ClienteID = @ClienteID AND FechaFin > GETDATE() ORDER BY InscripcionID DESC) -- si el cliente tiene una inscripcion vigente
		BEGIN
			RAISERROR('El cliente ya tiene una inscripción activa.', 16, 1);
				ROLLBACK;
		END
			DECLARE @DescuentoID INT;
			IF @Descuento IS NULL
			BEGIN
				SET @DescuentoID = NULL;
			END
			ELSE
			BEGIN
				SET @DescuentoID = (SELECT DescuentoID FROM DESCUENTOS WHERE Nombre = @Descuento)
			END
			INSERT INTO INSCRIPCION(ClienteID, CantidadMeses, FechaInicio, DescuentoID)
			VALUES (@ClienteID, @CantidadMeses, @FechaInicio, @DescuentoID);

			COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK;
		DECLARE @error_msg NVARCHAR(4000) =	ERROR_MESSAGE();
		RAISERROR(@error_msg, 16, 1)
	END CATCH
END

------------------ EN PAGOS ------------------
-- 1.Boton Agregar Pago
ALTER PROCEDURE sp_agregar_pago
@CI INT,
@Fecha DATE,
@Monto INT
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM CLIENTES WHERE CI = @CI)
		BEGIN
			RAISERROR('No existe un cliente con ese CI.', 16, 1);
		END

		DECLARE @ClienteID INT = (SELECT ClienteID FROM CLIENTES WHERE CI = @CI)		
		IF NOT EXISTS (SELECT TOP 1 InscripcionID FROM INSCRIPCION WHERE ClienteID = @ClienteID AND FechaFin > GETDATE() ORDER BY InscripcionID DESC) -- si no tiene una inscripcion vigente
		BEGIN
			RAISERROR('El cliente no tiene una inscripción activa.', 16, 1);
		END

		DECLARE @InscripcionID INT
		DECLARE @FechaInicio DATE
		DECLARE @FechaFin DATE
		DECLARE @Total INT
		DECLARE @TotalPagos INT
		-- Obtener los detalles de la inscripción vigente
		SELECT TOP 1 
			@InscripcionID = InscripcionID,
			@FechaInicio = FechaInicio,
			@FechaFin = FechaFin,
			@Total = Total
		FROM INSCRIPCION
		WHERE ClienteID = @ClienteID AND FechaFin > GETDATE()
		ORDER BY InscripcionID DESC
		-- Calcular el total de pagos realizados hasta la fecha
		SELECT @TotalPagos = SUM(Monto)
		FROM PAGOS
		WHERE InscripcionID = @InscripcionID
		-- Verificar si el total de pagos es mayor o igual al subtotal
		IF @TotalPagos >= @Total
		BEGIN
			RAISERROR('El cliente ya ha saldado toda su deuda. No se puede realizar más pagos.', 16, 1);
		END
		IF @Fecha < @FechaInicio OR @Fecha > @FechaFin
		BEGIN
			DECLARE @msg NVARCHAR(200) = 'La fecha del pago debe estar dentro del rango de la inscripción vigente. Rango: ' + 
										  CONVERT(NVARCHAR(10), @FechaInicio, 23) + ' y ' + CONVERT(NVARCHAR(10), @FechaFin, 23) + '.'
			RAISERROR(@msg, 16, 1);
		END

		-- si pasa todas las verificaciones se añade
		INSERT INTO PAGOS(InscripcionID, Fecha, Monto)
		VALUES (@InscripcionID, @Fecha, @Monto)

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK;
		DECLARE @error_msg NVARCHAR(4000) =	ERROR_MESSAGE();
		RAISERROR(@error_msg, 16, 1)
	END CATCH
END

-- 2.Boton Buscar Pagos
ALTER PROCEDURE sp_buscar_pagos
@CI INT
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM CLIENTES WHERE CI = @CI)
		BEGIN
			RAISERROR('No existe un cliente con ese CI.', 16, 1);
		END

		DECLARE @InscripcionID INT = (SELECT TOP 1 InscripcionID FROM INSCRIPCION WHERE ClienteID = (SELECT ClienteID FROM CLIENTES WHERE CI = @CI) ORDER BY InscripcionID DESC) --buscar la ultima inscripcion
		
		SELECT c.CI, c.Nombre, c.Apellido, p.Fecha as FechaPago, p.Monto
		FROM PAGOS p
		INNER JOIN INSCRIPCION i ON p.InscripcionID = i.InscripcionID
		INNER JOIN CLIENTES c ON i.ClienteID = c.ClienteID
		WHERE p.InscripcionID = @InscripcionID

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK;
		DECLARE @error_msg NVARCHAR(4000) =	ERROR_MESSAGE();
		RAISERROR(@error_msg, 16, 1)
	END CATCH
END

-- 3.Boton Consultar Deuda
CREATE PROCEDURE sp_consultar_deuda
@CI INT
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM CLIENTES WHERE CI = @CI)
		BEGIN
			RAISERROR('No existe un cliente con ese CI.', 16, 1);
		END

		DECLARE @InscripcionID INT = (SELECT TOP 1 InscripcionID FROM INSCRIPCION WHERE ClienteID = (SELECT ClienteID FROM CLIENTES WHERE CI = @CI) ORDER BY InscripcionID DESC) --buscar la ultima inscripcion
		
		SELECT c.CI, c.Nombre, c.Apellido, c.Telefono, i.FechaInicio as FechaInscripcion, i.FechaFin, i.Total,  SUM(p.Monto) as MontoPagado, (i.Total - SUM(p.Monto)) as Deuda
		FROM PAGOS p
		INNER JOIN INSCRIPCION i ON i.InscripcionID = p.InscripcionID
		INNER JOIN CLIENTES c ON i.ClienteID = c.ClienteID
		WHERE p.InscripcionID = @InscripcionID
		GROUP BY c.CI, c.Nombre, c.Apellido, c.Telefono, i.FechaInicio, i.FechaFin, i.Total

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK;
		DECLARE @error_msg NVARCHAR(4000) =	ERROR_MESSAGE();
		RAISERROR(@error_msg, 16, 1)
	END CATCH
END

---------------- EN ASISTENCIA ----------------
-- 1.Boton Agregar Asistencia
CREATE PROCEDURE sp_agregar_asistencia
@CI INT,
@Servicio NVARCHAR(50),
@Fecha DATE,
@HoraIngreso TIME
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM CLIENTES WHERE CI = @CI)
		BEGIN
			RAISERROR('No existe un cliente con ese CI.', 16, 1);
		END
		DECLARE @InscripcionID INT = (SELECT TOP 1 InscripcionID FROM INSCRIPCION WHERE ClienteID = (SELECT ClienteID FROM CLIENTES WHERE CI = @CI) AND FechaFin > GETDATE() ORDER BY InscripcionID DESC)
		IF @InscripcionID IS NULL
		BEGIN
			RAISERROR('El cliente no tiene una inscripción activa.', 16, 1);
		END
		IF EXISTS (SELECT 1 FROM ASISTENCIA WHERE InscripcionID = @InscripcionID AND Fecha = @Fecha)
		BEGIN
			RAISERROR('El cliente ya asistió hoy al gimnasio.', 16, 1);
		END

		DECLARE @FechaInicio INT, @FechaFin INT,  @ServicioID INT, @HoraInicio TIME(0), @HoraFin TIME(0)

		SELECT @FechaInicio = FechaInicio, @FechaFin = FechaFin
		FROM INSCRIPCION
		WHERE InscripcionID = @InscripcionID

		IF @Fecha < @FechaInicio OR @Fecha > @FechaFin
		BEGIN
			DECLARE @msg NVARCHAR(200) = 'La fecha de la asistencia debe estar dentro del rango de la inscripción vigente. Rango: ' + 
										  CONVERT(NVARCHAR(10), @FechaInicio, 23) + ' y ' + CONVERT(NVARCHAR(10), @FechaFin, 23) + '.'
			RAISERROR(@msg, 16, 1);
		END

		SELECT @ServicioID = ServicioID, @HoraInicio = HoraInicio, @HoraFin = HoraFin
		FROM SERVICIOS
		WHERE Nombre = @Servicio
		IF @HoraIngreso < @HoraInicio OR @HoraIngreso > DATEADD(MINUTE, -55, @HoraFin) 
		BEGIN
			DECLARE @msg2 NVARCHAR(200) = 'La hora de la asistencia debe ser al menos 55 minutos antes del cierre del servicio. Rango: ' + 
										  CONVERT(NVARCHAR(8), @HoraInicio, 108) + ' - ' + CONVERT(NVARCHAR(8), @HoraFin, 108) + '.'
			RAISERROR(@msg2, 16, 1);
		END
		-- si pasa todas las verificaciones, se inserta
		INSERT INTO ASISTENCIA(InscripcionID, ServicioID, Fecha, HoraIngreso)
		VALUES (@InscripcionID, @ServicioID, @Fecha, @HoraIngreso)

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK;
		DECLARE @error_msg NVARCHAR(4000) =	ERROR_MESSAGE();
		RAISERROR(@error_msg, 16, 1)
	END CATCH
END

-- 2.Boton Buscar Asistencias
CREATE PROCEDURE sp_buscar_asistencias
@CI INT
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM CLIENTES WHERE CI = @CI)
		BEGIN
			RAISERROR('No existe un cliente con ese CI.', 16, 1);
		END

		DECLARE @InscripcionID INT = (SELECT TOP 1 InscripcionID FROM INSCRIPCION WHERE ClienteID = (SELECT ClienteID FROM CLIENTES WHERE CI = @CI) ORDER BY InscripcionID DESC) --buscar la ultima inscripcion
		
		SELECT c.CI, c.Nombre, c.Apellido, s.Nombre as Servicio, a.Fecha, a.HoraIngreso
		FROM ASISTENCIA a
		INNER JOIN INSCRIPCION i ON a.InscripcionID = i.InscripcionID
		INNER JOIN CLIENTES c ON i.ClienteID = c.ClienteID
		INNER JOIN SERVICIOS s ON a.ServicioID = s.ServicioID
		WHERE a.InscripcionID = @InscripcionID

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK;
		DECLARE @error_msg NVARCHAR(4000) =	ERROR_MESSAGE();
		RAISERROR(@error_msg, 16, 1)
	END CATCH
END */
