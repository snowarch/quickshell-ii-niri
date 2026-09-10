pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root
    required property var widget
    property bool wide: false
    spacing: 8
    implicitWidth: 320

    StyledText {
        Layout.fillWidth: true
        text: Translation.tr("Anchor to display")
        color: Appearance.colors.colSubtext
        font.pixelSize: Appearance.font.pixelSize.smaller
    }
    RowLayout {
        Layout.fillWidth: true
        spacing: 10
        GridLayout {
            Layout.preferredWidth: 112
            columns: 3
            columnSpacing: 4
            rowSpacing: 4
            Repeater {
                model: root.widget._snapZones
                WidgetEditAction {
                    required property string modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    iconName: ({topLeft: "north_west", topCenter: "north", topRight: "north_east",
                        centerLeft: "west", center: "center_focus_strong", centerRight: "east",
                        bottomLeft: "south_west", bottomCenter: "south", bottomRight: "south_east"})[modelData]
                    label: ""
                    toggled: root.widget.placementStrategy === modelData
                    tooltip: Translation.tr(({topLeft: "Top left", topCenter: "Top center", topRight: "Top right",
                        centerLeft: "Center left", center: "Center", centerRight: "Center right",
                        bottomLeft: "Bottom left", bottomCenter: "Bottom center", bottomRight: "Bottom right"})[modelData])
                    onClicked: root.widget.snapToZone(modelData)
                }
            }
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4
            WidgetEditAction {
                Layout.fillWidth: true
                iconName: "open_with"; label: Translation.tr("Free")
                toggled: root.widget.placementStrategy === "free"
                onClicked: root.widget._setOutputValues({placementStrategy: "free",
                    x: Math.round(root.widget.x), y: Math.round(root.widget.y)})
            }
            WidgetEditAction {
                Layout.fillWidth: true
                iconName: "layers"; label: Translation.tr("To front")
                onClicked: root.widget._bringToFront()
            }
        }
    }
    RowLayout {
        Layout.fillWidth: true
        StyledText {
            text: Translation.tr("Nudge")
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnLayer2
            Layout.fillWidth: true
        }
        Repeater {
            model: [{iconName: "west", x: -1, y: 0}, {iconName: "north", x: 0, y: -1},
                {iconName: "south", x: 0, y: 1}, {iconName: "east", x: 1, y: 0}]
            WidgetEditAction {
                required property var modelData
                iconName: modelData.iconName; compact: true
                tooltip: Translation.tr("Move by one pixel")
                onClicked: root.widget.nudge(modelData.x, modelData.y)
            }
        }
    }
    GridLayout {
        Layout.fillWidth: true
        columns: root.wide ? 4 : 2
        columnSpacing: 8
        rowSpacing: 8
        StyledText {
            text: Translation.tr("Scale") + " %"
            color: Appearance.colors.colOnLayer2
            font.pixelSize: Appearance.font.pixelSize.small
        }
        StyledSpinBox {
            Layout.fillWidth: true
            from: 50; to: 200; stepSize: 5
            value: Math.round(root.widget.scaleFactor * 100)
            onValueModified: root.widget._setOutputValue("widgetScale", value)
        }
        StyledText {
            text: Translation.tr("Opacity") + " %"
            color: Appearance.colors.colOnLayer2
            font.pixelSize: Appearance.font.pixelSize.small
        }
        StyledSpinBox {
            Layout.fillWidth: true
            from: 10; to: 100; stepSize: 5
            value: Math.round(root.widget.widgetOpacity * 100)
            onValueModified: root.widget._setOutputValue("widgetOpacity", value)
        }
    }
    StyledText {
        Layout.fillWidth: true
        text: Math.round(root.widget.width) + " × " + Math.round(root.widget.height)
            + " px   ·   X " + Math.round(root.widget.x) + "   Y " + Math.round(root.widget.y)
        color: Appearance.colors.colSubtext
        font.family: Appearance.font.family.numbers
        font.pixelSize: Appearance.font.pixelSize.smaller
        elide: Text.ElideRight
    }
}
