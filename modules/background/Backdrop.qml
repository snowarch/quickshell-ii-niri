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
            }

            MultiEffect {
                id: blurEffect
                anchors.fill: parent
                source: wallpaper
                visible: wallpaper.status === Image.Ready
                blurEnabled: backdropWindow.backdropBlurRadius > 0
                blur: backdropWindow.backdropBlurRadius / 100.0
                blurMax: 64
            }

            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: backdropWindow.backdropDim / 100.0
            }
        }
    }
}
