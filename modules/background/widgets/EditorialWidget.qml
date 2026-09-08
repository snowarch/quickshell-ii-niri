pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

AbstractBackgroundWidget {
    id: root
    configEntryName: "editorial"
    defaultConfig: ({ placementStrategy: "free", contentWidth: 360, contentHeight: 240,
        title: "Make room for wonder.", caption: "A LITTLE EVERY DAY", footer: "YOUR OWN PERSPECTIVE",
        style: "poster", showAccent: true, widgetScale: 100, widgetOpacity: 100,
        colorMode: "auto", dim: 0, showBackground: false, showBorder: false,
        backgroundOpacity: 0.12, borderWidth: 1, borderOpacity: 0.2,
        cornerRadius: -1, useBlur: false, x: 100, y: 300 })
    implicitWidth: Math.max(180, Number(root._readConfigKey("contentWidth") ?? 360)) * scaleFactor
    implicitHeight: Math.max(140, Number(root._readConfigKey("contentHeight") ?? 240)) * scaleFactor
    resizableAxes: ({ width: "contentWidth", height: "contentHeight" })
    resizeMinWidth: 180
    resizeMinHeight: 140
    needsColText: true
    readonly property string composition: String(root._readConfigKey("style") ?? "poster")
    readonly property bool showAccent: Boolean(root._readConfigKey("showAccent") ?? true)
    readonly property bool _globalEditorial: Appearance.editorialEverywhere
    readonly property real _titleScale: root._globalEditorial ? Appearance.editorial.titleScale : 1
    readonly property bool _ornaments: !root._globalEditorial || Appearance.editorial.ornaments
    readonly property bool centered: composition === "quote"
    readonly property real inset: 20 * scaleFactor

    WidgetSurface {
        anchors.fill: parent
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

    Rectangle {
        visible: root.showAccent && root.composition === "label"
        x: root.inset; y: root.inset
        width: 3 * root.scaleFactor
        height: parent.height - root.inset * 2
        radius: width / 2
        color: root.widgetAccent
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.inset
        anchors.leftMargin: root.composition === "label" ? root.inset * 2 : root.inset
        spacing: 10 * root.scaleFactor
        RowLayout {
            Layout.fillWidth: true
            spacing: 10 * root.scaleFactor
            StyledText {
                Layout.fillWidth: true
                text: String(root._readConfigKey("caption") ?? "A LITTLE EVERY DAY")
                textFormat: Text.PlainText
                font.capitalization: Font.AllUppercase
                color: root.widgetAccentVisible
                font.pixelSize: Appearance.font.pixelSize.smallest * root.scaleFactor
                font.weight: Font.DemiBold
                horizontalAlignment: root.centered ? Text.AlignHCenter : Text.AlignLeft
                elide: Text.ElideRight
            }
            MaterialShape {
                visible: root.showAccent && root._ornaments && root.composition === "poster"
                implicitSize: 24 * root.scaleFactor
                shape: MaterialShape.Shape.Flower
                color: root.widgetAccent
            }
        }
        StyledText {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 0
            text: String(root._readConfigKey("title") ?? "Make room for wonder.")
            textFormat: Text.PlainText
            color: root.widgetInk
            font.family: root.centered
                ? (root._globalEditorial ? Appearance.editorial.serifFamily : "serif")
                : Appearance.font.family.main
            font.pixelSize: (root.composition === "label" ? 34 : 48) * root._titleScale * root.scaleFactor
            font.weight: root.centered ? Font.Normal : Font.DemiBold
            font.italic: root.centered
            fontSizeMode: Text.Fit
            minimumPixelSize: Math.max(1, 12 * root.scaleFactor)
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            horizontalAlignment: root.centered ? Text.AlignHCenter : Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
        }
        Rectangle {
            Layout.fillWidth: true
            visible: root.showAccent && root._ornaments && root.composition !== "label"
            implicitHeight: root.scaleFactor
            color: root.widgetAccent
            opacity: 0.5
        }
        StyledText {
            Layout.fillWidth: true
            text: String(root._readConfigKey("footer") ?? "YOUR OWN PERSPECTIVE")
            textFormat: Text.PlainText
            color: root.widgetInkMuted
            font.pixelSize: Appearance.font.pixelSize.smallest * root.scaleFactor
            horizontalAlignment: root.centered ? Text.AlignHCenter : Text.AlignLeft
            elide: Text.ElideRight
        }
    }

    editPopoverContent: Component {
        ColumnLayout {
            spacing: 8
            RowLayout {
                Repeater {
                    model: [ { value: "poster", label: Translation.tr("Poster") },
                        { value: "quote", label: Translation.tr("Quote") },
                        { value: "label", label: Translation.tr("Label") } ]
                    SelectionGroupButton {
                        required property var modelData
                        Layout.fillWidth: true
                        buttonText: modelData.label
                        toggled: root.composition === modelData.value
                        onClicked: root._setOutputValue("style", modelData.value)
                    }
                }
            }
            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Title")
                text: String(root._readConfigKey("title") ?? "Make room for wonder.")
                onEditingFinished: root._setOutputValue("title", text)
            }
            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Caption")
                text: String(root._readConfigKey("caption") ?? "A LITTLE EVERY DAY")
                onEditingFinished: root._setOutputValue("caption", text)
            }
            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Footer")
                text: String(root._readConfigKey("footer") ?? "YOUR OWN PERSPECTIVE")
                onEditingFinished: root._setOutputValue("footer", text)
            }
            SelectionGroupButton {
                Layout.fillWidth: true
                buttonText: Translation.tr("Decorative accents")
                toggled: root.showAccent
                onClicked: root._setOutputValue("showAccent", !root.showAccent)
            }
        }
    }
}
