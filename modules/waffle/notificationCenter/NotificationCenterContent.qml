pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Qt.labs.synchronizer
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.waffle.looks

WBarAttachedPanelContent {
    id: root

    readonly property bool barAtBottom: Config.options.waffles.bar.bottom
    revealFromSides: true
    revealFromLeft: false

    property bool collapsed: false

    contentItem: ColumnLayout {
        id: contentLayout
        spacing: 12

        Item {
            id: notificationArea
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(300, notificationPane.implicitHeight)
            implicitWidth: notificationPane.implicitWidth

            WPane {
                id: notificationPane
                anchors.fill: parent
                contentItem: NotificationPaneContent {
                    implicitWidth: calendarColumnLayout.implicitWidth
                }
            }
        }

        WPane {
            id: calendarPane
            Layout.fillWidth: true
            contentItem: WPanelPageColumn {
                id: calendarColumnLayout
                DateHeader {
                    Layout.fillWidth: true
                    Synchronizer on collapsed {
                        property alias source: root.collapsed
                    }
                }

                WPanelSeparator {
                    visible: !root.collapsed
                }

                CalendarWidget {
                    Layout.fillWidth: true
                    Synchronizer on collapsed {
                        property alias source: root.collapsed
                    }
                }

                WPanelSeparator {}

                FocusFooter {
                    Layout.fillWidth: true
                }
            }
        }
    }
}
