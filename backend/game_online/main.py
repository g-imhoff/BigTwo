import asyncio
import json
from websockets.asyncio.server import serve
import ssl

ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
ssl_context.minimum_version = ssl.TLSVersion.TLSv1_2
ssl_context.load_cert_chain(
    certfile="../certs/cert.pem", keyfile="../certs/key.pem")

WEBSOCKETS_URL = "localhost"  # for the moment, turn to 0.0.0.0 after
WEBSOCKETS_PORT = 10006

connected_client = {}
nb_client = 0


async def handler(websocket):
  global nb_client
  global connected_client
  async for message in websocket:
    content = json.loads(message)
    result_message = {
        "code": -99,
        "message": "undefined behavior"
    }
    match content["function"]:
      case "connect":
        if nb_client < 4:
          connected_client[content["profile_name"]] = websocket
          nb_client += 1

          result_message = {
              "code": 0,
              "message": "Connection worked"
          }
    await websocket.send(json.dumps(result_message))


async def main():
  async with serve(handler, WEBSOCKETS_URL, WEBSOCKETS_PORT, ssl=ssl_context) as server:
    await server.serve_forever()

if __name__ == "__main__":
  asyncio.run(main())
