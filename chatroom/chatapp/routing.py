# chatapp/routing.py
from channels.auth import AuthMiddlewareStack
from channels.routing import ProtocolTypeRouter, URLRouter
import chatroom.routing

"""
Desc: 1.the ProtocolTypeRouter will first inspect the type of connection
      2.WebSocket connection (ws:// or wss://), 
        the connection will be given to the AuthMiddlewareStack.
      3.The URLRouter will examine the HTTP path of 
        the connection to route it to a particular consumer
"""
application = ProtocolTypeRouter({
    # (http->django views is added by default)
    'websocket': AuthMiddlewareStack(
        URLRouter(
            chatroom.routing.websocket_urlpatterns
        )
    ),
})