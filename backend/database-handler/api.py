from fastapi import FastAPI, Body
import uvicorn
from bdd_script import bdd_logout, login_account, create_account
from verification import send_email
from bdd_script import set_verification_code, verify_code

app = FastAPI()

create_account_error = [
    "The creation of the account worked well for",
    "This account already exist",
    "There is an error with psycopg2",
    "This is not a valid email"
]

login_account_error = [
    "The connection worked well",
    "This account doesn't exist",
    "There is an error with psycopg2",
    "This is the wrong password",
    "Somebody is already logged on this account"
]


@app.post("/auth/login")
def login(data: dict = Body(...)):
    username_email = data.get("username_email")
    password = data.get("password")

    print("Trying a login from", username_email, password)
    result, username = login_account(username_email, password)
    print(login_account_error[result],
          username_email, password)

    return {"code": result, "message": login_account_error[result], "username": username}


@app.post("/auth/register")
def register(data: dict = Body(...)):
    email = data.get("email")

    verification_code: int = send_email(email)
    set_verification_code(verification_code, email)
    return {"code": 0, "message": "Await verification_code"}


@app.post("/auth/confirm_register")
def confirm_register(data: dict = Body(...)):
    username: str = data.get("username")
    email: str = data.get("email")
    password: str = data.get("password")
    verification_code: int = data.get("verification_code")

    result: bool = verify_code(verification_code, email)

    if result:
        print("Trying a register from", username, email, password)
        result = create_account(username, email, password)

        print(create_account_error[result],
              username, email, password)
        return {"code": 0, "message": "connection success"}
    else:
        return {"code": 1, "message": "wrong verification code"}


@app.post("/auth/logout")
def logout(data: dict = Body(...)):
    username = data.get("username")

    print("Logout from", username)
    bdd_logout(username)


if __name__ == "main":
    uvicorn.run(app, host="0.0.0.0", port=10005)
