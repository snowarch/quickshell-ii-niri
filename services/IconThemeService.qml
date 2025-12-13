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

    property bool _initialized: false

    function ensureInitialized(): void {
        if (root._initialized)
            return;
        root._initialized = true;
        currentThemeProc.running = true
        listThemesProc.running = true
    }

    function setTheme(themeName) {
        if (!themeName || String(themeName).trim().length === 0)
            return;

        gsettingsSetProc.themeName = String(themeName).trim()
        gsettingsSetProc.running = true
    }

    Timer {
        id: restartDelay
        interval: 300
        repeat: false
        onTriggered: Quickshell.execDetached(["qs", "-c", "ii"])
    }

    Process {
        id: gsettingsSetProc
        property string themeName: ""
        command: ["gsettings", "set", "org.gnome.desktop.interface", "icon-theme", gsettingsSetProc.themeName]
        onExited: (exitCode, exitStatus) => {
            // Best-effort KDE sync
            kdeGlobalsSedProc.themeName = gsettingsSetProc.themeName
            kdeGlobalsSedProc.running = true
        }
    }

    Process {
        id: kdeGlobalsSedProc
        property string themeName: ""
        command: [
            "sed",
            "-i",
            `s/^Theme=.*/Theme=${kdeGlobalsSedProc.themeName}/`,
            `${FileUtils.trimFileProtocol(Directories.home)}/.config/kdeglobals`
        ]
        onExited: (exitCode, exitStatus) => {
            // Restart shell (same as previous behavior but without chaining)
            Quickshell.execDetached(["qs", "kill", "-c", "ii"])
            restartDelay.start()
        }
    }

    Process {
        id: currentThemeProc
        command: ["gsettings", "get", "org.gnome.desktop.interface", "icon-theme"]
        stdout: SplitParser {
            onRead: line => {
                root.currentTheme = line.trim().replace(/'/g, "")
            }
        }
    }

    Process {
        id: listThemesProc
        command: [
            "find",
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
