import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    forceWidth: true
    settingsPageIndex: 9
    settingsPageName: Translation.tr("Modules")

    ContentSection {
        icon: "extension"
        title: Translation.tr("Shell Modules")

        StyledText {
            Layout.fillWidth: true
            text: Translation.tr("Enable or disable shell modules. Disabled modules are not loaded, saving memory. Changes require shell restart.")
            color: Appearance.colors.colSubtext
            font.pixelSize: Appearance.font.pixelSize.smaller
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            RippleButton {
                Layout.fillWidth: true
                implicitHeight: 36
                buttonRadius: Appearance.rounding.small
                colBackground: Appearance.colors.colPrimaryContainer
                colBackgroundHover: Appearance.colors.colPrimaryContainerHover
                colRipple: Appearance.colors.colPrimaryContainerActive

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    MaterialSymbol {
                        text: "refresh"
                        iconSize: Appearance.font.pixelSize.normal
                        color: Appearance.m3colors.m3onPrimaryContainer
                    }
                    StyledText {
                        text: Translation.tr("Restart shell")
                        font.pixelSize: Appearance.font.pixelSize.small
                        color: Appearance.m3colors.m3onPrimaryContainer
                    }
                }

                onClicked: Quickshell.execDetached(["bash", "-c", "qs kill -c ii; sleep 0.3; qs -c ii"])
            }

            RippleButton {
                Layout.fillWidth: true
                implicitHeight: 36
                buttonRadius: Appearance.rounding.small
                colBackground: Appearance.colors.colLayer1
                colBackgroundHover: Appearance.colors.colLayer1Hover
                colRipple: Appearance.colors.colLayer1Active

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    MaterialSymbol {
                        text: "restart_alt"
                        iconSize: Appearance.font.pixelSize.normal
                        color: Appearance.m3colors.m3onSurface
                    }
                    StyledText {
                        text: Translation.tr("Reset to defaults")
                        font.pixelSize: Appearance.font.pixelSize.small
                    }
                }

                onClicked: {
                    Config.options.modules.altSwitcher = true
                    Config.options.modules.bar = true
                    Config.options.modules.background = true
                    Config.options.modules.cheatsheet = true
                    Config.options.modules.clipboard = true
                    Config.options.modules.crosshair = false
                    Config.options.modules.dock = true
                    Config.options.modules.lock = true
                    Config.options.modules.mediaControls = true
                    Config.options.modules.notificationPopup = true
                    Config.options.modules.onScreenDisplay = true
                    Config.options.modules.onScreenKeyboard = true
                    Config.options.modules.overview = true
                    Config.options.modules.overlay = true
                    Config.options.modules.polkit = true
                    Config.options.modules.regionSelector = true
                    Config.options.modules.reloadPopup = true
                    Config.options.modules.screenCorners = true
                    Config.options.modules.sessionScreen = true
                    Config.options.modules.sidebarLeft = true
                    Config.options.modules.sidebarRight = true
                    Config.options.modules.verticalBar = true
                    Config.options.modules.wallpaperSelector = true
                }
            }
        }
    }

    ContentSection {
        icon: "dashboard"
        title: Translation.tr("Core Modules")

        ConfigSwitch {
            buttonIcon: "toolbar"
            text: Translation.tr("Bar")
            checked: Config.options.modules.bar
            onCheckedChanged: Config.options.modules.bar = checked
            StyledToolTip { text: Translation.tr("Top/bottom bar with clock, workspaces, tray") }
        }

        ConfigSwitch {
            buttonIcon: "wallpaper"
            text: Translation.tr("Background")
            checked: Config.options.modules.background
            onCheckedChanged: Config.options.modules.background = checked
            StyledToolTip { text: Translation.tr("Wallpaper and background widgets") }
        }

        ConfigSwitch {
            buttonIcon: "overview_key"
            text: Translation.tr("Overview")
            checked: Config.options.modules.overview
            onCheckedChanged: Config.options.modules.overview = checked
            StyledToolTip { text: Translation.tr("Workspace overview grid") }
        }

        ConfigSwitch {
            buttonIcon: "layers"
            text: Translation.tr("Overlay")
            checked: Config.options.modules.overlay
            onCheckedChanged: Config.options.modules.overlay = checked
            StyledToolTip { text: Translation.tr("Search overlay and widgets") }
        }
    }

    ContentSection {
        icon: "side_navigation"
        title: Translation.tr("Sidebars")

        ConfigSwitch {
            buttonIcon: "left_panel_open"
            text: Translation.tr("Left Sidebar")
            checked: Config.options.modules.sidebarLeft
            onCheckedChanged: Config.options.modules.sidebarLeft = checked
            StyledToolTip { text: Translation.tr("AI chat, translator, wallpaper browser") }
        }

        ConfigSwitch {
            buttonIcon: "right_panel_open"
            text: Translation.tr("Right Sidebar")
            checked: Config.options.modules.sidebarRight
            onCheckedChanged: Config.options.modules.sidebarRight = checked
            StyledToolTip { text: Translation.tr("Quick settings, calendar, notepad") }
        }
    }

    ContentSection {
        icon: "notifications"
        title: Translation.tr("Notifications & OSD")

        ConfigSwitch {
            buttonIcon: "notifications"
            text: Translation.tr("Notification Popup")
            checked: Config.options.modules.notificationPopup
            onCheckedChanged: Config.options.modules.notificationPopup = checked
        }

        ConfigSwitch {
            buttonIcon: "tune"
            text: Translation.tr("On-Screen Display")
            checked: Config.options.modules.onScreenDisplay
            onCheckedChanged: Config.options.modules.onScreenDisplay = checked
            StyledToolTip { text: Translation.tr("Volume/brightness indicators") }
        }

        ConfigSwitch {
            buttonIcon: "play_circle"
            text: Translation.tr("Media Controls")
            checked: Config.options.modules.mediaControls
            onCheckedChanged: Config.options.modules.mediaControls = checked
        }
    }

    ContentSection {
        icon: "build"
        title: Translation.tr("Utilities")

        ConfigSwitch {
            buttonIcon: "screenshot_frame"
            text: Translation.tr("Region Selector")
            checked: Config.options.modules.regionSelector
            onCheckedChanged: Config.options.modules.regionSelector = checked
            StyledToolTip { text: Translation.tr("Screenshot, OCR, screen recording") }
        }

        ConfigSwitch {
            buttonIcon: "wallpaper_slideshow"
            text: Translation.tr("Wallpaper Selector")
            checked: Config.options.modules.wallpaperSelector
            onCheckedChanged: Config.options.modules.wallpaperSelector = checked
        }

        ConfigSwitch {
            buttonIcon: "keyboard"
            text: Translation.tr("Keyboard Shortcuts")
            checked: Config.options.modules.cheatsheet
            onCheckedChanged: Config.options.modules.cheatsheet = checked
            StyledToolTip { text: Translation.tr("Keybindings cheatsheet overlay") }
        }

        ConfigSwitch {
            buttonIcon: "power_settings_new"
            text: Translation.tr("Session Screen")
            checked: Config.options.modules.sessionScreen
            onCheckedChanged: Config.options.modules.sessionScreen = checked
            StyledToolTip { text: Translation.tr("Lock, logout, suspend, reboot, shutdown") }
        }

        ConfigSwitch {
            buttonIcon: "lock"
            text: Translation.tr("Lock Screen")
            checked: Config.options.modules.lock
            onCheckedChanged: Config.options.modules.lock = checked
        }
    }

    ContentSection {
        icon: "more_horiz"
        title: Translation.tr("Optional Modules")

        ConfigSwitch {
            buttonIcon: "call_to_action"
            text: Translation.tr("Dock")
            checked: Config.options.modules.dock
            onCheckedChanged: Config.options.modules.dock = checked
            StyledToolTip { text: Translation.tr("Bottom dock with pinned apps") }
        }

        ConfigSwitch {
            buttonIcon: "point_scan"
            text: Translation.tr("Crosshair")
            checked: Config.options.modules.crosshair
            onCheckedChanged: Config.options.modules.crosshair = checked
            StyledToolTip { text: Translation.tr("Gaming crosshair overlay") }
        }

        ConfigSwitch {
            buttonIcon: "keyboard"
            text: Translation.tr("On-Screen Keyboard")
            checked: Config.options.modules.onScreenKeyboard
            onCheckedChanged: Config.options.modules.onScreenKeyboard = checked
        }

        ConfigSwitch {
            buttonIcon: "security"
            text: Translation.tr("Polkit Agent")
            checked: Config.options.modules.polkit
            onCheckedChanged: Config.options.modules.polkit = checked
            StyledToolTip { text: Translation.tr("Authentication dialogs for sudo, etc.") }
        }

        ConfigSwitch {
            buttonIcon: "rounded_corner"
            text: Translation.tr("Screen Corners")
            checked: Config.options.modules.screenCorners
            onCheckedChanged: Config.options.modules.screenCorners = checked
            StyledToolTip { text: Translation.tr("Rounded screen corner overlays") }
        }

        ConfigSwitch {
            buttonIcon: "swap_horiz"
            text: Translation.tr("Alt-Tab Switcher")
            checked: Config.options.modules.altSwitcher
            onCheckedChanged: Config.options.modules.altSwitcher = checked
            StyledToolTip { text: Translation.tr("Custom window switcher") }
        }

        ConfigSwitch {
            buttonIcon: "content_paste"
            text: Translation.tr("Clipboard Manager")
            checked: Config.options.modules.clipboard
            onCheckedChanged: Config.options.modules.clipboard = checked
            StyledToolTip { text: Translation.tr("Clipboard history panel") }
        }
    }
}
