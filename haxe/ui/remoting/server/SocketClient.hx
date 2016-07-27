package haxe.ui.remoting.server;

import haxe.ui.remoting.Msg;
import sys.net.Socket;

class SocketClient extends Client {
    public var socket:Socket;
    
    public function new() {
        super();
    }
    
    public override function sendMessage(msg:Msg) {
        var data:String = Client.serializeMsg(msg);
        socket.output.writeInt32(data.length);
        socket.write(data);
    }
}