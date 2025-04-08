import tkinter as tk
from tkinter import ttk, messagebox
from datetime import datetime, date, time
import config_window

def agregarAsistencia(conn):
    window = tk.Toplevel()
    #config_window.centrar(window, 350, 200)
    window.title("Agregar Asistencia")

    # CI
    tk.Label(window, text="CI").grid(row=0, column=0, padx=10, pady=5, sticky="e")
    ci_var = tk.StringVar()
    tk.Entry(window, textvariable=ci_var).grid(row=0, column=1, padx=10, pady=5)

    # Servicio
    tk.Label(window, text="Servicio").grid(row=1, column=0, padx=10, pady=5, sticky="e")
    try:
        cur = conn.cursor()
        cur.execute("SELECT Nombre FROM SERVICIOS")
        servicios = [r[0] for r in cur.fetchall()]
    except Exception as e:
        messagebox.showerror("Error al cargar servicios", str(e))
        servicios = []
    servicio_var = tk.StringVar()
    combo_servicio = ttk.Combobox(
        window,
        textvariable=servicio_var,
        values=servicios,
        state="readonly" if servicios else "disabled"
    )
    combo_servicio.grid(row=1, column=1, padx=10, pady=5)
    if servicios:
        servicio_var.set(servicios[0])

    def on_save():
        try:
            ci = int(ci_var.get())
            servicio = servicio_var.get()
            if not servicio:
                raise ValueError("Debe seleccionar un servicio.")

            cursor = conn.cursor()
            # Ahora solo pasamos CI y Servicio; la fecha y hora las fija el SP
            cursor.execute(
                "EXEC sp_agregar_asistencia ?, ?",
                ci, servicio
            )
            conn.commit()
            messagebox.showinfo("Éxito", "Asistencia registrada correctamente.")
            window.destroy()
        except Exception as e:
            messagebox.showerror("Error", str(e))

    tk.Button(window, text="Guardar", command=on_save)\
      .grid(row=2, columnspan=2, pady=20)

def buscarAsistencias(conn):
    window = tk.Toplevel()
    #config_window.centrar(window, 600, 400)
    window.title("Buscar Asistencias")

    # CI
    tk.Label(window, text="CI").grid(row=0, column=0, padx=10, pady=5, sticky="e")
    ci_var = tk.StringVar()
    tk.Entry(window, textvariable=ci_var).grid(row=0, column=1, padx=10, pady=5)

    # Botón Buscar
    def on_search():
        try:
            ci = int(ci_var.get())
            cur = conn.cursor()
            cur.execute("EXEC sp_buscar_asistencias ?", ci)
            rows = cur.fetchall()

            # Limpiar tabla
            for item in tree.get_children():
                tree.delete(item)

            # Insertar resultados formateados
            for r in rows:
                ci_val, nombre, apellido, servicio, fecha, hora = r

                # Formatear fecha
                fecha_str = fecha.strftime('%Y-%m-%d') if isinstance(fecha, (date, datetime)) else str(fecha)
                # Formatear hora
                hora_str = hora.strftime('%H:%M') if isinstance(hora, time) else str(hora)

                tree.insert("", "end", values=(
                    ci_val, nombre, apellido, servicio, fecha_str, hora_str
                ))
        except Exception as e:
            messagebox.showerror("Error", str(e))

    tk.Button(window, text="Buscar", command=on_search).grid(row=0, column=2, padx=10)

    # Tabla de resultados
    cols = ("CI", "Nombre", "Apellido", "Servicio", "Fecha", "HoraIngreso")
    tree = ttk.Treeview(window, columns=cols, show="headings")
    for c in cols:
        tree.heading(c, text=c)
        tree.column(c, width=100, anchor="center")
    tree.grid(row=1, column=0, columnspan=3, padx=10, pady=10, sticky="nsew")

    window.grid_rowconfigure(1, weight=1)
    window.grid_columnconfigure(1, weight=1)