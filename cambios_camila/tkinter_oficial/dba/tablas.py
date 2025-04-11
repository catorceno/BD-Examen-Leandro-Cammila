import tkinter as tk
from tkinter import ttk, messagebox, simpledialog

# Diccionario de configuración para cada tabla (campos a insertar/editar)
table_config = {
    "CLIENTES": {
        "insert": ["CI", "Nombre", "Apellido", "Telefono"],
        "edit": ["CI", "Nombre", "Apellido", "Telefono"]
    },
    "SERVICIOS": {
        "insert": ["Nombre", "HoraInicio", "HoraFin"],
        "edit": ["Nombre", "HoraInicio", "HoraFin"]
    },
    "DESCUENTOS": {
        "insert": ["Nombre", "Porcentaje", "FechaInicio", "FechaFin"],
        "edit": ["Nombre", "Porcentaje", "FechaInicio", "FechaFin", "Estado"]
    },
    "INSCRIPCION": {
        "insert": ["ClienteID", "CantidadMeses", "FechaInicio", "FechaFin", "Mensualidad", "Subtotal", "DescuentoID", "Total"],
        "edit": ["ClienteID", "CantidadMeses", "FechaInicio", "FechaFin", "Mensualidad", "Subtotal", "DescuentoID", "Total"]
    },
    "INVENTARIO": {
        "insert": ["ServicioID", "Nombre", "Cantidad", "FechaAdquisicion", "Estado"],
        "edit": ["ServicioID", "Nombre", "Cantidad", "FechaAdquisicion", "Estado"]
    },
    "ENTRENADORES": {
        "insert": ["ServicioID", "CI", "Nombre", "Apellido", "Telefono", "Correo", "FechaInicio", "FechaFin", "Sueldo", "Turno", "Estado"],
        "edit": ["ServicioID", "CI", "Nombre", "Apellido", "Telefono", "Correo", "FechaInicio", "FechaFin", "Sueldo", "Turno", "Estado"]
    },
    "ASISTENCIA": {
        "insert": ["InscripcionID", "ServicioID", "Fecha", "HoraIngreso"],
        "edit": ["InscripcionID", "ServicioID", "Fecha", "HoraIngreso"]
    },
    "PAGOS": {
        "insert": ["InscripcionID", "Fecha", "Monto"],
        "edit": ["InscripcionID", "Fecha", "Monto"]
    }
}

# Configuración de la clave primaria para cada tabla: (nombre de columna, tipo esperado)
pk_config = {
    "CLIENTES": ("ClienteID", int),
    "SERVICIOS": ("ServicioID", int),
    "DESCUENTOS": ("DescuentoID", int),
    "INSCRIPCION": ("InscripcionID", int),
    "INVENTARIO": ("EquipoID", int),
    "ENTRENADORES": ("EntrenadorID", int),
    "ASISTENCIA": ("AsistenciaID", int),
    "PAGOS": ("PagoID", int)
}

# Configuración de tipos esperados para cada campo editable.
expected_types = {
    "CLIENTES": {"CI": int, "Nombre": str, "Apellido": str, "Telefono": int},
    "SERVICIOS": {"Nombre": str, "HoraInicio": str, "HoraFin": str},
    "DESCUENTOS": {"Nombre": str, "Porcentaje": int, "FechaInicio": str, "FechaFin": str, "Estado": str},
    "INSCRIPCION": {"ClienteID": int, "CantidadMeses": int, "FechaInicio": str, "FechaFin": str, "Mensualidad": int, "Subtotal": int, "DescuentoID": int, "Total": float},
    "INVENTARIO": {"ServicioID": int, "Nombre": str, "Cantidad": int, "FechaAdquisicion": str, "Estado": str},
    "ENTRENADORES": {"ServicioID": int, "CI": int, "Nombre": str, "Apellido": str, "Telefono": int, "Correo": str, "FechaInicio": str, "FechaFin": str, "Sueldo": int, "Turno": str, "Estado": str},
    "ASISTENCIA": {"InscripcionID": int, "ServicioID": int, "Fecha": str, "HoraIngreso": str},
    "PAGOS": {"InscripcionID": int, "Fecha": str, "Monto": int}
}

