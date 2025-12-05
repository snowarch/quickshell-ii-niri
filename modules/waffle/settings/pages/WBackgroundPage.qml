pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.waffle.looks
import qs.modules.waffle.settings

WSettingsPage {
    id: root
    pageTitle: Translation.tr("Background")
    pageIcon: "image"
    pageDescription: Translation.tr("Wallpaper effects and backdrop settings")
    
    WSettingsCard {
        title: Translation.tr("Wallpaper Effects")
        icon: "image"
        
        WSettingsSwitch {
            label: Translation.tr("Enable blur")
            icon: "options"
            description: Translation.tr("Blur wallpaper when windows are open")
            checked: Config.options?.background?.effects?.enableBlur ?? false
            onCheckedChanged: Config.setNestedValue("background.effects.enableBlur", checked)
        }
        
        WSettingsSpinBox {
            visible: Config.options?.background?.effects?.enableBlur ?? false
            label: Translation.tr("Blur radius")
            icon: "options"
            from: 0; to: 100; stepSize: 5
            value: Config.options?.background?.effects?.blurRadius ?? 32
            onValueChanged: Config.setNestedValue("background.effects.blurRadius", value)
        }
        
        WSettingsSpinBox {
            label: Translation.tr("Dim overlay")
            icon: "options"
            description: Translation.tr("Darken the wallpaper")
            suffix: "%"
            from: 0; to: 100; stepSize: 5
            value: Config.options?.background?.effects?.dim ?? 0
            onValueChanged: Config.setNestedValue("background.effects.dim", value)
        }
        
        WSettingsSpinBox {
            label: Translation.tr("Extra dim with windows")
            icon: "options"
            description: Translation.tr("Additional dim when windows are present")
            suffix: "%"
            from: 0; to: 100; stepSize: 5
            value: Config.options?.background?.effects?.dynamicDim ?? 0
            onValueChanged: Config.setNestedValue("background.effects.dynamicDim", value)
        }
    }
    
    WSettingsCard {
        title: Translation.tr("Backdrop (Overview)")
        icon: "desktop"
        
        WSettingsSwitch {
            label: Translation.tr("Enable backdrop")
            icon: "desktop"
            description: Translation.tr("Show backdrop layer for overview")
            checked: Config.options?.background?.backdrop?.enable ?? true
            onCheckedChanged: Config.setNestedValue("background.backdrop.enable", checked)
        }
        
        WSettingsSwitch {
            visible: Config.options?.background?.backdrop?.enable ?? true
            label: Translation.tr("Hide main wallpaper")
            icon: "options"
            description: Translation.tr("Show only backdrop, hide main wallpaper")
            checked: Config.options?.background?.backdrop?.hideWallpaper ?? false
            onCheckedChanged: Config.setNestedValue("background.backdrop.hideWallpaper", checked)
        }
        
        WSettingsSwitch {
            visible: Config.options?.background?.backdrop?.enable ?? true
            label: Translation.tr("Use main wallpaper")
            icon: "image"
            description: Translation.tr("Use the same wallpaper for backdrop")
            checked: Config.options?.background?.backdrop?.useMainWallpaper ?? true
            onCheckedChanged: Config.setNestedValue("background.backdrop.useMainWallpaper", checked)
        }
        
        WSettingsSpinBox {
            visible: Config.options?.background?.backdrop?.enable ?? true
            label: Translation.tr("Backdrop blur")
            icon: "options"
            from: 0; to: 100; stepSize: 5
            value: Config.options?.background?.backdrop?.blurRadius ?? 64
            onValueChanged: Config.setNestedValue("background.backdrop.blurRadius", value)
        }
        
        WSettingsSpinBox {
            visible: Config.options?.background?.backdrop?.enable ?? true
            label: Translation.tr("Backdrop dim")
            icon: "options"
            suffix: "%"
            from: 0; to: 100; stepSize: 5
            value: Config.options?.background?.backdrop?.dim ?? 20
            onValueChanged: Config.setNestedValue("background.backdrop.dim", value)
        }
    }
    
    WSettingsCard {
        title: Translation.tr("Wallpaper Rounding")
        icon: "options"
        
        WSettingsDropdown {
            label: Translation.tr("Fill radius")
            icon: "options"
            description: Translation.tr("Round corners on wallpaper")
            currentValue: Config.options?.background?.fillRadius ?? 0
            options: [
                { value: 0, displayName: Translation.tr("None") },
                { value: 12, displayName: Translation.tr("Small (12px)") },
                { value: 24, displayName: Translation.tr("Medium (24px)") },
                { value: 48, displayName: Translation.tr("Large (48px)") }
            ]
            onSelected: newValue => Config.setNestedValue("background.fillRadius", newValue)
        }
    }
}
