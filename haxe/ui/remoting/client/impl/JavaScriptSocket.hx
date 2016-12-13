package haxe.ui.remoting.client.impl;

import haxe.ui.remoting.Msg;
import haxe.ui.remoting.client.ClientSocket;
import js.html.MessageEvent;
import js.html.WebSocket;

class JavaScriptSocket {
    public var onMessage:Msg->Void;
    public var onError:String->Void;

    private var _socket:WebSocket;

    public function new() {
    }

    public function connect(host:String, port:Int) {
        disconnect();
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
        _socket.onerror = function(e) {
            if (onError != null) {
                onError(e);
            }
        }
        _socket.onclose = function() {
            if (onError != null) {
                onError(null);
            }
        }
    }

    public function disconnect() {
        if (_socket != null) {
            _socket.onopen = null;
            _socket.onmessage = null;
            _socket.onerror = null;
            _socket.onclose = null;
            _socket.close();
            _socket = null;
        }
    }

    public function sendMessage(msg:Msg) {
        var data:String = ClientSocket.serializeMsg(msg);
        _socket.send(data);
    }
}