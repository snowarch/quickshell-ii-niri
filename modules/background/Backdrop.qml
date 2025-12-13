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
        WlrLayershell.namespace: "quickshell:iiBackdrop"
        WlrLayershell.exclusionMode: ExclusionMode.Ignore

        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true

        color: "transparent"

        // Material ii backdrop config (independent)
        readonly property var iiBackdrop: Config.options?.background?.backdrop ?? {}
        
        readonly property int backdropBlurRadius: iiBackdrop.blurRadius ?? 32
        readonly property int backdropDim: iiBackdrop.dim ?? 35
        readonly property real backdropSaturation: iiBackdrop.saturation ?? 0
        readonly property real backdropContrast: iiBackdrop.contrast ?? 0
        readonly property bool vignetteEnabled: iiBackdrop.vignetteEnabled ?? false
        readonly property real vignetteIntensity: iiBackdrop.vignetteIntensity ?? 0.5
        readonly property real vignetteRadius: iiBackdrop.vignetteRadius ?? 0.7

        readonly property string effectiveWallpaperPath: {
            const useMain = iiBackdrop.useMainWallpaper ?? true;
            const mainPath = Config.options?.background?.wallpaperPath ?? "";
            const backdropPath = iiBackdrop.wallpaperPath || "";
            return useMain ? mainPath : (backdropPath || mainPath);
        }

        Item {
            anchors.fill: parent

            Image {
                id: wallpaper
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                source: backdropWindow.effectiveWallpaperPath 
                    ? (backdropWindow.effectiveWallpaperPath.startsWith("file://") 
                        ? backdropWindow.effectiveWallpaperPath 
                        : "file://" + backdropWindow.effectiveWallpaperPath)
                    : ""
                asynchronous: true
                cache: true
            }

            MultiEffect {
                id: blurEffect
                anchors.fill: parent
                source: wallpaper
                visible: wallpaper.status === Image.Ready
                blurEnabled: Appearance.effectsEnabled && backdropWindow.backdropBlurRadius > 0
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
