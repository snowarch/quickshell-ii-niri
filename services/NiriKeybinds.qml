pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import qs.modules.common.functions
import QtQuick
import Quickshell
import Quickshell.Io

/**
 * A service that provides access to Niri keybinds.
 * Parses keybinds from the Niri config.kdl file.
 */
Singleton {
    id: root
    property string niriConfigPath: FileUtils.trimFileProtocol(`${Directories.config}/niri/config.kdl`)
    property var keybinds: ({
        children: defaultKeybinds
    })

    // Default keybinds structure for Niri (manually defined for reliability)
    readonly property var defaultKeybinds: [
        {
            name: "System",
            children: [
                {
                    keybinds: [
                        { mods: ["Super"], key: "Tab", comment: "Niri Overview" },
                        { mods: ["Super", "Shift"], key: "Slash", comment: "Show hotkey overlay" },
                        { mods: ["Super", "Shift"], key: "E", comment: "Quit Niri" },
                        { mods: ["Super"], key: "Escape", comment: "Toggle shortcuts inhibit" },
                        { mods: ["Super", "Shift"], key: "P", comment: "Power off monitors" }
                    ]
                }
            ]
        },
        {
            name: "Window Switcher",
            children: [
                {
                    keybinds: [
                        { mods: ["Alt"], key: "Tab", comment: "Next window" },
                        { mods: ["Alt", "Shift"], key: "Tab", comment: "Previous window" }
                    ]
                }
            ]
        },
        {
            name: "Applications",
            children: [
                {
                    keybinds: [
                        { mods: ["Super"], key: "T", comment: "Terminal" },
                        { mods: ["Super"], key: "Return", comment: "Terminal" },
                        { mods: ["Super"], key: "W", comment: "Browser" },
                        { mods: ["Super"], key: "E", comment: "File manager" },
                        { mods: ["Super"], key: "C", comment: "Windsurf" },
                        { mods: ["Super"], key: "X", comment: "VS Code" },
                        { mods: ["Super"], key: "B", comment: "System monitor" },
                        { mods: ["Ctrl", "Super"], key: "V", comment: "Volume control" }
                    ]
                }
            ]
        },
        {
            name: "Window Management",
            children: [
                {
                    keybinds: [
                        { mods: ["Super"], key: "Q", comment: "Close window" },
                        { mods: ["Super"], key: "D", comment: "Maximize column" },
                        { mods: ["Super"], key: "F", comment: "Fullscreen" },
                        { mods: ["Super"], key: "A", comment: "Toggle floating" }
                    ]
                }
            ]
        },
        {
            name: "Focus",
            children: [
                {
                    keybinds: [
                        { mods: ["Super"], key: "Left", comment: "Focus column left" },
                        { mods: ["Super"], key: "Right", comment: "Focus column right" },
                        { mods: ["Super"], key: "Up", comment: "Focus window up" },
                        { mods: ["Super"], key: "Down", comment: "Focus window down" },
                        { mods: ["Super"], key: "H", comment: "Focus column left" },
                        { mods: ["Super"], key: "L", comment: "Focus column right" },
                        { mods: ["Super"], key: "K", comment: "Focus window up" },
                        { mods: ["Super"], key: "J", comment: "Focus window down" }
                    ]
                }
            ]
        },
        {
            name: "Move Windows",
            children: [
                {
                    keybinds: [
                        { mods: ["Super", "Shift"], key: "Left", comment: "Move column left" },
                        { mods: ["Super", "Shift"], key: "Right", comment: "Move column right" },
                        { mods: ["Super", "Shift"], key: "Up", comment: "Move window up" },
                        { mods: ["Super", "Shift"], key: "Down", comment: "Move window down" }
                    ]
                }
            ]
        },
        {
            name: "Workspaces",
            children: [
                {
                    keybinds: [
                        { mods: ["Super"], key: "1-9", comment: "Focus workspace 1-9" },
                        { mods: ["Super", "Shift"], key: "1-5", comment: "Move to workspace 1-5" }
                    ]
                }
            ]
        },
        {
            name: "ii Shell",
            children: [
                {
                    keybinds: [
                        { mods: ["Super"], key: "Space", comment: "ii Overview" },
                        { mods: ["Super"], key: "G", comment: "ii Overlay" },
                        { mods: ["Super"], key: "V", comment: "Clipboard history" },
                        { mods: ["Super"], key: "Comma", comment: "Settings" },
                        { mods: ["Super"], key: "N", comment: "Notepad" },
                        { mods: ["Super", "Alt"], key: "L", comment: "Lock screen" },
                        { mods: ["Super"], key: "Slash", comment: "Cheatsheet" }
                    ]
                }
            ]
        },
        {
            name: "Screenshots",
            children: [
                {
                    keybinds: [
                        { mods: ["Super", "Shift"], key: "S", comment: "Screenshot region" },
                        { mods: ["Super", "Shift"], key: "X", comment: "OCR region" },
                        { mods: [], key: "Print", comment: "Screenshot (select)" },
                        { mods: ["Ctrl"], key: "Print", comment: "Screenshot screen" },
                        { mods: ["Alt"], key: "Print", comment: "Screenshot window" }
                    ]
                }
            ]
        },
        {
            name: "Media",
            children: [
                {
                    keybinds: [
                        { mods: [], key: "XF86AudioRaiseVolume", comment: "Volume up" },
                        { mods: [], key: "XF86AudioLowerVolume", comment: "Volume down" },
                        { mods: [], key: "XF86AudioMute", comment: "Mute audio" },
                        { mods: [], key: "XF86MonBrightnessUp", comment: "Brightness up" },
                        { mods: [], key: "XF86MonBrightnessDown", comment: "Brightness down" }
                    ]
                }
            ]
        }
    ]

    Component.onCompleted: {
        console.info("[NiriKeybinds] Loaded", defaultKeybinds.length, "keybind categories")
    }
}
