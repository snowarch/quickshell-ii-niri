pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.common
import qs.modules.common.widgets

SelectionGroupButton {
    id: root
    implicitHeight: 32
    StyledToolTip { text: root.buttonText }
}
