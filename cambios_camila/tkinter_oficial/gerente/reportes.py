import tkinter as tk
from tkinter import ttk

def flatten_values(row):
    flattened = []
    for item in row:
        if isinstance(item, tuple):
            # Si es una tupla, se extraen sus elementos convertidos a str
            flattened.extend([str(subitem) for subitem in item])
        else:
            flattened.append(str(item))
    return flattened

def top10clientes(conn):
    # Crear ventana Toplevel para mostrar el Top 10 Clientes
    top10_window = tk.Toplevel()
    top10_window.title("Top 10 Clientes")
    top10_window.geometry("900x400")  # Ajusta el tamaño a tu preferencia

    # Definir las columnas según la vista
    columns = ("CI", "Nombre", "Apellido", "CantidadMeses", "CantidadInsc", "Total", 
               "FechaUltimaInsc", "FechaFinUltimaInsc", "EstadoInsc")

    # Crear el Treeview
    tree = ttk.Treeview(top10_window, columns=columns, show="headings")
    # Configurar cada columna
    tree.heading("CI", text="CI")
    tree.heading("Nombre", text="Nombre")
    tree.heading("Apellido", text="Apellido")
    tree.heading("CantidadMeses", text="Meses")
    tree.heading("CantidadInsc", text="Inscripciones")
    tree.heading("Total", text="Total")
    tree.heading("FechaUltimaInsc", text="F. Última Insc")
    tree.heading("FechaFinUltimaInsc", text="F. Fin Última Insc")
    tree.heading("EstadoInsc", text="Estado")

    tree.column("CI", width=100, anchor="center")
    tree.column("Nombre", width=150, anchor="w")
    tree.column("Apellido", width=150, anchor="w")
    tree.column("CantidadMeses", width=80, anchor="center")
    tree.column("CantidadInsc", width=100, anchor="center")
    tree.column("Total", width=100, anchor="center")
    tree.column("FechaUltimaInsc", width=120, anchor="center")
    tree.column("FechaFinUltimaInsc", width=120, anchor="center")
    tree.column("EstadoInsc", width=80, anchor="center")

    # Agregar scrollbars (en caso de que los datos se salgan)
    scroll_y = ttk.Scrollbar(top10_window, orient="vertical", command=tree.yview)
    tree.configure(yscrollcommand=scroll_y.set)
    scroll_y.pack(side="right", fill="y")
    tree.pack(fill="both", expand=True)

    # Ejecutar la consulta y cargar los datos en el Treeview
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM vw_clientesTop")
        rows = cursor.fetchall()
        for row in rows:
            # Se aplica flatten_values para obtener cada dato como cadena sin los caracteres extras
            clean_values = flatten_values(row)
            tree.insert("", "end", values=clean_values)
    except Exception as e:
        print("Error al obtener Top 10 Clientes:", e)

