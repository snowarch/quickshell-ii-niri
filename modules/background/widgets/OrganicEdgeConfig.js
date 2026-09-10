.pragma library

var path = "background.edgeWidgets.organic"
var defaults = {
    enable: false, edge: "bottom", edges: [], screenList: [],
    span: 70, position: 50, depth: 180, inset: 0, respectPanels: false,
    topScale: 100, rightScale: 100, bottomScale: 100, leftScale: 100,
    cornerRadius: 24, taper: 14, thickness: 22, detail: 42,
    style: "silk", shape: "flow", palette: "theme", colorMode: "flow", effectMode: "clean",
    joinMode: "auto",
    primaryColor: "#b5a0ff",
    secondaryColor: "#64dbcf", tertiaryColor: "#ffb2cf", colorSpeed: 35,
    hueShift: 0, colorIntensity: 100, effectStrength: 38,
    opacity: 100, bodyOpacity: 32, crestStrength: 90, glow: 52, glowSpread: 48,
    smoothing: 2, frequencyProfile: "flat", accentStrength: 70,
    sensitivity: 72, audioRange: 78, pulse: 90, beatGlow: 64, transientStrength: 90,
    bassDrive: 88, trebleDrive: 68, attack: 105, release: 82,
    compression: 12, motionSpeed: 100, idleMotion: 14,
    audioReactive: true, idleMode: "ambient"
}

