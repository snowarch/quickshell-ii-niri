import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    forceWidth: true
    settingsPageIndex: 7
    settingsPageName: Translation.tr("Shortcuts")

    ContentSection {
        icon: "keyboard"
        title: Translation.tr("System")

        ShortcutRow { keys: "Super + Tab"; action: Translation.tr("Toggle Overview") }
        ShortcutRow { keys: "Super + Shift + E"; action: Translation.tr("Quit Niri") }
        ShortcutRow { keys: "Super + Escape"; action: Translation.tr("Toggle shortcuts inhibit") }
        ShortcutRow { keys: "Super + Shift + O"; action: Translation.tr("Power off monitors") }
    }

    ContentSection {
        icon: "swap_horiz"
        title: Translation.tr("Window Switcher")

        ShortcutRow { keys: "Alt + Tab"; action: Translation.tr("Next window") }
        ShortcutRow { keys: "Alt + Shift + Tab"; action: Translation.tr("Previous window") }
    }

    ContentSection {
        icon: "apps"
        title: Translation.tr("Applications")

        ShortcutRow { keys: "Super + T"; action: Translation.tr("Terminal") }
        ShortcutRow { keys: "Super + Return"; action: Translation.tr("Terminal") }
        ShortcutRow { keys: "Super + E"; action: Translation.tr("File manager") }
    }

    ContentSection {
        icon: "web_asset"
        title: Translation.tr("Window Management")

        ShortcutRow { keys: "Super + Q"; action: Translation.tr("Close window") }
        ShortcutRow { keys: "Super + F"; action: Translation.tr("Fullscreen") }
        ShortcutRow { keys: "Super + A"; action: Translation.tr("Toggle floating") }
    }

    ContentSection {
        icon: "open_with"
        title: Translation.tr("Focus & Move")

        ShortcutRow { keys: "Super + Arrows / HJKL"; action: Translation.tr("Focus navigation") }
        ShortcutRow { keys: "Super + Shift + Arrows"; action: Translation.tr("Move window") }
        ShortcutRow { keys: "Super + 1-9"; action: Translation.tr("Focus workspace") }
        ShortcutRow { keys: "Super + Shift + 1-5"; action: Translation.tr("Move to workspace") }
    }

    ContentSection {
        icon: "auto_awesome"
        title: Translation.tr("ii Shell")

        ShortcutRow { keys: "Super + G"; action: Translation.tr("Toggle overlay") }
        ShortcutRow { keys: "Super + V"; action: Translation.tr("Clipboard history") }
        ShortcutRow { keys: "Super + Alt + L"; action: Translation.tr("Lock screen") }
        ShortcutRow { keys: "Super + /"; action: Translation.tr("Keyboard shortcuts") }
        ShortcutRow { keys: "Ctrl + Alt + T"; action: Translation.tr("Wallpaper selector") }
    }

    ContentSection {
        icon: "screenshot_region"
        title: Translation.tr("Region Tools")

        ShortcutRow { keys: "Super + Shift + S"; action: Translation.tr("Screenshot region") }
        ShortcutRow { keys: "Super + Shift + X"; action: Translation.tr("OCR region") }
        ShortcutRow { keys: "Super + Shift + A"; action: Translation.tr("Google Lens search") }
        ShortcutRow { keys: "Print"; action: Translation.tr("Screenshot") }
    }

    // Helper component for shortcut rows
    component ShortcutRow: RowLayout {
        required property string keys
        required property string action
        Layout.fillWidth: true
        spacing: 15

        Rectangle {
            Layout.preferredWidth: keyLabel.implicitWidth + 16
            Layout.preferredHeight: 28
            radius: Appearance.rounding.small
            color: Appearance.colors.colSurfaceContainerHighest ?? Appearance.colors.colLayer1
            border.width: 1
            border.color: Appearance.colors.colLayer1Border ?? "transparent"

            StyledText {
                id: keyLabel
                anchors.centerIn: parent
                text: keys
                font.pixelSize: Appearance.font.pixelSize.small
                font.family: "monospace"
                color: Appearance.colors.colOnLayer1
            }
        }

        StyledText {
            Layout.fillWidth: true
            text: action
            font.pixelSize: Appearance.font.pixelSize.normal
            color: Appearance.colors.colOnLayer2
        }
    }
}
