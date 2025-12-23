import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.services
import qs.modules.sidebarRight.notifications
import qs.modules.sidebarRight.volumeMixer
import Qt5Compat.GraphicalEffects as GE
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    readonly property bool auroraEverywhere: (Config.options?.bar?.blurBackground?.enabled ?? false) && !(Config.options?.bar?.showBackground ?? true)
    radius: Appearance.rounding.normal
    color: root.auroraEverywhere ? ColorUtils.transparentize(Appearance.colors.colLayer1, Appearance.aurora.subSurfaceTransparentize) : Appearance.colors.colLayer1

    NotificationList {
        anchors.fill: parent
        anchors.margins: 5
    }
}
