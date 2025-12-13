import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
    id: root

    Loader {
        id: sessionLoader
        active: GlobalStates.sessionOpen

        Connections {
            target: GlobalStates
            function onScreenLockedChanged() {
                if (GlobalStates.screenLocked) {
                    GlobalStates.sessionOpen = false
                }
            }
        }

        sourceComponent: PanelWindow {
            id: sessionRoot
            visible: sessionLoader.active

            function hide(): void {
                GlobalStates.sessionOpen = false
            }

            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.namespace: "quickshell:wSession"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            color: "#000000"

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            Item {
                anchors.fill: parent
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        sessionRoot.hide()
                    }
                }

                SessionScreenContent {
                    anchors.fill: parent
                }
            }
        }
    }

    IpcHandler {
        target: "session"

        function toggle(): void {
            GlobalStates.sessionOpen = !GlobalStates.sessionOpen
        }

        function close(): void {
            GlobalStates.sessionOpen = false
        }

        function open(): void {
            GlobalStates.sessionOpen = true
        }
    }
}
