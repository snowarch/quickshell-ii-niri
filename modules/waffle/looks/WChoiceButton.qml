import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.modules.waffle.looks

WButton {
    id: root

    property bool animateChoiceHighlight: true

    Layout.fillWidth: true
    implicitWidth: contentItem.implicitWidth
    horizontalPadding: 10
    verticalPadding: 11
    buttonSpacing: 8

    color: {
        if (root.checked) {
            if (root.down) {
                return root.colBackgroundHover;
            } else if (root.hovered && !root.down) {
                return root.colBackgroundActive;
            } else {
                return root.colBackgroundHover;
            }
        }
        if (root.down) {
            return root.colBackgroundActive;
        } else if (root.hovered && !root.down) {
            return root.colBackgroundHover;
        } else {
            return root.colBackground;
        }
    }
    fgColor: colForeground

    background: Rectangle {
        id: backgroundRect
        radius: Looks.radius.medium
        color: root.color
        Behavior on color {
            animation: Looks.transition.color.createObject(this)
        }

        // Windows 11 style accent indicator with spring animation
        Rectangle {
            id: accentIndicator
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: 3
            radius: width / 2
            color: Looks.colors.accent
            opacity: root.checked ? 1 : 0
            height: root.checked ? Math.max(16, root.background.height - 18 * 2) : 0
            
            Behavior on opacity {
                enabled: root.animateChoiceHighlight
                NumberAnimation {
                    duration: Looks.transition.enabled ? Looks.transition.duration.fast : 0
                    easing.type: Easing.OutQuad
                }
            }
            Behavior on height {
                enabled: root.animateChoiceHighlight
                NumberAnimation {
                    duration: Looks.transition.enabled ? Looks.transition.duration.normal : 0
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Looks.transition.easing.bezierCurve.decelerate
                }
            }
        }
    }
}
