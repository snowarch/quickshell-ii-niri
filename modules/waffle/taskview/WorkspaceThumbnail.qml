pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.waffle.looks

Item {
    id: root

    required property var workspace
    required property int workspaceIndex
    required property real thumbnailWidth
    required property real thumbnailHeight
    property bool isActive: false
    property bool isSelected: false
    property bool isDragTarget: false
    property bool isLastEmpty: false

    property bool isEmpty: false  // True if workspace has no windows (but not the "new desktop" placeholder)
    
    signal clicked()
    signal dragEntered()
    signal closeRequested()

    readonly property real labelHeight: 24
    readonly property real labelSpacing: 8
    
    implicitWidth: thumbnailWidth
    implicitHeight: thumbnailHeight + labelHeight + labelSpacing

    // Entry animation - respects GameMode
    opacity: 0
    transform: Translate { id: entryTranslate; y: 20 }
    
    Component.onCompleted: {
        if (Looks.transition.enabled) {
            entryAnim.start()
        } else {
            opacity = 1
            entryTranslate.y = 0
        }
    }
    
    SequentialAnimation {
        id: entryAnim
        PauseAnimation { duration: root.workspaceIndex * 40 }
        ParallelAnimation {
            NumberAnimation { 
                target: root
                property: "opacity"
                to: 1
                duration: Looks.transition.enabled ? 180 : 0
                easing.type: Easing.OutCubic 
            }
            NumberAnimation { 
                target: entryTranslate
                property: "y"
                to: 0
                duration: Looks.transition.enabled ? 180 : 0
                easing.type: Easing.OutCubic 
            }
        }
    }

    readonly property string wallpaperPath: {
        const wBg = Config.options?.waffles?.background ?? {}
        if (wBg.useMainWallpaper ?? true)
            return Config.options?.background?.wallpaperPath ?? ""
        return wBg.wallpaperPath ?? Config.options?.background?.wallpaperPath ?? ""
    }

    readonly property string workspaceName: {
        if (root.isLastEmpty) return Translation.tr("New desktop")
        const customNames = Config.options?.waffles?.workspaceNames ?? {}
        const idx = workspace?.idx ?? (workspaceIndex + 1)
        return customNames[idx.toString()] ?? Translation.tr("Desktop") + " " + idx
    }

    property bool isEditing: false
    
    signal workspaceRenamed(int wsIdx, string newName)

    // Label above thumbnail
    Column {
        id: labelColumn
        anchors.bottom: thumbnailContainer.top
        anchors.bottomMargin: root.labelSpacing
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 2

        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.max(nameLabel.width, nameEditor.width)
            height: nameLabel.height
            
            WText {
                id: nameLabel
                anchors.centerIn: parent
                visible: !root.isEditing
                text: root.workspaceName
                font.pixelSize: Looks.font.pixelSize.normal
                font.weight: root.isActive ? Font.DemiBold : Font.Normal
                color: root.isActive ? Looks.colors.fg : ColorUtils.transparentize(Looks.colors.fg, 0.3)
                
                Behavior on color { 
                    ColorAnimation { 
                        duration: Looks.transition.enabled ? 120 : 0 
                    } 
                }
                
                MouseArea {
                    anchors.fill: parent
                    onDoubleClicked: {
                        if (!root.isLastEmpty) {
                            root.isEditing = true
                            nameEditor.text = root.workspaceName
                            nameEditor.forceActiveFocus()
                            nameEditor.selectAll()
                        }
                    }
                }
            }
            
            Rectangle {
                anchors.centerIn: parent
                visible: root.isEditing
                width: nameEditor.width + 16
                height: nameEditor.height + 8
                radius: Looks.radius.small
                color: Looks.colors.bg2Base
                border.width: 1
                border.color: Looks.colors.accent
                
                TextInput {
                    id: nameEditor
                    anchors.centerIn: parent
                    width: Math.max(80, contentWidth + 4)
                    font.pixelSize: Looks.font.pixelSize.normal
                    font.weight: Font.DemiBold
                    color: Looks.colors.fg
                    selectionColor: Looks.colors.accent
                    selectedTextColor: Looks.colors.fg
                    horizontalAlignment: Text.AlignHCenter
                    
                    onAccepted: {
                        if (text.trim() !== "") {
                            const idx = root.workspace?.idx ?? (root.workspaceIndex + 1)
                            root.workspaceRenamed(idx, text.trim())
                        }
                        root.isEditing = false
                    }
                    
                    Keys.onEscapePressed: {
                        root.isEditing = false
                    }
                    
                    onFocusChanged: {
                        if (!focus && root.isEditing) {
                            root.isEditing = false
                        }
                    }
                }
            }
        }
        
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.isActive ? nameLabel.width : 0
            height: 2
            radius: 1
            color: Looks.colors.accent
            visible: !root.isEditing
            
            Behavior on width { 
                NumberAnimation { 
                    duration: Looks.transition.enabled ? 150 : 0
                    easing.type: Easing.OutCubic 
                } 
            }
        }
    }

    Item {
        id: thumbnailContainer
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.thumbnailWidth
        height: root.thumbnailHeight

        WRectangularShadow {
            target: thumbnailRect
            visible: root.isActive || root.isDragTarget || thumbnailArea.containsMouse
        }

        Rectangle {
            id: thumbnailRect
            anchors.fill: parent
            radius: Looks.radius.large
            color: root.isLastEmpty ? ColorUtils.transparentize(Looks.colors.bg1Base, 0.4) : Looks.colors.bg0Opaque
            border.width: (root.isActive || root.isDragTarget || (root.isLastEmpty && thumbnailArea.containsMouse)) ? 2 : 1
            border.color: (root.isActive || root.isDragTarget || (root.isLastEmpty && thumbnailArea.containsMouse)) ? Looks.colors.accent : Looks.colors.bg2Border
            clip: true

            // No scale - causes layout issues
            opacity: root.isSelected ? 1 : (thumbnailArea.containsMouse ? 0.9 : 0.7)
            
            Behavior on opacity { 
                NumberAnimation { 
                    duration: Looks.transition.enabled ? 150 : 0
                    easing.type: Easing.OutCubic 
                } 
            }
            Behavior on color { 
                ColorAnimation { 
                    duration: Looks.transition.enabled ? 120 : 0 
                } 
            }
            Behavior on border.color { 
                ColorAnimation { 
                    duration: Looks.transition.enabled ? 100 : 0 
                } 
            }

            Image {
                id: wallpaperSource
                anchors.fill: parent
                anchors.margins: 1
                source: root.wallpaperPath ? "file://" + root.wallpaperPath : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: false
            }

            MultiEffect {
                anchors.fill: parent
                anchors.margins: 1
                source: wallpaperSource
                blurEnabled: true
                blur: 0.4
                blurMax: 32
                saturation: 0.6
                
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: thumbnailRect.width - 2
                        height: thumbnailRect.height - 2
                        radius: Looks.radius.large - 1
                    }
                }
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                radius: Looks.radius.large - 1
                color: Qt.rgba(0, 0, 0, thumbnailArea.containsMouse ? 0.15 : (root.isActive ? 0.2 : 0.3))
                Behavior on color { 
                    ColorAnimation { 
                        duration: Looks.transition.enabled ? 120 : 0 
                    } 
                }
            }
            
            // "New desktop" plus icon
            Item {
                anchors.centerIn: parent
                width: 64
                height: 64
                visible: root.isLastEmpty
                opacity: thumbnailArea.containsMouse ? 1 : 0.6
                Behavior on opacity { 
                    NumberAnimation { 
                        duration: Looks.transition.enabled ? 120 : 0 
                    } 
                }
                
                Rectangle {
                    anchors.centerIn: parent
                    width: 48
                    height: 48
                    radius: Looks.radius.large
                    color: thumbnailArea.containsMouse ? ColorUtils.transparentize(Looks.colors.accent, 0.7) : ColorUtils.transparentize(Looks.colors.fg, 0.85)
                    border.width: 2
                    border.color: thumbnailArea.containsMouse ? Looks.colors.accent : ColorUtils.transparentize(Looks.colors.fg, 0.6)
                    Behavior on color { 
                        ColorAnimation { 
                            duration: Looks.transition.enabled ? 120 : 0 
                        } 
                    }
                    Behavior on border.color { 
                        ColorAnimation { 
                            duration: Looks.transition.enabled ? 120 : 0 
                        } 
                    }
                    
                    WText {
                        anchors.centerIn: parent
                        text: "+"
                        font.pixelSize: 28
                        font.weight: Font.Light
                        color: thumbnailArea.containsMouse ? Looks.colors.accent : Looks.colors.fg
                        Behavior on color { 
                            ColorAnimation { 
                                duration: Looks.transition.enabled ? 120 : 0 
                            } 
                        }
                    }
                }
            }

            MouseArea {
                id: thumbnailArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.clicked()
            }

            DropArea {
                anchors.fill: parent
                z: 100
                onEntered: root.dragEntered()
            }
            
            // Close button for empty workspaces
            Rectangle {
                id: closeBtn
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.rightMargin: 8
                anchors.topMargin: 8
                width: 24
                height: 24
                radius: 12
                visible: root.isEmpty && !root.isLastEmpty && thumbnailArea.containsMouse
                color: closeBtnArea.containsMouse ? Looks.colors.danger : ColorUtils.transparentize(Looks.colors.bg0Opaque, 0.3)
                z: 10
                
                Behavior on color { 
                    ColorAnimation { 
                        duration: Looks.transition.enabled ? 100 : 0 
                    } 
                }
                
                WText {
                    anchors.centerIn: parent
                    text: "✕"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: closeBtnArea.containsMouse ? "white" : Looks.colors.fg
                }
                
                MouseArea {
                    id: closeBtnArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.closeRequested()
                }
            }
        }
    }
}
