# main.py
import tkinter as tk
from tkinter import messagebox
import connections
from recepcionista.menu_recepcionista import mostrar_menu
from gerente.menu_gerente import crear_menu_gerente
from dba.menu_dba import crear_menu_dba

# Usuarios válidos y sus roles
USUARIOS = {
    "usuario_recepcionista": "recepcionista",
    "usuario_gerente": "gerente",
    "usuario_dba": "dba"
}

def login():
    user = entry_usuario.get()
    password = entry_contrasena.get()

    rol = USUARIOS.get(user)

    if rol:
        try:
            conn = connections.open_connection(user, password)
            messagebox.showinfo("Login exitoso", f"Bienvenido, rol: {rol.capitalize()}")

            login_window.destroy()
            abrir_interfaz_por_rol(rol, conn)

        except Exception as e:
            messagebox.showerror("Error de conexión", f"No se pudo conectar a la base de datos:\n{e}")
    else:
        messagebox.showwarning("Usuario inválido", "Usuario no registrado en el sistema.")

def abrir_interfaz_por_rol(rol, conn):
    root = tk.Tk()
    if rol == "recepcionista":
        mostrar_menu(root, conn)
    elif rol == "gerente":
        crear_menu_gerente(root, conn)
    elif rol == "dba":
        crear_menu_dba(root, conn)
    root.mainloop()

# Interfaz de login
login_window = tk.Tk()
login_window.title("Login - Sistema de Gimnasio")
login_window.geometry("300x200")

tk.Label(login_window, text="Usuario:").pack(pady=5)
entry_usuario = tk.Entry(login_window)
entry_usuario.pack(pady=5)

tk.Label(login_window, text="Contraseña:").pack(pady=5)
entry_contrasena = tk.Entry(login_window, show="*")
entry_contrasena.pack(pady=5)

tk.Button(login_window, text="Ingresar", command=login).pack(pady=10)

login_window.mainloop()


"""# main.py
import tkinter as tk
from tkinter import messagebox
import connections
import pyodbc

def verificar_credenciales():
    user = entry_usuario.get()
    password = entry_contrasena.get()
    
    try:
        conn = connections.open_connection(user, password)
        cursor = conn.cursor()
        cursor.execute("SELECT USER_NAME();")
        db_user = cursor.fetchone()[0]

        # Identificar tipo de usuario según nombre de usuario
        if db_user.startswith("recepcionista"):
            abrir_menu_recepcionista(conn)
        elif db_user.startswith("gerente"):
            abrir_menu_gerente(conn)
        elif db_user.startswith("dba"):
            abrir_menu_dba(conn)
        else:
            messagebox.showerror("Error", "Usuario no autorizado.")
    except pyodbc.Error as e:
        messagebox.showerror("Error de conexión", str(e))

def abrir_menu_recepcionista(conn):
    root.destroy()
    import recepcionista_menu
    recepcionista_menu.mostrar_menu(conn)

def abrir_menu_gerente(conn):
    root.destroy()
    import gerente_menu
    gerente_menu.mostrar_menu(conn)

def abrir_menu_dba(conn):
    root.destroy()
    import dba_menu
    dba_menu.mostrar_menu(conn)

# --- Interfaz de Login ---
root = tk.Tk()
root.title("Login Gym")
root.geometry("300x200")

tk.Label(root, text="Usuario").pack(pady=5)
entry_usuario = tk.Entry(root)
entry_usuario.pack()

tk.Label(root, text="Contraseña").pack(pady=5)
entry_contrasena = tk.Entry(root, show='*')
entry_contrasena.pack()

btn_ingresar = tk.Button(root, text="Ingresar", command=verificar_credenciales)
btn_ingresar.pack(pady=20)

root.mainloop()"""
