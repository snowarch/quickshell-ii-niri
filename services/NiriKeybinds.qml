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
                        { mods: ["Super"], key: "Tab", comment: "Toggle Overview" },
                        { mods: ["Super", "Shift"], key: "E", comment: "Quit Niri" },
                        { mods: ["Super"], key: "Escape", comment: "Toggle keyboard shortcuts inhibit" },
                        { mods: ["Super", "Shift"], key: "O", comment: "Power off monitors" }
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
                        { mods: ["Super"], key: "T", comment: "Open terminal" },
                        { mods: ["Super"], key: "Return", comment: "Open terminal" },
                        { mods: ["Super"], key: "E", comment: "Open file manager" }
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
                        { mods: ["Super"], key: "F", comment: "Toggle fullscreen" },
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
                        { mods: ["Super"], key: "G", comment: "Toggle overlay" },
                        { mods: ["Super"], key: "V", comment: "Clipboard history" },
                        { mods: ["Super", "Alt"], key: "L", comment: "Lock screen" },
                        { mods: ["Ctrl", "Alt"], key: "T", comment: "Wallpaper selector" },
                        { mods: ["Super"], key: "/", comment: "Keyboard shortcuts" }
                    ]
                }
            ]
        },
        {
            name: "Region Tools",
            children: [
                {
                    keybinds: [
                        { mods: ["Super", "Shift"], key: "S", comment: "Screenshot region" },
                        { mods: ["Super", "Shift"], key: "X", comment: "OCR region" },
                        { mods: ["Super", "Shift"], key: "A", comment: "Google Lens search" }
                    ]
                }
            ]
        },
        {
            name: "Screenshots",
            children: [
                {
                    keybinds: [
                        { mods: [], key: "Print", comment: "Screenshot (select)" },
                        { mods: ["Ctrl"], key: "Print", comment: "Screenshot screen" },
                        { mods: ["Alt"], key: "Print", comment: "Screenshot window" }
                    ]
                }
            ]
        }
    ]

    Component.onCompleted: {
        console.info("[NiriKeybinds] Loaded", defaultKeybinds.length, "keybind categories")
    }
}
