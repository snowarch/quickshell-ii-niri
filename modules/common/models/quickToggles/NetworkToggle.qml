import QtQuick
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

QuickToggleModel {
    name: Translation.tr("Internet")
    statusText: Network.networkName
    tooltipText: Translation.tr("%1 | Right-click to configure").arg(Network.networkName)
    icon: Network.materialSymbol

    toggled: Network.wifiStatus !== "disabled"
    mainAction: () => Network.toggleWifi()
    hasMenu: true
    altAction: () => {
        const cmd = Network.ethernet
            ? (Config.options?.apps?.networkEthernet ?? "nm-connection-editor")
            : (Config.options?.apps?.network ?? "nm-connection-editor")
        Quickshell.execDetached(["fish", "-c", cmd])
    }
}
