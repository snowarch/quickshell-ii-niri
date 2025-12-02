pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.modules.waffle.looks
import qs.modules.waffle.bar

BarIconButton {
    id: root

    required property SystemTrayItem item
    property alias menuOpen: menu.visible
    readonly property bool barAtBottom: Config.options.waffles.bar.bottom
    readonly property bool tintIcons: Config.options.waffles.bar.tintTrayIcons

    iconSource: tintIcons ? "" : item.icon
    iconScale: 0
    Component.onCompleted: {
        root.iconScale = 1
    }
    Behavior on iconScale {
        animation: Looks.transition.enter.createObject(this)
    }

    onClicked: {
        // Try to focus existing window matching this tray item (Niri only)
        if (CompositorService.isNiri) {
            const itemId = (item.id ?? "").toLowerCase();
            const title = (item.title ?? "").toLowerCase();
            
            // Known app_id mappings
            const knownMappings = {
                "spotify": ["spotify"],
                "discord": ["discord", "vesktop", "armcord"],
                "steam": ["steam"],
                "slack": ["slack"],
                "telegram": ["telegram", "org.telegram", "kotatogram"],
                "signal": ["signal"],
                "chrome": ["chrome", "chromium", "google-chrome"],
                "firefox": ["firefox", "librewolf"],
            };
            
            let searchPatterns = [itemId, title].filter(s => s.length >= 3);
            for (const [key, patterns] of Object.entries(knownMappings)) {
                if (itemId.includes(key) || title.includes(key)) {
                    searchPatterns = searchPatterns.concat(patterns);
                }
            }
            
            const window = NiriService.windows.find(w => {
                const appId = (w.app_id ?? "").toLowerCase();
                const windowTitle = (w.title ?? "").toLowerCase();
                for (const pattern of searchPatterns) {
                    if (appId === pattern || appId.includes(pattern) || windowTitle.includes(pattern))
                        return true;
                }
                return false;
            });
            
            if (window) {
                NiriService.focusWindow(window.id);
                return;
            }
        }
        
        // No window found - activate tray item (opens app or shows its menu)
        item.activate();
    }

    altAction: () => {
        if (item.hasMenu) menu.active = true
    }

    // Tinted icon (same style as WAppIcon)
    Item {
        visible: root.tintIcons
        anchors.centerIn: parent
        width: 16
        height: 16

        IconImage {
            id: trayIcon
            anchors.fill: parent
            source: {
                // If item.icon fails, try to get icon from GTK theme by app name
                const itemIcon = root.item.icon;
                if (itemIcon && itemIcon.length > 0) return itemIcon;
                
                // Fallback: try common icon names based on item id/title
                const itemId = (root.item.id ?? "").toLowerCase();
                const title = (root.item.title ?? "").toLowerCase();
                
                if (itemId.includes("spotify") || title.includes("spotify")) 
                    return Quickshell.iconPath("spotify", "");
                if (itemId.includes("discord") || title.includes("discord")) 
                    return Quickshell.iconPath("discord", "");
                    
                return "";
            }
            visible: status === Image.Ready
        }
        
        // Fallback icon when main icon fails
        IconImage {
            anchors.fill: parent
            visible: trayIcon.status !== Image.Ready
            source: {
                const itemId = (root.item.id ?? "").toLowerCase();
                const title = (root.item.title ?? "").toLowerCase();
                
                if (itemId.includes("spotify") || title.includes("spotify")) 
                    return Quickshell.iconPath("spotify", "");
                if (itemId.includes("discord") || title.includes("discord")) 
                    return Quickshell.iconPath("discord", "");
                    
                return Quickshell.iconPath("application-x-executable", "");
            }
        }

        Loader {
            active: root.tintIcons
            anchors.fill: trayIcon
            sourceComponent: Item {
                Desaturate {
                    id: desaturatedIcon
                    visible: false
                    anchors.fill: parent
                    source: trayIcon
                    desaturation: 0.8
                }
                ColorOverlay {
                    anchors.fill: desaturatedIcon
                    source: desaturatedIcon
                    color: ColorUtils.transparentize(Looks.colors.accent, 0.9)
                }
            }
        }
    }

    WaffleTrayMenu {
        id: menu
        trayItemMenuHandle: root.item.menu
    }

    BarToolTip {
        extraVisibleCondition: root.shouldShowTooltip && !root.Drag.active
        text: TrayService.getTooltipForItem(root.item)
    }
}
