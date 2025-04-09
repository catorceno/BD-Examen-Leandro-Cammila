import tkinter as tk
from tkinter import ttk
import config_window
from recepcionista import inscripcion, pagos, asistencia
from gerente import reportes
import dba.tablas

def showMenu(root, conn):
    root.title("Menú DBA")
    config_window.centrar(root, 300, 610)

    tk.Label(root, text="RECEPCIONISTA", font=("", 11, "bold")).pack()
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

    tk.Label(root, text="GERENTE", font=("", 11, "bold")).pack()
    gerente_frame = tk.LabelFrame(root, text="", padx=10, pady=10)
    gerente_frame.pack(pady=5, fill='x')
    tk.Button(gerente_frame, text="Top 10 Clientes", command=lambda: reportes.top10clientes(conn)).pack(fill="x")
    tk.Button(gerente_frame, text="Reporte Inventario", command=lambda: reportes.reporteInventario(conn)).pack(fill="x")
    tk.Button(gerente_frame, text="Reporte Ingresos", command=lambda: reportes.reporteIngresos(conn)).pack(fill="x")
    tk.Button(gerente_frame, text="Reporte Asistencias", command=lambda: reportes.reporteAsistencias(conn)).pack(fill="x") 

    tk.Label(root, text="GESTIONAR TABLAS", font=("", 11, "bold")).pack(pady=10)
    tablas : list[str] = [
        "CLIENTES", "INSCRIPCION", "PAGOS", "DESCUENTOS", "ASISTENCIA",
        "ENTRENADORES", "SERVICIOS", "INVENTARIO"
    ]

    tk.Button(root, text="Gestionar Tabla", command=lambda: dba.tablas.gestionarTablas(root, conn, tablas)).pack(pady=5)