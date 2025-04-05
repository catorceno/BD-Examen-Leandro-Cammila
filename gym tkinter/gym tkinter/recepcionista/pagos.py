# recepcionista/pagos.py
import tkinter as tk
from tkinter import messagebox
from tkinter import simpledialog

def agregar_pago(conn):
    ventana = tk.Toplevel()
    ventana.title("Agregar Pago")

    inscripcion_id = tk.StringVar()
    total = tk.StringVar()
    descuento_id = tk.StringVar()

    tk.Label(ventana, text="ID de Inscripción").grid(row=0, column=0, padx=10, pady=5)
    tk.Entry(ventana, textvariable=inscripcion_id).grid(row=0, column=1)

    tk.Label(ventana, text="Total").grid(row=1, column=0, padx=10, pady=5)
    tk.Entry(ventana, textvariable=total).grid(row=1, column=1)

    tk.Label(ventana, text="ID de Descuento (opcional)").grid(row=2, column=0, padx=10, pady=5)
    tk.Entry(ventana, textvariable=descuento_id).grid(row=2, column=1)

    def guardar_pago():
        try:
            cursor = conn.cursor()
            descuento = None
            total_final = float(total.get())

            if descuento_id.get():
                cursor.execute("SELECT Porcentaje FROM DESCUENTOS WHERE DescuentoID = ?", descuento_id.get())
                row = cursor.fetchone()
                if row:
                    porcentaje = float(row[0])
                    total_final = total_final * (1 - porcentaje / 100)
                    descuento = int(descuento_id.get())

            cursor.execute("""
                INSERT INTO PAGOS (InscripcionID, Fecha, Total, DescuentoID, TotalFinal)
                VALUES (?, GETDATE(), ?, ?, ?)
            """, inscripcion_id.get(), total.get(), descuento, total_final)

            conn.commit()
            messagebox.showinfo("Éxito", "Pago registrado.")
            ventana.destroy()
        except Exception as e:
            messagebox.showerror("Error", str(e))

    tk.Button(ventana, text="Guardar", command=guardar_pago).grid(row=3, columnspan=2, pady=10)

def buscar_pago(conn):
    id_pago = simpledialog.askinteger("Buscar Pago", "Ingrese el ID del Pago:")
    if not id_pago:
        return
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM PAGOS WHERE PagoID = ?", id_pago)
        row = cursor.fetchone()
        if row:
            resultado = "\n".join(f"{desc[0]}: {valor}" for desc, valor in zip(cursor.description, row))
            messagebox.showinfo("Resultado", resultado)
        else:
            messagebox.showinfo("Sin resultados", "No se encontró el pago.")
    except Exception as e:
        messagebox.showerror("Error", str(e))

def consultar_deuda(conn):
    inscripcion_id = simpledialog.askinteger("Consultar Deuda", "Ingrese el ID de Inscripción:")
    if not inscripcion_id:
        return
    try:
        cursor = conn.cursor()
        # Total esperado
        cursor.execute("SELECT PrecioTotal FROM INSCRIPCION WHERE InscripcionID = ?", inscripcion_id)
        total_esperado_row = cursor.fetchone()
        if not total_esperado_row:
            messagebox.showinfo("Sin resultados", "No se encontró la inscripción.")
            return
        total_esperado = total_esperado_row[0]

        # Total pagado
        cursor.execute("SELECT SUM(TotalFinal) FROM PAGOS WHERE InscripcionID = ?", inscripcion_id)
        total_pagado_row = cursor.fetchone()
        total_pagado = total_pagado_row[0] if total_pagado_row[0] else 0

        deuda = total_esperado - total_pagado
        messagebox.showinfo("Deuda", f"Total esperado: {total_esperado}\nPagado: {total_pagado}\nDeuda: {deuda}")
    except Exception as e:
        messagebox.showerror("Error", str(e))
