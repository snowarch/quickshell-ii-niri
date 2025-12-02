import QtQuick
import qs
import qs.services
import qs.modules.common
import qs.modules.waffle.looks

Rectangle {
    id: root
    implicitWidth: 6
    implicitHeight: parent.height
    color: hoverArea.containsMouse ? Looks.colors.bg1 : "transparent"

    Behavior on color { animation: Looks.transition.color.createObject(this) }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if (CompositorService.isNiri) {
                NiriService.toggleOverview()
            } else {
                GlobalStates.overviewOpen = !GlobalStates.overviewOpen
            }
        }
    }

    BarToolTip {
        extraVisibleCondition: hoverArea.containsMouse
        text: Translation.tr("Show desktop")
    }
}