def gestionarTablas(root, conn, tablas):
    ventana = tk.Toplevel(root)
    ventana.title("Gestionar Tablas")
    ventana.geometry("700x500")

    tabla_var = tk.StringVar(value=tablas[0])

    ttk.Label(ventana, text="Selecciona una tabla:").pack(pady=5)
    combo_tablas = ttk.Combobox(ventana, textvariable=tabla_var, values=tablas, state="readonly")
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
        
        # Iterar por cada fila obtenida de la consulta
        for row in cursor.fetchall():
            clean_values = []
            for val in row:
                if isinstance(val, tuple):
                    # Si la tupla tiene un solo elemento, extraemos ese valor
                    val = val[0]
                clean_values.append(val)
            tree.insert("", "end", values=clean_values)

    def insertar_dato():
        tabla = tabla_var.get()
        # Usar configuración personalizada si existe
        if tabla in table_config:
            columnas = table_config[tabla]["insert"]
        else:
            columnas = get_columnas_sin_id(tabla, conn)
        valores = []
        for col in columnas:
            val = simpledialog.askstring("Insertar", f"Ingrese valor para {col}:")
            if val is None:
                return  # Se aborta la operación si se cancela
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
        columnas_completas = get_columnas_completas(tabla, conn)

        # Usar pk_config para obtener el nombre y tipo de la clave primaria
        if tabla in pk_config:
            pk_col, pk_type = pk_config[tabla]
        else:
            pk_col, pk_type = columnas_completas[0], int

        # Convertir la PK (valor de la columna pk_col) al tipo esperado.
        try:
            pk_valor = pk_type(fila[0])
        except Exception as ex:
            messagebox.showerror("Error", f"Error al convertir PK a {pk_type}: {ex}")
            return

        # Obtener las opciones de edición configuradas
        if tabla in table_config:
            columnas_edit = table_config[tabla]["edit"]
        else:
            columnas_edit = columnas_completas

        # Solicitar al usuario que indique la columna a editar (entre las válidas)
        opcion = simpledialog.askstring("Editar",
            f"Ingrese el nombre de la columna a editar\nOpciones: {', '.join(columnas_edit)}")
        if opcion is None:
            return
        if opcion not in columnas_edit:
            messagebox.showerror("Error", "La columna ingresada no es válida para editar.")
            return

        # Solicitar el nuevo valor
        nuevo_valor_str = simpledialog.askstring("Editar", f"Ingrese nuevo valor para {opcion}:")
        if nuevo_valor_str is None:
            return

        # Realizar la conversión del nuevo valor según expected_types
        if tabla in expected_types and opcion in expected_types[tabla]:
            tipo_obj = expected_types[tabla][opcion]
            try:
                nuevo_valor = tipo_obj(nuevo_valor_str)
            except Exception as ex:
                messagebox.showerror("Error", f"El valor para {opcion} debe ser de tipo {tipo_obj.__name__}. Detalle: {ex}")
                return
        else:
            nuevo_valor = nuevo_valor_str  # Si no se tiene información, se usa la cadena

        query = f"UPDATE {tabla} SET {opcion} = ? WHERE {pk_col} = ?"
        try:
            cursor = conn.cursor()
            cursor.execute(query, (nuevo_valor, pk_valor))
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
        columnas_completas = get_columnas_completas(tabla, conn)
        if tabla in pk_config:
            pk_col, pk_type = pk_config[tabla]
        else:
            pk_col, pk_type = columnas_completas[0], int
        try:
            pk_valor = pk_type(fila[0])
        except Exception as ex:
            messagebox.showerror("Error", f"Error al convertir PK: {ex}")
            return

        # Ventana de confirmación
        if messagebox.askyesno("Confirmar Eliminación", "¿Estás seguro de que deseas eliminar el registro?"):
            try:
                cursor = conn.cursor()
                query = f"DELETE FROM {tabla} WHERE {pk_col} = ?"
                cursor.execute(query, (pk_valor,))
                conn.commit()
                messagebox.showinfo("Éxito", "Registro eliminado.")
                cargar_datos()
            except Exception as e:
                messagebox.showerror("Error", str(e))
        else:
            return

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
    # Se omiten las columnas cuyo nombre finaliza en "id" (excepto cuando es "ClienteID")
    return [col for col in columnas if not (col.lower().endswith("id") and col.lower() != "clienteid")]