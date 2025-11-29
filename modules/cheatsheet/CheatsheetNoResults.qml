import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

/**
 * No results message following M3 typography and color patterns.
 */
Item {
    id: root
    signal clearSearchRequested()
    
    implicitWidth: contentColumn.implicitWidth
    implicitHeight: contentColumn.implicitHeight
    
    ColumnLayout {
        id: contentColumn
        anchors.centerIn: parent
        spacing: 10
        
        MaterialSymbol {
            Layout.alignment: Qt.AlignHCenter
            text: "search_off"
            iconSize: 40
            color: Appearance.colors.colSubtext
        }
        
        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: Translation.tr("No matches found")
            font.pixelSize: Appearance.font.pixelSize.large
            color: Appearance.m3colors.m3onSurface
        }
        
        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: Translation.tr("Try a different search term")
            font.pixelSize: Appearance.font.pixelSize.smaller
            color: Appearance.colors.colSubtext
        }
        
        // M3 action button (Section 4.3)
        RippleButton {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 6
            implicitWidth: clearContent.implicitWidth + 20
            implicitHeight: 32
            buttonRadius: Appearance.rounding.full
            colBackground: Appearance.colors.colSurfaceContainer
            colBackgroundHover: Appearance.colors.colSurfaceContainerHigh
            colRipple: Appearance.colors.colSurfaceContainerHighest
            onClicked: root.clearSearchRequested()
            
            contentItem: RowLayout {
                id: clearContent
                anchors.centerIn: parent
                spacing: 4
                
                MaterialSymbol {
                    text: "backspace"
                    iconSize: Appearance.font.pixelSize.small
                    color: Appearance.m3colors.m3onSurface
                }
                
                StyledText {
                    text: Translation.tr("Clear search")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.m3colors.m3onSurface
                }
            }
        }
    }
}
