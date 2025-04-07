import tkinter as tk
from tkinter import messagebox
import connections
import recepcionista.menu
import gerente.menu
import dba.menu

import config_window

def getUserRole(conn):
    cursor = conn.cursor()
    cursor.execute("""
        SELECT r.name
        FROM sys.database_principals u
        JOIN sys.database_role_members rm ON u.principal_id = rm.member_principal_id
        JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
        WHERE u.name = USER_NAME();
    """)
    roles = [row[0] for row in cursor.fetchall()]
    cursor.close()
    if 'db_owner' in roles: return 'dba'
    elif 'db_datareader' in roles: return 'gerente'
    elif 'db_datawriter' in roles: return 'recepcionista'
    else: return None

def login():
    user = entry_usuario.get()
    password = entry_contraseña.get()

    try:
        conn = connections.open_connection(user, password)
        rol = getUserRole(conn)

        if rol != None:
            login_window.destroy()
            openInterfaceByRol(conn, rol)
        else:
            messagebox.showerror("Usuario inválido", "Usuario no registrado en el sistema.")
    except Exception as e:
        messagebox.showerror("Error de conexión", f"No se pudo conectar a la base de datos: \n{e}")
    
def openInterfaceByRol(conn, rol):
    root = tk.Tk()
    if rol == 'recepcionista': recepcionista.menu.showMenu(root, conn)
    elif rol == 'gerente': gerente.menu.showMenu(root, conn)
    elif rol == 'dba': dba.menu.showMenu(root, conn)
    root.mainloop()

login_window = tk.Tk()
login_window.title("Login - Sistema de Gimnasio")
config_window.centrar(login_window, 340, 200) # login_window.geometry("300x200")

tk.Label(login_window, text="Usuario:").pack(pady=5)
entry_usuario = tk.Entry(login_window)
entry_usuario.pack(pady=5)

tk.Label(login_window, text="Contraseña:").pack(pady=5)
entry_contraseña = tk.Entry(login_window, show="*")
entry_contraseña.pack(pady=5)

tk.Button(login_window, text="Ingresar", command=login).pack(pady=10)

login_window.mainloop()