def reporteInventario(conn):
    inv_window = tk.Toplevel()
    inv_window.title("Reporte Inventario")
    inv_window.geometry("900x500")  # Aumentamos un poco la ventana

    # Frame Reporte Agregado
    agg_frame = tk.LabelFrame(inv_window, text="Reporte Estado Maquinas", padx=5, pady=5)
    agg_frame.pack(fill="x", expand=False, padx=5, pady=5)

    # Scrollbars Agregado
    scroll_x_agg = ttk.Scrollbar(agg_frame, orient="horizontal")
    scroll_y_agg = ttk.Scrollbar(agg_frame, orient="vertical")

    columns_agg = ("Nuevo", "En_Uso", "Mantenimiento", "Mal_Estado", "Descontinuado")
    agg_tree = ttk.Treeview(
        agg_frame, 
        columns=columns_agg, 
        show="headings",
        xscrollcommand=scroll_x_agg.set,
        yscrollcommand=scroll_y_agg.set,
        height=2
    )

    scroll_x_agg.config(command=agg_tree.xview)
    scroll_y_agg.config(command=agg_tree.yview)
    scroll_x_agg.pack(side="bottom", fill="x")
    scroll_y_agg.pack(side="right", fill="y")
    agg_tree.pack(side="left", fill="x", expand=True)

    for col in columns_agg:
        agg_tree.heading(col, text=col)
        agg_tree.column(col, width=120, anchor="center", stretch=False)

    # Cargar datos
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM vw_reporteEstadoMaquinas")
        row = cursor.fetchone()
        if row:
            agg_tree.insert("", "end", values=row)
    except Exception as e:
        print("Error reporte agregado:", e)

    # Frame Reporte Detallado
    det_frame = tk.LabelFrame(inv_window, text="Reporte Estado Maquinas - Detalle", padx=5, pady=5)
    det_frame.pack(fill="both", expand=True, padx=5, pady=5)

    # Scrollbars Detallado
    scroll_x_det = ttk.Scrollbar(det_frame, orient="horizontal")
    scroll_y_det = ttk.Scrollbar(det_frame, orient="vertical")

    columns_det = ("row_num", "Nuevo", "EnUso", "Mantenimiento", "MalEstado", "Descontinuado")
    det_tree = ttk.Treeview(
        det_frame, 
        columns=columns_det, 
        show="headings",
        xscrollcommand=scroll_x_det.set,
        yscrollcommand=scroll_y_det.set
    )

    scroll_x_det.config(command=det_tree.xview)
    scroll_y_det.config(command=det_tree.yview)
    scroll_x_det.pack(side="bottom", fill="x")
    scroll_y_det.pack(side="right", fill="y")
    det_tree.pack(side="left", fill="both", expand=True)

    for col in columns_det:
        det_tree.heading(col, text=col, anchor="w")
        det_tree.column(col, width=180, anchor="w", stretch=True)

    try:
        cursor.execute("SELECT * FROM vw_reporteEstadoMaquinasDetalle ORDER BY row_num")
        rows = cursor.fetchall()
        for r in rows:
            # Remover saltos de línea si existen
            clean_values = [str(x).replace('\n', ' ').replace('\r', ' ') for x in r]
            det_tree.insert("", "end", values=clean_values)
    except Exception as e:
        print("Error reporte detallado:", e)

def reporteIngresos(conn):
    # Crear ventana Toplevel para mostrar el reporte de ingresos
    ingresos_window = tk.Toplevel()
    ingresos_window.title("Reporte Ingresos")
    ingresos_window.geometry("600x350")  # Ajusta tamaño para que sea más compacto

    # --- Sección 1: Total de ingresos ---
    total_frame = tk.LabelFrame(ingresos_window, text="", padx=5, pady=5)
    total_frame.pack(fill="x", padx=5, pady=5)

    total_label = tk.Label(total_frame, text="Cargando total...")
    total_label.pack(anchor="w", padx=5, pady=5)

    try:
        cursor = conn.cursor()
        # Si tus vistas están en dbo, podrías usar dbo.vw_ingresosUltimoSemestre
        cursor.execute("SELECT * FROM vw_ingresosUltimoSemestre")
        row = cursor.fetchone()
        if row:
            # Se espera un valor (TotalIngresos)
            total_ingresos = row[0] if row[0] else 0
            total_label.config(text=f"Total Ingresos el Ultimo Semestre: {total_ingresos} Bs.")
        else:
            total_label.config(text="No se encontraron datos de ingresos.")
    except Exception as e:
        total_label.config(text="Error al cargar el total de ingresos.")
        print("Error en reporteIngresos (total):", e)

    # --- Sección 2: Ingresos por mes ---
    mes_frame = tk.LabelFrame(ingresos_window, text="Ingresos por Mes (Último Semestre)", padx=5, pady=5)
    mes_frame.pack(fill="both", expand=True, padx=5, pady=5)

    columns_mes = ("Mes", "Ingresos")
    mes_tree = ttk.Treeview(mes_frame, columns=columns_mes, show="headings")
    mes_tree.heading("Mes", text="Mes")
    mes_tree.heading("Ingresos", text="Ingresos")

    # Ajustar el ancho de columnas: Mes más estrecha que Ingresos
    mes_tree.column("Mes", width=70, anchor="center")
    mes_tree.column("Ingresos", width=140, anchor="center")

    scroll_y_mes = ttk.Scrollbar(mes_frame, orient="vertical", command=mes_tree.yview)
    mes_tree.configure(yscrollcommand=scroll_y_mes.set)
    scroll_y_mes.pack(side="right", fill="y")
    mes_tree.pack(fill="both", expand=True)

    try:
        cursor.execute("SELECT * FROM vw_ingresosPorMes")
        rows = cursor.fetchall()
        for row in rows:
            # row[0] = Mes, row[1] = Ingresos (ej. '250 Bs.')
            mes_tree.insert("", "end", values=(str(row[0]), str(row[1])))
    except Exception as e:
        print("Error en reporteIngresos (mes):", e)

