import qs.modules.common
import qs.modules.common.widgets

// Alias to the generic ContextMenu with dock-specific defaults
ContextMenu {
    popupAbove: !(Config.options?.dock?.top ?? false)
}
