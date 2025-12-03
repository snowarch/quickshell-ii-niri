pragma ComponentBehavior: Bound
import Qt.labs.synchronizer
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.waffle.looks

Item {
    id: root
    signal closed

    property bool searching: false
    property string searchText: ""
    property bool showAllApps: false

    // Size comes from the pane content
    implicitWidth: pane.implicitWidth + 24
    implicitHeight: pane.implicitHeight + 24

    function close() {
        root.closed()
    }

    // Get radius from preset
    property string preset: Config.options.waffles?.startMenu?.sizePreset ?? "normal"
    property int customRadius: preset === "mini" ? 20 : preset === "compact" ? 14 : 8

    WPane {
        id: pane
        anchors.centerIn: parent
        radius: root.customRadius

        contentItem: ColumnLayout {
            spacing: 0
            
            SearchBar {
                id: searchBar
                Layout.fillWidth: true
                Synchronizer on searching {
                    property alias target: root.searching
                }
                Synchronizer on text {
                    property alias source: root.searchText
                }
                Component.onCompleted: Qt.callLater(() => searchBar.forceActiveFocus())
                
                onNavigateUp: {
                    if (root.searching && searchPage.navigateUp) {
                        searchPage.navigateUp()
                    }
                }
                onNavigateDown: {
                    if (root.searching && searchPage.navigateDown) {
                        searchPage.navigateDown()
                    }
                }
                onAccepted: {
                    if (root.searching && searchPage.activateCurrent) {
                        searchPage.activateCurrent()
                    }
                }
            }
            
            // Fixed size container - always uses startPage dimensions
            Item {
                id: pageContainer
                Layout.fillWidth: true
                implicitWidth: startPage.implicitWidth
                implicitHeight: startPage.implicitHeight
                clip: true

                // Start page - always loaded, hidden when searching
                StartPageContent {
                    id: startPage
                    anchors.fill: parent
                    visible: !root.searching && !root.showAllApps
                    onAllAppsClicked: root.showAllApps = true
                }

                // Search page - always loaded, shown when searching
                SearchPageContent {
                    id: searchPage
                    anchors.fill: parent
                    visible: root.searching
                    searchText: root.searchText
                }

                // All apps - loaded on demand
                Loader {
                    id: allAppsLoader
                    anchors.fill: parent
                    active: root.showAllApps
                    sourceComponent: AllAppsContent {
                        onBack: root.showAllApps = false
                    }
                }
            }
        }
    }

    Keys.onEscapePressed: root.close()
}