var presets = [
    {name: "Silk Horizon", icon: "waves", description: "Elegant music ribbon along the lower edge",
        values: {style: "silk", shape: "ribbon", palette: "adaptive", colorMode: "flow", effectMode: "shimmer", joinMode: "auto",
            effectStrength: 44, edges: ["bottom"], span: 88, depth: 184, thickness: 21, taper: 18,
            detail: 46, bodyOpacity: 24, crestStrength: 98, glow: 48, glowSpread: 48,
            audioRange: 82, sensitivity: 76, pulse: 90, beatGlow: 62, transientStrength: 92,
            bassDrive: 86, trebleDrive: 76, attack: 112, release: 78, compression: 14,
            motionSpeed: 84, idleMotion: 16, opacity: 92, colorSpeed: 30}},
    {name: "Aurora Rails", icon: "flare", description: "Two luminous rails with airy high-frequency motion",
        values: {style: "aurora", shape: "filament", palette: "wallpaper", colorMode: "spectrum", effectMode: "echo", joinMode: "auto",
            effectStrength: 54, edges: ["left", "right"], span: 100, depth: 224, thickness: 18,
            taper: 8, detail: 62, bodyOpacity: 17, crestStrength: 86, glow: 80, glowSpread: 80,
            audioRange: 72, sensitivity: 72, pulse: 70, beatGlow: 94, transientStrength: 76,
            bassDrive: 68, trebleDrive: 108, attack: 86, release: 64, compression: 20,
            motionSpeed: 64, idleMotion: 22, opacity: 84, colorSpeed: 22}},
    {name: "Neon Frame", icon: "select_all", description: "A complete reactive frame with crisp club-like light",
        values: {style: "contour", shape: "filament", palette: "vivid", colorMode: "pulse", effectMode: "prism", joinMode: "auto",
            effectStrength: 58, edges: ["top", "right", "bottom", "left"], span: 100, depth: 126,
            thickness: 15, taper: 0, detail: 44, bodyOpacity: 6, crestStrength: 124,
            glow: 58, glowSpread: 46, audioRange: 76, sensitivity: 78, pulse: 104, beatGlow: 112,
            transientStrength: 124, bassDrive: 82, trebleDrive: 112, attack: 142, release: 98,
            compression: 26, smoothing: 1, motionSpeed: 72, idleMotion: 8, opacity: 94, colorSpeed: 18}},
    {name: "Ember Pulse", icon: "local_fire_department", description: "Warm low-end pulses with a dense liquid crest",
        values: {style: "liquid", shape: "cells", palette: "warm", colorMode: "pulse", effectMode: "bloom", joinMode: "auto",
            effectStrength: 64, edges: ["bottom", "left"], span: 100, depth: 214, thickness: 24,
            taper: 8, detail: 66, bodyOpacity: 38, crestStrength: 102, glow: 72, glowSpread: 60,
            audioRange: 98, sensitivity: 84, pulse: 122, beatGlow: 104, transientStrength: 120,
            bassDrive: 132, trebleDrive: 56, attack: 132, release: 84, compression: 12,
            smoothing: 2, motionSpeed: 116, idleMotion: 18, opacity: 88, colorSpeed: 24}},
    {name: "Album Aura", icon: "album", description: "Artwork colors flow through a cinematic music ribbon",
        values: {style: "silk", shape: "ribbon", palette: "album", colorMode: "spectrum", effectMode: "shimmer", joinMode: "auto",
            effectStrength: 48, edges: ["bottom"], span: 94, depth: 224, thickness: 21,
            taper: 12, detail: 50, bodyOpacity: 20, crestStrength: 92, glow: 62, glowSpread: 68,
            audioRange: 78, sensitivity: 72, pulse: 80, beatGlow: 70, transientStrength: 84,
            bassDrive: 84, trebleDrive: 86, attack: 104, release: 74, compression: 16,
            smoothing: 2, motionSpeed: 72, idleMotion: 16, opacity: 88, colorSpeed: 20}},
    {name: "Spectrum Crown", icon: "multiline_chart", description: "Fine detail and treble shimmer across the top edge",
        values: {style: "aurora", shape: "filament", palette: "adaptive", colorMode: "spectrum", effectMode: "shimmer", joinMode: "auto",
            effectStrength: 70, edges: ["top"], span: 94, depth: 166, thickness: 14,
            taper: 14, detail: 82, bodyOpacity: 10, crestStrength: 112, glow: 62, glowSpread: 46,
            audioRange: 82, sensitivity: 76, pulse: 58, beatGlow: 78, transientStrength: 118,
            bassDrive: 48, trebleDrive: 142, attack: 148, release: 124, compression: 32,
            smoothing: 1, motionSpeed: 94, idleMotion: 10, opacity: 92, colorSpeed: 34}},
    {name: "Ghost Frame", icon: "filter_vintage", description: "Minimal ambient outline for quiet desktops",
        values: {style: "contour", shape: "ribbon", palette: "mono", colorMode: "static", effectMode: "echo", joinMode: "auto",
            effectStrength: 20, edges: ["top", "right", "bottom", "left"], span: 100, depth: 92,
            thickness: 11, taper: 0, detail: 24, bodyOpacity: 3, crestStrength: 72, glow: 24,
            glowSpread: 22, audioRange: 42, sensitivity: 54, pulse: 38, beatGlow: 26,
            transientStrength: 54, bassDrive: 54, trebleDrive: 70, attack: 84, release: 58,
            compression: 12, smoothing: 3, motionSpeed: 34, idleMotion: 5, opacity: 76, colorSpeed: 0}},
    {name: "Club Pulse", icon: "graphic_eq", description: "Fast bass-driven light for music-focused desktops",
        values: {style: "liquid", shape: "cells", palette: "vivid", colorMode: "pulse", effectMode: "bloom", joinMode: "auto",
            effectStrength: 82, edges: ["top", "bottom"], span: 100, depth: 178, thickness: 20,
            taper: 0, detail: 58, bodyOpacity: 22, crestStrength: 126, glow: 84, glowSpread: 64,
            audioRange: 108, sensitivity: 90, pulse: 138, beatGlow: 132, transientStrength: 138,
            bassDrive: 140, trebleDrive: 88, attack: 172, release: 118, compression: 20,
            smoothing: 1, motionSpeed: 128, idleMotion: 8, opacity: 94, colorSpeed: 44}},
    {name: "Wallpaper Tide", icon: "water", description: "Wallpaper-driven ribbon with liquid caustic motion",
        values: {style: "silk", shape: "ribbon", palette: "wallpaper", colorMode: "flow", effectMode: "caustic", joinMode: "auto",
            effectStrength: 58, edges: ["bottom", "right"], span: 100, depth: 206, thickness: 22,
            taper: 14, detail: 54, bodyOpacity: 22, crestStrength: 94, glow: 56, glowSpread: 62,
            audioRange: 88, sensitivity: 76, pulse: 82, beatGlow: 68, transientStrength: 92,
            bassDrive: 90, trebleDrive: 86, attack: 108, release: 72, compression: 16,
            smoothing: 2, motionSpeed: 78, idleMotion: 14, opacity: 90, colorSpeed: 26}},
    {name: "Afterglow Frame", icon: "blur_on", description: "A unified frame whose peaks leave a soft musical afterglow",
        values: {style: "contour", shape: "flow", palette: "adaptive", colorMode: "spectrum", effectMode: "afterglow", joinMode: "auto",
            effectStrength: 66, edges: ["top", "right", "bottom", "left"], span: 100, depth: 148,
            thickness: 14, taper: 0, detail: 48, bodyOpacity: 6, crestStrength: 118, glow: 66,
            glowSpread: 58, audioRange: 82, sensitivity: 78, pulse: 88, beatGlow: 116,
            transientStrength: 118, bassDrive: 72, trebleDrive: 118, attack: 142, release: 116,
            compression: 24, smoothing: 1, motionSpeed: 68, idleMotion: 7, opacity: 92, colorSpeed: 22}}
]

