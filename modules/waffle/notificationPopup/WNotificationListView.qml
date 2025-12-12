pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.modules.common
import qs.modules.waffle.looks
import qs.services

/**
 * Windows 11 style notification list with smooth transitions
 */
ListView {
    id: root

    spacing: 8
    cacheBuffer: 300

    property int dragIndex: -1
    property real dragDistance: 0

    function resetDrag() {
        dragIndex = -1
        dragDistance = 0
    }

    // Smooth add transition - slide in from right with scale
    add: Transition {
        enabled: Looks.transition.enabled
        ParallelAnimation {
            NumberAnimation { 
                property: "opacity"
                from: 0; to: 1
                duration: Looks.transition.duration.medium
                easing.type: Easing.OutQuad
            }
            NumberAnimation { 
                property: "x"
                from: 40; to: 0
                duration: Looks.transition.duration.panel
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Looks.transition.easing.bezierCurve.decelerate
            }
            NumberAnimation {
                property: "scale"
                from: 0.92; to: 1
                duration: Looks.transition.duration.panel
                easing.type: Easing.OutBack
                easing.overshoot: 0.15
            }
        }
    }

    // Smooth remove transition - slide out to right
    remove: Transition {
        enabled: Looks.transition.enabled
        ParallelAnimation {
            NumberAnimation { 
                property: "opacity"
                from: 1; to: 0
                duration: Looks.transition.duration.normal
                easing.type: Easing.InQuad
            }
            NumberAnimation { 
                property: "x"
                from: 0; to: 60
                duration: Looks.transition.duration.medium
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Looks.transition.easing.bezierCurve.accelerate
            }
            NumberAnimation {
                property: "scale"
                from: 1; to: 0.95
                duration: Looks.transition.duration.medium
                easing.type: Easing.InQuad
            }
        }
    }

    // Smooth reposition when items move
    displaced: Transition {
        enabled: Looks.transition.enabled
        NumberAnimation { 
            properties: "x,y"
            duration: Looks.transition.duration.medium
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Looks.transition.easing.bezierCurve.standard
        }
    }

    model: ScriptModel {
        values: Notifications.popupAppNameList
    }

    delegate: WNotificationGroup {
        required property int index
        required property var modelData

        width: root.width
        notificationGroup: Notifications.popupGroupsByAppName[modelData]
        qmlParent: root
    }
}
