import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: root
    forceWidth: true
    settingsPageIndex: 8
    settingsPageName: Translation.tr("Shortcuts")

    // Info banner showing keybind source
    Rectangle {
        Layout.fillWidth: true
        Layout.bottomMargin: 8
        implicitHeight: infoBannerRow.implicitHeight + 16
        radius: Appearance.rounding.normal
        color: Appearance.colors.colSurfaceContainerLow ?? Appearance.colors.colLayer0
        border.width: 1
        border.color: Appearance.m3colors.m3outlineVariant ?? "transparent"
        visible: CompositorService.isNiri

        RowLayout {
            id: infoBannerRow
            anchors {
                fill: parent
                margins: 8
            }
            spacing: 8

            MaterialSymbol {
                text: NiriKeybinds.loaded ? "check_circle" : "info"
                iconSize: Appearance.font.pixelSize.larger
                color: NiriKeybinds.loaded ? Appearance.colors.colPrimary : Appearance.colors.colSubtext
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                StyledText {
                    text: NiriKeybinds.loaded 
                        ? Translation.tr("Keybinds loaded from your niri config")
                        : Translation.tr("Using default keybinds")
                    font.pixelSize: Appearance.font.pixelSize.small
                    font.weight: Font.Medium
                    color: Appearance.colors.colOnLayer1
                }

                StyledText {
                    visible: NiriKeybinds.configPath !== ""
                    text: NiriKeybinds.configPath
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.family: Appearance.font.family.monospace
                    color: Appearance.colors.colSubtext
                    elide: Text.ElideMiddle
                    Layout.fillWidth: true
                }
            }

            RippleButton {
                implicitWidth: 32
                implicitHeight: 32
                buttonRadius: Appearance.rounding.full
                colBackground: "transparent"
                
                ToolTip.visible: hovered
                ToolTip.text: Translation.tr("Reload keybinds")
                ToolTip.delay: 500

                onClicked: NiriKeybinds.reload()

                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    text: "refresh"
                    iconSize: Appearance.font.pixelSize.larger
                    color: Appearance.colors.colOnLayer1
                }
            }
        }
    }

    // Keyboard shortcut badge component
    component KeyBadge: Rectangle {
        property string keyText
        implicitWidth: Math.max(keyLabel.implicitWidth + 12, 28)
        implicitHeight: 26
        radius: Appearance.rounding.small
        color: Appearance.colors.colSurfaceContainerHighest ?? Appearance.colors.colLayer1
        border.width: 1
        border.color: Appearance.m3colors.m3outlineVariant ?? "transparent"

        StyledText {
            id: keyLabel
            anchors.centerIn: parent
            text: parent.keyText
            font.pixelSize: Appearance.font.pixelSize.smaller
            font.family: Appearance.font.family.monospace
            font.weight: Font.Medium
            color: Appearance.colors.colOnLayer1
        }
    }

    // Single shortcut row with key badges
    component ShortcutItem: RowLayout {
        required property var keys  // Array of key strings, e.g. ["Super", "T"]
        required property string action
        Layout.fillWidth: true
        spacing: 8

        // Keys container
        Row {
            Layout.preferredWidth: 180
            Layout.alignment: Qt.AlignVCenter
            spacing: 4

            Repeater {
                model: keys
                delegate: Row {
                    required property string modelData
                    required property int index
                    spacing: 4

                    KeyBadge { keyText: modelData }

                    // Plus sign between keys
                    StyledText {
                        visible: index < keys.length - 1
                        text: "+"
                        font.pixelSize: Appearance.font.pixelSize.small
                        color: Appearance.colors.colSubtext
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        // Action description
        StyledText {
            Layout.fillWidth: true
            text: action
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnLayer2
            elide: Text.ElideRight
        }
    }

    // Category header
    component CategoryHeader: RowLayout {
        required property string icon
        required property string title
        Layout.fillWidth: true
        Layout.topMargin: 16
        Layout.bottomMargin: 8
        spacing: 8

        MaterialSymbol {
            text: icon
            iconSize: Appearance.font.pixelSize.larger
            color: Appearance.colors.colPrimary
        }

        StyledText {
            text: title
            font.pixelSize: Appearance.font.pixelSize.large
            font.weight: Font.Medium
            color: Appearance.colors.colOnLayer1
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            Layout.leftMargin: 8
            color: Appearance.m3colors.m3outlineVariant ?? Appearance.colors.colLayer1Border
        }
    }

    // Two-column grid for shortcuts
    component ShortcutGrid: GridLayout {
        Layout.fillWidth: true
        columns: 2
        columnSpacing: 24
        rowSpacing: 8
    }

    // ═══════════════════════════════════════════════════════════════════════
    // SYSTEM
    // ═══════════════════════════════════════════════════════════════════════
    CategoryHeader { icon: "settings_power"; title: Translation.tr("System") }

    ShortcutGrid {
        ShortcutItem { keys: ["Super", "Tab"]; action: Translation.tr("Niri Overview") }
        ShortcutItem { keys: ["Super", "Space"]; action: Translation.tr("ii Overview") }
        ShortcutItem { keys: ["Super", "Shift", "E"]; action: Translation.tr("Quit Niri") }
        ShortcutItem { keys: ["Super", "Esc"]; action: Translation.tr("Toggle shortcuts inhibit") }
        ShortcutItem { keys: ["Super", "Shift", "O"]; action: Translation.tr("Power off monitors") }
        ShortcutItem { keys: ["Super", ","]; action: Translation.tr("Settings") }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // APPLICATIONS
    // ═══════════════════════════════════════════════════════════════════════
    CategoryHeader { icon: "apps"; title: Translation.tr("Applications") }

    ShortcutGrid {
        ShortcutItem { keys: ["Super", "T"]; action: Translation.tr("Terminal") }
        ShortcutItem { keys: ["Super", "Return"]; action: Translation.tr("Terminal (alt)") }
        ShortcutItem { keys: ["Super", "E"]; action: Translation.tr("File Manager") }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // WINDOW MANAGEMENT
    // ═══════════════════════════════════════════════════════════════════════
    CategoryHeader { icon: "web_asset"; title: Translation.tr("Window Management") }

    ShortcutGrid {
        ShortcutItem { keys: ["Super", "Q"]; action: Translation.tr("Close window") }
        ShortcutItem { keys: ["Super", "F"]; action: Translation.tr("Fullscreen") }
        ShortcutItem { keys: ["Super", "D"]; action: Translation.tr("Maximize column") }
        ShortcutItem { keys: ["Super", "A"]; action: Translation.tr("Toggle floating") }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // WINDOW SWITCHER
    // ═══════════════════════════════════════════════════════════════════════
    CategoryHeader { icon: "swap_horiz"; title: Translation.tr("Window Switcher") }

    ShortcutGrid {
        ShortcutItem { keys: ["Alt", "Tab"]; action: Translation.tr("Next window") }
        ShortcutItem { keys: ["Alt", "Shift", "Tab"]; action: Translation.tr("Previous window") }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // FOCUS & NAVIGATION
    // ═══════════════════════════════════════════════════════════════════════
    CategoryHeader { icon: "open_with"; title: Translation.tr("Focus & Navigation") }

    ShortcutGrid {
        ShortcutItem { keys: ["Super", "←"]; action: Translation.tr("Focus left") }
        ShortcutItem { keys: ["Super", "→"]; action: Translation.tr("Focus right") }
        ShortcutItem { keys: ["Super", "↑"]; action: Translation.tr("Focus up") }
        ShortcutItem { keys: ["Super", "↓"]; action: Translation.tr("Focus down") }
        ShortcutItem { keys: ["Super", "H/J/K/L"]; action: Translation.tr("Vim-style focus") }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // MOVE WINDOWS
    // ═══════════════════════════════════════════════════════════════════════
    CategoryHeader { icon: "drag_pan"; title: Translation.tr("Move Windows") }

    ShortcutGrid {
        ShortcutItem { keys: ["Super", "Shift", "←"]; action: Translation.tr("Move left") }
        ShortcutItem { keys: ["Super", "Shift", "→"]; action: Translation.tr("Move right") }
        ShortcutItem { keys: ["Super", "Shift", "↑"]; action: Translation.tr("Move up") }
        ShortcutItem { keys: ["Super", "Shift", "↓"]; action: Translation.tr("Move down") }
        ShortcutItem { keys: ["Super", "Shift", "H/J/K/L"]; action: Translation.tr("Vim-style move") }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // WORKSPACES
    // ═══════════════════════════════════════════════════════════════════════
    CategoryHeader { icon: "grid_view"; title: Translation.tr("Workspaces") }

    ShortcutGrid {
        ShortcutItem { keys: ["Super", "1-9"]; action: Translation.tr("Focus workspace 1-9") }
        ShortcutItem { keys: ["Super", "Shift", "1-5"]; action: Translation.tr("Move to workspace 1-5") }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // ii SHELL
    // ═══════════════════════════════════════════════════════════════════════
    CategoryHeader { icon: "auto_awesome"; title: Translation.tr("ii Shell") }

    ShortcutGrid {
        ShortcutItem { keys: ["Super", "G"]; action: Translation.tr("Toggle overlay") }
        ShortcutItem { keys: ["Super", "V"]; action: Translation.tr("Clipboard history") }
        ShortcutItem { keys: ["Super", "Alt", "L"]; action: Translation.tr("Lock screen") }
        ShortcutItem { keys: ["Super", "/"]; action: Translation.tr("Keyboard shortcuts") }
        ShortcutItem { keys: ["Ctrl", "Alt", "T"]; action: Translation.tr("Wallpaper selector") }
        ShortcutItem { keys: ["Super", "Shift", "W"]; action: Translation.tr("Cycle panel family") }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // REGION TOOLS
    // ═══════════════════════════════════════════════════════════════════════
    CategoryHeader { icon: "screenshot_region"; title: Translation.tr("Region Tools") }

    ShortcutGrid {
        ShortcutItem { keys: ["Super", "Shift", "S"]; action: Translation.tr("Screenshot region") }
        ShortcutItem { keys: ["Super", "Shift", "X"]; action: Translation.tr("OCR region") }
        ShortcutItem { keys: ["Super", "Shift", "A"]; action: Translation.tr("Google Lens search") }
        ShortcutItem { keys: ["Print"]; action: Translation.tr("Screenshot (full)") }
        ShortcutItem { keys: ["Ctrl", "Print"]; action: Translation.tr("Screenshot screen") }
        ShortcutItem { keys: ["Alt", "Print"]; action: Translation.tr("Screenshot window") }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // MEDIA & VOLUME
    // ═══════════════════════════════════════════════════════════════════════
    CategoryHeader { icon: "volume_up"; title: Translation.tr("Media & Volume") }

    ShortcutGrid {
        ShortcutItem { keys: ["XF86Audio", "+"]; action: Translation.tr("Volume up") }
        ShortcutItem { keys: ["XF86Audio", "-"]; action: Translation.tr("Volume down") }
        ShortcutItem { keys: ["XF86Audio", "Mute"]; action: Translation.tr("Mute toggle") }
        ShortcutItem { keys: ["XF86Audio", "MicMute"]; action: Translation.tr("Mic mute") }
        ShortcutItem { keys: ["Super", "Shift", "M"]; action: Translation.tr("Mute (keyboard)") }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // MEDIA PLAYBACK
    // ═══════════════════════════════════════════════════════════════════════
    CategoryHeader { icon: "play_circle"; title: Translation.tr("Media Playback") }

    ShortcutGrid {
        ShortcutItem { keys: ["XF86Audio", "Play"]; action: Translation.tr("Play/Pause") }
        ShortcutItem { keys: ["XF86Audio", "Next"]; action: Translation.tr("Next track") }
        ShortcutItem { keys: ["XF86Audio", "Prev"]; action: Translation.tr("Previous track") }
        ShortcutItem { keys: ["Super", "Shift", "P"]; action: Translation.tr("Play/Pause (keyboard)") }
        ShortcutItem { keys: ["Super", "Shift", "N"]; action: Translation.tr("Next (keyboard)") }
        ShortcutItem { keys: ["Super", "Shift", "B"]; action: Translation.tr("Previous (keyboard)") }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // BRIGHTNESS
    // ═══════════════════════════════════════════════════════════════════════
    CategoryHeader { icon: "brightness_6"; title: Translation.tr("Brightness") }

    ShortcutGrid {
        ShortcutItem { keys: ["XF86Brightness", "+"]; action: Translation.tr("Brightness up") }
        ShortcutItem { keys: ["XF86Brightness", "-"]; action: Translation.tr("Brightness down") }
    }

    // Spacer at bottom
    Item { Layout.preferredHeight: 20 }
}
