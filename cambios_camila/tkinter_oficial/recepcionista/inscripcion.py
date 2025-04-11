import tkinter as tk
from tkinter import ttk, messagebox
from datetime import datetime
import config_window

def add_date_field(window, row, label_text="Fecha Inicio"):
    fecha_var = tk.StringVar()
    tk.Label(window, text=label_text).grid(
        row=row, column=0, padx=10, pady=5, sticky="e"
    )
    entry = tk.Entry(window, textvariable=fecha_var)
    entry.grid(row=row, column=1, padx=10, pady=5)

    usar_hoy = tk.BooleanVar()
    def toggle():
        if usar_hoy.get():
            fecha_var.set(datetime.today().strftime('%Y-%m-%d'))
            entry.config(state='disabled')
        else:
            fecha_var.set('')
            entry.config(state='normal')

    tk.Checkbutton(
        window,
        text="Usar fecha de hoy",
        variable=usar_hoy,
        command=toggle
    ).grid(row=row+1, columnspan=2, pady=(0,10))

    return fecha_var, usar_hoy


def add_discount_field(window, row, conn):
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT Nombre FROM DESCUENTOS WHERE Estado = 'Activo'")
        descuentos = [r[0] for r in cursor.fetchall()]
    except Exception as e:
        messagebox.showerror("Error al cargar descuentos", str(e))
        descuentos = []

    var_descuento = tk.StringVar()
    tk.Label(window, text="Descuento").grid(
        row=row, column=0, padx=10, pady=5, sticky="e"
    )
    combo = ttk.Combobox(
        window,
        textvariable=var_descuento,
        values=descuentos,
        state="readonly" if descuentos else "disabled"
    )
    combo.grid(row=row, column=1, padx=10, pady=5)
    if descuentos:
        var_descuento.set(descuentos[0])

    usar_sin_descuento = tk.BooleanVar(value=(not descuentos))
    def toggle_desc():
        if usar_sin_descuento.get():
            var_descuento.set('')
            combo.config(state='disabled')
        else:
            combo.config(state='readonly')
            if descuentos:
                var_descuento.set(descuentos[0])

    tk.Checkbutton(
        window,
        text="Sin Descuento",
        variable=usar_sin_descuento,
        command=toggle_desc
    ).grid(row=row+1, columnspan=2, pady=(0,10))

    return var_descuento, usar_sin_descuento

def clienteNuevo(conn):
    window = tk.Toplevel()
    #config_window.centrar(window, 275, 360)
    window.title("Nuevo Cliente")

    # Campos básicos
    fields = ["CI", "Nombre", "Apellido", "Telefono", "Cantidad de Meses"]
    vars = {f: tk.StringVar() for f in fields}
    for i, f in enumerate(fields):
        tk.Label(window, text=f).grid(
            row=i, column=0, padx=10, pady=5, sticky="e"
        )
        tk.Entry(window, textvariable=vars[f]).grid(
            row=i, column=1, padx=10, pady=5
        )

    # Fecha Inicio
    row = len(fields)
    fecha_var, usar_hoy = add_date_field(window, row)
    row += 2

    # Descuento
    desc_var, usar_sin = add_discount_field(window, row, conn)
    row += 2

    # Botón Guardar
    def on_save():
        try:
            # Validar fecha
            fecha = fecha_var.get()
            if not usar_hoy.get():
                datetime.strptime(fecha, "%Y-%m-%d")

            # Determinar descuento
            descuento_sel = None if usar_sin.get() else desc_var.get()

            # Llamada al SP
            cursor = conn.cursor()
            cursor.execute(
                "EXEC sp_inscribir_nuevo_cliente ?, ?, ?, ?, ?, ?, ?",
                int(vars["CI"].get()),
                vars["Nombre"].get(),
                vars["Apellido"].get(),
                int(vars["Telefono"].get()),
                int(vars["Cantidad de Meses"].get()),
                fecha,
                descuento_sel
            )
            conn.commit()
            messagebox.showinfo("Éxito", "Cliente e inscripción agregados correctamente.")
            window.destroy()
        except Exception as e:
            messagebox.showerror("Error", str(e))

    tk.Button(window, text="Guardar", command=on_save).grid(
        row=row, columnspan=2, pady=15
    )

def clienteExistente(conn):
    window = tk.Toplevel()
    #config_window.centrar(window, 275, 360)
    window.title("Inscribir Cliente Existente")

    # Campos básicos
    fields = ["CI", "Cantidad de Meses"]
    vars = {f: tk.StringVar() for f in fields}
    for i, f in enumerate(fields):
        tk.Label(window, text=f).grid(
            row=i, column=0, padx=10, pady=5, sticky="e"
        )
        tk.Entry(window, textvariable=vars[f]).grid(
            row=i, column=1, padx=10, pady=5
        )

    # Fecha Inicio
    row = len(fields)
    fecha_var, usar_hoy = add_date_field(window, row)
    row += 2

    # Descuento
    desc_var, usar_sin = add_discount_field(window, row, conn)
    row += 2

    # Botón Guardar
    def on_save():
        try:
            # Validar fecha
            fecha = fecha_var.get()
            if not usar_hoy.get():
                datetime.strptime(fecha, "%Y-%m-%d")

            # Determinar descuento
            descuento_sel = None if usar_sin.get() else desc_var.get()

            # Llamada al SP
            cursor = conn.cursor()
            cursor.execute(
                "EXEC sp_inscribir_cliente_existente ?, ?, ?, ?",
                int(vars["CI"].get()),
                int(vars["Cantidad de Meses"].get()),
                fecha,
                descuento_sel
            )
            conn.commit()
            messagebox.showinfo("Éxito", "Inscripción de cliente existente completada.")
            window.destroy()
        except Exception as e:
            messagebox.showerror("Error", str(e))

    tk.Button(window, text="Guardar", command=on_save).grid(
        row=row, columnspan=2, pady=15
    )