var palettes = [
    {name: "Adaptive", value: "adaptive"}, {name: "Wallpaper", value: "wallpaper"},
    {name: "Album", value: "album"}, {name: "Theme", value: "theme"},
    {name: "Vivid", value: "vivid"}, {name: "Iridescent", value: "iridescent"},
    {name: "Monochrome", value: "mono"}, {name: "Cool", value: "cool"},
    {name: "Warm", value: "warm"}, {name: "Custom", value: "custom"}
]

var shapes = [
    {name: "Flow", value: "flow"}, {name: "Ribbon", value: "ribbon"},
    {name: "Pulse cells", value: "cells"}, {name: "Filament", value: "filament"}
]

var colorModes = [
    {name: "Flow", value: "flow"}, {name: "Spectrum", value: "spectrum"},
    {name: "Beat", value: "pulse"}, {name: "Static", value: "static"}
]

var effects = [
    {name: "Clean", value: "clean"}, {name: "Shimmer", value: "shimmer"},
    {name: "Echo", value: "echo"}, {name: "Prism", value: "prism"},
    {name: "Bloom", value: "bloom"}, {name: "Caustic", value: "caustic"},
    {name: "Afterglow", value: "afterglow"}
]

var responsePresets = [
    {name: "Smooth", icon: "water", values: {sensitivity: 64, audioRange: 62,
        pulse: 58, beatGlow: 42, transientStrength: 52, bassDrive: 74, trebleDrive: 66,
        attack: 72, release: 54, compression: 8, smoothing: 4}},
    {name: "Balanced", icon: "tune", values: {sensitivity: 72, audioRange: 78,
        pulse: 90, beatGlow: 64, transientStrength: 90, bassDrive: 88, trebleDrive: 68,
        attack: 105, release: 82, compression: 12, smoothing: 2}},
    {name: "Punchy", icon: "bolt", values: {sensitivity: 86, audioRange: 100,
        pulse: 118, beatGlow: 96, transientStrength: 132, bassDrive: 102, trebleDrive: 82,
        attack: 150, release: 112, compression: 18, smoothing: 1}},
    {name: "Bass pulse", icon: "graphic_eq", values: {sensitivity: 82, audioRange: 92,
        pulse: 132, beatGlow: 82, transientStrength: 112, bassDrive: 138, trebleDrive: 42,
        attack: 126, release: 88, compression: 14, smoothing: 2}},
    {name: "Fine detail", icon: "multiline_chart", values: {sensitivity: 74, audioRange: 80,
        pulse: 66, beatGlow: 54, transientStrength: 108, bassDrive: 52, trebleDrive: 138,
        attack: 142, release: 126, compression: 28, smoothing: 1}}
]

