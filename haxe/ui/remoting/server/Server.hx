package haxe.ui.remoting.server;
import haxe.ui.remoting.Msg;
import haxe.ui.util.GUID;

class Server {
    public var clients:Array<Client> = new Array<Client>();

    public var onConnected:Client->Void;
    
    public function new(host:String = "localhost", port:Int = 1234) {
        var ws:WebSocketServer = new WebSocketServer(host, port + 1); // hack for html5 / websockets - actually starts two servers!
        ws.onMessage = onMessage;
        ws.onNewClient = onNewClient;
        
        var ss:SocketServer = new SocketServer(host, port);
        ss.onNewClient = onNewClient;
        ss.onMessage = onMessage;
    }
    
    private function onNewClient(client:Client) {
        trace("NEW CLIENT CONNECTED!");
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
    
    private function onMessage(client:Client, msg:Msg) {
    }
}