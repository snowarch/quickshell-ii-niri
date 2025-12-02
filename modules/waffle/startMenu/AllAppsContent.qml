pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.waffle.looks

WPanelPageColumn {
    id: root
    signal back()

    WPanelSeparator {}

    BodyRectangle {
        Layout.fillWidth: true
        implicitHeight: 600
        implicitWidth: 768

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                WBorderlessButton {
                    implicitHeight: 28
                    implicitWidth: backRow.implicitWidth + 16
                    contentItem: RowLayout {
                        id: backRow
                        spacing: 4
                        FluentIcon { icon: "chevron-left"; implicitSize: 12 }
                        WText { text: Translation.tr("Back"); font.pixelSize: Looks.font.pixelSize.small }
                    }
                    onClicked: root.back()
                }
                Item { Layout.fillWidth: true }
                WText {
                    text: Translation.tr("All apps")
                    font.pixelSize: Looks.font.pixelSize.large
                    font.weight: Font.DemiBold
                }
            }

            ListView {
                id: appsList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 2

                model: ScriptModel {
                    values: DesktopEntries.applications.values
                        .filter(e => !e.noDisplay)
                        .sort((a, b) => (a.name || "").localeCompare(b.name || ""))
                }

                section.property: "modelData.name"
                section.criteria: ViewSection.FirstCharacter
                section.delegate: Item {
                    required property string section
                    width: appsList.width
                    height: 32
                    WText {
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        text: section.toUpperCase()
                        font.pixelSize: Looks.font.pixelSize.small
                        font.weight: Font.DemiBold
                        color: Looks.colors.accent
                    }
                }

                delegate: WBorderlessButton {
                    id: appItem
                    required property var modelData
                    width: appsList.width
                    implicitHeight: 44

                    onClicked: {
                        modelData.execute()
                        GlobalStates.searchOpen = false
                    }

                    contentItem: RowLayout {
                        spacing: 12
                        Image {
                            source: Quickshell.iconPath(appItem.modelData.icon || appItem.modelData.name, "application-x-executable")
                            sourceSize: Qt.size(28, 28)
                            width: 28; height: 28
                        }
                        WText {
                            Layout.fillWidth: true
                            text: appItem.modelData.name || ""
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }
}
