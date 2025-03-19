import asyncio
import json
import ssl

from websockets.asyncio.server import serve

from bdd_script import create_account, login_account

ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
ssl_context.minimum_version = ssl.TLSVersion.TLSv1_2
ssl_context.load_cert_chain(certfile="../certs/cert.pem", keyfile="../certs/key.pem")

WEBSOCKETS_URL = "0.0.0.0"
WEBSOCKETS_PORT = 10005

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

async def handler(websocket):
    async for message in websocket:
        content = json.loads(message)
        match content["function"]: 
            case "create_account":
                profile_name = content["data"]["profile_name"]
                email = content["data"]["email"]
                password = content["data"]["password"]

                print("Trying a register from", profile_name, email, password)
                result = create_account(profile_name, email, password)
                print(create_account_error[result], profile_name, email, password)

                result_message = {
                    "code": result,
                    "message": create_account_error[result]
                }

                await websocket.send(json.dumps(result_message))
            case "login":
                profile_name_email = content["data"]["profile_name_email"]
                password = content["data"]["password"]

                print("Trying a login from", profile_name_email, password)
                result = login_account(profile_name_email, password)
                print(login_account_error[result], profile_name_email, password)

                result_message = {
                    "code": result,
                    "message": login_account_error[result]
                }

                await websocket.send(json.dumps(result_message))

async def main():

    async with serve(handler, WEBSOCKETS_URL, WEBSOCKETS_PORT, ssl=ssl_context) as server:
        await server.serve_forever()
    

if __name__ == "__main__": 
    asyncio.run(main())
