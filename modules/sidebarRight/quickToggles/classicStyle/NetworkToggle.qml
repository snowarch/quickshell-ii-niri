import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.modules.sidebarRight.quickToggles
import qs
import QtQuick
import Quickshell
import Quickshell.Io

QuickToggleButton {
    toggled: Network.wifiStatus !== "disabled"
    buttonIcon: Network.materialSymbol
    onClicked: Network.toggleWifi()
    altAction: () => {
        const cmd = Network.ethernet ? (Config.options?.apps?.networkEthernet ?? "nm-connection-editor") : (Config.options?.apps?.network ?? "nm-connection-editor")
        Quickshell.execDetached(["fish", "-c", cmd])
        GlobalStates.sidebarRightOpen = false
    }
    StyledToolTip {
        text: Translation.tr("%1 | Right-click to configure").arg(Network.networkName)
    }
}
