package haxe.ui.remoting.client.calls;

import haxe.ui.core.Screen;

class RemoveAllChildComponents extends Call {
    public function new() {
        super();
    }

    public override function execute(details:Dynamic):Dynamic {
        for (r in Screen.instance.rootComponents) {
            Screen.instance.removeComponent(r);
        }
        return true;
    }
}