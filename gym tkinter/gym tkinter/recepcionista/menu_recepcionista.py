# recepcionista_menu.py
import tkinter as tk
from recepcionista import inscripcion, pagos, asistencia

def mostrar_menu(root, conn):
    ventana = tk.Tk()
    ventana.title("Menú Recepcionista")
    ventana.geometry("300x360")

    # Menú de Inscripción
    insc_frame = tk.LabelFrame(ventana, text="Inscripción", padx=10, pady=10)
    insc_frame.pack(pady=10, fill="x")

    tk.Button(insc_frame, text="Cliente Nuevo", command=lambda: inscripcion.cliente_nuevo(conn)).pack(fill="x")
    tk.Button(insc_frame, text="Cliente Existente", command=lambda: inscripcion.cliente_existente(conn)).pack(fill="x")

    # Menú de Pago
    pago_frame = tk.LabelFrame(ventana, text="Pagos", padx=10, pady=10)
    pago_frame.pack(pady=10, fill="x")

    tk.Button(pago_frame, text="Agregar Pago", command=lambda: pagos.agregar_pago(conn)).pack(fill="x")
    tk.Button(pago_frame, text="Buscar Pago", command=lambda: pagos.buscar_pago(conn)).pack(fill="x")
    tk.Button(pago_frame, text="Consultar Deuda", command=lambda: pagos.consultar_deuda(conn)).pack(fill="x")

    # Menú de Asistencia
    asist_frame = tk.LabelFrame(ventana, text="Asistencia", padx=10, pady=10)
    asist_frame.pack(pady=10, fill="x")

    tk.Button(asist_frame, text="Agregar Asistencia", command=lambda: asistencia.agregar_asistencia(conn)).pack(fill="x")
    tk.Button(asist_frame, text="Buscar Asistencia", command=lambda: asistencia.buscar_asistencia(conn)).pack(fill="x")

    ventana.mainloop()
