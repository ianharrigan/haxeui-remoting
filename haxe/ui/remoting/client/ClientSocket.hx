package haxe.ui.remoting.client;

import haxe.Serializer;
import haxe.Unserializer;
import haxe.ui.remoting.Msg;

#if flash
typedef SocketImpl = haxe.ui.remoting.client.impl.FlashSocket;
#elseif (neko || cpp)
typedef SocketImpl = haxe.ui.remoting.client.impl.NativeSocket;
#elseif js
typedef SocketImpl = haxe.ui.remoting.client.impl.JavaScriptSocket;
#end

class ClientSocket {
    private var _socket:SocketImpl;

    public var onMessage:Msg->Void;
    public var onError:String->Void;

    public function new() {
    }

    private function onMessageInternal(msg:Msg) {
        if (onMessage != null) {
            onMessage(msg);
        }
    }

    public function connect(host:String, port:Int) {
        _socket = new SocketImpl();
        _socket.onMessage = onMessageInternal;
        _socket.onError = onError;
        _socket.connect(host, port);
    }

    public function disconnect() {
        if (_socket != null) {
            _socket.disconnect();
            _socket.onMessage = null;
            _socket.onError = null;
            _socket = null;
        }
    }

    public function sendMessage(msg:Msg) {
        _socket.sendMessage(msg);
    }

    public static function unserializeMsg(data:String):Msg {
        var unserializer:Unserializer = new Unserializer(data);
        var msg:Msg = unserializer.unserialize();
        return msg;
    }

    public static function serializeMsg(msg:Msg):String {
        var serializer:Serializer = new Serializer();
        serializer.serialize(msg);
        return serializer.toString();
    }
}