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
    property real iconSize: 35
    property real countDotWidth: 10
    property real countDotHeight: 4
    property bool appIsActive: appToplevel.toplevels.find(t => (t.activated == true)) !== undefined

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
                appListRoot.lastHoveredButton = root
                appListRoot.buttonHovered = true
                lastFocused = appToplevel.toplevels.length - 1
            }
            onExited: {
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
        appToplevel.toplevels[lastFocused].activate()
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
                active: !root.isSeparator && (!Config.options.dock.minimizeUnfocused || root.appIsActive || mouseArea.containsMouse)
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

            RowLayout {
                visible: !Config.options.dock.minimizeUnfocused || root.appIsActive || mouseArea.containsMouse
                spacing: 3
                anchors {
                    top: iconImageLoader.bottom
                    topMargin: 2
                    horizontalCenter: parent.horizontalCenter
                }
                Repeater {
                    model: Math.min(appToplevel.toplevels.length, 3)
                    delegate: Rectangle {
                        required property int index
                        radius: Appearance.rounding.full
                        implicitWidth: (appToplevel.toplevels.length <= 3) ? 
                            root.countDotWidth : root.countDotHeight // Circles when too many
                        implicitHeight: root.countDotHeight
                        color: appIsActive ? Appearance.colors.colPrimary : ColorUtils.transparentize(Appearance.colors.colOnLayer0, 0.4)
                    }
                }
            }
            // Dot for minimized/unfocused state
            Loader {
                active: Config.options.dock.minimizeUnfocused && !root.appIsActive && !mouseArea.containsMouse && !root.isSeparator
                anchors.centerIn: parent
                sourceComponent: Rectangle {
                    width: 6
                    height: 6
                    radius: 3
                    color: Appearance.colors.colOnLayer0
                    opacity: 0.6
                }
            }
        }
    }
}
