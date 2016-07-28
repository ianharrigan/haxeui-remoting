package haxe.ui.remoting.server;
import haxe.ui.remoting.Msg;
import haxe.ui.util.GUID;

class Server {
    public var clients:Array<Client> = new Array<Client>();

    public var onConnected:Client->Void;
    public var onDisconnected:Client->Void;

    public function new(host:String = "localhost", port:Int = 1234) {
        var ws:WebSocketServer = new WebSocketServer(host, port + 1); // hack for html5 / websockets - actually starts two servers!
        ws.onMessage = onMessage;
        ws.onClientConnected = onClientConnected;
        ws.onClientDisconnected = onClientDisconnected;

        var ss:SocketServer = new SocketServer(host, port);
        ss.onClientConnected = onClientConnected;
        ss.onClientDisconnected = onClientDisconnected;
        ss.onMessage = onMessage;
    }

    private function onClientConnected(client:Client) {
        trace("CLIENT CONNECTED!");
        client.uuid = GUID.uuid();

        clients.push(client);
        var msg:Msg = {
            id: "client.connected"
        };
        client.sendMessage(msg);

        if (onConnected != null) {
            onConnected(client);
        }
    }

    private function onClientDisconnected(client:Client) {
        trace("CLIENT DISCONNECTED - "  + client.uuid);
        if (onDisconnected != null) {
            onDisconnected(client);
            clients.remove(client);
        }
    }
    
    private function onMessage(client:Client, msg:Msg) {
    }
    
    public function findClient(uuid:String):Client {
        var client:Client = null;
        for (c in clients) {
            if (c.uuid == uuid) {
                client = c;
                break;
            }
        }
        return client;
    }
}