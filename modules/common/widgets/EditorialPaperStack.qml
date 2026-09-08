pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.common

Item {
    id: root

    property color faceColor: Appearance.editorial.paper
    property real radius: Appearance.editorial.radius
    property real topLeftRadius: radius
    property real topRightRadius: radius
    property real bottomLeftRadius: radius
    property real bottomRightRadius: radius
    readonly property real depth: Math.min(Appearance.editorial.paperDepth, width / 8, height / 8)

    visible: Appearance.editorialEverywhere && Appearance.editorial.paperStack

    // Both sheets stay inside the host's mask and input geometry.
    Rectangle {
        anchors.fill: parent
        radius: root.radius
        topLeftRadius: root.topLeftRadius
        topRightRadius: root.topRightRadius
        bottomLeftRadius: root.bottomLeftRadius
        bottomRightRadius: root.bottomRightRadius
        color: Appearance.editorial.paperBacking
    }

    Rectangle {
        anchors.fill: parent
        anchors.rightMargin: root.depth
        anchors.bottomMargin: root.depth
        radius: root.radius
        topLeftRadius: root.topLeftRadius
        topRightRadius: root.topRightRadius
        bottomLeftRadius: root.bottomLeftRadius
        bottomRightRadius: root.bottomRightRadius
        color: root.faceColor
    }
}
