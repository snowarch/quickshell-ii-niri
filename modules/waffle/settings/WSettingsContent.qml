pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions as CF
import qs.modules.waffle.looks

// Main Windows 11 style settings container
Item {
    id: root
    
    property var pages: []
    property int currentPage: 0
    property string searchText: ""
    property var searchResults: []
    property bool navExpanded: width > 800
    
    // Search index for waffle settings pages
    property var searchIndex: [
        // Home (0)
        { pageIndex: 0, pageName: pages[0]?.name ?? "Home", section: "", label: Translation.tr("Home"), keywords: ["home", "quick", "start"] },
        
        // General (1)
        { pageIndex: 1, pageName: pages[1]?.name ?? "General", section: Translation.tr("Time"), label: Translation.tr("Time Format"), keywords: ["time", "clock", "24h", "12h", "format", "seconds"] },
        { pageIndex: 1, pageName: pages[1]?.name ?? "General", section: Translation.tr("Language"), label: Translation.tr("Language"), keywords: ["language", "locale", "translation"] },
        { pageIndex: 1, pageName: pages[1]?.name ?? "General", section: Translation.tr("Behavior"), label: Translation.tr("Behavior"), keywords: ["behavior", "close", "confirm", "window"] },
        { pageIndex: 1, pageName: pages[1]?.name ?? "General", section: Translation.tr("Developer"), label: Translation.tr("Developer Options"), keywords: ["developer", "debug", "reload"] },
        
        // Taskbar (2)
        { pageIndex: 2, pageName: pages[2]?.name ?? "Taskbar", section: Translation.tr("Position"), label: Translation.tr("Taskbar Position"), keywords: ["taskbar", "bar", "position", "bottom"] },
        { pageIndex: 2, pageName: pages[2]?.name ?? "Taskbar", section: Translation.tr("Buttons"), label: Translation.tr("Taskbar Buttons"), keywords: ["start", "search", "widgets", "tray", "clock"] },
        { pageIndex: 2, pageName: pages[2]?.name ?? "Taskbar", section: Translation.tr("Desktop Peek"), label: Translation.tr("Desktop Peek"), keywords: ["desktop", "peek", "hover", "show"] },
        { pageIndex: 2, pageName: pages[2]?.name ?? "Taskbar", section: Translation.tr("Weather"), label: Translation.tr("Weather in Widgets"), keywords: ["weather", "widgets", "temperature"] },
        
        // Background (3)
        { pageIndex: 3, pageName: pages[3]?.name ?? "Background", section: Translation.tr("Wallpaper"), label: Translation.tr("Wallpaper"), keywords: ["wallpaper", "background", "image"] },
        { pageIndex: 3, pageName: pages[3]?.name ?? "Background", section: Translation.tr("Effects"), label: Translation.tr("Background Effects"), keywords: ["blur", "dim", "effects", "parallax"] },
        { pageIndex: 3, pageName: pages[3]?.name ?? "Background", section: Translation.tr("Backdrop"), label: Translation.tr("Backdrop"), keywords: ["backdrop", "overlay"] },
        
        // Themes (4)
        { pageIndex: 4, pageName: pages[4]?.name ?? "Themes", section: Translation.tr("Theme Presets"), label: Translation.tr("Theme Presets"), keywords: ["theme", "preset", "gruvbox", "catppuccin", "nord", "dracula"] },
        { pageIndex: 4, pageName: pages[4]?.name ?? "Themes", section: Translation.tr("Auto Theme"), label: Translation.tr("Auto Theme"), keywords: ["auto", "wallpaper", "dynamic", "matugen"] },
        { pageIndex: 4, pageName: pages[4]?.name ?? "Themes", section: Translation.tr("Typography"), label: Translation.tr("Typography"), keywords: ["font", "typography", "family", "size"] },
        
        // Interface (5)
        { pageIndex: 5, pageName: pages[5]?.name ?? "Interface", section: Translation.tr("Animations"), label: Translation.tr("Animations"), keywords: ["animations", "effects", "motion", "reduce"] },
        { pageIndex: 5, pageName: pages[5]?.name ?? "Interface", section: Translation.tr("Blur"), label: Translation.tr("Blur Effects"), keywords: ["blur", "transparency", "acrylic"] },
        { pageIndex: 5, pageName: pages[5]?.name ?? "Interface", section: Translation.tr("Screen"), label: Translation.tr("Screen Rounding"), keywords: ["screen", "rounding", "corners"] },
        
        // Modules (6)
        { pageIndex: 6, pageName: pages[6]?.name ?? "Modules", section: Translation.tr("Panels"), label: Translation.tr("Panel Modules"), keywords: ["modules", "panels", "enable", "disable"] },
        
        // Waffle Style (7)
        { pageIndex: 7, pageName: pages[7]?.name ?? "Waffle Style", section: Translation.tr("Action Center"), label: Translation.tr("Action Center"), keywords: ["action", "center", "toggles", "quick"] },
        { pageIndex: 7, pageName: pages[7]?.name ?? "Waffle Style", section: Translation.tr("Start Menu"), label: Translation.tr("Start Menu"), keywords: ["start", "menu", "apps", "pinned"] },
        { pageIndex: 7, pageName: pages[7]?.name ?? "Waffle Style", section: Translation.tr("Alt+Tab"), label: Translation.tr("Alt+Tab Switcher"), keywords: ["alt", "tab", "switcher", "windows"] },
        { pageIndex: 7, pageName: pages[7]?.name ?? "Waffle Style", section: Translation.tr("Widgets"), label: Translation.tr("Widgets Panel"), keywords: ["widgets", "panel", "weather", "calendar"] },
        
        // About (8)
        { pageIndex: 8, pageName: pages[8]?.name ?? "About", section: "", label: Translation.tr("About ii"), keywords: ["about", "version", "credits", "github"] }
    ]
    
    function highlightTerms(text: string, terms: list<string>): string {
        if (!text || !terms || terms.length === 0) return text;
        var result = text;
        for (var i = 0; i < terms.length; i++) {
            var term = terms[i];
            var idx = result.toLowerCase().indexOf(term.toLowerCase());
            if (idx >= 0) {
                var original = result.substring(idx, idx + term.length);
                result = result.substring(0, idx) + "<b>" + original + "</b>" + result.substring(idx + term.length);
            }
        }
        return result;
    }
    
    function recomputeSearchResults(): void {
        var q = String(searchText || "").toLowerCase().trim();
        if (!q.length) {
            searchResults = [];
            return;
        }
        
        var terms = q.split(/\s+/).filter(t => t.length > 0);
        var results = [];
        
        for (var i = 0; i < searchIndex.length; i++) {
            var entry = searchIndex[i];
            var label = (entry.label || "").toLowerCase();
            var section = (entry.section || "").toLowerCase();
            var page = (entry.pageName || "").toLowerCase();
            var kw = (entry.keywords || []).join(" ").toLowerCase();
            
            var matchCount = 0;
            var score = 0;
            
            for (var j = 0; j < terms.length; j++) {
                var term = terms[j];
                if (label.indexOf(term) >= 0 || section.indexOf(term) >= 0 || 
                    page.indexOf(term) >= 0 || kw.indexOf(term) >= 0) {
                    matchCount++;
                    if (label.indexOf(term) === 0) score += 800;
                    else if (label.indexOf(term) > 0) score += 400;
                    if (kw.indexOf(term) >= 0) score += 300;
                    if (section.indexOf(term) >= 0) score += 200;
                }
            }
            
            if (matchCount === terms.length) {
                results.push({
                    pageIndex: entry.pageIndex,
                    pageName: entry.pageName,
                    section: entry.section,
                    label: entry.label,
                    labelHighlighted: highlightTerms(entry.label, terms),
                    score: score
                });
            }
        }
        
        // Also search in dynamic registry if available
        if (typeof SettingsSearchRegistry !== "undefined") {
            var widgetResults = SettingsSearchRegistry.buildResults(searchText);
            results = results.concat(widgetResults);
        }
        
        results.sort((a, b) => b.score - a.score);
        
        // Remove duplicates
        var seen = {};
        var unique = [];
        for (var k = 0; k < results.length; k++) {
            var key = (results[k].label || "") + "|" + (results[k].section || "");
            if (!seen[key]) {
                seen[key] = true;
                unique.push(results[k]);
            }
        }
        
        searchResults = unique.slice(0, 30);
    }
    
    function openSearchResult(entry: var): void {
        if (entry && entry.pageIndex !== undefined && entry.pageIndex >= 0) {
            currentPage = entry.pageIndex;
            
            // Focus option if available
            if (typeof SettingsSearchRegistry !== "undefined" && entry.optionId !== undefined) {
                const optionId = entry.optionId;
                Qt.callLater(() => {
                    SettingsSearchRegistry.focusOption(optionId);
                });
            }
        }
        
        searchText = "";
        searchInput.text = "";
    }
    
    RowLayout {
        anchors.fill: parent
        spacing: 0
        
        // Navigation sidebar
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: root.navExpanded ? 280 : 64
            color: Looks.colors.bgPanelFooterBase
            
            Behavior on Layout.preferredWidth {
                NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
            }
            
            ColumnLayout {
                anchors {
                    fill: parent
                    margins: 12
                }
                spacing: 4
                
                // Header with app name
                RowLayout {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 8
                    spacing: 12
                    visible: root.navExpanded
                    
                    Rectangle {
                        width: 32
                        height: 32
                        radius: Looks.radius.medium
                        color: Looks.colors.accent
                        
                        WText {
                            anchors.centerIn: parent
                            text: "ii"
                            font.pixelSize: Looks.font.pixelSize.large
                            font.weight: Font.Bold
                            color: Looks.colors.accentFg
                        }
                    }
                    
                    WText {
                        Layout.fillWidth: true
                        text: Translation.tr("Settings")
                        font.pixelSize: Looks.font.pixelSize.larger
                        font.weight: Font.DemiBold
                    }
                }
                
                // Search bar (only when expanded)
                Rectangle {
                    id: searchBarContainer
                    visible: root.navExpanded
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    radius: Looks.radius.medium
                    color: Looks.colors.inputBg
                    border.width: searchInput.activeFocus ? 2 : 1
                    border.color: searchInput.activeFocus ? Looks.colors.accent : Looks.colors.bg2Border
                    
                    Behavior on border.color {
                        ColorAnimation { duration: 120 }
                    }
                    
                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: 10
                            rightMargin: 10
                        }
                        spacing: 8
                        
                        FluentIcon {
                            icon: "search"
                            implicitSize: 16
                            color: Looks.colors.subfg
                        }
                        
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            
                            TextInput {
                                id: searchInput
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                color: Looks.colors.fg
                                selectionColor: Looks.colors.accent
                                selectedTextColor: Looks.colors.accentFg
                                font.family: Looks.font.family.ui
                                font.pixelSize: Looks.font.pixelSize.normal
                                clip: true
                                
                                onTextChanged: {
                                    root.searchText = text;
                                    root.recomputeSearchResults();
                                }
                                
                                Keys.onPressed: event => {
                                    if (event.key === Qt.Key_Down && root.searchResults.length > 0) {
                                        searchResultsList.forceActiveFocus();
                                        searchResultsList.currentIndex = 0;
                                        event.accepted = true;
                                    } else if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && root.searchResults.length > 0) {
                                        root.openSearchResult(root.searchResults[0]);
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Escape) {
                                        root.openSearchResult({});
                                        event.accepted = true;
                                    }
                                }
                            }
                            
                            // Placeholder text (separate element to avoid overlap)
                            WText {
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                text: Translation.tr("Find a setting")
                                color: Looks.colors.subfg
                                font.family: Looks.font.family.ui
                                font.pixelSize: Looks.font.pixelSize.normal
                                visible: !searchInput.text && !searchInput.activeFocus
                            }
                        }
                        
                        // Clear button
                        Item {
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 20
                            visible: searchInput.text.length > 0
                            
                            Rectangle {
                                anchors.fill: parent
                                radius: 10  // pill shape
                                color: clearMouse.containsMouse ? Looks.colors.bg2Hover : "transparent"
                                
                                FluentIcon {
                                    anchors.centerIn: parent
                                    icon: "dismiss"
                                    implicitSize: 12
                                    color: Looks.colors.subfg
                                }
                                
                                MouseArea {
                                    id: clearMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        searchInput.text = "";
                                        searchInput.forceActiveFocus();
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Search results dropdown
                Rectangle {
                    id: searchResultsDropdown
                    visible: root.searchText.length > 0 && root.searchResults.length > 0
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min((searchResultsList.contentHeight || 0) + 8, 300)
                    radius: Looks.radius.large
                    color: Looks.colors.bg1Base
                    border.width: 1
                    border.color: Looks.colors.bg2Border
                    
                    layer.enabled: true
                    layer.effect: DropShadow {
                        color: Looks.colors.shadow
                        radius: 8
                        samples: 9
                        verticalOffset: 2
                    }
                    
                    ListView {
                        id: searchResultsList
                        anchors {
                            fill: parent
                            margins: 4
                        }
                        spacing: 2
                        model: root.searchResults
                        clip: true
                        currentIndex: -1
                        boundsBehavior: Flickable.StopAtBounds
                        
                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Up) {
                                if (currentIndex > 0) currentIndex--;
                                else searchInput.forceActiveFocus();
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Down) {
                                if (currentIndex < count - 1) currentIndex++;
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (currentIndex >= 0) root.openSearchResult(root.searchResults[currentIndex]);
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Escape) {
                                root.openSearchResult({});
                                searchInput.forceActiveFocus();
                                event.accepted = true;
                            }
                        }
                        
                        delegate: Rectangle {
                            id: resultDelegate
                            required property var modelData
                            required property int index
                            
                            width: searchResultsList.width
                            height: 44
                            radius: Looks.radius.medium
                            color: {
                                if (ListView.isCurrentItem) return Looks.colors.accent;
                                if (resultMouse.containsMouse) return Looks.colors.bg2Hover;
                                return "transparent";
                            }
                            
                            Behavior on color {
                                ColorAnimation { duration: 80 }
                            }
                            
                            MouseArea {
                                id: resultMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.openSearchResult(resultDelegate.modelData)
                            }
                            
                            RowLayout {
                                anchors {
                                    fill: parent
                                    leftMargin: 10
                                    rightMargin: 10
                                }
                                spacing: 10
                                
                                // Page icon
                                FluentIcon {
                                    icon: {
                                        var icons = ["home", "settings", "desktop", "image", "color", 
                                                    "apps", "apps", "desktop", "info"];
                                        return icons[resultDelegate.modelData.pageIndex] || "settings";
                                    }
                                    implicitSize: 16
                                    color: resultDelegate.ListView.isCurrentItem 
                                        ? Looks.colors.accentFg 
                                        : Looks.colors.accent
                                }
                                
                                // Text content
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 0
                                    
                                    Text {
                                        Layout.fillWidth: true
                                        text: resultDelegate.modelData.labelHighlighted || resultDelegate.modelData.label || ""
                                        textFormat: Text.StyledText
                                        font.family: Looks.font.family.ui
                                        font.pixelSize: Looks.font.pixelSize.normal
                                        font.weight: Font.Medium
                                        color: resultDelegate.ListView.isCurrentItem 
                                            ? Looks.colors.accentFg 
                                            : Looks.colors.fg
                                        elide: Text.ElideRight
                                    }
                                    
                                    WText {
                                        Layout.fillWidth: true
                                        text: resultDelegate.modelData.pageName + (resultDelegate.modelData.section ? " › " + resultDelegate.modelData.section : "")
                                        font.pixelSize: Looks.font.pixelSize.small
                                        color: resultDelegate.ListView.isCurrentItem 
                                            ? Looks.colors.accentFg 
                                            : Looks.colors.subfg
                                        elide: Text.ElideRight
                                        opacity: 0.8
                                    }
                                }
                                
                                // Arrow
                                FluentIcon {
                                    icon: "chevron-right"
                                    implicitSize: 12
                                    color: resultDelegate.ListView.isCurrentItem 
                                        ? Looks.colors.accentFg 
                                        : Looks.colors.subfg
                                    opacity: resultMouse.containsMouse || resultDelegate.ListView.isCurrentItem ? 1 : 0
                                    
                                    Behavior on opacity {
                                        NumberAnimation { duration: 80 }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // No results indicator
                Rectangle {
                    visible: root.searchText.length > 0 && root.searchResults.length === 0
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    radius: Looks.radius.medium
                    color: Looks.colors.bg1Base
                    
                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        
                        FluentIcon {
                            icon: "search"
                            implicitSize: 14
                            color: Looks.colors.subfg
                        }
                        
                        WText {
                            text: Translation.tr("No results")
                            font.pixelSize: Looks.font.pixelSize.small
                            color: Looks.colors.subfg
                        }
                    }
                }

                // Search icon button (when collapsed)
                WBorderlessButton {
                    visible: !root.navExpanded
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    Layout.alignment: Qt.AlignHCenter
                    
                    contentItem: FluentIcon {
                        anchors.centerIn: parent
                        icon: "search"
                        implicitSize: 20
                        color: Looks.colors.fg
                    }
                    
                    onClicked: root.navExpanded = true
                }
                
                Item { height: 8 }
                
                // Navigation items
                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentHeight: navColumn.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    
                    ColumnLayout {
                        id: navColumn
                        width: parent.width
                        spacing: 2
                        
                        Repeater {
                            model: root.pages
                            
                            WSettingsNavItem {
                                required property int index
                                required property var modelData
                                
                                Layout.fillWidth: true
                                text: modelData.name
                                navIcon: modelData.icon
                                selected: root.currentPage === index
                                expanded: root.navExpanded
                                
                                onClicked: root.currentPage = index
                            }
                        }
                    }
                }
                
                // Expand/collapse button
                WBorderlessButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    
                    contentItem: RowLayout {
                        spacing: 12
                        
                        Item {
                            implicitWidth: 24
                            implicitHeight: 24
                            Layout.leftMargin: root.navExpanded ? 8 : 12
                            
                            FluentIcon {
                                anchors.centerIn: parent
                                icon: root.navExpanded ? "panel-left-contract" : "panel-left-expand"
                                implicitSize: 20
                                color: Looks.colors.fg
                            }
                        }
                        
                        WText {
                            visible: root.navExpanded
                            Layout.fillWidth: true
                            text: Translation.tr("Collapse")
                            font.pixelSize: Looks.font.pixelSize.normal
                        }
                    }
                    
                    onClicked: root.navExpanded = !root.navExpanded
                }
            }
        }
        
        // Separator
        Rectangle {
            Layout.fillHeight: true
            width: 1
            color: Looks.colors.bg2Border
        }
        
        // Content area
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Looks.colors.bg0
            
            // Page stack
            Item {
                id: pageStack
                anchors.fill: parent
                
                property var visitedPages: ({})
                
                Connections {
                    target: root
                    function onCurrentPageChanged() {
                        pageStack.visitedPages[root.currentPage] = true
                        pageStack.visitedPagesChanged()
                    }
                }
                
                Component.onCompleted: {
                    visitedPages[root.currentPage] = true
                }
                
                Repeater {
                    model: root.pages.length
                    
                    Loader {
                        id: pageLoader
                        required property int index
                        anchors.fill: parent
                        active: Config.ready && (pageStack.visitedPages[index] === true)
                        asynchronous: index !== root.currentPage
                        source: root.pages[index].component
                        visible: index === root.currentPage && status === Loader.Ready
                        opacity: visible ? 1 : 0
                        
                        Behavior on opacity {
                            NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                        }
                    }
                }
            }
        }
    }
    
    // Keyboard shortcut for search
    Shortcut {
        sequences: [StandardKey.Find]
        onActivated: {
            if (!root.navExpanded) root.navExpanded = true;
            searchInput.forceActiveFocus();
        }
    }
}
