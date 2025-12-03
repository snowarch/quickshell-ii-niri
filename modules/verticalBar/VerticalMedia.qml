import qs.modules.common
import qs.modules.common.widgets
import qs.services
import qs
import qs.modules.common.functions

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

import qs.modules.bar as Bar

MouseArea {
    id: root
    property bool borderless: Config.options.bar.borderless
    readonly property MprisPlayer activePlayer: MprisController.activePlayer
    readonly property string cleanedTitle: StringUtils.cleanMusicTitle(activePlayer?.trackTitle) || Translation.tr("No media")
    property bool volumePopupVisible: false

    Layout.fillHeight: true
    implicitHeight: mediaCircProg.implicitHeight
    implicitWidth: Appearance.sizes.verticalBarWidth

    Timer {
        running: activePlayer?.playbackState == MprisPlaybackState.Playing
        interval: Config.options.resources.updateInterval
        repeat: true
        onTriggered: activePlayer?.positionChanged()
    }

    Timer {
        id: volumeHideTimer
        interval: 1000
        onTriggered: root.volumePopupVisible = false
    }

    acceptedButtons: Qt.MiddleButton | Qt.BackButton | Qt.ForwardButton | Qt.RightButton | Qt.LeftButton
    hoverEnabled: true
    onPressed: (event) => {
        if (event.button === Qt.MiddleButton) {
            activePlayer?.togglePlaying();
        } else if (event.button === Qt.BackButton) {
            activePlayer?.previous();
        } else if (event.button === Qt.ForwardButton || event.button === Qt.RightButton) {
            activePlayer?.next();
        } else if (event.button === Qt.LeftButton) {
            GlobalStates.mediaControlsOpen = !GlobalStates.mediaControlsOpen
        }
    }
    onWheel: (event) => {
        if (!activePlayer?.volumeSupported) return
        const step = 0.05
        if (event.angleDelta.y > 0) activePlayer.volume = Math.min(1, activePlayer.volume + step)
        else if (event.angleDelta.y < 0) activePlayer.volume = Math.max(0, activePlayer.volume - step)
        root.volumePopupVisible = true
        volumeHideTimer.restart()
    }

    ClippedFilledCircularProgress {
        id: mediaCircProg
        anchors.centerIn: parent
        implicitSize: 20

        lineWidth: Appearance.rounding.unsharpen
        value: activePlayer?.position / activePlayer?.length
        colPrimary: Appearance.colors.colOnSecondaryContainer
        enableAnimation: false

        Item {
            anchors.centerIn: parent
            width: mediaCircProg.implicitSize
            height: mediaCircProg.implicitSize
            
            MaterialSymbol {
                anchors.centerIn: parent
                fill: 1
                text: activePlayer?.isPlaying ? "pause" : "music_note"
                iconSize: Appearance.font.pixelSize.normal
                color: Appearance.m3colors.m3onSecondaryContainer
            }
        }
    }

    // Volume popup (shows on hover or scroll)
    Bar.StyledPopup {
        hoverTarget: root
        active: (root.volumePopupVisible || root.containsMouse) && !GlobalStates.mediaControlsOpen

        Row {
            anchors.centerIn: parent
            spacing: 4
            MaterialSymbol {
                text: (activePlayer?.volume ?? 0) === 0 ? "volume_off" : "volume_up"
                iconSize: Appearance.font.pixelSize.small
                color: Appearance.m3colors.m3onSurface
            }
            StyledText {
                text: Math.round((activePlayer?.volume ?? 0) * 100) + "%"
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.m3colors.m3onSurface
            }
        }
    }

}
