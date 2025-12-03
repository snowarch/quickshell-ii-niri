pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.modules.waffle.looks

Scope {
    id: root

    Connections {
        target: GlobalStates
        function onWaffleClipboardOpenChanged() {
            if (GlobalStates.waffleClipboardOpen) panelLoader.active = true
        }
    }

    // Click-outside-to-close overlay
    LazyLoader {
        active: GlobalStates.waffleClipboardOpen
        component: PanelWindow {
            anchors { top: true; bottom: true; left: true; right: true }
            WlrLayershell.namespace: "quickshell:wClipboardBg"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            color: "transparent"
            MouseArea {
                anchors.fill: parent
                onClicked: GlobalStates.waffleClipboardOpen = false
            }
        }
    }

    Loader {
        id: panelLoader
        active: GlobalStates.waffleClipboardOpen
        sourceComponent: PanelWindow {
            id: panelWindow
            exclusiveZone: 0
            WlrLayershell.namespace: "quickshell:wClipboard"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            color: "transparent"

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            Connections {
                target: GlobalStates
                function onWaffleClipboardOpenChanged() {
                    if (!GlobalStates.waffleClipboardOpen) content.close()
                }
            }

            WaffleClipboardContent {
                id: content
                anchors.centerIn: parent
                anchors.verticalCenterOffset: (Config.options.waffles?.bar?.bottom ?? true) ? -30 : 30
                onClosed: {
                    GlobalStates.waffleClipboardOpen = false
                    panelLoader.active = false
                }
            }
        }
    }

    // IPC handler - only active when waffle family is active
    IpcHandler {
        target: "clipboard"
        enabled: Config.options?.panelFamily === "waffle"
        function toggle(): void { GlobalStates.waffleClipboardOpen = !GlobalStates.waffleClipboardOpen }
        function close(): void { GlobalStates.waffleClipboardOpen = false }
        function open(): void { GlobalStates.waffleClipboardOpen = true }
    }
}
