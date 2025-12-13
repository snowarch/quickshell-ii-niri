pragma Singleton
pragma ComponentBehavior: Bound
import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

/**
 * A nice wrapper for default Pipewire audio sink and source.
 */
Singleton {
    id: root

    // Misc props
    property bool ready: Pipewire.defaultAudioSink?.ready ?? false
    property PwNode sink: Pipewire.defaultAudioSink
    property PwNode source: Pipewire.defaultAudioSource
    readonly property real hardMaxValue: 2.00 // People keep joking about setting volume to 5172% so...
    property string audioTheme: Config.options?.sounds?.theme ?? "freedesktop"
    property real value: sink?.audio.volume ?? 0
    property bool micBeingAccessed: (Pipewire.links?.values ?? []).filter(link =>
        !(link?.source?.isStream ?? true)
            && !(link?.source?.isSink ?? true)
            && (link?.target?.isStream ?? false)
    ).length > 0
    function friendlyDeviceName(node) {
        return node ? (node.nickname || node.description || Translation.tr("Unknown")) : Translation.tr("Unknown");
    }
    function appNodeDisplayName(node) {
        if (!node) return Translation.tr("Unknown");
        return (node.properties?.["application.name"] || node.description || node.name || Translation.tr("Unknown"))
    }

    // Lists
    function correctType(node, isSink) {
        return (node.isSink === isSink) && node.audio
    }
    function appNodes(isSink) {
        return Pipewire.nodes.values.filter((node) => { // Should be list<PwNode> but it breaks ScriptModel
            return root.correctType(node, isSink) && node.isStream
        })
    }
    function devices(isSink) {
        return Pipewire.nodes.values.filter(node => {
            return root.correctType(node, isSink) && !node.isStream
        })
    }
    readonly property list<var> outputAppNodes: root.appNodes(true)
    readonly property list<var> inputAppNodes: root.appNodes(false)
    readonly property list<var> outputDevices: root.devices(true)
    readonly property list<var> inputDevices: root.devices(false)

    // Signals
    signal sinkProtectionTriggered(string reason);

    // Controls
    function toggleMute() {
        Audio.sink.audio.muted = !Audio.sink.audio.muted
    }

    // Set sink volume safely. When protection is enabled, large jumps can be rejected as "Illegal increment".
    // To keep UX consistent with brightness (click anywhere), we optionally ramp in small steps.
    function setSinkVolume(target: real, ramp: bool = true): void {
        if (!root.sink?.audio) return;

        const maxAllowed = (Config.options?.audio?.protection?.maxAllowed ?? 100) / 100;
        const clamped = Math.max(0, Math.min(Math.min(maxAllowed, root.hardMaxValue), target));

        const protectionEnabled = (Config.options?.audio?.protection?.enable ?? false);
        if (!ramp || !protectionEnabled) {
            root.sink.audio.volume = clamped;
            return;
        }

        root._rampTarget = clamped;
        root._rampTimer.restart();
    }

    function toggleMicMute() {
        Audio.source.audio.muted = !Audio.source.audio.muted
    }

    function incrementVolume() {
        const currentVolume = Audio.value;
        const step = currentVolume < 0.1 ? 0.01 : 0.02 || 0.2;
        Audio.sink.audio.volume = Math.min(1, Audio.sink.audio.volume + step);
    }
    
    function decrementVolume() {
        const currentVolume = Audio.value;
        const step = currentVolume < 0.1 ? 0.01 : 0.02 || 0.2;
        Audio.sink.audio.volume -= step;
    }

    function setDefaultSink(node) {
        Pipewire.preferredDefaultAudioSink = node;
    }

    function setDefaultSource(node) {
        Pipewire.preferredDefaultAudioSource = node;
    }

    // Internals
    PwObjectTracker {
        objects: [sink, source]
    }

    Connections { // Protection against sudden volume changes
        target: sink?.audio ?? null
        property bool lastReady: false
        property real lastVolume: 0
        function onVolumeChanged() {
            if (!(Config.options?.audio?.protection?.enable ?? false)) return;
            if (!sink?.audio) return;
            const newVolume = sink.audio.volume;
            // when resuming from suspend, we should not write volume to avoid pipewire volume reset issues
            if (isNaN(newVolume) || newVolume === undefined || newVolume === null) {
                lastReady = false;
                lastVolume = 0;
                return;
            }
            if (!lastReady) {
                lastVolume = newVolume;
                lastReady = true;
                return;
            }
            const maxAllowedIncrease = (Config.options?.audio?.protection?.maxAllowedIncrease ?? 0) / 100; 
            const maxAllowed = (Config.options?.audio?.protection?.maxAllowed ?? 100) / 100;

            if (newVolume - lastVolume > maxAllowedIncrease) {
                sink.audio.volume = lastVolume;
                root.sinkProtectionTriggered(Translation.tr("Illegal increment"));
            } else if (Math.round(newVolume * 100) / 100 > maxAllowed || newVolume > root.hardMaxValue) {
                root.sinkProtectionTriggered(Translation.tr("Exceeded max allowed"));
                sink.audio.volume = maxAllowed;
            }
            lastVolume = sink.audio.volume;
        }
    }

    // Ramp helper (prevents "Illegal increment" when user clicks far away on slider)
    property real _rampTarget: 0
    Timer {
        id: _rampTimer
        interval: 16
        repeat: true
        running: false
        onTriggered: {
            if (!root.sink?.audio) {
                running = false
                return
            }

            const protectionEnabled = (Config.options?.audio?.protection?.enable ?? false)
            if (!protectionEnabled) {
                root.sink.audio.volume = root._rampTarget
                running = false
                return
            }

            const maxStep = (Config.options?.audio?.protection?.maxAllowedIncrease ?? 2) / 100
            const step = Math.max(0.005, maxStep)
            const current = root.sink.audio.volume
            const diff = root._rampTarget - current
            if (Math.abs(diff) <= step) {
                root.sink.audio.volume = root._rampTarget
                running = false
                return
            }
            root.sink.audio.volume = current + Math.sign(diff) * step
        }
    }

    function playSystemSound(soundName) {
        const ogaPath = `/usr/share/sounds/${root.audioTheme}/stereo/${soundName}.oga`;
        const oggPath = `/usr/share/sounds/${root.audioTheme}/stereo/${soundName}.ogg`;

        // Try playing .oga first
        let command = [
            "/usr/bin/pw-play",
            ogaPath
        ];
        Quickshell.execDetached(command);

        // Also try playing .ogg (will just fail silently if file doesn't exist)
        command = [
            "/usr/bin/pw-play",
            oggPath
        ];
        Quickshell.execDetached(command);

        // Fallback: try canberra (theme lookup by sound name)
        Quickshell.execDetached([
            "/usr/bin/canberra-gtk-play",
            "-i",
            soundName
        ])
    }

    // IPC handlers for external control (keybinds, etc.)
    IpcHandler {
        target: "audio"

        function volumeUp(): void {
            root.incrementVolume();
        }

        function volumeDown(): void {
            root.decrementVolume();
        }

        function mute(): void {
            root.toggleMute();
        }

        function micMute(): void {
            root.toggleMicMute();
        }
    }
}