def reporteAsistencias(conn):
    import tkinter as tk
    from tkinter import ttk

    # Crear ventana Toplevel para mostrar el reporte de asistencias
    asistencias_window = tk.Toplevel()
    asistencias_window.title("Reporte Asistencias")
    asistencias_window.geometry("600x500")  # Ajusta el tamaño a tus necesidades

    # Sección 1: Asistencias por Hora
    hora_frame = tk.LabelFrame(asistencias_window, text="Asistencias por Hora", padx=5, pady=5)
    hora_frame.pack(fill="both", expand=True, padx=5, pady=5)

    # Definir las columnas para la vista vw_asistenciasPorHora
    columns_hora = ("Hora", "Asistencias")
    hora_tree = ttk.Treeview(hora_frame, columns=columns_hora, show="headings")
    hora_tree.heading("Hora", text="Hora")
    hora_tree.heading("Asistencias", text="Asistencias")

    # Ajustar el ancho de las columnas:
    hora_tree.column("Hora", width=80, anchor="center")
    hora_tree.column("Asistencias", width=120, anchor="center")

    # Agregar scrollbar vertical para el treeview
    scroll_y_hora = ttk.Scrollbar(hora_frame, orient="vertical", command=hora_tree.yview)
    hora_tree.configure(yscrollcommand=scroll_y_hora.set)
    scroll_y_hora.pack(side="right", fill="y")
    hora_tree.pack(fill="both", expand=True)

    # Ejecutar la consulta para la vista vw_asistenciasPorHora
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM vw_asistenciasPorHora")
        rows = cursor.fetchall()
        for row in rows:
            # row[0] = Hora (ejemplo "10:00") y row[1] = Asistencias
            hora_tree.insert("", "end", values=(str(row[0]), str(row[1])))
    except Exception as e:
        print("Error al cargar datos de asistencias por hora:", e)

    # Sección 2: Ranking de Servicios (Servicios más populares de acuerdo a la asistencia)
    servicios_frame = tk.LabelFrame(asistencias_window, text="Ranking de Servicios", padx=5, pady=5)
    servicios_frame.pack(fill="both", expand=True, padx=5, pady=5)

    # Definir las columnas para la vista vw_rankingServicios
    columns_servicios = ("Servicio", "Asistencias")
    servicios_tree = ttk.Treeview(servicios_frame, columns=columns_servicios, show="headings")
    servicios_tree.heading("Servicio", text="Servicio")
    servicios_tree.heading("Asistencias", text="Asistencias")

    # Ajustar el ancho de las columnas:
    servicios_tree.column("Servicio", width=200, anchor="w")
    servicios_tree.column("Asistencias", width=120, anchor="center")

    # Agregar scrollbar vertical para el treeview de servicios
    scroll_y_servicios = ttk.Scrollbar(servicios_frame, orient="vertical", command=servicios_tree.yview)
    servicios_tree.configure(yscrollcommand=scroll_y_servicios.set)
    scroll_y_servicios.pack(side="right", fill="y")
    servicios_tree.pack(fill="both", expand=True)

    # Ejecutar la consulta para la vista vw_rankingServicios
    try:
        cursor.execute("SELECT * FROM vw_rankingServicios")
        rows = cursor.fetchall()
        for row in rows:
            # row[0] = Servicio y row[1] = Asistencias
            servicios_tree.insert("", "end", values=(str(row[0]), str(row[1])))
    except Exception as e:
        print("Error al cargar datos de ranking de servicios:", e)