USE Gym;
GO

-- 1.Boton Despedir a un Entrenador
CREATE PROCEDURE sp_depedir_entrenador
	@CI INT,
	@FechaDespido DATE
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION

		IF NOT EXISTS (SELECT 1 FROM ENTRENADORES WHERE CI = @CI)
		BEGIN
			THROW 50001, 'No existe ningún entrenador con ese CI.', 1;
		END

		IF @FechaDespido < (SELECT FechaInicio FROM ENTRENADORES WHERE CI = @CI)
		BEGIN
			THROW 50002, 'La fecha de despido debe ser posterior al del inicio del contrato.', 1;
		END

		UPDATE ENTRENADORES
		SET FechaFin = @FechaDespido
		WHERE CI = @CI

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF XACT_STATE() <> 0
			ROLLBACK TRANSACTION;
		THROW;
	END CATCH
END