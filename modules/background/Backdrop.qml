pragma ComponentBehavior: Bound

import qs
import qs.modules.common
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland

Variants {
    id: root
    model: Quickshell.screens

    PanelWindow {
        id: backdropWindow
        required property var modelData

        screen: modelData

        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.namespace: "dms:blurwallpaper"
        WlrLayershell.exclusionMode: ExclusionMode.Ignore

        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true

        color: "transparent"

        // Determine which config to use based on panel family
        readonly property bool isWaffleMode: Config.options?.panelFamily === "waffle"
        
        // Individual properties that read from the correct config
        readonly property bool backdropEnabled: isWaffleMode 
            ? (Config.options?.waffles?.background?.backdrop?.enable ?? false)
            : (Config.options?.background?.backdrop?.enable ?? false)
            
        readonly property bool backdropUseMainWallpaper: isWaffleMode
            ? (Config.options?.waffles?.background?.backdrop?.useMainWallpaper ?? true)
            : (Config.options?.background?.backdrop?.useMainWallpaper ?? true)
            
        readonly property string backdropWallpaperPath: isWaffleMode
            ? (Config.options?.waffles?.background?.backdrop?.wallpaperPath ?? "")
            : (Config.options?.background?.backdrop?.wallpaperPath ?? "")
            
        readonly property int backdropBlurRadius: isWaffleMode
            ? (Config.options?.waffles?.background?.backdrop?.blurRadius ?? 32)
            : (Config.options?.background?.backdrop?.blurRadius ?? 32)
            
        readonly property int backdropDim: isWaffleMode
            ? (Config.options?.waffles?.background?.backdrop?.dim ?? 35)
            : (Config.options?.background?.backdrop?.dim ?? 35)
            
        readonly property real backdropSaturation: isWaffleMode
            ? (Config.options?.waffles?.background?.backdrop?.saturation ?? 1.0)
            : (Config.options?.background?.backdrop?.saturation ?? 1.0)
            
        readonly property real backdropContrast: isWaffleMode
            ? (Config.options?.waffles?.background?.backdrop?.contrast ?? 1.0)
            : (Config.options?.background?.backdrop?.contrast ?? 1.0)
            
        readonly property bool backdropVignetteEnabled: isWaffleMode
            ? (Config.options?.waffles?.background?.backdrop?.vignetteEnabled ?? false)
            : (Config.options?.background?.backdrop?.vignetteEnabled ?? false)
            
        readonly property real backdropVignetteIntensity: isWaffleMode
            ? (Config.options?.waffles?.background?.backdrop?.vignetteIntensity ?? 0.5)
            : (Config.options?.background?.backdrop?.vignetteIntensity ?? 0.5)
            
        readonly property real backdropVignetteRadius: isWaffleMode
            ? (Config.options?.waffles?.background?.backdrop?.vignetteRadius ?? 0.7)
            : (Config.options?.background?.backdrop?.vignetteRadius ?? 0.7)
        
        // Get the effective wallpaper path for backdrop
        readonly property string effectiveWallpaperPath: {
            if (backdropUseMainWallpaper) {
                // For Waffle: check if Waffle has its own wallpaper
                if (isWaffleMode) {
                    const waffleBg = Config.options?.waffles?.background;
                    if (waffleBg && !waffleBg.useMainWallpaper && waffleBg.wallpaperPath) {
                        return waffleBg.wallpaperPath;
                    }
                }
                return Config.options?.background?.wallpaperPath ?? "";
            }
            return backdropWallpaperPath || Config.options?.background?.wallpaperPath || "";
        }

        Item {
            id: content
            anchors.fill: parent
            clip: true

            property string source: backdropWindow.effectiveWallpaperPath
            property bool isColorSource: source.startsWith("#")

            function effectiveSource() {
                if (!source || isColorSource)
                    return "";
                return source.startsWith("file://") ? source : "file://" + source;
            }

            Image {
                id: wallpaper
                anchors.fill: parent
                asynchronous: true
                smooth: true
                cache: true
                fillMode: Image.PreserveAspectCrop
                source: content.effectiveSource()
                visible: content.source !== "" && !content.isColorSource
            }

            MultiEffect {
                anchors.fill: parent
                source: wallpaper
                blurEnabled: Appearance.effectsEnabled
                             && backdropWindow.backdropEnabled
                             && backdropWindow.backdropBlurRadius > 0
                blur: backdropWindow.backdropBlurRadius / 100.0
                blurMax: 64
                saturation: Appearance.effectsEnabled ? (backdropWindow.backdropSaturation - 1.0) : 0
                contrast: backdropWindow.backdropContrast - 1.0
            }

            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: Math.max(0, Math.min(1, backdropWindow.backdropDim / 100.0))
            }

            Item {
                anchors.fill: parent
                visible: backdropWindow.backdropVignetteEnabled

                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: backdropWindow.backdropVignetteRadius; color: "transparent" }
                        GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, backdropWindow.backdropVignetteIntensity) }
                    }
                }
            }
        }
    }
}
