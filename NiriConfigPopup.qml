import QtQuick
import QtQuick.Layouts
import Quickshell
import Qt5Compat.GraphicalEffects
import qs.services

Scope {
    id: root
    property bool failed: false
    property string errorString: ""

    Connections {
        target: NiriService

        function onConfigLoadFinished(ok, error) {
            // Close any existing popup before showing a new one
            popupLoader.active = false

            root.failed = !ok
            root.errorString = error || ""
            popupLoader.loading = true
        }
    }

    LazyLoader {
        id: popupLoader

        PanelWindow {
            id: popup

            exclusiveZone: 0
            anchors.top: true
            margins.top: 0

            implicitWidth: rect.width + shadow.radius * 2
            implicitHeight: rect.height + shadow.radius * 2

            color: "transparent"

            Rectangle {
                id: rect
                anchors.centerIn: parent
                color: failed ? "#ffe99195" : "#ffD1E8D5"

                implicitHeight: layout.implicitHeight + 30
                implicitWidth: layout.implicitWidth + 30
                radius: 12

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    onPressed: popupLoader.active = false
                    hoverEnabled: true
                }

                ColumnLayout {
                    id: layout
                    spacing: 10
                    anchors {
                        top: parent.top
                        topMargin: 10
                        horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        renderType: Text.NativeRendering
                        font.family: "Rubik"
                        font.pointSize: 14
                        text: root.failed ? "Niri: config reload failed" : "Niri: config reloaded"
                        color: failed ? "#ff93000A" : "#ff0C1F13"
                    }

                    Text {
                        renderType: Text.NativeRendering
                        font.family: "JetBrains Mono NF"
                        font.pointSize: 11
                        text: root.errorString
                        color: failed ? "#ff93000A" : "#ff0C1F13"
                        visible: root.errorString !== ""
                    }
                }

                Rectangle {
                    z: 2
                    id: bar
                    color: failed ? "#ff93000A" : "#ff0C1F13"
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.margins: 10
                    height: 5
                    radius: 9999

                    PropertyAnimation {
                        id: anim
                        target: bar
                        property: "width"
                        from: rect.width - bar.anchors.margins * 2
                        to: 0
                        duration: failed ? 10000 : 1200
                        onFinished: popupLoader.active = false
                        paused: mouseArea.containsMouse
                    }
                }

                Rectangle {
                    z: 1
                    id: bar_bg
                    color: failed ? "#30af1b25" : "#4027643e"
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.margins: 10
                    height: 5
                    radius: 9999
                    width: rect.width - bar.anchors.margins * 2
                }

                Component.onCompleted: anim.start()
            }

            DropShadow {
                id: shadow
                anchors.fill: rect
                horizontalOffset: 0
                verticalOffset: 2
                radius: 6
                samples: radius * 2 + 1
                color: "#44000000"
                source: rect
            }
        }
    }
}
