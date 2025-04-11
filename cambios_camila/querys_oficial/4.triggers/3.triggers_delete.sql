USE Gym;
GO

-- 1.No permitir borrar un cliente si tiene inscripciones
CREATE TRIGGER trg_preventDeleteClient
ON CLIENTES
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM INSCRIPCION WHERE ClienteID IN (SELECT ClienteID FROM deleted))
    BEGIN
        RAISERROR ('No se puede eliminar el cliente porque tiene inscripciones asociadas.', 16, 1);
        ROLLBACK TRANSACTION;
    END
	ELSE
	BEGIN
		DELETE FROM CLIENTES WHERE ClienteID IN (SELECT ClienteID FROM deleted);
	END
END;

-- 2.No permitir borrar un servicio si está referenciado en otra tabla
CREATE TRIGGER trg_preventDeleteServicio
ON SERVICIOS
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM INVENTARIO WHERE ServicioID IN (SELECT ServicioID FROM deleted))
    BEGIN
        RAISERROR ('No se puede eliminar el servicio porque tiene equipos asociados.', 16, 1);
        ROLLBACK TRANSACTION;
    END
	IF EXISTS (SELECT 1 FROM ENTRENADORES WHERE ServicioID IN (SELECT ServicioID FROM deleted))
    BEGIN
        RAISERROR ('No se puede eliminar el servicio porque tiene entrenadores en ese servicio.', 16, 1);
        ROLLBACK TRANSACTION;
    END
	IF EXISTS (SELECT 1 FROM ASISTENCIA WHERE ServicioID IN (SELECT ServicioID FROM deleted))
    BEGIN
        RAISERROR ('No se puede eliminar el servicio porque tiene asistencias registradas.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    DELETE FROM SERVICIOS WHERE ServicioID IN (SELECT ServicioID FROM deleted);
END;

-- 3.No permitir borrar una inscripcion si tiene pagos o asistencias asociadas
CREATE TRIGGER trg_preventDeleteInscripcion
ON INSCRIPCION
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM PAGOS WHERE InscripcionID IN (SELECT InscripcionID FROM deleted))
    BEGIN
        RAISERROR ('No se puede eliminar la inscripción porque tiene pagos registrados.', 16, 1);
        ROLLBACK TRANSACTION;
    END
	IF EXISTS (SELECT 1 FROM ASISTENCIA WHERE InscripcionID IN (SELECT InscripcionID FROM deleted))
    BEGIN
        RAISERROR ('No se puede eliminar la inscripción porque tiene asistencias asociadas.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    DELETE FROM INSCRIPCION WHERE InscripcionID IN (SELECT InscripcionID FROM deleted);
END;