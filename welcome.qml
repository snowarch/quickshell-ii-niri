//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env INIR_STANDALONE_WINDOW=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects as GE
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

Scope {
    id: root
    property string firstRunFilePath: FileUtils.trimFileProtocol(`${Directories.state}/user/first_run.txt`)
    property string firstRunFileContent: "This file is just here to confirm you've been greeted :>"
    property int currentStep: 0

    // ─── Responsive scale ───
    readonly property real screenWidth: focusedScreen?.width ?? 1920
    readonly property real screenHeight: focusedScreen?.height ?? 1080
    readonly property bool compact: screenHeight < 1000
    readonly property bool veryCompact: screenHeight < 720
    readonly property int screenPadding: compact ? 24 : 60
    readonly property int cardPadding: compact ? 20 : 36
    readonly property real stepWidth: Math.min(720, screenWidth - 2 * screenPadding - 2 * cardPadding)
    readonly property int totalSteps: 5
    property var focusedScreen: GlobalStates.primaryScreen

    readonly property string selectedExperiencePreset: Config.options?.welcomeWizard?.stylePreset ?? "material"
    readonly property string selectedPerformancePreset: Config.options?.welcomeWizard?.performancePreset ?? "balanced"
    property bool experienceCustomized: false
    property bool initialExperienceApplied: false
    property bool initialPerformanceApplied: false
    readonly property bool firstRunSetup: !(Config.options?.welcomeWizard?.completed ?? false)
        && !(Config.options?.welcomeWizard?.skipped ?? false)

    readonly property var experiencePresets: [
        {
            id: "material", name: "Material", icon: "category", panelFamily: "ii", globalStyle: "material",
            description: Translation.tr("Material II at full strength: a populated M3 bar, M3 dock, practical sidebars, rich quick controls and a balanced desktop composition."),
            values: {
                "bar.appearanceStyle": "m3",
                "bar.m3.layoutMode": "showcase",
                "bar.m3.borderless": "separated",
                "bar.m3.layouts.leftLayout": ["media", "workspaces"],
                "bar.m3.layouts.middleLayout": ["visualizer", "docktoPanel", "visualizer"],
                "bar.m3.layouts.rightLayout": ["utilButtons", "systemIcons", "weatherBar", "clockWidget"],
                "bar.m3.resources.style": "filled",
                "bar.m3.resources.showValue": true,
                "bar.m3.workspaces.showAppIcons": true,
                "bar.m3.workspaces.indicatorStyle": "icon",
                "bar.visualizer.enable": true,
                "bar.visualizer.type": "organic",
                "bar.visualizer.organicFit": "contained",
                "bar.visualizer.opacity": 0.24,
                "dock.enable": true,
                "dock.style": "m3",
                "dock.cardStyle": false,
                "sidebar.style": "panel",
                "sidebar.cardStyle": true,
                "sidebar.animationType": "slide",
                "sidebar.widgets.note": true, "sidebar.widgets.launch": true, "sidebar.widgets.status": true,
                "sidebar.right.enabledWidgets": ["calendar", "events", "todo", "notepad", "calculator", "sysmon", "weather", "timer"],
                "sidebar.right.headerStyle": "profile",
                "sidebar.quickToggles.style": "android",
                "controlPanel.style": "panel",
                "dashboard.appearance.density": "comfortable",
                "background.widgets.clock.enable": true,
                "background.widgets.clock.placementStrategy": "topLeft",
                "background.widgets.clock.style": "digital",
                "background.widgets.systemMonitor.enable": true,
                "background.widgets.systemMonitor.placementStrategy": "bottomRight",
                "background.widgets.systemMonitor.displayMode": "rings",
                "background.widgets.mediaControls.enable": true,
                "background.widgets.mediaControls.placementStrategy": "bottomLeft",
                "background.widgets.mediaControls.playerPreset": "compact"
            }
        },
        {
            id: "cards", name: "Cards", icon: "branding_watermark", panelFamily: "ii", globalStyle: "cards",
            description: Translation.tr("Layered Material cards: a card-shaped classic bar, panel dock and card sidebars with a calmer information hierarchy."),
            values: {
                "bar.appearanceStyle": "classic", "bar.cornerStyle": 3, "bar.borderless": false,
                "bar.layout.left": ["leftSidebarButton", "activeWindow"],
                "bar.layout.centerLeft": ["resources", "media"],
                "bar.layout.center": ["workspaces"],
                "bar.layout.centerRight": ["clock", "utilButtons", "battery"],
                "bar.layout.right": ["rightSidebarButton", "tray", "weather"],
                "bar.visualizer.enable": false,
                "dock.enable": true, "dock.style": "panel", "dock.cardStyle": true,
                "sidebar.style": "panel", "sidebar.cardStyle": true, "sidebar.animationType": "pop",
                "sidebar.tools.enable": false, "sidebar.software.enable": false,
                "sidebar.widgets.note": true, "sidebar.widgets.launch": true, "sidebar.widgets.status": false,
                "sidebar.right.enabledWidgets": ["calendar", "todo", "notepad", "weather", "timer"],
                "sidebar.right.headerStyle": "profile", "sidebar.quickToggles.style": "android",
                "controlPanel.style": "panel", "dashboard.appearance.density": "comfortable",
                "background.widgets.clock.enable": true, "background.widgets.clock.placementStrategy": "topLeft", "background.widgets.clock.style": "digital", "background.widgets.clock.showDate": false,
                "background.widgets.dateBadge.enable": true, "background.widgets.dateBadge.placementStrategy": "topRight", "background.widgets.dateBadge.style": "ticket",
                "background.widgets.mediaControls.enable": true, "background.widgets.mediaControls.placementStrategy": "bottomLeft", "background.widgets.mediaControls.playerPreset": "full",
                "background.widgets.calendarUpcoming.enable": true, "background.widgets.calendarUpcoming.placementStrategy": "bottomRight"
            }
        },
        {
            id: "aurora", name: "Aurora", icon: "blur_on", panelFamily: "ii", globalStyle: "aurora",
            description: Translation.tr("Wallpaper glass composition: Islands bar, island dock, island sidebars and floating content with restrained transparent desktop widgets."),
            values: {
                "appearance.island.glass": true, "appearance.island.glassBlur": 0.9,
                "appearance.island.opacity": 0.78, "appearance.island.shadow": true, "appearance.island.sheen": true,
                "appearance.aurora.transparency.overlay": 0.34, "appearance.aurora.transparency.subSurface": 0.46,
                "bar.appearanceStyle": "islands", "bar.islands.inset": 5, "bar.islands.padding": 14,
                "bar.layout.left": ["leftSidebarButton", "activeWindow"],
                "bar.layout.centerLeft": ["media"],
                "bar.layout.center": ["workspaces"],
                "bar.layout.centerRight": ["clock", "battery"],
                "bar.layout.right": ["rightSidebarButton", "tray", "weather"],
                "bar.visualizer.enable": true, "bar.visualizer.type": "wave", "bar.visualizer.waveMode": "ribbon", "bar.visualizer.frequencyProfile": "warm", "bar.visualizer.opacity": 0.24,
                "dock.enable": true, "dock.style": "island", "dock.cardStyle": false, "dock.enableBlurGlass": true,
                "sidebar.style": "island", "sidebar.cardStyle": false, "sidebar.animationType": "reveal",
                "sidebar.tools.enable": false, "sidebar.software.enable": false,
                "sidebar.widgets.note": false, "sidebar.widgets.launch": false, "sidebar.widgets.status": false, "sidebar.widgets.worldClock": true,
                "sidebar.right.enabledWidgets": ["calendar", "events", "todo", "weather", "timer"],
                "sidebar.right.headerStyle": "profile", "sidebar.right.headerBanner": "wallpaper", "sidebar.quickToggles.style": "android",
                "controlPanel.style": "island", "background.widgets.style": "island",
                "dashboard.appearance.cardOpacity": 0.78,
                "background.widgets.clock.enable": true, "background.widgets.clock.placementStrategy": "topLeft", "background.widgets.clock.style": "androidStacked", "background.widgets.clock.showDate": false,
                "background.widgets.weather.enable": true, "background.widgets.weather.placementStrategy": "topRight",
                "background.widgets.mediaControls.enable": true, "background.widgets.mediaControls.placementStrategy": "bottomLeft", "background.widgets.mediaControls.playerPreset": "visualizer"
            }
        },
        {
            id: "inir", name: "iNiR", icon: "terminal", panelFamily: "ii", globalStyle: "inir",
            description: Translation.tr("Technical information layout: framed bar, dense system controls, classic quick toggles and terminal-like desktop readouts."),
            values: {
                "appearance.iiMotionProfile": "classic",
                "bar.appearanceStyle": "frame", "bar.borderless": false,
                "bar.layout.left": ["leftSidebarButton", "activeWindow"],
                "bar.layout.centerLeft": ["resources"],
                "bar.layout.center": ["workspaces"],
                "bar.layout.centerRight": ["clock", "battery"],
                "bar.layout.right": ["rightSidebarButton", "tray", "shellUpdate"],
                "bar.visualizer.enable": false,
                "dock.enable": true, "dock.style": "panel", "dock.cardStyle": false,
                "sidebar.style": "panel", "sidebar.cardStyle": false, "sidebar.layout": "compact", "sidebar.animationType": "fade",
                "sidebar.news.enable": false, "sidebar.widgets.week": false, "sidebar.widgets.media": false, "sidebar.widgets.wallpaper": false,
                "sidebar.widgets.note": false, "sidebar.widgets.launch": true, "sidebar.widgets.controls": true, "sidebar.widgets.status": true,
                "sidebar.right.enabledWidgets": ["calendar", "calculator", "sysmon", "timer"],
                "sidebar.right.headerStyle": "classic", "sidebar.right.headerBanner": "none", "sidebar.quickToggles.style": "classic",
                "controlPanel.compactMode": true, "dashboard.appearance.density": "compact",
                "background.widgets.clock.enable": true, "background.widgets.clock.placementStrategy": "topLeft", "background.widgets.clock.style": "pixel",
                "background.widgets.systemMonitor.enable": true, "background.widgets.systemMonitor.placementStrategy": "bottomRight", "background.widgets.systemMonitor.displayMode": "text",
                "background.widgets.uptime.enable": true, "background.widgets.uptime.placementStrategy": "bottomLeft"
            }
        },
        {
            id: "angel", name: "Angel", icon: "raven", panelFamily: "ii", globalStyle: "angel",
            description: Translation.tr("Neo-brutalist glass: scenic edge treatment, pill dock, responsive glass sidebars and bold media/system accents."),
            values: {
                "appearance.angelSubStyle": "frost",
                "appearance.angel.blur.intensity": 0.32, "appearance.angel.blur.saturation": 0.18,
                "appearance.angel.transparency.panel": 0.32, "appearance.angel.transparency.card": 0.46,
                "bar.appearanceStyle": "scenic",
                "bar.layout.left": ["leftSidebarButton", "activeWindow"],
                "bar.layout.centerLeft": ["media"],
                "bar.layout.center": ["workspaces"],
                "bar.layout.centerRight": ["clock", "utilButtons"],
                "bar.layout.right": ["rightSidebarButton", "tray", "weather"],
                "bar.visualizer.enable": true, "bar.visualizer.type": "wave", "bar.visualizer.waveMode": "line", "bar.visualizer.frequencyProfile": "vocal", "bar.visualizer.opacity": 0.32,
                "dock.enable": true, "dock.style": "pill", "dock.cardStyle": false, "dock.enableBlurGlass": true,
                "sidebar.style": "panel", "sidebar.cardStyle": false, "sidebar.animationType": "drop",
                "sidebar.tools.enable": false, "sidebar.software.enable": false,
                "sidebar.widgets.note": false, "sidebar.widgets.launch": false, "sidebar.widgets.status": true,
                "sidebar.right.enabledWidgets": ["calendar", "events", "todo", "weather"],
                "sidebar.right.headerStyle": "profile", "sidebar.right.headerBanner": "wallpaper", "sidebar.quickToggles.style": "android",
                "controlPanel.style": "panel", "dashboard.appearance.cardOpacity": 0.84,
                "background.widgets.clock.enable": true, "background.widgets.clock.placementStrategy": "topLeft", "background.widgets.clock.style": "androidStacked",
                "background.widgets.dateBadge.enable": true, "background.widgets.dateBadge.placementStrategy": "topRight", "background.widgets.dateBadge.style": "seal",
                "background.widgets.systemMonitor.enable": true, "background.widgets.systemMonitor.placementStrategy": "bottomRight", "background.widgets.systemMonitor.displayMode": "graph",
                "background.widgets.mediaControls.enable": true, "background.widgets.mediaControls.placementStrategy": "bottomLeft", "background.widgets.mediaControls.playerPreset": "albumart"
            }
        },
        {
            id: "regalia", name: "Regalia", icon: "event_seat", panelFamily: "ii", globalStyle: "regalia",
            description: Translation.tr("Engineered luxury: structured classic bar groups, macOS-style dock, compact sidebars and high-density system instrumentation."),
            values: {
                "appearance.iiMotionProfile": "classic",
                "appearance.regalia.glass": true, "appearance.regalia.glassBlur": 0.72,
                "appearance.regalia.glassSurfaceOpacity": 0.68, "appearance.regalia.radiusScale": 0.92,
                "bar.appearanceStyle": "classic", "bar.cornerStyle": 1, "bar.borderless": false,
                "bar.layout.left": ["leftSidebarButton", "activeWindow"],
                "bar.layout.centerLeft": ["resources"],
                "bar.layout.center": ["workspaces"],
                "bar.layout.centerRight": ["clock", "battery"],
                "bar.layout.right": ["rightSidebarButton", "tray", "shellUpdate"],
                "bar.visualizer.enable": false,
                "dock.enable": true, "dock.style": "macos", "dock.cardStyle": false,
                "sidebar.style": "panel", "sidebar.cardStyle": false, "sidebar.layout": "compact", "sidebar.animationType": "slide",
                "sidebar.news.enable": false, "sidebar.widgets.week": false, "sidebar.widgets.media": true, "sidebar.widgets.wallpaper": false,
                "sidebar.widgets.note": false, "sidebar.widgets.launch": true, "sidebar.widgets.controls": true, "sidebar.widgets.status": true,
                "sidebar.right.enabledWidgets": ["calendar", "calculator", "sysmon", "timer"],
                "sidebar.right.headerStyle": "classic", "sidebar.quickToggles.style": "classic",
                "controlPanel.compactMode": true, "dashboard.appearance.density": "compact",
                "background.widgets.clock.enable": true, "background.widgets.clock.placementStrategy": "topLeft", "background.widgets.clock.style": "digital",
                "background.widgets.systemMonitor.enable": true, "background.widgets.systemMonitor.placementStrategy": "bottomRight", "background.widgets.systemMonitor.displayMode": "tiles",
                "background.widgets.uptime.enable": true, "background.widgets.uptime.placementStrategy": "bottomLeft"
            }
        },
        {
            id: "zzz", name: "ZZZ", icon: "bolt", panelFamily: "ii", globalStyle: "zzz",
            description: Translation.tr("Urban graphic composition: unified ZZZ bar chrome, punchy panels, pixel typography and poster-like decorative widgets."),
            values: {
                "appearance.iiMotionProfile": "classic",
                "appearance.zzz.shape": "square", "appearance.zzz.glass": true,
                "appearance.zzz.backdrop.burst": true, "appearance.zzz.backdrop.ghost": true,
                "appearance.zzz.backdrop.grid": true,
                "bar.appearanceStyle": "classic", "bar.cornerStyle": 1, "bar.borderless": true,
                "bar.layout.left": ["leftSidebarButton", "activeWindow"],
                "bar.layout.centerLeft": ["media"],
                "bar.layout.center": ["workspaces"],
                "bar.layout.centerRight": ["clock", "utilButtons"],
                "bar.layout.right": ["rightSidebarButton", "tray", "weather"],
                "bar.visualizer.enable": true, "bar.visualizer.type": "bars", "bar.visualizer.barsOrigin": "mirror", "bar.visualizer.frequencyProfile": "bass", "bar.visualizer.opacity": 0.3,
                "dock.enable": true, "dock.style": "panel", "dock.cardStyle": false,
                "sidebar.style": "panel", "sidebar.cardStyle": false, "sidebar.animationType": "pop",
                "sidebar.software.enable": false, "sidebar.widgets.note": true, "sidebar.widgets.launch": true,
                "sidebar.widgets.controls": false, "sidebar.widgets.status": true,
                "sidebar.right.enabledWidgets": ["calendar", "todo", "notepad", "weather", "timer"],
                "sidebar.right.headerStyle": "profile", "sidebar.right.headerBanner": "solid", "sidebar.quickToggles.style": "android",
                "background.widgets.clock.enable": true, "background.widgets.clock.placementStrategy": "topLeft", "background.widgets.clock.style": "pixel", "background.widgets.clock.showDate": false,
                "background.widgets.dateBadge.enable": true, "background.widgets.dateBadge.placementStrategy": "topRight", "background.widgets.dateBadge.style": "seal",
                "background.widgets.shape.enable": true, "background.widgets.shape.placementStrategy": "centerRight", "background.widgets.shape.shape": "SoftBurst",
                "background.widgets.mediaControls.enable": true, "background.widgets.mediaControls.placementStrategy": "bottomLeft", "background.widgets.mediaControls.playerPreset": "visualizer"
            }
        },
        {
            id: "cookie", name: Translation.tr("Cookie Shapes"), icon: "cookie", panelFamily: "ii", globalStyle: "cookie",
            description: Translation.tr("Material Expressive composition: the morphing Pill bar, live organic wings, pill dock, shape-driven widgets and playful motion."),
            values: {
                "bar.appearanceStyle": "pill",
                "bar.pill.barMode": false, "bar.pill.musicViz": true, "bar.pill.showGlyphs": true,
                "bar.pill.soul.enable": true, "bar.pill.soul.style": "orb",
                "bar.pill.surfaces.sysmon": true, "bar.pill.surfaces.clipboard": true, "bar.pill.surfaces.glance": true, "bar.pill.surfaces.launcher": true,
                "bar.pill.modules.workspaces": true, "bar.pill.modules.weather": true, "bar.pill.modules.tray": true, "bar.pill.modules.wifi": true, "bar.pill.modules.battery": true, "bar.pill.modules.inbox": true, "bar.pill.modules.mixer": true, "bar.pill.modules.sidebars": true, "bar.pill.modules.power": true,
                "bar.visualizer.enable": true, "bar.visualizer.type": "organic", "bar.visualizer.organicFit": "aura", "bar.visualizer.organicGlow": 38, "bar.visualizer.pillWingMode": "bounded",
                "dock.enable": true, "dock.style": "pill", "dock.cardStyle": false,
                "sidebar.style": "panel", "sidebar.cardStyle": false, "sidebar.animationType": "elastic", "sidebar.quickToggles.style": "android",
                "sidebar.tools.enable": false, "sidebar.software.enable": false,
                "sidebar.widgets.note": false, "sidebar.widgets.launch": false, "sidebar.widgets.status": true,
                "sidebar.right.enabledWidgets": ["calendar", "events", "todo", "weather", "timer"],
                "background.widgets.clock.enable": true, "background.widgets.clock.placementStrategy": "topLeft", "background.widgets.clock.style": "cookie",
                "background.widgets.shape.enable": true, "background.widgets.shape.placementStrategy": "centerRight", "background.widgets.shape.shape": "Flower",
                "background.widgets.mediaControls.enable": true, "background.widgets.mediaControls.placementStrategy": "bottomLeft", "background.widgets.mediaControls.playerPreset": "visualizer"
            }
        },
        {
            id: "editorial", name: "Editorial", icon: "auto_stories", panelFamily: "ii", globalStyle: "editorial",
            description: Translation.tr("Paper studio composition: Editorial chrome, classic card bar, quiet panel surfaces and typography-led desktop elements."),
            values: {
                "bar.appearanceStyle": "classic", "bar.cornerStyle": 3, "bar.borderless": false, "bar.visualizer.enable": false,
                "bar.layout.left": ["leftSidebarButton", "activeWindow"],
                "bar.layout.centerLeft": ["workspaces"],
                "bar.layout.center": ["clock"],
                "bar.layout.centerRight": ["utilButtons", "battery"],
                "bar.layout.right": ["rightSidebarButton", "tray", "weather"],
                "dock.enable": true, "dock.style": "panel", "dock.cardStyle": true,
                "sidebar.style": "panel", "sidebar.cardStyle": true, "sidebar.animationType": "fade",
                "sidebar.tools.enable": false, "sidebar.software.enable": false, "sidebar.widgets.wallpaper": false,
                "sidebar.widgets.note": true, "sidebar.widgets.launch": false, "sidebar.widgets.controls": false, "sidebar.widgets.status": false,
                "sidebar.right.enabledWidgets": ["calendar", "events", "todo", "notepad", "weather"],
                "sidebar.right.headerStyle": "classic", "sidebar.right.headerBanner": "none", "sidebar.quickToggles.style": "classic",
                "controlPanel.style": "panel", "settingsUi.overlayStyle": "editorial",
                "appearance.editorial.paperStack": true, "appearance.editorial.paperDepth": 3,
                "dashboard.appearance.density": "comfortable", "dashboard.appearance.showCardTitles": true,
                "background.widgets.clock.enable": true, "background.widgets.clock.placementStrategy": "topRight", "background.widgets.clock.style": "digital",
                "background.widgets.editorial.enable": true, "background.widgets.editorial.placementStrategy": "centerLeft", "background.widgets.editorial.style": "poster",
                "background.widgets.shape.enable": true, "background.widgets.shape.placementStrategy": "centerRight", "background.widgets.shape.shape": "Flower"
            }
        },
        {
            id: "waffle", name: "Waffle", icon: "grid_view", panelFamily: "waffle", globalStyle: "material",
            description: Translation.tr("The native Waffle experience: Windows-like bottom bar, wide Start menu, complete Action Center, Widgets panel and Waffle desktop clock."),
            values: {
                "waffles.settings.useMaterialStyle": false,
                "waffles.bar.bottom": true, "waffles.bar.leftAlignApps": false, "waffles.bar.desktopPeek.hoverPeek": true,
                "waffles.bar.monochromeIcons": false, "waffles.bar.tintTrayIcons": false,
                "waffles.startMenu.sizePreset": "wide",
                "waffles.taskView.mode": "carousel",
                "waffles.widgetsPanel.showDateTime": true, "waffles.widgetsPanel.showWeather": true, "waffles.widgetsPanel.showSystem": true, "waffles.widgetsPanel.showMedia": true, "waffles.widgetsPanel.showQuickActions": true,
                "waffles.widgetsPanel.showColorScheme": true,
                "waffles.widgetsPanel.quickActions": ["files", "terminal", "settings", "wallpaper", "screenshot", "screenRecord", "session"],
                "waffles.actionCenter.toggles": ["network", "hotspot", "bluetooth", "easyEffects", "powerProfile", "idleInhibitor", "nightLight", "darkMode", "mic", "notifications", "onScreenKeyboard", "gameMode", "screenSnip", "colorPicker"],
                "waffles.background.widgets.clock.enable": true, "waffles.background.widgets.clock.placementStrategy": "leastBusy", "waffles.background.widgets.clock.style": "hero",
                "waffles.background.widgets.clock.colorMode": "adaptive", "waffles.background.widgets.clock.showDate": true, "waffles.background.widgets.clock.showShadow": true,
                "waffles.modules.widgets": true, "waffles.modules.sidebarLeft": false, "waffles.modules.sidebarRight": false, "waffles.modules.dock": false, "waffles.modules.mediaControls": false,
                "dashboard.enable": false, "dock.enable": false,
                "background.widgets.clock.enable": false, "background.widgets.dateBadge.enable": false, "background.widgets.systemMonitor.enable": false, "background.widgets.mediaControls.enable": false
            }
        }
    ]

    readonly property var performancePresets: [
        {
            id: "minimum", name: Translation.tr("Low-end"), icon: "energy_savings_leaf",
            description: Translation.tr("Maximum savings for very weak GPUs or battery-first systems: effects and motion are disabled, while Style default stays remembered for when you turn them back on."),
            values: {
                "performance.lowPower": true,
                "performance.reduceAnimations": true,
                "performance.blurBackend": "auto",
                "performance.compositorBlur": false,
                "performance.blurAreas.bar": "inherit",
                "performance.blurAreas.dock": "inherit",
                "performance.blurAreas.panels": "inherit",
                "performance.blurAreas.islands": "inherit",
                "performance.blurAreas.widgets": "inherit"
            }
        },
        {
            id: "efficient", name: Translation.tr("Low-end styled"), icon: "speed",
            description: Translation.tr("Keeps full motion and each style's intended wallpaper glass, but avoids compositor blur. The low-end choice when you still want iNiR to look like iNiR."),
            values: {
                "performance.lowPower": false,
                "performance.reduceAnimations": false,
                "performance.blurBackend": "auto",
                "performance.compositorBlur": false,
                "performance.blurAreas.bar": "inherit",
                "performance.blurAreas.dock": "inherit",
                "performance.blurAreas.panels": "inherit",
                "performance.blurAreas.islands": "inherit",
                "performance.blurAreas.widgets": "inherit"
            }
        },
        {
            id: "balanced", name: Translation.tr("Medium"), icon: "tune",
            description: Translation.tr("Medium hardware and up: each style gets its intended effects and blur policy, with game mode still able to cut them automatically."),
            values: {
                "performance.lowPower": false,
                "performance.reduceAnimations": false,
                "performance.blurBackend": "auto",
                "performance.compositorBlur": true,
                "performance.blurAreas.bar": "inherit",
                "performance.blurAreas.dock": "inherit",
                "performance.blurAreas.panels": "inherit",
                "performance.blurAreas.islands": "inherit",
                "performance.blurAreas.widgets": "inherit"
            }
        }
    ]

    readonly property var presetManagedDesktopWidgets: [
        "weather", "clock", "customImage", "imageConverter", "mediaControls",
        "visualizer", "systemMonitor", "battery", "notes", "calendarUpcoming",
        "monthCalendar", "todo", "timers", "uptime", "shape", "dateBadge",
        "editorial", "newsTicker", "mascot", "japaneseTypography", "worldClock",
        "userCard"
    ]

    function desktopCompositionForPreset(id: string): var {
        switch (id) {
        case "material": return {
            clock: { placementStrategy: "topLeft", timeScale: 76, dateScale: 74 },
            mediaControls: { placementStrategy: "bottomLeft", widgetScale: 86 },
            systemMonitor: { placementStrategy: "bottomRight", contentWidth: 300, contentHeight: 100 }
        }
        case "cards": return {
            clock: { placementStrategy: "topLeft", timeScale: 88, dateScale: 86 },
            dateBadge: { placementStrategy: "topRight", contentWidth: 176, contentHeight: 120 },
            mediaControls: { placementStrategy: "bottomLeft", widgetScale: 82 },
            calendarUpcoming: { placementStrategy: "bottomRight", contentWidth: 250, contentHeight: 168 }
        }
        case "aurora": return {
            clock: { placementStrategy: "topLeft", timeScale: 86, dateScale: 84 },
            weather: { placementStrategy: "topRight", size: 120 },
            mediaControls: { placementStrategy: "bottomLeft", widgetScale: 82 }
        }
        case "inir": return {
            clock: { placementStrategy: "topLeft", timeScale: 86, dateScale: 82 },
            uptime: { placementStrategy: "bottomLeft", contentWidth: 220, contentHeight: 84 },
            systemMonitor: { placementStrategy: "bottomRight", contentWidth: 420, contentHeight: 88 }
        }
        case "angel": return {
            clock: { placementStrategy: "topLeft", timeScale: 88, dateScale: 84 },
            dateBadge: { placementStrategy: "topRight", contentWidth: 164, contentHeight: 120 },
            mediaControls: { placementStrategy: "bottomLeft", widgetScale: 72 },
            systemMonitor: { placementStrategy: "bottomRight", contentWidth: 300, contentHeight: 106 }
        }
        case "regalia": return {
            clock: { placementStrategy: "topLeft", timeScale: 84, dateScale: 82 },
            uptime: { placementStrategy: "bottomLeft", contentWidth: 220, contentHeight: 84 },
            systemMonitor: { placementStrategy: "bottomRight", contentWidth: 300, contentHeight: 150 }
        }
        case "zzz": return {
            clock: { placementStrategy: "topLeft", timeScale: 88, dateScale: 84 },
            dateBadge: { placementStrategy: "topRight", contentWidth: 160, contentHeight: 120 },
            shape: { placementStrategy: "centerRight", contentWidth: 108, contentHeight: 108 },
            mediaControls: { placementStrategy: "bottomLeft", widgetScale: 80 }
        }
        case "cookie": return {
            clock: { placementStrategy: "topLeft", "cookie.size": 170 },
            shape: { placementStrategy: "centerRight", contentWidth: 104, contentHeight: 104 },
            mediaControls: { placementStrategy: "bottomLeft", widgetScale: 82 }
        }
        case "editorial": return {
            clock: { placementStrategy: "topRight", timeScale: 78, dateScale: 76 },
            editorial: { placementStrategy: "centerLeft", contentWidth: 320, contentHeight: 190 },
            shape: { placementStrategy: "centerRight", contentWidth: 92, contentHeight: 92 }
        }
        case "waffle": return {
            "waffle.clock": { placementStrategy: "leastBusy", timeScale: 92, dateScale: 88 }
        }
        default: return ({})
        }
    }

    function applyDesktopComposition(id: string): void {
        const composition = root.desktopCompositionForPreset(id)
        const screens = Quickshell.screens
        for (let i = 0; i < screens.length; ++i) {
            const output = String(screens[i]?.name ?? "")
            if (!output)
                continue
            for (const widget of root.presetManagedDesktopWidgets)
                DesktopWidgetLayout.clearWidget(output, widget)
            DesktopWidgetLayout.clearWidget(output, "waffle.clock")

            for (const widget of Object.keys(composition)) {
                const desired = Object.assign({}, composition[widget])
                const strategy = String(desired.placementStrategy ?? "free")
                desired.placementStrategy = "free"
                DesktopWidgetLayout.setValues(output, widget, desired)
                if (strategy !== "free") {
                    const targetOutput = output
                    const targetWidget = widget
                    const targetStrategy = strategy
                    Qt.callLater(() => DesktopWidgetLayout.setValue(
                        targetOutput, targetWidget, "placementStrategy", targetStrategy))
                }
            }
        }
    }

    function presetById(list: var, id: string): var {
        return list.find(preset => preset.id === id) ?? list[0]
    }

    function valuesMatch(values: var): bool {
        const keys = Object.keys(values ?? {})
        for (const key of keys) {
            const current = Config.getNestedValue(key, undefined)
            if (JSON.stringify(current) !== JSON.stringify(values[key]))
                return false
        }
        return true
    }

    function performancePresetMatches(id: string): bool {
        return root.valuesMatch(root.presetById(root.performancePresets, id).values)
    }

    readonly property string effectivePerformancePreset: root.performancePresetMatches(root.selectedPerformancePreset)
        ? root.selectedPerformancePreset : "custom"
    readonly property var currentExperiencePreset: root.presetById(root.experiencePresets, root.selectedExperiencePreset)
    readonly property var currentPerformancePreset: root.presetById(root.performancePresets, root.selectedPerformancePreset)
    readonly property string currentExperienceDescription: root.experienceCustomized
        ? Translation.tr("Custom setup. Your manual changes are now layered on top of the selected starting experience.")
        : root.currentExperiencePreset.description
    readonly property string currentPerformancePresetDescription: root.effectivePerformancePreset === "custom"
        ? Translation.tr("Custom graphics policy. Pick a budget to reset effects, motion and blur together.")
        : root.currentPerformancePreset.description

    function experienceBaseValues(): var {
        return {
            "panelFamily": "ii",
            "appearance.iiMotionProfile": "contextual",
            "appearance.island.glass": true, "appearance.island.glassBlur": 1.0,
            "appearance.island.opacity": 1.0, "appearance.island.shadow": true, "appearance.island.sheen": true,
            "appearance.aurora.transparency.overlay": 0.38, "appearance.aurora.transparency.subSurface": 0.52,
            "appearance.angelSubStyle": "frost", "appearance.angel.blur.intensity": 0.25,
            "appearance.angel.blur.saturation": 0.15, "appearance.angel.transparency.panel": 0.35,
            "appearance.angel.transparency.card": 0.50,
            "appearance.regalia.glass": true, "appearance.regalia.glassBlur": 0.72,
            "appearance.regalia.glassSurfaceOpacity": 0.60, "appearance.regalia.radiusScale": 1.0,
            "appearance.zzz.shape": "square", "appearance.zzz.glass": true,
            "appearance.zzz.backdrop.burst": true, "appearance.zzz.backdrop.ghost": true,
            "appearance.zzz.backdrop.grid": true,
            "appearance.editorial.paperStack": false, "appearance.editorial.paperDepth": 3,
            "settingsUi.overlayStyle": "rail",
            "bar.appearanceStyle": "classic", "bar.cornerStyle": 1, "bar.borderless": true,
            "bar.showBackground": true, "bar.opacity": 1.0, "bar.autoHide.enable": false,
            "bar.layout.migrated": true,
            "bar.layout.left": ["leftSidebarButton", "activeWindow"],
            "bar.layout.centerLeft": ["resources", "media"],
            "bar.layout.center": ["workspaces"],
            "bar.layout.centerRight": ["clock", "utilButtons", "battery"],
            "bar.layout.right": ["rightSidebarButton", "tray", "weather"],
            "bar.weather.enable": true,
            "bar.modules.activeWindow": true, "bar.modules.battery": true, "bar.modules.clock": true,
            "bar.modules.leftSidebarButton": true, "bar.modules.media": true, "bar.modules.resources": true,
            "bar.modules.rightSidebarButton": true, "bar.modules.sysTray": true, "bar.modules.taskbar": false,
            "bar.modules.utilButtons": true, "bar.modules.weather": true, "bar.modules.workspaces": true,
            "bar.visualizer.enable": false, "bar.visualizer.type": "bars", "bar.visualizer.opacity": 0.25,
            "bar.visualizer.barsOrigin": "bottom", "bar.visualizer.waveMode": "fill",
            "bar.visualizer.frequencyProfile": "flat", "bar.visualizer.organicFit": "auto",
            "bar.visualizer.pillWingMode": "bounded",
            "bar.pill.musicViz": false, "bar.pill.barMode": false, "bar.pill.soul.enable": true, "bar.pill.soul.style": "orb",
            "dock.enable": true, "dock.style": "panel", "dock.cardStyle": false, "dock.showBackground": true,
            "dock.hoverToReveal": false, "dock.pinnedOnStartup": true, "dock.enableBlurGlass": false,
            "sidebar.style": "panel", "sidebar.cardStyle": false, "sidebar.layout": "default",
            "sidebar.animationType": "slide", "sidebar.instantOpen": false,
            "sidebar.collapseEmptyNotifications": false, "sidebar.collapseWidgetsTab": false,
            "sidebar.wallhaven.enable": true, "sidebar.news.enable": true, "sidebar.tools.enable": true,
            "sidebar.software.enable": true, "sidebar.translator.enable": false,
            "sidebar.animeSchedule.enable": false, "sidebar.ytmusic.enable": false,
            "sidebar.left.tabOrder": ["widgets", "wallhaven", "news", "tools", "software", "ai", "translator", "anime", "animeSchedule", "ytmusic"],
            "sidebar.widgets.enable": true, "sidebar.widgets.context": true, "sidebar.widgets.week": true,
            "sidebar.widgets.media": true, "sidebar.widgets.controls": true, "sidebar.widgets.status": true,
            "sidebar.widgets.wallpaper": true, "sidebar.widgets.note": true, "sidebar.widgets.launch": true,
            "sidebar.widgets.worldClock": false,
            "sidebar.widgets.widgetOrder": ["context", "week", "media", "controls", "status", "wallpaper", "note", "launch", "crypto", "worldclock"],
            "sidebar.right.enabledWidgets": ["calendar", "events", "todo", "notepad", "calculator", "sysmon", "weather", "timer"],
            "sidebar.right.sectionOrder": ["system", "sliders", "toggles", "notifications", "widgets"],
            "sidebar.right.headerStyle": "profile", "sidebar.right.headerBanner": "wallpaper",
            "sidebar.quickToggles.style": "android", "sidebar.quickToggles.android.columns": 4,
            "sidebar.quickToggles.android.toggles": [
                { "size": 1, "type": "network" }, { "size": 1, "type": "bluetooth" },
                { "size": 1, "type": "audio" }, { "size": 1, "type": "mic" },
                { "size": 1, "type": "nightLight" }, { "size": 1, "type": "gameMode" },
                { "size": 1, "type": "screenSnip" }, { "size": 1, "type": "colorPicker" }
            ],
            "sidebar.quickSliders.enable": true, "sidebar.quickSliders.showBrightness": true,
            "sidebar.quickSliders.showVolume": true, "sidebar.quickSliders.showMic": true,
            "controlPanel.style": "panel", "controlPanel.compactMode": false,
            "controlPanel.showMediaSection": true, "controlPanel.showWeatherSection": true,
            "controlPanel.showWallpaperSection": true, "controlPanel.showSystemSection": true,
            "controlPanel.showSlidersSection": true, "controlPanel.showQuickActionsSection": true,
            "dashboard.enable": true, "dashboard.showHeader": true, "dashboard.showPowerButtons": true,
            "dashboard.appearance.density": "comfortable", "dashboard.appearance.cardOpacity": 1.0,
            "dashboard.appearance.showCardTitles": true,
            "dashboard.layout.left": ["welcome", "clock", "system"],
            "dashboard.layout.center": ["notifications", "todo", "agenda"],
            "dashboard.layout.right": ["media", "weather", "calendar"],
            "background.widgets.style": "panel",
            "background.widgets.clock.enable": false, "background.widgets.clock.showDate": true, "background.widgets.clock.showBackground": false,
            "background.widgets.clock.showBorder": false, "background.widgets.clock.backgroundOpacity": 0,
            "background.widgets.clock.borderWidth": 0, "background.widgets.clock.quote.enable": false,
            "background.widgets.dateBadge.enable": false, "background.widgets.dateBadge.showBackground": false,
            "background.widgets.dateBadge.showBorder": false, "background.widgets.dateBadge.backgroundOpacity": 0,
            "background.widgets.dateBadge.borderWidth": 0,
            "background.widgets.systemMonitor.enable": false, "background.widgets.systemMonitor.showBackground": false,
            "background.widgets.systemMonitor.showBorder": false, "background.widgets.systemMonitor.backgroundOpacity": 0,
            "background.widgets.systemMonitor.borderWidth": 0,
            "background.widgets.mediaControls.enable": false, "background.widgets.mediaControls.showBackground": false,
            "background.widgets.mediaControls.showBorder": false, "background.widgets.mediaControls.backgroundOpacity": 0,
            "background.widgets.mediaControls.borderWidth": 0,
            "background.widgets.visualizer.enable": false, "background.widgets.visualizer.showBackground": false,
            "background.widgets.visualizer.showBorder": false, "background.widgets.visualizer.backgroundOpacity": 0,
            "background.widgets.visualizer.borderWidth": 0,
            "background.widgets.editorial.enable": false, "background.widgets.editorial.showBackground": false,
            "background.widgets.editorial.showBorder": false,
            "background.widgets.japaneseTypography.enable": false, "background.widgets.japaneseTypography.showBackground": false,
            "background.widgets.japaneseTypography.showBorder": false,
            "background.widgets.shape.enable": false, "background.widgets.shape.showBackground": false,
            "background.widgets.shape.showBorder": false,
            "background.widgets.uptime.enable": false, "background.widgets.uptime.showBackground": false,
            "background.widgets.uptime.showBorder": false,
            "background.widgets.weather.enable": false, "background.widgets.battery.enable": false,
            "background.widgets.calendarUpcoming.enable": false, "background.widgets.monthCalendar.enable": false,
            "background.widgets.notes.enable": false, "background.widgets.todo.enable": false,
            "background.widgets.timers.enable": false, "background.widgets.worldClock.enable": false,
            "background.widgets.userCard.enable": false, "background.widgets.newsTicker.enable": false,
            "background.widgets.imageConverter.enable": false, "background.widgets.customImage.enable": false,
            "background.widgets.mascot.enable": false,
            "mascot.enable": false,
            "sounds.notifications": true, "gameMode.autoDetect": true, "audio.protection.enable": true,
            "waffles.modules.widgets": true, "waffles.modules.sidebarLeft": false, "waffles.modules.sidebarRight": false,
            "waffles.modules.dock": false, "waffles.modules.mediaControls": false, "waffles.modules.screenCorners": false,
            "waffles.settings.useMaterialStyle": false, "waffles.background.widgets.clock.enable": false, "waffles.startMenu.sizePreset": "normal",
            "waffles.taskView.mode": "centered", "waffles.bar.desktopPeek.hoverPeek": false
        }
    }

    function applyExperiencePreset(id: string): void {
        const preset = root.presetById(root.experiencePresets, id)
        ThemeService.setGlobalStyle(preset.globalStyle)
        Config.setNestedValues(Object.assign({}, root.experienceBaseValues(), preset.values, {
            "panelFamily": preset.panelFamily,
            "welcomeWizard.stylePreset": preset.id
        }))
        root.applyDesktopComposition(preset.id)
        root.experienceCustomized = false
    }

    function applyPerformancePreset(id: string): void {
        const preset = root.presetById(root.performancePresets, id)
        Config.setNestedValues(Object.assign({}, preset.values, {
            "welcomeWizard.performancePreset": preset.id
        }))
    }

    function setExperienceFeature(path: string, value: var): void {
        root.experienceCustomized = true
        Config.setNestedValue(path, value)
    }

    onCurrentStepChanged: {
        if (!root.firstRunSetup)
            return
        if (root.currentStep === 1) {
            if (!root.initialExperienceApplied) {
                root.initialExperienceApplied = true
                root.applyExperiencePreset(root.selectedExperiencePreset)
            }
            if (!root.initialPerformanceApplied) {
                root.initialPerformanceApplied = true
                root.applyPerformancePreset(root.selectedPerformancePreset)
            }
        }
    }

    // ─── Entry/exit animation state (gate pattern) ───
    property bool _entryReady: false
    property bool _contentReady: false
    property bool _closing: false

    // The starting point runs before Appearance and Layout: a profile writes
    // composition keys wholesale and would overwrite anything refined earlier.
    readonly property var steps: [
        {
            icon: "waving_hand", title: Translation.tr("Welcome"),
            headline: Translation.tr("Welcome to iNiR"),
            subtitle: Translation.tr("Five short steps. Everything here can be changed later in Settings.")
        },
        {
            icon: "tune", title: Translation.tr("Experience"),
            headline: Translation.tr("How should iNiR introduce itself?"),
            subtitle: Translation.tr("Each option is a complete composition: surfaces, modules, sidebars, quick controls and desktop widgets. Accounts and credential-backed features stay opt-in.")
        },
        {
            icon: "palette", title: Translation.tr("Appearance"),
            headline: Translation.tr("Make it yours"),
            subtitle: Translation.tr("Your wallpaper generates the palette. The visual style sets the shape of every surface.")
        },
        {
            icon: "dashboard", title: Translation.tr("Layout"),
            headline: Translation.tr("Arrange the desktop"),
            subtitle: Translation.tr("Where the bar and dock live, and how the shell is shaped around them.")
        },
        {
            icon: "celebration", title: Translation.tr("Ready"),
            headline: Translation.tr("You're all set"),
            subtitle: Translation.tr("A few things worth knowing before you start.")
        }
    ]

    function finish(skipped: bool): void {
        if (root._closing) return
        root._closing = true
        // Write config keys
        Config.setNestedValue("welcomeWizard.completed", !skipped)
        Config.setNestedValue("welcomeWizard.skipped", skipped)
        // Reverse the entry animation
        root._contentReady = false
        root._entryReady = false
        _exitTimer.start()
    }

    Timer {
        id: _exitTimer
        interval: Appearance.animationsEnabled ? 400 : 0
        repeat: false
        onTriggered: {
            // first_run.txt is already written by FirstRunExperience before launching us
            Quickshell.execDetached(["/usr/bin/notify-send", Translation.tr("Welcome to inir"), Translation.tr("Press Super+/ for all keyboard shortcuts."), "-a", "Shell"])
            Qt.quit()
        }
    }

    Component.onCompleted: {
        Quickshell.watchFiles = false
        MaterialThemeLoader.reapplyTheme()
        Config.readWriteDelay = 0
        // Staggered entry: scrim first, then card content
        if (Appearance.animationsEnabled) {
            _entryTimer.start()
        } else {
            root._entryReady = true
            root._contentReady = true
        }
    }

    Timer {
        id: _entryTimer
        interval: 80
        repeat: false
        onTriggered: {
            root._entryReady = true
            _contentEntryTimer.start()
        }
    }
    Timer {
        id: _contentEntryTimer
        interval: 120
        repeat: false
        onTriggered: root._contentReady = true
    }

    PanelWindow {
        id: wizardPanel
        visible: true
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "quickshell:welcome"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: root._closing ? WlrKeyboardFocus.None : WlrKeyboardFocus.Exclusive
        anchors { top: true; bottom: true; left: true; right: true }
        implicitWidth: root.focusedScreen?.width ?? 1920
        implicitHeight: root.focusedScreen?.height ?? 1080

        // ─── Blurred wallpaper backdrop (scrim) ───
        Item {
            id: scrim
            anchors.fill: parent
            opacity: root._entryReady ? 1.0 : 0.0
            Behavior on opacity {
                enabled: Appearance.animationsEnabled
                NumberAnimation {
                    duration: Appearance.calcEffectiveDuration(320)
                    easing.type: Easing.OutCubic
                }
            }

            // Blur edge compensation: MultiEffect fades at boundaries
            readonly property int blurOverflow: 64

            Item {
                id: blurSource
                anchors.fill: parent
                anchors.margins: -scrim.blurOverflow

                Image {
                    anchors.fill: parent
                    anchors.margins: scrim.blurOverflow
                    source: Config.options?.background?.wallpaperPath ?? ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true
                    sourceSize.width: wizardPanel.implicitWidth
                    sourceSize.height: wizardPanel.implicitHeight
                }
            }

            MultiEffect {
                source: blurSource
                anchors.fill: parent
                anchors.margins: -scrim.blurOverflow
                blurEnabled: Appearance.effectsEnabled
                blurMax: 64
                blur: Appearance.effectsEnabled ? 1.0 : 0
                saturation: Appearance.effectsEnabled ? 0.15 : 0
            }

            // Scrim overlay
            Rectangle {
                anchors.fill: parent
                color: Appearance.colors.colScrim
                opacity: 0.55
            }

            // Vignette
            GE.RadialGradient {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.6; color: "transparent" }
                    GradientStop { position: 1.0; color: ColorUtils.applyAlpha(Appearance.colors.colScrim, 0.35) }
                }
            }
        }

        // Click outside does NOT dismiss — just absorb clicks
        MouseArea {
            anchors.fill: parent
        }

        // Main wizard card
        Item {
            id: wizardCard
            anchors.centerIn: parent
            width: Math.max(360, Math.min(1040, parent.width - 2 * root.screenPadding))
            height: Math.max(320, Math.min(parent.height - 2 * root.screenPadding, 1100))
            focus: true

            // Staggered entry animation — card comes in after scrim
            transformOrigin: Item.Center
            scale: root._contentReady ? 1.0 : 0.92
            opacity: root._contentReady ? 1.0 : 0.0
            Behavior on scale {
                enabled: Appearance.animationsEnabled
                NumberAnimation {
                    duration: Appearance.calcEffectiveDuration(420)
                    easing.type: Appearance.animation.elementMoveEnter.type
                    easing.bezierCurve: Appearance.animation.elementMoveEnter.bezierCurve
                }
            }
            Behavior on opacity {
                enabled: Appearance.animationsEnabled
                NumberAnimation {
                    duration: Appearance.calcEffectiveDuration(350)
                    easing.type: Easing.OutCubic
                }
            }

            // Keyboard navigation
            Keys.onEscapePressed: root.finish(true)
            Keys.onLeftPressed: if (root.currentStep > 0) root.currentStep--
            Keys.onRightPressed: if (root.currentStep < root.totalSteps - 1) root.currentStep++
            Keys.onReturnPressed: root.currentStep < root.totalSteps - 1 ? root.currentStep++ : root.finish(false)
            Keys.onEnterPressed: root.currentStep < root.totalSteps - 1 ? root.currentStep++ : root.finish(false)

            // Shadow (hide in aurora)
            StyledRectangularShadow {
                target: cardBg
                visible: Appearance.angelEverywhere || !Appearance.auroraEverywhere
            }

            // Card background - style-aware
            Rectangle {
                id: cardBg
                anchors.fill: parent

                radius: Appearance.inirEverywhere ? Appearance.inir.roundingLarge
                      : Appearance.rounding.large

                // Base color — colLayer1Base is the raw m3surfaceContainerLow without
                // contentTransparency mixing, so the wizard stays solid even when the user
                // has transparency enabled in Material/Cards styles.
                color: Appearance.inirEverywhere ? Appearance.inir.colLayer1
                     : Appearance.auroraEverywhere ? "transparent"
                     : Appearance.colors.colLayer1Base

                border.width: Appearance.inirEverywhere ? 1 : (Appearance.auroraEverywhere ? 0 : 1)
                border.color: Appearance.inirEverywhere ? Appearance.inir.colBorder
                            : Appearance.colors.colLayer0Border

                Behavior on color { ColorAnimation { duration: Appearance.animation.elementMoveFast.duration } }
                Behavior on border.color { ColorAnimation { duration: Appearance.animation.elementMoveFast.duration } }

                // Aurora: Wallpaper blur inside card
                Item {
                    id: auroraBlurSource
                    visible: Appearance.auroraEverywhere
                    anchors.fill: parent

                    Image {
                        x: -wizardCard.x
                        y: -wizardCard.y
                        width: wizardPanel.width
                        height: wizardPanel.height
                        source: Config.options?.background?.wallpaperPath ?? ""
                        fillMode: Image.PreserveAspectCrop
                    }
                }

                MultiEffect {
                    visible: Appearance.auroraEverywhere
                    source: auroraBlurSource
                    anchors.fill: parent
                    blurEnabled: Appearance.effectsEnabled
                    blurMax: 40
                    blur: Appearance.effectsEnabled ? 1.0 : 0
                    saturation: Appearance.effectsEnabled ? 0.1 : 0
                }

                // Aurora: Tinted overlay
                Rectangle {
                    anchors.fill: parent
                    visible: Appearance.auroraEverywhere
                    radius: parent.radius
                    color: ColorUtils.transparentize(Appearance.colors.colLayer1Base, 0.25)
                }

                // Block clicks from propagating to background MouseArea
                MouseArea {
                    anchors.fill: parent
                    onClicked: (event) => event.accepted = true
                }

                // Clip content to rounded corners
                layer.enabled: Appearance.effectsEnabled
                layer.effect: GE.OpacityMask {
                    maskSource: Rectangle {
                        width: cardBg.width
                        height: cardBg.height
                        radius: cardBg.radius
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: root.cardPadding
                spacing: root.compact ? 14 : 24

                // Header with step indicator
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    // Wrapped so the stepper centres on the card, not on itself.
                    Item {
                        Layout.fillWidth: true
                        implicitHeight: stepperRow.implicitHeight

                    Row {
                        id: stepperRow
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 0

                        Repeater {
                            model: root.steps
                            Row {
                                required property int index
                                required property var modelData

                                ColumnLayout {
                                    spacing: 4

                                    Rectangle {
                                        id: stepCircle
                                        Layout.alignment: Qt.AlignHCenter
                                        implicitWidth: root.compact ? 30 : 38
                                        implicitHeight: implicitWidth
                                        radius: implicitWidth / 2

                                        color: index < root.currentStep ? Appearance.colors.colPrimary
                                             : index === root.currentStep ? Appearance.colors.colPrimaryContainer
                                             : Appearance.colors.colLayer2

                                        border.width: index === root.currentStep ? 2 : 0
                                        border.color: Appearance.colors.colPrimary

                                        Behavior on color { ColorAnimation { duration: Appearance.animation.elementMoveFast.duration } }
                                        Behavior on scale {
                                            NumberAnimation {
                                                duration: Appearance.animation.elementMove.duration
                                                easing.type: Easing.OutBack
                                            }
                                        }
                                        Behavior on border.width { NumberAnimation { duration: Appearance.animation.elementMoveFast.duration } }

                                        scale: index === root.currentStep ? 1.12 : 1.0

                                        MaterialSymbol {
                                            anchors.centerIn: parent
                                            text: index < root.currentStep ? "check" : modelData.icon
                                            iconSize: index === root.currentStep ? 20 : 18
                                            color: index < root.currentStep ? Appearance.colors.colOnPrimary
                                                 : index === root.currentStep ? Appearance.colors.colOnPrimaryContainer
                                                 : Appearance.colors.colOnLayer2

                                            Behavior on iconSize { NumberAnimation { duration: Appearance.animation.elementMoveFast.duration } }
                                        }

                                        // Click on a past step to jump back to it (forward jumping disabled to keep flow)
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: index <= root.currentStep ? Qt.PointingHandCursor : Qt.ArrowCursor
                                            enabled: index <= root.currentStep
                                            onClicked: root.currentStep = index
                                        }
                                    }

                                    StyledText {
                                        Layout.alignment: Qt.AlignHCenter
                                        Layout.preferredWidth: root.compact ? 58 : 70
                                        visible: !root.veryCompact
                                        text: modelData.title
                                        horizontalAlignment: Text.AlignHCenter
                                        font.pixelSize: Appearance.font.pixelSize.smallest
                                        font.weight: index === root.currentStep ? Font.Medium : Font.Normal
                                        color: index === root.currentStep
                                            ? Appearance.colors.colOnLayer1
                                            : Appearance.colors.colSubtext
                                        elide: Text.ElideRight
                                        Behavior on color { ColorAnimation { duration: Appearance.animation.elementMoveFast.duration } }
                                    }
                                }

                                // Connector line with progress
                                Item {
                                    visible: index < root.steps.length - 1
                                    width: 36; height: 4
                                    y: 17  // align with circle vertical center (38/2 - 4/2)

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 2
                                        color: Appearance.colors.colLayer2
                                    }

                                    Rectangle {
                                        height: parent.height
                                        radius: 2
                                        color: Appearance.colors.colPrimary
                                        width: index < root.currentStep ? parent.width : 0
                                        Behavior on width {
                                            NumberAnimation {
                                                duration: Appearance.animation.elementMove.duration
                                                easing.type: Appearance.animation.elementMove.type
                                                easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    }

                    StyledText {
                        Layout.fillWidth: true
                        Layout.topMargin: 10
                        text: root.steps[root.currentStep].headline
                        horizontalAlignment: Text.AlignHCenter
                        font.family: Appearance.font.family.title
                        font.pixelSize: Appearance.font.pixelSize.hugeass
                        color: Appearance.colors.colOnLayer1
                        elide: Text.ElideRight
                    }

                    StyledText {
                        Layout.fillWidth: true
                        Layout.maximumWidth: 620
                        Layout.alignment: Qt.AlignHCenter
                        text: root.steps[root.currentStep].subtitle
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colSubtext
                        wrapMode: Text.WordWrap
                    }
                }

                // Separator
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    height: 1
                    color: Appearance.inirEverywhere ? Appearance.inir.colBorderSubtle
                         : Appearance.colors.colOutlineVariant
                }

                // Content area with transitions
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    StackLayout {
                        id: stepStack
                        anchors.fill: parent
                        anchors.topMargin: 8
                        currentIndex: root.currentStep

                        // Step transition - improved with scale and better easing
                        property int prevStep: 0
                        onCurrentIndexChanged: {
                            stepAnim.direction = currentIndex > prevStep ? 1 : -1
                            stepAnim.restart()
                            prevStep = currentIndex
                        }

                        opacity: 1
                        scale: 1
                        transform: Translate { id: stepTranslate; x: 0 }

                        ParallelAnimation {
                            id: stepAnim
                            property int direction: 1
                            property int moveDuration: Appearance.animation.elementMove.duration

                            // Fade + scale out, then fade + scale in
                            SequentialAnimation {
                                ParallelAnimation {
                                    NumberAnimation { 
                                        target: stepStack; property: "opacity"; to: 0
                                        duration: stepAnim.moveDuration * 0.35
                                        easing.type: Easing.OutCubic
                                    }
                                    NumberAnimation { 
                                        target: stepStack; property: "scale"; to: 0.96
                                        duration: stepAnim.moveDuration * 0.35
                                        easing.type: Easing.OutCubic
                                    }
                                }
                                ParallelAnimation {
                                    NumberAnimation { 
                                        target: stepStack; property: "opacity"; to: 1
                                        duration: stepAnim.moveDuration * 0.65
                                        easing.type: Easing.OutCubic
                                    }
                                    NumberAnimation { 
                                        target: stepStack; property: "scale"; to: 1
                                        duration: stepAnim.moveDuration * 0.65
                                        easing.type: Easing.OutBack
                                        easing.overshoot: 1.2
                                    }
                                }
                            }

                            // Slide animation with improved easing
                            SequentialAnimation {
                                NumberAnimation { 
                                    target: stepTranslate; property: "x"
                                    to: stepAnim.direction * -30
                                    duration: stepAnim.moveDuration * 0.35
                                    easing.type: Easing.OutCubic
                                }
                                PropertyAction { 
                                    target: stepTranslate; property: "x"
                                    value: stepAnim.direction * 30
                                }
                                NumberAnimation { 
                                    target: stepTranslate; property: "x"; to: 0
                                    duration: stepAnim.moveDuration * 0.65
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }

                        Item {
                            WelcomeContent {
                                id: welcomePage
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                            }
                            ScrollEdgeFade { target: welcomePage }
                        }
                        Item {
                            FeaturesContent {
                                id: featuresPage
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                            }
                            ScrollEdgeFade { target: featuresPage }
                        }
                        Item {
                            ThemeContent {
                                id: themePage
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                            }
                            ScrollEdgeFade { target: themePage }
                        }
                        Item {
                            LayoutContent {
                                id: layoutPage
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                            }
                            ScrollEdgeFade { target: layoutPage }
                        }
                        Item {
                            ReadyContent {
                                id: readyPage
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                            }
                            ScrollEdgeFade { target: readyPage }
                        }
                    }
                }

                // Navigation buttons — Back / hint / Continue (Skip moved to top-right corner)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    DialogButton {
                        visible: root.currentStep > 0
                        buttonText: Translation.tr("Back")
                        colBackground: Appearance.colors.colLayer2
                        colBackgroundHover: Appearance.colors.colLayer2Hover
                        onClicked: root.currentStep--
                    }

                    Item { Layout.fillWidth: true }

                    // Keyboard hint
                    RowLayout {
                        spacing: 6
                        opacity: 0.6

                        Row {
                            spacing: 2
                            KeyboardKey { key: "←" }
                            KeyboardKey { key: "→" }
                        }
                        StyledText {
                            text: Translation.tr("navigate")
                            font.pixelSize: Appearance.font.pixelSize.smallest
                            color: Appearance.colors.colSubtext
                        }
                    }

                    Item { Layout.fillWidth: true }

                    DialogButton {
                        buttonText: root.currentStep === root.totalSteps - 1 ? Translation.tr("Get Started") : Translation.tr("Continue")
                        colBackground: Appearance.colors.colPrimary
                        colBackgroundHover: Appearance.colors.colPrimaryHover
                        colText: Appearance.colors.colOnPrimary
                        onClicked: root.currentStep < root.totalSteps - 1 ? root.currentStep++ : root.finish(false)
                    }
                }
            }

            // Subtle "Skip setup" escape hatch in the top-right corner of the card.
            // Hidden on the last step (where "Get Started" is the right action).
            RippleButton {
                id: skipButton
                property bool _hovered: false
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 14
                anchors.rightMargin: 14
                visible: root.currentStep < root.totalSteps - 1
                opacity: visible ? (_hovered ? 1.0 : 0.65) : 0
                Behavior on opacity { NumberAnimation { duration: Appearance.animation.elementMoveFast.duration } }

                implicitHeight: 30
                implicitWidth: skipRow.implicitWidth + 20
                buttonRadius: Appearance.rounding.full
                colBackground: "transparent"
                colBackgroundHover: Appearance.colors.colLayer2Hover

                onClicked: root.finish(true)

                contentItem: RowLayout {
                    id: skipRow
                    anchors.centerIn: parent
                    spacing: 4

                    StyledText {
                        text: Translation.tr("Skip setup")
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colSubtext
                    }
                    MaterialSymbol {
                        text: "close"
                        iconSize: 14
                        color: Appearance.colors.colSubtext
                    }
                }

                StyledToolTip {
                    text: Translation.tr("You can re-open this wizard anytime with:\n  inir welcome")
                }

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                    onHoveredChanged: skipButton._hovered = hovered
                }
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // STEP CONTENT COMPONENTS
    // ═══════════════════════════════════════════════════════════════════════

    component WelcomeContent: Flickable {
        id: welcomeFlickable
        width: root.stepWidth
        contentHeight: welcomeColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        bottomMargin: 16
        topMargin: Math.max(0, (height - contentHeight - 16) / 2)

        ColumnLayout {
            id: welcomeColumn
            width: parent.width
            spacing: root.compact ? 12 : 18

        MaterialShapeWrappedMaterialSymbol {
            Layout.alignment: Qt.AlignHCenter
            text: "waving_hand"
            iconSize: 56
            padding: 18
            shape: MaterialShape.Shape.Cookie4Sided
            color: Appearance.colors.colPrimaryContainer
            colSymbol: Appearance.colors.colOnPrimaryContainer
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: Translation.tr("A Wayland shell for Niri, built to be lived in.")
            color: Appearance.colors.colSubtext
            font.pixelSize: Appearance.font.pixelSize.normal
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            Layout.maximumWidth: 520
        }

        // "What we'll set up" — gives users a preview so they see VALUE before skipping
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 6
            Layout.maximumWidth: 540
            implicitWidth: 520
            implicitHeight: previewCol.implicitHeight + 24
            radius: Appearance.inirEverywhere ? Appearance.inir.roundingNormal : Appearance.rounding.normal
            color: Appearance.inirEverywhere ? Appearance.inir.colLayer2
                 : Appearance.auroraEverywhere ? ColorUtils.transparentize(Appearance.colors.colLayer2, 0.5)
                 : Appearance.colors.colLayer2
            border.width: Appearance.inirEverywhere ? 1 : 0
            border.color: Appearance.inir.colBorderSubtle

            ColumnLayout {
                id: previewCol
                anchors {
                    fill: parent
                    margins: 12
                }
                spacing: 10

                StyledText {
                    Layout.fillWidth: true
                    text: Translation.tr("What this setup covers")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.weight: Font.Medium
                    color: Appearance.colors.colSubtext
                }

                Repeater {
                    model: [
                        { icon: "palette",   label: Translation.tr("Look"),       desc: Translation.tr("Theme, wallpaper, and visual style") },
                        { icon: "dashboard", label: Translation.tr("Structure"),  desc: Translation.tr("Bar, dock, and panel family") },
                        { icon: "tune",      label: Translation.tr("Essentials"), desc: Translation.tr("Only the daily features worth deciding now") }
                    ]
                    RowLayout {
                        Layout.fillWidth: true
                        required property var modelData
                        spacing: 12

                        MaterialSymbol {
                            text: modelData.icon
                            iconSize: 22
                            color: Appearance.colors.colPrimary
                            Layout.preferredWidth: 24
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            StyledText {
                                Layout.fillWidth: true
                                text: modelData.label
                                font.pixelSize: Appearance.font.pixelSize.small
                                font.weight: Font.Medium
                                color: Appearance.colors.colOnSurface
                            }
                            StyledText {
                                Layout.fillWidth: true
                                text: modelData.desc
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colSubtext
                                wrapMode: Text.WordWrap
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }

        // Settings UI experience choice — Easy vs Advanced
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 12
            Layout.maximumWidth: 560
            spacing: 8

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: Translation.tr("How much should Settings show at first?")
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.Medium
                color: Appearance.colors.colOnSurface
            }

            RowLayout {
                id: settingsDepthRow
                Layout.fillWidth: true
                Layout.maximumWidth: 520
                Layout.alignment: Qt.AlignHCenter
                spacing: 12

                readonly property real cardHeight: Math.max(
                    easyCardCol.implicitHeight, advancedCardCol.implicitHeight) + 24

                // Easy mode card
                Rectangle {
                    id: easyCard
                    readonly property bool selected: (Config.options?.settingsUi?.easyMode ?? false) === true
                    Layout.fillWidth: true
                    Layout.preferredHeight: settingsDepthRow.cardHeight
                    radius: Appearance.inirEverywhere ? Appearance.inir.roundingNormal : Appearance.rounding.normal
                    color: selected
                        ? Appearance.colors.colPrimaryContainer
                        : (Appearance.inirEverywhere ? Appearance.inir.colLayer2
                          : Appearance.auroraEverywhere ? ColorUtils.transparentize(Appearance.colors.colLayer2, 0.5)
                          : Appearance.colors.colLayer2)
                    border.width: selected ? 2 : 1
                    border.color: selected
                        ? Appearance.colors.colPrimary
                        : (Appearance.inirEverywhere ? Appearance.inir.colBorderSubtle
                          : Appearance.colors.colLayer0Border)

                    Behavior on color {
                        enabled: Appearance.animationsEnabled
                        animation: ColorAnimation { duration: Appearance.animation.elementMoveFast.duration; easing.type: Appearance.animation.elementMoveFast.type; easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve }
                    }

                    ColumnLayout {
                        id: easyCardCol
                        anchors {
                            fill: parent
                            margins: 12
                        }
                        spacing: 6

                        RowLayout {
                            spacing: 8
                            MaterialSymbol {
                                text: "school"
                                iconSize: 22
                                color: easyCard.selected
                                    ? Appearance.colors.colOnPrimaryContainer
                                    : Appearance.colors.colPrimary
                            }
                            StyledText {
                                Layout.fillWidth: true
                                text: Translation.tr("Focused")
                                font.pixelSize: Appearance.font.pixelSize.normal
                                font.weight: Font.Medium
                                color: easyCard.selected
                                    ? Appearance.colors.colOnPrimaryContainer
                                    : Appearance.colors.colOnSurface
                            }
                            MaterialSymbol {
                                visible: easyCard.selected
                                text: "check_circle"
                                iconSize: 18
                                color: Appearance.colors.colOnPrimaryContainer
                            }
                        }
                        StyledText {
                            Layout.fillWidth: true
                            text: Translation.tr("A shorter navigation with the controls most people need.")
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            wrapMode: Text.WordWrap
                            color: easyCard.selected
                                ? Appearance.colors.colOnPrimaryContainer
                                : Appearance.colors.colSubtext
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Config.setNestedValue("settingsUi.easyMode", true)
                    }
                }

                // Advanced mode card
                Rectangle {
                    id: advancedCard
                    readonly property bool selected: (Config.options?.settingsUi?.easyMode ?? false) === false
                    Layout.fillWidth: true
                    Layout.preferredHeight: settingsDepthRow.cardHeight
                    radius: Appearance.inirEverywhere ? Appearance.inir.roundingNormal : Appearance.rounding.normal
                    color: selected
                        ? Appearance.colors.colPrimaryContainer
                        : (Appearance.inirEverywhere ? Appearance.inir.colLayer2
                          : Appearance.auroraEverywhere ? ColorUtils.transparentize(Appearance.colors.colLayer2, 0.5)
                          : Appearance.colors.colLayer2)
                    border.width: selected ? 2 : 1
                    border.color: selected
                        ? Appearance.colors.colPrimary
                        : (Appearance.inirEverywhere ? Appearance.inir.colBorderSubtle
                          : Appearance.colors.colLayer0Border)

                    Behavior on color {
                        enabled: Appearance.animationsEnabled
                        animation: ColorAnimation { duration: Appearance.animation.elementMoveFast.duration; easing.type: Appearance.animation.elementMoveFast.type; easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve }
                    }

                    ColumnLayout {
                        id: advancedCardCol
                        anchors {
                            fill: parent
                            margins: 12
                        }
                        spacing: 6

                        RowLayout {
                            spacing: 8
                            MaterialSymbol {
                                text: "tune"
                                iconSize: 22
                                color: advancedCard.selected
                                    ? Appearance.colors.colOnPrimaryContainer
                                    : Appearance.colors.colPrimary
                            }
                            StyledText {
                                Layout.fillWidth: true
                                text: Translation.tr("Complete")
                                font.pixelSize: Appearance.font.pixelSize.normal
                                font.weight: Font.Medium
                                color: advancedCard.selected
                                    ? Appearance.colors.colOnPrimaryContainer
                                    : Appearance.colors.colOnSurface
                            }
                            Rectangle {
                                implicitWidth: advancedDefaultLabel.implicitWidth + 12
                                implicitHeight: advancedDefaultLabel.implicitHeight + 4
                                radius: height / 2
                                color: advancedCard.selected
                                    ? Appearance.colors.colPrimary
                                    : Appearance.colors.colPrimaryContainer
                                StyledText {
                                    id: advancedDefaultLabel
                                    anchors.centerIn: parent
                                    text: Translation.tr("Default")
                                    font.pixelSize: Appearance.font.pixelSize.smallest
                                    color: advancedCard.selected
                                        ? Appearance.colors.colOnPrimary
                                        : Appearance.colors.colOnPrimaryContainer
                                }
                            }
                            MaterialSymbol {
                                visible: advancedCard.selected
                                text: "check_circle"
                                iconSize: 18
                                color: Appearance.colors.colOnPrimaryContainer
                            }
                        }
                        StyledText {
                            Layout.fillWidth: true
                            text: Translation.tr("Every page and advanced control. You can switch between both views at any time.")
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            wrapMode: Text.WordWrap
                            color: advancedCard.selected
                                ? Appearance.colors.colOnPrimaryContainer
                                : Appearance.colors.colSubtext
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Config.setNestedValue("settingsUi.easyMode", false)
                    }
                }
            }
        }
        }
    }

    component ThemeContent: Flickable {
        id: themeFlickable
        width: root.stepWidth
        contentHeight: themeColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        bottomMargin: 16
        topMargin: Math.max(0, (height - contentHeight - 16) / 2)
        
        ColumnLayout {
            id: themeColumn
            width: parent.width
            spacing: 16

        // Light/Dark toggle
        SettingsGroup {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    MaterialSymbol { text: "contrast"; iconSize: 20; color: Appearance.colors.colPrimary }
                    StyledText { text: Translation.tr("Theme"); font.pixelSize: Appearance.font.pixelSize.normal }
                    Item { Layout.fillWidth: true }
                    StyledText {
                        text: Translation.tr("Applies everywhere")
                        font.pixelSize: Appearance.font.pixelSize.smallest
                        color: Appearance.colors.colSubtext
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 16
                    LightDarkPreferenceButton { dark: false }
                    LightDarkPreferenceButton { dark: true }
                }
            }
        }

        // Global style selector
        SettingsGroup {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    MaterialSymbol { text: "style"; iconSize: 20; color: Appearance.colors.colPrimary }
                    StyledText { text: Translation.tr("Visual Style"); font.pixelSize: Appearance.font.pixelSize.normal }
                    Item { Layout.fillWidth: true }
                    StyledText {
                        text: {
                            const style = Config.options?.appearance?.globalStyle ?? "material"
                            return style === "material" ? Translation.tr("Clean & Solid")
                                 : style === "cards" ? Translation.tr("Rounded Cards")
                                 : style === "aurora" ? Translation.tr("Glass & Blur")
                                 : style === "angel" ? Translation.tr("Neo-Brutalism Glass")
                                 : style === "inir" ? Translation.tr("Terminal Style")
                                 : style === "cookie" ? Translation.tr("Organic & Expressive")
                                 : style === "zzz" ? Translation.tr("Urban Graphic")
                                 : style === "regalia" ? Translation.tr("Engineered Luxury")
                                 : style === "editorial" ? Translation.tr("Editorial Paper")
                                 : Translation.tr("Custom")
                        }
                        color: Appearance.colors.colSubtext
                        font.pixelSize: Appearance.font.pixelSize.smaller
                    }
                }

                ConfigSelectionArray {
                    Layout.fillWidth: true
                    currentValue: Config.options?.appearance?.globalStyle ?? "material"
                    onSelected: newValue => {
                        root.experienceCustomized = true
                        ThemeService.setGlobalStyle(newValue)
                    }
                    options: [
                        { displayName: "Material", icon: "dashboard", value: "material" },
                        { displayName: "Cards", icon: "crop_square", value: "cards" },
                        { displayName: "Aurora", icon: "blur_on", value: "aurora" },
                        { displayName: "Inir", icon: "terminal", value: "inir" },
                        { displayName: "Angel", icon: "raven", value: "angel" },
                        { displayName: "Regalia", icon: "event_seat", value: "regalia" },
                        { displayName: "ZZZ", icon: "bolt", value: "zzz" },
                        { displayName: Translation.tr("Cookie Shapes"), icon: "cookie", value: "cookie" },
                        { displayName: Translation.tr("Editorial"), icon: "auto_stories", value: "editorial" }
                    ]
                }

                StyledText {
                    Layout.fillWidth: true
                    text: Translation.tr("All global styles remain fully editable in Settings.")
                    color: Appearance.colors.colSubtext
                    font.pixelSize: Appearance.font.pixelSize.smallest
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
            }
        }

        SettingsGroup {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            visible: (Config.options?.panelFamily ?? "ii") === "ii"

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    MaterialSymbol { text: "toolbar"; iconSize: 20; color: Appearance.colors.colPrimary }
                    StyledText { text: Translation.tr("Bar style"); font.pixelSize: Appearance.font.pixelSize.normal }
                    Item { Layout.fillWidth: true }
                }

                ConfigSelectionArray {
                    Layout.fillWidth: true
                    currentValue: Config.options?.bar?.appearanceStyle ?? "m3"
                    onSelected: newValue => root.setExperienceFeature("bar.appearanceStyle", newValue)
                    options: [
                        { displayName: Translation.tr("Classic"), icon: "toolbar", value: "classic" },
                        { displayName: Translation.tr("Islands"), icon: "linear_scale", value: "islands" },
                        { displayName: Translation.tr("Scenic"), icon: "gradient", value: "scenic" },
                        { displayName: Translation.tr("Frame"), icon: "crop_free", value: "frame" },
                        { displayName: "M3", icon: "category", value: "m3" },
                        { displayName: Translation.tr("Pill"), icon: "blur_on", value: "pill" }
                    ]
                }
            }
        }

        SettingsGroup {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            visible: (Config.options?.panelFamily ?? "ii") === "ii"

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    MaterialSymbol { text: "dock_to_bottom"; iconSize: 20; color: Appearance.colors.colPrimary }
                    StyledText { text: Translation.tr("Dock style"); font.pixelSize: Appearance.font.pixelSize.normal }
                    Item { Layout.fillWidth: true }
                }

                ConfigSelectionArray {
                    Layout.fillWidth: true
                    currentValue: Config.options?.dock?.style ?? "m3"
                    onSelected: newValue => root.setExperienceFeature("dock.style", newValue)
                    options: [
                        { displayName: Translation.tr("Panel"), icon: "dock_to_bottom", value: "panel" },
                        { displayName: Translation.tr("Pill"), icon: "interests", value: "pill" },
                        { displayName: "macOS", icon: "desktop_mac", value: "macos" },
                        { displayName: Translation.tr("Island"), icon: "blur_on", value: "island" },
                        { displayName: "M3", icon: "category", value: "m3" }
                    ]
                }
            }
        }

        SettingsGroup {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            visible: (Config.options?.panelFamily ?? "ii") === "ii"

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    MaterialSymbol { text: "side_navigation"; iconSize: 20; color: Appearance.colors.colPrimary }
                    StyledText { text: Translation.tr("Sidebar style"); font.pixelSize: Appearance.font.pixelSize.normal }
                    Item { Layout.fillWidth: true }
                }

                ConfigSelectionArray {
                    Layout.fillWidth: true
                    currentValue: Config.options?.sidebar?.style ?? "panel"
                    onSelected: newValue => root.setExperienceFeature("sidebar.style", newValue)
                    options: [
                        { displayName: Translation.tr("Panel"), icon: "side_navigation", value: "panel" },
                        { displayName: Translation.tr("Island"), icon: "blur_on", value: "island" }
                    ]
                }

                SettingsSwitch {
                    buttonIcon: "branding_watermark"
                    text: Translation.tr("Use Card style")
                    enabled: ["material", "inir", "editorial"].includes(Config.options?.appearance?.globalStyle ?? "material")
                    checked: Config.options?.sidebar?.cardStyle ?? false
                    onCheckedChanged: root.setExperienceFeature("sidebar.cardStyle", checked)
                }
            }
        }

        // Wallpaper - Inline picker (like QuickWallpaper widget)
        SettingsGroup {
            id: wallpaperGroup
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter

            property var wallpapersList: []
            readonly property string wallpapersPath: Directories.wallpapersPath
            readonly property real itemWidth: 130
            readonly property real itemHeight: 78

            Component.onCompleted: wallpaperScanProc.running = true

            Process {
                id: wallpaperScanProc
                command: ["/bin/sh", "-c", `find '${wallpaperGroup.wallpapersPath}' -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.avif' \\) -printf '%C@\\t%p\\n' 2>/dev/null`]
                stdout: SplitParser {
                    splitMarker: ""
                    onRead: data => {
                        const lines = data.trim().split("\n").filter(l => l.length > 0)
                        lines.sort((a, b) => parseFloat(b.split("\t")[0]) - parseFloat(a.split("\t")[0]))
                        wallpaperGroup.wallpapersList = lines.map(l => l.split("\t")[1]).filter(p => p && p.length > 0)
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    MaterialSymbol { text: "wallpaper"; iconSize: 20; color: Appearance.colors.colPrimary }
                    StyledText { text: Translation.tr("Wallpaper & Colors"); font.pixelSize: Appearance.font.pixelSize.normal }
                    Item { Layout.fillWidth: true }
                    StyledText {
                        text: Translation.tr("Colors auto-generated")
                        color: Appearance.colors.colSubtext
                        font.pixelSize: Appearance.font.pixelSize.smallest
                    }
                }

                // Carousel like QuickWallpaper widget
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: wallpaperGroup.itemHeight + 16
                    visible: wallpaperGroup.wallpapersList.length > 0

                    Rectangle {
                        anchors.fill: parent
                        radius: Appearance.rounding.small
                        color: Appearance.colors.colLayer2
                    }

                    ListView {
                        id: wallpaperCarousel
                        anchors.fill: parent
                        anchors.margins: 8
                        orientation: ListView.Horizontal
                        spacing: 8
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        model: wallpaperGroup.wallpapersList

                        WheelHandler {
                            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                            onWheel: event => {
                                const delta = event.angleDelta.y !== 0 ? event.angleDelta.y : event.angleDelta.x
                                wallpaperCarousel.contentX = Math.max(0, Math.min(
                                    wallpaperCarousel.contentWidth - wallpaperCarousel.width,
                                    wallpaperCarousel.contentX - delta
                                ))
                            }
                        }

                        delegate: Item {
                            id: wpDelegate
                            required property int index
                            required property string modelData
                            readonly property string filePath: modelData
                            readonly property bool isCurrentWallpaper: (Config.options?.background?.wallpaperPath ?? "") === filePath
                            readonly property bool isHovered: wpMouseArea.containsMouse

                            width: wallpaperGroup.itemWidth
                            height: wallpaperGroup.itemHeight

                            Rectangle {
                                anchors.fill: parent
                                radius: Appearance.rounding.small
                                color: "transparent"
                                border.width: wpDelegate.isCurrentWallpaper ? 2 : 0
                                border.color: Appearance.colors.colPrimary
                                z: 2
                            }

                            Rectangle {
                                id: wpThumb
                                anchors.fill: parent
                                radius: Appearance.rounding.small
                                color: Appearance.colors.colLayer3
                                clip: true

                                Image {
                                    anchors.fill: parent
                                    source: wpDelegate.filePath ? `file://${wpDelegate.filePath}` : ""
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    cache: false
                                    sourceSize.width: wallpaperGroup.itemWidth * 2
                                    sourceSize.height: wallpaperGroup.itemHeight * 2

                                    layer.enabled: Appearance.effectsEnabled
                                    layer.effect: GE.OpacityMask {
                                        maskSource: Rectangle {
                                            width: wpThumb.width
                                            height: wpThumb.height
                                            radius: wpThumb.radius
                                        }
                                    }
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    radius: parent.radius
                                    color: wpDelegate.isHovered && !wpDelegate.isCurrentWallpaper ? "#50000000" : "transparent"
                                }

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 28; height: 28
                                    radius: 14
                                    color: Appearance.colors.colPrimary
                                    visible: wpDelegate.isCurrentWallpaper
                                    scale: wpDelegate.isCurrentWallpaper ? 1 : 0
                                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                                    MaterialSymbol {
                                        anchors.centerIn: parent
                                        text: "check"
                                        iconSize: 18
                                        color: Appearance.colors.colOnPrimary
                                    }
                                }

                                MouseArea {
                                    id: wpMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        Wallpapers.select(wpDelegate.filePath)
                                    }
                                }
                            }
                        }
                    }

                    ScrollEdgeFade {
                        target: wallpaperCarousel
                        vertical: false
                    }
                }

                // Empty state
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: wallpaperGroup.itemHeight + 16
                    visible: wallpaperGroup.wallpapersList.length === 0
                    radius: Appearance.rounding.small
                    color: Appearance.colors.colLayer2

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        MaterialSymbol { Layout.alignment: Qt.AlignHCenter; text: "image"; iconSize: 24; color: Appearance.colors.colSubtext }
                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: Translation.tr("No wallpapers found in ~/Pictures/Wallpapers").replace("~/Pictures/Wallpapers", Directories.shortHomePath(Directories.wallpapersPath))
                            color: Appearance.colors.colSubtext
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }
                    }
                }
            }
        }

        Item { Layout.preferredHeight: 16 }
        }
    }

    component LayoutContent: Flickable {
        id: layoutFlickable
        width: root.stepWidth
        contentHeight: layoutColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        bottomMargin: 16
        topMargin: Math.max(0, (height - contentHeight - 16) / 2)

        ColumnLayout {
            id: layoutColumn
            width: parent.width
            spacing: root.compact ? 12 : 16

        GridLayout {
            Layout.alignment: Qt.AlignHCenter
            columns: 2
            columnSpacing: 20
            rowSpacing: 16

            // Material II bar position. Waffle owns `waffles.bar.bottom`.
            SettingsGroup {
                Layout.preferredWidth: 260
                visible: (Config.options?.panelFamily ?? "ii") === "ii"
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    RowLayout {
                        MaterialSymbol { text: "web_asset"; iconSize: 18; color: Appearance.colors.colPrimary }
                        StyledText {
                            text: "Material II · " + Translation.tr("Bar")
                            font.pixelSize: Appearance.font.pixelSize.small
                        }
                    }
                    ConfigSelectionArray {
                        Layout.fillWidth: true
                        currentValue: Config.options?.bar?.bottom ?? false
                        onSelected: v => root.setExperienceFeature("bar.bottom", v)
                        options: [
                            { displayName: Translation.tr("Top"), icon: "vertical_align_top", value: false },
                            { displayName: Translation.tr("Bottom"), icon: "vertical_align_bottom", value: true }
                        ]
                    }
                }
            }

            // Material II dock position. Waffle family modules are independent.
            SettingsGroup {
                Layout.preferredWidth: 260
                visible: (Config.options?.panelFamily ?? "ii") === "ii"
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    RowLayout {
                        MaterialSymbol { text: "dock_to_bottom"; iconSize: 18; color: Appearance.colors.colPrimary }
                        StyledText {
                            text: "Material II · " + Translation.tr("Dock")
                            font.pixelSize: Appearance.font.pixelSize.small
                        }
                    }
                    ConfigSelectionArray {
                        Layout.fillWidth: true
                        currentValue: Config.options?.dock?.position ?? "bottom"
                        onSelected: v => root.setExperienceFeature("dock.position", v)
                        options: [
                            { displayName: Translation.tr("Top"), icon: "arrow_upward", value: "top" },
                            { displayName: Translation.tr("Bottom"), icon: "arrow_downward", value: "bottom" },
                            { displayName: Translation.tr("Left"), icon: "arrow_back", value: "left" },
                            { displayName: Translation.tr("Right"), icon: "arrow_forward", value: "right" }
                        ]
                    }
                }
            }

            // Selects which family starts active. Both family configurations
            // remain stored and switching later does not reset either one.
            SettingsGroup {
                Layout.columnSpan: 2
                Layout.fillWidth: true
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    RowLayout {
                        MaterialSymbol { text: "view_quilt"; iconSize: 18; color: Appearance.colors.colPrimary }
                        StyledText { text: Translation.tr("Panel family"); font.pixelSize: Appearance.font.pixelSize.small }
                    }
                    ConfigSelectionArray {
                        Layout.fillWidth: true
                        currentValue: Config.options?.panelFamily ?? "ii"
                        onSelected: v => root.setExperienceFeature("panelFamily", v)
                        options: [
                            { displayName: "Material II", icon: "dashboard", value: "ii" },
                            { displayName: "Waffle", icon: "grid_view", value: "waffle" }
                        ]
                    }
                }
            }

            // Only the ii horizontal bar reads bar.appearanceStyle.
            SettingsGroup {
                Layout.columnSpan: 2
                Layout.fillWidth: true
                visible: (Config.options?.panelFamily ?? "ii") === "ii"
                    && !(Config.options?.bar?.vertical ?? false)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    RowLayout {
                        MaterialSymbol { text: "wysiwyg"; iconSize: 18; color: Appearance.colors.colPrimary }
                        StyledText {
                            text: "Material II · " + Translation.tr("Bar shape")
                            font.pixelSize: Appearance.font.pixelSize.small
                        }
                        Item { Layout.fillWidth: true }
                        StyledText {
                            text: Translation.tr("Changes how the whole bar reads")
                            font.pixelSize: Appearance.font.pixelSize.smallest
                            color: Appearance.colors.colSubtext
                        }
                    }
                    ConfigSelectionArray {
                        Layout.fillWidth: true
                        currentValue: Config.options?.bar?.appearanceStyle ?? "classic"
                        onSelected: v => root.setExperienceFeature("bar.appearanceStyle", v)
                        options: [
                            { displayName: Translation.tr("Classic"), icon: "horizontal_rule", value: "classic" },
                            { displayName: Translation.tr("Islands"), icon: "view_column", value: "islands" },
                            { displayName: Translation.tr("Scenic"), icon: "gradient", value: "scenic" },
                            { displayName: Translation.tr("Frame"), icon: "crop_free", value: "frame" },
                            { displayName: "Material 3", icon: "widgets", value: "m3" },
                            { displayName: Translation.tr("Pill"), icon: "blur_circular", value: "pill" }
                        ]
                    }
                }
            }
        }

        SettingsGroup {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            visible: (Config.options?.panelFamily ?? "ii") === "ii"

            ConfigSwitch {
                buttonIcon: "dock_to_bottom"
                text: "Material II · " + Translation.tr("Show dock")
                description: Translation.tr("Keep dock visible at all times (Empty workspace mode only)")
                checked: Config.options?.dock?.enable ?? true
                onToggledByUser: checked => root.setExperienceFeature("dock.enable", checked)
            }
            ConfigSwitch {
                buttonIcon: "dashboard"
                text: "Material II · " + Translation.tr("Show dashboard")
                description: Translation.tr("Keep a centered home panel for notifications, media, weather and daily controls.")
                checked: Config.options?.dashboard?.enable ?? true
                onToggledByUser: checked => root.setExperienceFeature("dashboard.enable", checked)
            }
            ConfigSwitch {
                buttonIcon: "auto_awesome_motion"
                text: "Material II · " + Translation.tr("Auto-hide the bar")
                description: Translation.tr("A quieter desktop; the bar returns from the edge or while holding Super.")
                checked: Config.options?.bar?.autoHide?.enable ?? false
                onToggledByUser: checked => root.setExperienceFeature("bar.autoHide.enable", checked)
            }
        }

        SettingsGroup {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            visible: (Config.options?.panelFamily ?? "ii") === "waffle"

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                StyledText {
                    text: Translation.tr("Waffle layout")
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.Medium
                }

                ConfigSelectionArray {
                    Layout.fillWidth: true
                    currentValue: Config.options?.waffles?.bar?.bottom ?? true
                    onSelected: value => root.setExperienceFeature("waffles.bar.bottom", value)
                    options: [
                        { displayName: Translation.tr("Top bar"), icon: "vertical_align_top", value: false },
                        { displayName: Translation.tr("Bottom bar"), icon: "vertical_align_bottom", value: true }
                    ]
                }

                ConfigSelectionArray {
                    Layout.fillWidth: true
                    currentValue: Config.options?.waffles?.startMenu?.sizePreset ?? "normal"
                    onSelected: value => root.setExperienceFeature("waffles.startMenu.sizePreset", value)
                    options: [
                        { displayName: Translation.tr("Compact"), icon: "view_compact", value: "compact" },
                        { displayName: Translation.tr("Normal"), icon: "grid_view", value: "normal" },
                        { displayName: Translation.tr("Large"), icon: "view_module", value: "large" },
                        { displayName: Translation.tr("Wide"), icon: "view_week", value: "wide" }
                    ]
                }

                ConfigSelectionArray {
                    Layout.fillWidth: true
                    currentValue: Config.options?.waffles?.taskView?.mode ?? "centered"
                    onSelected: value => root.setExperienceFeature("waffles.taskView.mode", value)
                    options: [
                        { displayName: Translation.tr("Centered task view"), icon: "filter_center_focus", value: "centered" },
                        { displayName: Translation.tr("Carousel task view"), icon: "view_carousel", value: "carousel" }
                    ]
                }

                ConfigSwitch {
                    buttonIcon: "schedule"
                    text: Translation.tr("Wallpaper clock")
                    checked: Config.options?.waffles?.background?.widgets?.clock?.enable ?? false
                    onToggledByUser: checked => root.setExperienceFeature("waffles.background.widgets.clock.enable", checked)
                }
                ConfigSwitch {
                    buttonIcon: "widgets"
                    text: Translation.tr("Widgets panel")
                    checked: Config.options?.waffles?.modules?.widgets ?? true
                    onToggledByUser: checked => root.setExperienceFeature("waffles.modules.widgets", checked)
                }
            }
        }
        }
    }

    component FeaturesContent: Flickable {
        id: featuresFlickable
        width: root.stepWidth
        contentHeight: featuresColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        bottomMargin: 16
        topMargin: Math.max(0, (height - contentHeight - 16) / 2)

        ColumnLayout {
            id: featuresColumn
            width: parent.width
            spacing: 16

            Item { Layout.preferredHeight: 4 }

            SettingsGroup {
                Layout.fillWidth: true
                Layout.maximumWidth: 600
                Layout.alignment: Qt.AlignHCenter

                RowLayout {
                    Layout.fillWidth: true

                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr("Choose your iNiR experience")
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.weight: Font.Medium
                        color: Appearance.colors.colOnLayer1
                    }

                    StyledText {
                        text: Translation.tr("Material is the fresh-install default")
                        font.pixelSize: Appearance.font.pixelSize.smallest
                        color: Appearance.colors.colPrimary
                    }
                }

                ConfigSelectionArray {
                    Layout.fillWidth: true
                    currentValue: root.selectedExperiencePreset
                    options: root.experiencePresets.map(preset => ({
                        displayName: preset.name,
                        icon: preset.icon,
                        value: preset.id
                    }))
                    onSelected: value => root.applyExperiencePreset(value)
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: profileSummaryColumn.implicitHeight + 20
                    radius: Appearance.inirEverywhere ? Appearance.inir.roundingNormal : Appearance.rounding.small
                    color: root.experienceCustomized
                        ? Appearance.colors.colLayer2
                        : Appearance.colors.colPrimaryContainer
                    border.width: 1
                    border.color: root.experienceCustomized
                        ? Appearance.colors.colOutlineVariant
                        : Appearance.colors.colPrimary

                    RowLayout {
                        anchors {
                            fill: parent
                            margins: 10
                        }
                        spacing: 10

                        MaterialSymbol {
                            text: root.experienceCustomized ? "tune" : "check_circle"
                            iconSize: 20
                            color: root.experienceCustomized
                                ? Appearance.colors.colPrimary
                                : Appearance.colors.colOnPrimaryContainer
                        }

                        ColumnLayout {
                            id: profileSummaryColumn
                            Layout.fillWidth: true
                            spacing: 2

                            StyledText {
                                Layout.fillWidth: true
                                text: root.experienceCustomized
                                    ? Translation.tr("Custom setup")
                                    : root.currentExperiencePreset.name
                                font.pixelSize: Appearance.font.pixelSize.small
                                font.weight: Font.Medium
                                color: root.experienceCustomized
                                    ? Appearance.colors.colOnSurface
                                    : Appearance.colors.colOnPrimaryContainer
                            }
                            StyledText {
                                Layout.fillWidth: true
                                text: root.currentExperienceDescription
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: root.experienceCustomized
                                    ? Appearance.colors.colSubtext
                                    : Appearance.colors.colOnPrimaryContainer
                                wrapMode: Text.WordWrap
                            }
                            StyledText {
                                Layout.fillWidth: true
                                text: root.experienceCustomized
                                    ? Translation.tr("Choose an experience above again to restore its complete composition.")
                                    : Translation.tr("This preset configures the bar, dock, sidebars, their content, dashboard/control surfaces and desktop widgets together.")
                                font.pixelSize: Appearance.font.pixelSize.smallest
                                color: root.experienceCustomized
                                    ? Appearance.colors.colSubtext
                                    : Appearance.colors.colOnPrimaryContainer
                                opacity: 0.8
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }
            }

            SettingsGroup {
                Layout.fillWidth: true
                Layout.maximumWidth: 600
                Layout.alignment: Qt.AlignHCenter

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        MaterialSymbol { text: "speed"; iconSize: 20; color: Appearance.colors.colPrimary }
                        StyledText {
                            Layout.fillWidth: true
                            text: Translation.tr("Graphics budget")
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: Font.Medium
                        }
                        StyledText {
                            text: root.effectivePerformancePreset === "custom"
                                ? Translation.tr("Custom") : root.currentPerformancePreset.name
                            font.pixelSize: Appearance.font.pixelSize.smallest
                            color: Appearance.colors.colPrimary
                        }
                    }

                    ConfigSelectionArray {
                        Layout.fillWidth: true
                        currentValue: root.effectivePerformancePreset
                        onSelected: value => root.applyPerformancePreset(value)
                        options: root.performancePresets.map(preset => ({
                            displayName: preset.name,
                            icon: preset.icon,
                            value: preset.id
                        }))
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: root.currentPerformancePresetDescription
                        color: Appearance.colors.colSubtext
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.maximumWidth: 600
                Layout.alignment: Qt.AlignHCenter
                spacing: 20

                SettingsGroup {
                    Layout.fillWidth: true

                    ConfigSwitch {
                        buttonIcon: "notifications_active"
                        text: Translation.tr("Notification sounds")
                        description: Translation.tr("Keep the desktop silent, or add subtle feedback for notifications.")
                        checked: Config.options?.sounds?.notifications ?? false
                        onToggledByUser: checked => root.setExperienceFeature("sounds.notifications", checked)
                    }
                    ConfigSwitch {
                        buttonIcon: "sports_esports"
                        text: Translation.tr("Automatic game mode")
                        description: Translation.tr("Pauses expensive effects while a fullscreen game is active.")
                        checked: Config.options?.gameMode?.autoDetect ?? true
                        onToggledByUser: checked => root.setExperienceFeature("gameMode.autoDetect", checked)
                    }
                    ConfigSwitch {
                        buttonIcon: "schedule"
                        text: Translation.tr("Desktop clock")
                        description: Translation.tr("Adds a quiet clock to the wallpaper. The bar clock remains available either way.")
                        checked: Config.getNestedValue("background.widgets.clock.enable", false)
                        onToggledByUser: checked => root.setExperienceFeature("background.widgets.clock.enable", checked)
                    }
                }

                SettingsGroup {
                    Layout.fillWidth: true

                    ConfigSwitch {
                        buttonIcon: "cloud"
                        text: Translation.tr("Weather")
                        description: Translation.tr("Shows weather in the bar and glance cards after location resolves.")
                        checked: (Config.options?.bar?.weather?.enable ?? false)
                            && (Config.options?.bar?.modules?.weather ?? false)
                        onToggledByUser: checked => {
                            root.experienceCustomized = true
                            Config.setNestedValues({
                                "bar.weather.enable": checked,
                                "bar.modules.weather": checked
                            })
                        }
                    }
                    ConfigSwitch {
                        buttonIcon: "bolt"
                        text: Translation.tr("Reduce animations")
                        description: Translation.tr("Calmer motion and less graphics work on slower hardware.")
                        checked: Config.options?.performance?.reduceAnimations ?? false
                        onToggledByUser: checked => Config.setNestedValue("performance.reduceAnimations", checked)
                    }
                    ConfigSwitch {
                        buttonIcon: "hearing"
                        text: Translation.tr("Volume protection")
                        description: Translation.tr("Prevents sudden output jumps without changing normal volume control.")
                        checked: Config.options?.audio?.protection?.enable ?? true
                        onToggledByUser: checked => root.setExperienceFeature("audio.protection.enable", checked)
                    }
                }
            }

            SettingsGroup {
                Layout.fillWidth: true
                Layout.maximumWidth: 600
                Layout.alignment: Qt.AlignHCenter

                ConfigSwitch {
                    buttonIcon: "pets"
                    text: Translation.tr("Kira, the desktop companion")
                    description: Translation.tr("iNiR's mascot peeks in from the screen edges and reacts to what you do. Purely decorative, and she never takes focus.")
                    checked: Config.options?.mascot?.enable ?? false
                    onToggledByUser: checked => root.setExperienceFeature("mascot.enable", checked)
                }
            }

        }
    }

    component ReadyContent: Flickable {
        id: readyFlickable
        width: root.stepWidth
        contentHeight: readyColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        bottomMargin: 16
        topMargin: Math.max(0, (height - contentHeight - 16) / 2)

        ColumnLayout {
            id: readyColumn
            width: parent.width
            spacing: 18

            Item { Layout.preferredHeight: 4 }

            MaterialShapeWrappedMaterialSymbol {
                Layout.alignment: Qt.AlignHCenter
                text: "check_circle"
                iconSize: 50
                padding: 16
                shape: MaterialShape.Shape.Circle
                color: Appearance.colors.colPrimaryContainer
                colSymbol: Appearance.colors.colOnPrimaryContainer
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: 540
                horizontalAlignment: Text.AlignHCenter
                text: Translation.tr("Four shortcuts cover most daily navigation. The full list is always one key away.")
                color: Appearance.colors.colSubtext
                wrapMode: Text.WordWrap
            }

            // Two cards side by side: shortcuts + first actions
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 8
                Layout.maximumWidth: 700
                spacing: 14

                // Keyboard shortcuts card
                Rectangle {
                    Layout.preferredWidth: 340
                    Layout.alignment: Qt.AlignTop
                    implicitHeight: shortcutsCardCol.implicitHeight + 24
                    radius: Appearance.inirEverywhere ? Appearance.inir.roundingNormal : Appearance.rounding.normal
                    color: Appearance.inirEverywhere ? Appearance.inir.colLayer2
                         : Appearance.auroraEverywhere ? ColorUtils.transparentize(Appearance.colors.colLayer2, 0.5)
                         : Appearance.colors.colLayer2
                    border.width: Appearance.inirEverywhere ? 1 : 0
                    border.color: Appearance.inir.colBorderSubtle

                    ColumnLayout {
                        id: shortcutsCardCol
                        anchors {
                            fill: parent
                            margins: 12
                        }
                        spacing: 10

                        RowLayout {
                            spacing: 8
                            MaterialSymbol { text: "keyboard"; iconSize: 18; color: Appearance.colors.colPrimary }
                            StyledText {
                                text: Translation.tr("Keyboard")
                                font.pixelSize: Appearance.font.pixelSize.small
                                font.weight: Font.Medium
                            }
                            Item { Layout.fillWidth: true }
                            StyledText {
                                text: Translation.tr("Press Super+/ for full list")
                                font.pixelSize: Appearance.font.pixelSize.smallest
                                color: Appearance.colors.colSubtext
                            }
                        }

                        Repeater {
                            model: [
                                { keys: "Super+/",     desc: Translation.tr("All shortcuts") },
                                { keys: "Super+Space", desc: Translation.tr("App launcher") },
                                { keys: "Super+,",     desc: Translation.tr("Settings") },
                                { keys: "Super+V",     desc: Translation.tr("Clipboard history") }
                            ]
                            RowLayout {
                                Layout.fillWidth: true
                                required property var modelData
                                spacing: 10

                                Row {
                                    spacing: 2
                                    Repeater {
                                        model: modelData.keys.split("+")
                                        KeyboardKey {
                                            required property string modelData
                                            key: modelData
                                        }
                                    }
                                }
                                Item { Layout.fillWidth: true }
                                StyledText {
                                    text: modelData.desc
                                    font.pixelSize: Appearance.font.pixelSize.smaller
                                    color: Appearance.colors.colSubtext
                                }
                            }
                        }
                    }
                }

                // Try it now — interactive action card
                Rectangle {
                    Layout.preferredWidth: 340
                    Layout.alignment: Qt.AlignTop
                    implicitHeight: tryItCardCol.implicitHeight + 24
                    radius: Appearance.inirEverywhere ? Appearance.inir.roundingNormal : Appearance.rounding.normal
                    color: Appearance.inirEverywhere ? Appearance.inir.colLayer2
                         : Appearance.auroraEverywhere ? ColorUtils.transparentize(Appearance.colors.colLayer2, 0.5)
                         : Appearance.colors.colLayer2
                    border.width: Appearance.inirEverywhere ? 1 : 0
                    border.color: Appearance.inir.colBorderSubtle

                    ColumnLayout {
                        id: tryItCardCol
                        anchors {
                            fill: parent
                            margins: 12
                        }
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            MaterialSymbol { text: "rocket_launch"; iconSize: 18; color: Appearance.colors.colPrimary }
                            StyledText {
                                text: Translation.tr("Try it now")
                                font.pixelSize: Appearance.font.pixelSize.small
                                font.weight: Font.Medium
                            }
                            Item { Layout.fillWidth: true }
                            StyledText {
                                text: Translation.tr("one click, no typing")
                                font.pixelSize: Appearance.font.pixelSize.smallest
                                color: Appearance.colors.colSubtext
                            }
                        }

                        Repeater {
                            model: [
                                {
                                    icon: "tune",
                                    label: Translation.tr("Open quick settings"),
                                    sub: Translation.tr("Wi-Fi, audio, brightness"),
                                    target: "controlPanel",
                                    fn: "toggle"
                                },
                                {
                                    icon: "wallpaper",
                                    label: Translation.tr("Pick a wallpaper"),
                                    sub: Translation.tr("Browse and apply"),
                                    target: "wallpaperSelector",
                                    fn: "toggle"
                                },
                                {
                                    icon: "keyboard",
                                    label: Translation.tr("Show all shortcuts"),
                                    sub: Translation.tr("Cheatsheet overlay"),
                                    target: "cheatsheet",
                                    fn: "toggle"
                                }
                            ]
                            RippleButton {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 46
                                required property var modelData
                                buttonRadius: Appearance.rounding.small
                                colBackground: Appearance.colors.colLayer1
                                colBackgroundHover: Appearance.colors.colLayer1Hover

                                onClicked: Quickshell.execDetached([
                                    Quickshell.shellPath("scripts/inir"),
                                    modelData.target,
                                    modelData.fn
                                ])

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    spacing: 10

                                    MaterialSymbol {
                                        text: modelData.icon
                                        iconSize: 22
                                        color: Appearance.colors.colPrimary
                                        Layout.preferredWidth: 26
                                    }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 0
                                        StyledText {
                                            Layout.fillWidth: true
                                            text: modelData.label
                                            font.pixelSize: Appearance.font.pixelSize.small
                                            font.weight: Font.Medium
                                            color: Appearance.colors.colOnLayer1
                                            elide: Text.ElideRight
                                        }
                                        StyledText {
                                            Layout.fillWidth: true
                                            text: modelData.sub
                                            font.pixelSize: Appearance.font.pixelSize.smallest
                                            color: Appearance.colors.colSubtext
                                            elide: Text.ElideRight
                                        }
                                    }
                                    MaterialSymbol {
                                        text: "arrow_forward"
                                        iconSize: 16
                                        color: Appearance.colors.colSubtext
                                        opacity: 0.6
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Need help? clickable callout — opens troubleshooting wiki
            RippleButton {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 4
                Layout.preferredWidth: 694
                Layout.maximumWidth: 700
                Layout.preferredHeight: helpCalloutRow.implicitHeight + 18
                buttonRadius: Appearance.inirEverywhere ? Appearance.inir.roundingNormal : Appearance.rounding.normal
                colBackground: ColorUtils.transparentize(Appearance.colors.colPrimaryContainer, 0.6)
                colBackgroundHover: ColorUtils.transparentize(Appearance.colors.colPrimaryContainer, 0.4)

                onClicked: Qt.openUrlExternally("https://github.com/snowarch/inir/wiki/Troubleshooting")

                Rectangle {
                    anchors.fill: parent
                    radius: parent.buttonRadius
                    color: "transparent"
                    border.width: 1
                    border.color: ColorUtils.transparentize(Appearance.colors.colPrimary, 0.6)
                }

                RowLayout {
                    id: helpCalloutRow
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    anchors.topMargin: 9
                    anchors.bottomMargin: 9
                    spacing: 10

                    MaterialSymbol {
                        text: "support"
                        iconSize: 20
                        color: Appearance.colors.colOnPrimaryContainer
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        StyledText {
                            Layout.fillWidth: true
                            text: Translation.tr("Something not working?")
                            font.pixelSize: Appearance.font.pixelSize.small
                            font.weight: Font.Medium
                            color: Appearance.colors.colOnPrimaryContainer
                            elide: Text.ElideRight
                        }
                        StyledText {
                            Layout.fillWidth: true
                            text: Translation.tr("Open the troubleshooting guide — common fixes, in plain English.")
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: ColorUtils.transparentize(Appearance.colors.colOnPrimaryContainer, 0.2)
                            wrapMode: Text.WordWrap
                        }
                    }
                    MaterialSymbol {
                        text: "open_in_new"
                        iconSize: 16
                        color: ColorUtils.transparentize(Appearance.colors.colOnPrimaryContainer, 0.3)
                    }
                }
            }

            // Quick actions
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 8
                spacing: 10

                RippleButton {
                    implicitWidth: settingsChipRow.implicitWidth + 32
                    implicitHeight: 38
                    buttonRadius: Appearance.rounding.small
                    colBackground: Appearance.colors.colLayer2
                    colBackgroundHover: Appearance.colors.colLayer2Hover
                    onClicked: Quickshell.execDetached([Quickshell.shellPath("scripts/inir"), "settings"])
                    RowLayout {
                        id: settingsChipRow
                        anchors.centerIn: parent
                        spacing: 8
                        MaterialSymbol { text: "settings"; iconSize: 16 }
                        StyledText { text: Translation.tr("Settings"); font.pixelSize: Appearance.font.pixelSize.small }
                    }
                }

                RippleButton {
                    implicitWidth: docsChipRow.implicitWidth + 32
                    implicitHeight: 38
                    buttonRadius: Appearance.rounding.small
                    colBackground: Appearance.colors.colLayer2
                    colBackgroundHover: Appearance.colors.colLayer2Hover
                    onClicked: Qt.openUrlExternally("https://github.com/snowarch/inir/wiki")
                    RowLayout {
                        id: docsChipRow
                        anchors.centerIn: parent
                        spacing: 8
                        MaterialSymbol { text: "menu_book"; iconSize: 16 }
                        StyledText { text: Translation.tr("Documentation"); font.pixelSize: Appearance.font.pixelSize.small }
                    }
                }

                RippleButton {
                    implicitWidth: issueChipRow.implicitWidth + 32
                    implicitHeight: 38
                    buttonRadius: Appearance.rounding.small
                    colBackground: Appearance.colors.colLayer2
                    colBackgroundHover: Appearance.colors.colLayer2Hover
                    onClicked: Qt.openUrlExternally("https://github.com/snowarch/inir/issues")
                    RowLayout {
                        id: issueChipRow
                        anchors.centerIn: parent
                        spacing: 8
                        MaterialSymbol { text: "bug_report"; iconSize: 16 }
                        StyledText { text: Translation.tr("Report issue"); font.pixelSize: Appearance.font.pixelSize.small }
                    }
                }

            }

            Item { Layout.preferredHeight: 8 }
        }
    }
}
