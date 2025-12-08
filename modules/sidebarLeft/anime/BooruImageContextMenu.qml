import qs.modules.common
import qs.modules.common.widgets

// Context menu for booru images - centered and stays open
ContextMenu {
    closeOnHoverLost: false  // Don't auto-close on hover lost - only on click outside
    closeOnFocusLost: true
    popupAbove: false  // Use bottom positioning, will be centered via anchor
}
