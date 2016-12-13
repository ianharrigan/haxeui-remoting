package haxe.ui.remoting.client.impl;

import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.Event;
import flash.net.Socket;
import flash.utils.ByteArray;
import haxe.ui.remoting.Msg;
import haxe.ui.remoting.client.ClientSocket;
import flash.events.SecurityErrorEvent;

class FlashSocket {
    private var _socket:Socket;
    private var _buffer:ByteArray = new ByteArray();

    public var onMessage:Msg->Void;
    public var onError:String->Void;

    public function new() {
    }

    public function connect(host:String, port:Int) {
        disconnect();
        _socket = new Socket();
        _socket.addEventListener(ProgressEvent.SOCKET_DATA, onData);
        _socket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
        _socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
        _socket.addEventListener(Event.CLOSE, onIOError);
        _socket.endian = "littleEndian";
        //_socket.timeout = 0;
        _socket.connect(host, port);
    }

    public function disconnect() {
        if (_socket != null) {
            _socket.removeEventListener(ProgressEvent.SOCKET_DATA, onData);
            _socket.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
            _socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
            _socket.addEventListener(Event.CLOSE, onIOError);
            if (_socket.connected) {
                _socket.close();
            }
            _socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e) { }, false, 0, true);
            _socket = null;
        }
    }

    public function sendMessage(msg:Msg) {
        var data:String = ClientSocket.serializeMsg(msg);
        _socket.writeInt(data.length);
        _socket.writeUTFBytes(data);
        _socket.flush();
    }

    private function onData(event:ProgressEvent) {
        var socket:Socket = event.currentTarget;

        if (socket.bytesAvailable <= 4) {
            return;
        }

        var len = socket.readInt();
        while (len <= cast(socket.bytesAvailable, Int)) {
            var s:String = socket.readUTFBytes(len);
            var msg:Msg = ClientSocket.unserializeMsg(s);
            if (onMessage != null) {
                onMessage(msg);
            }
            if (socket.bytesAvailable <= 4) {
                break;
            }
            len = socket.readInt();
        }
    }

    private function onIOError(event:Event) {
        trace(event);
        if (onError != null) {
            disconnect();
            onError(event.toString());
        }
    }

    private function onSecurityError(event:SecurityErrorEvent) {
        trace(event);
        return;
        if (onError != null) {
            disconnect();
            onError(event.toString());
        }
    }
}