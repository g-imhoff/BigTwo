from fastapi import FastAPI, Body
import uvicorn
from bdd_script import login_account, create_account
from verification import random_code, send_email, email_reset_password
from bdd_script import set_verification_code, verify_code, check_token, check_and_reset_password, set_reset_password_code, get_user_info, modify_avatar_database

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


@app.post("/user/change_avatar")
def change_avatar(data: dict = Body(...)):
    username = data.get("username")
    avatar = data.get("avatar")

    result, message = modify_avatar_database(username, avatar)

    return {"code": result, "message": message}


@app.post("/user/info")
def info(data: dict = Body(...)):
    username = data.get("username")

    result, avatar, game_won, game_played = get_user_info(username)

    return {
        "code": result,
        "avatar": avatar,
        "game_won": game_won,
        "game_played": game_played}


@app.post("/auth/login")
def login(data: dict = Body(...)):
    username_email = data.get("username_email")
    password = data.get("password")
    rememberme = data.get("rememberme")
    token = data.get("token")

    print("Trying a login from", username_email, password)
    result, username, email, avatar, game_won, game_played, token = login_account(
        username_email, password, token)
    print(login_account_error[result],
          username_email, password)

    if result == 5:
        verification_code: int = send_email(email)
        set_verification_code(verification_code, email)

    return {
        "code": result,
        "rememberme": rememberme,
        "message": login_account_error[result],
        "username": username,
        "email": email,
        "avatar": avatar,
        "game_won": game_won,
        "game_played": game_played,
        "connection_token": token}


@app.post("/auth/register")
def register(data: dict = Body(...)):
    username: str = data.get("username")
    email: str = data.get("email")
    password: str = data.get("password")

    result = create_account(username, email, password)

    if result == 0:
        verification_code: int = send_email(email)
        set_verification_code(verification_code, email)

    return {"code": result,
            "message": create_account_error[result], "email": email}


@app.post("/auth/confirm_register")
def confirm_register(data: dict = Body(...)):
    email: str = data.get("email")
    verification_code: int = data.get("verification_code")

    result: tuple[int, str] = verify_code(verification_code, email)

    return {"function": "confirm_register",
            "code": result[0], "message": result[1]}


@app.post("/auth/new_email_code")
def new_email_code(data: dict = Body(...)):
    email: str = data.get("email")

    verification_code: int = send_email(email)
    set_verification_code(verification_code, email)
    return {"function": "new_email_code"}


@app.post("/auth/check_connectivity")
def check_connectivity(data: dict = Body(...)):
    username: str = data.get("username")
    token: str = data.get("token")

    result: bool = check_token(username, token)

    return {"result": 1 if result else 0}


@app.post("/auth/send_email_reset_password")
def send_email_reset_password(data: dict = Body(...)):
    email: str = data.get("email")
    verification_code = random_code(6)

    result: tuple[int, str] = set_reset_password_code(verification_code, email)

    if result[0] == 0:
        reset_passord_code: tuple[int, str] = email_reset_password(
            verification_code, email)
        result = reset_passord_code

    return {"function": "send_email_reset_password",
            "code": result[0], "message": result[1]}


@app.post("/auth/reset_password")
def reset_passord(data: dict = Body(...)):
    email: str = data.get("email")
    reset_password_code: str = data.get("reset_password_code")
    new_password: str = data.get("new_password")

    result: tuple[int, str] = check_and_reset_password(
        email, reset_password_code, new_password)

    return {"function": "reset_password",
            "code": result[0], "message": result[1]}


if __name__ == "main":
    uvicorn.run(app, host="0.0.0.0", port=10005)
