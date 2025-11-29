import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

RippleButton {
    id: root
    required property var preset
    property bool isActive: preset.id === ThemeService.currentTheme

    implicitHeight: 100
    buttonRadius: Appearance.rounding.normal
    colBackground: isActive ? Appearance.colors.colPrimaryContainer : Appearance.colors.colLayer2
    colBackgroundHover: isActive ? Appearance.colors.colPrimaryContainerHover : Appearance.colors.colLayer2Hover
    colRipple: isActive ? Appearance.colors.colPrimaryContainerActive : Appearance.colors.colLayer2Active

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 6

        // Color swatches row
        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: [
                    { key: "m3primary" },
                    { key: "m3secondary" },
                    { key: "m3background" }
                ]

                Rectangle {
                    required property var modelData
                    width: 20
                    height: 20
                    radius: Appearance.rounding.small
                    color: {
                        if (!preset.colors) return Appearance.m3colors[modelData.key]
                        if (preset.colors === "custom") return Config.options.appearance.customTheme[modelData.key] ?? "#888"
                        return preset.colors[modelData.key] ?? "#888"
                    }
                    border.width: 1
                    border.color: Appearance.colors.colOutlineVariant
                }
            }

            Item { Layout.fillWidth: true }

            // Active indicator
            MaterialSymbol {
                visible: root.isActive
                text: "check_circle"
                iconSize: 18
                fill: 1
                color: Appearance.m3colors.m3primary
            }
        }

        // Theme name
        StyledText {
            Layout.fillWidth: true
            text: preset.name
            font.pixelSize: Appearance.font.pixelSize.small
            font.weight: Font.Medium
            color: isActive ? Appearance.m3colors.m3onPrimaryContainer : Appearance.colors.colOnLayer2
            elide: Text.ElideRight
        }

        // Description
        StyledText {
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: preset.description
            font.pixelSize: Appearance.font.pixelSize.smallest
            color: isActive ? Appearance.m3colors.m3onPrimaryContainer : Appearance.colors.colSubtext
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            maximumLineCount: 2
        }
    }
}
