pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool isRecording: false

    Timer {
        id: pollTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            if (!checkProcess.running) {
                checkProcess.running = true
            }
        }
    }

    Process {
        id: checkProcess
        command: ["pgrep", "-x", "wf-recorder"]
        onExited: (exitCode, exitStatus) => {
            // pgrep returns 0 if process found, 1 if not found
            root.isRecording = (exitCode === 0)
        }
    }
}
