//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

// Adjust this to make the app smaller or larger
//@ pragma Env QT_SCALE_FACTOR=1

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions as CF

ApplicationWindow {
    id: root
    property string firstRunFilePath: CF.FileUtils.trimFileProtocol(`${Directories.state}/user/first_run.txt`)
    property string firstRunFileContent: "This file is just here to confirm you've been greeted :>"
    property real contentPadding: 8
    property bool showNextTime: false
    property var pages: [
        {
            name: Translation.tr("Quick"),
            icon: "instant_mix",
            component: "modules/settings/QuickConfig.qml"
        },
        {
            name: Translation.tr("General"),
            icon: "browse",
            component: "modules/settings/GeneralConfig.qml"
        },
        {
            name: Translation.tr("Bar"),
            icon: "toast",
            iconRotation: 180,
            component: "modules/settings/BarConfig.qml"
        },
        {
            name: Translation.tr("Background"),
            icon: "texture",
            component: "modules/settings/BackgroundConfig.qml"
        },
        {
            name: Translation.tr("Themes"),
            icon: "palette",
            component: "modules/settings/ThemesConfig.qml"
        },
        {
            name: Translation.tr("Interface"),
            icon: "bottom_app_bar",
            component: "modules/settings/InterfaceConfig.qml"
        },
        {
            name: Translation.tr("Services"),
            icon: "settings",
            component: "modules/settings/ServicesConfig.qml"
        },
        {
            name: Translation.tr("Advanced"),
            icon: "construction",
            component: "modules/settings/AdvancedConfig.qml"
        },
        {
            name: Translation.tr("Shortcuts"),
            icon: "keyboard",
            component: "modules/settings/CheatsheetConfig.qml"
        },
        {
            name: Translation.tr("Modules"),
            icon: "extension",
            component: "modules/settings/ModulesConfig.qml"
        },
        {
            name: Translation.tr("Waffle Style"),
            icon: "window",
            component: "modules/settings/WaffleConfig.qml"
        },
        {
            name: Translation.tr("About"),
            icon: "info",
            component: "modules/settings/About.qml"
        }
    ]
    property int currentPage: 0
    property bool uiReady: Config.ready && ThemeService.ready

    // Global settings search
    property string settingsSearchText: ""
    property var settingsSearchResults: []

    // Índice de secciones principales de cada página para el buscador
    property var settingsSearchIndex: [
        // Quick
        {
            pageIndex: 0,
            pageName: pages[0].name,
            section: Translation.tr("Wallpaper & Colors"),
            label: Translation.tr("Wallpaper & Colors"),
            description: Translation.tr("Wallpaper, palette and transparency settings"),
            keywords: ["wallpaper", "colors", "palette", "theme", "background"]
        },
        {
            pageIndex: 0,
            pageName: pages[0].name,
            section: Translation.tr("Bar & screen"),
            label: Translation.tr("Bar & screen"),
            description: Translation.tr("Bar position and screen rounding"),
            keywords: ["bar", "position", "screen", "round", "corner"]
        },

        // General
        {
            pageIndex: 1,
            pageName: pages[1].name,
            section: Translation.tr("Audio"),
            label: Translation.tr("Audio"),
            description: Translation.tr("Volume protection and limits"),
            keywords: ["audio", "volume", "earbang", "limit", "sound"]
        },
        {
            pageIndex: 1,
            pageName: pages[1].name,
            section: Translation.tr("Battery"),
            label: Translation.tr("Battery"),
            description: Translation.tr("Battery warnings and auto suspend thresholds"),
            keywords: ["battery", "low", "critical", "suspend", "full"]
        },
        {
            pageIndex: 1,
            pageName: pages[1].name,
            section: Translation.tr("Language"),
            label: Translation.tr("Language"),
            description: Translation.tr("Interface language and AI translations"),
            keywords: ["language", "locale", "translation", "gemini"]
        },
        {
            pageIndex: 1,
            pageName: pages[1].name,
            section: Translation.tr("Sounds"),
            label: Translation.tr("Sounds"),
            description: Translation.tr("Battery, Pomodoro and notifications sounds"),
            keywords: ["sound", "notification", "pomodoro", "battery"]
        },
        {
            pageIndex: 1,
            pageName: pages[1].name,
            section: Translation.tr("Time"),
            label: Translation.tr("Time"),
            description: Translation.tr("Clock format and seconds"),
            keywords: ["time", "clock", "24h", "12h", "format"]
        },

        // Bar
        {
            pageIndex: 2,
            pageName: pages[2].name,
            section: Translation.tr("Notifications"),
            label: Translation.tr("Notifications"),
            description: Translation.tr("Notification indicator in the bar"),
            keywords: ["notifications", "unread", "indicator", "count"]
        },
        {
            pageIndex: 2,
            pageName: pages[2].name,
            section: Translation.tr("Positioning"),
            label: Translation.tr("Positioning"),
            description: Translation.tr("Bar position, auto hide and style"),
            keywords: ["bar", "position", "auto hide", "corner", "style"]
        },
        {
            pageIndex: 2,
            pageName: pages[2].name,
            section: Translation.tr("Tray"),
            label: Translation.tr("Tray"),
            description: Translation.tr("System tray icons behaviour"),
            keywords: ["tray", "systray", "icons", "pinned"]
        },
        {
            pageIndex: 2,
            pageName: pages[2].name,
            section: Translation.tr("Utility buttons"),
            label: Translation.tr("Utility buttons"),
            description: Translation.tr("Screen snip, color picker and toggles"),
            keywords: ["screen snip", "color picker", "mic", "dark mode", "performance"]
        },
        {
            pageIndex: 2,
            pageName: pages[2].name,
            section: Translation.tr("Workspaces"),
            label: Translation.tr("Workspaces"),
            description: Translation.tr("Workspace count, numbers and icons"),
            keywords: ["workspace", "numbers", "icons", "delays"]
        },

        // Background
        {
            pageIndex: 3,
            pageName: pages[3].name,
            section: Translation.tr("Parallax"),
            label: Translation.tr("Parallax"),
            description: Translation.tr("Background parallax based on workspace and sidebar"),
            keywords: ["parallax", "background", "zoom", "workspace"]
        },
        {
            pageIndex: 3,
            pageName: pages[3].name,
            section: Translation.tr("Effects"),
            label: Translation.tr("Effects"),
            description: Translation.tr("Wallpaper blur and dim overlay"),
            keywords: ["blur", "dim", "wallpaper", "effects"]
        },
        {
            pageIndex: 3,
            pageName: pages[3].name,
            section: Translation.tr("Widget: Clock"),
            label: Translation.tr("Widget: Clock"),
            description: Translation.tr("Clock widget style and behaviour"),
            keywords: ["clock", "widget", "cookie", "digital"]
        },
        {
            pageIndex: 3,
            pageName: pages[3].name,
            section: Translation.tr("Widget: Weather"),
            label: Translation.tr("Widget: Weather"),
            description: Translation.tr("Background weather widget"),
            keywords: ["weather", "widget", "background"]
        },

        // Themes
        {
            pageIndex: 4,
            pageName: pages[4].name,
            section: Translation.tr("Theme Presets"),
            label: Translation.tr("Theme Presets"),
            description: Translation.tr("Predefined color themes like Gruvbox, Catppuccin, Nord, Dracula"),
            keywords: ["theme", "preset", "gruvbox", "catppuccin", "nord", "dracula", "material", "colors", "palette"]
        },
        {
            pageIndex: 4,
            pageName: pages[4].name,
            section: Translation.tr("Auto Theme"),
            label: Translation.tr("Auto Theme"),
            description: Translation.tr("Automatic colors from wallpaper"),
            keywords: ["auto", "wallpaper", "dynamic", "colors", "matugen"]
        },

        // Interface
        {
            pageIndex: 5,
            pageName: pages[5].name,
            section: Translation.tr("Crosshair overlay"),
            label: Translation.tr("Crosshair overlay"),
            description: Translation.tr("In-game crosshair overlay"),
            keywords: ["crosshair", "overlay", "aim"]
        },
        {
            pageIndex: 5,
            pageName: pages[5].name,
            section: Translation.tr("Dock"),
            label: Translation.tr("Dock"),
            description: Translation.tr("Dock position and behaviour"),
            keywords: ["dock", "position", "pinned", "hover"]
        },
        {
            pageIndex: 5,
            pageName: pages[5].name,
            section: Translation.tr("Lock screen"),
            label: Translation.tr("Lock screen"),
            description: Translation.tr("Lock screen behaviour and style"),
            keywords: ["lock", "screen", "hyprlock", "blur"]
        },
        {
            pageIndex: 5,
            pageName: pages[5].name,
            section: Translation.tr("Notifications"),
            label: Translation.tr("Notifications"),
            description: Translation.tr("Notification timeouts and popup position"),
            keywords: ["notifications", "timeout", "popup", "position"]
        },
        {
            pageIndex: 5,
            pageName: pages[5].name,
            section: Translation.tr("Region selector (screen snipping/Google Lens)"),
            label: Translation.tr("Region selector (screen snipping/Google Lens)"),
            description: Translation.tr("Screen snipping target regions and Lens behaviour"),
            keywords: ["region", "selector", "snip", "lens", "screenshot"]
        },
        {
            pageIndex: 5,
            pageName: pages[5].name,
            section: Translation.tr("Sidebars"),
            label: Translation.tr("Sidebars"),
            description: Translation.tr("Sidebar toggles, sliders and corner open"),
            keywords: ["sidebar", "quick toggles", "sliders", "corner"]
        },
        {
            pageIndex: 5,
            pageName: pages[5].name,
            section: Translation.tr("On-screen display"),
            label: Translation.tr("On-screen display"),
            description: Translation.tr("OSD timeout"),
            keywords: ["osd", "volume", "brightness", "timeout"]
        },
        {
            pageIndex: 5,
            pageName: pages[5].name,
            section: Translation.tr("Overview"),
            label: Translation.tr("Overview"),
            description: Translation.tr("Overview scale, rows and columns"),
            keywords: ["overview", "grid", "rows", "columns"]
        },
        {
            pageIndex: 5,
            pageName: pages[5].name,
            section: Translation.tr("Wallpaper selector"),
            label: Translation.tr("Wallpaper selector"),
            description: Translation.tr("Wallpaper picker behaviour"),
            keywords: ["wallpaper", "selector", "file dialog"]
        },

        // Services
        {
            pageIndex: 6,
            pageName: pages[6].name,
            section: Translation.tr("AI"),
            label: Translation.tr("AI"),
            description: Translation.tr("System prompt for sidebar AI"),
            keywords: ["ai", "prompt", "system", "sidebar"]
        },
        {
            pageIndex: 6,
            pageName: pages[6].name,
            section: Translation.tr("Music Recognition"),
            label: Translation.tr("Music Recognition"),
            description: Translation.tr("Song recognition timeout and interval"),
            keywords: ["music", "recognition", "song", "timeout"]
        },
        {
            pageIndex: 6,
            pageName: pages[6].name,
            section: Translation.tr("Networking"),
            label: Translation.tr("Networking"),
            description: Translation.tr("Custom user agent string"),
            keywords: ["network", "user agent", "http"]
        },
        {
            pageIndex: 6,
            pageName: pages[6].name,
            section: Translation.tr("Resources"),
            label: Translation.tr("Resources"),
            description: Translation.tr("Polling interval for resource monitor"),
            keywords: ["resources", "cpu", "memory", "interval"]
        },
        {
            pageIndex: 6,
            pageName: pages[6].name,
            section: Translation.tr("Search"),
            label: Translation.tr("Search"),
            description: Translation.tr("Prefix configuration and engines"),
            keywords: ["search", "prefix", "engine", "web"]
        },
        {
            pageIndex: 6,
            pageName: pages[6].name,
            section: Translation.tr("Weather"),
            label: Translation.tr("Weather"),
            description: Translation.tr("Weather units, GPS and city"),
            keywords: ["weather", "gps", "city", "fahrenheit"]
        },

        // Advanced
        {
            pageIndex: 7,
            pageName: pages[7].name,
            section: Translation.tr("Color generation"),
            label: Translation.tr("Color generation"),
            description: Translation.tr("Wallpaper-based color theming"),
            keywords: ["color", "generation", "theming", "wallpaper"]
        },

        // Shortcuts
        {
            pageIndex: 8,
            pageName: pages[8].name,
            section: Translation.tr("Keyboard Shortcuts"),
            label: Translation.tr("Keyboard Shortcuts"),
            description: Translation.tr("Niri and ii keybindings reference"),
            keywords: ["shortcuts", "keybindings", "hotkeys", "keyboard", "cheatsheet"]
        }
    ]

    function recomputeSettingsSearchResults() {
        if (typeof SettingsSearchRegistry === "undefined") {
            settingsSearchResults = [];
            return;
        }

        settingsSearchResults = SettingsSearchRegistry.buildResults(settingsSearchText);
    }

    function openSearchResult(entry) {
        if (entry && entry.pageIndex !== undefined && entry.pageIndex >= 0) {
            currentPage = entry.pageIndex;

            if (typeof SettingsSearchRegistry !== "undefined" && entry.optionId !== undefined) {
                const optionId = entry.optionId;
                Qt.callLater(() => {
                    SettingsSearchRegistry.focusOption(optionId);
                });
            }
        }

        settingsSearchText = "";
        if (settingsSearchField) {
            settingsSearchField.text = "";
        }
    }

    visible: true
    onClosing: Qt.quit()
    title: "illogical-impulse Settings"

    Component.onCompleted: {
        Config.readWriteDelay = 0 // Settings app always only sets one var at a time so delay isn't needed
    }

    // Apply theme when Config is ready
    Connections {
        target: Config
        function onReadyChanged() {
            if (Config.ready) ThemeService.applyCurrentTheme()
        }
    }

    minimumWidth: 750
    minimumHeight: 500
    width: 1100
    height: 750
    color: root.uiReady ? Appearance.m3colors.m3background : "transparent"

    Shortcut {
        sequences: [StandardKey.Find]
        onActivated: settingsSearchField.forceActiveFocus()
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: contentPadding
        }
        visible: root.uiReady
        opacity: visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }

        Keys.onPressed: (event) => {
            if (event.modifiers === Qt.ControlModifier) {
                if (event.key === Qt.Key_PageDown) {
                    root.currentPage = Math.min(root.currentPage + 1, root.pages.length - 1)
                    event.accepted = true;
                } 
                else if (event.key === Qt.Key_PageUp) {
                    root.currentPage = Math.max(root.currentPage - 1, 0)
                    event.accepted = true;
                }
                else if (event.key === Qt.Key_Tab) {
                    root.currentPage = (root.currentPage + 1) % root.pages.length;
                    event.accepted = true;
                }
                else if (event.key === Qt.Key_Backtab) {
                    root.currentPage = (root.currentPage - 1 + root.pages.length) % root.pages.length;
                    event.accepted = true;
                }
            }
        }

        Item { // Titlebar
            visible: Config.options?.windows.showTitlebar
            Layout.fillWidth: true
            Layout.fillHeight: false
            implicitHeight: Math.max(titleText.implicitHeight, windowControlsRow.implicitHeight)
            StyledText {
                id: titleText
                anchors {
                    left: Config.options.windows.centerTitle ? undefined : parent.left
                    horizontalCenter: Config.options.windows.centerTitle ? parent.horizontalCenter : undefined
                    verticalCenter: parent.verticalCenter
                    leftMargin: 12
                }
                color: Appearance.colors.colOnLayer0
                text: Translation.tr("Settings")
                font {
                    family: Appearance.font.family.title
                    pixelSize: Appearance.font.pixelSize.title
                    variableAxes: Appearance.font.variableAxes.title
                }
            }
            RowLayout { // Window controls row
                id: windowControlsRow
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                RippleButton {
                    buttonRadius: Appearance.rounding.full
                    implicitWidth: 35
                    implicitHeight: 35
                    onClicked: root.close()
                    contentItem: MaterialSymbol {
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        text: "close"
                        iconSize: 20
                    }
                }
            }
        }

        // Global settings search bar (centered, rounded, matching Overview search style)
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 16
            Layout.bottomMargin: 12

            Item { Layout.fillWidth: true }

            RowLayout {
                id: settingsSearchBar
                Layout.preferredWidth: 540
                Layout.maximumWidth: 680
                spacing: 10

                MaterialShapeWrappedMaterialSymbol {
                    id: settingsSearchIcon
                    Layout.alignment: Qt.AlignVCenter
                    iconSize: Appearance.font.pixelSize.huge
                    shape: MaterialShape.Shape.Cookie7Sided
                    text: "search"
                }

                ToolbarTextField {
                    id: settingsSearchField
                    Layout.fillWidth: true
                    Layout.topMargin: 4
                    Layout.bottomMargin: 4
                    Layout.fillHeight: false
                    implicitHeight: 40
                    height: implicitHeight
                    font.pixelSize: Appearance.font.pixelSize.small
                    placeholderText: Translation.tr("Search all settings")
                    text: root.settingsSearchText
                    onTextChanged: {
                        root.settingsSearchText = text;
                        root.recomputeSettingsSearchResults();
                    }

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Down && root.settingsSearchResults.length > 0) {
                            resultsList.forceActiveFocus();
                            if ((resultsList.currentIndex < 0 || resultsList.currentIndex >= resultsList.count) && resultsList.count > 0) {
                                resultsList.currentIndex = 0;
                            }
                            event.accepted = true;
                        } else if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && root.settingsSearchResults.length > 0) {
                            var idx = (resultsList.currentIndex >= 0 && resultsList.currentIndex < root.settingsSearchResults.length)
                                ? resultsList.currentIndex
                                : 0;
                            root.openSearchResult(root.settingsSearchResults[idx]);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Escape) {
                            root.openSearchResult({});
                            event.accepted = true;
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }
        }

        RowLayout { // Window content with navigation rail and content pane
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: contentPadding
            Item {
                id: navRailWrapper
                Layout.fillHeight: true
                Layout.margins: 5
                implicitWidth: navRail.expanded ? 150 : fab.baseSize
                Behavior on implicitWidth {
                    animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                }
                Flickable {
                    id: navRailFlickable
                    anchors.fill: parent
                    contentWidth: navRail.width
                    contentHeight: navRail.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    
                    NavigationRail {
                        id: navRail
                        width: navRailWrapper.implicitWidth
                        spacing: 10
                        expanded: root.width > 900
                        
                        NavigationRailExpandButton {
                            focus: root.visible
                        }

                        FloatingActionButton {
                            id: fab
                            property bool justCopied: false
                            iconText: justCopied ? "check" : "edit"
                            buttonText: justCopied ? Translation.tr("Path copied") : Translation.tr("Config file")
                            expanded: navRail.expanded
                            downAction: () => {
                                Qt.openUrlExternally(`${Directories.config}/illogical-impulse/config.json`);
                            }
                            altAction: () => {
                                Quickshell.clipboardText = CF.FileUtils.trimFileProtocol(`${Directories.config}/illogical-impulse/config.json`);
                                fab.justCopied = true;
                                revertTextTimer.restart()
                            }

                            Timer {
                                id: revertTextTimer
                                interval: 1500
                                onTriggered: {
                                    fab.justCopied = false;
                                }
                            }

                            StyledToolTip {
                                text: Translation.tr("Open the shell config file\nAlternatively right-click to copy path")
                            }
                        }

                        NavigationRailTabArray {
                            currentIndex: root.currentPage
                            expanded: navRail.expanded
                            Repeater {
                                model: root.pages
                                NavigationRailButton {
                                    required property var index
                                    required property var modelData
                                    toggled: root.currentPage === index
                                    onPressed: root.currentPage = index;
                                    expanded: navRail.expanded
                                    buttonIcon: modelData.icon
                                    buttonIconRotation: modelData.iconRotation || 0
                                    buttonText: modelData.name
                                    showToggledHighlight: false
                                }
                            }
                        }
                    }
                }
            }
            Rectangle { // Content container
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Appearance.m3colors.m3surfaceContainerLow
                radius: Appearance.rounding.windowRounding - root.contentPadding

                Item {
                    id: pagesStack
                    anchors.fill: parent

                    // Track which pages have been visited (for lazy loading with cache)
                    property var visitedPages: ({})

                    Connections {
                        target: root
                        function onCurrentPageChanged() {
                            pagesStack.visitedPages[root.currentPage] = true
                            pagesStack.visitedPagesChanged()
                        }
                    }

                    Component.onCompleted: {
                        // Mark initial page as visited
                        visitedPages[root.currentPage] = true
                    }

                    Repeater {
                        model: root.pages.length
                        delegate: Loader {
                            id: pageLoader
                            required property int index
                            anchors.fill: parent
                            // Lazy load: only load when visited, keep loaded after
                            active: Config.ready && (pagesStack.visitedPages[index] === true)
                            asynchronous: index !== root.currentPage // Load non-current pages async
                            source: root.pages[index].component
                            visible: index === root.currentPage && status === Loader.Ready
                            opacity: visible ? 1 : 0

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: Appearance.animation.elementMoveFast.duration
                                    easing.type: Appearance.animation.elementMoveEnter.type
                                    easing.bezierCurve: Appearance.animationCurves.emphasizedLastHalf
                                }
                            }
                        }
                    }
                }

                // Search results overlay
                Rectangle {
                    id: settingsSearchOverlay
                    anchors.fill: parent
                    visible: root.settingsSearchText.length > 0 && root.settingsSearchResults.length > 0
                    color: Qt.rgba(0, 0, 0, 0.35)

                    Rectangle {
                        id: searchCard
                        width: Math.min(parent.width - 80, 720)
                        height: Math.min(parent.height - 80, 520)
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: 40
                        radius: Appearance.rounding.windowRounding
                        color: Appearance.m3colors.m3surface
                        border.color: Appearance.m3colors.m3outlineVariant

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true
                                StyledText {
                                    text: Translation.tr("Search results")
                                    font.pixelSize: Appearance.font.pixelSize.normal
                                    color: Appearance.colors.colOnLayer1
                                }
                                Item { Layout.fillWidth: true }
                                StyledText {
                                    text: Translation.tr("%1 results").arg(root.settingsSearchResults.length)
                                    font.pixelSize: Appearance.font.pixelSize.smallie
                                    color: Appearance.colors.colSubtext
                                }
                                RippleButtonWithIcon {
                                    materialIcon: "close"
                                    buttonRadius: Appearance.rounding.full
                                    Layout.preferredWidth: 32
                                    Layout.preferredHeight: 32
                                    mainText: ""
                                    onClicked: root.openSearchResult({})
                                }
                            }

                            ListView {
                                id: resultsList
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                anchors.margins: 6
                                spacing: 0
                                model: root.settingsSearchResults
                                clip: true

                                // Agrupación visual por categoría (sección)
                                section.property: "section"
                                section.criteria: ViewSection.FullString
                                section.delegate: StyledText {
                                    text: section
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    font.weight: Font.Medium
                                    color: Appearance.colors.colOnLayer1
                                    padding: 4
                                }

                                Keys.onPressed: (event) => {
                                    if (event.key === Qt.Key_Up) {
                                        if (resultsList.currentIndex > 0) {
                                            resultsList.currentIndex--;
                                        } else {
                                            settingsSearchField.forceActiveFocus();
                                        }
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Down) {
                                        if (resultsList.currentIndex < resultsList.count - 1) {
                                            resultsList.currentIndex++;
                                        }
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                        if (resultsList.currentIndex >= 0 && resultsList.currentIndex < root.settingsSearchResults.length) {
                                            root.openSearchResult(root.settingsSearchResults[resultsList.currentIndex]);
                                        }
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Escape) {
                                        root.openSearchResult({});
                                        settingsSearchField.forceActiveFocus();
                                        event.accepted = true;
                                    }
                                }

                                delegate: RippleButton {
                                    required property var modelData
                                    Layout.fillWidth: true
                                    buttonRadius: Appearance.rounding.small
                                    // Hover y selección más marcados
                                    colBackground: ListView.isCurrentItem ? Appearance.colors.colPrimaryContainerActive : "transparent"
                                    colBackgroundHover: Appearance.colors.colPrimaryContainer
                                    colRipple: Appearance.colors.colPrimaryActive
                                    Keys.forwardTo: [resultsList]
                                    onClicked: root.openSearchResult(modelData)

                                    contentItem: ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 6
                                        spacing: 0

                                        StyledText {
                                            text: (modelData.pageName ?? "") + " • " + (modelData.section ?? "")
                                            font.pixelSize: Appearance.font.pixelSize.smaller
                                            color: Appearance.colors.colSubtext
                                        }
                                        StyledText {
                                            text: modelData.label ?? modelData.section ?? modelData.pageName
                                            font.pixelSize: Appearance.font.pixelSize.normal
                                            color: Appearance.colors.colOnLayer2
                                        }
                                        StyledText {
                                            visible: !!modelData.description
                                            text: modelData.description ?? ""
                                            font.pixelSize: Appearance.font.pixelSize.smaller
                                            color: Appearance.colors.colSubtext
                                            elide: Text.ElideRight
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
