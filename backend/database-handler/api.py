from fastapi import FastAPI, Body
import uvicorn
from bdd_script import login_account, create_account
from verification import send_email
from bdd_script import set_verification_code, verify_code, check_token

app = FastAPI()

create_account_error = [
    "The creation of the account worked well for",
    "This account already exist",
    "There is an error with psycopg2",
    "This is not a valid email",
    "Your username looks like an email"
]

login_account_error = [
    "The connection worked well",
    "This account doesn't exist",
    "There is an error with psycopg2",
    "This is the wrong password",
    "Failed to generate a token",
    "The account isn't verified"
]


@app.post("/auth/login")
def login(data: dict = Body(...)):
    username_email = data.get("username_email")
    password = data.get("password")
    rememberme = data.get("rememberme")
    token = data.get("token")

    print("Trying a login from", username_email, password)
    result, username, email, token = login_account(
        username_email, password, token)
    print(login_account_error[result],
          username_email, password)

    if result == 5:
        verification_code: int = send_email(email)
        set_verification_code(verification_code, email)

    return {"code": result, "rememberme": rememberme, "message": login_account_error[result], "username": username, "email": email, "connection_token": token}


@app.post("/auth/register")
def register(data: dict = Body(...)):
    username: str = data.get("username")
    email: str = data.get("email")
    password: str = data.get("password")

    result = create_account(username, email, password)

    if result == 0:
        verification_code: int = send_email(email)
        set_verification_code(verification_code, email)

    return {"code": result, "message": create_account_error[result], "email": email}


@app.post("/auth/confirm_register")
def confirm_register(data: dict = Body(...)):
    email: str = data.get("email")
    verification_code: int = data.get("verification_code")

    result: bool = verify_code(verification_code, email)

    if result:
        return {"code": 0, "message": "connection success"}
    else:
        return {"code": 1, "message": "wrong verification code"}


@app.post("/auth/check_connectivity")
def check_connectivity(data: dict = Body(...)):
    username: str = data.get("username")
    token: str = data.get("token")

    result: bool = check_token(username, token)

    return {"result": 1 if result else 0}


if __name__ == "main":
    uvicorn.run(app, host="0.0.0.0", port=10005)
