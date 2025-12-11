import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root
    required property string label
    required property string colorKey
    signal colorChanged()

    property color currentColor: Config.options?.appearance?.customTheme?.[colorKey] ?? "#888888"

    Layout.fillWidth: true
    implicitHeight: column.implicitHeight

    ColumnLayout {
        id: column
        anchors.fill: parent
        spacing: 4

        StyledText {
            text: root.label
            font.pixelSize: Appearance.font.pixelSize.smallest
            color: Appearance.colors.colSubtext
        }

        RippleButton {
            Layout.fillWidth: true
            implicitHeight: 36
            colBackground: Appearance.colors.colLayer2
            colBackgroundHover: Appearance.colors.colLayer2Hover
            colRipple: Appearance.colors.colLayer2Active

            contentItem: RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 8

                Rectangle {
                    width: 18
                    height: 18
                    radius: 9
                    color: root.currentColor
                    border.width: 1
                    border.color: Appearance.colors.colOutline
                }

                StyledText {
                    Layout.fillWidth: true
                    text: root.currentColor.toString().toUpperCase().substring(0, 7)
                    font.pixelSize: Appearance.font.pixelSize.smallest
                    font.family: Appearance.font.family.monospace
                    elide: Text.ElideRight
                }

                MaterialSymbol {
                    text: "edit"
                    iconSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }
            }

            onClicked: colorDialog.open()
        }
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
