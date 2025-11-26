import qs.modules.common
import QtQuick

/**
 * Recreation of GTK revealer. Expects one single child.
 */
Item {
    id: root
    property bool reveal
    property bool vertical: false
    clip: true

    implicitWidth: (reveal || vertical) ? (children.length > 0 ? children[0].implicitWidth : 0) : 0
    implicitHeight: (reveal || !vertical) ? (children.length > 0 ? children[0].implicitHeight : 0) : 0
    visible: reveal || (implicitWidth > 0 && implicitHeight > 0)

    Behavior on implicitWidth {
        enabled: !vertical
        animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
    }
    Behavior on implicitHeight {
        enabled: vertical
        animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
    }
}
