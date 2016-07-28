package haxe.ui.remoting.client.calls;
import haxe.ui.core.Component;
import haxe.ui.core.Screen;

class HighlightComponent extends Call {
    private static var overlay:Component;
    
    public function new() {
        super();
    }
    
    @:access(haxe.ui.core.Component)
    public override function execute(details:Map<String, String>):Dynamic {
        var id:String = details.get("id");
        var hightlight:Bool = (details.get("highlight") == "true");
        
        var component:Component = Screen.instance.rootComponents[0].findComponent(id, Component, true);
        if (component != null) {
            if (hightlight == true) {
                if (overlay == null) {
                    overlay = new Component();
                    overlay.includeInLayout = false;
                    overlay.styleString = "border: 2px solid #FF0000;background-color: #FFCCCC; border-radius:2px;opacity: 0.5";
                }
                
                overlay.left = component.screenLeft;
                overlay.top = component.screenTop;
                overlay.width = component.componentWidth;
                overlay.height = component.componentHeight;
                
                Screen.instance.addComponent(overlay);
            } else {
                if (overlay != null) {
                    Screen.instance.removeComponent(overlay);
                }
            }
        }
        
        return null;
    }
}