package haxe.ui.remoting.server;

import haxe.Serializer;
import haxe.Unserializer;
import haxe.ui.remoting.Msg;

class Client {
    public var uuid:String;

    private var _callMap:Map<String, Dynamic->Void> = new Map<String, Dynamic->Void>();
    public function new() {

    }

    public function sendMessage(msg:Msg) {
        throw "Not implemented";
    }

    public function makeCall(id:String, params:Map<String, String> = null, fn:Dynamic->Void = null) {
        if (fn != null) {
            _callMap.set(id, fn);
        }
        sendMessage({
           id: id,
           details: params
        });
    }

    private function onMessageInternal(msg:Msg):Bool {
        var fn:Dynamic->Void = _callMap.get(msg.id);
        if (fn == null) {
            return false;
        }

        fn(msg.details);

        return true;
    }

    public function close() {
        
    }
    
    public static function serializeMsg(msg:Msg):String {
        var serializer:Serializer = new Serializer();
        serializer.serialize(msg);
        return serializer.toString();
    }

    public static function unserializeMsg(data:String):Msg {
        var unserializer:Unserializer = new Unserializer(data);
        var msg:Msg = unserializer.unserialize();
        return msg;
    }
}