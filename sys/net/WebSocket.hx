package sys.net;

import sys.net.Host;
import sys.net.Socket;

class FrameCode
{
	public static inline var Continuation = 0x00;
	public static inline var Text = 0x01;
	public static inline var Binary = 0x02;
	public static inline var Close = 0x08;
	public static inline var Ping = 0x09;
	public static inline var Pong = 0x0A;
}

class CloseException
{
	public var code : Int;
	public var message : String;
	
	public function new(code:Int, message:String)
	{
		this.code = code;
		this.message = message;
	}
	
	public function toString() return Type.getClassName(Type.getClass(this)) + ": " + code + (message != null && message != "" ? " / " + message : "");
}

class WebSocket
{
	var isServer : Bool;
	
	public var socket(default, null) : Socket;
	
	public function new(socket:Socket, isServer:Bool)
	{
		this.socket = socket;
		this.isServer = isServer;
	}
	
	public static function connect(host:String, port:Int, origin:String, url:String, key:String) : WebSocket
	{
		var socket = new Socket();
		socket.connect(new Host(host), port);
		
		WebSocketTools.sendClientHandShake(socket, url, host, port, key, origin);
		
		var rLine : String;
		while((rLine = socket.input.readLine()) != "")
		{
			//trace("Handshake from server: " + rLine);
		}
		
		return new WebSocket(socket, false);
	}
	
	public function send(data:String)
	{
		sendFrame(FrameCode.Text, true, data);
	}
	
	public function recv() : String
	{
		var s = "";
		
		while (true)
		{
			var frame = recvFrame();
			
			switch (frame.code)
			{
				case FrameCode.Text:
					s += frame.data;
					if (frame.fin) return s;
					
				case FrameCode.Close:
					throw new CloseException
					(
						frame.data.length >= 2 ? (frame.data.charCodeAt(0) << 8) | frame.data.charCodeAt(1) : 0,
						frame.data.length > 2 ? frame.data.substring(2) : ""
					);
					
				case FrameCode.Ping:
					sendFrame(FrameCode.Pong, true, "");	
					
				case FrameCode.Pong:
					// nothing to do
				
				case _:
					throw "Unsupported websocket opcode/fin: 0x" + StringTools.hex(frame.code) + "/" + frame.fin;
			}
		}
	}
	
	public function close(?code:Int, reason="")
    {
		var s = code != null ? String.fromCharCode(code >> 8) + String.fromCharCode(code & 0x0F) + reason : "";
		sendFrame(FrameCode.Close, true, s);
		socket.close();
    }
	
	function sendFrame(code:Int, fin:Bool, data:String) : Void
	{
		socket.output.writeByte((fin ? 0x80 : 0x00) | code);
		
		var len = 0;
		if       (data.length < 126) 	len = data.length;
		else  if (data.length < 65536)	len = 126;
		else 							len = 127;
		
		socket.output.writeByte(len | (!isServer ? 0x80 : 0x00));

		if (data.length >= 126)
		{
			if (data.length < 65536)
			{
				socket.output.writeByte((data.length >> 8) & 0xFF);
				socket.output.writeByte(data.length & 0xFF);
			}
			else
			{
				socket.output.writeByte((data.length >> 24) & 0xFF);
				socket.output.writeByte((data.length >> 16) & 0xFF);
				socket.output.writeByte((data.length >> 8) & 0xFF);
				socket.output.writeByte(data.length & 0xFF);
			}
		}
		
		if (isServer)
		{
			socket.output.writeString(data);
		}
		else
		{
			var mask = [ Std.random(256), Std.random(256), Std.random(256), Std.random(256) ];
			socket.output.writeByte(mask[0]);
			socket.output.writeByte(mask[1]);
			socket.output.writeByte(mask[2]);
			socket.output.writeByte(mask[3]);
			var maskedData = new StringBuf();
			for (i in 0...data.length)
			{
				maskedData.addChar(data.charCodeAt(i) ^ mask[i % 4]);
			}
			socket.output.writeString(maskedData.toString());
		}
	}
	
	function recvFrame() : { code:Int, fin:Bool, data:String }
	{
		var data = socket.input.readByte();
		
		var opcode = data & 0xF;
		var rsv = (data >> 1) & 0x07;
		var fin = (data >> 7) != 0;
		//trace("opcode = 0x" + StringTools.hex(opcode) + "; fin = " + fin);
		
		var s = recvFrameData();
		
		return
		{
			code: opcode,
			fin: fin,
			data: s
		};
	}
	
	function recvFrameData() : String
	{
		var data = socket.input.readByte();
		
		if (!isServer)
		{
			if (data & 0x80 == 0) // !mask
			{
				var len = data & 0x7F;
				
				if (len == 126)
				{
					var lenByte0 = socket.input.readByte();
					var lenByte1 = socket.input.readByte();
					len = (lenByte0 << 8) + lenByte1;
				}
				else
				if (len > 126)
				{
					var lenByte0 = socket.input.readByte();
					var lenByte1 = socket.input.readByte();
					var lenByte2 = socket.input.readByte();
					var lenByte3 = socket.input.readByte();
					len = (lenByte0 << 24) + (lenByte1 << 16) + (lenByte2 << 8) + lenByte3;
				}
				return socket.input.read(len).toString();
			}
			else
			{
				throw "Expected unmasked data.";
			}
		}
		else
		{
			if (data & 0x80 != 0) // mask
			{
				var len = data & 0x7F;
				
				if (len == 126)
				{
					var b2 = socket.input.readByte();
					var b3 = socket.input.readByte();
					len = (b2 << 8) + b3;
				}
				else
				if (len == 127)
				{
					var b2 = socket.input.readByte();
					var b3 = socket.input.readByte();
					var b4 = socket.input.readByte();
					var b5 = socket.input.readByte();
					len = (b2 << 24) + (b3 << 16) + (b4 << 8) + b5;
				}
				
				//Sys.println("len = " + len);
				
				// direct array init not work corectly!
				var mask = [];
				mask.push(socket.input.readByte());
				mask.push(socket.input.readByte());
				mask.push(socket.input.readByte());
				mask.push(socket.input.readByte());
				
				//Sys.println("mask = " + mask);
				
				var r = new StringBuf();
				for (i in 0...len)
				{
					r.addChar(socket.input.readByte() ^ mask[i % 4]);
				}
				
				//Sys.println("readed = " + r.toString());
				return r.toString();
			}
			else
			{
				throw "Expected masked data.";
			}
		}
	}
}