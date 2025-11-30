import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

Rectangle {
    id: root
    required property PwNode node
    PwObjectTracker {
        objects: [root.node]
    }

    implicitHeight: rowLayout.implicitHeight + Appearance.sizes.spacingMedium * 2
    radius: Appearance.rounding.small
    color: Appearance.colors.colLayer2

    RowLayout {
        id: rowLayout
        anchors {
            fill: parent
            margins: Appearance.sizes.spacingMedium
        }
        spacing: Appearance.sizes.spacingMedium

        Rectangle {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: Appearance.rounding.small
            color: Appearance.colors.colLayer3

            Image {
                anchors.centerIn: parent
                sourceSize.width: 24
                sourceSize.height: 24
                source: {
                    let icon = AppSearch.guessIcon(root.node?.properties["application.icon-name"] ?? "");
                    if (AppSearch.iconExists(icon))
                        return Quickshell.iconPath(icon, "image-missing");
                    icon = AppSearch.guessIcon(root.node?.properties["node.name"] ?? "");
                    return Quickshell.iconPath(icon, "image-missing");
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                
                StyledText {
                    Layout.fillWidth: true
                    font.pixelSize: Appearance.font.pixelSize.small
                    elide: Text.ElideRight
                    text: Audio.appNodeDisplayName(root.node)
                }
                
                StyledText {
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                    text: Math.round((root.node?.audio.volume ?? 0) * 100) + "%"
                }
            }

            StyledSlider {
                Layout.fillWidth: true
                value: root.node?.audio.volume ?? 0
                onMoved: root.node.audio.volume = value
                configuration: StyledSlider.Configuration.S
            }
        }

        RippleButton {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            buttonRadius: Appearance.rounding.full
            colBackground: root.node?.audio.muted ? Appearance.colors.colErrorContainer : "transparent"
            colBackgroundHover: root.node?.audio.muted ? Appearance.colors.colErrorContainer : Appearance.colors.colLayer3Hover
            colRipple: Appearance.colors.colLayer3Active
            onClicked: root.node.audio.muted = !root.node.audio.muted

            contentItem: MaterialSymbol {
                anchors.centerIn: parent
                text: root.node?.audio.muted ? "volume_off" : "volume_up"
                iconSize: Appearance.font.pixelSize.normal
                color: root.node?.audio.muted ? Appearance.colors.colOnErrorContainer : Appearance.colors.colOnLayer2
            }
        }
    }
}
