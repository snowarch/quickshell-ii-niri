pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var availableThemes: []
    property string currentTheme: ""

    Component.onCompleted: {
        currentThemeProc.running = true
        listThemesProc.running = true
    }

    function setTheme(themeName) {
        Quickshell.execDetached(["bash", "-c", 
            "gsettings set org.gnome.desktop.interface icon-theme '" + themeName + "' && " +
            "sed -i 's/^Theme=.*/Theme=" + themeName + "/' ~/.config/kdeglobals 2>/dev/null; " +
            "qs kill -c ii; sleep 0.3; qs -c ii &"
        ])
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
        command: ["bash", "-c", "find /usr/share/icons ~/.local/share/icons -maxdepth 1 -type d 2>/dev/null | xargs -I{} basename {} | sort -u | grep -vE '^(icons|default|hicolor|locolor)$' | grep -v cursors"]
        
        property var themes: []
        
        stdout: SplitParser {
            onRead: line => {
                const name = line.trim()
                if (name) listThemesProc.themes.push(name)
            }
        }
        
        onRunningChanged: {
            if (!running && themes.length > 0) {
                root.availableThemes = themes
                themes = []
            }
        }
    }
}
