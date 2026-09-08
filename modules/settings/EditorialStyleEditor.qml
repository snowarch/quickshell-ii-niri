pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.services

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: Math.round(14 * Appearance.editorial.spacing)

    readonly property var _defaults: ({
        typography: "poster", titleScale: 1.0, warmth: 0.55, accentStrength: 0.55,
        spacing: 1.0, radiusScale: 1.0, ornaments: true, motionScale: 1.0
    })
    readonly property var _presets: [
        { key: "poster", label: Translation.tr("Poster"), icon: "text_fields",
            description: Translation.tr("Bold sans display"), values: ({
                typography: "poster", titleScale: 1.0, warmth: 0.55, accentStrength: 0.55,
                spacing: 1.0, radiusScale: 1.0, ornaments: true, motionScale: 1.0
            }) },
        { key: "studio", label: Translation.tr("Studio"), icon: "tune",
            description: Translation.tr("Compact and quiet"), values: ({
                typography: "poster", titleScale: 0.9, warmth: 0.35, accentStrength: 0.25,
                spacing: 0.86, radiusScale: 0.8, ornaments: false, motionScale: 0.8
            }) },
        { key: "reading", label: Translation.tr("Reading"), icon: "auto_stories",
            description: Translation.tr("Serif-led composition"), values: ({
                typography: "reading", titleScale: 1.1, warmth: 0.65, accentStrength: 0.4,
                spacing: 1.1, radiusScale: 1.1, ornaments: true, motionScale: 1.0
            }) }
    ]

    function value(key: string, fallback): var {
        const current = Config.options?.appearance?.editorial?.[key]
        return current === undefined ? fallback : current
    }

    readonly property string currentPreset: {
        const current = {
            typography: root.value("typography", "poster"),
            titleScale: Number(root.value("titleScale", 1.0)),
            warmth: Number(root.value("warmth", 0.55)),
            accentStrength: Number(root.value("accentStrength", 0.55)),
            spacing: Number(root.value("spacing", 1.0)),
            radiusScale: Number(root.value("radiusScale", 1.0)),
            ornaments: Boolean(root.value("ornaments", true)),
            motionScale: Number(root.value("motionScale", 1.0))
        }
        for (const preset of root._presets) {
            const values = preset.values
            if (values.typography === current.typography
                    && Math.abs(values.titleScale - current.titleScale) < 0.001
                    && Math.abs(values.warmth - current.warmth) < 0.001
                    && Math.abs(values.accentStrength - current.accentStrength) < 0.001
                    && Math.abs(values.spacing - current.spacing) < 0.001
                    && Math.abs(values.radiusScale - current.radiusScale) < 0.001
                    && values.ornaments === current.ornaments
                    && Math.abs(values.motionScale - current.motionScale) < 0.001)
                return preset.key
        }
        return "custom"
    }

    function applyValues(values): void {
        Config.setNestedValues({
            "appearance.editorial.typography": values.typography,
            "appearance.editorial.titleScale": values.titleScale,
            "appearance.editorial.warmth": values.warmth,
            "appearance.editorial.accentStrength": values.accentStrength,
            "appearance.editorial.spacing": values.spacing,
            "appearance.editorial.radiusScale": values.radiusScale,
            "appearance.editorial.ornaments": values.ornaments,
            "appearance.editorial.motionScale": values.motionScale
        })
    }

    function resetEditorial(): void { root.applyValues(root._defaults) }

    component SliderRow: ColumnLayout {
        id: sliderRoot
        Layout.fillWidth: true
        spacing: 3
        property string label: ""
        property string description: ""
        property real from: 0
        property real to: 1
        property real stepSize: 0.05
        property real value: 0
        property string suffix: ""
        property string configPath: ""

        RowLayout {
            Layout.fillWidth: true
            StyledText {
                Layout.fillWidth: true
                text: sliderRoot.label
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.editorial.ink
            }
            StyledText {
                text: sliderRoot.value.toFixed(2) + sliderRoot.suffix
                font.family: Appearance.font.family.monospace
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.editorial.accent
            }
        }
        StyledText {
            Layout.fillWidth: true
            visible: sliderRoot.description.length > 0
            text: sliderRoot.description
            wrapMode: Text.WordWrap
            font.pixelSize: Appearance.font.pixelSize.smallest
            color: Appearance.editorial.muted
        }
        StyledSlider {
            Layout.fillWidth: true
            from: sliderRoot.from
            to: sliderRoot.to
            stepSize: sliderRoot.stepSize
            value: sliderRoot.value
            configuration: StyledSlider.Configuration.S
            settingsSearchLabel: sliderRoot.label
            settingsSearchDescription: sliderRoot.description
            settingsSearchKeywords: ["editorial", "style", sliderRoot.label.toLowerCase()]
            onMoved: Config.setNestedValue(sliderRoot.configPath, Math.round(value * 100) / 100)
        }
    }

    // This is the same paper/ink/rule composition used by the shell, not a
    // decorative mock. Every control below writes the tokens this preview reads.
    PanelSurface {
        Layout.fillWidth: true
        implicitHeight: editorialPreview.implicitHeight + 28
        elevation: 1
        editorialFocus: true
        // The composition owns its footer rule; avoid PanelSurface adding a
        // second perimeter rule around the same preview.
        outlined: false
        surfaceDialect: "editorial"
        ColumnLayout {
            id: editorialPreview
            anchors.fill: parent
            anchors.margins: 14
            spacing: Math.round(7 * Appearance.editorial.spacing)
            RowLayout {
                Layout.fillWidth: true
                StyledText {
                    Layout.fillWidth: true
                    text: Translation.tr("EDITORIAL / LIVE COMPOSITION")
                    font.pixelSize: Appearance.font.pixelSize.smallest
                    font.weight: Appearance.editorial.titleWeight
                    font.letterSpacing: 1.1
                    color: Appearance.editorial.paperOnInk
                }
                MaterialShape {
                    implicitSize: 18
                    visible: Appearance.editorial.ornaments
                    shape: MaterialShape.Shape.Flower
                    color: Appearance.editorial.paperOnInk
                }
            }
            StyledText {
                Layout.fillWidth: true
                text: Translation.tr("Make room for wonder.")
                font.family: Appearance.font.family.title
                font.pixelSize: Math.max(34, 36 * Appearance.editorial.titleScale) * Appearance.fontSizeScale
                font.weight: Appearance.editorial.titleWeight
                font.italic: Appearance.editorial.typography === "reading"
                wrapMode: Text.WordWrap
                color: Appearance.editorial.paperOnInk
            }
            EditorialRule {
                Layout.fillWidth: true
                Layout.preferredHeight: 2
                inset: 0
                color: Appearance.editorial.paperOnInk
                emphasized: true
            }
            StyledText {
                Layout.fillWidth: true
                text: Appearance.editorial.typography === "reading"
                    ? Translation.tr("A slower page for focused reading.")
                    : Translation.tr("A clear interface with a point of view.")
                font.pixelSize: Appearance.font.pixelSize.small
                wrapMode: Text.WordWrap
                color: ColorUtils.applyAlpha(Appearance.editorial.paperOnInk, 0.72)
            }
        }
    }

    ContentSubsection { title: Translation.tr("Preset")
        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            Repeater {
                model: root._presets
                delegate: RippleButton {
                    required property var modelData
                    Layout.fillWidth: true
                    implicitHeight: 58
                    buttonRadius: Appearance.editorial.radius
                    colBackground: root.currentPreset === modelData.key
                        ? Appearance.editorial.field : Appearance.editorial.layer(1)
                    colBackgroundHover: Appearance.editorial.field
                    onClicked: root.applyValues(modelData.values)
                    contentItem: ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 5
                        spacing: 1
                        MaterialSymbol {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.icon
                            iconSize: 17
                            color: root.currentPreset === modelData.key
                                ? Appearance.editorial.fieldInk : Appearance.editorial.accent
                        }
                        StyledText {
                            Layout.fillWidth: true
                            text: modelData.label
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: Appearance.font.pixelSize.smallest
                            font.weight: Font.DemiBold
                            color: root.currentPreset === modelData.key
                                ? Appearance.editorial.fieldInk : Appearance.editorial.ink
                        }
                    }
                }
            }
        }
        StyledText {
            Layout.fillWidth: true
            text: root.currentPreset === "custom"
                ? Translation.tr("Custom composition")
                : Translation.tr("Current preset: %1").arg(root.currentPreset)
            font.pixelSize: Appearance.font.pixelSize.smallest
            color: Appearance.editorial.muted
        }
    }

    ContentSubsection { title: Translation.tr("Typography")
        ConfigSelectionArray {
            currentValue: root.value("typography", "poster")
            options: [
                { displayName: Translation.tr("Poster sans"), icon: "text_fields", value: "poster" },
                { displayName: Translation.tr("Reading serif"), icon: "auto_stories", value: "reading" }
            ]
            onSelected: value => Config.setNestedValue("appearance.editorial.typography", value)
        }
        SliderRow {
            label: Translation.tr("Title scale")
            description: Translation.tr("Scales display headings without moving their targets.")
            from: 0.8; to: 1.3; stepSize: 0.05; suffix: "×"
            value: Number(root.value("titleScale", 1.0))
            configPath: "appearance.editorial.titleScale"
        }
    }

    ContentSubsection { title: Translation.tr("Material & composition")
        SliderRow {
            label: Translation.tr("Paper warmth")
            description: Translation.tr("Adds a restrained paper tint while preserving theme color.")
            from: 0; to: 1; stepSize: 0.05
            value: Number(root.value("warmth", 0.55))
            configPath: "appearance.editorial.warmth"
        }
        SliderRow {
            label: Translation.tr("Accent intensity")
            description: Translation.tr("From neutral ink to richer theme-colored highlights and tonal cards.")
            from: 0; to: 1; stepSize: 0.05
            value: Appearance.editorial.accentStrength
            configPath: "appearance.editorial.accentStrength"
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Repeater {
                model: [
                    { label: Translation.tr("Primary"), background: Appearance.editorial.field, foreground: Appearance.editorial.fieldInk },
                    { label: Translation.tr("Secondary"), background: Appearance.editorial.secondaryField, foreground: Appearance.editorial.secondaryFieldInk },
                    { label: Translation.tr("Tertiary"), background: Appearance.editorial.tertiaryField, foreground: Appearance.editorial.tertiaryFieldInk }
                ]
                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    implicitHeight: toneLabel.implicitHeight + 20
                    radius: Appearance.rounding.small
                    color: modelData.background
                    StyledText {
                        id: toneLabel
                        anchors.centerIn: parent
                        width: Math.max(0, parent.width - 12)
                        text: modelData.label
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        font.pixelSize: Appearance.font.pixelSize.smallest
                        color: modelData.foreground
                    }
                }
            }
        }
        SliderRow {
            label: Translation.tr("Spacing")
            description: Translation.tr("Opens or tightens editorial gutters and section rhythm.")
            from: 0.8; to: 1.2; stepSize: 0.05; suffix: "×"
            value: Number(root.value("spacing", 1.0))
            configPath: "appearance.editorial.spacing"
        }
        SliderRow {
            label: Translation.tr("Corner radius")
            description: Translation.tr("Scales Editorial surface and control corners together.")
            from: 0.5; to: 1.5; stepSize: 0.05; suffix: "×"
            value: Number(root.value("radiusScale", 1.0))
            configPath: "appearance.editorial.radiusScale"
        }
        ConfigSwitch {
            buttonIcon: "flare"
            text: Translation.tr("Flower accents")
            description: Translation.tr("Use the Flower as a contextual section mark.")
            checked: Boolean(root.value("ornaments", true))
            onToggledByUser: checked => Config.setNestedValue("appearance.editorial.ornaments", checked)
        }
    }

    ContentSubsection { title: Translation.tr("Motion")
        SliderRow {
            label: Translation.tr("Editorial motion")
            description: Translation.tr("Uses the existing shell animation owners; reduced motion still wins.")
            from: 0.6; to: 1.4; stepSize: 0.05; suffix: "×"
            value: Number(root.value("motionScale", 1.0))
            configPath: "appearance.editorial.motionScale"
        }
    }

    RippleButton {
        Layout.alignment: Qt.AlignRight
        implicitWidth: resetLabel.implicitWidth + 28
        implicitHeight: 34
        buttonRadius: Appearance.editorial.radius
        colBackground: Appearance.editorial.layer(1)
        colBackgroundHover: Appearance.editorial.field
        onClicked: root.resetEditorial()
        contentItem: RowLayout {
            id: resetLabel
            anchors.centerIn: parent
            spacing: 6
            MaterialSymbol { text: "restart_alt"; iconSize: 15; color: Appearance.editorial.accent }
            StyledText { text: Translation.tr("Reset Editorial"); font.pixelSize: Appearance.font.pixelSize.small; color: Appearance.editorial.ink }
        }
    }
}
