import tkinter as tk
from tkinter import ttk
import config_window
from gerente import ingresos

def showMenu(root, conn):
    root.title("Menú Gerente")
    config_window.centrar(root, 300, 300)

    tk.Button(root, text="Top 10 Clientes", command=lambda: top10clientes(conn)).pack(fill="x", pady=2)
    tk.Button(root, text="Reporte Inventario", command=lambda: reporteInventario(conn)).pack(fill="x", pady=2)

    asist_frame = tk.LabelFrame(root, text="Ingresos", padx=10, pady=10)
    asist_frame.pack(pady=20, fill='x')
    tk.Button(asist_frame, text="Reporte1", command=lambda: ingresos.reporteIngresos1(conn)).pack(fill="x", pady=5)
    tk.Button(asist_frame, text="Reporte2", command=lambda: ingresos.reporteIngresos2(conn)).pack(fill="x", pady=5) 

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

    # Agregar scrollbars (opcional, en caso de que los datos se salgan)
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
            tree.insert("", "end", values=row)
    except Exception as e:
        print("Error al obtener Top 10 Clientes:", e)

def reporteInventario(conn):
    inv_window = tk.Toplevel()
    inv_window.title("Reporte Inventario")
    inv_window.geometry("900x500")  # Aumentamos un poco la ventana

    # Frame Reporte Agregado
    agg_frame = tk.LabelFrame(inv_window, text="Reporte Estado Maquinas - Resumen", padx=5, pady=5)
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
            clean_values = [str(x).replace('\n',' ').replace('\r',' ') for x in r]
            det_tree.insert("", "end", values=clean_values)
    except Exception as e:
        print("Error reporte detallado:", e)





"""def reporteInventario(conn):
    # Crear una nueva ventana para el reporte
    top = tk.Toplevel()
    top.title("Reporte Inventario")
    config_window.centrar(top, 600, 500)
    
    cursor = conn.cursor()
    
    # 1. Obtener datos de la vista de resumen (vw_reporteEstadoMaquinas)
    try:
        cursor.execute("SELECT * FROM vw_reporteEstadoMaquinas")
        resumen = cursor.fetchall()
    except Exception as e:
        tk.messagebox.showerror("Error", f"Error al obtener resumen: {e}")
        return

    # Mostrar el resumen en un frame
    frame_resumen = tk.LabelFrame(top, text="Resumen Estado Máquinas", padx=10, pady=10)
    frame_resumen.pack(fill="x", padx=10, pady=5)
    
    text_resumen = tk.Text(frame_resumen, height=3, wrap="word")
    text_resumen.pack(fill="x")
    # Suponemos que la vista devuelve una única fila con las columnas:
    # Nuevo, En_Uso, Mantenimiento, Mal_Estado, Descontinuado
    if resumen:
        fila = resumen[0]
        resumen_str = (f"Nuevo: {fila[0]}, En Uso: {fila[1]}, "
                       f"Mantenimiento: {fila[2]}, Mal Estado: {fila[3]}, "
                       f"Descontinuado: {fila[4]}")
        text_resumen.insert("end", resumen_str)
    text_resumen.config(state="disabled")
    
    # 2. Obtener datos de la vista de detalle (vw_reporteEstadoMaquinasDetalle)
    try:
        cursor.execute("SELECT * FROM vw_reporteEstadoMaquinasDetalle ORDER BY row_num")
        detalles = cursor.fetchall()
    except Exception as e:
        tk.messagebox.showerror("Error", f"Error al obtener detalle: {e}")
        return

    # Mostrar los detalles en otro frame usando Treeview
    frame_detalle = tk.LabelFrame(top, text="Detalle Estado Máquinas", padx=10, pady=10)
    frame_detalle.pack(fill="both", expand=True, padx=10, pady=5)
    
    # Definir columnas según la vista: row_num, Nuevo, EnUso, Mantenimiento, MalEstado, Descontinuado
    columnas = ("row_num", "Nuevo", "EnUso", "Mantenimiento", "MalEstado", "Descontinuado")
    tree = ttk.Treeview(frame_detalle, columns=columnas, show="headings")
    for col in columnas:
        tree.heading(col, text=col)
        tree.column(col, width=100, anchor="center")
    tree.pack(fill="both", expand=True)
    
    for fila in detalles:
        tree.insert("", "end", values=fila)
    
    # Botón para cerrar la ventana del reporte
    tk.Button(top, text="Cerrar", command=top.destroy).pack(pady=10)"""