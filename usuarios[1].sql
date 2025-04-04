
-- Crear logins
CREATE LOGIN usuario_recepcionista WITH PASSWORD = 'Recepcionista123.';
CREATE LOGIN usuario_gerente WITH PASSWORD = 'Gerente123.';
CREATE LOGIN usuario_dba WITH PASSWORD = 'Dba123.';

-- Asignar el rol sysadmin al DBA 
ALTER SERVER ROLE sysadmin ADD MEMBER usuario_dba;

-- Crear los usuarios
USE Gym;
CREATE USER recepcionista1 FOR LOGIN usuario_recepcionista;
CREATE USER gerente1 FOR LOGIN usuario_gerente;
CREATE USER dba1 FOR LOGIN usuario_dba;

-- 5. Asignar roles de base de datos
EXEC sp_addrolemember 'db_datawriter', 'recepcionista1';
EXEC sp_addrolemember 'db_datareader', 'gerente1';
EXEC sp_addrolemember 'db_owner', 'dba1';

/*
-- Para verificar que se agregaron, NO agregar a la documentación
USE Gym;
GO
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
    AND dp.name NOT IN ('dbo', 'guest', 'INFORMATION_SCHEMA', 'sys');*/
