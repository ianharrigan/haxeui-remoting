package haxe.ui.remoting.server;

import haxe.io.Bytes;
import haxe.ui.remoting.Msg;
#if neko
import neko.net.ThreadServer;
import neko.vm.Thread;
#elseif cpp
import cpp.net.ThreadServer;
import cpp.vm.Thread;
#end

import sys.net.Socket;

class SocketServer extends ThreadServer<SocketClient, Msg> {
    private var _host:String;
    private var _port:Int;

    private var _serverThread:Thread;

    public var onClientConnected:SocketClient->Void;
    public var onClientDisconnected:SocketClient->Void;
    public var onMessage:SocketClient->Msg->Void;

    public function new(host:String, port:Int) {
        super();

        _host = host;
        _port = port;

        _serverThread = Thread.create(serverThread);
        _serverThread.sendMessage(this);
    }

    public function stop() {
        
    }
    
    private function serverThread() {
        var that:SocketServer = Thread.readMessage(true);
        that.run(that._host, that._port);
    }

    public override function clientConnected(socket:Socket):SocketClient {
        socket.setFastSend(true);
        var client:SocketClient = new SocketClient();
        client.socket = socket;
        if (onClientConnected != null) {
            onClientConnected(client);
        }
        return client;
    }

    public override function clientDisconnected(socket:SocketClient) {
        if (onClientDisconnected != null) {
            onClientDisconnected(socket);
        }
    }

    @:access(haxe.ui.remoting.server.Client)
    public override function readClientMessage(c:SocketClient, buf:Bytes, pos:Int, len:Int) {
        var complete = false;
        var l:Int = buf.getInt32(pos);
        var msg:Msg = null;
        if (pos + l <= len + 4) {
            var data:String = buf.getString(pos + 4, l);
            complete = true;
            msg = Client.unserializeMsg(data);
        }

        if (complete == false) {
            return null;
        }

        if (c.onMessageInternal(msg) == false) {
            if (onMessage != null) {
                onMessage(c, msg);
            }
        }

        return {msg: msg, bytes: pos + l + 4};
    }
}