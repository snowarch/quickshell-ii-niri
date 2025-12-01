import qs
import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: notificationPopup

    PanelWindow {
        id: root
        visible: (Notifications.popupList.length > 0) && !GlobalStates.screenLocked
        screen: CompositorService.isNiri 
            ? Quickshell.screens.find(s => s.name === NiriService.currentOutput) ?? Quickshell.screens[0]
            : Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? null

        WlrLayershell.namespace: "quickshell:notificationPopup"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        exclusiveZone: 0

        anchors {
            top: true
            right: true
        }

        color: "transparent"
        implicitWidth: Appearance.sizes.notificationPopupWidth
        implicitHeight: Math.min(listview.contentHeight + 8, screen?.height * 0.8 ?? 600)

        NotificationListView {
            id: listview
            anchors {
                fill: parent
                margins: 4
            }
            popup: true
        }
    }
}
