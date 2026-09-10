pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.background.widgets
import "../background/widgets/OrganicEdgeConfig.js" as EdgeConfig

ColumnLayout {
    id: root
    spacing: 12
    function value(key: string): var {
        return Config.getNestedValue(EdgeConfig.path + "." + key, EdgeConfig.defaults[key])
    }
    function setValue(key: string, value): void {
        Config.setNestedValue(EdgeConfig.path + "." + key, value)
    }
    function applyValues(values): void {
        const updates = {}
        for (const key of Object.keys(values)) updates[EdgeConfig.path + "." + key] = values[key]
        Config.setNestedValues(updates)
    }
    readonly property var selectedEdges: EdgeConfig.selectedEdges(root.value("edges"), root.value("edge"))
    function presetMatches(preset): bool {
        for (const key of Object.keys(preset.values)) {
            const current = root.value(key)
            const expected = preset.values[key]
            if (Array.isArray(expected)) {
                const actualList = []
                if (current && typeof current.length === "number") {
                    for (let i = 0; i < current.length; ++i)
                        actualList.push(String(current[i]))
                    actualList.sort()
                }
                const expectedList = expected.slice().sort()
                if (JSON.stringify(actualList) !== JSON.stringify(expectedList)) return false
            } else if (current !== expected) return false
        }
        return true
    }
    function metricVisible(key: string): bool {
        if (key === "topScale") return root.selectedEdges.includes("top")
        if (key === "rightScale") return root.selectedEdges.includes("right")
        if (key === "bottomScale") return root.selectedEdges.includes("bottom")
        if (key === "leftScale") return root.selectedEdges.includes("left")
        return true
    }
    function metricEnabled(key: string): bool {
        if (["sensitivity", "audioRange", "pulse", "beatGlow", "transientStrength", "bassDrive",
                "trebleDrive", "attack", "release", "compression", "smoothing",
                "accentStrength"].includes(key)
                && !root.value("audioReactive")) return false
        if (key === "accentStrength" && root.value("frequencyProfile") === "flat") return false
        if (key === "position" && Number(root.value("span")) >= 100) return false
        if (key === "taper" && Number(root.value("span")) >= 100
                && root.selectedEdges.length === 4) return false
        if (key === "colorSpeed" && (root.value("palette") === "mono"
                || root.value("colorMode") === "static")) return false
        if (key === "effectStrength" && root.value("effectMode") === "clean") return false
        return true
    }

    component Metrics: GridLayout {
        id: metrics
        required property var entries
        Layout.fillWidth: true
        columns: width >= 660 ? 2 : 1
        columnSpacing: 24
        rowSpacing: 8
        Repeater {
            model: metrics.entries
            ColumnLayout {
                id: metric
                required property var modelData
                Layout.fillWidth: true
                visible: root.metricVisible(modelData.key)
                spacing: 3
                enabled: root.metricEnabled(modelData.key)
                opacity: enabled ? 1 : 0.45
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr(metric.modelData.label)
                        color: Appearance.colors.colOnLayer1
                        font.pixelSize: Appearance.font.pixelSize.small
                        elide: Text.ElideRight
                    }
                    StyledText {
                        text: Math.round(Number(root.value(metric.modelData.key))) + metric.modelData.unit
                        color: Appearance.colors.colPrimary
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        font.family: Appearance.font.family.numbers
                        font.weight: Font.DemiBold
                    }
                }
                StyledSlider {
                    Layout.fillWidth: true
                    from: metric.modelData.min
                    to: metric.modelData.max
                    stepSize: metric.modelData.step
                    value: Number(root.value(metric.modelData.key))
                    configuration: StyledSlider.Configuration.XS
                    stopIndicatorValues: []
                    tooltipContent: Math.round(value) + metric.modelData.unit
                    onMoved: root.setValue(metric.modelData.key, Math.round(value))
                }
            }
        }
    }

    component SectionLabel: StyledText {
        Layout.fillWidth: true
        color: Appearance.colors.colSubtext
        font.pixelSize: Appearance.font.pixelSize.small
        font.weight: Font.DemiBold
        font.capitalization: Font.AllUppercase
        font.letterSpacing: 0.6
    }

    component PresetTile: Rectangle {
        id: presetTile
        required property var preset
        readonly property bool selected: root.presetMatches(preset)
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        implicitHeight: 82
        radius: Appearance.rounding.small
        color: selected
            ? Appearance.colors.colPrimaryContainer
            : presetHover.hovered ? Appearance.colors.colLayer2Hover : Appearance.colors.colLayer2
        border.width: selected ? 2 : 1
        border.color: selected ? Appearance.colors.colPrimary : Appearance.colors.colOutlineVariant

        RowLayout {
            anchors.fill: parent
            anchors.margins: 11
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 38
                Layout.preferredHeight: 38
                radius: 12
                color: presetTile.selected
                    ? Appearance.colors.colPrimary
                    : Appearance.colors.colLayer3

                MaterialSymbol {
                    anchors.centerIn: parent
                    text: presetTile.preset.icon
                    iconSize: 20
                    fill: 1
                    color: presetTile.selected
                        ? Appearance.colors.colOnPrimary
                        : Appearance.colors.colOnLayer2
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                spacing: 2
                StyledText {
                    Layout.fillWidth: true
                    text: Translation.tr(presetTile.preset.name)
                    color: presetTile.selected
                        ? Appearance.colors.colOnPrimaryContainer
                        : Appearance.colors.colOnLayer2
                    font.pixelSize: Appearance.font.pixelSize.small
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
                StyledText {
                    Layout.fillWidth: true
                    text: Translation.tr(presetTile.preset.description)
                    color: presetTile.selected
                        ? Appearance.colors.colOnPrimaryContainer
                        : Appearance.colors.colSubtext
                    opacity: 0.78
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }
            }

            Rectangle {
                Layout.preferredWidth: 8
                Layout.preferredHeight: 38
                radius: 4
                color: presetTile.preset.values.palette === "wallpaper"
                    ? Appearance.wallpaperDominantColor
                    : Appearance.colors.colPrimary
                opacity: presetTile.selected ? 1 : 0.72
            }
            MaterialSymbol {
                visible: presetTile.selected
                text: "check_circle"
                iconSize: 18
                fill: 1
                color: Appearance.colors.colPrimary
            }
        }

        HoverHandler { id: presetHover }
        TapHandler { onTapped: root.applyValues(presetTile.preset.values) }
    }

    SettingsCardSection {
        Layout.fillWidth: true
        settingsTaskSection: "edges"
        title: Translation.tr("Organic edge")
        icon: "border_outer"
        expanded: true
        SettingsGroup {
            SettingsSwitch {
                text: Translation.tr("Enable Organic edge")
                buttonIcon: "border_outer"
                checked: root.value("enable")
                autoToggle: false
                onToggledByUser: checked => root.setValue("enable", checked)
            }
            SettingsNote {
                text: Translation.tr("A living frame for your desktop. Compose one edge or surround the screen; corners blend into a single field. Windows and desktop controls stay above it.")
            }
            SectionLabel { text: Translation.tr("Scenes") }
            GridLayout {
                Layout.fillWidth: true
                columns: width >= 620 ? 2 : 1
                columnSpacing: 8
                rowSpacing: 8
                Repeater {
                    model: EdgeConfig.presets
                    PresetTile {
                        required property var modelData
                        preset: modelData
                    }
                }
            }
            SettingsNote {
                text: Translation.tr("Scenes are complete looks: edge composition, material, light, color and music response. Fine tuning below keeps the same scene and updates the renderer smoothly while you drag.")
            }
            WidgetChoiceButton {
                Layout.fillWidth: true
                buttonIcon: "restart_alt"
                buttonText: Translation.tr("Reset appearance")
                onClicked: {
                    const values = Object.assign({}, EdgeConfig.defaults)
                    delete values.enable
                    delete values.screenList
                    root.applyValues(values)
                }
            }
        }
    }

    SettingsCardSection {
        Layout.fillWidth: true
        settingsTaskSection: "edges"
        title: Translation.tr("Screen composition")
        icon: "select_all"
        expanded: true
        SettingsGroup {
            GridLayout {
                Layout.fillWidth: true
                columns: width >= 480 ? 4 : 2
                columnSpacing: 6
                rowSpacing: 6
                Repeater {
                    model: [{key: "top", label: "Top", icon: "border_top"},
                        {key: "right", label: "Right", icon: "border_right"},
                        {key: "bottom", label: "Bottom", icon: "border_bottom"},
                        {key: "left", label: "Left", icon: "border_left"}]
                    WidgetChoiceButton {
                        required property var modelData
                        Layout.fillWidth: true
                        buttonText: Translation.tr(modelData.label)
                        buttonIcon: modelData.icon
                        toggled: root.selectedEdges.includes(modelData.key)
                        onClicked: {
                            const edges = root.selectedEdges.slice()
                            const index = edges.indexOf(modelData.key)
                            if (index < 0) edges.push(modelData.key)
                            else if (edges.length > 1) edges.splice(index, 1)
                            root.setValue("edges", edges)
                        }
                    }
                }
            }
            SettingsSwitch {
                text: Translation.tr("Respect bars and dock")
                buttonIcon: "space_dashboard"
                checked: root.value("respectPanels")
                autoToggle: false
                onToggledByUser: checked => root.setValue("respectPanels", checked)
            }
            ConfigSelectionArray {
                currentValue: root.value("joinMode")
                onSelected: newValue => root.setValue("joinMode", newValue)
                options: [
                    {displayName: Translation.tr("Join connected edges"), value: "auto"},
                    {displayName: Translation.tr("Keep edges separate"), value: "separate"}
                ]
            }
            Metrics { entries: EdgeConfig.geometry }
            SettingsNote { text: Translation.tr("Connected full-length edges can behave as one continuous field through shared corners. Separate mode keeps each edge independent. Length and position still define partial-edge compositions.") }
        }
    }

    SettingsCardSection {
        Layout.fillWidth: true
        settingsTaskSection: "edges"
        title: Translation.tr("Material and palette")
        icon: "palette"
        expanded: true
        SettingsGroup {
            ConfigSelectionArray {
                currentValue: root.value("style")
                onSelected: newValue => root.setValue("style", newValue)
                options: [{displayName: Translation.tr("Silk"), value: "silk"},
                    {displayName: Translation.tr("Aurora"), value: "aurora"},
                    {displayName: Translation.tr("Contour"), value: "contour"},
                    {displayName: Translation.tr("Liquid"), value: "liquid"}]
            }
            SectionLabel { text: Translation.tr("Shape") }
            ConfigSelectionArray {
                currentValue: root.value("shape")
                onSelected: newValue => root.setValue("shape", newValue)
                options: EdgeConfig.shapes.map(p => ({displayName: Translation.tr(p.name), value: p.value}))
            }
            ConfigSelectionArray {
                currentValue: EdgeConfig.paletteValue(root.value("palette"))
                onSelected: newValue => root.setValue("palette", newValue)
                options: EdgeConfig.palettes.map(p => ({displayName: Translation.tr(p.name), value: p.value}))
            }
            SectionLabel { text: Translation.tr("Color behavior") }
            ConfigSelectionArray {
                currentValue: root.value("colorMode")
                onSelected: newValue => root.setValue("colorMode", newValue)
                options: EdgeConfig.colorModes.map(p => ({displayName: Translation.tr(p.name), value: p.value}))
            }
            SectionLabel { text: Translation.tr("Visual effect") }
            ConfigSelectionArray {
                currentValue: root.value("effectMode")
                onSelected: newValue => root.setValue("effectMode", newValue)
                options: EdgeConfig.effects.map(p => ({displayName: Translation.tr(p.name), value: p.value}))
            }
            ColumnLayout {
                Layout.fillWidth: true
                visible: root.value("palette") === "custom"
                ColorPickerRow { label: Translation.tr("Primary"); colorKey: "primaryColor"; configPath: EdgeConfig.path + "." + colorKey }
                ColorPickerRow { label: Translation.tr("Secondary"); colorKey: "secondaryColor"; configPath: EdgeConfig.path + "." + colorKey }
                ColorPickerRow { label: Translation.tr("Tertiary"); colorKey: "tertiaryColor"; configPath: EdgeConfig.path + "." + colorKey }
            }
            SectionLabel { text: Translation.tr("Body") }
            Metrics { entries: EdgeConfig.materialBody }
            SectionLabel { text: Translation.tr("Light") }
            Metrics { entries: EdgeConfig.materialLight }
            SectionLabel { text: Translation.tr("Color tuning") }
            Metrics { entries: EdgeConfig.colorTuning }
            SettingsNote { text: Translation.tr("Body opacity changes the translucent field without changing its reach. Crest controls the bright contour. Glow and visual effects stay outside the body, while hue and color intensity tune the palette without changing its material.") }
        }
    }

    SettingsCardSection {
        Layout.fillWidth: true
        settingsTaskSection: "edges"
        title: Translation.tr("Motion and sound")
        icon: "graphic_eq"
        expanded: false
        SettingsGroup {
            SettingsSwitch {
                text: Translation.tr("React to audio")
                buttonIcon: "equalizer"
                checked: root.value("audioReactive")
                autoToggle: false
                onToggledByUser: checked => root.setValue("audioReactive", checked)
            }
            ConfigSelectionArray {
                currentValue: root.value("idleMode")
                onSelected: newValue => root.setValue("idleMode", newValue)
                options: [{displayName: Translation.tr("Ambient"), value: "ambient"},
                    {displayName: Translation.tr("Still when silent"), value: "still"},
                    {displayName: Translation.tr("Hide when silent"), value: "hidden"}]
            }
            ConfigSelectionArray {
                enabled: root.value("audioReactive")
                currentValue: root.value("frequencyProfile")
                onSelected: newValue => root.setValue("frequencyProfile", newValue)
                options: [{displayName: Translation.tr("Balanced"), value: "flat"},
                    {displayName: Translation.tr("Bass"), value: "bass"},
                    {displayName: Translation.tr("Warm"), value: "warm"},
                    {displayName: Translation.tr("Vocals"), value: "vocal"},
                    {displayName: Translation.tr("Treble"), value: "treble"},
                    {displayName: Translation.tr("Bass + treble"), value: "smile"}]
            }
            SectionLabel { text: Translation.tr("Response presets") }
            GridLayout {
                Layout.fillWidth: true
                columns: width >= 600 ? 5 : width >= 420 ? 3 : 2
                columnSpacing: 6
                rowSpacing: 6
                Repeater {
                    model: EdgeConfig.responsePresets
                    WidgetChoiceButton {
                        required property var modelData
                        Layout.fillWidth: true
                        buttonText: Translation.tr(modelData.name)
                        buttonIcon: modelData.icon
                        toggled: root.presetMatches(modelData)
                        enabled: root.value("audioReactive")
                        onClicked: root.applyValues(modelData.values)
                    }
                }
            }
            SectionLabel { text: Translation.tr("Movement") }
            Metrics { entries: EdgeConfig.motion }
            SectionLabel { text: Translation.tr("Music dynamics") }
            Metrics { entries: EdgeConfig.audioDynamics }
            SectionLabel { text: Translation.tr("Frequency character") }
            Metrics { entries: EdgeConfig.audioTone }
            SettingsNote { text: Translation.tr("Attack controls how quickly the contour catches a hit; Release controls how quickly it settles. Bass drive pushes the contour outward, while Treble shimmer concentrates energy in the crest and glow instead of making the whole body thicker.") }
        }
    }

    SettingsCardSection {
        Layout.fillWidth: true
        settingsTaskSection: "edges"
        title: Translation.tr("Displays")
        icon: "monitor"
        expanded: false
        SettingsGroup {
            SettingsSwitch {
                visible: Quickshell.screens.length > 1
                text: Translation.tr("All displays")
                buttonIcon: "desktop_windows"
                checked: (root.value("screenList") ?? []).length === 0
                autoToggle: false
                onToggledByUser: checked => root.setValue("screenList", checked ? []
                    : (Quickshell.screens.length > 0 ? [Quickshell.screens[0].name] : []))
            }
            Repeater {
                model: Quickshell.screens
                SettingsSwitch {
                    required property var modelData
                    text: modelData.name
                    buttonIcon: "monitor"
                    readonly property var configured: root.value("screenList") ?? []
                    checked: configured.length === 0 || configured.includes(modelData.name)
                    autoToggle: false
                    enabled: !checked || (configured.length || Quickshell.screens.length) > 1
                    onToggledByUser: checked => {
                        const screens = configured.length ? configured.slice() : Quickshell.screens.map(s => s.name)
                        const index = screens.indexOf(modelData.name)
                        if (checked && index < 0) screens.push(modelData.name)
                        if (!checked && index >= 0) screens.splice(index, 1)
                        if (screens.length === 0) root.setValue("enable", false)
                        else if (screens.length === Quickshell.screens.length) root.setValue("screenList", [])
                        else root.setValue("screenList", screens)
                    }
                }
            }
        }
    }
}
