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

const off = ctx.ddcPowerOffArgs("1")
const bl = ctx.backlightOffArgs("amdgpu_bl1")

assert(Array.isArray(off) && off[0] === "ddcutil", "ddc off uses ddcutil")
assert(off.includes("10") && off.includes("0"), "ddc off is VCP 10 0, not D6 (D6 drops HPD)")
assert(off.includes("--noverify"), "ddc off skips verify at zero")
assert(!off.join(" ").includes("D6"), "must not use DDC power mode D6")
assert(!off.includes("power-off-monitors"), "ddc off must not use niri dpms")
assert(bl[0] === "brightnessctl" && bl.includes("0"), "backlight off writes 0")

const idleQml = fs.readFileSync(path.resolve(__dirname, "../services/Idle.qml"), "utf8")
assert(!idleQml.includes("idle-blank"), "Idle.qml must not paint a fake overlay")
assert(!idleQml.includes("WlrLayershell"), "Idle.qml must not keep a blank layer")

const brightnessQml = fs.readFileSync(path.resolve(__dirname, "../services/Brightness.qml"), "utf8")
assert(brightnessQml.includes("sleepPowerOff"), "sleepBegin drives hardware power-off")
assert(!brightnessQml.includes("power-off-monitors"), "Brightness.qml must not use niri dpms")

console.log("ok")
