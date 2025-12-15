pragma Singleton

import QtQuick
import qs.modules.common
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.services

/**
 * Simple hyprsunset service with automatic mode.
 * In theory we don't need this because hyprsunset has a config file, but it somehow doesn't work.
 * It should also be possible to control it via hyprctl, but it doesn't work consistently either so we're just killing and launching.
 */
Singleton {
    id: root
    property string from: Config.options?.light?.night?.from ?? "19:00" 
    property string to: Config.options?.light?.night?.to ?? "06:30"
    property bool automatic: (Config.options?.light?.night?.automatic ?? false) && (Config.ready ?? true)
    property int colorTemperature: Config.options?.light?.night?.colorTemperature ?? 5000
    property bool supported: CompositorService.isHyprland || CompositorService.isNiri
    property bool _wlsunsetAvailable: false
    property bool _wlsunsetWarned: false
    property bool shouldBeOn
    property bool firstEvaluation: true
    property bool active: false

    property int fromHour: Number(from.split(":")[0])
    property int fromMinute: Number(from.split(":")[1])
    property int toHour: Number(to.split(":")[0])
    property int toMinute: Number(to.split(":")[1])

    property int clockHour: DateTime.clock.hours
    property int clockMinute: DateTime.clock.minutes

    property var manualActive
    property int manualActiveHour
    property int manualActiveMinute

    onClockMinuteChanged: reEvaluate()
    onAutomaticChanged: {
        root.manualActive = undefined;
        root.firstEvaluation = true;
        if (CompositorService.isNiri && root.active) {
            if (root._wlsunsetAvailable) {
                niriKillProc.running = true
                niriStartProc.running = true
            }
        }
        reEvaluate();
    }

    Component.onCompleted: {
        // Detect wlsunset on Niri to avoid Process start spam
        if (CompositorService.isNiri) {
            wlsunsetCheckProc.running = true
        }
    }

    Process {
        id: wlsunsetCheckProc
        running: false
        command: ["/usr/bin/test", "-x", "/usr/bin/wlsunset"]
        onExited: (exitCode, exitStatus) => {
            root._wlsunsetAvailable = (exitCode === 0)
            if (!root._wlsunsetAvailable && !root._wlsunsetWarned) {
                root._wlsunsetWarned = true
                console.warn("[NightLight] wlsunset not found at /usr/bin/wlsunset - Night Light won't work on Niri until installed")
            }
        }
    }

    Process {
        id: pidofProc
        running: false
        command: ["/usr/bin/pidof", "hyprsunset"]
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                startProc.running = true
            }
        }
    }

    Process {
        id: startProc
        running: false
        command: ["/usr/bin/hyprsunset", "--temperature", `${root.colorTemperature}`]
    }

    Process {
        id: pkillProc
        running: false
        command: ["/usr/bin/pkill", "hyprsunset"]
    }

    Process {
        id: niriPidofProc
        running: false
        command: ["/usr/bin/pidof", "wlsunset"]
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                niriStartProc.running = true
            }
        }
    }

    Process {
        id: niriStartProc
        running: false
        command: {
            const low = `${Config.options?.light?.night?.colorTemperature ?? root.colorTemperature}`
            if (root.automatic) {
                return [
                    "/usr/bin/wlsunset",
                    "-T", "6500",
                    "-t", low,
                    "-S", `${root.to}`,
                    "-s", `${root.from}`
                ]
            }
            return [
                "/usr/bin/wlsunset",
                "-T", low,
                "-t", low
            ]
        }
    }

    Process {
        id: niriKillProc
        running: false
        command: ["/usr/bin/pkill", "wlsunset"]
    }

    function inBetween(t, from, to) {
        if (from < to) {
            return (t >= from && t <= to);
        } else {
            // Wrapped around midnight
            return (t >= from || t <= to);
        }
    }

    function reEvaluate() {
        const t = clockHour * 60 + clockMinute;
        const from = fromHour * 60 + fromMinute;
        const to = toHour * 60 + toMinute;
        const manualActive = manualActiveHour * 60 + manualActiveMinute;

        if (root.manualActive !== undefined && (inBetween(from, manualActive, t) || inBetween(to, manualActive, t))) {
            root.manualActive = undefined;
        }
        root.shouldBeOn = inBetween(t, from, to);
        if (firstEvaluation) {
            firstEvaluation = false;
            root.ensureState();
        }
    }

    onShouldBeOnChanged: ensureState()
    function ensureState() {
        // console.log("[Hyprsunset] Ensuring state:", root.shouldBeOn, "Automatic mode:", root.automatic);
        if (!root.automatic || root.manualActive !== undefined)
            return;
        if (root.shouldBeOn) {
            root.enable();
        } else {
            root.disable();
        }
    }

    function load() { } // Dummy to force init

    function enable() {
        if (!root.supported)
            return;
        if (CompositorService.isNiri && !root._wlsunsetAvailable) {
            if (!root._wlsunsetWarned) {
                root._wlsunsetWarned = true
                console.warn("[NightLight] wlsunset not found at /usr/bin/wlsunset - Night Light won't work on Niri until installed")
            }
            root.active = false
            return;
        }
        root.active = true;
        // console.log("[Hyprsunset] Enabling");
        if (CompositorService.isHyprland) {
            pidofProc.running = true
        } else if (CompositorService.isNiri) {
            niriPidofProc.running = true
        }
    }

    function disable() {
        if (!root.supported)
            return;
        if (CompositorService.isNiri && !root._wlsunsetAvailable) {
            root.active = false
            return;
        }
        root.active = false;
        // console.log("[Hyprsunset] Disabling");
        if (CompositorService.isHyprland) {
            pkillProc.running = true
        } else if (CompositorService.isNiri) {
            niriKillProc.running = true
        }
    }

    function fetchState() {
        if (!root.supported)
            return;
        if (CompositorService.isHyprland) {
            fetchProc.running = true;
        } else if (CompositorService.isNiri) {
            niriFetchProc.running = true;
        }
    }

    Process {
        id: fetchProc
        running: CompositorService.isHyprland
        command: ["/usr/bin/hyprctl", "hyprsunset", "temperature"]
        stdout: StdioCollector {
            id: stateCollector
            onStreamFinished: {
                const output = stateCollector.text.trim();
                if (output.length == 0 || output.startsWith("Couldn't"))
                    root.active = false;
                else
                    root.active = (output != "6500"); // 6500 is the default when off
                // console.log("[Hyprsunset] Fetched state:", output, "->", root.active);
            }
        }
    }

    Process {
        id: niriFetchProc
        running: CompositorService.isNiri
        command: ["/usr/bin/pidof", "wlsunset"]
        onExited: (exitCode, exitStatus) => {
            root.active = (exitCode === 0)
        }
    }

    function toggle(active = undefined) {
        if (!root.supported)
            return;
        if (root.manualActive === undefined) {
            root.manualActive = root.active;
            root.manualActiveHour = root.clockHour;
            root.manualActiveMinute = root.clockMinute;
        }

        root.manualActive = active !== undefined ? active : !root.manualActive;
        if (root.manualActive) {
            root.enable();
        } else {
            root.disable();
        }
    }

    // Change temp
    Connections {
        target: Config.options?.light?.night ?? null
        enabled: !!(Config.options?.light?.night)
        function onColorTemperatureChanged() {
            if (!root.active) return;
            if (CompositorService.isHyprland) {
                Quickshell.execDetached(["/usr/bin/hyprctl", "hyprsunset", "temperature", `${Config.options?.light?.night?.colorTemperature ?? root.colorTemperature}`]);
                return;
            }
            if (CompositorService.isNiri) {
                if (!root._wlsunsetAvailable) return;
                niriKillProc.running = true
                niriStartProc.running = true
            }
        }

        function onFromChanged() {
            if (CompositorService.isNiri && root.active) {
                if (!root._wlsunsetAvailable) return;
                niriKillProc.running = true
                niriStartProc.running = true
            }
        }

        function onToChanged() {
            if (CompositorService.isNiri && root.active) {
                if (!root._wlsunsetAvailable) return;
                niriKillProc.running = true
                niriStartProc.running = true
            }
        }

        function onAutomaticChanged() {
            if (CompositorService.isNiri && root.active) {
                if (!root._wlsunsetAvailable) return;
                niriKillProc.running = true
                niriStartProc.running = true
            }
        }
    }
}
