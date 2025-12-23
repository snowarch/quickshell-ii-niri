import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower

Rectangle {
    id: root

    readonly property bool auroraEverywhere: (Config.options?.bar?.blurBackground?.enabled ?? false) && !(Config.options?.bar?.showBackground ?? true)

    property var screen: root.QsWindow.window?.screen
    // Brightness monitor may be undefined (e.g. Niri without matching monitor); guard it.
    property var brightnessMonitor: screen ? Brightness.getMonitorForScreen(screen) : null

    implicitWidth: contentItem.implicitWidth + root.horizontalPadding * 2
    implicitHeight: contentItem.implicitHeight + root.verticalPadding * 2
    radius: Appearance.rounding.normal
    color: root.auroraEverywhere ? ColorUtils.transparentize(Appearance.colors.colLayer1, Appearance.aurora.subSurfaceTransparentize) : Appearance.colors.colLayer1
    property real verticalPadding: 4
    property real horizontalPadding: 12

    RowLayout {
        id: contentItem
        anchors {
            fill: parent
            leftMargin: root.horizontalPadding
            rightMargin: root.horizontalPadding
            topMargin: root.verticalPadding
            bottomMargin: root.verticalPadding
        }
        spacing: 10

        Loader {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: active
            active: (Config.options?.sidebar?.quickSliders?.showBrightness ?? true) && !!root.brightnessMonitor
            sourceComponent: QuickSlider {
                materialSymbol: "brightness_6"
                modelValue: root.brightnessMonitor?.brightness ?? 0
                onMoved: root.brightnessMonitor?.setBrightness(value)
            }
        }

        Loader {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: active
            active: Config.options?.sidebar?.quickSliders?.showVolume ?? true
            sourceComponent: QuickSlider {
                materialSymbol: "volume_up"
                modelValue: Audio.sink?.audio?.volume ?? 0
                to: Audio.uiMaxSinkVolume
                onMoved: Audio.setSinkVolume(value)
            }
        }

        Loader {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: active
            active: Config.options?.sidebar?.quickSliders?.showMic ?? false
            sourceComponent: QuickSlider {
                materialSymbol: "mic"
                modelValue: Audio.source?.audio?.volume ?? 0
                onMoved: {
                    if (Audio.source?.audio)
                        Audio.source.audio.volume = value
                }
            }
        }
    }

    component QuickSlider: StyledSlider { 
        id: quickSlider
        required property string materialSymbol
        property real modelValue: 0
        configuration: StyledSlider.Configuration.M
        stopIndicatorValues: []
        scrollable: true

        // Sync from model only when not interacting, with threshold to avoid micro-jumps
        onModelValueChanged: {
            if (!pressed && !_userInteracting) {
                if (Math.abs(value - modelValue) > 0.005) {
                    value = modelValue
                }
            }
        }
        
        MaterialSymbol {
            id: icon
            property bool nearFull: quickSlider.value >= 0.9
            anchors {
                verticalCenter: parent.verticalCenter
                right: nearFull ? quickSlider.handle.right : parent.right
                rightMargin: nearFull ? 14 : 8
            }
            iconSize: 20
            color: nearFull ? Appearance.colors.colOnPrimary : Appearance.colors.colOnSecondaryContainer
            text: quickSlider.materialSymbol

            Behavior on color {
                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
            }
            Behavior on anchors.rightMargin {
                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
            }

        }
    }
}
