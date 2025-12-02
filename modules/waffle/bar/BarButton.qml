import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.functions
import qs.modules.waffle.looks

AcrylicButton {
    id: root

    property var altAction: () => {}
    property var middleClickAction: () => {}

    Layout.fillHeight: true
    topInset: 4
    bottomInset: 4
    leftInset: 0
    rightInset: 0
    horizontalPadding: 8

    colBackground: ColorUtils.transparentize(Looks.colors.bg1)

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.MiddleButton
        propagateComposedEvents: true
        onClicked: event => {
            if (event.button === Qt.RightButton) root.altAction();
            if (event.button === Qt.MiddleButton) root.middleClickAction();
        }
    }
}
