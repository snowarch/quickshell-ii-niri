import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.waffle.looks
import qs.modules.waffle.actionCenter
import qs.modules.waffle.actionCenter.volumeControl

ColumnLayout {
    id: root
    property var screen: root.QsWindow.window?.screen
    property var brightnessMonitor: Brightness.getMonitorForScreen(screen)
    spacing: 12

    RowLayout {
        spacing: 4

        WPanelIconButton {
            color: colBackground
            property real animationValue: root.brightnessMonitor?.brightness ?? 0
            rotation: animationValue * 180
            scale: 0.8 + animationValue * 0.2
            iconName: "weather-sunny"

            Behavior on animationValue {
                animation: Looks.transition.longMovement.createObject(this)
            }
        }
        
        WSlider {
            id: brightnessSlider
            Layout.fillWidth: true
            value: root.brightnessMonitor?.brightness ?? 0
            scrollable: true
            tooltipContent: `${Math.round(value * 100)}%`
            onMoved: {
                root.brightnessMonitor?.setBrightness(value)
            }
            // Prevent binding from overwriting during interaction
            onPressedChanged: {
                if (pressed) {
                    value = value // Break binding temporarily
                }
            }
        }

        WPanelIconButton {
            opacity: 0
        }
    }
    
    RowLayout {
        spacing: 4

        WPanelIconButton {
            iconName: WIcons.volumeIcon ?? "speaker"
            onClicked: Audio.toggleMute();
        }
        
        WSlider {
            id: volumeSlider
            Layout.fillWidth: true
            value: Audio.sink?.audio?.volume ?? 0
            scrollable: true
            onMoved: {
                Audio.setSinkVolume(value)
            }
            // Prevent binding from overwriting during interaction
            onPressedChanged: {
                if (pressed) {
                    value = value // Break binding temporarily
                }
            }
        }

        WPanelIconButton {
            Component {
                id: volumeControlComp
                VolumeControl {}
            }
            onClicked: {
                if (ActionCenterContext.stackView) ActionCenterContext.stackView.push(volumeControlComp)
            }
            contentItem: Item {
                anchors.centerIn: parent
                Row {
                    anchors.centerIn: parent
                    spacing: -1
                    FluentIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        implicitSize: 18
                        icon: "options"
                    }
                    FluentIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        implicitSize: 12
                        icon: "chevron-right"
                    }
                }
            }
        }
    }

}