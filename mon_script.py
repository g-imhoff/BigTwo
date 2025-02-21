import psycopg2
import sys
import pprint


DB_PARAMS ={
        "host":"localhost",
        "dbname" :"mabdd",
        "user":"postgres",
        "password":"BiG2@l3info#"
        }


def creer_table():
    

    try : 

        #connexion de la db 
        print ("connecting to database\n ->%s" % (DB_PARAMS))
        conn = psycopg2.connect(**DB_PARAMS)
        cur = conn.cursor()
        print ("connected!\n")
        

        #creation de la table 

        creation ="""CREATE TABLE IF NOT EXISTS  users (
            id SERIAL PRIMARY KEY,
            username VARCHAR(50) UNIQUE NOT NULL, 
            email VARCHAR(50) UNIQUE NOT NULL,
            password VARCHAR(50) NOT NULL 
            );
            """
        cur.execute(creation)
        conn.commit() # commit la modif 
        print("Table 'users' créée avec succès.")
    except Exception as e : 
        print(f"Erreur lors de la création de la table : {e}")

    finally : 
        cur.close()
        conn.close()


def inserer_user (nom,email,password):

    try:
        conn = psycopg2.connect(**DB_PARAMS)
        cur = conn.cursor ()
        insertion = """INSERT INTO users (username,email,password)  
                    VALUES (%s,%s,%s)
                    RETURNING id;
                    """

        cur.execute(insertion,(nom,email,password))
    
        user_id = cur.fetchone()[0]
        conn.commit()
        print(f"Utilisateur insere avec ID : {user_id}")

    except Exception as e : 
        print(f"Erreur lors de l'insertion :{e}")

    finally:
        cur.close()
        conn.close()


    
def supp_table(nom_table):

    try: 
        conn = psycopg2.connect(**DB_PARAMS)
        cur=conn.cursor()

        cur.execute(f"DROP TABLE IF EXISTS {nom_table} CASCADE ; ")
        conn.commit()
        print(f"Table '{nom_table}' supprimée avec succès. ")

    except Exception as e : 
        print(f"Erreur lors de la suppression de la table : {e}")
    finally : 
        cur.close()
        conn.close()


if __name__ == "__main__":
    
    creer_table()
    inserer_user("John Doe","johndoe@example.com","Password1")
    #supp_table("users") 
