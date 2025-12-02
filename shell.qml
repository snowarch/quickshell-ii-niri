//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000
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

import qs.modules.waffle.actionCenter
import qs.modules.waffle.background as WaffleBackgroundModule
import qs.modules.waffle.bar as WaffleBarModule
import qs.modules.waffle.notificationCenter
import qs.modules.waffle.onScreenDisplay as WaffleOSDModule
import qs.modules.waffle.startMenu
import qs.modules.waffle.widgets
import qs.modules.waffle.backdrop as WaffleBackdropModule

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

ShellRoot {
    id: root

    // Force Idle/GameMode singleton instantiation
    property var _idleService: Idle
    property var _gameModeService: GameMode

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
                // Only reset enabledPanels if it's empty or undefined (first run / corrupted config)
                if (!Config.options.enabledPanels || Config.options.enabledPanels.length === 0) {
                    const family = Config.options.panelFamily || "ii"
                    if (root.families.includes(family)) {
                        Config.options.enabledPanels = root.panelFamilies[family]
                    }
                }
                // Migration: Ensure waffle family has wBackdrop instead of iiBackdrop
                root.migrateEnabledPanels();
            }
        }
    }

    // Migrate enabledPanels for users upgrading from older versions
    function migrateEnabledPanels() {
        const family = Config.options.panelFamily || "ii";
        const panels = Config.options.enabledPanels || [];
        
        if (family === "waffle") {
            // If waffle family has iiBackdrop but not wBackdrop, migrate
            const hasIiBackdrop = panels.includes("iiBackdrop");
            const hasWBackdrop = panels.includes("wBackdrop");
            
            if (hasIiBackdrop && !hasWBackdrop) {
                console.log("[Shell] Migrating enabledPanels: replacing iiBackdrop with wBackdrop for waffle family");
                const newPanels = panels.filter(p => p !== "iiBackdrop");
                newPanels.push("wBackdrop");
                Config.options.enabledPanels = newPanels;
            }
        }
    }

    // IPC for settings
    IpcHandler {
        target: "settings"
        function open(): void {
            settingsProcess.running = true
        }
    }
    Process {
        id: settingsProcess
        command: ["qs", "-n", "-p", Quickshell.shellPath("settings.qml")]
    }

    // === Panel Loaders ===
    // ii style (Material)
    PanelLoader { identifier: "iiBar"; extraCondition: !Config.options.bar.vertical; component: Bar {} }
    PanelLoader { identifier: "iiBackground"; component: Background {} }
    PanelLoader { identifier: "iiBackdrop"; extraCondition: Config.options?.background?.backdrop?.enable ?? false; component: Backdrop {} }
    PanelLoader { identifier: "iiCheatsheet"; component: Cheatsheet {} }
    PanelLoader { identifier: "iiCrosshair"; component: Crosshair {} }
    PanelLoader { identifier: "iiDock"; extraCondition: Config.options.dock.enable; component: Dock {} }
    PanelLoader { identifier: "iiLock"; component: Lock {} }
    PanelLoader { identifier: "iiMediaControls"; component: MediaControls {} }
    PanelLoader { identifier: "iiNotificationPopup"; component: NotificationPopup {} }
    PanelLoader { identifier: "iiOnScreenDisplay"; component: OnScreenDisplay {} }
    PanelLoader { identifier: "iiOnScreenKeyboard"; component: OnScreenKeyboard {} }
    PanelLoader { identifier: "iiOverlay"; component: Overlay {} }
    PanelLoader { identifier: "iiOverview"; component: Overview {} }
    PanelLoader { identifier: "iiPolkit"; component: Polkit {} }
    PanelLoader { identifier: "iiRegionSelector"; component: RegionSelector {} }
    PanelLoader { identifier: "iiScreenCorners"; component: ScreenCorners {} }
    PanelLoader { identifier: "iiSessionScreen"; component: SessionScreen {} }
    PanelLoader { identifier: "iiSidebarLeft"; component: SidebarLeft {} }
    PanelLoader { identifier: "iiSidebarRight"; component: SidebarRight {} }
    PanelLoader { identifier: "iiVerticalBar"; extraCondition: Config.options.bar.vertical; component: VerticalBar {} }
    PanelLoader { identifier: "iiWallpaperSelector"; component: WallpaperSelector {} }
    PanelLoader { identifier: "iiAltSwitcher"; component: AltSwitcher {} }
    PanelLoader { identifier: "iiClipboard"; component: ClipboardModule.ClipboardPanel {} }

    // Waffle style (Windows 11)
    PanelLoader { identifier: "wBar"; component: WaffleBarModule.WaffleBar {} }
    PanelLoader { identifier: "wBackground"; component: WaffleBackgroundModule.WaffleBackground {} }
    PanelLoader { identifier: "wStartMenu"; component: WaffleStartMenu {} }
    PanelLoader { identifier: "wActionCenter"; component: WaffleActionCenter {} }
    PanelLoader { identifier: "wNotificationCenter"; component: WaffleNotificationCenter {} }
    PanelLoader { identifier: "wOnScreenDisplay"; component: WaffleOSDModule.WaffleOSD {} }
    PanelLoader { identifier: "wWidgets"; component: WaffleWidgets {} }
    PanelLoader { identifier: "wBackdrop"; extraCondition: Config.options?.waffles?.background?.backdrop?.enable ?? true; component: WaffleBackdropModule.WaffleBackdrop {} }

    // Shared (always loaded via ToastManager)
    ToastManager {}

    // === PanelLoader Component ===
    component PanelLoader: LazyLoader {
        required property string identifier
        property bool extraCondition: true
        active: Config.ready && Config.options.enabledPanels.includes(identifier) && extraCondition
    }

    // === Panel Families ===
    property list<string> families: ["ii", "waffle"]
    property var panelFamilies: ({
        "ii": [
            "iiBar", "iiBackground", "iiBackdrop", "iiCheatsheet", "iiDock", "iiLock", 
            "iiMediaControls", "iiNotificationPopup", "iiOnScreenDisplay", "iiOnScreenKeyboard", 
            "iiOverlay", "iiOverview", "iiPolkit", "iiRegionSelector", "iiScreenCorners", 
            "iiSessionScreen", "iiSidebarLeft", "iiSidebarRight", "iiVerticalBar", 
            "iiWallpaperSelector", "iiAltSwitcher", "iiClipboard"
        ],
        "waffle": [
            "wBar", "wBackground", "wBackdrop", "wStartMenu", "wActionCenter", "wNotificationCenter", "wOnScreenDisplay", "wWidgets",
            // Shared modules that work with waffle
            "iiCheatsheet", "iiLock", "iiNotificationPopup", "iiOnScreenKeyboard", "iiOverlay", "iiOverview", "iiPolkit", 
            "iiRegionSelector", "iiSessionScreen", "iiWallpaperSelector", "iiAltSwitcher", "iiClipboard"
        ]
    })

    function cyclePanelFamily() {
        const currentIndex = families.indexOf(Config.options.panelFamily)
        const nextIndex = (currentIndex + 1) % families.length
        Config.options.panelFamily = families[nextIndex]
        Config.options.enabledPanels = panelFamilies[Config.options.panelFamily]
    }

    function setPanelFamily(family: string) {
        if (families.includes(family)) {
            Config.options.panelFamily = family
            Config.options.enabledPanels = panelFamilies[family]
        }
    }

    IpcHandler {
        target: "panelFamily"
        function cycle(): void { root.cyclePanelFamily() }
        function set(family: string): void { root.setPanelFamily(family) }
    }
}
