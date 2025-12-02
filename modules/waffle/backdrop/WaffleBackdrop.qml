pragma ComponentBehavior: Bound

import qs
import qs.modules.common
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland

Variants {
    id: root
    // Only create backdrop windows if enabled
    model: (Config.options?.waffles?.background?.backdrop?.enable ?? true) ? Quickshell.screens : []

    PanelWindow {
        id: backdropWindow
        required property var modelData

        screen: modelData

        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.namespace: "quickshell:wBackdrop"
        WlrLayershell.exclusionMode: ExclusionMode.Ignore

        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true

        color: "transparent"

        // Waffle backdrop config
        readonly property var wBackdrop: Config.options?.waffles?.background?.backdrop ?? {}
        
        readonly property int backdropBlurRadius: wBackdrop.blurRadius ?? 32
        readonly property int backdropDim: wBackdrop.dim ?? 35
        readonly property real backdropSaturation: wBackdrop.saturation ?? 1.0
        readonly property real backdropContrast: wBackdrop.contrast ?? 1.0
        readonly property bool vignetteEnabled: wBackdrop.vignetteEnabled ?? false
        readonly property real vignetteIntensity: wBackdrop.vignetteIntensity ?? 0.5
        readonly property real vignetteRadius: wBackdrop.vignetteRadius ?? 0.7

        // Wallpaper path - use main wallpaper or custom backdrop wallpaper
        readonly property string effectiveWallpaperPath: {
            const useMain = wBackdrop.useMainWallpaper ?? true;
            if (useMain) return Config.options?.background?.wallpaperPath ?? "";
            return wBackdrop.wallpaperPath || Config.options?.background?.wallpaperPath || "";
        }

        // Build proper file:// URL
        readonly property string wallpaperUrl: {
            const path = effectiveWallpaperPath;
            if (!path) return "";
            if (path.startsWith("file://")) return path;
            return "file://" + path;
        }

        Item {
            anchors.fill: parent

            Image {
                id: wallpaper
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                source: backdropWindow.wallpaperUrl
                asynchronous: true
                cache: true
            }

            MultiEffect {
                anchors.fill: parent
                source: wallpaper
                visible: wallpaper.status === Image.Ready
                blurEnabled: backdropWindow.backdropBlurRadius > 0
                blur: backdropWindow.backdropBlurRadius / 100.0
                blurMax: 64
                saturation: backdropWindow.backdropSaturation
                contrast: backdropWindow.backdropContrast
            }

            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: backdropWindow.backdropDim / 100.0
            }

            // Vignette effect
            Rectangle {
                anchors.fill: parent
                visible: backdropWindow.vignetteEnabled
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: backdropWindow.vignetteRadius; color: "transparent" }
                    GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, backdropWindow.vignetteIntensity) }
                }
            }
        }
    }
}
