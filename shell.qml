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
    // Enable/disable modules here. Reads from Config, falls back to true/false defaults.
    // False = not loaded at all, so rest assured no unnecessary stuff will take up memory.
    // Force Idle singleton instantiation (lazy singletons need a reference)
    property var _idleService: Idle
    property var _gameModeService: GameMode
    
    property bool enableBar: Config.options?.modules?.bar ?? true
    property bool enableBackground: Config.options?.modules?.background ?? true
    property bool enableCheatsheet: Config.options?.modules?.cheatsheet ?? true
    property bool enableCrosshair: Config.options?.modules?.crosshair ?? false
    property bool enableDock: Config.options?.modules?.dock ?? true
    property bool enableLock: Config.options?.modules?.lock ?? true
    property bool enableMediaControls: Config.options?.modules?.mediaControls ?? true
    property bool enableNotificationPopup: Config.options?.modules?.notificationPopup ?? true
    property bool enablePolkit: Config.options?.modules?.polkit ?? true
    property bool enableOnScreenDisplay: Config.options?.modules?.onScreenDisplay ?? true
    property bool enableOnScreenKeyboard: Config.options?.modules?.onScreenKeyboard ?? true
    property bool enableOverview: Config.options?.modules?.overview ?? true
    property bool enableOverlay: Config.options?.modules?.overlay ?? true
    property bool enableRegionSelector: Config.options?.modules?.regionSelector ?? true
    property bool enableReloadPopup: Config.options?.modules?.reloadPopup ?? true
    property bool enableScreenCorners: Config.options?.modules?.screenCorners ?? true
    property bool enableSessionScreen: Config.options?.modules?.sessionScreen ?? true
    property bool enableSidebarLeft: Config.options?.modules?.sidebarLeft ?? true
    property bool enableSidebarRight: Config.options?.modules?.sidebarRight ?? true
    property bool enableVerticalBar: Config.options?.modules?.verticalBar ?? true
    property bool enableWallpaperSelector: Config.options?.modules?.wallpaperSelector ?? true

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

    LazyLoader { active: Config.ready && enableBar && !Config.options.bar.vertical; component: Bar {} }
    LazyLoader { active: Config.ready && Config.options.background.backdrop.enable; component: Backdrop {} }
    LazyLoader { active: Config.ready && enableBackground; component: Background {} }
    LazyLoader { active: Config.ready && enableCheatsheet; component: Cheatsheet {} }
    LazyLoader { active: Config.ready && enableCrosshair; component: Crosshair {} }
    LazyLoader { active: Config.ready && enableDock && Config.options.dock.enable; component: Dock {} }
    LazyLoader { active: Config.ready && enableLock; component: Lock {} }
    LazyLoader { active: Config.ready && enableMediaControls; component: MediaControls {} }
    LazyLoader { active: Config.ready && enableNotificationPopup; component: NotificationPopup {} }
    LazyLoader { active: Config.ready && enableOnScreenDisplay; component: OnScreenDisplay {} }
    LazyLoader { active: Config.ready && enableOnScreenKeyboard; component: OnScreenKeyboard {} }
    LazyLoader { active: Config.ready && enableOverview; component: Overview {} }
    LazyLoader { active: Config.ready && enableOverlay; component: Overlay {} }
    LazyLoader { active: Config.ready && enablePolkit; component: Polkit {} }
    LazyLoader { active: Config.ready && enableRegionSelector; component: RegionSelector {} }
    LazyLoader { active: Config.ready && enableReloadPopup; component: ToastManager {} }
    LazyLoader { active: Config.ready && enableScreenCorners; component: ScreenCorners {} }
    LazyLoader { active: Config.ready && enableSessionScreen; component: SessionScreen {} }
    LazyLoader { active: Config.ready && enableSidebarLeft; component: SidebarLeft {} }
    LazyLoader { active: Config.ready && enableSidebarRight; component: SidebarRight {} }
    LazyLoader { active: Config.ready && enableVerticalBar && Config.options.bar.vertical; component: VerticalBar {} }
    LazyLoader { active: Config.ready && enableWallpaperSelector; component: WallpaperSelector {} }
    LazyLoader { active: Config.ready && (Config.options?.modules?.altSwitcher ?? true); component: AltSwitcher {} }
    LazyLoader { active: Config.ready && (Config.options?.modules?.clipboard ?? true); component: ClipboardModule.ClipboardPanel {} }
}
