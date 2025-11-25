import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

SettingsPage {
    id: root
    
    property var shortcuts: [
        {
            category: Translation.tr("System"),
            items: [
                { keys: "Super + Tab", action: Translation.tr("Toggle Overview") },
                { keys: "Super + Shift + E", action: Translation.tr("Quit Niri") },
                { keys: "Super + Escape", action: Translation.tr("Toggle keyboard shortcuts inhibit") },
                { keys: "Super + Shift + O", action: Translation.tr("Power off monitors") }
            ]
        },
        {
            category: Translation.tr("Window Switcher"),
            items: [
                { keys: "Alt + Tab", action: Translation.tr("Switch to next window") },
                { keys: "Alt + Shift + Tab", action: Translation.tr("Switch to previous window") }
            ]
        },
        {
            category: Translation.tr("Applications"),
            items: [
                { keys: "Super + T", action: Translation.tr("Open terminal") },
                { keys: "Super + Return", action: Translation.tr("Open terminal") },
                { keys: "Super + E", action: Translation.tr("Open file manager") }
            ]
        },
        {
            category: Translation.tr("Window Management"),
            items: [
                { keys: "Super + Q", action: Translation.tr("Close window") },
                { keys: "Super + F", action: Translation.tr("Toggle fullscreen") },
                { keys: "Super + A", action: Translation.tr("Toggle floating") }
            ]
        },
        {
            category: Translation.tr("Focus Navigation"),
            items: [
                { keys: "Super + Left / H", action: Translation.tr("Focus column left") },
                { keys: "Super + Right / L", action: Translation.tr("Focus column right") },
                { keys: "Super + Up / K", action: Translation.tr("Focus window up") },
                { keys: "Super + Down / J", action: Translation.tr("Focus window down") }
            ]
        },
        {
            category: Translation.tr("Move Windows"),
            items: [
                { keys: "Super + Shift + Left / H", action: Translation.tr("Move column left") },
                { keys: "Super + Shift + Right / L", action: Translation.tr("Move column right") },
                { keys: "Super + Shift + Up / K", action: Translation.tr("Move window up") },
                { keys: "Super + Shift + Down / J", action: Translation.tr("Move window down") }
            ]
        },
        {
            category: Translation.tr("Workspaces"),
            items: [
                { keys: "Super + 1-9", action: Translation.tr("Focus workspace 1-9") },
                { keys: "Super + Shift + 1-5", action: Translation.tr("Move window to workspace 1-5") }
            ]
        },
        {
            category: Translation.tr("ii Shell Features"),
            items: [
                { keys: "Super + G", action: Translation.tr("Toggle overlay") },
                { keys: "Super + V", action: Translation.tr("Toggle clipboard history") },
                { keys: "Super + Alt + L", action: Translation.tr("Lock screen") },
                { keys: "Ctrl + Alt + T", action: Translation.tr("Wallpaper selector") }
            ]
        },
        {
            category: Translation.tr("Region Tools"),
            items: [
                { keys: "Super + Shift + S", action: Translation.tr("Screenshot region") },
                { keys: "Super + Shift + X", action: Translation.tr("OCR region") },
                { keys: "Super + Shift + A", action: Translation.tr("Google Lens search") }
            ]
        },
        {
            category: Translation.tr("Screenshots (Native)"),
            items: [
                { keys: "Print", action: Translation.tr("Screenshot (select)") },
                { keys: "Ctrl + Print", action: Translation.tr("Screenshot screen") },
                { keys: "Alt + Print", action: Translation.tr("Screenshot window") }
            ]
        },
        {
            category: Translation.tr("Media"),
            items: [
                { keys: "XF86AudioRaiseVolume", action: Translation.tr("Volume up") },
                { keys: "XF86AudioLowerVolume", action: Translation.tr("Volume down") },
                { keys: "XF86AudioMute", action: Translation.tr("Toggle mute") }
            ]
        }
    ]

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        SettingsPageHeader {
            Layout.fillWidth: true
            title: Translation.tr("Keyboard Shortcuts")
            description: Translation.tr("Quick reference for Niri and ii keybindings")
        }

        SettingsScrollablePage {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                spacing: 15
                width: parent.width

                Repeater {
                    model: root.shortcuts

                    delegate: ContentSection {
                        required property var modelData
                        Layout.fillWidth: true
                        sectionTitle: modelData.category

                        Repeater {
                            model: modelData.items

                            delegate: RowLayout {
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.leftMargin: 10
                                Layout.rightMargin: 10
                                spacing: 20

                                // Keyboard shortcut badge
                                Rectangle {
                                    Layout.preferredWidth: keysText.implicitWidth + 20
                                    Layout.preferredHeight: 32
                                    radius: Appearance.rounding.small
                                    color: Appearance.colors.colSurfaceContainerHighest
                                    border.width: 1
                                    border.color: Appearance.colors.colLayer1Border

                                    StyledText {
                                        id: keysText
                                        anchors.centerIn: parent
                                        text: modelData.keys
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        font.family: "monospace"
                                        color: Appearance.colors.colOnLayer1
                                    }
                                }

                                StyledText {
                                    Layout.fillWidth: true
                                    text: modelData.action
                                    font.pixelSize: Appearance.font.pixelSize.normal
                                    color: Appearance.colors.colOnLayer2
                                    wrapMode: Text.Wrap
                                }
                            }
                        }
                    }
                }

                // Tip at bottom
                Rectangle {
                    Layout.fillWidth: true
                    Layout.margins: 10
                    radius: Appearance.rounding.normal
                    color: Appearance.colors.colPrimaryContainer
                    implicitHeight: tipLayout.implicitHeight + 20

                    RowLayout {
                        id: tipLayout
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        MaterialSymbol {
                            text: "lightbulb"
                            iconSize: 24
                            color: Appearance.colors.colOnPrimaryContainer
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: Translation.tr("Tip: Edit ~/.config/niri/config.kdl to customize keybindings")
                            font.pixelSize: Appearance.font.pixelSize.small
                            color: Appearance.colors.colOnPrimaryContainer
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }
        }
    }
}
