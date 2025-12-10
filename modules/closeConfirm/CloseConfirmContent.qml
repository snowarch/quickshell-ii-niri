import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

Item {
    id: root
    focus: true

    required property var targetWindow
    signal confirm()
    signal cancel()

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

    // Dialog card
    Rectangle {
        id: dialog
        anchors.centerIn: parent
        width: dialogContent.width + Appearance.rounding.large * 2
        height: dialogContent.height + Appearance.rounding.large * 2
        radius: Appearance.rounding.windowRounding
        color: Appearance.colors.colLayer0
        border.width: 1
        border.color: Appearance.colors.colLayer0Border

        // Entry animation
        scale: 0.9
        opacity: 0
        Component.onCompleted: { scale = 1; opacity = 1 }
        Behavior on scale {
            animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
        }
        Behavior on opacity {
            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
        }

        MouseArea { anchors.fill: parent }

        ColumnLayout {
            id: dialogContent
            anchors.centerIn: parent
            spacing: Appearance.sizes.spacingLarge

            // Icon circle - smaller
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: Appearance.font.pixelSize.huge + Appearance.sizes.spacingMedium
                height: width
                radius: width / 2
                color: Appearance.colors.colPrimaryContainer

                MaterialSymbol {
                    anchors.centerIn: parent
                    text: "close"
                    iconSize: Appearance.font.pixelSize.large
                    color: Appearance.colors.colOnPrimaryContainer
                }
            }

            // Title
            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: Translation.tr("Close Window?")
                font {
                    family: Appearance.font.family.title
                    pixelSize: Appearance.font.pixelSize.title
                    variableAxes: Appearance.font.variableAxes.title
                }
                color: Appearance.m3colors.m3onSurface
            }

            // App info card
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: Math.min(buttonsRow.width, 320)
                Layout.maximumWidth: 320
                implicitHeight: appInfoColumn.implicitHeight + Appearance.sizes.spacingMedium * 2
                radius: Appearance.rounding.normal
                color: Appearance.colors.colLayer1

                ColumnLayout {
                    id: appInfoColumn
                    anchors.fill: parent
                    anchors.margins: Appearance.sizes.spacingMedium
                    spacing: Appearance.sizes.spacingSmall / 2

                    StyledText {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: root.targetWindow?.app_id ?? Translation.tr("Unknown")
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.weight: Font.Medium
                        color: Appearance.colors.colPrimary
                        elide: Text.ElideMiddle
                    }

                    StyledText {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: root.targetWindow?.title ?? ""
                        font.pixelSize: Appearance.font.pixelSize.small
                        color: Appearance.colors.colSubtext
                        elide: Text.ElideMiddle
                        visible: text !== "" && text !== (root.targetWindow?.app_id ?? "")
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                    }
                }
            }

            // Buttons
            RowLayout {
                id: buttonsRow
                Layout.alignment: Qt.AlignHCenter
                spacing: Appearance.sizes.spacingMedium

                RippleButton {
                    Layout.preferredWidth: Appearance.sizes.searchWidthCollapsed / 2
                    Layout.preferredHeight: Appearance.sizes.baseBarHeight - Appearance.sizes.spacingSmall
                    buttonRadius: Appearance.rounding.normal
                    colBackground: Appearance.colors.colLayer2
                    colBackgroundHover: Appearance.colors.colLayer2Hover
                    colRipple: Appearance.colors.colLayer2Active

                    StyledText {
                        anchors.centerIn: parent
                        text: Translation.tr("Cancel")
                        font.pixelSize: Appearance.font.pixelSize.normal
                        color: Appearance.m3colors.m3onSurface
                    }

                    onClicked: root.cancel()
                }

                RippleButton {
                    Layout.preferredWidth: Appearance.sizes.searchWidthCollapsed / 2
                    Layout.preferredHeight: Appearance.sizes.baseBarHeight - Appearance.sizes.spacingSmall
                    buttonRadius: Appearance.rounding.normal
                    colBackground: Appearance.colors.colPrimary
                    colBackgroundHover: Appearance.colors.colPrimaryHover
                    colRipple: Appearance.colors.colPrimaryActive

                    StyledText {
                        anchors.centerIn: parent
                        text: Translation.tr("Close")
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.weight: Font.Medium
                        color: Appearance.colors.colOnPrimary
                    }

                    onClicked: root.confirm()
                }
            }
        }
    }
}
