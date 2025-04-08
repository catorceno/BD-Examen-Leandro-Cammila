import tkinter as tk
from tkinter import ttk
import config_window
from recepcionista import menu, inscripcion, pagos, asistencia
from gerente import menu, reportes
from dba import tablas

def showMenu(root, conn):
    root.title("Menú DBA")
    config_window.centrar(root, 300, 700)

    tk.Label(root, text="RECEPCIONISTA").pack()
    insc_frame = tk.LabelFrame(root, text="Inscripción", padx=10, pady=10)
    insc_frame.pack(pady=5, fill='x')
    tk.Button(insc_frame, text="Cliente Nuevo", command=lambda: inscripcion.clienteNuevo(conn)).pack(fill="x")
    tk.Button(insc_frame, text="Cliente Existente", command=lambda: inscripcion.clienteExistente(conn)).pack(fill="x")

    pago_frame = tk.LabelFrame(root, text="Pagos", padx=10, pady=10)
    pago_frame.pack(pady=5, fill='x')
    tk.Button(pago_frame, text="Agregar Pago", command=lambda: pagos.agregarPago(conn)).pack(fill="x")
    tk.Button(pago_frame, text="Buscar Pagos", command=lambda: pagos.buscarPagos(conn)).pack(fill="x")
    tk.Button(pago_frame, text="Consultar Deuda", command=lambda: pagos.consultarDeuda(conn)).pack(fill="x")

    asist_frame = tk.LabelFrame(root, text="Asistencia", padx=10, pady=10)
    asist_frame.pack(pady=5, fill='x')
    tk.Button(asist_frame, text="Agregar Asistencia", command=lambda: asistencia.agregarAsistencia(conn)).pack(fill="x")
    tk.Button(asist_frame, text="Buscar Asistencias", command=lambda: asistencia.buscarAsistencias(conn)).pack(fill="x") 

    tk.Label(root, text="GERENTE").pack()
    tk.Button(root, text="Top 10 Clientes", command=lambda: menu.top10clientes(conn)).pack(fill="x")
    tk.Button(root, text="Reporte Inventario", command=lambda: menu.reporteInventario(conn)).pack(fill="x")

    asist_frame = tk.LabelFrame(root, text="Ingresos", padx=10, pady=10)
    asist_frame.pack(pady=5, fill='x')
    tk.Button(asist_frame, text="Reporte1", command=lambda: reportes.reporteIngresos1(conn)).pack(fill="x")
    tk.Button(asist_frame, text="Reporte2", command=lambda: reportes.reporteIngresos2(conn)).pack(fill="x") 

    tk.Label(root, text="Gestionar Tablas", font=(12, "bold")).pack(pady=10)
    tablas : list[str] = [
        "CLIENTES", "INSCRIPCION", "PAGOS", "DESCUENTOS", "ASISTENCIA",
        "ENTRENADORES", "SERVICIO", "INVENTARIO"
    ]

    tabla_selec = ttk.Combobox(root, values=tablas, state="readonly")
    tabla_selec.pack(pady=5)
    tabla_selec.set("Seleccione una tabla")

    tk.Button(root, text="Gestionar Tabla", command=lambda: tablas.gestionarTablas(root, conn, tablas)).pack(pady=5)