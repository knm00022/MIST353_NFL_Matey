from get_db_connection import get_db_connection

def validate_user(
        email: str,
        password_hash: str
    ):
    # with get_db_connection() as conn: # this is a context manager that will automatically close the connection when we're done with it.
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("{call procValidateUser(?,?)}", email, password_hash) # this executes the stored procedure becuase of the EXEC keyword, and the ? are placeholders for the parameters that we pass in after the query string. This is a parameterized query, which helps prevent SQL injection attacks.  
    rows = cursor.fetchall()
    conn.close()  

    #Convert pyodbc.Row objects to dictionaries
    results = [
        {
            'AppUserID': row.AppUserID,
            'Fullname': row.Fullname,
            'UserRole': row.UserRole
        }
        for row in rows
    ]
    return {"data": results}
   