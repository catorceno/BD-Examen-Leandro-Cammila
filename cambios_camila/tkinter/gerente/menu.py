import tkinter as tk
import config_window
from gerente import reportes

def showMenu(root, conn):
    root.title("Menú Gerente")
    config_window.centrar(root, 300, 300)

    tk.Button(root, text="Top 10 Clientes", command=lambda: reportes.top10clientes(conn)).pack(fill="x", pady=2)
    tk.Button(root, text="Reporte Inventario", command=lambda: reportes.reporteInventario(conn)).pack(fill="x", pady=2)
    tk.Button(root, text="Reporte Ingresos", command=lambda: reportes.reporteIngresos(conn)).pack(fill="x", pady=5)
    tk.Button(root, text="Reporte Asistencias", command=lambda: reportes.reporteAsistencias(conn)).pack(fill="x", pady=5)