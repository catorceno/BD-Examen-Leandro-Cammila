--Creacion de los sps
--SPS
--1. Inscripcion de un cliente
use [Gym]
select * from INSCRIPCION
--ya esta creado y ejecutado 
CREATE PROCEDURE sp_InscribirCliente
    @Nombre NVARCHAR(50),
    @Apellido NVARCHAR(50),
    @Telefono INT,
    @CantidadMeses INT
AS
BEGIN
    DECLARE @ClienteID INT;
    DECLARE @FechaInicio DATE = GETDATE();

    -- Verificar si el cliente ya existe por su teléfono
    SELECT @ClienteID = ClienteID FROM CLIENTE WHERE Telefono = @Telefono;

    -- Si el cliente no existe, lo registramos
    IF @ClienteID IS NULL
    BEGIN
        INSERT INTO CLIENTE (Nombre, Apellido, Telefono, ModifiedDate)
        VALUES (@Nombre, @Apellido, @Telefono, GETDATE());

        SET @ClienteID = SCOPE_IDENTITY(); -- Obtener el ID recién insertado
    END

    -- Registrar la inscripción del cliente
    INSERT INTO INSCRIPCION (ClienteID, CantidadMeses, FechaInicio, Mensualidad, ModifiedDate)
    VALUES (@ClienteID, @CantidadMeses, @FechaInicio, 250, GETDATE());
END;


--Ejemplo de uso 
EXEC sp_InscribirCliente 
    @Nombre = 'Carlos', 
    @Apellido = 'Gómez', 
    @Telefono = 76543210, 
    @CantidadMeses = 6, 
    @FechaInicio = '2025-04-01';


--2. Realizar un pago de un cliente con la opcion de aplicar un descuento 
--Ya esta creado y ejecutado
CREATE PROCEDURE sp_RegistrarPago
    @InscripcionID INT,
    @Fecha DATE,
    @Total DECIMAL(10,2),
    @DescuentoID INT = NULL
AS
BEGIN
    DECLARE @Porcentaje DECIMAL(5,2) = 0;
    DECLARE @TotalFinal DECIMAL(10,2);

    -- Obtener el porcentaje de descuento si se aplica
    IF @DescuentoID IS NOT NULL
    BEGIN
        SELECT @Porcentaje = Porcentaje FROM DESCUENTOS WHERE DescuentoID = @DescuentoID;
    END

    -- Calcular total final aplicando el descuento
    SET @TotalFinal = @Total - (@Total * @Porcentaje / 100);

    -- Insertar el pago
    INSERT INTO PAGOS (InscripcionID, Fecha, Total, DescuentoID, TotalFinal, ModifiedDate)
    VALUES (@InscripcionID, @Fecha, @Total, @DescuentoID, @TotalFinal, GETDATE());
END;
--EJEMPLO DE USO 
EXEC sp_RegistrarPago @InscripcionID = 1, @Fecha = '2025-04-04', @Total = 1000, @DescuentoID = 2;


-- 3 . registrar la asistencia de un cliente a un servicio
--en una fecha y hora en especifico
--Ya esta creado y ejecutado
CREATE PROCEDURE sp_RegistrarAsistencia
    @InscripcionID INT,
    @ServicioID INT,
    @Fecha DATE,
    @HoraIngreso TIME
AS
BEGIN
    INSERT INTO ASISTENCIA (InscripcionI0D, ServicioID, Fecha, HoraIngreso, ModifiedDate)
    VALUES (@InscripcionID, @ServicioID, @Fecha, @HoraIngreso, GETDATE());
END;

--EJEMPLO DE USO 
EXEC sp_RegistrarAsistencia @InscripcionID = 1, @ServicioID = 3, @Fecha = '2025-04-03', @HoraIngreso = '08:30:00';

