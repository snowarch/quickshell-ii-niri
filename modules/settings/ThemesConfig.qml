import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: root
    forceWidth: true
    settingsPageIndex: 4
    settingsPageName: Translation.tr("Themes")

    function isFontInstalled(fontName) {
        if (!fontName || fontName.trim() === "") return false
        var testFont = Qt.font({ family: fontName, pixelSize: 12 })
        return testFont.family.toLowerCase() === fontName.toLowerCase()
    }

    ContentSection {
        icon: "palette"
        title: Translation.tr("Color Themes")

        StyledText {
            Layout.fillWidth: true
            text: Translation.tr("Select a color theme. Choose 'Auto' to use colors from your wallpaper.")
            color: Appearance.colors.colSubtext
            font.pixelSize: Appearance.font.pixelSize.smaller
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            MaterialSymbol {
                text: "check_circle"
                iconSize: Appearance.font.pixelSize.normal
                color: Appearance.m3colors.m3primary
            }

            StyledText {
                text: Translation.tr("Current: %1").arg(ThemePresets.getPreset(ThemeService.currentTheme).name)
                font.pixelSize: Appearance.font.pixelSize.small
            }
        }

        Flow {
            id: themeFlow
            Layout.fillWidth: true
            spacing: 12

            Repeater {
                model: ThemePresets.presets

                ThemePresetCard {
                    required property var modelData
                    width: Math.max(160, (themeFlow.width - themeFlow.spacing * 2) / 3)
                    preset: modelData
                    onClicked: ThemeService.setTheme(modelData.id)
                }
            }
        }
    }

    ContentSection {
        visible: ThemeService.currentTheme === "custom"
        icon: "edit"
        title: Translation.tr("Custom Theme Editor")

        Loader {
            Layout.fillWidth: true
            active: ThemeService.currentTheme === "custom"
            source: "CustomThemeEditor.qml"
        }
    }

    ContentSection {
        icon: "text_format"
        title: Translation.tr("Typography")

        // Quick Presets first
        ContentSubsection {
            title: Translation.tr("Quick Presets")

            Flow {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: StylePresets.presets

                    RippleButton {
                        required property var modelData
                        width: 90
                        height: 50
                        buttonRadius: Appearance.rounding.small
                        colBackground: Appearance.colors.colLayer1
                        colBackgroundHover: Appearance.colors.colLayer1Hover

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 2

                            MaterialSymbol {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.icon
                                iconSize: Appearance.font.pixelSize.normal
                                color: Appearance.m3colors.m3onSurface
                            }

                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.name
                                font.pixelSize: Appearance.font.pixelSize.smaller
                            }
                        }

                        onClicked: StylePresets.applyPreset(modelData.id)
                        StyledToolTip { text: modelData.description }
                    }
                }
            }
        }

        // Font Families
        ContentSubsection {
            title: Translation.tr("Font Families")

            ConfigRow {
                uniform: true

                FontSelector {
                    id: mainFontSelector
                    label: Translation.tr("Main")
                    icon: "font_download"
                    selectedFont: Config.options?.appearance?.typography?.mainFont ?? "Roboto Flex"
                    onSelectedFontChanged: {
                        if (Config.options?.appearance?.typography)
                            Config.options.appearance.typography.mainFont = selectedFont
                    }
                    Connections {
                        target: Config.options?.appearance?.typography ?? null
                        function onMainFontChanged() { mainFontSelector.selectedFont = Config.options.appearance.typography.mainFont }
                    }
                }

                FontSelector {
                    id: titleFontSelector
                    label: Translation.tr("Title")
                    icon: "title"
                    selectedFont: Config.options?.appearance?.typography?.titleFont ?? "Gabarito"
                    onSelectedFontChanged: {
                        if (Config.options?.appearance?.typography)
                            Config.options.appearance.typography.titleFont = selectedFont
                    }
                    Connections {
                        target: Config.options?.appearance?.typography ?? null
                        function onTitleFontChanged() { titleFontSelector.selectedFont = Config.options.appearance.typography.titleFont }
                    }
                }

                FontSelector {
                    id: monoFontSelector
                    label: Translation.tr("Mono")
                    icon: "terminal"
                    selectedFont: Config.options?.appearance?.typography?.monospaceFont ?? "JetBrains Mono NF"
                    onSelectedFontChanged: {
                        if (Config.options?.appearance?.typography)
                            Config.options.appearance.typography.monospaceFont = selectedFont
                    }
                    Connections {
                        target: Config.options?.appearance?.typography ?? null
                        function onMonospaceFontChanged() { monoFontSelector.selectedFont = Config.options.appearance.typography.monospaceFont }
                    }
                }
            }
        }

        // Size Scale
        ConfigSpinBox {
            icon: "format_size"
            text: Translation.tr("Size scale (%)")
            value: Math.round((Config.options?.appearance?.typography?.sizeScale ?? 1.0) * 100)
            from: 80
            to: 150
            stepSize: 5
            onValueChanged: {
                if (Config.options?.appearance?.typography)
                    Config.options.appearance.typography.sizeScale = value / 100
            }
        }

        // Variable Font Axes - Collapsible
        RippleButton {
            id: advancedToggle
            Layout.fillWidth: true
            implicitHeight: 32
            buttonRadius: Appearance.rounding.small
            colBackground: "transparent"
            property bool expanded: false

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                spacing: 8

                MaterialSymbol {
                    text: advancedToggle.expanded ? "expand_less" : "expand_more"
                    iconSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colSubtext
                }

                StyledText {
                    text: Translation.tr("Variable Font Axes")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }
            }

            onClicked: expanded = !expanded
        }

        ColumnLayout {
            visible: advancedToggle.expanded
            Layout.fillWidth: true
            Layout.leftMargin: 16
            spacing: 4

            ConfigSpinBox {
                id: weightSpinBox
                icon: "line_weight"
                text: Translation.tr("Weight")
                from: 100
                to: 900
                stepSize: 50
                value: Config.options?.appearance?.typography?.variableAxes?.wght ?? 300
                onValueChanged: {
                    if (Config.options?.appearance?.typography?.variableAxes)
                        Config.options.appearance.typography.variableAxes.wght = value
                }
                Connections {
                    target: Config.options?.appearance?.typography?.variableAxes ?? null
                    function onWghtChanged() { weightSpinBox.value = Config.options.appearance.typography.variableAxes.wght }
                }
            }

            ConfigSpinBox {
                id: widthSpinBox
                icon: "width"
                text: Translation.tr("Width")
                from: 75
                to: 125
                stepSize: 5
                value: Config.options?.appearance?.typography?.variableAxes?.wdth ?? 105
                onValueChanged: {
                    if (Config.options?.appearance?.typography?.variableAxes)
                        Config.options.appearance.typography.variableAxes.wdth = value
                }
                Connections {
                    target: Config.options?.appearance?.typography?.variableAxes ?? null
                    function onWdthChanged() { widthSpinBox.value = Config.options.appearance.typography.variableAxes.wdth }
                }
            }

            ConfigSpinBox {
                id: gradeSpinBox
                icon: "gradient"
                text: Translation.tr("Grade")
                from: -200
                to: 200
                stepSize: 25
                value: Config.options?.appearance?.typography?.variableAxes?.grad ?? 175
                onValueChanged: {
                    if (Config.options?.appearance?.typography?.variableAxes)
                        Config.options.appearance.typography.variableAxes.grad = value
                }
                Connections {
                    target: Config.options?.appearance?.typography?.variableAxes ?? null
                    function onGradChanged() { gradeSpinBox.value = Config.options.appearance.typography.variableAxes.grad }
                }
            }
        }

        // Reset button
        RippleButtonWithIcon {
            Layout.topMargin: 8
            buttonRadius: Appearance.rounding.full
            materialIcon: "restart_alt"
            mainText: Translation.tr("Reset typography to defaults")
            onClicked: StylePresets.resetTypographyToDefaults()
        }
    }

    ContentSection {
        icon: "folder"
        title: Translation.tr("Icon Theme")

        IconThemeSelector {}

        StyledText {
            Layout.fillWidth: true
            text: Translation.tr("Quickshell will restart to apply changes.")
            color: Appearance.colors.colSubtext
            font.pixelSize: Appearance.font.pixelSize.smaller
            wrapMode: Text.WordWrap
        }
    }

    ContentSection {
        icon: "info"
        title: Translation.tr("About Themes")

        StyledText {
            Layout.fillWidth: true
            text: Translation.tr("Themes apply a Material 3 color palette. 'Auto' generates colors from your wallpaper using matugen.")
            color: Appearance.colors.colSubtext
            font.pixelSize: Appearance.font.pixelSize.smaller
            wrapMode: Text.WordWrap
        }
    }
}
