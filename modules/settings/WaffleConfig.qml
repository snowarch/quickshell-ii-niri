import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

ContentPage {
    id: root
    forceWidth: true
    settingsPageIndex: 10
    settingsPageName: Translation.tr("Waffle Style")

    property bool isWaffleActive: Config.options?.panelFamily === "waffle"

    ContentSection {
        visible: !root.isWaffleActive
        icon: "info"
        title: Translation.tr("Not Active")

        StyledText {
            Layout.fillWidth: true
            text: Translation.tr("These settings only apply when using the Windows 11 (Waffle) panel style. Go to Modules → Panel Style to enable it.")
            color: Appearance.colors.colSubtext
            font.pixelSize: Appearance.font.pixelSize.small
            wrapMode: Text.WordWrap
        }
    }

    // Wallpaper section
    ContentSection {
        visible: root.isWaffleActive
        icon: "wallpaper"
        title: Translation.tr("Wallpaper")

        ConfigSwitch {
            buttonIcon: "link"
            text: Translation.tr("Use main wallpaper")
            checked: Config.options?.waffles?.background?.useMainWallpaper ?? true
            onCheckedChanged: {
                Config.options.waffles.background.useMainWallpaper = checked;
                if (checked) Config.options.waffles.background.wallpaperPath = "";
            }
            StyledToolTip { text: Translation.tr("Share wallpaper with Material ii style") }
        }

        // Button to pick main wallpaper (when using main)
        RippleButtonWithIcon {
            visible: Config.options?.waffles?.background?.useMainWallpaper ?? true
            Layout.fillWidth: true
            buttonRadius: Appearance.rounding.small
            materialIcon: "wallpaper"
            mainText: Translation.tr("Pick main wallpaper")
            onClicked: {
                // Use system file picker for main wallpaper (same as QuickConfig)
                Quickshell.execDetached(`${Directories.wallpaperSwitchScriptPath}`);
            }
        }

        // Button to pick Waffle-specific wallpaper (when NOT using main)
        RippleButtonWithIcon {
            visible: !(Config.options?.waffles?.background?.useMainWallpaper ?? true)
            Layout.fillWidth: true
            buttonRadius: Appearance.rounding.small
            materialIcon: "wallpaper"
            mainText: Translation.tr("Pick Waffle wallpaper")
            onClicked: {
                Config.options.wallpaperSelector.selectionTarget = "waffle";
                Quickshell.execDetached(["qs", "-c", "ii", "ipc", "call", "wallpaperSelector", "toggle"]);
            }
        }
    }

    ContentSection {
        visible: root.isWaffleActive
        icon: "toolbar"
        title: Translation.tr("Taskbar")

        ConfigSwitch {
            buttonIcon: "vertical_align_bottom"
            text: Translation.tr("Bottom position")
            checked: Config.options?.waffles?.bar?.bottom ?? true
            onCheckedChanged: Config.options.waffles.bar.bottom = checked
        }

        ConfigSwitch {
            buttonIcon: "format_align_left"
            text: Translation.tr("Left-align apps")
            checked: Config.options?.waffles?.bar?.leftAlignApps ?? false
            onCheckedChanged: Config.options.waffles.bar.leftAlignApps = checked
        }

        ConfigSwitch {
            buttonIcon: "palette"
            text: Translation.tr("Tint app icons")
            checked: Config.options?.waffles?.bar?.monochromeIcons ?? false
            onCheckedChanged: Config.options.waffles.bar.monochromeIcons = checked
            StyledToolTip { text: Translation.tr("Apply accent color tint to taskbar icons") }
        }

        ConfigSwitch {
            buttonIcon: "palette"
            text: Translation.tr("Tint tray icons")
            checked: Config.options?.waffles?.bar?.tintTrayIcons ?? false
            onCheckedChanged: Config.options.waffles.bar.tintTrayIcons = checked
            StyledToolTip { text: Translation.tr("Apply accent color tint to system tray icons") }
        }
    }

    ContentSection {
        visible: root.isWaffleActive
        icon: "auto_awesome"
        title: Translation.tr("Wallpaper Effects")

        ConfigSwitch {
            buttonIcon: "blur_on"
            text: Translation.tr("Enable dynamic blur")
            checked: Config.options?.waffles?.background?.effects?.enableBlur ?? false
            onCheckedChanged: Config.options.waffles.background.effects.enableBlur = checked
        }

        ConfigSpinBox {
            visible: Config.options?.waffles?.background?.effects?.enableBlur ?? false
            icon: "blur_medium"
            text: Translation.tr("Blur radius")
            from: 0; to: 64; stepSize: 2
            value: Config.options?.waffles?.background?.effects?.blurRadius ?? 32
            onValueChanged: Config.options.waffles.background.effects.blurRadius = value
        }

        ConfigSpinBox {
            icon: "brightness_5"
            text: Translation.tr("Dim (%)")
            from: 0; to: 100; stepSize: 5
            value: Config.options?.waffles?.background?.effects?.dim ?? 0
            onValueChanged: Config.options.waffles.background.effects.dim = value
        }
    }

    ContentSection {
        visible: root.isWaffleActive
        icon: "layers"
        title: Translation.tr("Backdrop")

        ConfigSwitch {
            buttonIcon: "blur_linear"
            text: Translation.tr("Enable backdrop")
            checked: Config.options?.waffles?.background?.backdrop?.enable ?? false
            onCheckedChanged: Config.options.waffles.background.backdrop.enable = checked
        }

        ConfigSwitch {
            visible: Config.options?.waffles?.background?.backdrop?.enable ?? false
            buttonIcon: "visibility_off"
            text: Translation.tr("Hide main wallpaper")
            checked: Config.options?.waffles?.background?.backdrop?.hideWallpaper ?? false
            onCheckedChanged: Config.options.waffles.background.backdrop.hideWallpaper = checked
        }

        ConfigSwitch {
            visible: Config.options?.waffles?.background?.backdrop?.enable ?? false
            buttonIcon: "link"
            text: Translation.tr("Use Waffle wallpaper")
            checked: Config.options?.waffles?.background?.backdrop?.useMainWallpaper ?? true
            onCheckedChanged: {
                Config.options.waffles.background.backdrop.useMainWallpaper = checked;
                if (checked) Config.options.waffles.background.backdrop.wallpaperPath = "";
            }
        }

        RippleButtonWithIcon {
            visible: (Config.options?.waffles?.background?.backdrop?.enable ?? false) 
                     && !(Config.options?.waffles?.background?.backdrop?.useMainWallpaper ?? true)
            Layout.fillWidth: true
            buttonRadius: Appearance.rounding.small
            materialIcon: "wallpaper"
            mainText: Translation.tr("Pick backdrop wallpaper")
            onClicked: {
                Config.options.wallpaperSelector.selectionTarget = "waffle-backdrop";
                Quickshell.execDetached(["qs", "-c", "ii", "ipc", "call", "wallpaperSelector", "toggle"]);
            }
        }

        ConfigSpinBox {
            visible: Config.options?.waffles?.background?.backdrop?.enable ?? false
            icon: "blur_on"
            text: Translation.tr("Blur radius")
            from: 0; to: 100; stepSize: 5
            value: Config.options?.waffles?.background?.backdrop?.blurRadius ?? 32
            onValueChanged: Config.options.waffles.background.backdrop.blurRadius = value
        }

        ConfigSpinBox {
            visible: Config.options?.waffles?.background?.backdrop?.enable ?? false
            icon: "brightness_5"
            text: Translation.tr("Dim (%)")
            from: 0; to: 100; stepSize: 5
            value: Config.options?.waffles?.background?.backdrop?.dim ?? 35
            onValueChanged: Config.options.waffles.background.backdrop.dim = value
        }
    }

    ContentSection {
        visible: root.isWaffleActive
        icon: "palette"
        title: Translation.tr("Theming")

        ConfigSwitch {
            buttonIcon: "format_color_fill"
            text: Translation.tr("Use Material colors")
            checked: Config.options?.waffles?.theming?.useMaterialColors ?? false
            onCheckedChanged: Config.options.waffles.theming.useMaterialColors = checked
            StyledToolTip { text: Translation.tr("Apply the Material ii color scheme instead of Windows 11 grey") }
        }
    }

    ContentSection {
        visible: root.isWaffleActive
        icon: "widgets"
        title: Translation.tr("Behavior")

        ConfigSwitch {
            buttonIcon: "stacks"
            text: Translation.tr("Allow multiple panels open")
            checked: Config.options?.waffles?.behavior?.allowMultiplePanels ?? false
            onCheckedChanged: Config.options.waffles.behavior.allowMultiplePanels = checked
            StyledToolTip { text: Translation.tr("Keep panels open when opening others") }
        }
    }

    ContentSection {
        visible: root.isWaffleActive
        icon: "grid_view"
        title: Translation.tr("Start Menu")

        ConfigSelectionArray {
            options: [
                { displayName: Translation.tr("Mini"), icon: "crop_square", value: "mini" },
                { displayName: Translation.tr("Compact"), icon: "view_compact", value: "compact" },
                { displayName: Translation.tr("Normal"), icon: "grid_view", value: "normal" },
                { displayName: Translation.tr("Large"), icon: "grid_on", value: "large" },
                { displayName: Translation.tr("Wide"), icon: "view_week", value: "wide" }
            ]
            currentValue: Config.options?.waffles?.startMenu?.sizePreset ?? "normal"
            onSelected: (newValue) => {
                Config.options.waffles.startMenu.sizePreset = newValue
            }
        }
    }

    ContentSection {
        visible: root.isWaffleActive
        icon: "tune"
        title: Translation.tr("Tweaks")

        ConfigSwitch {
            buttonIcon: "animation"
            text: Translation.tr("Smoother menu animations")
            checked: Config.options?.waffles?.tweaks?.smootherMenuAnimations ?? true
            onCheckedChanged: Config.options.waffles.tweaks.smootherMenuAnimations = checked
        }

        ConfigSwitch {
            buttonIcon: "toggle_on"
            text: Translation.tr("Switch handle position fix")
            checked: Config.options?.waffles?.tweaks?.switchHandlePositionFix ?? true
            onCheckedChanged: Config.options.waffles.tweaks.switchHandlePositionFix = checked
        }
    }

    ContentSection {
        visible: root.isWaffleActive
        icon: "calendar_month"
        title: Translation.tr("Calendar")

        ConfigSwitch {
            buttonIcon: "calendar_today"
            text: Translation.tr("Force 2-character day of week")
            checked: Config.options?.waffles?.calendar?.force2CharDayOfWeek ?? true
            onCheckedChanged: Config.options.waffles.calendar.force2CharDayOfWeek = checked
        }
    }

    ContentSection {
        visible: root.isWaffleActive
        icon: "widgets"
        title: Translation.tr("Widgets Panel")

        ConfigSwitch {
            buttonIcon: "schedule"
            text: Translation.tr("Date & Time")
            checked: Config.options?.waffles?.widgetsPanel?.showDateTime ?? true
            onCheckedChanged: Config.options.waffles.widgetsPanel.showDateTime = checked
        }

        ConfigSwitch {
            buttonIcon: "cloud"
            text: Translation.tr("Weather")
            checked: Config.options?.waffles?.widgetsPanel?.showWeather ?? true
            onCheckedChanged: Config.options.waffles.widgetsPanel.showWeather = checked
        }

        ConfigSwitch {
            buttonIcon: "memory"
            text: Translation.tr("System Resources")
            checked: Config.options?.waffles?.widgetsPanel?.showSystem ?? true
            onCheckedChanged: Config.options.waffles.widgetsPanel.showSystem = checked
        }

        ConfigSwitch {
            buttonIcon: "music_note"
            text: Translation.tr("Media Player")
            checked: Config.options?.waffles?.widgetsPanel?.showMedia ?? true
            onCheckedChanged: Config.options.waffles.widgetsPanel.showMedia = checked
        }

        ConfigSwitch {
            buttonIcon: "bolt"
            text: Translation.tr("Quick Actions")
            checked: Config.options?.waffles?.widgetsPanel?.showQuickActions ?? true
            onCheckedChanged: Config.options.waffles.widgetsPanel.showQuickActions = checked
        }
    }
}
