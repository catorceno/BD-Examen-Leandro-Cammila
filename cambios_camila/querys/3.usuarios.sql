
ALTER LOGIN usuario_recepcionista WITH PASSWORD = 'Recepcionista123.';
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
GRANT EXECUTE ON SCHEMA::dbo TO recepcionista;
EXEC sp_addrolemember 'db_datareader', 'gerente';
EXEC sp_addrolemember 'db_owner', 'dba';


SELECT r.name
        FROM sys.database_principals u
        JOIN sys.database_role_members rm ON u.principal_id = rm.member_principal_id
        JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
        WHERE u.name = 'recepcionista';


SELECT name, type_desc, create_date 
FROM sys.database_principals 
WHERE type IN ('S', 'U')
-- AND name NOT LIKE 'db_%' -- Opcional: filtra usuarios internos del sistema
ORDER BY name;



SELECT 
    dp.name AS Usuario,
    dp.type_desc AS Tipo,
    rp.name AS Rol
FROM 
    sys.database_principals dp
LEFT JOIN 
    sys.database_role_members drm ON dp.principal_id = drm.member_principal_id
LEFT JOIN 
    sys.database_principals rp ON drm.role_principal_id = rp.principal_id
WHERE 
    dp.type IN ('S', 'U') -- S = SQL user, U = Windows user
    AND dp.name NOT IN ('dbo', 'guest', 'INFORMATION_SCHEMA', 'sys');