var geometry = [
    {key: "span", label: "Edge length", min: 10, max: 100, step: 5, unit: "%"},
    {key: "position", label: "Position along edge", min: 0, max: 100, step: 1, unit: "%"},
    {key: "depth", label: "Field depth", min: 24, max: 600, step: 4, unit: "px"},
    {key: "inset", label: "Screen inset", min: 0, max: 160, step: 2, unit: "px"},
    {key: "cornerRadius", label: "Screen corner radius", min: 0, max: 160, step: 2, unit: "px"},
    {key: "taper", label: "Endpoint softness", min: 0, max: 50, step: 1, unit: "%"},
    {key: "topScale", label: "Top reach", min: 10, max: 200, step: 5, unit: "%"},
    {key: "rightScale", label: "Right reach", min: 10, max: 200, step: 5, unit: "%"},
    {key: "bottomScale", label: "Bottom reach", min: 10, max: 200, step: 5, unit: "%"},
    {key: "leftScale", label: "Left reach", min: 10, max: 200, step: 5, unit: "%"}
]
var materialBody = [
    {key: "thickness", label: "Body weight", min: 5, max: 70, step: 1, unit: "%"},
    {key: "bodyOpacity", label: "Body opacity", min: 0, max: 100, step: 5, unit: "%"},
    {key: "crestStrength", label: "Crest brightness", min: 0, max: 150, step: 5, unit: "%"},
    {key: "detail", label: "Contour detail", min: 0, max: 100, step: 5, unit: "%"},
    {key: "opacity", label: "Overall opacity", min: 0, max: 100, step: 5, unit: "%"}
]
var materialLight = [
    {key: "glow", label: "Glow intensity", min: 0, max: 100, step: 5, unit: "%"},
    {key: "glowSpread", label: "Glow spread", min: 0, max: 100, step: 5, unit: "%"},
    {key: "effectStrength", label: "Effect strength", min: 0, max: 100, step: 5, unit: "%"}
]
var colorTuning = [
    {key: "colorSpeed", label: "Color travel", min: 0, max: 100, step: 5, unit: "%"},
    {key: "hueShift", label: "Hue shift", min: -180, max: 180, step: 5, unit: "°"},
    {key: "colorIntensity", label: "Color intensity", min: 0, max: 150, step: 5, unit: "%"}
]
var motion = [
    {key: "motionSpeed", label: "Motion speed", min: 0, max: 250, step: 5, unit: "%"},
    {key: "idleMotion", label: "Ambient motion", min: 0, max: 100, step: 5, unit: "%"}
]
var audioDynamics = [
    {key: "sensitivity", label: "Audio sensitivity", min: 0, max: 200, step: 5, unit: "%"},
    {key: "audioRange", label: "Audio range", min: 0, max: 150, step: 5, unit: "%"},
    {key: "pulse", label: "Beat pulse", min: 0, max: 150, step: 5, unit: "%"},
    {key: "beatGlow", label: "Beat glow", min: 0, max: 150, step: 5, unit: "%"},
    {key: "transientStrength", label: "Transient punch", min: 0, max: 150, step: 5, unit: "%"},
    {key: "attack", label: "Attack speed", min: 20, max: 250, step: 5, unit: "%"},
    {key: "release", label: "Release speed", min: 20, max: 250, step: 5, unit: "%"},
    {key: "smoothing", label: "Audio smoothing", min: 0, max: 8, step: 1, unit: ""}
]
var audioTone = [
    {key: "bassDrive", label: "Bass drive", min: 0, max: 150, step: 5, unit: "%"},
    {key: "trebleDrive", label: "Treble shimmer", min: 0, max: 150, step: 5, unit: "%"},
    {key: "compression", label: "Frequency separation", min: 0, max: 100, step: 5, unit: "%"},
    {key: "accentStrength", label: "Frequency emphasis", min: 0, max: 100, step: 5, unit: "%"}
]

function selectedEdges(configured, legacy) {
    var allowed = ["top", "right", "bottom", "left"]
    var list = []
    if (configured && typeof configured.length === "number") {
        for (var i = 0; i < configured.length; ++i) {
            var edge = String(configured[i])
            if (allowed.indexOf(edge) >= 0 && list.indexOf(edge) < 0)
                list.push(edge)
        }
    }
    return list.length ? list : [allowed.indexOf(legacy) >= 0 ? legacy : "bottom"]
}

function paletteValue(value) {
    var name = String(value || "theme")
    if (name === "neon") return "vivid"
    if (name === "ocean") return "cool"
    if (name === "sunset") return "warm"
    if (name === "forest") return "wallpaper"
    return name
}
