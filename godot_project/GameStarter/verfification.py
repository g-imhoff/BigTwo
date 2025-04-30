import smtplib
import psycopg2
import json
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

from bdd_script import create_account

DB_PARAMS = {
    "host": "localhost",
    "dbname": "mabdd",
    "user": "postgres",
    "password": "BiG2@l3info#"
}

try:
    con = psycopg2.connect(**DB_PARAMS)
    cur = con.cursor()
    cur.execute("SELECT email FROM users WHERE id = %s", (create_account.user_id,))
    result = cur.fetchone()
    if result is None:
        print("No email found for the given user ID.")
    else:
        receiver_email = result[0]
except Exception as e:
    print("Error when connecting to the database:", e)
finally:
    if con:
        cur.close()
        con.close()


# Informations de l'expéditeur
smtp_server = "smtp.gmail.com"
smtp_port = 587
sender_email = "bigtwocardgame@gmail.com"
sender_password = "omdj irhm anhg chuw"

# Destinataire

def random_code(length):
    import random
    import string

    characters = string.digits  # Utiliser uniquement des chiffres
    return ''.join(random.choice(characters) for _ in range(length))

verification_code = random_code(6)  # Générer un code aléatoire de 6 chiffres

data = {
    "code": verification_code,
}

with open("data.json", "w") as f:
    json.dump(data, f)
# Contenu de l'email
subject = "Your Verification Code"
body = f"""
Hello,

To confirm your registration, please enter the code below in the application.

Here is your verification code:

CODE: {verification_code}

This code is valid for 10 minutes.

If you did not request this registration, please ignore this message.

The Support Team
"""

# receiver_email = "trystan.dh46@gmail.com"

# Création du message
message = MIMEMultipart()
message["From"] = sender_email
message["To"] = receiver_email
message["Subject"] = subject

message.attach(MIMEText(body, "plain"))

# Envoi de l'email
try:
    server = smtplib.SMTP(smtp_server, smtp_port)
    server.starttls()
    server.login(sender_email, sender_password)
    server.send_message(message)
    print("Email sent successfully!")
except Exception as e:
    print("Error when the email was sent :", e)
finally:
    server.quit()


