.pragma library

function resolveHardwareBrightness(current, max, lastGood) {
    const hasLast = Number.isFinite(lastGood) && lastGood >= 0.01
    const maxOk = Number.isFinite(max) && max > 0
    const currentOk = Number.isFinite(current)
    if (!maxOk || !currentOk) {
        return {
            value: hasLast ? lastGood : Number.NaN,
            restore: hasLast,
            rawMax: maxOk ? max : undefined,
        }
    }
    const normalized = current / max
    if (current <= 0 || normalized < 0.01) {
        return {
            value: hasLast ? lastGood : Number.NaN,
            restore: hasLast,
            rawMax: max,
        }
    }
    return {
        value: normalized,
        restore: false,
        rawMax: max,
    }
}

function pickRestoreValue(lastGood, currentBrightness) {
    if (Number.isFinite(lastGood) && lastGood >= 0.01)
        return lastGood
    if (Number.isFinite(currentBrightness) && currentBrightness >= 0.01)
        return currentBrightness
    return Number.NaN
}

function isExternalOutput(name) {
    const n = String(name || "").toUpperCase()
    if (!n)
        return false
    if (n.startsWith("EDP") || n.startsWith("DSI") || n.startsWith("LVDS"))
        return false
    return n.startsWith("HDMI") || n.startsWith("DP") || n.startsWith("DISPLAYPORT")
}

function niriPowerOffMonitorsArgs() {
    return ["niri", "msg", "action", "power-off-monitors"]
}

function niriPowerOnMonitorsArgs() {
    return ["niri", "msg", "action", "power-on-monitors"]
}

function niriOutputOffArgs(name) {
    return ["niri", "msg", "output", String(name), "off"]
}

function niriOutputOnArgs(name) {
    return ["niri", "msg", "output", String(name), "on"]
}
