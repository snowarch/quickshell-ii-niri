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

    Rectangle {
        visible: root.badgeStyle === "ticket" && root.horizontal
        x: 10 * root.scaleFactor
        y: 10 * root.scaleFactor
        width: root.width * 0.36
        height: root.height - 20 * root.scaleFactor
        radius: Math.min(root.widgetCardRadius, width / 2)
        color: root.widgetSemanticContainer(root.widgetPrimaryRole)
    }

    Rectangle {
        visible: root.badgeStyle === "stacked" && root.showBackground
        x: 16 * root.scaleFactor
        y: 12 * root.scaleFactor
        width: root.width - 32 * root.scaleFactor
        height: 4 * root.scaleFactor
        radius: height / 2
        color: root.widgetAccentVisible
    }

    StyledText {
        id: dayNumber
        x: root.horizontal ? 10 * root.scaleFactor : 0
        y: root.horizontal ? (root.height - height) / 2 : root.height * 0.14
        width: root.horizontal ? root.width * 0.36 : root.width
        height: root.height * 0.45
        text: Qt.locale().toString(root.today, "d")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: root.horizontal ? root.widgetSemanticOnContainer(root.widgetPrimaryRole)
            : root.widgetAccentVisible
        font.family: Appearance.font.family.numbers
        font.pixelSize: Math.min(height, 80 * root.scaleFactor)
        font.weight: root.widgetTitleWeight
        fontSizeMode: Text.Fit
        minimumPixelSize: 16
    }

    ColumnLayout {
        x: root.horizontal ? root.width * 0.36 + 24 * root.scaleFactor : root.width * 0.14
        y: root.horizontal ? (root.height - implicitHeight) / 2 : root.height * 0.59
        width: root.horizontal ? root.width - x - 14 * root.scaleFactor : root.width * 0.72
        spacing: 2 * root.scaleFactor

        StyledText {
            Layout.fillWidth: true
            text: Qt.locale().toString(root.today, "dddd")
            horizontalAlignment: root.horizontal ? Text.AlignLeft : Text.AlignHCenter
            color: root.widgetInk
            font.pixelSize: Appearance.font.pixelSize.small * root.scaleFactor
            font.weight: root.widgetLabelWeight
            elide: Text.ElideRight
        }
        StyledText {
            Layout.fillWidth: true
            text: Qt.locale().toString(root.today, root.showYear ? "MMM yyyy" : "MMMM")
            horizontalAlignment: root.horizontal ? Text.AlignLeft : Text.AlignHCenter
            color: root.widgetInkMuted
            font.pixelSize: Appearance.font.pixelSize.smallest * root.scaleFactor
            elide: Text.ElideRight
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
                    WidgetChoiceButton {
                        required property var modelData
                        Layout.fillWidth: true
                        buttonText: modelData.label
                        toggled: root.badgeStyle === modelData.value
                        onClicked: root._setOutputValue("style", modelData.value)
                    }
                }
            }
            WidgetChoiceButton {
                Layout.fillWidth: true
                buttonText: Translation.tr("Show year")
                toggled: root.showYear
                onClicked: root._setOutputValue("showYear", !root.showYear)
            }
        }
    }
}
