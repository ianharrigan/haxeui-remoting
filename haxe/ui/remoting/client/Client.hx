package haxe.ui.remoting.client;

import haxe.ui.remoting.Msg;
import haxe.ui.remoting.client.ClientSocket;
import haxe.ui.remoting.client.calls.Call;

class Client {
    private var _socket:ClientSocket;

    public function new(host:String = "localhost", port:Int = 1234) {
        _socket = new ClientSocket(host, port);
        _socket.onMessage = onMessage;
    }

    private function onMessage(msg:Msg) {
        var call:Call = Call.create(msg.id);
        if (msg.id == "client.connected") {
            return;
        }
        if (call == null) {
            trace("WARNING: message unrecognised, id=" + msg.id);
            return;
        }

        var details = call.execute(msg.details);
        if (details != null) {
            var response:Msg = {
                id: msg.id,
                details: details
            }

            _socket.sendMessage(response);
        }
    }
}