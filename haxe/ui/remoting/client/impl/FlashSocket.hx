package haxe.ui.remoting.client.impl;

import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.net.Socket;
import flash.utils.ByteArray;
import haxe.ui.remoting.Msg;
import haxe.ui.remoting.client.ClientSocket;

class FlashSocket {
    private var _socket:Socket;
    private var _buffer:ByteArray = new ByteArray();

    public var onMessage:Msg->Void;

    public function new(host:String, port:Int) {
        _socket = new Socket(host, port);
        _socket.addEventListener(ProgressEvent.SOCKET_DATA, onData);
        _socket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
        _socket.endian = "littleEndian";
    }

    public function sendMessage(msg:Msg) {
        var data:String = ClientSocket.serializeMsg(msg);
        _socket.writeInt(data.length);
        _socket.writeUTFBytes(data);
        _socket.flush();
    }

    private function onData(event:ProgressEvent) {
        var socket:Socket = event.currentTarget;

        var len = socket.readInt();
        while (len <= cast(socket.bytesAvailable, Int)) {
            var s:String = socket.readUTFBytes(len);
            if (socket.bytesAvailable == 0) {
                var msg:Msg = ClientSocket.unserializeMsg(s);
                if (onMessage != null) {
                    onMessage(msg);
                }
                break;
            }
            len = socket.readByte();
            var msg:Msg = ClientSocket.unserializeMsg(s);
            if (onMessage != null) {
                onMessage(msg);
            }
        }
    }

    private function onIOError(event:IOErrorEvent) {
        trace(event);
    }
}