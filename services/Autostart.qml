pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import qs.modules.common.functions
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool hasRun: false
    property bool _systemdUnitsRefreshRequested: false
    readonly property bool globalEnabled: Config.options?.autostart?.enable ?? false

    readonly property var entries: (Config.options?.autostart && Config.options?.autostart?.entries)
        ? Config.options.autostart.entries
        : []

    property var systemdUnits: []

    function load() {
        if (hasRun)
            return;

        hasRun = true;

        if (Config.ready) {
            startFromConfig();
        }
    }

    function startFromConfig() {
        if (!globalEnabled)
            return;

        const cfg = Config.options?.autostart;
        if (!cfg || !cfg.entries)
            return;

        for (let i = 0; i < cfg.entries.length; ++i) {
            const entry = cfg.entries[i];
            if (!entry || entry.enabled !== true)
                continue;
            startEntry(entry);
        }
    }

    function startEntry(entry) {
        if (!entry)
            return;

        if (entry.type === "desktop" && entry.desktopId) {
            startDesktop(entry.desktopId);
        } else if (entry.type === "command" && entry.command) {
            startCommand(entry.command);
        }
    }

    function startDesktop(desktopId) {
        if (!desktopId)
            return;

        const id = String(desktopId).trim();
        if (id.length === 0)
            return;

        startDesktopProc.desktopId = id
        startDesktopProc.running = true
    }

    Process {
        id: startDesktopProc
        property string desktopId: ""
        command: ["gtk-launch", startDesktopProc.desktopId]
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 && startDesktopProc.desktopId.length > 0) {
                Quickshell.execDetached([startDesktopProc.desktopId])
            }
            startDesktopProc.desktopId = ""
        }
    }

    function startCommand(command) {
        if (!command)
            return;

        const cmd = String(command).trim();
        if (cmd.length === 0)
            return;

        Quickshell.execDetached(["bash", "-lc", cmd]);
    }

    Process {
        id: systemdListProc
        property var buffer: []
        command: [
            "bash", "-lc",
            "dir=\"$HOME/.config/systemd/user\"; "
            + "[ -d \"$dir\" ] || exit 0; "
            + "for f in \"$dir\"/*.service; do "
            + "[ -e \"$f\" ] || continue; "
            + "name=$(basename \"$f\"); "
            + "enabled=$(systemctl --user is-enabled \"$name\" 2>/dev/null || echo disabled); "
            + "desc=$(grep -m1 '^Description=' \"$f\" | cut -d= -f2-); "
            + "wanted=$(grep -m1 '^WantedBy=' \"$f\" | cut -d= -f2-); "
            + "after=$(grep -m1 '^After=' \"$f\" | cut -d= -f2-); "
            + "desc=${desc//|/ }; wanted=${wanted//|/ }; kind=session; "
            + "printf '%s\n' \"$wanted\" \"$after\" | grep -q 'tray-apps.target' && kind=tray; "
            + "ii_managed=no; "
            + "grep -q '^# ii-autostart' \"$f\" 2>/dev/null && ii_managed=yes; "
            + "echo \"$name|$enabled|$kind|$desc|$wanted|$ii_managed\"; "
            + "done"
        ]
        stdout: SplitParser {
            onRead: (line) => {
                systemdListProc.buffer.push(line)
            }
        }
        onExited: (exitCode, exitStatus) => {
            const units = []
            if (exitCode !== 0) {
                console.log("[Autostart] systemdListProc exited with", exitCode, exitStatus)
                root.systemdUnits = units
                systemdListProc.buffer = []
                return;
            }

            for (let i = 0; i < systemdListProc.buffer.length; ++i) {
                const raw = systemdListProc.buffer[i].trim()
                if (raw.length === 0)
                    continue;
                const parts = raw.split("|")
                if (parts.length < 6)
                    continue;
                const name = parts[0]
                const state = parts[1]
                const kind = parts[2]
                const desc = parts.length > 3 ? parts[3] : ""
                const wanted = parts.length > 4 ? parts[4] : ""
                const enabled = state.indexOf("enabled") !== -1
                const isTray = kind === "tray"
                const iiManaged = parts[5] === "yes"
                units.push({
                    name: name,
                    state: state,
                    description: desc,
                    enabled: enabled,
                    isTray: isTray,
                    iiManaged: iiManaged
                })
            }
            console.log("[Autostart] Loaded", units.length, "user systemd services")
            root.systemdUnits = units
            systemdListProc.buffer = []
        }
    }

    function refreshSystemdUnits() {
        systemdListProc.buffer = []
        systemdListProc.running = true
    }

    function requestRefreshSystemdUnits(): void {
        root._systemdUnitsRefreshRequested = true
        refreshTimer.restart()
    }

    Timer {
        id: refreshTimer
        interval: 1200
        repeat: false
        onTriggered: {
            if (!root._systemdUnitsRefreshRequested)
                return;
            if (!(Config.ready ?? false))
                return;
            root._systemdUnitsRefreshRequested = false
            root.refreshSystemdUnits()
        }
    }

    Process {
        id: systemdToggleProc
        function toggle(name, enabled) {
            if (!name || name.length === 0)
                return;
            const op = enabled ? "enable" : "disable"
            console.log("[Autostart] Toggling user service", name, "->", enabled ? "enabled" : "disabled")
            exec(["systemctl", "--user", op, "--now", name])
        }
        onExited: (exitCode, exitStatus) => {
            console.log("[Autostart] systemdToggleProc exited with", exitCode, exitStatus)
            refreshSystemdUnits()
        }
    }

    // Creating a user systemd unit needs two ordering guarantees:
    // 1) the destination directory exists
    // 2) the file is written before we run `systemctl --user daemon-reload && enable --now`
    //
    // Using Quickshell.execDetached(["mkdir", ...]) + FileView.setText() can race.
    // Instead, do mkdir + write through a Process and only activate after it exits.

    property var _pendingServiceWrites: []

    function _enqueueServiceWrite(dir: string, filePath: string, text: string, unitName: string): void {
        root._pendingServiceWrites.push({ dir, filePath, text, unitName })
        root._startNextServiceWrite()
    }

    function _startNextServiceWrite(): void {
        if (serviceWriteProc.running) return
        if (root._pendingServiceWrites.length === 0) return

        const next = root._pendingServiceWrites[0]
        if (!next?.dir || !next?.filePath) {
            console.warn("[Autostart] Invalid pending service write:", JSON.stringify(next))
            root._pendingServiceWrites.shift()
            root._startNextServiceWrite()
            return
        }

        serviceWriteProc.start(next.dir, next.filePath, next.text, next.unitName)
    }

    Process {
        id: serviceWriteProc

        property string dir: ""
        property string filePath: ""
        property string text: ""
        property string unitName: ""

        stdinEnabled: true

        function start(dir: string, filePath: string, text: string, unitName: string): void {
            this.dir = dir
            this.filePath = filePath
            this.text = text
            this.unitName = unitName

            const dirEsc = StringUtils.shellSingleQuoteEscape(dir)
            const fileEsc = StringUtils.shellSingleQuoteEscape(filePath)

            // cat reads unit file contents from stdin.
            exec(["bash", "-lc", `mkdir -p '${dirEsc}' && cat > '${fileEsc}'`])
        }

        onRunningChanged: {
            if (serviceWriteProc.running) {
                serviceWriteProc.write(serviceWriteProc.text)
                // Close stdin so `cat` can exit.
                serviceWriteProc.stdinEnabled = false
            } else {
                serviceWriteProc.stdinEnabled = true
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                console.warn("[Autostart] Failed to write user service file", filePath, "exit", exitCode, exitStatus)
            } else if (unitName && unitName.length > 0) {
                console.log("[Autostart] Wrote user service file", filePath, "-> activating", unitName)
                systemdCreateProc.activate(unitName)
            }

            // Clear state
            dir = ""
            filePath = ""
            text = ""
            unitName = ""

            // Advance queue
            if (root._pendingServiceWrites.length > 0)
                root._pendingServiceWrites.shift()
            root._startNextServiceWrite()
        }
    }

    Process {
        id: systemdCreateProc
        function activate(unitName) {
            if (!unitName || unitName.length === 0)
                return;
            console.log("[Autostart] Activating new user service", unitName)
            const escaped = StringUtils.shellSingleQuoteEscape(unitName)
            exec(["bash", "-lc", "systemctl --user daemon-reload && systemctl --user enable --now '" + escaped + "' 2>/dev/null || true"])
        }
        onExited: (exitCode, exitStatus) => {
            console.log("[Autostart] systemdCreateProc exited with", exitCode, exitStatus)
            refreshSystemdUnits()
        }
    }

    Process {
        id: systemdDeleteProc
        function remove(name) {
            if (!name || name.length === 0)
                return;
            const home = Quickshell.env("HOME")
            const dir = `${home}/.config/systemd/user`
            console.log("[Autostart] Deleting user service", name)
            const cmd = "systemctl --user disable --now '" + name
                + "' 2>/dev/null || true; "
                // Only remove units that were created by ii Autostart (marker comment)
                + "if grep -q '^# ii-autostart' '" + dir + "/" + name + "' 2>/dev/null; then "
                + "rm -f '" + dir + "/" + name + "' 2>/dev/null || true; "
                + "fi; "
                + "systemctl --user daemon-reload"
            exec(["bash", "-lc", cmd])
        }
        onExited: (exitCode, exitStatus) => {
            console.log("[Autostart] systemdDeleteProc exited with", exitCode, exitStatus)
            refreshSystemdUnits()
        }
    }

    function setServiceEnabled(name, enabled) {
        systemdToggleProc.toggle(name, enabled)
    }

    function createUserService(name, description, command, kind) {
        if (!name)
            return;
        const trimmedName = String(name).trim()
        if (trimmedName.length === 0)
            return;
        const exec = String(command || "").trim()
        if (exec.length === 0)
            return;
        const safeName = trimmedName.replace(/\s+/g, "-")
        const unitName = safeName + ".service"
        const desc = String(description || safeName)
        const isTray = kind === "tray"
        const afterTarget = isTray ? "tray-apps.target" : "graphical-session.target"
        const wantedByTarget = isTray ? "tray-apps.target" : "graphical-session.target"

        // Build path using XDG home directory and trim any file:// prefix to get a real filesystem path
        const homePath = FileUtils.trimFileProtocol(Directories.home)
        const dir = `${homePath}/.config/systemd/user`
        const filePath = `${dir}/${safeName}.service`

        const text = "# ii-autostart\n"
            + "[Unit]\n"
            + "Description=" + desc + "\n"
            + "After=" + afterTarget + "\n"
            + "\n"
            + "[Service]\n"
            + "Type=simple\n"
            + "ExecStart=" + exec + "\n"
            + "Restart=on-failure\n"
            + "RestartSec=3\n"
            + "\n"
            + "[Install]\n"
            + "WantedBy=" + wantedByTarget + "\n"

        root._enqueueServiceWrite(dir, filePath, text, unitName)
    }

    function deleteUserService(name) {
        if (!name || name.length === 0)
            return;
        systemdDeleteProc.remove(name)
    }

    Component.onCompleted: {
        load()
        // Defer systemd scanning to keep shell startup smooth.
        root.requestRefreshSystemdUnits()
    }

    Connections {
        target: Config
        function onReadyChanged() {
            if (Config.ready && !root.hasRun) {
                root.startFromConfig();
                root.hasRun = true;
            }
            if (Config.ready) {
                root.requestRefreshSystemdUnits()
            }
        }
    }
}
