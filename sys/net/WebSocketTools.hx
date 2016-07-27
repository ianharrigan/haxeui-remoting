package sys.net;

import haxe.crypto.Sha1;
import sys.net.Socket;

class WebSocketTools
{
    public static function sendServerHandShake(socket:Socket, inpKey:String)
    {
        var outKey = encodeBase64(hex2data(Sha1.encode(StringTools.trim(inpKey) + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11")));

        var s = "HTTP/1.1 101 Switching Protocols\r\n"
              + "Upgrade: websocket\r\n"
              + "Connection: Upgrade\r\n"
              + "Sec-WebSocket-Accept: " + outKey + "\r\n"
              + "\r\n";

        socket.output.writeString(s);
    }

    public static function sendClientHandShake(socket:Socket, url:String, host:String, port:Int, key:String, origin:String)
    {
        var s = "GET " + url + " HTTP/1.1\r\n"
              + "Host: " + host + ":" + Std.string(port) + "\r\n"
              + "Upgrade: websocket\r\n"
              + "Connection: Upgrade\r\n"
              + "Sec-WebSocket-Key: " + encodeBase64(key) + "\r\n"
              + "Origin: " + origin + "\r\n"
              + "\r\n";


        socket.output.writeString(s);
    }

    static function hex2data(hex:String) : String
    {
        var data = "";
        for (i in 0...Std.int(hex.length / 2))
        {
            data += String.fromCharCode(Std.parseInt("0x" + hex.substr(i * 2, 2)));
        }
        return data;
    }

    static function encodeBase64(content:String) : String
    {
        var suffix = switch (content.length % 3)
        {
            case 2: "=";
            case 1: "==";
            default: "";
        };
        return haxe.crypto.BaseCode.encode(content, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/") + suffix;
    }
}