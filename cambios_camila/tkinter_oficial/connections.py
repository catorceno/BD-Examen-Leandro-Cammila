import pyodbc

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