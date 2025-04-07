import tkinter as tk
from recepcionista import inscripcion, pagos, asistencia
import config_window
def showMenu(root, conn):
    root.title("Menú Recepcionista")
    config_window.centrar(root, 300, 440)

    insc_frame = tk.LabelFrame(root, text="Inscripción", padx=10, pady=10)
    insc_frame.pack(pady=20, fill='x')
    tk.Button(insc_frame, text="Cliente Nuevo", command=lambda: inscripcion.clienteNuevo(conn)).pack(fill="x")
    tk.Button(insc_frame, text="Cliente Existente", command=lambda: inscripcion.clienteExistente(conn)).pack(fill="x")

    pago_frame = tk.LabelFrame(root, text="Pagos", padx=10, pady=10)
    pago_frame.pack(pady=20, fill='x')
    tk.Button(pago_frame, text="Agregar Pago", command=lambda: pagos.agregarPago(conn)).pack(fill="x")
    tk.Button(pago_frame, text="Buscar Pagos", command=lambda: pagos.buscarPagos(conn)).pack(fill="x")
    tk.Button(pago_frame, text="Consultar Deuda", command=lambda: pagos.consultarDeuda(conn)).pack(fill="x")

    asist_frame = tk.LabelFrame(root, text="Asistencia", padx=10, pady=10)
    asist_frame.pack(pady=20, fill='x')
    tk.Button(asist_frame, text="Agregar Asistencia", command=lambda: asistencia.agregarAsistencia(conn)).pack(fill="x")
    tk.Button(asist_frame, text="Buscar Asistencias", command=lambda: asistencia.buscarAsistencias(conn)).pack(fill="x") 