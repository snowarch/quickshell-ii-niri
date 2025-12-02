import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
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

        RippleButtonWithIcon {
            visible: Config.options?.waffles?.background?.useMainWallpaper ?? true
            Layout.fillWidth: true
            buttonRadius: Appearance.rounding.small
            materialIcon: "wallpaper"
            mainText: Translation.tr("Pick main wallpaper")
            onClicked: {
                // Open file picker for main wallpaper
                Quickshell.execDetached([FileUtils.trimFileProtocol(Directories.wallpaperSwitchScriptPath)]);
            }
        }

        RippleButtonWithIcon {
            visible: !(Config.options?.waffles?.background?.useMainWallpaper ?? true)
            Layout.fillWidth: true
            buttonRadius: Appearance.rounding.small
            materialIcon: "wallpaper"
            mainText: Translation.tr("Pick Waffle wallpaper")
            onClicked: {
                // Open file picker and set waffle-specific wallpaper
                waffleWallpaperPicker.running = true;
            }
        }

        Process {
            id: waffleWallpaperPicker
            command: ["kdialog", "--getopenfilename", FileUtils.trimFileProtocol(Directories.pictures), "Images (*.jpg *.jpeg *.png *.webp *.avif *.bmp)"]
            stdout: SplitParser {
                onRead: data => {
                    const path = data.trim();
                    if (path && path.length > 0) {
                        Config.options.waffles.background.wallpaperPath = path;
                    }
                }
            }
        }

        ConfigSwitch {
            buttonIcon: "fullscreen_exit"
            text: Translation.tr("Hide when fullscreen")
            checked: Config.options?.waffles?.background?.hideWhenFullscreen ?? true
            onCheckedChanged: Config.options.waffles.background.hideWhenFullscreen = checked
        }
    }

    ContentSection {
        visible: root.isWaffleActive
        icon: "auto_awesome"
        title: Translation.tr("Wallpaper Effects")

        ConfigSwitch {
            buttonIcon: "blur_on"
            text: Translation.tr("Enable blur")
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
            visible: Config.options?.waffles?.background?.effects?.enableBlur ?? false
            icon: "blur_circular"
            text: Translation.tr("Static blur (%)")
            from: 0; to: 100; stepSize: 5
            value: Config.options?.waffles?.background?.effects?.blurStatic ?? 0
            onValueChanged: Config.options.waffles.background.effects.blurStatic = value
            StyledToolTip { text: Translation.tr("Always-on blur percentage. Dynamic blur adds on top when windows are present.") }
        }

        ConfigSpinBox {
            icon: "brightness_5"
            text: Translation.tr("Dim (%)")
            from: 0; to: 100; stepSize: 5
            value: Config.options?.waffles?.background?.effects?.dim ?? 0
            onValueChanged: Config.options.waffles.background.effects.dim = value
        }

        ConfigSpinBox {
            icon: "brightness_auto"
            text: Translation.tr("Dynamic dim (%)")
            from: 0; to: 100; stepSize: 5
            value: Config.options?.waffles?.background?.effects?.dynamicDim ?? 0
            onValueChanged: Config.options.waffles.background.effects.dynamicDim = value
            StyledToolTip { text: Translation.tr("Extra dim when windows are present on current workspace") }
        }
    }

    ContentSection {
        visible: root.isWaffleActive
        icon: "layers"
        title: Translation.tr("Backdrop (Niri Overview)")

        StyledText {
            Layout.fillWidth: true
            text: Translation.tr("Backdrop is the wallpaper shown during Niri's native overview (Mod+Tab). It's always rendered in the background layer.")
            color: Appearance.colors.colSubtext
            font.pixelSize: Appearance.font.pixelSize.small
            wrapMode: Text.WordWrap
        }

        ConfigSwitch {
            buttonIcon: "texture"
            text: Translation.tr("Enable backdrop layer for overview")
            checked: Config.options?.waffles?.background?.backdrop?.enable ?? true
            onCheckedChanged: {
                Config.options.waffles.background.backdrop.enable = checked;
            }
        }

        ConfigSwitch {
            visible: Config.options?.waffles?.background?.backdrop?.enable ?? true
            buttonIcon: "visibility_off"
            text: Translation.tr("Hide main wallpaper (show only backdrop)")
            checked: Config.options?.waffles?.background?.backdrop?.hideWallpaper ?? false
            onCheckedChanged: {
                Config.options.waffles.background.backdrop.hideWallpaper = checked;
            }
            StyledToolTip { text: Translation.tr("Hides the desktop wallpaper, showing only the backdrop during Niri's overview") }
        }

        ConfigSwitch {
            visible: Config.options?.waffles?.background?.backdrop?.enable ?? true
            buttonIcon: "link"
            text: Translation.tr("Use main wallpaper")
            checked: Config.options?.waffles?.background?.backdrop?.useMainWallpaper ?? true
            onCheckedChanged: {
                Config.options.waffles.background.backdrop.useMainWallpaper = checked;
                if (checked) Config.options.waffles.background.backdrop.wallpaperPath = "";
            }
        }

        RippleButtonWithIcon {
            visible: (Config.options?.waffles?.background?.backdrop?.enable ?? true) && !(Config.options?.waffles?.background?.backdrop?.useMainWallpaper ?? true)
            Layout.fillWidth: true
            buttonRadius: Appearance.rounding.small
            materialIcon: "wallpaper"
            mainText: Translation.tr("Pick backdrop wallpaper")
            onClicked: {
                waffleBackdropPicker.running = true;
            }
        }

        Process {
            id: waffleBackdropPicker
            command: ["kdialog", "--getopenfilename", FileUtils.trimFileProtocol(Directories.pictures), "Images (*.jpg *.jpeg *.png *.webp *.avif *.bmp)"]
            stdout: SplitParser {
                onRead: data => {
                    const path = data.trim();
                    if (path && path.length > 0) {
                        Config.options.waffles.background.backdrop.wallpaperPath = path;
                    }
                }
            }
        }

        ConfigSpinBox {
            visible: Config.options?.waffles?.background?.backdrop?.enable ?? true
            icon: "blur_on"
            text: Translation.tr("Blur radius")
            from: 0; to: 100; stepSize: 5
            value: Config.options?.waffles?.background?.backdrop?.blurRadius ?? 32
            onValueChanged: Config.options.waffles.background.backdrop.blurRadius = value
        }

        ConfigSpinBox {
            visible: Config.options?.waffles?.background?.backdrop?.enable ?? true
            icon: "brightness_5"
            text: Translation.tr("Dim (%)")
            from: 0; to: 100; stepSize: 5
            value: Config.options?.waffles?.background?.backdrop?.dim ?? 35
            onValueChanged: Config.options.waffles.background.backdrop.dim = value
        }

        ConfigSpinBox {
            visible: Config.options?.waffles?.background?.backdrop?.enable ?? true
            icon: "contrast"
            text: Translation.tr("Saturation")
            from: 0; to: 200; stepSize: 10
            value: Math.round((Config.options?.waffles?.background?.backdrop?.saturation ?? 1.0) * 100)
            onValueChanged: Config.options.waffles.background.backdrop.saturation = value / 100.0
        }

        ConfigSpinBox {
            visible: Config.options?.waffles?.background?.backdrop?.enable ?? true
            icon: "exposure"
            text: Translation.tr("Contrast")
            from: 0; to: 200; stepSize: 10
            value: Math.round((Config.options?.waffles?.background?.backdrop?.contrast ?? 1.0) * 100)
            onValueChanged: Config.options.waffles.background.backdrop.contrast = value / 100.0
        }

        ConfigSwitch {
            visible: Config.options?.waffles?.background?.backdrop?.enable ?? true
            buttonIcon: "vignette"
            text: Translation.tr("Vignette")
            checked: Config.options?.waffles?.background?.backdrop?.vignetteEnabled ?? false
            onCheckedChanged: Config.options.waffles.background.backdrop.vignetteEnabled = checked
        }

        ConfigSpinBox {
            visible: (Config.options?.waffles?.background?.backdrop?.enable ?? true) && (Config.options?.waffles?.background?.backdrop?.vignetteEnabled ?? false)
            icon: "opacity"
            text: Translation.tr("Vignette intensity")
            from: 0; to: 100; stepSize: 5
            value: Math.round((Config.options?.waffles?.background?.backdrop?.vignetteIntensity ?? 0.5) * 100)
            onValueChanged: Config.options.waffles.background.backdrop.vignetteIntensity = value / 100.0
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
        }

        ConfigSwitch {
            buttonIcon: "palette"
            text: Translation.tr("Tint tray icons")
            checked: Config.options?.waffles?.bar?.tintTrayIcons ?? false
            onCheckedChanged: Config.options.waffles.bar.tintTrayIcons = checked
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
            onSelected: (newValue) => Config.options.waffles.startMenu.sizePreset = newValue
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
