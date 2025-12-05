pragma Singleton
pragma ComponentBehavior: Bound
import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

/**
 * Screensharing and mic activity indicators.
 */
Singleton {
    id: root

    property bool screenSharing: Pipewire.linkGroups.values.filter(pwlg => pwlg.source.type === PwNodeType.VideoSource).length > 0
    property bool micActive: Pipewire.linkGroups.values.filter(pwlg => pwlg.source.type === PwNodeType.AudioSource && pwlg.target.type === PwNodeType.AudioInStream).length > 0
}
