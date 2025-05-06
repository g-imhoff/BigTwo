import psycopg2

DB_PARAMS = {
    "host": "localhost",
    "dbname": "mabdd",
    "user": "postgres",
    "password": "BiG2@l3info#"
}


def increment_game_won(username: str) -> list[int, str]:
    result: list[int, str] = [0, ""]

    try:
        conn = psycopg2.connect(**DB_PARAMS)
        cur = conn.cursor()

        # Check if code is valid (NOT expired)
        cur.execute("""
        UPDATE users
        SET game_won = game_won + 1
        WHERE username = %s
            """, (username,))
    except psycopg2.Error as e:
        print("Database error:", e)
        conn.rollback()
        result[0:2] = 3, "Database error"
    finally:
        cur.close()
        conn.close()

    return result


def increment_game_played(username: str) -> list[int, str]:
    result: list[int, str] = [0, ""]

    try:
        conn = psycopg2.connect(**DB_PARAMS)
        cur = conn.cursor()

        # Check if code is valid (NOT expired)
        cur.execute("""
        UPDATE users
        SET game_played = game_played + 1
        WHERE username = %s
            """, (username,))
    except psycopg2.Error as e:
        print("Database error:", e)
        conn.rollback()
        result[0:2] = 3, "Database error"
    finally:
        cur.close()
        conn.close()

    return result
