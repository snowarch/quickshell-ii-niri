pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.modules.waffle.looks
import qs.modules.waffle.bar

WButton {
    id: root
    required property QsMenuEntry menuEntry
    property bool forceIconColumn: false
    property bool forceSpecialInteractionColumn: false
    readonly property bool hasIcon: menuEntry.icon.length > 0
    readonly property bool hasSpecialInteraction: menuEntry.buttonType !== QsMenuButtonType.None

    signal dismiss()
    signal openSubmenu(handle: QsMenuHandle)

    Layout.fillWidth: true
    Layout.topMargin: menuEntry.isSeparator ? 2 : 0
    Layout.bottomMargin: menuEntry.isSeparator ? 2 : 0
    
    inset: 2
    enabled: !menuEntry.isSeparator && menuEntry.enabled
    visible: !menuEntry.isSeparator
    
    // Hover más visible con accent color
    colBackground: "transparent"
    colBackgroundHover: ColorUtils.transparentize(Looks.colors.accent, 0.85)
    colBackgroundActive: ColorUtils.transparentize(Looks.colors.accent, 0.7)
    
    text: menuEntry.text
    horizontalPadding: 10
    verticalPadding: 6
    
    font.pixelSize: Looks.font.pixelSize.small

    onClicked: {
        if (menuEntry.hasChildren) {
            root.openSubmenu(root.menuEntry);
            return;
        }
        menuEntry.triggered();
        root.dismiss();
    }

    contentItem: RowLayout {
        spacing: 8

        // Checkbox/Radio indicator
        Item {
            visible: root.hasSpecialInteraction || root.forceSpecialInteractionColumn
            implicitWidth: 16
            implicitHeight: 16

            MaterialSymbol {
                anchors.centerIn: parent
                visible: root.menuEntry.buttonType === QsMenuButtonType.RadioButton && root.menuEntry.checkState === Qt.Checked
                text: "radio_button_checked"
                iconSize: 16
                color: Looks.colors.accent
            }

            MaterialSymbol {
                anchors.centerIn: parent
                visible: root.menuEntry.buttonType === QsMenuButtonType.CheckBox && root.menuEntry.checkState !== Qt.Unchecked
                text: root.menuEntry.checkState === Qt.PartiallyChecked ? "indeterminate_check_box" : "check_box"
                iconSize: 16
                color: Looks.colors.accent
            }
        }

        // Menu item icon
        Item {
            visible: root.hasIcon || root.forceIconColumn
            implicitWidth: 16
            implicitHeight: 16

            IconImage {
                anchors.centerIn: parent
                visible: root.menuEntry.icon.length > 0
                asynchronous: true
                source: root.menuEntry.icon
                implicitSize: 16
                mipmap: true
            }
        }

        // Menu item text
        WText {
            text: root.menuEntry.text
            font.pixelSize: Looks.font.pixelSize.small
            color: root.fgColor
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        // Submenu arrow
        FluentIcon {
            visible: root.menuEntry.hasChildren
            icon: "chevron-right"
            implicitSize: 10
            color: root.fgColor
        }
    }
}
