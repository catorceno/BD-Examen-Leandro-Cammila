USE Gym;
--CREACION DE LOS TERCEROS TRIGGERS 

-- Actualizar modifiedDate en todas las tablas
-- cliente
CREATE TRIGGER trg_clienteModifiedDate
ON CLIENTE
AFTER UPDATE
AS
BEGIN
    UPDATE CLIENTE
    SET ModifiedDate = GETDATE()
    FROM CLIENTE c
    INNER JOIN inserted i ON c.ClienteID = i.ClienteID;
END;

-- inscripcion
CREATE TRIGGER trg_inscripcionModifiedDate
ON INSCRIPCION
AFTER UPDATE
AS
BEGIN
    UPDATE INSCRIPCION
    SET ModifiedDate = GETDATE()
    FROM INSCRIPCION i
    INNER JOIN inserted i2 ON i.InscripcionID = i2.InscripcionID;
END;

-- pagos
CREATE TRIGGER trg_pagosModifiedDate
ON PAGOS
AFTER UPDATE
AS
BEGIN
    UPDATE PAGOS
    SET ModifiedDate = GETDATE()
    FROM PAGOS p
    INNER JOIN inserted i ON p.PagoID = i.PagoID;
END;

-- asistencia
CREATE TRIGGER trg_asistenciaModifiedDate
ON ASISTENCIA
AFTER UPDATE
AS
BEGIN
    UPDATE ASISTENCIA
    SET ModifiedDate = GETDATE()
    FROM ASISTENCIA a
    INNER JOIN inserted i ON a.AsistenciaID = i.AsistenciaID;
END;

-- servicio
CREATE TRIGGER trg_servicioModifiedDate
ON SERVICIO
AFTER UPDATE
AS
BEGIN
    UPDATE SERVICIO
    SET ModifiedDate = GETDATE()
    FROM SERVICIO s
    INNER JOIN inserted i ON s.ServicioID = i.ServicioID;
END;

-- entrenadores
CREATE TRIGGER trg_entrenadoresModifiedDate
ON ENTRENADORES
AFTER UPDATE
AS
BEGIN
    UPDATE ENTRENADORES
    SET ModifiedDate = GETDATE()
    FROM ENTRENADORES e
    INNER JOIN inserted i ON e.EntrenadorID = i.EntrenadorID;
END;

-- inventario
CREATE TRIGGER trg_inventarioModifiedDate
ON INVENTARIO
AFTER UPDATE
AS
BEGIN
    UPDATE INVENTARIO
    SET ModifiedDate = GETDATE()
    FROM INVENTARIO i
    INNER JOIN inserted i2 ON i.EquipoID = i2.EquipoID;
END;

-- descuentos
CREATE TRIGGER trg_descuentosModifiedDate
ON DESCUENTOS
AFTER UPDATE
AS
BEGIN
    UPDATE DESCUENTOS
    SET ModifiedDate = GETDATE()
    FROM DESCUENTOS d
    INNER JOIN inserted i ON d.DescuentoID = i.DescuentoID;
END;