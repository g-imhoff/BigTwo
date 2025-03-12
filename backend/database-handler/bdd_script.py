import psycopg2
import re

DB_PARAMS = {
    "host": "localhost",
    "dbname": "mabdd",
    "user": "postgres",
    "password": "BiG2@l3info#"
}

pattern_email = r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$'

def create_account(profile_name, email, password):
    """
    Check if an account exists in the database, and create it if it doesn't.

    :param profile_name: profile_name of the user
    :param username: username of the user
    :param password: password of the user
    """
    
    if re.match(pattern_email, email):
        try: 
            conn = psycopg2.connect(**DB_PARAMS)
            cur = conn.cursor()
            cur.execute("SELECT * FROM users WHERE username = %s", (profile_name,))

            if cur.fetchone():
                return 1 # error : already exist

            cur.execute("INSERT INTO users (username, email, password) VALUES (%s, %s, %s)", (profile_name, email, password))
            conn.commit()
            return 0 # Worked
        except psycopg2.Error as e:
            print("Database error : ", e)
            return 2 #Error psycopg2
    else:
        return 3 #not a valid email

def login_account(profile_name_email, password):
    """
    Check if an account exists in the database, and create it if it doesn't.

    :param profile_name_email: profile_name or email of the user
    :param password: password of the user
    """
    try: 
        conn = psycopg2.connect(**DB_PARAMS)
        cur = conn.cursor()
        cur.execute("SELECT * FROM users WHERE username = %s OR email = %s", (profile_name_email, profile_name_email))

        result = cur.fetchone()
        if result:
            bdd_id, bdd_username, bdd_email, bdd_password = result 

            if bdd_password == password: 
               
                  
                return 0 #connection worked
                
            else:
                return 3 #wrong password
        else: 
            return 1 #account not found
    except psycopg2.Error as e:
        print("Database error : ", e)
        return 2 #Error psycopg2


def creer_table():
    conn = None
    cur = None
    try:
        print("Connecting to database\n -> %s" % DB_PARAMS)
        conn = psycopg2.connect(**DB_PARAMS)
        cur = conn.cursor()
        print("Connected!\n")

        # Création de la table avec une meilleure gestion des types
        creation = """ 
        CREATE TABLE IF NOT EXISTS users (
            id SERIAL PRIMARY KEY,
            username VARCHAR(50) UNIQUE NOT NULL, 
            email VARCHAR(100) UNIQUE NOT NULL,
            password TEXT NOT NULL
        );
        """
        cur.execute(creation)
        conn.commit()
        print("Table 'users' créée avec succès.")

    except Exception as e:
        print(f"Erreur lors de la création de la table : {e}")

    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()

def supp_table(nom_table):
    """ Supprime une table en vérifiant d'abord que le nom est valide """
    conn = None
    cur = None
    try:
        # Vérification simple du nom de table pour éviter l'injection SQL
        if not nom_table.isidentifier():
            raise ValueError("Nom de table invalide")

        conn = psycopg2.connect(**DB_PARAMS)
        cur = conn.cursor()
        
        sql = f"DROP TABLE IF EXISTS {nom_table} CASCADE;"
        cur.execute(sql)
        conn.commit()
        print(f"Table '{nom_table}' supprimée avec succès.")

    except Exception as e:
        print(f"Erreur lors de la suppression de la table : {e}")

    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()

def inserer_user(nom, email, password):
    conn = None
    cur = None
    try:
        conn = psycopg2.connect(**DB_PARAMS)
        cur = conn.cursor()

        insertion = """ 
        INSERT INTO users (username, email, password)  
        VALUES (%s, %s, %s)
        RETURNING id;
        """
        cur.execute(insertion, (nom, email, password))

        result = cur.fetchone()  # fetchone() retourne une tuple

        # Afficher les résultats
        if result:
            user_id, username, email, password = result
            print(f"Utilisateur inséré avec succès. ID : {user_id}, Username : {username}, Email : {email}")

        conn.commit()
    except Exception as e:
        print(f"Erreur lors de la selection: {e}")

    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()

def select_user() : 
    conn = None
    cur = None
    try:
        conn = psycopg2.connect(**DB_PARAMS)
        cur = conn.cursor()

        cur.execute("SELECT * FROM users")
    
        user_id = cur.fetchone()[0]
        conn.commit()
        print(f"Utilisateur inséré avec ID : {user_id}")

    except Exception as e:
        print(f"Erreur lors de l'insertion : {e}")

    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()

if __name__ == "__main__": 
    creer_table()
