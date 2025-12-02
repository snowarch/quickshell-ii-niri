pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.waffle.looks

BodyRectangle {
    id: root

    required property string searchText

    implicitWidth: 832
    implicitHeight: Math.min(600, resultsView.contentHeight + 32)

    function navigateUp() {
        if (resultsView.currentIndex > 0) {
            resultsView.currentIndex--
        }
    }

    function navigateDown() {
        if (resultsView.currentIndex < resultsView.count - 1) {
            resultsView.currentIndex++
        }
    }

    function activateCurrent() {
        if (resultsView.currentItem) {
            resultsView.currentItem.clicked()
        }
    }

    ListView {
        id: resultsView
        anchors.fill: parent
        anchors.margins: 16
        clip: true
        spacing: 4
        highlightMoveDuration: 100
        focus: true
        currentIndex: 0
        keyNavigationEnabled: true

        Connections {
            target: root
            function onSearchTextChanged() {
                if (resultsView.count > 0) resultsView.currentIndex = 0
            }
        }

        Keys.onUpPressed: if (currentIndex > 0) currentIndex--
        Keys.onDownPressed: if (currentIndex < count - 1) currentIndex++
        Keys.onReturnPressed: if (currentItem) currentItem.clicked()
        Keys.onEnterPressed: if (currentItem) currentItem.clicked()

        model: ScriptModel {
            values: {
                if (!root.searchText || root.searchText.length === 0)
                    return []
                return AppSearch.fuzzyQuery(root.searchText).slice(0, 8)
            }
        }

        highlight: Rectangle {
            color: Looks.colors.bg1
            radius: Looks.radius.small
        }

        delegate: WBorderlessButton {
            id: resultItem
            required property var modelData
            required property int index

            width: resultsView.width
            implicitHeight: 56
            checked: resultsView.currentIndex === index

            onClicked: {
                if (modelData.execute) {
                    modelData.execute()
                    GlobalStates.searchOpen = false
                }
            }

            Keys.onReturnPressed: clicked()
            Keys.onEnterPressed: clicked()

            contentItem: RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 16

                Image {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    source: Quickshell.iconPath(modelData.icon || modelData.name, "application-x-executable")
                    sourceSize: Qt.size(32, 32)
                    fillMode: Image.PreserveAspectFit
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    WText {
                        Layout.fillWidth: true
                        text: modelData.name || ""
                        font.pixelSize: Looks.font.pixelSize.large
                        elide: Text.ElideRight
                    }

                    WText {
                        Layout.fillWidth: true
                        visible: modelData.description && modelData.description.length > 0
                        text: modelData.description || ""
                        color: Looks.colors.fg1
                        font.pixelSize: Looks.font.pixelSize.small
                        elide: Text.ElideRight
                    }
                }

                WText {
                    text: Translation.tr("App")
                    color: Looks.colors.fg1
                    font.pixelSize: Looks.font.pixelSize.small
                }
            }
        }

        // Empty state
        WText {
            anchors.centerIn: parent
            visible: resultsView.count === 0 && root.searchText.length > 0
            text: Translation.tr("No results found")
            color: Looks.colors.fg1
        }
    }
}
