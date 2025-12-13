pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    // Mic active: device -> stream link (same as Audio.micBeingAccessed)
    property bool micActive: (Pipewire.links?.values ?? []).some(link =>
        !(link?.source?.isStream ?? true)
            && !(link?.source?.isSink ?? true)
            && (link?.target?.isStream ?? false)
    )

    // Screen sharing not detected here - done directly in UtilButtons/SystemButton
    property bool screenSharing: false
}
