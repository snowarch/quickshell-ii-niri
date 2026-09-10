#!/usr/bin/env node
const fs = require("fs")
const path = require("path")

function assert(cond, msg) {
    if (!cond) {
        console.error("fail:", msg)
        process.exit(1)
    }
}

function positionHead(src) {
    const i = src.indexOf("onPositionChanged")
    assert(i >= 0, "onPositionChanged missing")
    return src.slice(i, i + 280)
}

const ii = fs.readFileSync(path.resolve(__dirname, "../modules/lock/LockSurface.qml"), "utf8")
const waffle = fs.readFileSync(path.resolve(__dirname, "../modules/waffle/lock/WaffleLockSurface.qml"), "utf8")
for (const [name, src] of [["ii", ii], ["waffle", waffle]]) {
    const head = positionHead(src)
    assert(head.includes("restoreAfterWake"), `${name} pointer while asleep must restoreAfterWake`)
    assert(!/if \(Brightness\.asleep\)\s*\n\s*return/.test(head), `${name} must not ignore asleep pointer`)
}

console.log("ok")
