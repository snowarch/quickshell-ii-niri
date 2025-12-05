pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.waffle.looks

// Single settings row with label and control - Windows 11 style
Item {
    id: root
    
    property string icon: ""
    property string label: ""
    property string description: ""
    property alias control: controlLoader.sourceComponent
    property bool clickable: false
    property bool showChevron: false
    
    signal clicked()
    
    Layout.fillWidth: true
    implicitHeight: Math.max(48, contentRow.implicitHeight + 16)
    
    Rectangle {
        id: background
        anchors.fill: parent
        radius: Looks.radius.medium
        color: root.clickable && mouseArea.containsMouse 
            ? Looks.colors.bg2Hover 
            : "transparent"
        
        Behavior on color {
            animation: Looks.transition.color.createObject(this)
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.clickable
        hoverEnabled: true
        cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }
    
    RowLayout {
        id: contentRow
        anchors {
            fill: parent
            leftMargin: 12
            rightMargin: 12
        }
        spacing: 12
        
        FluentIcon {
            visible: root.icon !== ""
            icon: root.icon
            implicitSize: 20
            color: Looks.colors.fg
        }
        
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            
            WText {
                Layout.fillWidth: true
                text: root.label
                font.pixelSize: Looks.font.pixelSize.normal
                elide: Text.ElideRight
            }
            
            WText {
                visible: root.description !== ""
                Layout.fillWidth: true
                text: root.description
                font.pixelSize: Looks.font.pixelSize.small
                color: Looks.colors.subfg
                wrapMode: Text.WordWrap
            }
        }
        
        Loader {
            id: controlLoader
            Layout.alignment: Qt.AlignVCenter
        }
        
        FluentIcon {
            visible: root.showChevron
            icon: "chevron-right"
            implicitSize: 16
            color: Looks.colors.subfg
        }
    }
}
