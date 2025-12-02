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
                Layout.preferredWidth: pageLoader.item?.implicitWidth ?? 300
                Synchronizer on searching {
                    property alias target: root.searching
                }
                Synchronizer on text {
                    property alias source: root.searchText
                }
                Component.onCompleted: Qt.callLater(() => searchBar.forceActiveFocus())
                
                onNavigateUp: {
                    if (root.searching && pageLoader.item?.navigateUp) {
                        pageLoader.item.navigateUp()
                    }
                }
                onNavigateDown: {
                    if (root.searching && pageLoader.item?.navigateDown) {
                        pageLoader.item.navigateDown()
                    }
                }
                onAccepted: {
                    if (root.searching && pageLoader.item?.activateCurrent) {
                        pageLoader.item.activateCurrent()
                    }
                }
            }
            
            Loader {
                id: pageLoader
                Layout.fillWidth: true
                sourceComponent: {
                    if (root.searching) return searchPageComponent
                    if (root.showAllApps) return allAppsComponent
                    return startPageComponent
                }
            }
        }
    }

    Component {
        id: searchPageComponent
        SearchPageContent { 
            id: searchPage
            searchText: root.searchText
        }
    }

    Component {
        id: startPageComponent
        StartPageContent { onAllAppsClicked: root.showAllApps = true }
    }

    Component {
        id: allAppsComponent
        AllAppsContent { onBack: root.showAllApps = false }
    }

    Keys.onEscapePressed: root.close()
}
