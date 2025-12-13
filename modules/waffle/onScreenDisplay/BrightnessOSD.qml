import QtQuick
import Quickshell
import qs.services
import qs.modules.waffle.looks

OSDValue {
    id: root
    property var focusedScreen: Quickshell.screens.find(s => s.name === NiriService.currentOutput) ?? Quickshell.screens[0]
    property var brightnessMonitor: Brightness.getMonitorForScreen(focusedScreen)
    iconName: "weather-sunny"
    value: brightnessMonitor?.brightness ?? 0
    showNumber: true

    Connections {
        target: Brightness
        function onBrightnessChanged() {
            root.timer.restart();
        }
    }
}
