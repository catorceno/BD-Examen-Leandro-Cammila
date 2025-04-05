# recepcionista/asistencia.py
import tkinter as tk
from tkinter import messagebox
from tkinter import simpledialog
from datetime import datetime

def agregar_asistencia(conn):
    ventana = tk.Toplevel()
    ventana.title("Agregar Asistencia")

    inscripcion_id = tk.StringVar()
    servicio_id = tk.StringVar()
    fecha = tk.StringVar(value=datetime.now().strftime("%Y-%m-%d"))
    hora_ingreso = tk.StringVar(value=datetime.now().strftime("%H:%M:%S"))

    tk.Label(ventana, text="ID de Inscripción").grid(row=0, column=0, padx=10, pady=5)
    tk.Entry(ventana, textvariable=inscripcion_id).grid(row=0, column=1)

    tk.Label(ventana, text="ID de Servicio").grid(row=1, column=0, padx=10, pady=5)
    tk.Entry(ventana, textvariable=servicio_id).grid(row=1, column=1)

    tk.Label(ventana, text="Fecha (YYYY-MM-DD)").grid(row=2, column=0, padx=10, pady=5)
    tk.Entry(ventana, textvariable=fecha).grid(row=2, column=1)

    tk.Label(ventana, text="Hora Ingreso (HH:MM:SS)").grid(row=3, column=0, padx=10, pady=5)
    tk.Entry(ventana, textvariable=hora_ingreso).grid(row=3, column=1)

    def guardar_asistencia():
        try:
            cursor = conn.cursor()
            cursor.execute("""
                INSERT INTO ASISTENCIA (InscripcionID, ServicioID, Fecha, HoraIngreso)
                VALUES (?, ?, ?, ?)
            """, inscripcion_id.get(), servicio_id.get(), fecha.get(), hora_ingreso.get())
            conn.commit()
            messagebox.showinfo("Éxito", "Asistencia registrada.")
            ventana.destroy()
        except Exception as e:
            messagebox.showerror("Error", str(e))

    tk.Button(ventana, text="Guardar", command=guardar_asistencia).grid(row=4, columnspan=2, pady=10)

def buscar_asistencia(conn):
    inscripcion_id = simpledialog.askinteger("Buscar Asistencia", "Ingrese el ID de Inscripción:")
    fecha = simpledialog.askstring("Buscar Asistencia", "Ingrese la Fecha (YYYY-MM-DD):")
    if not inscripcion_id or not fecha:
        return
    try:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT * FROM ASISTENCIA
            WHERE InscripcionID = ? AND Fecha = ?
        """, inscripcion_id, fecha)
        row = cursor.fetchone()
        if row:
            resultado = "\n".join(f"{desc[0]}: {valor}" for desc, valor in zip(cursor.description, row))
            messagebox.showinfo("Resultado", resultado)
        else:
            messagebox.showinfo("Sin resultados", "No se encontró asistencia.")
    except Exception as e:
        messagebox.showerror("Error", str(e))
