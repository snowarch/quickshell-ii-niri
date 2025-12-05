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
    pageTitle: Translation.tr("Modules")
    pageIcon: "apps"
    pageDescription: Translation.tr("Enable or disable shell modules")
    
    WSettingsCard {
        title: Translation.tr("Panel Style")
        icon: "desktop"
        
        WText {
            Layout.fillWidth: true
            text: Translation.tr("Choose between Material Design (ii) and Windows 11 (Waffle) styles.")
            font.pixelSize: Looks.font.pixelSize.normal
            color: Looks.colors.subfg
            wrapMode: Text.WordWrap
        }
        
        WSettingsDropdown {
            label: Translation.tr("Panel family")
            icon: "desktop"
            currentValue: Config.options?.panelFamily ?? "waffle"
            options: [
                { value: "ii", displayName: Translation.tr("Material (ii)") },
                { value: "waffle", displayName: Translation.tr("Windows 11 (Waffle)") }
            ]
            onSelected: newValue => {
                Config.setNestedValue("panelFamily", newValue)
                Quickshell.execDetached(["qs", "-c", "ii", "ipc", "call", "panelFamily", "set", newValue])
            }
        }
    }
    
    WSettingsCard {
        title: Translation.tr("Core Modules")
        icon: "apps"
        
        WSettingsSwitch {
            label: Translation.tr("Background")
            icon: "image"
            description: Translation.tr("Wallpaper and backdrop layer")
            checked: (Config.options?.enabledPanels ?? []).includes("iiBackground") || (Config.options?.enabledPanels ?? []).includes("wBackground")
            onCheckedChanged: {
                let panels = Config.options?.enabledPanels ?? []
                const bgPanels = ["iiBackground", "wBackground"]
                if (checked) {
                    if (!panels.includes("iiBackground")) panels.push("iiBackground")
                    if (!panels.includes("wBackground")) panels.push("wBackground")
                } else {
                    panels = panels.filter(p => !bgPanels.includes(p))
                }
                Config.setNestedValue("enabledPanels", panels)
            }
        }
        
        WSettingsSwitch {
            label: Translation.tr("Overview")
            icon: "apps"
            description: Translation.tr("Window overview and app launcher")
            checked: (Config.options?.enabledPanels ?? []).includes("iiOverview")
            onCheckedChanged: {
                let panels = Config.options?.enabledPanels ?? []
                if (checked) {
                    if (!panels.includes("iiOverview")) panels.push("iiOverview")
                } else {
                    panels = panels.filter(p => p !== "iiOverview")
                }
                Config.setNestedValue("enabledPanels", panels)
            }
        }
        
        WSettingsSwitch {
            label: Translation.tr("Clipboard")
            icon: "copy"
            description: Translation.tr("Clipboard history manager")
            checked: (Config.options?.enabledPanels ?? []).includes("iiClipboard")
            onCheckedChanged: {
                let panels = Config.options?.enabledPanels ?? []
                if (checked) {
                    if (!panels.includes("iiClipboard")) panels.push("iiClipboard")
                } else {
                    panels = panels.filter(p => p !== "iiClipboard")
                }
                Config.setNestedValue("enabledPanels", panels)
            }
        }
        
        WSettingsSwitch {
            label: Translation.tr("Lock Screen")
            icon: "lock-closed"
            checked: (Config.options?.enabledPanels ?? []).includes("iiLock")
            onCheckedChanged: {
                let panels = Config.options?.enabledPanels ?? []
                if (checked) {
                    if (!panels.includes("iiLock")) panels.push("iiLock")
                } else {
                    panels = panels.filter(p => p !== "iiLock")
                }
                Config.setNestedValue("enabledPanels", panels)
            }
        }
    }
    
    WSettingsCard {
        title: Translation.tr("Waffle Modules")
        icon: "desktop"
        visible: Config.options?.panelFamily === "waffle"
        
        WSettingsSwitch {
            label: Translation.tr("Start Menu")
            icon: "apps"
            checked: (Config.options?.enabledPanels ?? []).includes("wStartMenu")
            onCheckedChanged: {
                let panels = Config.options?.enabledPanels ?? []
                if (checked) {
                    if (!panels.includes("wStartMenu")) panels.push("wStartMenu")
                } else {
                    panels = panels.filter(p => p !== "wStartMenu")
                }
                Config.setNestedValue("enabledPanels", panels)
            }
        }
        
        WSettingsSwitch {
            label: Translation.tr("Action Center")
            icon: "settings"
            checked: (Config.options?.enabledPanels ?? []).includes("wActionCenter")
            onCheckedChanged: {
                let panels = Config.options?.enabledPanels ?? []
                if (checked) {
                    if (!panels.includes("wActionCenter")) panels.push("wActionCenter")
                } else {
                    panels = panels.filter(p => p !== "wActionCenter")
                }
                Config.setNestedValue("enabledPanels", panels)
            }
        }
        
        WSettingsSwitch {
            label: Translation.tr("Notification Center")
            icon: "alert"
            checked: (Config.options?.enabledPanels ?? []).includes("wNotificationCenter")
            onCheckedChanged: {
                let panels = Config.options?.enabledPanels ?? []
                if (checked) {
                    if (!panels.includes("wNotificationCenter")) panels.push("wNotificationCenter")
                } else {
                    panels = panels.filter(p => p !== "wNotificationCenter")
                }
                Config.setNestedValue("enabledPanels", panels)
            }
        }
        
        WSettingsSwitch {
            label: Translation.tr("Widgets Panel")
            icon: "apps"
            checked: (Config.options?.enabledPanels ?? []).includes("wWidgets")
            onCheckedChanged: {
                let panels = Config.options?.enabledPanels ?? []
                if (checked) {
                    if (!panels.includes("wWidgets")) panels.push("wWidgets")
                } else {
                    panels = panels.filter(p => p !== "wWidgets")
                }
                Config.setNestedValue("enabledPanels", panels)
            }
        }
    }
    
    WSettingsCard {
        title: Translation.tr("Material Modules")
        icon: "options"
        visible: Config.options?.panelFamily !== "waffle"
        
        WSettingsSwitch {
            label: Translation.tr("Left Sidebar")
            icon: "options"
            description: Translation.tr("AI chat, wallpapers, translator")
            checked: (Config.options?.enabledPanels ?? []).includes("iiSidebarLeft")
            onCheckedChanged: {
                let panels = Config.options?.enabledPanels ?? []
                if (checked) {
                    if (!panels.includes("iiSidebarLeft")) panels.push("iiSidebarLeft")
                } else {
                    panels = panels.filter(p => p !== "iiSidebarLeft")
                }
                Config.setNestedValue("enabledPanels", panels)
            }
        }
        
        WSettingsSwitch {
            label: Translation.tr("Right Sidebar")
            icon: "options"
            description: Translation.tr("Quick settings, calendar, notifications")
            checked: (Config.options?.enabledPanels ?? []).includes("iiSidebarRight")
            onCheckedChanged: {
                let panels = Config.options?.enabledPanels ?? []
                if (checked) {
                    if (!panels.includes("iiSidebarRight")) panels.push("iiSidebarRight")
                } else {
                    panels = panels.filter(p => p !== "iiSidebarRight")
                }
                Config.setNestedValue("enabledPanels", panels)
            }
        }
    }
}
