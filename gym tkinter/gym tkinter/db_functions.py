from connections import open_connection, close_connection

def obtener_roles_usuario(usuario, password):
    try:
        conn = open_connection(usuario, password)
        cursor = conn.cursor()

        cursor.execute("""
            SELECT dp.name
            FROM sys.database_principals dp
            INNER JOIN sys.database_role_members drm ON dp.principal_id = drm.role_principal_id
            INNER JOIN sys.database_principals dp2 ON drm.member_principal_id = dp2.principal_id
            WHERE dp2.name = ?
        """, usuario)

        roles = [row[0] for row in cursor.fetchall()]
        return roles

    except Exception as e:
        raise e

    finally:
        close_connection(conn)