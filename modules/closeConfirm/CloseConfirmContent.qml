import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import org.kde.kirigami as Kirigami
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root
    focus: true

    required property var targetWindow
    signal confirm()
    signal cancel()

    readonly property string appId: targetWindow?.app_id ?? ""
    readonly property string appTitle: targetWindow?.title ?? ""

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            root.cancel()
            event.accepted = true
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.confirm()
            event.accepted = true
        }
    }

    // Scrim
    Rectangle {
        id: bg
        anchors.fill: parent
        color: Appearance.colors.colScrim
        opacity: 0
        Component.onCompleted: opacity = 1
        Behavior on opacity {
            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.cancel()
        }
    }

    // Dialog using Material WindowDialog
    WindowDialog {
        anchors.centerIn: parent
        backgroundWidth: 340
        show: false
        Component.onCompleted: show = true

        // App icon row
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Kirigami.Icon {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                source: root.appId
                fallback: "application-x-executable"
                roundToIconSize: false
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                WindowDialogTitle {
                    Layout.fillWidth: true
                    text: Translation.tr("Close this window?")
                }

                // App title
                StyledText {
                    Layout.fillWidth: true
                    text: root.appTitle || root.appId || Translation.tr("Unknown")
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.m3colors.m3onSurface
                    elide: Text.ElideMiddle
                    maximumLineCount: 1
                }

                // App ID (if different)
                StyledText {
                    Layout.fillWidth: true
                    text: root.appId
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                    visible: root.appId !== "" && root.appId !== root.appTitle
                    elide: Text.ElideMiddle
                }
            }
        }

        // Buttons
        WindowDialogButtonRow {
            Item { Layout.fillWidth: true }

            DialogButton {
                buttonText: Translation.tr("Cancel")
                onClicked: root.cancel()
            }

            DialogButton {
                buttonText: Translation.tr("Close")
                colText: Appearance.colors.colError
                colEnabled: Appearance.colors.colError
                onClicked: root.confirm()
            }
        }
    }
}
