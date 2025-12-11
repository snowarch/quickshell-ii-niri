import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

RippleButton {
    id: root
    required property var preset
    property bool isActive: preset.id === ThemeService.currentTheme

    implicitHeight: 44
    buttonRadius: Appearance.rounding.small
    colBackground: isActive ? Appearance.colors.colPrimaryContainer : Appearance.colors.colLayer2
    colBackgroundHover: isActive ? Appearance.colors.colPrimaryContainerHover : Appearance.colors.colLayer2Hover
    colRipple: isActive ? Appearance.colors.colPrimaryContainerActive : Appearance.colors.colLayer2Active

    contentItem: RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 10

        // Color swatches
        Row {
            spacing: -4

            Repeater {
                model: [
                    { key: "m3primary" },
                    { key: "m3secondary" },
                    { key: "m3background" }
                ]

                Rectangle {
                    required property var modelData
                    width: 16
                    height: 16
                    radius: 8
                    color: {
                        if (!preset.colors) return Appearance.m3colors[modelData.key]
                        if (preset.colors === "custom") return Config.options.appearance.customTheme[modelData.key] ?? "#888"
                        return preset.colors[modelData.key] ?? "#888"
                    }
                    border.width: 1
                    border.color: Appearance.colors.colOutlineVariant ?? Appearance.m3colors.m3outlineVariant
                }
            }
        }

        // Theme name
        StyledText {
            Layout.fillWidth: true
            text: preset.name
            font.pixelSize: Appearance.font.pixelSize.small
            color: isActive ? Appearance.m3colors.m3onPrimaryContainer : Appearance.colors.colOnLayer2
            elide: Text.ElideRight
        }

        // Active indicator
        MaterialSymbol {
            visible: root.isActive
            text: "check"
            iconSize: 16
            color: Appearance.m3colors.m3onPrimaryContainer
        }
    }
}
