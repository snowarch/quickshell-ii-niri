import QtQuick
import qs.modules.common
import qs.modules.common.functions

Rectangle {
    id: root

    property bool editMode: false

    readonly property bool auroraEverywhere: (Config.options?.bar?.blurBackground?.enabled ?? false) && !(Config.options?.bar?.showBackground ?? true)

    radius: Appearance.rounding.normal
    color: root.auroraEverywhere ? ColorUtils.transparentize(Appearance.colors.colLayer1, Appearance.aurora.subSurfaceTransparentize) : Appearance.colors.colLayer1

    signal openAudioOutputDialog()
    signal openAudioInputDialog()
    signal openBluetoothDialog()
    signal openNightLightDialog()
    signal openWifiDialog()
}
