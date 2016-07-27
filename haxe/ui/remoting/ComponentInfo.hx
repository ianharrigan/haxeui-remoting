package haxe.ui.remoting;

typedef ComponentInfo = {
    var className:String;
    @:optional var id:String;
    @:optional var children:Array<ComponentInfo>;
    @:optional var left:Float;
    @:optional var top:Float;
    @:optional var width:Float;
    @:optional var height:Float;
    @:optional var percentWidth:Float;
    @:optional var percentHeight:Float;
    @:optional var text:String;
}
