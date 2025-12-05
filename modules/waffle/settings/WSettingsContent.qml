pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.common.functions as CF
import qs.modules.waffle.looks

// Main Windows 11 style settings container
Item {
    id: root
    
    property var pages: []
    property int currentPage: 0
    property string searchText: ""
    property bool navExpanded: width > 800
    
    RowLayout {
        anchors.fill: parent
        spacing: 0
        
        // Navigation sidebar
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: root.navExpanded ? 240 : 56
            color: Looks.colors.bgPanelFooterBase
            
            Behavior on Layout.preferredWidth {
                NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
            }
            
            ColumnLayout {
                anchors {
                    fill: parent
                    margins: 8
                }
                spacing: 4
                
                // Search bar (only when expanded)
                Rectangle {
                    visible: root.navExpanded
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    radius: Looks.radius.medium
                    color: Looks.colors.inputBg
                    border.width: searchInput.activeFocus ? 2 : 1
                    border.color: searchInput.activeFocus ? Looks.colors.accent : Looks.colors.bg2Border
                    
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
                        
                        TextInput {
                            id: searchInput
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            verticalAlignment: Text.AlignVCenter
                            color: Looks.colors.fg
                            selectionColor: Looks.colors.selection
                            font.family: Looks.font.family.ui
                            font.pixelSize: Looks.font.pixelSize.normal
                            clip: true
                            
                            Text {
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                text: Translation.tr("Find a setting")
                                color: Looks.colors.subfg
                                font: parent.font
                                visible: !parent.text && !parent.activeFocus
                            }
                            
                            onTextChanged: root.searchText = text
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
                        // Use Qt.resolvedUrl to resolve relative to waffleSettings.qml
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
}
