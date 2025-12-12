import QtQuick
import qs.modules.waffle.looks

/**
 * Loader with Windows 11 style page transition animations.
 * Use for switching between pages/views with smooth fade + scale.
 */
Loader {
    id: root
    
    // Animation configuration
    property real scaleInactive: 0.97
    property real scaleActive: 1.0
    property int animDuration: Looks.transition.duration.medium
    property list<real> enterCurve: Looks.transition.easing.bezierCurve.decelerate
    property list<real> exitCurve: Looks.transition.easing.bezierCurve.standard
    
    // Convenience - set this instead of active for animated transitions
    property bool shown: true
    
    // Track if we're animating out (to keep active during exit animation)
    property bool _animatingOut: false
    
    // Active when shown OR when animating out (opacity still > 0)
    active: shown || _animatingOut
    visible: opacity > 0
    opacity: shown ? 1 : 0
    scale: shown ? scaleActive : scaleInactive
    
    // Transform from center for natural feel
    transformOrigin: Item.Center
    
    // Track animation state
    onShownChanged: {
        if (!shown) {
            _animatingOut = true
        }
    }
    
    onOpacityChanged: {
        // When opacity reaches 0, we're done animating out
        if (opacity === 0 && _animatingOut) {
            _animatingOut = false
        }
    }
    
    Behavior on opacity {
        NumberAnimation {
            duration: Looks.transition.enabled ? root.animDuration : 0
            easing.type: Easing.BezierSpline
            easing.bezierCurve: root.shown ? root.enterCurve : root.exitCurve
        }
    }
    
    Behavior on scale {
        NumberAnimation {
            duration: Looks.transition.enabled ? root.animDuration : 0
            easing.type: Easing.BezierSpline
            easing.bezierCurve: root.shown ? root.enterCurve : root.exitCurve
        }
    }
}
