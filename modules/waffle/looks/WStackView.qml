import QtQuick
import QtQuick.Controls
import qs.modules.waffle.looks

StackView {
    id: root
    
    // Animation configuration
    property real moveDistance: 24
    property real scaleFrom: 0.96
    property int pushDuration: Looks.transition.enabled ? Looks.transition.duration.medium : 0
    property int fadeDuration: Looks.transition.enabled ? (Looks.transition.duration.normal) : 0
    property list<real> enterCurve: Looks.transition.easing.bezierCurve.decelerate
    property list<real> exitCurve: Looks.transition.easing.bezierCurve.accelerate
    
    clip: true
    background: null

    // Push: new page slides in from left with scale
    pushEnter: Transition {
        ParallelAnimation {
            XAnimator {
                from: -root.moveDistance
                to: 0
                duration: root.pushDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.enterCurve
            }
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: root.fadeDuration
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                property: "scale"
                from: root.scaleFrom
                to: 1
                duration: root.pushDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.enterCurve
            }
        }
    }
    
    // Push exit: old page fades and scales down slightly
    pushExit: Transition {
        ParallelAnimation {
            XAnimator {
                from: 0
                to: root.moveDistance * 0.5
                duration: root.pushDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.exitCurve
            }
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: root.fadeDuration
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                property: "scale"
                from: 1
                to: 1.02
                duration: root.pushDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.exitCurve
            }
        }
    }
    
    // Pop: returning page slides in from right
    popEnter: Transition {
        ParallelAnimation {
            XAnimator {
                from: root.moveDistance
                to: 0
                duration: root.pushDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.enterCurve
            }
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: root.fadeDuration
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                property: "scale"
                from: 1.02
                to: 1
                duration: root.pushDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.enterCurve
            }
        }
    }
    
    // Pop exit: current page slides out to left
    popExit: Transition {
        ParallelAnimation {
            XAnimator {
                from: 0
                to: -root.moveDistance
                duration: root.pushDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.exitCurve
            }
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: root.fadeDuration
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                property: "scale"
                from: 1
                to: root.scaleFrom
                duration: root.pushDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.exitCurve
            }
        }
    }
}
