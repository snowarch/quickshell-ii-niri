import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.modules.overview as OverviewModule
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Io

Scope {
    id: root

    property int panelWidth: 600
    property int panelMaxHeight: 700
    property string searchText: ""
    property int totalCount: 0
    property bool showKeyboardHints: false
    property string lastCopiedEntry: ""

    function formatCliphistName(entry) {
        let cleaned = StringUtils.cleanCliphistEntry(entry)
        if (Cliphist.entryIsImage(entry)) {
            cleaned = cleaned.replace(/^\s*\[\[.*?\]\]\s*/, "")
        }
        return cleaned.trim()
    }

    function updateFilteredModel() {
        console.log("[ClipboardPanel] Updating filtered model from", Cliphist.entries.length, "entries")
        filteredClipboardModel.clear()

        const trimmedSearch = searchText.trim().toLowerCase()

        for (let i = 0; i < Cliphist.entries.length; i++) {
            const entry = Cliphist.entries[i]
            if (trimmedSearch.length === 0) {
                filteredClipboardModel.append({
                    "rawEntry": entry
                })
            } else {
                const content = formatCliphistName(entry).toLowerCase()
                if (content.includes(trimmedSearch)) {
                    filteredClipboardModel.append({
                        "rawEntry": entry
                    })
                }
            }
        }

        totalCount = filteredClipboardModel.count

        if (totalCount > 0 && typeof listView !== "undefined" && listView) {
            listView.currentIndex = 0
        }
    }

    function open() {
        GlobalStates.clipboardOpen = true
    }

    function close() {
        GlobalStates.clipboardOpen = false
    }

    function toggle() {
        GlobalStates.clipboardOpen = !GlobalStates.clipboardOpen
    }

    function copyEntry(entry) {
        console.log("[ClipboardPanel] copyEntry", String(entry).slice(0, 120))
        lastCopiedEntry = entry
        Cliphist.copy(entry)
        GlobalStates.clipboardOpen = false
    }

    function deleteEntry(entry) {
        Cliphist.deleteEntry(entry)
    }

    function clearAll() {
        Cliphist.wipe()
        GlobalStates.clipboardOpen = false
    }

    function refresh() {
        console.log("[ClipboardPanel] Refreshing clipboard via Cliphist service...")
        Cliphist.refresh()
    }

    Component.onCompleted: {
        refresh()
    }

    Connections {
        target: Cliphist
        function onEntriesChanged() {
            root.updateFilteredModel()
        }
    }

    ListModel {
        id: filteredClipboardModel
    }

    Connections {
        target: GlobalStates
        function onClipboardOpenChanged() {
            if (GlobalStates.clipboardOpen) {
                root.refresh()
                root.searchText = ""
                Qt.callLater(() => searchField.forceActiveFocus())
            }
        }
    }

    IpcHandler {
        target: "clipboard"
        function open() {
            root.open()
        }
        function close() {
            root.close()
        }
        function toggle() {
            root.toggle()
        }
    }

    PanelWindow {
        id: window
        visible: GlobalStates.clipboardOpen
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        WlrLayershell.namespace: "quickshell:clipboardPanel"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: GlobalStates.clipboardOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        Keys.onPressed: function (event) {
            if (!GlobalStates.clipboardOpen)
                return

            // Helper to get current entry from filtered model
            function currentEntry() {
                const idx = listView.currentIndex
                if (idx < 0 || idx >= filteredClipboardModel.count)
                    return null
                return filteredClipboardModel.get(idx).rawEntry
            }

            if (event.key === Qt.Key_Escape) {
                GlobalStates.clipboardOpen = false
                event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                // Paste current entry and close
                listView.activateCurrent()
                event.accepted = true
            } else if (event.key === Qt.Key_Down || event.key === Qt.Key_J) {
                listView.moveNext()
                event.accepted = true
            } else if (event.key === Qt.Key_Up || event.key === Qt.Key_K) {
                listView.movePrevious()
                event.accepted = true
            } else if (event.key === Qt.Key_Delete && (event.modifiers & Qt.ShiftModifier)) {
                // Clear all history (Shift+Del)
                root.clearAll()
                event.accepted = true
            } else if (event.key === Qt.Key_Delete && event.modifiers === Qt.NoModifier) {
                // Delete current entry
                const entry = currentEntry()
                if (entry !== null) {
                    root.deleteEntry(entry)
                    event.accepted = true
                }
            } else if (event.key === Qt.Key_C && (event.modifiers & Qt.ControlModifier)) {
                // Copy current entry to clipboard
                const entry = currentEntry()
                if (entry !== null) {
                    root.copyEntry(entry)
                    event.accepted = true
                }
            } else if (event.key === Qt.Key_F10) {
                // Toggle keyboard hints
                root.showKeyboardHints = !root.showKeyboardHints
                event.accepted = true
            }
        }

        StyledRectangularShadow {
            target: panelBackground
            radius: panelBackground.radius
        }

        // Click outside the panel to close
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: mouse => {
                const localPos = mapToItem(panelBackground, mouse.x, mouse.y)
                const outside = (localPos.x < 0 || localPos.x > panelBackground.width
                        || localPos.y < 0 || localPos.y > panelBackground.height)
                if (outside) {
                    GlobalStates.clipboardOpen = false
                } else {
                    mouse.accepted = false
                }
            }
        }

        Rectangle {
            id: panelBackground
            anchors.centerIn: parent
            width: panelWidth
            height: Math.min(contentColumn.implicitHeight, panelMaxHeight)
            color: Appearance.colors.colLayer0
            border.width: 1
            border.color: Appearance.colors.colLayer0Border
            radius: Appearance.rounding.screenRounding

            ColumnLayout {
                id: contentColumn
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Toolbar {
                    id: headerToolbar
                    Layout.fillWidth: true
                    enableShadow: false

                    MaterialSymbol {
                        text: "content_paste"
                        iconSize: Appearance.font.pixelSize.huge
                        color: Appearance.colors.colPrimary
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignVCenter
                        text: Translation.tr("Clipboard history") + ` (${root.totalCount})`
                        font.pixelSize: Appearance.font.pixelSize.small
                        color: Appearance.m3colors.m3onSurface
                        elide: Text.ElideRight
                    }

                    ToolbarTextField {
                        id: searchField
                        Layout.fillWidth: true
                        implicitHeight: 40
                        focus: true
                        text: root.searchText
                        placeholderText: Translation.tr("Search clipboard history")
                        onTextChanged: {
                            root.searchText = text
                            root.updateFilteredModel()
                        }
                        Keys.onEscapePressed: function(event) {
                            GlobalStates.clipboardOpen = false
                            event.accepted = true
                        }
                    }

                    IconToolbarButton {
                        implicitWidth: height
                        onClicked: {
                            root.showKeyboardHints = !root.showKeyboardHints
                        }
                        text: "help"
                        StyledToolTip {
                            text: Translation.tr("Keyboard hints")
                        }
                    }

                    IconToolbarButton {
                        implicitWidth: height
                        onClicked: {
                            root.clearAll()
                        }
                        text: "delete"
                        StyledToolTip {
                            text: Translation.tr("Clear all")
                        }
                    }

                    IconToolbarButton {
                        implicitWidth: height
                        onClicked: {
                            GlobalStates.clipboardOpen = false
                        }
                        text: "close"
                        StyledToolTip {
                            text: Translation.tr("Close")
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    // Keep a sensible minimum height so single-result lists don't visually collapse
                    implicitHeight: Math.min(480, Math.max(160, listView.contentHeight + 20))
                    radius: Appearance.rounding.normal
                    color: Appearance.colors.colLayer1
                    clip: true

                    ListView {
                        id: listView
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 2
                        clip: true

                        model: filteredClipboardModel

                        delegate: ClipboardItem {
                            required property string rawEntry
                            required property int index
                            anchors.left: parent?.left
                            anchors.right: parent?.right
                            isSelected: ListView.isCurrentItem
                            copiedFromPanel: rawEntry === lastCopiedEntry
                            entry: {
                                const raw = rawEntry
                                const type = `#${raw.match(/^[\s]*(\S+)/)?.[1] || ""}`
                                const name = formatCliphistName(raw)
                                return {
                                    key: type,
                                    cliphistRawString: raw,
                                    name: name,
                                    clickActionName: Translation.tr("Copy"),
                                    type: type,
                                    execute: () => {
                                        root.copyEntry(raw)
                                    },
                                    actions: [
                                        {
                                            name: "Copy",
                                            materialIcon: "content_copy",
                                            execute: () => root.copyEntry(raw),
                                        },
                                        {
                                            name: "Delete",
                                            materialIcon: "delete",
                                            execute: () => root.deleteEntry(raw),
                                        },
                                    ],
                                    blurImage: false,
                                    blurImageText: Translation.tr("Work safety"),
                                    compactClipboardPreview: true,
                                }
                            }
                            query: root.searchText
                        }

                        function moveNext() {
                            const total = count
                            if (total === 0) return
                            if (currentIndex < 0)
                                currentIndex = 0
                            else
                                currentIndex = (currentIndex + 1) % total
                        }

                        function movePrevious() {
                            const total = count
                            if (total === 0) return
                            if (currentIndex < 0)
                                currentIndex = total - 1
                            else
                                currentIndex = (currentIndex - 1 + total) % total
                        }

                        function activateCurrent() {
                            if (currentIndex < 0 || currentIndex >= count) return
                            const rawEntry = filteredClipboardModel.get(currentIndex).rawEntry
                            Cliphist.copy(rawEntry)
                            GlobalStates.clipboardOpen = false
                        }

                        StyledText {
                            visible: listView.count === 0
                            anchors.centerIn: parent
                            text: Translation.tr("No clipboard entries")
                            color: Appearance.colors.colSubtext
                            font.pixelSize: Appearance.font.pixelSize.small
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.showKeyboardHints ? 56 : 0

                    Behavior on Layout.preferredHeight {
                        NumberAnimation {
                            duration: Appearance.animation.duration.shortDuration
                            easing.type: Appearance.animationCurves.standardEasing
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: Appearance.rounding.normal
                        color: ColorUtils.transparentize(Appearance.colors.colLayer1, 0.15)
                        border.color: Appearance.colors.colPrimary
                        border.width: 1
                        opacity: root.showKeyboardHints ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Appearance.animation.duration.shortDuration
                                easing.type: Appearance.animationCurves.standardEasing
                            }
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 2

                            StyledText {
                                Layout.fillWidth: true
                                text: Translation.tr("↑/↓, J/K: Navigate • Enter: Paste")
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.m3colors.m3onSurface
                                elide: Text.ElideRight
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: Translation.tr("Ctrl+C: Copy • Del: Delete • Shift+Del: Clear all • Esc: Close • F10: Toggle hints")
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.m3colors.m3onSurface
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }
    }
}
