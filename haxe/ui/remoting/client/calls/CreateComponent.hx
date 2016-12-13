package haxe.ui.remoting.client.calls;
import haxe.ui.core.Component;
import haxe.ui.core.Screen;

class CreateComponent extends Call {
    public function new() {
        super();
    }

    public override function execute(details:Dynamic):Dynamic {
        if (details == null) {
            return false;
        }
        var componentString:String = details.componentString;
        var component:Component = Toolkit.componentFromString(componentString);
        Screen.instance.addComponent(component);
        return true;
    }
}