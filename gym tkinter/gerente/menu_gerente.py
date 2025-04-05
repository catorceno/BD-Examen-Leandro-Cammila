# gerente/menu_gerente.py
import tkinter as tk
from tkinter import messagebox

def mostrar_estado_maquinas(conn):
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM vw_reportEstadoMaquinas")
        rows = cursor.fetchall()
        print("\n=== Estado de las Máquinas ===")
        for row in rows:
            print(row)
    except Exception as e:
        messagebox.showerror("Error", str(e))

def top_clientes(conn):
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM vw_clienteTop")
        rows = cursor.fetchall()
        print("\n=== Top 10 Clientes ===")
        for row in rows:
            print(row)
    except Exception as e:
        messagebox.showerror("Error", str(e))

def reporte_inscripciones(conn):
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM vw_reportLastInscriptions")
        rows = cursor.fetchall()
        print("\n=== Reporte de Inscripciones del Último Semestre ===")
        for row in rows:
            print(row)
    except Exception as e:
        messagebox.showerror("Error", str(e))

def reporte_asistencias(conn):
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM vw_asistenciaLastMonth")
        rows = cursor.fetchall()
        print("\n=== Reporte de Asistencias del Último Mes ===")
        for row in rows:
            print(row)
    except Exception as e:
        messagebox.showerror("Error", str(e))

def crear_menu_gerente(root, conn):
    root.title("Panel de Gerente")
    frame = tk.Frame(root)
    frame.pack(padx=20, pady=20)

    tk.Button(frame, text="Estado de Máquinas", width=25, command=lambda: mostrar_estado_maquinas(conn)).pack(pady=5)
    tk.Button(frame, text="Top 10 Clientes", width=25, command=lambda: top_clientes(conn)).pack(pady=5)
    tk.Button(frame, text="Reporte Inscripciones", width=25, command=lambda: reporte_inscripciones(conn)).pack(pady=5)
    tk.Button(frame, text="Reporte Asistencias", width=25, command=lambda: reporte_asistencias(conn)).pack(pady=5)
