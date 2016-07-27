package neko.net;

import haxe.io.Bytes;
import sys.net.Socket;
import sys.net.WebSocket;
import sys.net.WebSocketTools;

class ClientData
{
	public var ws : WebSocket;
	public var isHandsShakeDone : Bool;
	
	public function new(socket:Socket)
	{
		ws = new WebSocket(socket, true);
	}
}

class WebSocketServerLoop<TClientData:ClientData> extends neko.net.ServerLoop<TClientData>
{
	public function new(processNewData:Socket->TClientData)
	{
		super(processNewData);
		listenCount = 128;
	}
	
	override function processClientData(d:TClientData, buf:Bytes, bufpos:Int, buflen:Int) : Int
	{
		//Lib.println("===== RECEIVE (" + bufpos + ", " + buflen + "): " + buf.readString(bufpos, buflen - bufpos));
		if (d.isHandsShakeDone)
		{
			//Lib.println("===== DUMP:" + dump(buf, bufpos, buflen));
			if (buf.get(bufpos) == 0x00)
			{
				for (i in (bufpos + 1)...buflen)
				{
					if (buf.get(i) == 0xFF)
					{
						processIncomingMessage(d, buf.getString(bufpos + 1, i - bufpos - 1));
					}
					return i + 1 - bufpos;
				}
			}
			else
			if (buf.get(bufpos) == 0x81)
			{
				if (bufpos + 1 < buflen)
				{
					if (buf.get(bufpos + 1) & 0x80 != 0)
					{
						var len = -1;
						var lenSize = 0;
						
						var lenCode = buf.get(bufpos + 1) & 0x7F;
						if (lenCode < 126)
						{
							lenSize = 1;
							len = lenCode;
						}
						else
						if (lenCode == 126)
						{
							if (bufpos + 3 < buflen)
							{
								lenSize = 3;
								len = (buf.get(bufpos + 2) << 8) + buf.get(bufpos + 3);
							}
						}
						else
						{
							if (bufpos + 5 < buflen)
							{
								lenSize = 5;
								len = (buf.get(bufpos + 2) << 24) + (buf.get(bufpos + 3) << 16) + (buf.get(bufpos + 4) << 8) + buf.get(bufpos + 5);
							}
						}
						
						if (len >= 0)
						{
							if (bufpos + lenSize + 4 + len < buflen)
							{
								var maskpos = bufpos + 1 + lenSize;
								var mask = [ 
									 buf.get(maskpos)
									,buf.get(maskpos + 1)
									,buf.get(maskpos + 2)
									,buf.get(maskpos + 3)
								];
								
								var datapos = maskpos + 4;
								var data = new StringBuf();
								for (i in 0...len)
								{
									data.addChar(buf.get(datapos + i) ^ mask[i % 4]);
								}
								
								processIncomingMessage(d, data.toString());
								
								return 1 + lenSize + 4 + len;
							}
						}
					}
					else
					{
						throw "Bad websocket frame (unmasked).";
					}
				}
			}
			else
			if (buf.get(bufpos) == 0x88)
			{
				throw "Client request connection to close.";
			}
			else
			{
				throw "Bad websocket string. First char of '" + buf.getString(bufpos, buflen - bufpos) + "' is " + buf.get(bufpos) + ".";
			}
			return 0;
		}
		else
		{
			return shakeHands(d, buf, bufpos, buflen);
		}
	}
	
	function dump(buf:Bytes, bufpos:Int, buflen:Int)
	{
		var s = "";
		for (i in bufpos...buflen)
		{
			s += " 0x" + StringTools.hex(buf.get(i), 2);
		}
		return s;
	}
	
	function shakeHands(d:TClientData, buf:Bytes, bufpos:Int, buflen:Int) : Int
	{
		if (buf.get(bufpos) == "<".code)
		{
			//Lib.print("===== shakeHands - try to find 0x00: ");
			for (i in bufpos...buflen)
			{
				if (buf.get(i) == 0x00)
				{
					//Lib.println("OK");
					//Lib.println("===== OUT: <POLICY>");
					d.ws.socket.output.writeString('<cross-domain-policy><allow-access-from domain="*" to-ports="*" /></cross-domain-policy>' + String.fromCharCode(0x00));
					closeConnection(d.ws.socket);
					return i + 1 - bufpos;
				}
			}
			//Lib.println("FAIL");
			return 0;
		}
		else
		{
			//Lib.print("===== shakeHands - try to find \\r\\n\\r\\n: ");
			for (i in bufpos...(buflen - 3))
			{
				if (buf.get(i) == '\r'.code && buf.get(i + 1) == '\n'.code && buf.get(i + 2) == '\r'.code && buf.get(i + 3) == '\n'.code)
				{
					//Lib.println("OK");
					//Lib.println("HandShake received.");
					
					var lines = buf.getString(bufpos, i - bufpos).split("\r\n");
					//var methodUrlProtocol = lines[0];
					var clientHeaders = new Map<String,String>();
					for (j in 1...lines.length)
					{
						var t = lines[j].split(":");
						if (t.length == 2)
						{
							clientHeaders.set(StringTools.trim(t[0]), StringTools.trim(t.slice(1).join(":")));
						}
					}
					
					//Lib.print("WebSocketTools.sendHandsShake: ");
					WebSocketTools.sendServerHandShake(d.ws.socket, clientHeaders.get("Sec-WebSocket-Key"));
					//Lib.println("OK");
					
					d.isHandsShakeDone = true;
					
					return i + 4 - bufpos;
				}
			}
			//Lib.println("FAIL");
			return 0;
		}
	}
	
	public function stop()
	{
		socks[0].close();
	}
	
	// --- CUSTOMIZABLE API ---
	
	public dynamic function processIncomingMessage(data:TClientData, message:String)
	{
	}
}
