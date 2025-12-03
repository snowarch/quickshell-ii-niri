pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.modules.waffle.looks

Item {
    id: root

    required property var item
    property bool selected: false
    property bool compact: false

    signal clicked

    implicitWidth: compact ? 72 : parent?.width ?? 380
    implicitHeight: compact ? 72 : 56

    // Compact mode: icon tile
    Loader {
        active: root.compact
        anchors.fill: parent
        sourceComponent: Item {
            AcrylicRectangle {
                id: compactBg
                anchors.centerIn: parent
                width: 64
                height: 64
                radius: Looks.radius.large
                shiny: root.selected || compactMouse.containsMouse
                color: {
                    if (compactMouse.pressed) return Looks.colors.bg2Active
                    if (root.selected) return Looks.colors.accent
                    if (compactMouse.containsMouse) return Looks.colors.bg2Hover
                    return Looks.colors.bg2
                }
                scale: compactMouse.pressed ? 0.92 : 1.0

                Behavior on color {
                    animation: Looks.transition.color.createObject(this)
                }
                Behavior on scale {
                    animation: Looks.transition.enter.createObject(this)
                }

                WAppIcon {
                    anchors.centerIn: parent
                    implicitSize: 36
                    iconName: AppSearch.guessIcon(root.item?.appId ?? root.item?.appName ?? "")
                    tryCustomIcon: false
                    monochrome: false
                }

                // Selection indicator pill
                Rectangle {
                    visible: root.selected
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: 6
                    width: 20
                    height: 3
                    radius: height / 2
                    color: Looks.colors.accentFg
                }
            }

            MouseArea {
                id: compactMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.clicked()
            }

            // Tooltip - using BarToolTip pattern
            WPopupToolTip {
                extraVisibleCondition: compactMouse.containsMouse && !root.selected
                text: root.item?.appName ?? root.item?.title ?? ""
            }
        }
    }

    // List mode: full row with icon, title, subtitle
    Loader {
        active: !root.compact
        anchors.fill: parent
        sourceComponent: Item {
            AcrylicRectangle {
                id: listBg
                anchors.fill: parent
                anchors.margins: 2
                radius: Looks.radius.medium
                shiny: root.selected || listMouse.containsMouse
                color: {
                    if (listMouse.pressed) return Looks.colors.bg2Active
                    if (root.selected) return Looks.colors.accent
                    if (listMouse.containsMouse) return Looks.colors.bg2Hover
                    return Looks.colors.bg1Base
                }

                Behavior on color {
                    animation: Looks.transition.color.createObject(this)
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 12

                    // Selection indicator dot
                    Rectangle {
                        Layout.alignment: Qt.AlignVCenter
                        width: 6
                        height: 6
                        radius: 3
                        color: root.selected ? Looks.colors.accentFg : "transparent"
                        visible: root.selected
                    }

                    // App icon
                    WAppIcon {
                        Layout.alignment: Qt.AlignVCenter
                        implicitSize: 32
                        iconName: AppSearch.guessIcon(root.item?.appId ?? root.item?.appName ?? "")
                        tryCustomIcon: false
                        monochrome: false
                    }

                    // Text content
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 2

                        WText {
                            Layout.fillWidth: true
                            text: root.item?.appName ?? root.item?.title ?? "Window"
                            font.pixelSize: Looks.font.pixelSize.large
                            font.weight: root.selected ? Looks.font.weight.strong : Looks.font.weight.regular
                            color: root.selected ? Looks.colors.accentFg : Looks.colors.fg
                            elide: Text.ElideRight
                        }

                        WText {
                            Layout.fillWidth: true
                            text: {
                                const wsIdx = root.item?.workspaceIdx
                                const title = root.item?.title
                                if (wsIdx && wsIdx > 0 && title && title !== root.item?.appName)
                                    return "WS " + wsIdx + " · " + title
                                if (wsIdx && wsIdx > 0)
                                    return "WS " + wsIdx
                                if (title && title !== root.item?.appName)
                                    return title
                                return ""
                            }
                            visible: text !== ""
                            font.pixelSize: Looks.font.pixelSize.small
                            color: root.selected ? ColorUtils.transparentize(Looks.colors.accentFg, 0.3) : Looks.colors.subfg
                            elide: Text.ElideRight
                        }
                    }

                    // Workspace badge
                    Rectangle {
                        Layout.alignment: Qt.AlignVCenter
                        visible: (root.item?.workspaceIdx ?? 0) > 0
                        width: wsText.implicitWidth + 12
                        height: 22
                        radius: Looks.radius.medium
                        color: root.selected 
                            ? ColorUtils.transparentize(Looks.colors.accentFg, 0.8)
                            : Looks.colors.bg1

                        WText {
                            id: wsText
                            anchors.centerIn: parent
                            text: root.item?.workspaceIdx ?? ""
                            font.pixelSize: Looks.font.pixelSize.small
                            font.weight: Looks.font.weight.strong
                            color: root.selected ? Looks.colors.accentFg : Looks.colors.subfg
                        }
                    }
                }
            }

            MouseArea {
                id: listMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.clicked()
            }
        }
    }
}
