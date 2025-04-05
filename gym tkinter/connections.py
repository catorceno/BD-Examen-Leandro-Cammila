import pyodbc
from tkinter import messagebox

def open_connection(user, password):
    return pyodbc.connect(
        "Driver={ODBC Driver 17 for SQL Server};"
        "Server=DESKTOP-H1RNTOQ;"
        "Database=Gym;" 
        f"UID={user}; PWD={password}"
    )

def close_connection(connection):
    if(connection):
        connection.close()
        print("SQLServer connection closed.")
    else: print("Nothing to close. No connection to SQLServer was found.")


"""
para la base de datos:
CREATE DATABASE Gym
USE Gym

-- 1.
CREATE TABLE CLIENTE (
ClienteID INT PRIMARY KEY IDENTITY(1,1),
Nombre NVARCHAR(50) NOT NULL,
Apellido NVARCHAR(50) NOT NULL,
Telefono INT,
ModifiedDate DATETIME DEFAULT GETDATE(),
UNIQUE(Telefono)
)

-- 2.
CREATE TABLE SERVICIO (
ServicioID INT PRIMARY KEY IDENTITY(1,1),
Nombre NVARCHAR(50) NOT NULL,
HoraInicio TIME NOT NULL,
HoraFin TIME NOT NULL,
ModifiedDate DATETIME DEFAULT GETDATE()
)

-- 3.
CREATE TABLE INSCRIPCION (
InscripcionID INT PRIMARY KEY IDENTITY(1,1),
ClienteID INT NOT NULL,
FOREIGN KEY (ClienteID) REFERENCES CLIENTE(ClienteID),
CantidadMeses INT NOT NULL,
FechaInicio DATE NOT NULL,
FechaFin AS (DATEADD(MONTH, CantidadMeses, FechaInicio)) PERSISTED,
Mensualidad INT NOT NULL DEFAULT 250,
PrecioTotal AS (Mensualidad * CantidadMeses) PERSISTED,
ModifiedDate DATETIME DEFAULT GETDATE()
)

-- 4.
CREATE TABLE PAGOS (
PagoID INT PRIMARY KEY IDENTITY(1,1),
InscripcionID INT NOT NULL,
FOREIGN KEY (InscripcionID) REFERENCES INSCRIPCION(InscripcionID),
Fecha DATE NOT NULL,
Total DECIMAL(10,2) NOT NULL,
DescuentoID INT,
TotalFinal DECIMAL(10,2),
ModifiedDate DATETIME DEFAULT GETDATE()
)

-- 5.
CREATE TABLE ASISTENCIA (
AsistenciaID INT PRIMARY KEY IDENTITY(1,1),
InscripcionID INT NOT NULL,
ServicioID INT,
FOREIGN KEY (InscripcionID) REFERENCES INSCRIPCION(InscripcionID),
FOREIGN KEY (ServicioID) REFERENCES SERVICIO(ServicioID),
Fecha DATE NOT NULL,
HoraIngreso TIME,
UNIQUE(InscripcionID, Fecha),
ModifiedDate DATETIME DEFAULT GETDATE()
)

-- 6.
CREATE TABLE ENTRENADORES (
EntrenadorID INT PRIMARY KEY IDENTITY(1,1),
ServicioID INT NOT NULL, FOREIGN KEY (ServicioID) REFERENCES SERVICIO(ServicioID),
Nombre NVARCHAR(50) NOT NULL,
Apellido NVARCHAR(50) NOT NULL,
Telefono INT,
Correo NVARCHAR(50),
FechaInicio DATE NOT NULL,
FechaFin DATE,
Sueldo INT NOT NULL,
Turno NVARCHAR(50),
Estado AS (
	CASE WHEN FechaFin IS NULL THEN 'Activo'
	ELSE 'Despedido'
	END
	) PERSISTED,
ModifiedDate DATETIME DEFAULT GETDATE()
)

-- 7.
CREATE TABLE INVENTARIO (
    EquipoID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(255) NOT NULL,
    Cantidad INT DEFAULT 1,
    Estado NVARCHAR(50) CHECK (Estado IN ('Nuevo', 'En Uso', 'Mantenimiento', 'Mal Estado', 'Descontinuado')),
    FechaAdquisicion DATE NOT NULL,
    ServicioID INT NOT NULL,
    ModifiedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ServicioID) REFERENCES SERVICIO(ServicioID) 
);

-- 8.
CREATE TABLE DESCUENTOS (
    DescuentoID INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(50) NOT NULL,
    Porcentaje DECIMAL(5,2) CHECK (Porcentaje BETWEEN 0 AND 100),
    FechaInicio DATE NOT NULL,
    FechaFin DATE NOT NULL,
    Estado NVARCHAR(50) DEFAULT 'Activo',
	ModifiedDate DATETIME DEFAULT GETDATE()
);
estoy realizando una interfaz usando tkinter de python, por el momento tengo un archivo llamado 'connections.py' que contiene estas funciones:
    def open_connection(user, password):
        return pyodbc.connect(
            "Driver={ODBC Driver 17 for SQL Server};"
            "Server=DESKTOP-K99GLDO\\SQLEXPRESS;"
            "Database=Gym;" 
            f"UID={user}; PWD={password}"
        )

    def close_connection(connection):
        if(connection):
            connection.close()
            print("SQLServer connection closed.")
        else: print("Nothing to close. No connection to SQLServer was found.")
y tengo estos usuarios registrados en mi base de datos: 
    -- Crear logins
    CREATE LOGIN usuario_recepcionita WITH PASSWORD = 'Recepcionista123.';
    CREATE LOGIN usuario_gerente WITH PASSWORD = 'Gerente123.';
    CREATE LOGIN usuario_dba WITH PASSWORD = 'Dba123.';

    -- Asignar el rol sysadmin al DBA 
    ALTER SERVER ROLE sysadmin ADD MEMBER usuario_dba;

    -- Crear los usuarios
    USE Gym;
    CREATE USER recepcionista1 FOR LOGIN usuario_recepcionita;
    CREATE USER gerente1 FOR LOGIN usuario_gerente;
    CREATE USER dba1 FOR LOGIN usuario_dba;

    -- 5. Asignar roles de base de datos
    EXEC sp_addrolemember 'db_datawriter', 'recepcionista1';
    EXEC sp_addrolemember 'db_datareader', 'gerente1';
    EXEC sp_addrolemember 'db_owner', 'dba1';
sin embargo aun me falta implementar la interfaz que permita:
1. Cuando se corra 'main.py' (es el programa donde se encuentra el flujo principal) se muestre una ventana donde se pida al usuario:
    - usuario
    - contraseña
y tenga un boton 'Ingresar'
2. Se debe verificar el usuario de acuerdo a los usuarios que te pase arriba y segun a su rol mostrar:
recepcionista:
1. menu 'inscripcion' con las opciones:
    - cliente nuevo (en una ventana mergente se pide lo necesario para ingresar los datos para hacer el INSERT en la tabla CLIENTE y tambien para la tabla INSCRIPCION)
    - cliente existente (en una ventana mergente se pide lo necesario para buscar al cliente en la tabla CLIENTE y tambien para la tabla INSCRIPCION)
1. menu 'pago' con las opciones:
    - agregar pago
    - buscar pago
    - consultar deuda (en una ventana emergente pide lo necesario para realizar la busqueda y calcular la deuda para mostrarla)
1. menu 'asistencia' con las opciones:
    - agregar asistencia
    - buscar asistencia

gerente: (para las consultas, no es necesario mostrarlo en la interfaz, es suficiente con que se vea en la consola)
1. boton 'estado de las maquinas' (se hace la consulta: SELECT * FROM vw_reportEstadoMaquinas) 
1. boton 'top 10 clientes' (se hace la consulta: SELECT * FROM vw_clienteTop) 
1. boton 'reporte inscripciones' (se hace la consulta: SELECT * FROM vw_reportLastInscriptions) 
1. boton 'reporte asistencias' (se hace la consulta: SELECT * FROM vw_asistenciaLastMonth) 

dba: (para las consultas, no es necesario mostrarlo en la interfaz, es suficiente con que se vea en la consola)
en una columna se muestras todas las opciones que tiene GERENTE y en otra columna todas las opciones que tiene RECEPCIONISTA mas:
1. menu 'Gestionar Tablas' con las opciones:
    - CLIENTE
    - INSCRIPCION
    - PAGOS
    - DESCUENTOS
    - ASISTENCIA
    - ENTRENADORES
    - SERVICIO
    - INVENTARIO
Despues de seleccionar alguna de las opciones se repite este proceso de acuerdo a la opcion:
1. se hace la consulta: SELECT *  FROM opcion_seleccionada(por ejemplo CLIENTE)
2. se muestran 3 botones
    - insertar (que pida ingresar lo necesario de acuerdo a la tabla en una ventana emergente)
    - editar (que pida ingresar lo necesario de acuerdo a la tabla en una ventana emergente)
    - eliminar (que pida ingresar lo necesario de acuerdo a la tabla en una ventana emergente)
"""