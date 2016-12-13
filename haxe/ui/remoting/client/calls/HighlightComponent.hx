package haxe.ui.remoting.client.calls;

import haxe.ui.core.Component;
import haxe.ui.core.Screen;

class HighlightComponent extends Call {
    private static var overlay:Component;

    public function new() {
        super();
    }

    @:access(haxe.ui.core.Component)
    public override function execute(details:Dynamic):Dynamic {
        var id:String = details.id;
        var hightlight:Bool = (details.highlight == "true");

        var component:Component = Screen.instance.rootComponents[0].findComponent(id, Component, true);
        if (component != null) {
            if (hightlight == true) {
                if (overlay == null) {
                    overlay = new Component();
                    overlay.includeInLayout = false;
                    overlay.styleString = "border: 2px solid #FF0000;background-color: #FFCCCC; border-radius:2px;opacity: 0.5";
                    Screen.instance.addComponent(overlay);
                }

                overlay.left = component.screenLeft;
                overlay.top = component.screenTop;
                overlay.width = component.componentWidth;
                overlay.height = component.componentHeight;
                overlay.show();
            } else {
                if (overlay != null) {
                    //Screen.instance.removeComponent(overlay);
                    overlay.hide();
                }
            }
        }

        return null;
    }
}