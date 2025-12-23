import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.modules.sidebarRight.quickToggles.classicStyle

AbstractQuickPanel {
    id: root
    
    implicitHeight: grid.implicitHeight
    Layout.fillWidth: true

    Grid {
        id: grid
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        
        // Approximate width of a toggle (40) + spacing (12)
        property int itemSlotWidth: 52 
        columns: Math.max(1, Math.floor(root.width / itemSlotWidth))
        
        spacing: 12
        
        NetworkToggle {
            altAction: () => root.openWifiDialog()
        }
        
        BluetoothToggle {
            altAction: () => root.openBluetoothDialog()
        }
        
        NightLight {
            altAction: () => root.openNightLightDialog()
        }
        
        EasyEffectsToggle {
            altAction: () => Quickshell.execDetached(["easyeffects"])
        }
        
        IdleInhibitor {}
        
        GameMode {}
        
        CloudflareWarp {}
    }
}
