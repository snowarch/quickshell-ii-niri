import QtQuick
import QtQuick.Layouts
import qs.modules.waffle.looks

Item {
    id: root

    property int gap: 3
    property int verticalInset: 24
    property real lineOpacity: 0.4

    Layout.fillHeight: true
    Layout.preferredWidth: (gap * 2) + 1

    Rectangle {
        anchors.centerIn: parent
        width: 1
        height: Math.max(0, parent.height - root.verticalInset)
        radius: 1
        color: Looks.colors.bg1Border
        opacity: root.lineOpacity
    }
}
