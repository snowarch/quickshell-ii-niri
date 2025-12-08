import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import Qt.labs.synchronizer
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item { // Wrapper
    id: root
    readonly property string xdgConfigHome: Directories.config
    property string searchingText: ""
    property bool showResults: searchingText != ""
    implicitWidth: searchWidgetContent.implicitWidth + Appearance.sizes.elevationMargin * 2
    implicitHeight: searchBar.implicitHeight + searchBar.verticalPadding * 2 + Appearance.sizes.elevationMargin * 2

    property string mathResult: ""
    property string debouncedSearchText: ""
    property var cachedResults: []

    property bool clipboardWorkSafetyActive: {
        const enabled = Config.options.workSafety.enable.clipboard;
        const sensitiveNetwork = (StringUtils.stringListContainsSubstring(Network.networkName.toLowerCase(), Config.options.workSafety.triggerCondition.networkNameKeywords))
        return enabled && sensitiveNetwork;
    }

    property var searchActions: [
        {
            action: "accentcolor",
            execute: args => {
                Quickshell.execDetached([Directories.wallpaperSwitchScriptPath, "--noswitch", "--color", ...(args != '' ? [`${args}`] : [])]);
            }
        },
        {
            action: "dark",
            execute: () => {
                Quickshell.execDetached([Directories.wallpaperSwitchScriptPath, "--mode", "dark", "--noswitch"]);
            }
        },
        {
            action: "konachanwallpaper",
            execute: () => {
                Quickshell.execDetached([Quickshell.shellPath("scripts/colors/random/random_konachan_wall.sh")]);
            }
        },
        {
            action: "light",
            execute: () => {
                Quickshell.execDetached([Directories.wallpaperSwitchScriptPath, "--mode", "light", "--noswitch"]);
            }
        },
        {
            action: "superpaste",
            execute: args => {
                if (!/^(\d+)/.test(args.trim())) { // Invalid if doesn't start with numbers
                    Quickshell.execDetached([
                        "notify-send", 
                        Translation.tr("Superpaste"), 
                        Translation.tr("Usage: <tt>%1superpaste NUM_OF_ENTRIES[i]</tt>\nSupply <tt>i</tt> when you want images\nExamples:\n<tt>%1superpaste 4i</tt> for the last 4 images\n<tt>%1superpaste 7</tt> for the last 7 entries").arg(Config.options.search.prefix.action),
                        "-a", "Shell"
                    ]);
                    return;
                }
                const syntaxMatch = /^(?:(\d+)(i)?)/.exec(args.trim());
                const count = syntaxMatch[1] ? parseInt(syntaxMatch[1]) : 1;
                const isImage = !!syntaxMatch[2];
                Cliphist.superpaste(count, isImage);
            }
        },
        {
            action: "todo",
            execute: args => {
                Todo.addTask(args);
            }
        },
        {
            action: "wallpaper",
            execute: () => {
                GlobalStates.wallpaperSelectorOpen = true;
            }
        },
        {
            action: "wipeclipboard",
            execute: () => {
                Cliphist.wipe();
            }
        },
    ]

    function focusFirstItem() {
        appResults.currentIndex = 0;
    }

    function focusSearchInput() {
        searchBar.forceFocus();
    }

    function disableExpandAnimation() {
        searchBar.animateWidth = false;
    }

    function cancelSearch() {
        searchBar.searchInput.text = "";
        root.searchingText = "";
        searchBar.animateWidth = true;
    }

    function setSearchingText(text) {
        searchBar.searchInput.text = text;
        root.searchingText = text;
    }

    function containsUnsafeLink(entry) {
        if (entry == undefined) return false;
        const unsafeKeywords = Config.options.workSafety.triggerCondition.linkKeywords;
        return StringUtils.stringListContainsSubstring(entry.toLowerCase(), unsafeKeywords);
    }

    function updateSearchResults(): void {
        const text = root.debouncedSearchText;
        
        if (text === "") {
            root.cachedResults = [];
            return;
        }

        // Clipboard search
        if (text.startsWith(Config.options.search.prefix.clipboard)) {
            const searchString = StringUtils.cleanPrefix(text, Config.options.search.prefix.clipboard);
            root.cachedResults = Cliphist.fuzzyQuery(searchString).map((entry, index, array) => {
                const mightBlurImage = Cliphist.entryIsImage(entry) && root.clipboardWorkSafetyActive;
                let shouldBlurImage = mightBlurImage;
                if (mightBlurImage) {
                    shouldBlurImage = shouldBlurImage && (containsUnsafeLink(array[index - 1]) || containsUnsafeLink(array[index + 1]));
                }
                const type = `#${entry.match(/^\s*(\S+)/)?.[1] || ""}`
                return {
                    key: type,
                    cliphistRawString: entry,
                    name: StringUtils.cleanCliphistEntry(entry),
                    clickActionName: "",
                    type: type,
                    execute: () => { Cliphist.copy(entry) },
                    actions: [
                        { name: "Copy", materialIcon: "content_copy", execute: () => { Cliphist.copy(entry); } },
                        { name: "Delete", materialIcon: "delete", execute: () => { Cliphist.deleteEntry(entry); } }
                    ],
                    blurImage: shouldBlurImage,
                    blurImageText: Translation.tr("Work safety")
                };
            }).filter(Boolean);
            return;
        }
        
        // Emoji search
        if (text.startsWith(Config.options.search.prefix.emojis)) {
            const searchString = StringUtils.cleanPrefix(text, Config.options.search.prefix.emojis);
            root.cachedResults = Emojis.fuzzyQuery(searchString).map(entry => {
                const emoji = entry.match(/^\s*(\S+)/)?.[1] || ""
                return {
                    key: emoji,
                    cliphistRawString: entry,
                    bigText: emoji,
                    name: entry.replace(/^\s*\S+\s+/, ""),
                    clickActionName: "",
                    type: "Emoji",
                    execute: () => { Quickshell.clipboardText = entry.match(/^\s*(\S+)/)?.[1]; }
                };
            }).filter(Boolean);
            return;
        }

        // Default search
        nonAppResultsTimer.restart();
        
        const mathResultObject = {
            key: `Math result: ${root.mathResult}`,
            name: root.mathResult,
            clickActionName: Translation.tr("Copy"),
            type: Translation.tr("Math result"),
            fontType: "monospace",
            materialSymbol: 'calculate',
            execute: () => { Quickshell.clipboardText = root.mathResult; }
        };
        
        const appResultObjects = AppSearch.fuzzyQuery(StringUtils.cleanPrefix(text, Config.options.search.prefix.app)).map(entry => {
            entry.clickActionName = Translation.tr("Launch");
            entry.type = Translation.tr("App");
            entry.key = entry.execute;
            return entry;
        });
        
        const commandResultObject = {
            key: `cmd ${text}`,
            name: StringUtils.cleanPrefix(text, Config.options.search.prefix.shellCommand).replace("file://", ""),
            clickActionName: Translation.tr("Run"),
            type: Translation.tr("Run command"),
            fontType: "monospace",
            materialSymbol: 'terminal',
            execute: () => {
                let cleanedCommand = text.replace("file://", "");
                cleanedCommand = StringUtils.cleanPrefix(cleanedCommand, Config.options.search.prefix.shellCommand);
                if (cleanedCommand.startsWith(Config.options.search.prefix.shellCommand)) {
                    cleanedCommand = cleanedCommand.slice(Config.options.search.prefix.shellCommand.length);
                }
                cleanedCommand = cleanedCommand.trim();
                if (!cleanedCommand.length) return;
                const term = Config.options.apps.terminal || "ghostty";
                if (term.indexOf("ghostty") !== -1) {
                    Quickshell.execDetached([term, "-e", "sh", "-lc", cleanedCommand]);
                } else {
                    const commandToRun = `${term} fish -C '${cleanedCommand}'`;
                    Quickshell.execDetached(["bash", "-c", commandToRun]);
                }
            }
        };
        
        const webSearchResultObject = {
            key: `website ${text}`,
            name: StringUtils.cleanPrefix(text, Config.options.search.prefix.webSearch),
            clickActionName: Translation.tr("Search"),
            type: Translation.tr("Search the web"),
            materialSymbol: 'travel_explore',
            execute: () => {
                let query = StringUtils.cleanPrefix(text, Config.options.search.prefix.webSearch);
                let url = Config.options.search.engineBaseUrl + query;
                for (let site of Config.options.search.excludedSites) {
                    url += ` -site:${site}`;
                }
                Qt.openUrlExternally(url);
            }
        };
        
        const launcherActionObjects = root.searchActions.map(action => {
            const actionString = `${Config.options.search.prefix.action}${action.action}`;
            if (actionString.startsWith(text) || text.startsWith(actionString)) {
                return {
                    key: `Action ${actionString}`,
                    name: text.startsWith(actionString) ? text : actionString,
                    clickActionName: Translation.tr("Run"),
                    type: Translation.tr("Action"),
                    materialSymbol: 'settings_suggest',
                    execute: () => { action.execute(text.split(" ").slice(1).join(" ")); }
                };
            }
            return null;
        }).filter(Boolean);

        let result = [];
        const startsWithNumber = /^\d/.test(text);
        const startsWithMathPrefix = text.startsWith(Config.options.search.prefix.math);
        const startsWithShellCommandPrefix = text.startsWith(Config.options.search.prefix.shellCommand);
        const startsWithWebSearchPrefix = text.startsWith(Config.options.search.prefix.webSearch);
        
        if (startsWithNumber || startsWithMathPrefix) {
            result.push(mathResultObject);
        } else if (startsWithShellCommandPrefix) {
            result.push(commandResultObject);
        } else if (startsWithWebSearchPrefix) {
            result.push(webSearchResultObject);
        }

        result = result.concat(appResultObjects);
        result = result.concat(launcherActionObjects);

        if (Config.options.search.prefix.showDefaultActionsWithoutPrefix) {
            if (!startsWithShellCommandPrefix) result.push(commandResultObject);
            if (!startsWithNumber && !startsWithMathPrefix) result.push(mathResultObject);
            if (!startsWithWebSearchPrefix) result.push(webSearchResultObject);
        }

        root.cachedResults = result;
    }

    Timer {
        id: searchDebounceTimer
        interval: 32  // ~2 frames debounce
        onTriggered: {
            root.debouncedSearchText = root.searchingText;
            root.updateSearchResults();
        }
    }

    onSearchingTextChanged: {
        searchDebounceTimer.restart();
    }

    Timer {
        id: nonAppResultsTimer
        interval: Config.options.search.nonAppResultDelay
        onTriggered: {
            let expr = root.debouncedSearchText;
            if (expr.startsWith(Config.options.search.prefix.math)) {
                expr = expr.slice(Config.options.search.prefix.math.length);
            }
            mathProcess.calculateExpression(expr);
        }
    }

    Process {
        id: mathProcess
        property list<string> baseCommand: ["qalc", "-t"]
        function calculateExpression(expression) {
            mathProcess.running = false;
            mathProcess.command = baseCommand.concat(expression);
            mathProcess.running = true;
        }
        stdout: SplitParser {
            onRead: data => {
                root.mathResult = data;
                root.focusFirstItem();
            }
        }
    }

    Keys.onPressed: event => {
        // Prevent Esc and Backspace from registering
        if (event.key === Qt.Key_Escape)
            return;

        // Handle Backspace: focus and delete character if not focused
        if (event.key === Qt.Key_Backspace) {
            if (!searchBar.searchInput.activeFocus) {
                root.focusSearchInput();
                if (event.modifiers & Qt.ControlModifier) {
                    // Delete word before cursor
                    let text = searchBar.searchInput.text;
                    let pos = searchBar.searchInput.cursorPosition;
                    if (pos > 0) {
                        // Find the start of the previous word
                        let left = text.slice(0, pos);
                        let match = left.match(/(\s*\S+)\s*$/);
                        let deleteLen = match ? match[0].length : 1;
                        searchBar.searchInput.text = text.slice(0, pos - deleteLen) + text.slice(pos);
                        searchBar.searchInput.cursorPosition = pos - deleteLen;
                    }
                } else {
                    // Delete character before cursor if any
                    if (searchBar.searchInput.cursorPosition > 0) {
                        searchBar.searchInput.text = searchBar.searchInput.text.slice(0, searchBar.searchInput.cursorPosition - 1) + searchBar.searchInput.text.slice(searchBar.searchInput.cursorPosition);
                        searchBar.searchInput.cursorPosition -= 1;
                    }
                }
                // Always move cursor to end after programmatic edit
                searchBar.searchInput.cursorPosition = searchBar.searchInput.text.length;
                event.accepted = true;
            }
            // If already focused, let TextField handle it
            return;
        }

        // Only handle visible printable characters (ignore control chars, arrows, etc.)
        if (event.text && event.text.length === 1 && event.key !== Qt.Key_Enter && event.key !== Qt.Key_Return && event.key !== Qt.Key_Delete && event.text.charCodeAt(0) >= 0x20) // ignore control chars like Backspace, Tab, etc.
        {
            if (!searchBar.searchInput.activeFocus) {
                root.focusSearchInput();
                // Insert the character at the cursor position
                searchBar.searchInput.text = searchBar.searchInput.text.slice(0, searchBar.searchInput.cursorPosition) + event.text + searchBar.searchInput.text.slice(searchBar.searchInput.cursorPosition);
                searchBar.searchInput.cursorPosition += 1;
                event.accepted = true;
                root.focusFirstItem();
            }
        }
    }

    StyledRectangularShadow {
        target: searchWidgetContent
    }
    Rectangle { // Background
        id: searchWidgetContent
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: Appearance.sizes.elevationMargin
        }
        clip: true
        implicitWidth: columnLayout.implicitWidth
        implicitHeight: columnLayout.implicitHeight
        radius: searchBar.height / 2 + searchBar.verticalPadding
        color: Appearance.colors.colBackgroundSurfaceContainer

        Behavior on implicitHeight {
            id: searchHeightBehavior
            enabled: GlobalStates.overviewOpen && root.showResults
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuart
            }
        }

        ColumnLayout {
            id: columnLayout
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }
            spacing: 0

            // clip: true
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: searchWidgetContent.width
                    height: searchWidgetContent.width
                    radius: searchWidgetContent.radius
                }
            }

            SearchBar {
                id: searchBar
                property real verticalPadding: 4
                Layout.fillWidth: true
                Layout.leftMargin: 10
                Layout.rightMargin: 4
                Layout.topMargin: verticalPadding
                Layout.bottomMargin: verticalPadding
                Synchronizer on searchingText {
                    property alias source: root.searchingText
                }
            }

            Rectangle {
                // Separator
                visible: root.showResults
                Layout.fillWidth: true
                height: 1
                color: Appearance.colors.colOutlineVariant
            }

            ListView { // App results
                id: appResults
                visible: root.showResults
                Layout.fillWidth: true
                implicitHeight: Math.min(600, appResults.contentHeight + topMargin + bottomMargin)
                clip: true
                topMargin: 10
                bottomMargin: 10
                spacing: 2
                KeyNavigation.up: searchBar
                highlightMoveDuration: 100

                onFocusChanged: {
                    if (focus)
                        appResults.currentIndex = 1;
                }

                Connections {
                    target: root
                    function onSearchingTextChanged() {
                        if (appResults.count > 0)
                            appResults.currentIndex = 0;
                    }
                }

                model: ScriptModel {
                    id: model
                    objectProp: "key"
                    values: root.cachedResults
                }

                delegate: SearchItem {
                    // The selectable item for each search result
                    required property var modelData
                    anchors.left: parent?.left
                    anchors.right: parent?.right
                    entry: modelData
                    query: StringUtils.cleanOnePrefix(root.debouncedSearchText, [
                        Config.options.search.prefix.action,
                        Config.options.search.prefix.app,
                        Config.options.search.prefix.clipboard,
                        Config.options.search.prefix.emojis,
                        Config.options.search.prefix.math,
                        Config.options.search.prefix.shellCommand,
                        Config.options.search.prefix.webSearch
                    ])
                }
            }
        }
    }
}
