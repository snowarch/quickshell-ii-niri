import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects
import qs.modules.common
import qs.modules.common.widgets

Scope {
    id: root
    property bool failed: false
    property string errorString: ""
    property int maxErrorLines: 8
    property int maxErrorWidth: 500

    function copyError() {
        if (errorString) {
            Quickshell.clipboardText = errorString
            copyButton.copied = true
            copyResetTimer.restart()
        }
    }

    Timer {
        id: copyResetTimer
        interval: 2000
        onTriggered: copyButton.copied = false
    }

    Connections {
        target: Quickshell

        function onReloadCompleted() {
            root.failed = false
            root.errorString = ""
            popupLoader.loading = true
        }

        function onReloadFailed(error: string) {
            popupLoader.active = false
            root.failed = true
            root.errorString = error
            popupLoader.loading = true
        }
    }

    LazyLoader {
        id: popupLoader

        PanelWindow {
            id: popup
            exclusiveZone: 0
            anchors.top: true
            margins.top: 10
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "quickshell:reload-popup"

            implicitWidth: rect.width + shadow.radius * 2
            implicitHeight: rect.height + shadow.radius * 2
            color: "transparent"

            Rectangle {
                id: rect
                anchors.centerIn: parent
                color: failed ? Appearance.colors.colErrorContainer : Appearance.m3colors.m3successContainer
                border.color: failed ? Appearance.colors.colError : Appearance.m3colors.m3success
                border.width: 1

                implicitHeight: layout.implicitHeight + 24
                implicitWidth: Math.min(layout.implicitWidth + 32, root.maxErrorWidth + 64)
                radius: Appearance.rounding.normal

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    onClicked: popupLoader.active = false
                    hoverEnabled: true
                }

                ColumnLayout {
                    id: layout
                    spacing: 8
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        topMargin: 12
                        leftMargin: 16
                        rightMargin: 16
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        MaterialSymbol {
                            text: root.failed ? "error" : "check_circle"
                            iconSize: 20
                            color: root.failed ? Appearance.colors.colOnErrorContainer : Appearance.m3colors.m3onSuccessContainer
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: root.failed ? "Quickshell reload failed" : "Quickshell reloaded"
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: Font.Medium
                            color: root.failed ? Appearance.colors.colOnErrorContainer : Appearance.m3colors.m3onSuccessContainer
                        }

                        // Copy button (only when error)
                        RippleButton {
                            id: copyButton
                            property bool copied: false
                            visible: root.failed && root.errorString !== ""
                            implicitWidth: 28
                            implicitHeight: 28
                            buttonRadius: Appearance.rounding.small
                            colBackground: "transparent"
                            colBackgroundHover: Qt.rgba(0, 0, 0, 0.1)
                            onClicked: root.copyError()

                            contentItem: MaterialSymbol {
                                anchors.centerIn: parent
                                text: copyButton.copied ? "check" : "content_copy"
                                iconSize: 16
                                color: root.failed ? Appearance.colors.colOnErrorContainer : Appearance.m3colors.m3onSuccessContainer
                            }

                            StyledToolTip {
                                text: copyButton.copied ? "Copied!" : "Copy error"
                            }
                        }
                    }

                    // Error details (scrollable if too long)
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.min(errorText.implicitHeight + 16, root.maxErrorLines * 16 + 16)
                        visible: root.errorString !== ""
                        color: Qt.rgba(0, 0, 0, 0.15)
                        radius: Appearance.rounding.small

                        Flickable {
                            id: errorFlickable
                            anchors.fill: parent
                            anchors.margins: 8
                            contentHeight: errorText.implicitHeight
                            clip: true
                            boundsBehavior: Flickable.StopAtBounds

                            Text {
                                id: errorText
                                width: errorFlickable.width
                                text: root.errorString
                                font.family: "JetBrains Mono"
                                font.pixelSize: 11
                                color: root.failed ? Appearance.colors.colOnErrorContainer : Appearance.m3colors.m3onSuccessContainer
                                wrapMode: Text.WrapAnywhere
                                textFormat: Text.PlainText
                            }

                            // Scroll indicator
                            Rectangle {
                                visible: errorFlickable.contentHeight > errorFlickable.height
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: 3
                                radius: 2
                                color: Qt.rgba(0, 0, 0, 0.2)

                                Rectangle {
                                    width: parent.width
                                    height: Math.max(20, parent.height * (errorFlickable.height / errorFlickable.contentHeight))
                                    y: (parent.height - height) * (errorFlickable.contentY / (errorFlickable.contentHeight - errorFlickable.height))
                                    radius: 2
                                    color: Qt.rgba(0, 0, 0, 0.4)
                                }
                            }
                        }
                    }

                    // Hint text
                    StyledText {
                        visible: root.failed
                        text: "Click to dismiss • Check qs log -c ii for details"
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Qt.rgba(root.failed ? Appearance.m3colors.m3onErrorContainer.r : Appearance.m3colors.m3onTertiaryContainer.r,
                                       root.failed ? Appearance.m3colors.m3onErrorContainer.g : Appearance.m3colors.m3onTertiaryContainer.g,
                                       root.failed ? Appearance.m3colors.m3onErrorContainer.b : Appearance.m3colors.m3onTertiaryContainer.b, 0.7)
                    }
                }

                // Progress bar
                Rectangle {
                    z: 2
                    id: bar
                    color: failed ? Appearance.colors.colError : Appearance.m3colors.m3success
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.margins: 8
                    height: 3
                    radius: 2

                    PropertyAnimation {
                        id: anim
                        target: bar
                        property: "width"
                        from: rect.width - bar.anchors.margins * 2
                        to: 0
                        duration: failed ? 15000 : 2000
                        onFinished: popupLoader.active = false
                        paused: mouseArea.containsMouse || (errorFlickable.moving)
                    }
                }

                Rectangle {
                    z: 1
                    color: Qt.rgba(0, 0, 0, 0.1)
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.margins: 8
                    height: 3
                    radius: 2
                    width: rect.width - anchors.margins * 2
                }

                Component.onCompleted: anim.start()
            }

            DropShadow {
                id: shadow
                anchors.fill: rect
                horizontalOffset: 0
                verticalOffset: 4
                radius: 12
                samples: 25
                color: "#40000000"
                source: rect
            }
        }
    }
}
