package haxe.ui.remoting.client.impl;

import haxe.ui.remoting.Msg;
import haxe.ui.remoting.client.ClientSocket;
import js.html.MessageEvent;
import js.html.WebSocket;

class JavaScriptSocket {
    public var onMessage:Msg->Void;
    private var _socket:WebSocket;
    
    public function new(host:String, port:Int) {
        _socket = new WebSocket("ws://" + host + ":" + (port + 1));
        _socket.onopen = function() {
            _socket.send("ready");
        }
        _socket.onmessage = function(m:MessageEvent) {
            var msg:Msg = ClientSocket.unserializeMsg(m.data);
            if (onMessage != null) {
                onMessage(msg);
            }
        }
    }
    
    public function sendMessage(msg:Msg) {
        var data:String = ClientSocket.serializeMsg(msg);
        _socket.send(data);
    }
}