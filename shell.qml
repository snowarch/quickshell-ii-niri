//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

// Adjust this to make the shell smaller or larger
//@ pragma Env QT_SCALE_FACTOR=1


import qs.modules.common
import qs.modules.background
import qs.modules.bar
import qs.modules.cheatsheet
import qs.modules.crosshair
import qs.modules.dock
import qs.modules.lock
import qs.modules.mediaControls
import qs.modules.notificationPopup
import qs.modules.onScreenDisplay
import qs.modules.onScreenKeyboard
import qs.modules.overview
import qs.modules.polkit
import qs.modules.regionSelector
import qs.modules.screenCorners
import qs.modules.sessionScreen
import qs.modules.sidebarLeft
import qs.modules.sidebarRight
import qs.modules.verticalBar
import qs.modules.wallpaperSelector
import qs.modules.altSwitcher
import qs.modules.ii.overlay
import "modules/clipboard" as ClipboardModule

import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Io
import qs.services

ShellRoot {
    // IPC handler for opening settings
    IpcHandler {
        target: "settings"
        function open(): void {
            console.log("[Shell] Opening settings from:", settingsProcess.command)
            settingsProcess.running = true
        }
    }
    
    Process {
        id: settingsProcess
        command: ["qs", "-n", "-p", Quickshell.shellPath("settings.qml")]
        onExited: (code, status) => console.log("[Shell] Settings process exited with code:", code)
    }
    // Enable/disable modules here. False = not loaded at all, so rest assured
    // no unnecessary stuff will take up memory if you decide to only use, say, the overview.
    property bool enableBar: true
    property bool enableBackground: true
    property bool enableCheatsheet: true
    property bool enableCrosshair: true
    property bool enableDock: true
    property bool enableLock: true
    property bool enableMediaControls: true
    property bool enableNotificationPopup: true
    property bool enablePolkit: true
    property bool enableOnScreenDisplay: true
    property bool enableOnScreenKeyboard: true
    property bool enableOverview: true
    property bool enableOverlay: true
    property bool enableRegionSelector: true
    property bool enableReloadPopup: true
    property bool enableScreenCorners: true
    property bool enableSessionScreen: true
    property bool enableSidebarLeft: true
    property bool enableSidebarRight: true
    property bool enableVerticalBar: true
    property bool enableWallpaperSelector: true

    // Force initialization of some singletons
    Component.onCompleted: {
        console.log("[Shell] Initializing singletons");
        Hyprsunset.load();
        FirstRunExperience.load();
        ConflictKiller.load();
        Cliphist.refresh();
        Wallpapers.load();
    }

    Connections {
        target: Config
        function onReadyChanged() {
            if (Config.ready) {
                console.log("[Shell] Config ready, applying theme");
                ThemeService.applyCurrentTheme();
            }
        }
    }

    LazyLoader { active: enableBar && Config.ready && !Config.options.bar.vertical; component: Bar {} }
    LazyLoader { active: Config.ready && Config.options.background.backdrop.enable; component: Backdrop {} }
    LazyLoader { active: enableBackground; component: Background {} }
    LazyLoader { active: enableCheatsheet; component: Cheatsheet {} }
    LazyLoader { active: enableCrosshair; component: Crosshair {} }
    LazyLoader { active: enableDock && Config.options.dock.enable; component: Dock {} }
    LazyLoader { active: enableLock; component: Lock {} }
    LazyLoader { active: enableMediaControls; component: MediaControls {} }
    LazyLoader { active: enableNotificationPopup; component: NotificationPopup {} }
    LazyLoader { active: enableOnScreenDisplay; component: OnScreenDisplay {} }
    LazyLoader { active: enableOnScreenKeyboard; component: OnScreenKeyboard {} }
    LazyLoader { active: enableOverview; component: Overview {} }
    LazyLoader { active: enableOverlay; component: Overlay {} }
    LazyLoader { active: enablePolkit; component: Polkit {} }
    LazyLoader { active: enableRegionSelector; component: RegionSelector {} }
    LazyLoader { active: enableReloadPopup; component: ToastManager {} }
    LazyLoader { active: enableScreenCorners; component: ScreenCorners {} }
    LazyLoader { active: enableSessionScreen; component: SessionScreen {} }
    LazyLoader { active: enableSidebarLeft; component: SidebarLeft {} }
    LazyLoader { active: enableSidebarRight; component: SidebarRight {} }
    LazyLoader { active: enableVerticalBar && Config.ready && Config.options.bar.vertical; component: VerticalBar {} }
    LazyLoader { active: enableWallpaperSelector; component: WallpaperSelector {} }
    LazyLoader { active: true; component: AltSwitcher {} }
    LazyLoader { active: true; component: ClipboardModule.ClipboardPanel {} }
}
