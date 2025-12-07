import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.modules.waffle.looks
import qs.modules.waffle.bar

BarPopup {
    id: root
    required property QsMenuHandle trayItemMenuHandle
    
    closeOnFocusLost: true
    closeOnHoverLost: true
    padding: 2
    visualMargin: 8

    contentItem: Item {
        implicitWidth: Math.min(stackView.implicitWidth, 220)
        implicitHeight: stackView.implicitHeight

        StackView {
            id: stackView
            anchors.fill: parent
            pushEnter: NoAnim {}
            pushExit: NoAnim {}
            popEnter: NoAnim {}
            popExit: NoAnim {}

            implicitWidth: currentItem?.implicitWidth ?? 100
            implicitHeight: currentItem?.implicitHeight ?? 50

            initialItem: SubMenu {
                handle: root.trayItemMenuHandle
            }
        }
    }

    component NoAnim: Transition {
        NumberAnimation { duration: 0 }
    }

    component SubMenu: ColumnLayout {
        id: submenu
        required property QsMenuHandle handle
        property bool isSubMenu: false
        property bool shown: false
        opacity: shown ? 1 : 0

        Behavior on opacity {
            animation: Looks.transition.opacity.createObject(this)
        }

        Component.onCompleted: shown = true
        StackView.onActivating: shown = true
        StackView.onDeactivating: shown = false
        StackView.onRemoved: destroy()

        QsMenuOpener {
            id: menuOpener
            menu: submenu.handle
        }

        spacing: 0

        // Back button for submenus
        Loader {
            Layout.fillWidth: true
            visible: submenu.isSubMenu
            active: visible
            sourceComponent: WButton {
                inset: 2
                icon.name: "chevron-left"
                text: Translation.tr("Back")
                onClicked: stackView.pop()
            }
        }

        Repeater {
            id: menuEntriesRepeater
            property bool iconColumnNeeded: {
                for (let i = 0; i < menuOpener.children.values.length; i++) {
                    if (menuOpener.children.values[i].icon.length > 0)
                        return true;
                }
                return false;
            }
            property bool specialInteractionColumnNeeded: {
                for (let i = 0; i < menuOpener.children.values.length; i++) {
                    if (menuOpener.children.values[i].buttonType !== QsMenuButtonType.None)
                        return true;
                }
                return false;
            }
            model: menuOpener.children
            delegate: Loader {
                required property QsMenuEntry modelData
                Layout.fillWidth: true
                
                sourceComponent: modelData.isSeparator ? separatorComponent : menuEntryComponent
                
                Component {
                    id: separatorComponent
                    Rectangle {
                        height: 1
                        color: Looks.colors.bg0Border
                        Layout.fillWidth: true
                        Layout.topMargin: 4
                        Layout.bottomMargin: 4
                    }
                }
                
                Component {
                    id: menuEntryComponent
                    WaffleTrayMenuEntry {
                        forceIconColumn: menuEntriesRepeater.iconColumnNeeded
                        forceSpecialInteractionColumn: menuEntriesRepeater.specialInteractionColumnNeeded
                        menuEntry: modelData

                        onDismiss: root.close()
                        onOpenSubmenu: handle => {
                            stackView.push(subMenuComponent.createObject(null, {
                                handle: handle,
                                isSubMenu: true
                            }));
                        }
                    }
                }
            }
        }
    }

    Component {
        id: subMenuComponent
        SubMenu {}
    }
}
