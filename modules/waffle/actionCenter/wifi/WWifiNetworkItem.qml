import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs
import qs.services
import qs.services.network
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.modules.waffle.looks
import qs.modules.waffle.actionCenter

ExpandableChoiceButton {
    id: root
    required property WifiAccessPoint wifiNetwork

    // Auto-expand when password is requested
    Connections {
        target: root.wifiNetwork
        function onAskingPasswordChanged() {
            if (root.wifiNetwork?.askingPassword) {
                root.expanded = true;
            }
        }
    }

    contentItem: RowLayout {
        id: contentItem
        spacing: 12

        FluentIcon { // Duotone hack
            Layout.bottomMargin: 2
            Layout.alignment: Qt.AlignTop
            property int strength: root.wifiNetwork?.strength ?? 0
            icon: "wifi-1"
            implicitSize: 30
            color: Looks.colors.inactiveIcon

            FluentIcon { // Signal
                property int strength: root.wifiNetwork?.strength ?? 0
                icon: WIcons.wifiIconForStrength(strength)
                implicitSize: 30

                FluentIcon { // Security
                    anchors {
                        right: parent.right
                        bottom: parent.bottom
                    }
                    visible: root?.wifiNetwork?.isSecure ?? false
                    icon: "lock-closed"
                    filled: true
                    implicitSize: 14           
                }
            }
        }

        ColumnLayout {
            Layout.topMargin: statusText.visible ? 4 : 7
            Layout.bottomMargin: 4
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            spacing: 1

            Behavior on Layout.topMargin {
                animation: Looks.transition.move.createObject(this)
            }

            WText { // Network name
                Layout.fillWidth: true
                elide: Text.ElideRight
                font.pixelSize: Looks.font.pixelSize.large
                text: root.wifiNetwork?.ssid ?? Translation.tr("Unknown")
            }
            WText { // Status
                id: statusText
                Layout.fillWidth: true
                elide: Text.ElideRight
                text: root.wifiNetwork?.active ? Translation.tr("Connected") : root.wifiNetwork?.isSecure ? Translation.tr("Secured") : Translation.tr("Not secured")
                font.pixelSize: Looks.font.pixelSize.large
                color: Looks.colors.subfg
                visible: root.wifiNetwork?.active || root.expanded
                Behavior on opacity {
                    animation: Looks.transition.opacity.createObject(this)
                }
            }

            // Password input (shown when network requires password)
            ColumnLayout {
                id: passwordPrompt
                Layout.fillWidth: true
                Layout.topMargin: 4
                visible: root.wifiNetwork?.askingPassword ?? false
                spacing: 8

                WTextField {
                    id: passwordField
                    Layout.fillWidth: true
                    placeholderText: Translation.tr("Password")
                    echoMode: TextInput.Password
                    inputMethodHints: Qt.ImhSensitiveData

                    onAccepted: {
                        Network.changePassword(root.wifiNetwork, passwordField.text);
                        passwordField.text = "";
                    }

                    // Auto-focus when visible
                    onVisibleChanged: {
                        if (visible) Qt.callLater(() => passwordField.forceActiveFocus());
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Item { Layout.fillWidth: true }

                    WButton {
                        text: Translation.tr("Cancel")
                        implicitHeight: 30
                        colBackground: Looks.colors.bg2
                        colBackgroundHover: Looks.colors.bg2Hover
                        colBackgroundActive: Looks.colors.bg2Active
                        onClicked: {
                            root.wifiNetwork.askingPassword = false;
                            passwordField.text = "";
                        }
                    }

                    WButton {
                        text: Translation.tr("Connect")
                        implicitHeight: 30
                        checked: true
                        onClicked: {
                            Network.changePassword(root.wifiNetwork, passwordField.text);
                            passwordField.text = "";
                        }
                    }
                }
            }

            // Connect/Disconnect button (hidden when asking for password)
            WButton {
                Layout.alignment: Qt.AlignRight
                horizontalAlignment: Text.AlignHCenter
                visible: root.expanded && !(root.wifiNetwork?.askingPassword ?? false)
                checked: !(root.wifiNetwork?.active ?? false)
                colBackground: Looks.colors.bg2
                colBackgroundHover: Looks.colors.bg2Hover
                colBackgroundActive: Looks.colors.bg2Active
                implicitHeight: 30
                implicitWidth: 148
                text: root.wifiNetwork?.active ? Translation.tr("Disconnect") : Translation.tr("Connect")

                onClicked: {
                    if (root.wifiNetwork?.active) {
                        Network.disconnectWifiNetwork();
                    } else {
                        Network.connectToWifiNetwork(root.wifiNetwork);
                    }
                }
            }
        }
    }
}
