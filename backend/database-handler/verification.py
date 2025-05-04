import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import psycopg2
import re

# Informations de l'expéditeur
smtp_server = "smtp.gmail.com"
smtp_port = 587
sender_email = "bigtwocardgame@gmail.com"
sender_password = "omdj irhm anhg chuw"


pattern_email = r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$'

DB_PARAMS = {
    "host": "localhost",
    "dbname": "mabdd",
    "user": "postgres",
    "password": "BiG2@l3info#"
}


def random_code(length):
    import random
    import string

    characters = string.digits  # Utiliser uniquement des chiffres
    return ''.join(random.choice(characters) for _ in range(length))


def send_email(email_user) -> int:
    # Générer un code aléatoire de 6 chiffres
    verification_code = random_code(6)

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

    # Création du message
    message = MIMEMultipart()
    message["From"] = sender_email
    message["To"] = email_user
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

    return verification_code
