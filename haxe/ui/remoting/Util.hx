package haxe.ui.remoting;

class Util {
    public static function buildComponentInfo(c:ComponentInfo, indent:String = ""):String {
        var sb:StringBuf = new StringBuf();
        sb.add(indent);
        sb.add('> ');
        sb.add(c.className);
        if (c.id != null)                   sb.add(', id: ${c.id}');
        if (c.text != null)                 sb.add(', text: ${c.text}');
        if (c.left != null)                 sb.add(', left: ${c.left}');
        if (c.top != null)                  sb.add(', top: ${c.top}');
        if (c.width != null)                sb.add(', width: ${c.width}');
        if (c.height != null)               sb.add(', height: ${c.height}');
        if (c.percentWidth != null)         sb.add(', percentWidth: ${c.percentWidth}');
        if (c.percentHeight != null)        sb.add(', percentHeight: ${c.percentHeight}');
        sb.add("\n");
        
        if (c.children != null) {
            for (child in c.children) {
                sb.add(buildComponentInfo(child, indent + "  "));
            }
        }
        
        return sb.toString();
    }
}