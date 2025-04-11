import tkinter as tk
from tkinter import ttk, messagebox
from datetime import datetime, date
import config_window
from recepcionista.inscripcion import add_date_field

def agregarPago(conn):
    window = tk.Toplevel()
    #config_window.centrar(window, 300, 240)
    window.title("Agregar Pago")

    # CI
    tk.Label(window, text="CI").grid(row=0, column=0, padx=10, pady=5, sticky="e")
    ci_var = tk.StringVar()
    tk.Entry(window, textvariable=ci_var).grid(row=0, column=1, padx=10, pady=5)

    # Fecha (con checkbox "Usar fecha de hoy"), ahora el label es "Fecha"
    fecha_var, usar_hoy = add_date_field(window, 1, label_text="Fecha")

    # Monto
    tk.Label(window, text="Monto").grid(row=3, column=0, padx=10, pady=5, sticky="e")
    monto_var = tk.StringVar()
    tk.Entry(window, textvariable=monto_var).grid(row=3, column=1, padx=10, pady=5)

    def on_save():
        try:
            ci = int(ci_var.get())
            monto = int(monto_var.get())
            fecha = fecha_var.get()
            if not usar_hoy.get():
                # valida formato YYYY-MM-DD
                datetime.strptime(fecha, "%Y-%m-%d")

            cursor = conn.cursor()
            cursor.execute("EXEC sp_agregar_pago ?, ?, ?", ci, fecha, monto)
            conn.commit()
            messagebox.showinfo("Éxito", "Pago agregado correctamente.")
            window.destroy()
        except Exception as e:
            messagebox.showerror("Error", str(e))

    tk.Button(window, text="Guardar", command=on_save)\
      .grid(row=4, columnspan=2, pady=15)

def buscarPagos(conn):
    window = tk.Toplevel()
    #config_window.centrar(window, 600, 400)
    window.title("Buscar Pagos")

    # CI
    tk.Label(window, text="CI").grid(row=0, column=0, padx=10, pady=5, sticky="e")
    ci_var = tk.StringVar()
    tk.Entry(window, textvariable=ci_var).grid(row=0, column=1, padx=10, pady=5)

    # Botón Buscar
    def on_search():
        try:
            ci = int(ci_var.get())
            cursor = conn.cursor()
            cursor.execute("EXEC sp_buscar_pagos ?", ci)
            rows = cursor.fetchall()

            # Limpia la tabla
            for item in tree.get_children():
                tree.delete(item)

            # Inserta resultados formateados
            for row in rows:
                # row == (CI, Nombre, Apellido, FechaPago, Monto)
                ci_val, nombre, apellido, fecha_pago, monto = row

                # Formatear FechaPago
                if isinstance(fecha_pago, (date, datetime)):
                    fecha_str = fecha_pago.strftime('%Y-%m-%d')
                else:
                    fecha_str = str(fecha_pago)

                tree.insert("", "end", values=(
                    ci_val,
                    nombre,
                    apellido,
                    fecha_str,
                    monto
                ))

        except Exception as e:
            messagebox.showerror("Error", str(e))

    tk.Button(window, text="Buscar", command=on_search).grid(row=0, column=2, padx=10)

    # Tabla de resultados
    cols = ("CI", "Nombre", "Apellido", "FechaPago", "Monto")
    tree = ttk.Treeview(window, columns=cols, show="headings")
    for c in cols:
        tree.heading(c, text=c)
        tree.column(c, width=100, anchor="center")
    tree.grid(row=1, column=0, columnspan=3, padx=10, pady=10, sticky="nsew")

    window.grid_rowconfigure(1, weight=1)
    window.grid_columnconfigure(1, weight=1)

def consultarDeuda(conn):
    window = tk.Toplevel()
    #config_window.centrar(window, 600, 340)
    window.title("Consultar Deuda")

    # CI
    tk.Label(window, text="CI").grid(row=0, column=0, padx=10, pady=5, sticky="e")
    ci_var = tk.StringVar()
    tk.Entry(window, textvariable=ci_var).grid(row=0, column=1, padx=10, pady=5)

    # Botón Consultar
    def on_check():
        try:
            ci = int(ci_var.get())
            cursor = conn.cursor()
            cursor.execute("EXEC sp_consultar_deuda ?", ci)
            row = cursor.fetchone()
            if not row:
                messagebox.showinfo("Sin datos", "No se encontraron datos de pagos.")
                return

            # Etiquetas con los campos resultantes
            labels = [
                "CI", "Nombre", "Apellido", "Teléfono",
                "Fecha Inscripción", "Fecha Fin",
                "Total", "Monto Pagado", "Deuda"
            ]
            for i, val in enumerate(row):
                tk.Label(window, text=f"{labels[i]}:").grid(
                    row=i+1, column=0, padx=10, pady=2, sticky="e"
                )
                tk.Label(window, text=str(val)).grid(
                    row=i+1, column=1, padx=10, pady=2, sticky="w"
                )

        except Exception as e:
            messagebox.showerror("Error", str(e))

    tk.Button(window, text="Consultar", command=on_check)\
      .grid(row=0, column=2, padx=10)