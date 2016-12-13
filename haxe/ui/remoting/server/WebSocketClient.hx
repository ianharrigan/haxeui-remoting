package haxe.ui.remoting.server;
import haxe.ui.remoting.Msg;

class WebSocketClient extends Client {
    public var connection:WebSocketConnection;

    public function new() {
        super();
    }

    public override function sendMessage(msg:Msg) {
        connection.ws.send(Client.serializeMsg(msg));
    }

    public override function close() {
        connection.ws.socket.close();
    }
}