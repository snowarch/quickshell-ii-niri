import QtQuick
import QtQuick.Layouts
import Quickshell
import Qt5Compat.GraphicalEffects
import qs.modules.common

Item {
    id: root
    
    property string title: ""
    property string message: ""
    property string icon: "info"
    property bool isError: false
    property int duration: 3000
    property string source: "system" // "quickshell" or "niri"
    property color accentColor: Appearance.colors.colPrimary
    
    signal dismissed()
    signal copyRequested()
    
    property bool copied: false
    
    implicitWidth: card.width
    implicitHeight: card.height
    
    Rectangle {
        id: card
        width: contentLayout.implicitWidth + 32
        height: contentLayout.implicitHeight + 20
        radius: Appearance.rounding.normal
        color: root.isError ? Appearance.colors.colErrorContainer : Appearance.colors.colLayer1
        border.width: 1
        border.color: root.isError ? Appearance.colors.colError : root.accentColor
        
        // Left accent bar
        Rectangle {
            width: 4
            height: parent.height - 16
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            radius: 2
            color: root.isError ? Appearance.colors.colError : root.accentColor
        }
        
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.dismissed()
        }
        
        RowLayout {
            id: contentLayout
            anchors.centerIn: parent
            anchors.leftMargin: 20
            spacing: 10
            
            // Icon
            MaterialSymbol {
                text: root.icon
                iconSize: 20
                color: root.isError ? Appearance.colors.colOnErrorContainer : Appearance.colors.colOnLayer1
            }
            
            // Content
            ColumnLayout {
                spacing: 2
                Layout.maximumWidth: 400
                
                StyledText {
                    text: root.title
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.Medium
                    color: root.isError ? Appearance.colors.colOnErrorContainer : Appearance.colors.colOnLayer1
                }
                
                StyledText {
                    visible: root.message !== ""
                    text: root.message.length > 100 ? root.message.substring(0, 100) + "..." : root.message
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.family: root.isError ? "JetBrains Mono" : Appearance.font.family.main
                    color: Qt.rgba(
                        root.isError ? Appearance.m3colors.m3onErrorContainer.r : Appearance.m3colors.m3onSurface.r,
                        root.isError ? Appearance.m3colors.m3onErrorContainer.g : Appearance.m3colors.m3onSurface.g,
                        root.isError ? Appearance.m3colors.m3onErrorContainer.b : Appearance.m3colors.m3onSurface.b,
                        0.8
                    )
                    wrapMode: Text.WordWrap
                    Layout.maximumWidth: 350
                }
            }
            
            // Copy button (only for errors with message)
            RippleButton {
                visible: root.isError && root.message !== ""
                implicitWidth: 28
                implicitHeight: 28
                buttonRadius: Appearance.rounding.small
                colBackground: "transparent"
                colBackgroundHover: Qt.rgba(0, 0, 0, 0.1)
                onClicked: {
                    Quickshell.clipboardText = root.message
                    root.copied = true
                    copyResetTimer.restart()
                }
                
                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    text: root.copied ? "check" : "content_copy"
                    iconSize: 16
                    color: Appearance.colors.colOnErrorContainer
                }
                
                StyledToolTip {
                    text: root.copied ? "Copied!" : "Copy error"
                }
            }
            
            // Close button
            RippleButton {
                implicitWidth: 28
                implicitHeight: 28
                buttonRadius: Appearance.rounding.small
                colBackground: "transparent"
                colBackgroundHover: Qt.rgba(0, 0, 0, 0.1)
                onClicked: root.dismissed()
                
                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    text: "close"
                    iconSize: 16
                    color: root.isError ? Appearance.colors.colOnErrorContainer : Appearance.colors.colOnLayer1
                }
            }
        }
        
        // Progress bar
        Rectangle {
            id: progressBar
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.margins: 6
            height: 3
            radius: 2
            color: root.isError ? Appearance.colors.colError : root.accentColor
            
            PropertyAnimation {
                id: progressAnim
                target: progressBar
                property: "width"
                from: card.width - 12
                to: 0
                duration: root.duration
                onFinished: root.dismissed()
                paused: mouseArea.containsMouse
            }
        }
        
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.margins: 6
            height: 3
            radius: 2
            width: card.width - 12
            color: Qt.rgba(0, 0, 0, 0.1)
            z: -1
        }
        
        Component.onCompleted: progressAnim.start()
    }
    
    Timer {
        id: copyResetTimer
        interval: 2000
        onTriggered: root.copied = false
    }
    
    layer.enabled: true
    layer.effect: DropShadow {
        horizontalOffset: 0
        verticalOffset: 4
        radius: 12
        samples: 25
        color: "#30000000"
    }
}
