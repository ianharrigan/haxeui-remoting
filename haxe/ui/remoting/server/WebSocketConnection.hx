package haxe.ui.remoting.server;

#if neko
import neko.net.WebSocketServerLoop;
#elseif cpp
import cpp.net.WebSocketServerLoop;
#end

class WebSocketConnection extends WebSocketServerLoop.ClientData {
    public var client:WebSocketClient;
}
