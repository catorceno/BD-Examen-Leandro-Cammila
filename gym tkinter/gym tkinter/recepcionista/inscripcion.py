# recepcionista/inscripcion.py
import tkinter as tk
from tkinter import messagebox
from tkinter import simpledialog
from datetime import datetime

def cliente_nuevo(conn):
    ventana = tk.Toplevel()
    ventana.title("Nuevo Cliente")
    
    campos = {
        "Nombre": tk.StringVar(),
        "Apellido": tk.StringVar(),
        "Telefono": tk.StringVar(),
        "Cantidad de Meses": tk.IntVar(),
        "Fecha Inicio (YYYY-MM-DD)": tk.StringVar()
    }

    for i, (label, var) in enumerate(campos.items()):
        tk.Label(ventana, text=label).grid(row=i, column=0, padx=10, pady=5, sticky="e")
        tk.Entry(ventana, textvariable=var).grid(row=i, column=1, padx=10, pady=5)

    def guardar_cliente():
        try:
            cursor = conn.cursor()
            # Insertar en CLIENTE
            cursor.execute("""
                INSERT INTO CLIENTE (Nombre, Apellido, Telefono)
                VALUES (?, ?, ?)
            """, campos["Nombre"].get(), campos["Apellido"].get(), int(campos["Telefono"].get()))
            conn.commit()

            cliente_id = cursor.execute("SELECT SCOPE_IDENTITY()").fetchval()

            # Insertar en INSCRIPCION
            cursor.execute("""
                INSERT INTO INSCRIPCION (ClienteID, CantidadMeses, FechaInicio)
                VALUES (?, ?, ?)
            """, cliente_id, campos["Cantidad de Meses"].get(), campos["Fecha Inicio (YYYY-MM-DD)"].get())
            conn.commit()

            messagebox.showinfo("Éxito", "Cliente e inscripción agregados correctamente.")
            ventana.destroy()
        except Exception as e:
            messagebox.showerror("Error", str(e))

    tk.Button(ventana, text="Guardar", command=guardar_cliente).grid(row=len(campos), columnspan=2, pady=10)

def cliente_existente(conn):
    ventana = tk.Toplevel()
    ventana.title("Cliente Existente")

    cliente_id_var = tk.StringVar()
    meses_var = tk.IntVar()
    fecha_inicio_var = tk.StringVar()

    tk.Label(ventana, text="ID Cliente").grid(row=0, column=0, padx=10, pady=5)
    tk.Entry(ventana, textvariable=cliente_id_var).grid(row=0, column=1)

    tk.Label(ventana, text="Cantidad de Meses").grid(row=1, column=0, padx=10, pady=5)
    tk.Entry(ventana, textvariable=meses_var).grid(row=1, column=1)

    tk.Label(ventana, text="Fecha Inicio (YYYY-MM-DD)").grid(row=2, column=0, padx=10, pady=5)
    tk.Entry(ventana, textvariable=fecha_inicio_var).grid(row=2, column=1)

    def inscribir_cliente():
        try:
            cursor = conn.cursor()
            cursor.execute("""
                INSERT INTO INSCRIPCION (ClienteID, CantidadMeses, FechaInicio)
                VALUES (?, ?, ?)
            """, int(cliente_id_var.get()), meses_var.get(), fecha_inicio_var.get())
            conn.commit()
            messagebox.showinfo("Éxito", "Inscripción realizada.")
            ventana.destroy()
        except Exception as e:
            messagebox.showerror("Error", str(e))

    tk.Button(ventana, text="Inscribir", command=inscribir_cliente).grid(row=3, columnspan=2, pady=10)
