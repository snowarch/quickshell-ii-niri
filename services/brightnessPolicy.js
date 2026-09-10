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

function wakeOutputRetryLimit() {
    return 25
}

function wakeOutputRetryMs() {
    return 400
}

function shouldRetryWakeOutput(attempt, limit) {
    const cap = Number.isFinite(limit) ? limit : wakeOutputRetryLimit()
    return attempt < cap
}

function disabledExternalOutputNames(jsonText) {
    let data
    try {
        data = JSON.parse(jsonText)
    } catch (e) {
        return []
    }
    if (!data || typeof data !== "object")
        return []
    const names = []
    const keys = Object.keys(data)
    for (let i = 0; i < keys.length; ++i) {
        const name = keys[i]
        if (!isExternalOutput(name))
            continue
        const info = data[name]
        if (!info || info.current_mode == null)
            names.push(name)
    }
    return names
}

function mergeOutputNames(a, b) {
    const out = []
    const seen = {}
    const lists = [a || [], b || []]
    for (let i = 0; i < lists.length; ++i) {
        const list = lists[i]
        for (let j = 0; j < list.length; ++j) {
            const n = list[j]
            if (!n || seen[n])
                continue
            seen[n] = true
            out.push(n)
        }
    }
    return out
}
