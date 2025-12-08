import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.services

Item {
    id: root
    
    implicitHeight: themeButton.implicitHeight
    implicitWidth: 250
    Layout.fillWidth: true

    RippleButton {
        id: themeButton
        anchors.fill: parent
        implicitHeight: 40
        
        colBackground: Appearance.colors.colLayer1
        colBackgroundHover: Appearance.colors.colLayer1Hover
        colRipple: Appearance.colors.colLayer1Active

        contentItem: RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 8
            spacing: 8

            StyledText {
                Layout.fillWidth: true
                text: IconThemeService.currentTheme || "Select theme..."
                font.pixelSize: Appearance.font.pixelSize.small
                elide: Text.ElideRight
            }

            MaterialSymbol {
                text: popup.visible ? "expand_less" : "expand_more"
                iconSize: Appearance.font.pixelSize.normal
                color: Appearance.colors.colSubtext
            }
        }

        onClicked: popup.visible ? popup.close() : popup.open()
    }

    Popup {
        id: popup
        y: -height - 4
        width: Math.min(300, themeButton.width)
        height: Math.min(280, themeList.contentHeight + searchField.height + 24)
        padding: 8
        
        background: Rectangle {
            color: Appearance.colors.colLayer2
            radius: Appearance.rounding.normal
            border.width: 1
            border.color: Appearance.m3colors.m3outlineVariant
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 8

            TextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: Translation.tr("Search...")
                font.pixelSize: Appearance.font.pixelSize.small
                background: Rectangle {
                    color: Appearance.colors.colLayer1
                    radius: Appearance.rounding.small
                }
                color: Appearance.m3colors.m3onSurface
                placeholderTextColor: Appearance.colors.colSubtext
            }

            ListView {
                id: themeList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: {
                    let themes = IconThemeService.availableThemes
                    let search = searchField.text.toLowerCase()
                    if (search) return themes.filter(t => t.toLowerCase().includes(search))
                    return themes
                }

                delegate: RippleButton {
                    required property string modelData
                    width: themeList.width
                    implicitHeight: 32
                    
                    colBackground: modelData === IconThemeService.currentTheme 
                        ? Appearance.colors.colPrimaryContainer 
                        : "transparent"
                    colBackgroundHover: Appearance.colors.colLayer1Hover
                    colRipple: Appearance.colors.colLayer1Active

                    contentItem: StyledText {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        verticalAlignment: Text.AlignVCenter
                        text: modelData
                        font.pixelSize: Appearance.font.pixelSize.small
                        elide: Text.ElideRight
                        color: modelData === IconThemeService.currentTheme 
                            ? Appearance.m3colors.m3onPrimaryContainer 
                            : Appearance.m3colors.m3onSurface
                    }

                    onClicked: {
                        IconThemeService.setTheme(modelData)
                        popup.close()
                    }
                }
            }
        }
    }
}
