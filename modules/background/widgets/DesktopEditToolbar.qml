pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root

    required property real availableWidth
    required property real availableHeight
    property bool libraryOpen: false
    property string outputName: ""
    property bool hasSelection: false
    property bool gridExpanded: false

    signal libraryRequested()
    signal settingsRequested()
    signal edgeSettingsRequested()
    signal doneRequested()

    readonly property int gridSize: Config.getNestedValue("background.widgets.editGrid.size", 32)
    readonly property bool snap: Config.getNestedValue("background.widgets.editGrid.snap", true)
    readonly property bool compact: availableWidth < 760
    readonly property int railItemStride: 34
    readonly property int railSlots: Math.max(3, Math.min(12,
        Math.floor(Math.max(railItemStride * 3, availableWidth - 390) / railItemStride)))
    readonly property real railWidth: railSlots * railItemStride
    readonly property var builtinWidgets: [
        { key: "weather", icon: "cloud", label: "Weather", defaultOn: false },
        { key: "customImage", icon: "add_photo_alternate", label: "Custom Image", defaultOn: false },
        { key: "imageConverter", icon: "transform", label: "Image Converter", defaultOn: false },
        { key: "clock", icon: "schedule", label: "Clock", defaultOn: true },
        { key: "mediaControls", icon: "album", label: "Media", defaultOn: false },
        { key: "japaneseTypography", icon: "translate", label: "Japanese Typography", defaultOn: false },
        { key: "visualizer", icon: "graphic_eq", label: "Visualizer", defaultOn: false },
        { key: "systemMonitor", icon: "monitor_heart", label: "System Monitor", defaultOn: false },
        { key: "battery", icon: "battery_full", label: "Battery", defaultOn: false },
        { key: "notes", icon: "sticky_note_2", label: "Notes", defaultOn: false },
        { key: "calendarUpcoming", icon: "event", label: "Upcoming Events", defaultOn: false },
        { key: "monthCalendar", icon: "calendar_month", label: "Month Calendar", defaultOn: false },
        { key: "todo", icon: "checklist", label: "Todo", defaultOn: false },
        { key: "timers", icon: "timer", label: "Timers", defaultOn: false },
        { key: "uptime", icon: "avg_pace", label: "System Uptime", defaultOn: false },
        { key: "shape", icon: "category", label: "Decorative Shape", defaultOn: false },
        { key: "dateBadge", icon: "today", label: "Date Badge", defaultOn: false },
        { key: "editorial", icon: "text_fields", label: "Editorial", defaultOn: false },
        { key: "mascot", icon: "pets", label: "Mascot", defaultOn: false },
        { key: "newsTicker", icon: "newspaper", label: "News Ticker", defaultOn: false },
        { key: "worldClock", icon: "public", label: "World Clock", defaultOn: false },
        { key: "userCard", icon: "account_circle", label: "User Card", defaultOn: false }
    ]

    width: Math.min(availableWidth, Math.max(320, toolbarRow.implicitWidth + 12))
    height: 48

    Toolbar {
        anchors.fill: parent
        padding: 6
        spacing: 4
        screenX: root.x
        screenY: root.y
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        acceptedButtons: Qt.AllButtons
    }

    RowLayout {
        id: toolbarRow
        anchors.fill: parent
        anchors.margins: 6
        spacing: 4

        WidgetEditAction {
            id: snapAction
            compact: true
            iconName: root.snap ? "grid_on" : "grid_off"
            label: Translation.tr("Snap to grid")
            toggled: root.snap
            tooltip: root.snap ? Translation.tr("Disable grid snap") : Translation.tr("Enable grid snap")
            onClicked: Config.setNestedValue("background.widgets.editGrid.snap", !root.snap)
        }

        WidgetEditAction {
            id: gridSizeAction
            iconName: "grid_4x4"
            label: root.gridSize + " px"
            compact: root.availableWidth < 560
            tooltip: Translation.tr("Grid size: %1px — click to cycle").arg(root.gridSize)
            onClicked: {
                const sizes = [16, 32, 48, 64]
                const index = sizes.indexOf(root.gridSize)
                Config.setNestedValue("background.widgets.editGrid.size",
                    sizes[(index + 1) % sizes.length])
            }
        }

        Rectangle {
            Layout.preferredWidth: 1
            Layout.preferredHeight: 22
            color: Appearance.colors.colOutlineVariant
            opacity: 0.42
        }

        WidgetEditAction {
            compact: true
            iconName: "chevron_left"
            label: Translation.tr("Previous widgets")
            enabled: widgetRail.contentX > 1
            opacity: enabled ? 1 : 0.28
            onClicked: widgetRail.scrollPage(-1)
        }

        Flickable {
            id: widgetRail
            Layout.preferredWidth: root.railWidth
            Layout.minimumWidth: root.railWidth
            Layout.maximumWidth: root.railWidth
            Layout.preferredHeight: 32
            contentWidth: widgetRow.implicitWidth
            contentHeight: height
            clip: true
            interactive: contentWidth > width
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.HorizontalFlick

            function snapContentX(value: real): real {
                const maxX = Math.max(0, contentWidth - width)
                const snapped = Math.round(value / root.railItemStride) * root.railItemStride
                return Math.max(0, Math.min(maxX, snapped))
            }

            function scrollPage(direction: int): void {
                const page = Math.max(root.railItemStride,
                    (root.railSlots - 1) * root.railItemStride)
                contentX = snapContentX(contentX + direction * page)
            }

            onMovementEnded: contentX = snapContentX(contentX)
            onWidthChanged: Qt.callLater(() => contentX = snapContentX(contentX))
            onContentWidthChanged: Qt.callLater(() => contentX = snapContentX(contentX))

            WheelHandler {
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                onWheel: event => {
                    const horizontal = event.angleDelta.x
                    const vertical = event.angleDelta.y
                    const delta = Math.abs(horizontal) > Math.abs(vertical) ? -horizontal : -vertical
                    if (delta !== 0)
                        widgetRail.contentX = widgetRail.snapContentX(widgetRail.contentX
                            + (delta > 0 ? root.railItemStride * 3 : -root.railItemStride * 3))
                    event.accepted = true
                }
            }

            Row {
                id: widgetRow
                spacing: 2

                Repeater {
                    model: root.builtinWidgets
                    WidgetEditAction {
                        required property var modelData
                        readonly property bool widgetEnabled: DesktopWidgetLayout.enabled(
                            root.outputName, modelData.key,
                            Config.getNestedValue("background.widgets." + modelData.key + ".enable", modelData.defaultOn))
                        compact: true
                        iconName: modelData.icon
                        label: Translation.tr(modelData.label)
                        tooltip: Translation.tr(modelData.label)
                        toggled: widgetEnabled
                        onClicked: DesktopWidgetLayout.setGloballyEnabled(modelData.key, !widgetEnabled)
                    }
                }

                Repeater {
                    model: CustomWidgets.ready ? CustomWidgets.widgets : []
                    WidgetEditAction {
                        required property var modelData
                        readonly property string layoutKey: "custom." + modelData.id
                        readonly property bool widgetEnabled: DesktopWidgetLayout.enabled(
                            root.outputName, layoutKey,
                            Config.getNestedValue("background.widgets.custom." + modelData.id + ".enable", false))
                        compact: true
                        iconName: modelData.icon || "widgets"
                        label: modelData.name
                        tooltip: modelData.name
                        toggled: widgetEnabled
                        onClicked: DesktopWidgetLayout.setGloballyEnabled(layoutKey, !widgetEnabled)
                    }
                }
            }
        }

        WidgetEditAction {
            compact: true
            iconName: "chevron_right"
            label: Translation.tr("More widgets")
            enabled: widgetRail.contentX < Math.max(0, widgetRail.contentWidth - widgetRail.width) - 1
            opacity: enabled ? 1 : 0.28
            onClicked: widgetRail.scrollPage(1)
        }

        Rectangle {
            Layout.preferredWidth: 1
            Layout.preferredHeight: 22
            color: Appearance.colors.colOutlineVariant
            opacity: 0.42
        }

        WidgetEditAction {
            id: libraryAction
            iconName: "dashboard_customize"
            label: Translation.tr("Manage widgets")
            compact: root.availableWidth < 980
            toggled: root.libraryOpen
            tooltip: Translation.tr("Browse, add and manage widgets")
            onClicked: root.libraryRequested()
        }

        WidgetEditAction {
            compact: true
            iconName: "border_outer"
            label: Translation.tr("Screen edges")
            tooltip: Translation.tr("Configure Organic edge")
            onClicked: root.edgeSettingsRequested()
        }

        WidgetEditAction {
            compact: true
            iconName: "settings"
            label: Translation.tr("Widget settings")
            tooltip: Translation.tr("Open full widget settings")
            onClicked: root.settingsRequested()
        }

        Rectangle {
            Layout.preferredWidth: 1
            Layout.preferredHeight: 22
            color: Appearance.colors.colOutlineVariant
            opacity: 0.42
        }

        WidgetEditAction {
            id: doneAction
            iconName: "check"
            label: Translation.tr("Done")
            compact: root.availableWidth < 720
            primary: true
            tooltip: Translation.tr("Done editing")
            onClicked: root.doneRequested()
        }
    }
}
