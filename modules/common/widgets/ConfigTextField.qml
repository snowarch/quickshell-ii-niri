import qs.modules.common
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    property string icon
    property string label: ""
    property alias text: textField.text
    property alias placeholderText: textField.placeholderText
    property alias echoMode: textField.echoMode

    spacing: 10
    Layout.fillWidth: true
    Layout.leftMargin: 8
    Layout.rightMargin: 8

    RowLayout {
        spacing: 10
        Layout.fillWidth: false
        
        OptionalMaterialSymbol {
            icon: root.icon
            iconSize: Appearance.font.pixelSize.larger
            opacity: root.enabled ? 1 : 0.4
        }
        StyledText {
            visible: root.label !== ""
            text: root.label
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnSecondaryContainer
            opacity: root.enabled ? 1 : 0.4
        }
    }

    MaterialTextField {
        id: textField
        Layout.fillWidth: true
        font.pixelSize: Appearance.font.pixelSize.small
    }
}
