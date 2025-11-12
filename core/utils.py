from django.db import connection

def call_procedure(proc_name, params):
    """Call a stored procedure with the given name and parameters."""
    with connection.cursor() as cursor:
        cursor.callproc(proc_name, params)
        results = cursor.fetchall()
    return results