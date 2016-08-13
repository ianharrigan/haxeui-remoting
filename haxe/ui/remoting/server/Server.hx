package haxe.ui.remoting.server;
import haxe.ui.remoting.Msg;
//import haxe.ui.util.GUID;

class Server {
    public var clients:Array<Client> = new Array<Client>();

    public var onConnected:Client->Void;
    public var onDisconnected:Client->Void;

    private var _ws:WebSocketServer;
    private var _ss:SocketServer;
    
    public function new() {
    }

    public function start(host:String = "localhost", port:Int = 1234) {
        _ws = new WebSocketServer(host, port + 1); // hack for html5 / websockets - actually starts two servers!
        _ws.onMessage = onMessage;
        _ws.onClientConnected = onClientConnected;
        _ws.onClientDisconnected = onClientDisconnected;

        _ss = new SocketServer(host, port);
        _ss.onClientConnected = onClientConnected;
        _ss.onClientDisconnected = onClientDisconnected;
        _ss.onMessage = onMessage;
    }
    
    public function stop() {
        if (_ws != null) {
            _ws.stop();
        }
        if (_ss != null) {
            _ss.stop();
        }
    }
    
    private function onClientConnected(client:Client) {
        //trace("CLIENT CONNECTED!");
        //client.uuid = GUID.uuid();

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