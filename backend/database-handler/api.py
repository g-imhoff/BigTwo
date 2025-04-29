from fastapi import FastAPI, Body
import uvicorn
from bdd_script import create_account, login_account

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
    "This is the wrong password"
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
    username = data.get("username")
    email = data.get("email")
    password = data.get("password")

    print("Trying a register from", username, email, password)
    result = create_account(username, email, password)
    print(create_account_error[result],
          username, email, password)

    return {"code": result, "message": create_account_error[result]}

if __name__ == "main":
    uvicord.run(app, host="0.0.0.0", port=10005)
