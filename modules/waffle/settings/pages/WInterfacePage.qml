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
    pageTitle: Translation.tr("Interface")
    pageIcon: "apps"
    pageDescription: Translation.tr("Notifications, OSD, and other UI elements")
    
    WSettingsCard {
        title: Translation.tr("Notifications")
        icon: "alert"
        
        WSettingsSpinBox {
            label: Translation.tr("Normal timeout")
            icon: "options"
            description: Translation.tr("How long normal notifications stay visible")
            suffix: "ms"
            from: 1000; to: 30000; stepSize: 1000
            value: Config.options?.notifications?.timeoutNormal ?? 7000
            onValueChanged: Config.setNestedValue("notifications.timeoutNormal", value)
        }
        
        WSettingsSpinBox {
            label: Translation.tr("Low priority timeout")
            icon: "options"
            suffix: "ms"
            from: 1000; to: 30000; stepSize: 1000
            value: Config.options?.notifications?.timeoutLow ?? 5000
            onValueChanged: Config.setNestedValue("notifications.timeoutLow", value)
        }
        
        WSettingsSpinBox {
            label: Translation.tr("Critical timeout")
            icon: "options"
            description: Translation.tr("0 = never auto-dismiss")
            suffix: "ms"
            from: 0; to: 30000; stepSize: 1000
            value: Config.options?.notifications?.timeoutCritical ?? 0
            onValueChanged: Config.setNestedValue("notifications.timeoutCritical", value)
        }
        
        WSettingsDropdown {
            label: Translation.tr("Popup position")
            icon: "options"
            currentValue: Config.options?.notifications?.position ?? "topRight"
            options: [
                { value: "topLeft", displayName: Translation.tr("Top Left") },
                { value: "topRight", displayName: Translation.tr("Top Right") },
                { value: "bottomLeft", displayName: Translation.tr("Bottom Left") },
                { value: "bottomRight", displayName: Translation.tr("Bottom Right") }
            ]
            onSelected: newValue => Config.setNestedValue("notifications.position", newValue)
        }
        
        WSettingsSwitch {
            label: Translation.tr("Do Not Disturb")
            icon: "alert-off"
            description: Translation.tr("Silence all notifications")
            checked: Config.options?.notifications?.silent ?? false
            onCheckedChanged: Config.setNestedValue("notifications.silent", checked)
        }
    }
    
    WSettingsCard {
        title: Translation.tr("On-Screen Display")
        icon: "speaker-2-filled"
        
        WSettingsSpinBox {
            label: Translation.tr("OSD timeout")
            icon: "options"
            description: Translation.tr("How long volume/brightness OSD stays visible")
            suffix: "ms"
            from: 500; to: 5000; stepSize: 250
            value: Config.options?.osd?.timeout ?? 1000
            onValueChanged: Config.setNestedValue("osd.timeout", value)
        }
    }
    
    WSettingsCard {
        title: Translation.tr("Overview")
        icon: "apps"
        
        WSettingsSpinBox {
            label: Translation.tr("Scale")
            icon: "options"
            description: Translation.tr("Window preview size in overview")
            suffix: "%"
            from: 50; to: 150; stepSize: 10
            value: Math.round((Config.options?.overview?.scale ?? 1.0) * 100)
            onValueChanged: Config.setNestedValue("overview.scale", value / 100)
        }
        
        WSettingsSpinBox {
            label: Translation.tr("Rows")
            icon: "options"
            from: 1; to: 5; stepSize: 1
            value: Config.options?.overview?.rows ?? 2
            onValueChanged: Config.setNestedValue("overview.rows", value)
        }
        
        WSettingsSpinBox {
            label: Translation.tr("Columns")
            icon: "options"
            from: 2; to: 8; stepSize: 1
            value: Config.options?.overview?.columns ?? 5
            onValueChanged: Config.setNestedValue("overview.columns", value)
        }
    }
    
    WSettingsCard {
        title: Translation.tr("Lock Screen")
        icon: "lock-closed"
        
        WSettingsSwitch {
            label: Translation.tr("Enable blur")
            icon: "options"
            description: Translation.tr("Blur background on lock screen")
            checked: Config.options?.lock?.blur?.enable ?? true
            onCheckedChanged: Config.setNestedValue("lock.blur.enable", checked)
        }
        
        WSettingsSpinBox {
            visible: Config.options?.lock?.blur?.enable ?? true
            label: Translation.tr("Blur radius")
            icon: "options"
            from: 0; to: 200; stepSize: 10
            value: Config.options?.lock?.blur?.radius ?? 100
            onValueChanged: Config.setNestedValue("lock.blur.radius", value)
        }
        
        WSettingsSwitch {
            label: Translation.tr("Center clock")
            icon: "options"
            checked: Config.options?.lock?.centerClock ?? true
            onCheckedChanged: Config.setNestedValue("lock.centerClock", checked)
        }
        
        WSettingsSwitch {
            label: Translation.tr("Show 'Locked' text")
            icon: "options"
            checked: Config.options?.lock?.showLockedText ?? true
            onCheckedChanged: Config.setNestedValue("lock.showLockedText", checked)
        }
    }
    
    WSettingsCard {
        title: Translation.tr("Screen Corners")
        icon: "desktop"
        
        WSettingsDropdown {
            label: Translation.tr("Fake rounded corners")
            icon: "desktop"
            description: Translation.tr("Add rounded corners to flat screens")
            currentValue: Config.options?.appearance?.fakeScreenRounding ?? 0
            options: [
                { value: 0, displayName: Translation.tr("None") },
                { value: 1, displayName: Translation.tr("Always") },
                { value: 2, displayName: Translation.tr("When not fullscreen") }
            ]
            onSelected: newValue => Config.setNestedValue("appearance.fakeScreenRounding", newValue)
        }
    }
}
