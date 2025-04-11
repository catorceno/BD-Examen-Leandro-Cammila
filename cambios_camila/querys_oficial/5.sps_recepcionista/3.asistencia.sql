USE Gym;
GO

-- =========================================
-- Author:      Camila Catorceno
-- Create date: 2025-04-06
-- Description: Boton Agregar Asistencia
-- =========================================
CREATE PROCEDURE sp_agregar_asistencia
    @CI INT,
    @Servicio NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

		DECLARE @Fecha DATE = CAST(GETDATE() AS DATE);
		DECLARE @HoraIngreso TIME(0) = CONVERT(TIME(0), GETDATE());
        
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