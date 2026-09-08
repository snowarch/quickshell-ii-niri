pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.modules.background.widgets

AbstractBackgroundWidget {
    id: root
    configEntryName: "dateBadge"
    defaultConfig: ({ placementStrategy: "free", contentWidth: 220, contentHeight: 140,
        style: "ticket", showYear: true, widgetScale: 100, widgetOpacity: 100,
        colorMode: "auto", dim: 0, showBackground: true, showBorder: true,
        backgroundOpacity: 0.16, borderWidth: 1, borderOpacity: 0.2,
        cornerRadius: -1, useBlur: false, x: 260, y: 80 })
    implicitWidth: Math.max(140, Number(root._readConfigKey("contentWidth") ?? 220)) * scaleFactor
    implicitHeight: Math.max(120, Number(root._readConfigKey("contentHeight") ?? 140)) * scaleFactor
    resizableAxes: ({ width: "contentWidth", height: "contentHeight" })
    resizeMinWidth: 140
    resizeMinHeight: 120
    needsColText: true
    readonly property string badgeStyle: String(root._readConfigKey("style") ?? "ticket")
    readonly property bool showYear: Boolean(root._readConfigKey("showYear") ?? true)
    readonly property date today: DateTime.clock.date
    readonly property bool horizontal: root.badgeStyle === "ticket" && root.width >= 200 * root.scaleFactor

    WidgetSurface {
        anchors.fill: parent
        visible: root.badgeStyle !== "seal"
        regionBrightness: root.regionBrightness
        surfaceRadius: root.cornerRadiusOverride >= 0 ? root.cornerRadiusOverride : root.widgetCardRadius
        surfaceOpacity: root.backgroundOpacity
        surfaceBorderWidth: root.borderWidth
        surfaceBorderOpacity: root.borderOpacity
        surfaceColor: root.widgetInk
        colorMode: root.colorMode
        surfaceAccent: root.widgetAccent
        surfaceFill: root.widgetPlateColor
        surfaceUseBlur: root.effectiveBlur
        screenX: root.x; screenY: root.y
        screenWidth: root.scaledScreenWidth; screenHeight: root.scaledScreenHeight
    }

    MaterialShape {
        anchors.centerIn: parent
        implicitSize: Math.min(root.width, root.height)
        visible: root.badgeStyle === "seal"
        shape: MaterialShape.Shape.Cookie12Sided
        color: ColorUtils.applyAlpha(root.widgetPlateColor, root.backgroundOpacity)
        strokeColor: ColorUtils.applyAlpha(root.widgetAccent, root.borderOpacity)
        strokeWidth: root.borderWidth
    }

    GridLayout {
        anchors.centerIn: parent
        width: root.badgeStyle === "seal" ? Math.min(root.width, root.height) * 0.72 : root.width - 28 * root.scaleFactor
        columns: root.horizontal ? 2 : 1
        columnSpacing: 14 * root.scaleFactor
        rowSpacing: 0

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            Layout.rowSpan: root.horizontal ? 3 : 1
            text: Qt.locale().toString(root.today, "d")
            color: root.widgetAccentVisible
            font.family: Appearance.font.family.numbers
            font.pixelSize: Math.min(root.height * 0.36, 64 * root.scaleFactor)
            font.weight: Font.DemiBold
        }
        StyledText {
            Layout.fillWidth: true
            text: Qt.locale().toString(root.today, "dddd")
            horizontalAlignment: root.horizontal ? Text.AlignLeft : Text.AlignHCenter
            color: root.widgetInk
            font.pixelSize: Appearance.font.pixelSize.small * root.scaleFactor
            font.weight: Appearance.editorialEverywhere ? Appearance.editorial.labelWeight : Font.Medium
            elide: Text.ElideRight
        }
        StyledText {
            Layout.fillWidth: true
            text: Qt.locale().toString(root.today, "MMMM")
            horizontalAlignment: root.horizontal ? Text.AlignLeft : Text.AlignHCenter
            color: root.widgetInkMuted
            font.pixelSize: Appearance.font.pixelSize.small * root.scaleFactor
            elide: Text.ElideRight
        }
        StyledText {
            Layout.fillWidth: true
            visible: root.showYear
            text: Qt.locale().toString(root.today, "yyyy")
            horizontalAlignment: root.horizontal ? Text.AlignLeft : Text.AlignHCenter
            color: root.widgetInkMuted
            font.pixelSize: Appearance.font.pixelSize.smallest * root.scaleFactor
        }
    }

    editPopoverContent: Component {
        ColumnLayout {
            spacing: 8
            RowLayout {
                Repeater {
                    model: [
                        { value: "ticket", label: Translation.tr("Ticket") },
                        { value: "stacked", label: Translation.tr("Stacked") },
                        { value: "seal", label: Translation.tr("Seal") }
                    ]
                    SelectionGroupButton {
                        required property var modelData
                        Layout.fillWidth: true
                        buttonText: modelData.label
                        toggled: root.badgeStyle === modelData.value
                        onClicked: root._setOutputValue("style", modelData.value)
                    }
                }
            }
            SelectionGroupButton {
                Layout.fillWidth: true
                buttonText: Translation.tr("Show year")
                toggled: root.showYear
                onClicked: root._setOutputValue("showYear", !root.showYear)
            }
        }
    }
}
