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
            # Intentamos obtener la información de deuda a través del stored procedure
            cursor.execute("EXEC sp_consultar_deuda ?", ci)
            row = cursor.fetchone()

            if row:
                # Si se encontró un registro, nos aseguramos de que "Monto Pagado" (posición 7) no sea None
                row = list(row)
                if row[7] is None:
                    row[7] = 0
                datos = row
            else:
                # Si no se encontraron pagos, obtenemos información del cliente y su última inscripción
                # Consulta la información básica del cliente
                cursor.execute("SELECT CI, Nombre, Apellido, Telefono FROM CLIENTES WHERE CI = ?", ci)
                client_info = cursor.fetchone()
                if not client_info:
                    messagebox.showinfo("Sin datos", "No se encontraron datos para este cliente.")
                    return

                # Consulta la última inscripción del cliente
                cursor.execute("""
                    SELECT TOP 1 i.FechaInicio, i.FechaFin, i.Total 
                    FROM INSCRIPCION i
                    INNER JOIN CLIENTES c ON i.ClienteID = c.ClienteID
                    WHERE c.CI = ?
                    ORDER BY i.InscripcionID DESC
                    """, ci)
                insc_info = cursor.fetchone()
                if not insc_info:
                    messagebox.showinfo("Sin datos", "El cliente no tiene inscripciones registradas.")
                    return

                # Armar la tupla con el siguiente orden:
                # "CI", "Nombre", "Apellido", "Teléfono", "Fecha Inscripción", "Fecha Fin", "Total", "Monto Pagado", "Deuda"
                # Como no hay pagos, se asume que el "Monto Pagado" es 0 y la "Deuda" es igual a Total.
                fecha_inicio, fecha_fin, total = insc_info
                datos = list(client_info) + [fecha_inicio, fecha_fin, total, 0, total]

            # Lista de labels para mostrar en la interfaz
            labels = [
                "CI", "Nombre", "Apellido", "Teléfono",
                "Fecha Inscripción", "Fecha Fin",
                "Total", "Monto Pagado", "Deuda"
            ]
            # Limpiar posibles etiquetas previas (opcional)
            for widget in window.grid_slaves():
                if int(widget.grid_info()["row"]) > 0:
                    widget.destroy()

            # Mostrar cada dato en la ventana
            for i, val in enumerate(datos):
                tk.Label(window, text=f"{labels[i]}:").grid(
                    row=i+1, column=0, padx=10, pady=2, sticky="e"
                )
                tk.Label(window, text=str(val)).grid(
                    row=i+1, column=1, padx=10, pady=2, sticky="w"
                )

        except Exception as e:
            messagebox.showerror("Error", str(e))

    tk.Button(window, text="Consultar", command=on_check).grid(row=0, column=2, padx=10)