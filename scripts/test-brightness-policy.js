#!/usr/bin/env node
const fs = require("fs")
const path = require("path")
const vm = require("vm")

const file = path.resolve(__dirname, "../services/brightnessPolicy.js")
const src = fs.readFileSync(file, "utf8").replace(/^\.pragma library\s*/, "")
const ctx = {}
vm.runInNewContext(src, ctx)

function assert(cond, msg) {
    if (!cond) {
        console.error("fail:", msg)
        process.exit(1)
    }
}

assert(ctx.isExternalOutput("HDMI-A-1") === true, "HDMI is external")
assert(ctx.isExternalOutput("DP-3") === true, "DP is external")
assert(ctx.isExternalOutput("eDP-1") === false, "eDP is internal")
assert(ctx.isExternalOutput("DSI-1") === false, "DSI is internal")

const off = ctx.niriPowerOffMonitorsArgs()
const on = ctx.niriPowerOnMonitorsArgs()
const outOff = ctx.niriOutputOffArgs("HDMI-A-1")
const outOn = ctx.niriOutputOnArgs("HDMI-A-1")

assert(off.join(" ").includes("power-off-monitors"), "sleep uses niri dpms")
assert(on.join(" ").includes("power-on-monitors"), "wake uses niri power-on")
assert(outOff.join(" ") === "niri msg output HDMI-A-1 off", "externals are disabled so hpd cannot reconnect")
assert(outOn.join(" ") === "niri msg output HDMI-A-1 on", "wake re-enables externals")
assert(ctx.shouldRetryWakeOutput(0, 15) === true, "first wake output-on retries")
assert(ctx.shouldRetryWakeOutput(14, 15) === true, "retries until limit")
assert(ctx.shouldRetryWakeOutput(15, 15) === false, "stop at limit")
assert(ctx.wakeOutputRetryLimit() >= 10, "enough retries to cover hpd delay")

const disabled = ctx.disabledExternalOutputNames(JSON.stringify({
    "HDMI-A-1": { current_mode: null },
    "eDP-1": { current_mode: { width: 1920 } },
    "DP-3": { current_mode: null },
}))
assert(disabled.includes("HDMI-A-1"), "wake must see disabled HDMI in niri json")
assert(disabled.includes("DP-3"), "wake must see disabled DP")
assert(!disabled.includes("eDP-1"), "eDP is not an external to force-on")

const merged = ctx.mergeOutputNames(["HDMI-A-1"], ["HDMI-A-1", "DP-1"])
assert(merged.join(",") === "HDMI-A-1,DP-1", "wake retries remembered plus currently disabled")

const idleQml = fs.readFileSync(path.resolve(__dirname, "../services/Idle.qml"), "utf8")
assert(!idleQml.includes("idle-blank"), "Idle.qml must not paint a fake overlay")
assert(!idleQml.includes("WlrLayershell"), "Idle.qml must not keep a blank layer")

const brightnessQml = fs.readFileSync(path.resolve(__dirname, "../services/Brightness.qml"), "utf8")
assert(brightnessQml.includes("niriPowerOffMonitorsArgs"), "sleepBegin must dpms")
assert(brightnessQml.includes("niriOutputOffArgs"), "sleepBegin disables external outputs")
assert(brightnessQml.includes("_tryWakeOutputs"), "wake retries output on")
assert(brightnessQml.includes("wakeRetryTimer"), "wake retries on a timer")
assert(brightnessQml.includes("disabledExternalOutputNames"), "wake reads niri json for disabled hdmi")
assert(!brightnessQml.includes("sleepPowerOff"), "ddc/backlight sleep path is gone")

console.log("ok")
