package haxe.ui.remoting.client.calls;

import haxe.ui.core.Component;
import haxe.ui.core.Screen;
import haxe.ui.remoting.ComponentInfo;

class ListComponents extends Call {
    public function new() {
        super();
    }
    
    public override function execute(details:Dynamic):Dynamic {
        var components = new Array<ComponentInfo>();
        for (component in Screen.instance.rootComponents) {
            var className:String = Type.getClassName(Type.getClass(component));
            var componentInfo:ComponentInfo = {
               className: className 
            };
            buildComponentTree(component, componentInfo);
            components.push(componentInfo);
        }
        return components;
    }
    
    @:access(haxe.ui.core.Component)
    private static function buildComponentTree(c:Component, i:ComponentInfo) {
        if (c.id != null)                           i.id = c.id;
        if (c.left != null)                         i.left = c.componentWidth;
        if (c.top != null)                          i.top = c.componentHeight;
        if (c.componentWidth != null)               i.width = c.componentWidth;
        if (c.componentHeight != null)              i.height = c.componentHeight;
        if (c.percentWidth != null)                 i.percentWidth = c.percentWidth;
        if (c.percentHeight != null)                i.percentHeight = c.percentHeight;
        if (c.text != null)                         i.text = c.text;
        
        for (child in c.childComponents) {
            var childInfo:ComponentInfo = {
                className: Type.getClassName(Type.getClass(child))
            }
            buildComponentTree(child, childInfo);
            if (i.children == null) {
                i.children = new Array<ComponentInfo>();
            }
            i.children.push(childInfo);
        }
    }
}