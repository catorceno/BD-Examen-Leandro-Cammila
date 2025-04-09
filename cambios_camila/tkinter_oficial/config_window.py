 
def centrar(window, ancho, alto):
    pantalla_ancho = window.winfo_screenwidth()
    pantalla_alto = window.winfo_screenheight()
    x = (pantalla_ancho // 2) - (ancho // 2)
    y = (pantalla_alto // 2) - (alto // 2)
    window.geometry(f"{ancho}x{alto}+{x}+{y}")