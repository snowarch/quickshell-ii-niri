pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Quickshell

Singleton {
    id: root
    
    property StackView stackView: null

    function push(component) {
        if (stackView && stackView.depth !== undefined) {
            stackView.push(component)
        } else {
            console.warn("[ActionCenterContext] stackView not ready")
        }
    }

    function back() {
        if (stackView && stackView.depth > 1) {
            stackView.pop()
        }
    }
}
