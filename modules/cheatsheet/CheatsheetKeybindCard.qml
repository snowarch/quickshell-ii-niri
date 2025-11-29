pragma ComponentBehavior: Bound

import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Layouts

/**
 * Category card for keybinds following M3 patterns.
 * Uses colLayer0/colLayer1 hierarchy and m3onSurface typography.
 */
Rectangle {
    id: root
    
    required property var categoryData
    required property int categoryIndex
    property var keyBlacklist: ["Super_L"]
    property var keySubstitutions: ({})
    
    readonly property string categoryName: categoryData?.name ?? ""
    readonly property var keybindList: categoryData?.children?.[0]?.keybinds ?? []
    
    // M3 card styling - uses colLayer0 (same as panel background for subtle elevation)
    color: hovered ? Appearance.colors.colLayer0 : ColorUtils.transparentize(Appearance.colors.colLayer0, 0.5)
    radius: Appearance.rounding.normal
    border.width: 1
    border.color: hovered ? Appearance.colors.colLayer0Border : "transparent"
    
    implicitWidth: contentColumn.implicitWidth + 16
    implicitHeight: contentColumn.implicitHeight + 16
    
    property bool hovered: hoverArea.containsMouse
    
    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }
    
    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    // Staggered entrance animation
    opacity: 0
    transform: Translate { id: translateY; y: 12 }
    
    Component.onCompleted: animateIn.start()
    
    SequentialAnimation {
        id: animateIn
        PauseAnimation { duration: root.categoryIndex * 20 }
        ParallelAnimation {
            NumberAnimation { target: root; property: "opacity"; to: 1; duration: 250; easing.type: Easing.OutCubic }
            NumberAnimation { target: translateY; property: "y"; to: 0; duration: 250; easing.type: Easing.OutCubic }
        }
    }
    
    function restartAnimation() {
        opacity = 0; translateY.y = 12; animateIn.start()
    }
    
    ColumnLayout {
        id: contentColumn
        anchors { fill: parent; margins: 8 }
        spacing: 6
        
        // Category header - M3 typography (Section 4.2)
        StyledText {
            text: root.categoryName
            font.pixelSize: Appearance.font.pixelSize.small
            font.weight: Font.Medium
            color: Appearance.m3colors.m3onSurface
        }
        
        // Separator using outline color
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Appearance.colors.colOutlineVariant
        }
        
        // Keybind rows
        Column {
            Layout.fillWidth: true
            spacing: 2
            
            Repeater {
                model: root.keybindList
                
                delegate: CheatsheetKeybindRow {
                    required property var modelData
                    required property int index
                    
                    width: parent.width
                    keybindData: modelData
                    alternateBackground: index % 2 === 1
                    keyBlacklist: root.keyBlacklist
                    keySubstitutions: root.keySubstitutions
                }
            }
        }
    }
}
