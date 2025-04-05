# dba/tablas.py
import tkinter as tk
from tkinter import ttk, messagebox, simpledialog

TABLAS = [
    "CLIENTE", "INSCRIPCION", "PAGOS", "DESCUENTOS",
    "ASISTENCIA", "ENTRENADORES", "SERVICIO", "INVENTARIO"
]

def gestionar_tablas(root, conn):
    ventana = tk.Toplevel(root)
    ventana.title("Gestionar Tablas")
    ventana.geometry("700x500")

    tabla_var = tk.StringVar(value=TABLAS[0])

    ttk.Label(ventana, text="Selecciona una tabla:").pack(pady=5)
    combo_tablas = ttk.Combobox(ventana, textvariable=tabla_var, values=TABLAS, state="readonly")
    combo_tablas.pack()

    frame_tabla = tk.Frame(ventana)
    frame_tabla.pack(fill="both", expand=True)

    tree = ttk.Treeview(frame_tabla)
    tree.pack(fill="both", expand=True, side="left")

    scrollbar = ttk.Scrollbar(frame_tabla, orient="vertical", command=tree.yview)
    scrollbar.pack(side="right", fill="y")
    tree.configure(yscrollcommand=scrollbar.set)

    def cargar_datos():
        tree.delete(*tree.get_children())
        tabla = tabla_var.get()

        cursor = conn.cursor()
        cursor.execute(f"SELECT * FROM {tabla}")
        columnas = [column[0] for column in cursor.description]
        tree["columns"] = columnas
        tree["show"] = "headings"
        for col in columnas:
            tree.heading(col, text=col)

        for row in cursor.fetchall():
            tree.insert("", "end", values=row)

    def insertar_dato():
        tabla = tabla_var.get()
        columnas = get_columnas_sin_id(tabla, conn)
        valores = []
        for col in columnas:
            val = simpledialog.askstring("Insertar", f"Ingrese valor para {col}:")
            valores.append(val)

        placeholders = ", ".join(["?"] * len(columnas))
        query = f"INSERT INTO {tabla} ({', '.join(columnas)}) VALUES ({placeholders})"

        try:
            cursor = conn.cursor()
            cursor.execute(query, valores)
            conn.commit()
            messagebox.showinfo("Éxito", "Registro insertado.")
            cargar_datos()
        except Exception as e:
            messagebox.showerror("Error", str(e))

    def editar_dato():
        tabla = tabla_var.get()
        item = tree.selection()
        if not item:
            messagebox.showwarning("Selecciona una fila", "Debes seleccionar un registro para editar.")
            return
        fila = tree.item(item)["values"]
        columnas = get_columnas_completas(tabla, conn)

        nuevos_valores = []
        for i, col in enumerate(columnas):
            nuevo_valor = simpledialog.askstring("Editar", f"{col}:", initialvalue=fila[i])
            nuevos_valores.append(nuevo_valor)

        set_clause = ", ".join([f"{col} = ?" for col in columnas[1:]])
        query = f"UPDATE {tabla} SET {set_clause} WHERE {columnas[0]} = ?"

        try:
            cursor = conn.cursor()
            cursor.execute(query, nuevos_valores[1:] + [nuevos_valores[0]])
            conn.commit()
            messagebox.showinfo("Éxito", "Registro actualizado.")
            cargar_datos()
        except Exception as e:
            messagebox.showerror("Error", str(e))

    def eliminar_dato():
        tabla = tabla_var.get()
        item = tree.selection()
        if not item:
            messagebox.showwarning("Selecciona una fila", "Debes seleccionar un registro para eliminar.")
            return
        fila = tree.item(item)["values"]
        columnas = get_columnas_completas(tabla, conn)

        try:
            cursor = conn.cursor()
            cursor.execute(f"DELETE FROM {tabla} WHERE {columnas[0]} = ?", fila[0:1])
            conn.commit()
            messagebox.showinfo("Éxito", "Registro eliminado.")
            cargar_datos()
        except Exception as e:
            messagebox.showerror("Error", str(e))

    tk.Button(ventana, text="Cargar datos", command=cargar_datos).pack(pady=5)
    tk.Button(ventana, text="Insertar", command=insertar_dato).pack(pady=5)
    tk.Button(ventana, text="Editar", command=editar_dato).pack(pady=5)
    tk.Button(ventana, text="Eliminar", command=eliminar_dato).pack(pady=5)

# Helpers
def get_columnas_completas(tabla, conn):
    cursor = conn.cursor()
    cursor.execute(f"SELECT * FROM {tabla}")
    return [column[0] for column in cursor.description]

def get_columnas_sin_id(tabla, conn):
    columnas = get_columnas_completas(tabla, conn)
    return [col for col in columnas if not col.lower().endswith("id") or col.lower() == "clienteid"]

"""# dba/tablas.py
import tkinter as tk
from tkinter import messagebox, simpledialog

def gestionar_tabla(conn, tabla):
    if tabla == "Seleccione una tabla":
        messagebox.showwarning("Advertencia", "Debe seleccionar una tabla.")
        return

    try:
        cursor = conn.cursor()
        cursor.execute(f"SELECT * FROM {tabla}")
        rows = cursor.fetchall()
        print(f"\n=== Datos en {tabla} ===")
        for row in rows:
            print(row)
    except Exception as e:
        messagebox.showerror("Error", f"No se pudo consultar {tabla}:\n{e}")
        return

    ventana = tk.Toplevel()
    ventana.title(f"Gestionar Tabla: {tabla}")

    tk.Button(ventana, text="Insertar", width=20, command=lambda: accion_simple("insertar", tabla, conn)).pack(pady=5)
    tk.Button(ventana, text="Editar", width=20, command=lambda: accion_simple("editar", tabla, conn)).pack(pady=5)
    tk.Button(ventana, text="Eliminar", width=20, command=lambda: accion_simple("eliminar", tabla, conn)).pack(pady=5)

def accion_simple(accion, tabla, conn):
    messagebox.showinfo(
        f"{accion.capitalize()} en {tabla}",
        f"Para este ejemplo, simula que se abre una ventana para {accion} datos en la tabla {tabla}.\n\n"
        f"Puedes implementar los formularios específicos según las columnas de {tabla}."
    )
"""