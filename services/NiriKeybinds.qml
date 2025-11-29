pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

/**
 * Keybinds for Niri compositor with ii shell.
 * These match defaults/niri/config.kdl
 */
Singleton {
    id: root
    property var keybinds: ({
        children: defaultKeybinds
    })

    readonly property var defaultKeybinds: [
        {
            name: "System",
            children: [{ keybinds: [
                { mods: ["Super"], key: "Tab", comment: "Niri Overview" },
                { mods: ["Super", "Shift"], key: "E", comment: "Quit Niri" },
                { mods: ["Super"], key: "Escape", comment: "Toggle shortcuts inhibit" }
            ]}]
        },
        {
            name: "ii Shell",
            children: [{ keybinds: [
                { mods: ["Super"], key: "Space", comment: "ii Overview" },
                { mods: ["Super"], key: "G", comment: "ii Overlay" },
                { mods: ["Super"], key: "V", comment: "Clipboard" },
                { mods: ["Super"], key: "Comma", comment: "Settings" },
                { mods: ["Super"], key: "Slash", comment: "Cheatsheet" },
                { mods: ["Super", "Alt"], key: "L", comment: "Lock Screen" },
                { mods: ["Ctrl", "Alt"], key: "T", comment: "Wallpaper Selector" }
            ]}]
        },
        {
            name: "Window Switcher",
            children: [{ keybinds: [
                { mods: ["Alt"], key: "Tab", comment: "Next window" },
                { mods: ["Alt", "Shift"], key: "Tab", comment: "Previous window" }
            ]}]
        },
        {
            name: "Region Tools",
            children: [{ keybinds: [
                { mods: ["Super", "Shift"], key: "S", comment: "Screenshot region" },
                { mods: ["Super", "Shift"], key: "X", comment: "OCR region" },
                { mods: ["Super", "Shift"], key: "A", comment: "Reverse image search" }
            ]}]
        },
        {
            name: "Applications",
            children: [{ keybinds: [
                { mods: ["Super"], key: "T", comment: "Terminal" },
                { mods: ["Super"], key: "Return", comment: "Terminal" },
                { mods: ["Super"], key: "E", comment: "File manager" }
            ]}]
        },
        {
            name: "Window Management",
            children: [{ keybinds: [
                { mods: ["Super"], key: "Q", comment: "Close window" },
                { mods: ["Super"], key: "D", comment: "Maximize column" },
                { mods: ["Super"], key: "F", comment: "Fullscreen" },
                { mods: ["Super"], key: "A", comment: "Toggle floating" }
            ]}]
        },
        {
            name: "Focus",
            children: [{ keybinds: [
                { mods: ["Super"], key: "←/→/↑/↓", comment: "Focus direction" },
                { mods: ["Super"], key: "H/J/K/L", comment: "Focus (vim)" }
            ]}]
        },
        {
            name: "Move Windows",
            children: [{ keybinds: [
                { mods: ["Super", "Shift"], key: "←/→/↑/↓", comment: "Move direction" },
                { mods: ["Super", "Shift"], key: "H/J/K/L", comment: "Move (vim)" }
            ]}]
        },
        {
            name: "Workspaces",
            children: [{ keybinds: [
                { mods: ["Super"], key: "1-9", comment: "Focus workspace" },
                { mods: ["Super", "Shift"], key: "1-5", comment: "Move to workspace" }
            ]}]
        },
        {
            name: "Screenshots",
            children: [{ keybinds: [
                { mods: [], key: "Print", comment: "Screenshot (select)" },
                { mods: ["Ctrl"], key: "Print", comment: "Screenshot screen" },
                { mods: ["Alt"], key: "Print", comment: "Screenshot window" }
            ]}]
        },
        {
            name: "Media",
            children: [{ keybinds: [
                { mods: [], key: "Vol+", comment: "Volume up" },
                { mods: [], key: "Vol-", comment: "Volume down" },
                { mods: [], key: "Mute", comment: "Mute audio" }
            ]}]
        }
    ]

    Component.onCompleted: {
        console.info("[NiriKeybinds] Loaded", defaultKeybinds.length, "keybind categories")
    }
}
