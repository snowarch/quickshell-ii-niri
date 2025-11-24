pragma ComponentBehavior: Bound

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

        Item {
            id: content
            anchors.fill: parent

            // Source wallpaper: use main wallpaper when requested, otherwise prefer custom backdrop path
            property string source: Config.options.background.backdrop.useMainWallpaper
                                      ? Config.options.background.wallpaperPath
                                      : (Config.options.background.backdrop.wallpaperPath
                                         || Config.options.background.wallpaperPath)
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

            // Blur + color adjustments
            MultiEffect {
                anchors.fill: parent
                source: wallpaper
                blurEnabled: Config.options.background.backdrop.enable
                             && Config.options.background.backdrop.blurRadius > 0
                             && !Config.options.performance.lowPower
                blur: Config.options.background.backdrop.blurRadius / 100.0
                blurMax: 64
                saturation: Config.options.background.backdrop.saturation
                contrast: Config.options.background.backdrop.contrast
            }

            // Dim overlay
            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: Math.max(0, Math.min(1, Config.options.background.backdrop.dim / 100.0))
            }

            // Vignette overlay (simple gradient approximation)
            Item {
                anchors.fill: parent
                visible: Config.options.background.backdrop.vignetteEnabled

                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: Config.options.background.backdrop.vignetteRadius; color: "transparent" }
                        GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, Config.options.background.backdrop.vignetteIntensity) }
                    }
                }
            }
        }
    }
}
