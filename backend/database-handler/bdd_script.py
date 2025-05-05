import psycopg2
import re
from uuid import uuid4

DB_PARAMS = {
    "host": "localhost",
    "dbname": "mabdd",
    "user": "postgres",
    "password": "BiG2@l3info#"
}

pattern_email = r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$'


def check_and_reset_password(email: str, user_reset_password_code: str, new_password: str) -> tuple(int, str):
    try:
        conn = psycopg2.connect(**DB_PARAMS)
        cur = conn.cursor()
        cur.execute("""
        SELECT reset_password_code
        FROM users
        WHERE email = %s
        AND reset_password_code_updated_at < NOW() - INTERVAL '10 minutes'""",
                    (email,))

        try:
            reset_password_code, = cur.fetchone()

            if reset_password_code == user_reset_password_code:
                cur.execute("""
                UPDATE users
                SET password = %s
                WHERE email = %s""",
                            (new_password, email,))
                conn.commit()

                return 0, "reset worked"
            else:
                return 1, "wrong code"
        except TypeError:
            return 2, "Account not find or password code limit timer passed"

    except psycopg2.Error as e:
        print("Database error : ", e)
        return 3, "Database error"


def create_account(profile_name, email, password):
    """
    Check if an account exists in the database, and create it if it doesn't.

    :param profile_name: profile_name of the user
    :param username: username of the user
    :param password: password of the user
    """
    if re.match(pattern_email, profile_name):
        return 4  # error username looks like an email
    elif re.match(pattern_email, email):
        try:
            conn = psycopg2.connect(**DB_PARAMS)
            cur = conn.cursor()
            cur.execute("SELECT * FROM users WHERE username = %s",
                        (profile_name,))

            if cur.fetchone():
                return 1  # error : already exist

            cur.execute("INSERT INTO users (username, email, password) VALUES (%s, %s, %s)",
                        (profile_name, email, password))
            conn.commit()
            return 0  # Worked
        except psycopg2.Error as e:
            print("Database error : ", e)
            return 2  # Error psycopg2
    else:
        return 3  # not a valid email


def set_verification_code(code: int, email: str) -> None:
    try:
        conn = psycopg2.connect(**DB_PARAMS)
        cur = conn.cursor()
        cur.execute("UPDATE users SET verification_code = %s WHERE email = %s",
                    (code, email))
        conn.commit()

    except psycopg2.Error as e:
        print("Database error : ", e)


def verify_code(code: int, email: str) -> tuple(int, str):
    try:
        conn = psycopg2.connect(**DB_PARAMS)
        cur = conn.cursor()
        cur.execute("""
        SELECT verification_code
        FROM users
        WHERE email = %s
        AND verification_code_updated_at < NOW() - INTERVAL '10 minutes'""",
                    (email,))

        try:
            verification_code, = cur.fetchone()

            if verification_code == code:
                cur.execute("""
                UPDATE users
                SET verified_account = true
                WHERE email = %s""", (email,))
                conn.commit()
                return 0, "account verified"
            else:
                return 1, "Wrong code"
        except TypeError:
            return 2, "Account not find or verification code limit timer passed"

    except psycopg2.Error as e:
        print("Database error : ", e)
        return 3, "Database error"


def set_reset_password_code(verification_code: str, email: str) -> tuple(int, str):
    try:
        conn = psycopg2.connect(**DB_PARAMS)
        cur = conn.cursor()
        cur.execute("""
        SELECT email
        FROM users
        WHERE email = %s""",
                    (email,))

        try:
            cur.fetchone()  # Check if there is an account

            cur.execute("""
            UPDATE users
            SET reset_password_code = %s
            WHERE email = %s""", (verification_code, email,))
            conn.commit()
            return 0, "password was set"
        except TypeError:
            return 1, "Email not existing"
    except psycopg2.Error as e:
        print("Database error : ", e)
        return 2, "Database got an error"


def login_account(profile_name_email, password, connection_token):
    """
    Check if an account exists in the database, and create it if it doesn't.

    :param profile_name_email: profile_name or email of the user
    :param password: password of the user
    """
    try:
        conn = psycopg2.connect(**DB_PARAMS)
        cur = conn.cursor()
        cur.execute("SELECT id, username, email, password, verified_account, connection_token FROM users WHERE username = %s OR email = %s",
                    (profile_name_email, profile_name_email))

        result = cur.fetchone()
        if result:
            bdd_id, bdd_username, bdd_email, bdd_password, bdd_verified, bdd_token = result

            if bdd_password == password:
                if not bdd_verified:
                    return 5, "", bdd_email, ""  # the account is not verified
                elif bdd_token == connection_token:
                    return 0, bdd_username, bdd_email, ""  # connection worked
                else:
                    token = generate_token(bdd_username)
                    if token == -1:
                        return 4, "", "", ""  # failed to generate a token
                    else:
                        return 0, bdd_username, bdd_email, token  # connection worked
            else:
                return 3, "", "", ""  # wrong password
        else:
            return 1, "", "", ""  # account not found
    except psycopg2.Error as e:
        print("Database error : ", e)
        return 2, "", "", ""  # Error psycopg2


def generate_token(email):
    rand_token = str(uuid4())

    try:
        conn = psycopg2.connect(**DB_PARAMS)
        cur = conn.cursor()
        cur.execute("""
        UPDATE users
        SET connection_token = %s
        WHERE username = %s
        """, (rand_token, email))

        conn.commit()
        return rand_token
    except psycopg2.Error as e:
        print("Database error : ", e)
        return -1


def check_token(username, token):
    try:
        conn = psycopg2.connect(**DB_PARAMS)
        cur = conn.cursor()
        cur.execute("""
        SELECT connection_token 
        FROM users 
        WHERE username = %s""",
                    (username, ))

        try:
            connection_token, = cur.fetchone()
        except TypeError as e:
            return False

        if connection_token == token:
            return True
        else:
            return False
    except psycopg2.Error as e:
        print("Database error : ", e)


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
            print(
                f"Utilisateur inséré avec succès. ID : {user_id}, Username : {username}, Email : {email}")

        conn.commit()
    except Exception as e:
        print(f"Erreur lors de la selection: {e}")

    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()


def select_user():
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
