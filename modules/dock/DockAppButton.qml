import qs.services
import qs.modules.common
import qs.modules.common.functions
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

DockButton {
    id: root
    property var appToplevel
    property var appListRoot
    property int lastFocused: -1
    property real iconSize: Config.options.dock.iconSize ?? 35
    property real countDotWidth: 10
    property real countDotHeight: 4
    property bool appIsActive: appToplevel.toplevels.find(t => (t.activated == true)) !== undefined
    property bool hasWindows: appToplevel.toplevels.length > 0
    property bool buttonHovered: false
    
    // Determine focused window index for smart indicator (Niri only)
    // Returns the index (0-based) of the focused window sorted by column position
    property int focusedWindowIndex: {
        if (!root.appIsActive || appToplevel.toplevels.length <= 1)
            return 0;
        
        // Find the focused toplevel
        const focusedToplevel = appToplevel.toplevels.find(t => t.activated === true);
        if (!focusedToplevel)
            return 0;
        
        // For Niri: use column position to determine order
        if (CompositorService.isNiri && focusedToplevel.niriWindowId) {
            const niriWindows = NiriService.windows;
            
            // Build array of {toplevelIdx, column} for sorting
            const windowPositions = [];
            for (let i = 0; i < appToplevel.toplevels.length; i++) {
                const tl = appToplevel.toplevels[i];
                let col = 999999;
                if (tl.niriWindowId) {
                    const niriWin = niriWindows.find(w => w.id === tl.niriWindowId);
                    if (niriWin && niriWin.layout && niriWin.layout.pos_in_scrolling_layout) {
                        col = niriWin.layout.pos_in_scrolling_layout[0];
                    }
                }
                windowPositions.push({ idx: i, col: col, activated: tl.activated });
            }
            
            // Sort by column
            windowPositions.sort((a, b) => a.col - b.col);
            
            // Find the focused one's position in sorted array
            for (let i = 0; i < windowPositions.length; i++) {
                if (windowPositions[i].activated) return i;
            }
        }
        
        // Fallback: find by activated flag in original order
        for (let i = 0; i < appToplevel.toplevels.length; i++) {
            if (appToplevel.toplevels[i].activated) return i;
        }
        return 0;
    }
    
    // Subtle highlight for active app
    scale: appIsActive ? 1.05 : 1.0
    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

    property bool isSeparator: appToplevel.appId === "SEPARATOR"
    // Use originalAppId (preserves case) for desktop entry lookup, fallback to appId for backwards compat
    property var desktopEntry: DesktopEntries.heuristicLookup(appToplevel.originalAppId ?? appToplevel.appId)
    enabled: !isSeparator
    implicitWidth: isSeparator ? 1 : implicitHeight - topInset - bottomInset

    Loader {
        active: isSeparator
        anchors {
            fill: parent
            topMargin: dockVisualBackground.margin + dockRow.padding + Appearance.rounding.normal
            bottomMargin: dockVisualBackground.margin + dockRow.padding + Appearance.rounding.normal
        }
        sourceComponent: DockSeparator {}
    }

    Loader {
        anchors.fill: parent
        active: appToplevel.toplevels.length > 0
        sourceComponent: MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onEntered: {
                root.buttonHovered = true
                appListRoot.lastHoveredButton = root
                appListRoot.buttonHovered = true
                lastFocused = appToplevel.toplevels.length - 1
            }
            onExited: {
                root.buttonHovered = false
                if (appListRoot.lastHoveredButton === root) {
                    appListRoot.buttonHovered = false
                }
            }
        }
    }

    function launchFromDesktopEntry() {
        // Intentar siempre vía gtk-launch y, si falla, ejecutar appId directamente
        var id = appToplevel.originalAppId ?? appToplevel.appId;
        // Caso especial: YouTube Music (pear)
        if (id === "com.github.th_ch.youtube_music") {
            id = "pear-desktop";
        }
        // Caso especial: Spotify launcher
        if (id === "spotify" || id === "spotify-launcher") {
            id = "spotify-launcher";
        }
        if (id && id !== "" && id !== "SEPARATOR") {
            const cmd = "gtk-launch \"" + id + "\" || \"" + id + "\" &";
            Quickshell.execDetached(["bash", "-lc", cmd]);
            return true;
        }
        return false;
    }

    onClicked: {
        // Sin ventanas abiertas: lanzar nueva instancia desde desktop entry o fallbacks
        if (appToplevel.toplevels.length === 0) {
            launchFromDesktopEntry();
            return;
        }
        // Con ventanas: rotar foco entre instancias abiertas
        lastFocused = (lastFocused + 1) % appToplevel.toplevels.length
        const toplevel = appToplevel.toplevels[lastFocused]
        if (CompositorService.isNiri && toplevel?.niriWindowId) {
            NiriService.focusWindow(toplevel.niriWindowId)
        } else {
            toplevel?.activate()
        }
    }

    middleClickAction: () => {
        launchFromDesktopEntry();
    }

    altAction: () => {
        // Use originalAppId to ensure proper matching with config (case-sensitive comparison)
        const appId = appToplevel.originalAppId ?? appToplevel.appId;
        if (Config.options.dock.pinnedApps.indexOf(appId) !== -1) {
            Config.options.dock.pinnedApps = Config.options.dock.pinnedApps.filter(id => id !== appId)
        } else {
            Config.options.dock.pinnedApps = Config.options.dock.pinnedApps.concat([appId])
        }
    }

    contentItem: Loader {
        active: !isSeparator
        sourceComponent: Item {
            anchors.centerIn: parent

            Loader {
                id: iconImageLoader
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                active: !root.isSeparator
                sourceComponent: IconImage {
                    // Use desktop entry icon if available, fallback to guessed icon
                    source: {
                        const appId = appToplevel.originalAppId ?? appToplevel.appId;
                        let iconName;

                        // Caso especial: Spotify → usar icono de tema "spotify"
                        if (appId === "Spotify" || appId === "spotify" || appId === "spotify-launcher") {
                            iconName = "spotify";
                        } else {
                            iconName = root.desktopEntry?.icon || AppSearch.guessIcon(appId);
                        }

                        return Quickshell.iconPath(iconName, "image-missing");
                    }
                    implicitSize: root.iconSize
                }
            }

            Loader {
                active: Config.options.dock.monochromeIcons
                anchors.fill: iconImageLoader
                sourceComponent: Item {
                    Desaturate {
                        id: desaturatedIcon
                        visible: false // There's already color overlay
                        anchors.fill: parent
                        source: iconImageLoader
                        desaturation: 0.8
                    }
                    ColorOverlay {
                        anchors.fill: desaturatedIcon
                        source: desaturatedIcon
                        color: ColorUtils.transparentize(Appearance.colors.colPrimary, 0.9)
                    }
                }
            }

            // Smart indicator: shows window count and which is focused
            Loader {
                active: root.hasWindows && !root.isSeparator
                anchors {
                    top: iconImageLoader.bottom
                    topMargin: 2
                    horizontalCenter: parent.horizontalCenter
                }
                
                // Config options
                property bool smartIndicator: Config.options.dock.smartIndicator !== false
                property bool showAllDots: Config.options.dock.showAllWindowDots !== false
                property int maxDots: Config.options.dock.maxIndicatorDots ?? 5
                
                sourceComponent: Row {
                    spacing: 3
                    
                    Repeater {
                        // Show dots for all windows if enabled, otherwise just for active apps
                        model: {
                            const showAll = Config.options.dock.showAllWindowDots !== false;
                            const max = Config.options.dock.maxIndicatorDots ?? 5;
                            if (root.appIsActive || showAll) {
                                return Math.min(appToplevel.toplevels.length, max);
                            }
                            return 0;
                        }
                        
                        delegate: Rectangle {
                            required property int index
                            
                            property bool smartMode: Config.options.dock.smartIndicator !== false
                            
                            // Determine if this indicator corresponds to the focused window
                            property bool isFocusedWindow: {
                                if (!root.appIsActive) return false;
                                if (!smartMode) return true; // All indicators same when smart mode off
                                if (appToplevel.toplevels.length <= 1) return true;
                                return index === root.focusedWindowIndex;
                            }
                            
                            radius: Appearance.rounding.full
                            implicitWidth: isFocusedWindow ? root.countDotWidth : root.countDotHeight
                            implicitHeight: root.countDotHeight
                            color: isFocusedWindow 
                                   ? Appearance.colors.colPrimary 
                                   : ColorUtils.transparentize(Appearance.colors.colOnLayer0, 0.5)
                            
                            Behavior on implicitWidth { 
                                NumberAnimation { duration: 120; easing.type: Easing.OutQuad } 
                            }
                        }
                    }
                    
                    // Fallback: single dot when showAllDots is off and app is inactive
                    Rectangle {
                        visible: !root.appIsActive && root.hasWindows && Config.options.dock.showAllWindowDots === false
                        width: 5
                        height: 5
                        radius: 2.5
                        color: ColorUtils.transparentize(Appearance.colors.colOnLayer0, 0.5)
                    }
                }
            }
        }
    }
}
