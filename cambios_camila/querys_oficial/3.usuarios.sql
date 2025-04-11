
CREATE LOGIN usuario_recepcionista WITH PASSWORD = 'Recepcionista123.';
CREATE LOGIN usuario_gerente WITH PASSWORD = 'Gerente123.';
CREATE LOGIN usuario_dba WITH PASSWORD = 'Dba123.'

USE Gym;
GO
CREATE USER recepcionista FOR LOGIN usuario_recepcionista
CREATE USER gerente FOR LOGIN usuario_gerente
CREATE USER dba FOR LOGIN usuario_dba

EXEC sp_addrolemember 'db_datawriter', 'recepcionista';
GRANT SELECT ON dbo.PAGOS TO recepcionista
GRANT SELECT ON dbo.ASISTENCIA TO recepcionista
GRANT SELECT ON dbo.DESCUENTOS TO recepcionista
GRANT SELECT ON dbo.SERVICIOS TO recepcionista
GRANT SELECT ON dbo.CLIENTES TO recepcionista
GRANT SELECT ON dbo.INSCRIPCION TO recepcionista
GRANT EXECUTE ON SCHEMA::dbo TO recepcionista;
EXEC sp_addrolemember 'db_datareader', 'gerente';
EXEC sp_addrolemember 'db_owner', 'dba';