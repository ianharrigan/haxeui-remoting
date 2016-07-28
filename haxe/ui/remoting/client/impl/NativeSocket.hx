package haxe.ui.remoting.client.impl;

import haxe.Unserializer;
import haxe.ui.remoting.Msg;
import haxe.ui.remoting.client.ClientSocket;
import sys.net.Host;
import sys.net.Socket;

#if neko
import neko.vm.Thread;
#elseif cpp
import cpp.vm.Thread;
#end

class NativeSocket {
    private var _socket:Socket;
    private var _readThread:Thread;

    public var onMessage:Msg->Void;
    public var onError:String->Void;

    public function new() {
    }

    public function connect(host:String = "localhost", port:Int = 1234) {
        try {
            _socket = new Socket();
            _socket.connect(new Host(host), port);
        } catch (e:Dynamic) {
            trace(e);            
            if (onError != null) {
                onError(e);
            }
            return;
        }
        
        _readThread = Thread.create(readThread);

        _readThread.sendMessage(this);
    }
    
    public function disconnect() {
        if (_socket != null) {
            _socket.close();
            _socket = null;
        }
    }
    
    public function sendMessage(msg:Msg) {
        var data:String = ClientSocket.serializeMsg(msg);
        _socket.output.writeInt32(data.length);
        _socket.output.writeString(data);
    }

    private function readThread() {
        var that:NativeSocket = Thread.readMessage(true);
        var c = true;
        while (c == true) {
            try {
                var len = that._socket.input.readInt32();
                var data:String = "";
                for (i in 0...len) {
                    var c = that._socket.input.readByte();
                    data += String.fromCharCode(c);
                }

                var unserializer:Unserializer = new Unserializer(data);
                var msg:Msg = unserializer.unserialize();
                if (onMessage != null) {
                    onMessage(msg);
                }
            } catch (e:Dynamic) {
                trace(e);
                if (that.onError != null) {
                    that.onError(e);
                    c = false;
                    break;
                }
            }
        }
    }
}