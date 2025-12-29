pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common
import qs.modules.common.functions

Singleton {
    id: root

    property var availableThemes: []
    property string currentTheme: ""
    property string dockTheme: ""  // Separate theme for dock icons

    property bool _initialized: false
    property bool _restartQueued: false

    // Get icon path from dock theme, fallback to system
    function dockIconPath(iconName: string, fallback: string): string {
        if (!iconName) return Quickshell.iconPath(fallback || "application-x-executable")
        if (!root.dockTheme) return Quickshell.iconPath(iconName, fallback || "application-x-executable")
        
        const home = Quickshell.env("HOME")
        const theme = root.dockTheme
        
        // Return first candidate path - Image will handle fallback via onStatusChanged
        // Structure: theme/apps/scalable (YAMIS, etc)
        return `file://${home}/.local/share/icons/${theme}/apps/scalable/${iconName}.svg`
    }
    
    // Get all candidate paths for dock icon
    function dockIconCandidates(iconName: string): list<string> {
        if (!iconName || !root.dockTheme) return []
        
        const home = Quickshell.env("HOME")
        const theme = root.dockTheme
        
        return [
            `file://${home}/.local/share/icons/${theme}/apps/scalable/${iconName}.svg`,
            `file:///usr/share/icons/${theme}/apps/scalable/${iconName}.svg`,
            `file://${home}/.local/share/icons/${theme}/scalable/apps/${iconName}.svg`,
            `file:///usr/share/icons/${theme}/scalable/apps/${iconName}.svg`,
            `file://${home}/.local/share/icons/${theme}/apps/256x256/${iconName}.png`,
            `file:///usr/share/icons/${theme}/apps/256x256/${iconName}.png`,
            `file://${home}/.local/share/icons/${theme}/256x256/apps/${iconName}.png`,
            `file:///usr/share/icons/${theme}/256x256/apps/${iconName}.png`,
        ]
    }

    function ensureInitialized(): void {
        if (root._initialized)
            return;
        root._initialized = true;
        
        listThemesProc.running = false
        listThemesProc.running = true
        
        // Load system theme
        const savedTheme = Config.ready ? (Config.options?.appearance?.iconTheme ?? "") : ""
        if (savedTheme && String(savedTheme).trim().length > 0) {
            root.currentTheme = String(savedTheme).trim()
            console.log("[IconThemeService] Restoring saved icon theme:", root.currentTheme)
            gsettingsSetProc.themeName = root.currentTheme
            gsettingsSetProc.skipRestart = true
            gsettingsSetProc.running = false
            gsettingsSetProc.running = true
        } else {
            currentThemeProc.running = false
            currentThemeProc.running = true
        }
        
        // Load dock theme
        root.dockTheme = Config.options?.appearance?.dockIconTheme ?? ""
    }

    function setTheme(themeName) {
        if (!themeName || String(themeName).trim().length === 0)
            return;

        const themeStr = String(themeName).trim()
        console.log("[IconThemeService] Setting icon theme:", themeStr)

        // Update UI immediately; actual system change follows via gsettings.
        root.currentTheme = themeStr

        gsettingsSetProc.themeName = themeStr
        gsettingsSetProc.skipRestart = false
        gsettingsSetProc.running = false
        gsettingsSetProc.running = true
        
        // Persist to config.json
        Config.setNestedValue('appearance.iconTheme', themeStr)

        // Ensure config is written before we do any restart.
        Config.flushWrites()
    }

    function setDockTheme(themeName: string): void {
        root.dockTheme = themeName ?? ""
        Config.setNestedValue('appearance.dockIconTheme', themeName ?? "")
        Config.flushWrites()
        root.queueRestart()
    }

    Timer {
        id: restartDelay
        interval: 250
        repeat: false
        onTriggered: {
            root._restartQueued = false
            console.log("[IconThemeService] Restarting shell now...")
            Quickshell.execDetached(["/usr/bin/setsid", "/usr/bin/fish", "-c", "qs kill -c ii; sleep 0.3; qs -c ii"])
        }
    }

    function queueRestart(): void {
        if (root._restartQueued)
            return;
        root._restartQueued = true
        restartDelay.restart()
    }

    Process {
        id: gsettingsSetProc
        property string themeName: ""
        property bool skipRestart: false
        command: ["/usr/bin/gsettings", "set", "org.gnome.desktop.interface", "icon-theme", gsettingsSetProc.themeName]
        onExited: (exitCode, exitStatus) => {
            console.log("[IconThemeService] gsettings set exited:", exitCode, "theme:", gsettingsSetProc.themeName)
            // Sync to KDE/Qt apps via kdeglobals
            kdeGlobalsUpdateProc.themeName = gsettingsSetProc.themeName
            kdeGlobalsUpdateProc.skipRestart = gsettingsSetProc.skipRestart
            kdeGlobalsUpdateProc.running = false
            kdeGlobalsUpdateProc.running = true
        }
    }

    // Update kdeglobals [Icons] section properly
    Process {
        id: kdeGlobalsUpdateProc
        property string themeName: ""
        property bool skipRestart: false
        command: [
            "/usr/bin/python3",
            "-c",
            `
import configparser
import os

config_path = os.path.expanduser("~/.config/kdeglobals")
theme = "${kdeGlobalsUpdateProc.themeName}"

config = configparser.ConfigParser()
config.optionxform = str  # Preserve case

if os.path.exists(config_path):
    config.read(config_path)

if "Icons" not in config:
    config["Icons"] = {}

config["Icons"]["Theme"] = theme

with open(config_path, "w") as f:
    config.write(f, space_around_delimiters=False)
`
        ]
        onExited: (exitCode, exitStatus) => {
            // Also update plasma icon theme via kwriteconfig if available
            kwriteconfigProc.themeName = kdeGlobalsUpdateProc.themeName
            kwriteconfigProc.skipRestart = kdeGlobalsUpdateProc.skipRestart

            kwriteconfigProc.running = false
            kwriteconfigProc.running = true

            // Restart shell if user actively changed theme.
            // Do not depend on kwriteconfig6 succeeding.
            if (!kdeGlobalsUpdateProc.skipRestart) {
                root.queueRestart()
            }
        }
    }

    // Use kwriteconfig6 for better KDE integration (if available)
    Process {
        id: kwriteconfigProc
        property string themeName: ""
        property bool skipRestart: false
        command: [
            "/usr/bin/kwriteconfig6",
            "--file", "kdeglobals",
            "--group", "Icons",
            "--key", "Theme",
            kwriteconfigProc.themeName
        ]
        onExited: (exitCode, exitStatus) => {
            console.log("[IconThemeService] kwriteconfig exited:", exitCode, "theme:", kwriteconfigProc.themeName)
        }
    }

    Process {
        id: currentThemeProc
        command: ["/usr/bin/gsettings", "get", "org.gnome.desktop.interface", "icon-theme"]
        stdout: SplitParser {
            onRead: line => {
                root.currentTheme = line.trim().replace(/'/g, "")
            }
        }
    }

    Process {
        id: listThemesProc
        command: [
            "/usr/bin/find",
            "/usr/share/icons",
            `${FileUtils.trimFileProtocol(Directories.home)}/.local/share/icons`,
            "-maxdepth",
            "1",
            "-type",
            "d"
        ]
        
        property var themes: []
        
        stdout: SplitParser {
            onRead: line => {
                const p = line.trim()
                if (!p)
                    return
                const parts = p.split("/")
                const name = parts[parts.length - 1]
                if (!name)
                    return
                if (["icons", "default", "hicolor", "locolor"].includes(name))
                    return
                if (name === "cursors")
                    return
                listThemesProc.themes.push(name)
            }
        }
        
        onRunningChanged: {
            if (!running && themes.length > 0) {
                const uniqueSorted = Array.from(new Set(themes)).sort()
                root.availableThemes = uniqueSorted
                themes = []
            }
        }
    }
}
