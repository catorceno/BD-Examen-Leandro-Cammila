# dba/menu_dba.py
import tkinter as tk
from tkinter import ttk, messagebox
from gerente.menu_gerente import mostrar_estado_maquinas, top_clientes, reporte_inscripciones, reporte_asistencias
from recepcionista.inscripcion import cliente_nuevo, cliente_existente
from recepcionista.pagos import agregar_pago, buscar_pago, consultar_deuda
from recepcionista.asistencia import agregar_asistencia, buscar_asistencia
from dba.tablas import gestionar_tablas

def crear_menu_dba(root, conn):
    root.title("Panel de DBA")

    frame = tk.Frame(root)
    frame.pack(padx=20, pady=20)

    # === Sección Gerente ===
    tk.Label(frame, text="Consultas Gerente", font=("Arial", 12, "bold")).pack(pady=5)
    tk.Button(frame, text="Estado de Máquinas", width=25, command=lambda: mostrar_estado_maquinas(conn)).pack(pady=2)
    tk.Button(frame, text="Top 10 Clientes", width=25, command=lambda: top_clientes(conn)).pack(pady=2)
    tk.Button(frame, text="Reporte Inscripciones", width=25, command=lambda: reporte_inscripciones(conn)).pack(pady=2)
    tk.Button(frame, text="Reporte Asistencias", width=25, command=lambda: reporte_asistencias(conn)).pack(pady=2)

    # === Sección Recepcionista ===
    tk.Label(frame, text="Funciones Recepcionista", font=("Arial", 12, "bold")).pack(pady=10)
    tk.Button(frame, text="Cliente Nuevo", width=25, command=lambda: cliente_nuevo(conn)).pack(pady=2)
    tk.Button(frame, text="Cliente Existente", width=25, command=lambda: cliente_existente(conn)).pack(pady=2)
    tk.Button(frame, text="Agregar Pago", width=25, command=lambda: agregar_pago(conn)).pack(pady=2)
    tk.Button(frame, text="Buscar Pago", width=25, command=lambda: buscar_pago(conn)).pack(pady=2)
    tk.Button(frame, text="Consultar Deuda", width=25, command=lambda: consultar_deuda(conn)).pack(pady=2)
    tk.Button(frame, text="Agregar Asistencia", width=25, command=lambda: agregar_asistencia(conn)).pack(pady=2)
    tk.Button(frame, text="Buscar Asistencia", width=25, command=lambda: buscar_asistencia(conn)).pack(pady=2)

    # === Gestión de Tablas ===
    tk.Label(frame, text="Gestionar Tablas", font=("Arial", 12, "bold")).pack(pady=10)
    
    tablas = [
        "CLIENTE", "INSCRIPCION", "PAGOS", "DESCUENTOS",
        "ASISTENCIA", "ENTRENADORES", "SERVICIO", "INVENTARIO"
    ]
    
    tabla_seleccionada = ttk.Combobox(frame, values=tablas, state="readonly")
    tabla_seleccionada.pack(pady=5)
    tabla_seleccionada.set("Seleccione una tabla")

    tk.Button(frame, text="Gestionar Tabla", command=lambda: gestionar_tablas(root, conn)).pack(pady=5)
    """tabla_seleccionada.get()"""
