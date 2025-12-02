pragma ComponentBehavior: Bound

import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions as CF
import qs.modules.common.widgets
import qs.modules.background.widgets.clock
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Variants {
    id: root
    model: Quickshell.screens

    PanelWindow {
        id: panelRoot
        required property var modelData

        screen: modelData
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.namespace: "quickshell:wBackground"
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: "transparent"

        // Wallpaper dimensions
        property int wallpaperWidth: modelData.width
        property int wallpaperHeight: modelData.height
        property real wallpaperToScreenRatio: Math.min(wallpaperWidth / screen.width, wallpaperHeight / screen.height)
        property real preferredWallpaperScale: Config.options.background.parallax.workspaceZoom
        property real effectiveWallpaperScale: 1
        property real movableXSpace: ((wallpaperWidth / wallpaperToScreenRatio * effectiveWallpaperScale) - screen.width) / 2
        property real movableYSpace: ((wallpaperHeight / wallpaperToScreenRatio * effectiveWallpaperScale) - screen.height) / 2
        readonly property bool verticalParallax: (Config.options.background.parallax.autoVertical && wallpaperHeight > wallpaperWidth) || Config.options.background.parallax.vertical

        // Dynamic focus: blur + dim based on windows
        property bool hasWindowsOnCurrentWorkspace: {
            try {
                if (CompositorService.isNiri && typeof NiriService !== "undefined" && NiriService.windows && NiriService.workspaces) {
                    const allWs = Object.values(NiriService.workspaces);
                    if (!allWs || allWs.length === 0) return false;
                    const currentNumber = NiriService.getCurrentWorkspaceNumber();
                    const currentWs = allWs.find(ws => ws.idx === currentNumber);
                    if (!currentWs) return false;
                    return NiriService.windows.some(w => w.workspace_id === currentWs.id);
                }
                return false;
            } catch (e) { return false; }
        }

        property bool focusWindowsPresent: !GlobalStates.screenLocked && hasWindowsOnCurrentWorkspace
        property real focusPresenceProgress: focusWindowsPresent ? 1 : 0
        Behavior on focusPresenceProgress {
            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
        }

        // Backdrop active only in overview mode
        property bool backdropActive: Config.options.background.backdrop.enable && GlobalStates.overviewOpen

        property real blurProgress: {
            if (!(Config.options.background.effects.enableBlur && Config.options.background.effects.blurRadius > 0)) return 0;
            const base = Math.max(0, Math.min(100, Number(Config.options.background.effects.blurStatic) || 0));
            const total = (base + (100 - base) * focusPresenceProgress) / 100;
            return Math.max(0, Math.min(1, total));
        }

        function updateZoomScale() {
            getWallpaperSizeProc.path = content.effectiveSource().replace("file://", "");
            getWallpaperSizeProc.running = true;
        }

        Process {
            id: getWallpaperSizeProc
            property string path: ""
            command: ["magick", "identify", "-format", "%w %h", path]
            stdout: StdioCollector {
                onStreamFinished: {
                    const output = text;
                    const parts = output.split(" ").map(Number);
                    if (parts.length >= 2) {
                        panelRoot.wallpaperWidth = parts[0];
                        panelRoot.wallpaperHeight = parts[1];
                        const [sw, sh] = [panelRoot.screen.width, panelRoot.screen.height];
                        if (parts[0] <= sw || parts[1] <= sh) {
                            panelRoot.effectiveWallpaperScale = Math.max(sw / parts[0], sh / parts[1]);
                        } else {
                            panelRoot.effectiveWallpaperScale = Math.min(panelRoot.preferredWallpaperScale, parts[0] / sw, parts[1] / sh);
                        }
                    }
                }
            }
        }

        Item {
            id: content
            anchors.fill: parent
            clip: true

            property string source: Config.options.background.backdrop.useMainWallpaper
                                      ? Config.options.background.wallpaperPath
                                      : (Config.options.background.backdrop.wallpaperPath || Config.options.background.wallpaperPath)
            property bool isColorSource: source.startsWith("#")

            function effectiveSource() {
                if (!source || isColorSource) return ""
                return source.startsWith("file://") ? source : "file://" + source
            }

            onSourceChanged: panelRoot.updateZoomScale()
            Component.onCompleted: panelRoot.updateZoomScale()

            Image {
                id: wallpaper
                asynchronous: true
                smooth: true
                cache: true
                fillMode: Image.PreserveAspectCrop
                source: content.effectiveSource()
                visible: content.source !== "" && !content.isColorSource && !blurEffect.visible

                // Parallax positioning
                property int chunkSize: Config?.options.bar.workspaces.shown ?? 10
                property int lower: 0
                property int upper: chunkSize
                property int range: Math.max(1, upper - lower)
                property real valueX: {
                    let result = 0.5;
                    if (Config.options.background.parallax.enableWorkspace && !panelRoot.verticalParallax) {
                        const wsId = CompositorService.isNiri ? (NiriService.focusedWorkspaceIndex ?? 1) : 1;
                        result = ((wsId - lower) / range);
                    }
                    if (Config.options.background.parallax.enableSidebar) {
                        result += (0.15 * GlobalStates.sidebarRightOpen - 0.15 * GlobalStates.sidebarLeftOpen);
                    }
                    return result;
                }
                property real valueY: {
                    let result = 0.5;
                    if (Config.options.background.parallax.enableWorkspace && panelRoot.verticalParallax) {
                        const wsId = CompositorService.isNiri ? (NiriService.focusedWorkspaceIndex ?? 1) : 1;
                        result = ((wsId - lower) / range);
                    }
                    return result;
                }
                property real effectiveValueX: Math.max(0, Math.min(1, valueX))
                property real effectiveValueY: Math.max(0, Math.min(1, valueY))

                x: -(panelRoot.movableXSpace) - (effectiveValueX - 0.5) * 2 * panelRoot.movableXSpace
                y: -(panelRoot.movableYSpace) - (effectiveValueY - 0.5) * 2 * panelRoot.movableYSpace
                Behavior on x { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
                Behavior on y { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }

                sourceSize {
                    width: panelRoot.screen.width * panelRoot.effectiveWallpaperScale
                    height: panelRoot.screen.height * panelRoot.effectiveWallpaperScale
                }
                width: panelRoot.wallpaperWidth / panelRoot.wallpaperToScreenRatio * panelRoot.effectiveWallpaperScale
                height: panelRoot.wallpaperHeight / panelRoot.wallpaperToScreenRatio * panelRoot.effectiveWallpaperScale
            }

            // Blur effect layer
            MultiEffect {
                id: blurEffect
                anchors.fill: wallpaper
                x: wallpaper.x
                y: wallpaper.y
                width: wallpaper.width
                height: wallpaper.height
                source: wallpaper
                visible: Appearance.effectsEnabled && (panelRoot.blurProgress > 0 || panelRoot.backdropActive)
                blurEnabled: visible
                blur: {
                    const dynamicBlur = panelRoot.blurProgress * (Config.options.background.effects.blurRadius / 100.0);
                    const backdropBlur = panelRoot.backdropActive ? (Config.options.background.backdrop.blurRadius / 100.0) : 0;
                    return Math.max(dynamicBlur, backdropBlur);
                }
                blurMax: 64
                saturation: Appearance.effectsEnabled && panelRoot.backdropActive ? Config.options.background.backdrop.saturation : 0
                contrast: panelRoot.backdropActive ? Config.options.background.backdrop.contrast : 0
                Behavior on blur { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
            }

            // Dim overlay
            Rectangle {
                anchors.fill: parent
                color: {
                    const baseN = Number(Config?.options?.background?.effects?.dim) || 0;
                    const dynN = Number(Config?.options?.background?.effects?.dynamicDim) || 0;
                    const backdropDim = panelRoot.backdropActive ? (Config.options.background.backdrop.dim || 0) : 0;
                    const extra = (!GlobalStates.screenLocked && panelRoot.focusPresenceProgress > 0) ? dynN * panelRoot.focusPresenceProgress : 0;
                    const total = Math.max(0, Math.min(100, baseN + extra + backdropDim));
                    return Qt.rgba(0, 0, 0, total / 100);
                }
                Behavior on color { ColorAnimation { duration: 220 } }
            }

            // Vignette
            Item {
                anchors.fill: parent
                visible: panelRoot.backdropActive && Config.options.background.backdrop.vignetteEnabled
                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: Config.options.background.backdrop.vignetteRadius; color: "transparent" }
                        GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, Config.options.background.backdrop.vignetteIntensity) }
                    }
                }
            }

            // Clock widget
            Loader {
                active: Config.options.background.widgets.clock.enable
                anchors.fill: parent
                sourceComponent: Component {
                    ClockWidget {
                        screenWidth: panelRoot.screen.width
                        screenHeight: panelRoot.screen.height
                        scaledScreenWidth: panelRoot.screen.width / panelRoot.effectiveWallpaperScale
                        scaledScreenHeight: panelRoot.screen.height / panelRoot.effectiveWallpaperScale
                        wallpaperScale: panelRoot.effectiveWallpaperScale
                        wallpaperSafetyTriggered: false
                    }
                }
            }
        }
    }
}
