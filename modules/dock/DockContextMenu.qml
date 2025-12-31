import qs.modules.common
import qs.modules.common.widgets
import Quickshell

// Alias to the generic ContextMenu with dock-specific defaults
ContextMenu {
    readonly property string dockPosition: Config.options?.dock?.position ?? "bottom"
    readonly property bool isVertical: dockPosition === "left" || dockPosition === "right"
    
    // Para posiciones verticales: popup hacia el centro (right para left, left para right)
    // Para posiciones horizontales: popup arriba para bottom, abajo para top
    popupAbove: !isVertical && dockPosition !== "top"
    
    // Para posiciones verticales, usar gravity/edges horizontales (0 = none/vertical)
    popupSide: isVertical ? (dockPosition === "left" ? Edges.Right : Edges.Left) : 0
}
