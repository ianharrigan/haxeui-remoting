package haxe.ui.remoting.server;

import neko.net.WebSocketServerLoop;

class WebSocketConnection extends WebSocketServerLoop.ClientData {
	public var client:WebSocketClient;
}
