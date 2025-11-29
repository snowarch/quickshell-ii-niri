import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: root
    forceWidth: true
    settingsPageIndex: 4
    settingsPageName: Translation.tr("Themes")

    ContentSection {
        icon: "palette"
        title: Translation.tr("Color Themes")

        StyledText {
            Layout.fillWidth: true
            text: Translation.tr("Select a color theme to transform the visual appearance of your shell. Choose 'Auto' to use colors generated from your wallpaper.")
            color: Appearance.colors.colSubtext
            font.pixelSize: Appearance.font.pixelSize.smaller
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            MaterialSymbol {
                text: "check_circle"
                iconSize: Appearance.font.pixelSize.normal
                color: Appearance.m3colors.m3primary
            }

            StyledText {
                text: Translation.tr("Current theme: %1").arg(ThemePresets.getPreset(ThemeService.currentTheme).name)
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.m3colors.m3onSurface
            }
        }

        Flow {
            id: themeFlow
            Layout.fillWidth: true
            spacing: 12

            Repeater {
                model: ThemePresets.presets

                ThemePresetCard {
                    required property var modelData
                    width: Math.max(160, (themeFlow.width - themeFlow.spacing * 2) / 3)
                    preset: modelData
                    onClicked: ThemeService.setTheme(modelData.id)
                }
            }
        }
    }

    ContentSection {
        visible: ThemeService.currentTheme === "custom"
        icon: "edit"
        title: Translation.tr("Custom Theme Editor")

        Loader {
            Layout.fillWidth: true
            active: ThemeService.currentTheme === "custom"
            source: "CustomThemeEditor.qml"
        }
    }

    ContentSection {
        icon: "info"
        title: Translation.tr("About Themes")

        StyledText {
            Layout.fillWidth: true
            text: Translation.tr("Themes apply a complete Material 3 color palette to the shell. When using 'Auto (Wallpaper)', colors are dynamically generated from your current wallpaper using matugen. Manual themes provide consistent colors regardless of wallpaper.")
            color: Appearance.colors.colSubtext
            font.pixelSize: Appearance.font.pixelSize.smaller
            wrapMode: Text.WordWrap
        }
    }
}
