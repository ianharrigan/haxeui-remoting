package haxe.ui.remoting.server;

#if neko
import neko.vm.Thread;
#elseif cpp
import cpp.vm.Thread;
#end
import haxe.ui.remoting.Msg;
import neko.net.WebSocketServerLoop;
import sys.net.Host;
import sys.net.WebSocket;

class WebSocketServer {
    private var _host:String;
    private var _port:Int;

    private var _serverThread:Thread;

    public var onNewClient:Client->Void;
    public var onMessage:Client->Msg->Void;

    public function new(host:String, port:Int) {
        _host = host;
        _port = port;

        _serverThread = Thread.create(serverThread);
        _serverThread.sendMessage(this);
    }

    @:access(haxe.ui.remoting.server.Client)
    private function serverThread() {
        var that:WebSocketServer = Thread.readMessage(true);

        var serverLoop = new WebSocketServerLoop<WebSocketConnection>(function(socket) {
            var conn:WebSocketConnection = new WebSocketConnection(socket);
            return conn;
        });
        serverLoop.processIncomingMessage = function(connection:WebSocketConnection, data:String) {
            trace("Incoming: " + data);
            // use "connection.ws" to send answer
            // use "serverLoop.closeConnection(connection.ws.socket)" to close connection and remove socket from processing
            if (data == "ready" && that.onNewClient != null) {
                var client:WebSocketClient = new WebSocketClient();
                client.connection = connection;
                connection.client = client;
                that.onNewClient(client);
            } else {
                var msg = Client.unserializeMsg(data);
                if (connection.client.onMessageInternal(msg) == false) {
                    if (onMessage != null) {
                        onMessage(connection.client, msg);
                    }
                }
            }
        };

        serverLoop.run(new Host(_host), _port);
    }
}