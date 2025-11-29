import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

RowLayout {
    id: root
    required property string label
    required property string colorKey
    signal colorChanged()

    property color currentColor: Config.options?.appearance?.customTheme?.[colorKey] ?? "#888888"

    Layout.fillWidth: true
    spacing: 8

    StyledText {
        Layout.preferredWidth: 100
        text: root.label
        font.pixelSize: Appearance.font.pixelSize.smaller
        color: Appearance.colors.colOnLayer1
        elide: Text.ElideRight
    }

    RippleButton {
        Layout.preferredWidth: 36
        Layout.preferredHeight: 28
        buttonRadius: Appearance.rounding.small
        colBackground: root.currentColor
        onClicked: colorDialog.open()

        Rectangle {
            anchors.fill: parent
            radius: Appearance.rounding.small
            color: "transparent"
            border.color: Appearance.colors.colOutline
            border.width: 1
        }
    }

    StyledText {
        Layout.fillWidth: true
        text: root.currentColor.toString().toUpperCase().substring(0, 7)
        font.pixelSize: Appearance.font.pixelSize.smallest
        font.family: "monospace"
        color: Appearance.colors.colSubtext
    }

    ColorDialog {
        id: colorDialog
        selectedColor: root.currentColor
        onAccepted: {
            Config.options.appearance.customTheme[root.colorKey] = selectedColor.toString()
            root.colorChanged()
        }
    }
}
