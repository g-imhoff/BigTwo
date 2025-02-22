import asyncio
import json
from websockets.asyncio.server import serve

async def handler(websocket):
    async for message in websocket:
        content = json.loads(message)
        match content["function"]: 
            case "create_account":
                profile_name = content["data"]["profile_name"]
                email = content["data"]["email"]
                password = content["data"]["password"]

                print(profile_name, email, password)
            case "login":
                profile_name_email = content["data"]["profile_name_email"]
                password = content["data"]["password"]

                print(profile_name_email, password)

async def main():
    async with serve(handler, "localhost", 18014) as server:
        await server.serve_forever()

if __name__ == "__main__": 
    asyncio.run(main())
