import QtQuick
import QtQuick.Controls
import qs.modules.waffle.looks

StackView {
    id: root
    
    // Animation configuration - Windows 11 style
    property real moveDistance: 20
    property real scaleEnter: 0.97
    property real scaleExit: 1.01
    property int pushDuration: Looks.transition.enabled ? Looks.transition.duration.panel : 0
    property int fadeDuration: Looks.transition.enabled ? Looks.transition.duration.normal : 0
    property list<real> enterCurve: Looks.transition.easing.bezierCurve.decelerate
    property list<real> exitCurve: Looks.transition.easing.bezierCurve.accelerate
    
    clip: true
    background: null

    // Push: new page slides in from right with scale (Windows 11 style)
    pushEnter: Transition {
        enabled: Looks.transition.enabled
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
                from: root.scaleEnter
                to: 1
                duration: root.pushDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.enterCurve
            }
        }
    }
    
    // Push exit: old page fades back
    pushExit: Transition {
        enabled: Looks.transition.enabled
        ParallelAnimation {
            XAnimator {
                from: 0
                to: -root.moveDistance * 0.4
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
                to: root.scaleExit
                duration: root.pushDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.exitCurve
            }
        }
    }
    
    // Pop: returning page slides in from left
    popEnter: Transition {
        enabled: Looks.transition.enabled
        ParallelAnimation {
            XAnimator {
                from: -root.moveDistance * 0.4
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
                from: root.scaleExit
                to: 1
                duration: root.pushDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.enterCurve
            }
        }
    }
    
    // Pop exit: current page slides out to right
    popExit: Transition {
        enabled: Looks.transition.enabled
        ParallelAnimation {
            XAnimator {
                from: 0
                to: root.moveDistance
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
                to: root.scaleEnter
                duration: root.pushDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.exitCurve
            }
        }
    }
}
