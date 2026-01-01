pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.services
import "root:"

Item {
    id: root
    implicitHeight: column.implicitHeight
    
    property bool animateIn: false

    property var widgetOrder: {
        const saved = Config.options?.sidebar?.widgets?.widgetOrder
        if (!saved) return defaultOrder
        const missing = defaultOrder.filter(id => !saved.includes(id))
        return [...saved, ...missing]
    }
    readonly property var defaultOrder: ["media", "week", "context", "note", "launch", "controls", "status", "crypto", "wallpaper"]
    readonly property int widgetSpacing: Config.options?.sidebar?.widgets?.spacing ?? 8

    readonly property bool showMedia: Config.options?.sidebar?.widgets?.media ?? true
    readonly property bool showWeek: Config.options?.sidebar?.widgets?.week ?? true
    readonly property bool showContext: Config.options?.sidebar?.widgets?.context ?? true
    readonly property bool showNote: Config.options?.sidebar?.widgets?.note ?? true
    readonly property bool showLaunch: Config.options?.sidebar?.widgets?.launch ?? true
    readonly property bool showControls: Config.options?.sidebar?.widgets?.controls ?? true
    readonly property bool showStatus: Config.options?.sidebar?.widgets?.status ?? true
    readonly property bool showCrypto: Config.options?.sidebar?.widgets?.crypto ?? false
    readonly property bool showWallpaper: Config.options?.sidebar?.widgets?.wallpaper ?? false

    readonly property var visibleWidgets: {
        const order = widgetOrder ?? defaultOrder
        return order.filter(id => {
            switch(id) {
                case "media": return showMedia
                case "week": return showWeek
                case "context": return showContext
                case "note": return showNote
                case "launch": return showLaunch
                case "controls": return showControls
                case "status": return showStatus
                case "crypto": return showCrypto
                case "wallpaper": return showWallpaper
                default: return false
            }
        })
    }

    // Drag state
    property int dragIndex: -1
    property int hoverIndex: -1
    property bool editMode: false
    property real dragStartY: 0
    property real dragCurrentY: 0

    function moveWidget(fromIdx, toIdx) {
        if (fromIdx === toIdx || fromIdx < 0 || toIdx < 0) return
        const fromId = visibleWidgets[fromIdx]
        const toId = visibleWidgets[toIdx]
        
        let newOrder = [...(widgetOrder ?? defaultOrder)]
        const realFrom = newOrder.indexOf(fromId)
        const realTo = newOrder.indexOf(toId)
        
        newOrder.splice(realFrom, 1)
        newOrder.splice(realTo, 0, fromId)
        
        Config.setNestedValue("sidebar.widgets.widgetOrder", newOrder)
    }

    function startDrag(index: int, mouseY: real) {
        dragIndex = index
        hoverIndex = index
        dragStartY = mouseY
        dragCurrentY = mouseY
        editMode = true
    }

    function updateDrag(mouseY: real) {
        if (dragIndex < 0) return
        dragCurrentY = mouseY
        
        // Calculate which widget we're hovering over
        let accY = 0
        for (let i = 0; i < repeater.count; i++) {
            const item = repeater.itemAt(i)
            if (!item?.visible) continue
            const itemCenter = accY + item.height / 2
            if (mouseY < itemCenter) {
                hoverIndex = i
                return
            }
            accY += item.height + column.spacing
        }
        hoverIndex = repeater.count - 1
    }

    function endDrag() {
        if (dragIndex >= 0 && hoverIndex >= 0 && dragIndex !== hoverIndex) {
            moveWidget(dragIndex, hoverIndex)
        }
        dragIndex = -1
        hoverIndex = -1
        editMode = false
        dragStartY = 0
        dragCurrentY = 0
    }

    function cancelDrag() {
        dragIndex = -1
        hoverIndex = -1
        editMode = false
        dragStartY = 0
        dragCurrentY = 0
    }

    // Reset on sidebar close
    Connections {
        target: GlobalStates
        function onSidebarLeftOpenChanged() {
            if (!GlobalStates.sidebarLeftOpen) {
                root.cancelDrag()
            }
        }
    }

    ColumnLayout {
        id: column
        width: parent.width
        spacing: root.widgetSpacing

        Repeater {
            id: repeater
            model: root.visibleWidgets

            delegate: Item {
                id: widgetWrapper
                required property string modelData
                required property int index

                Layout.fillWidth: true
                Layout.preferredHeight: contentLoader.item?.implicitHeight ?? 0
                Layout.leftMargin: needsMargin ? 12 : 0
                Layout.rightMargin: needsMargin ? 12 : 0
                visible: Layout.preferredHeight > 0

                readonly property bool needsMargin: ["context", "note", "media", "crypto", "wallpaper"].includes(modelData)
                readonly property bool isBeingDragged: root.dragIndex === index
                readonly property bool isDropTarget: root.hoverIndex === index && root.dragIndex !== index && root.dragIndex >= 0
                
                // Staggered animation
                readonly property int staggerDelay: 45
                property bool animatedIn: false
                
                onVisibleChanged: if (!visible) animatedIn = false
                
                Timer {
                    id: staggerTimer
                    interval: widgetWrapper.index * widgetWrapper.staggerDelay + 20
                    running: root.animateIn && !widgetWrapper.animatedIn
                    onTriggered: widgetWrapper.animatedIn = true
                }
                
                opacity: animatedIn ? 1 : 0
                scale: animatedIn ? 1 : 0.96
                transformOrigin: Item.Center
                transform: Translate { y: animatedIn ? 0 : 24 }

                Behavior on opacity {
                    enabled: Appearance.animationsEnabled
                    NumberAnimation { 
                        duration: 500
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Appearance.animationCurves.emphasizedDecel
                    }
                }
                Behavior on scale {
                    enabled: Appearance.animationsEnabled && !widgetWrapper.isBeingDragged
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }

                // Drop indicator line
                Rectangle {
                    id: dropIndicator
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: -root.widgetSpacing / 2 - 1
                    height: 3
                    radius: 1.5
                    color: Appearance.colors.colPrimary
                    opacity: widgetWrapper.isDropTarget && root.hoverIndex < root.dragIndex ? 1 : 0
                    visible: opacity > 0
                    
                    Behavior on opacity {
                        enabled: Appearance.animationsEnabled
                        NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                    }
                }
                
                Rectangle {
                    id: dropIndicatorBottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: -root.widgetSpacing / 2 - 1
                    height: 3
                    radius: 1.5
                    color: Appearance.colors.colPrimary
                    opacity: widgetWrapper.isDropTarget && root.hoverIndex > root.dragIndex ? 1 : 0
                    visible: opacity > 0
                    
                    Behavior on opacity {
                        enabled: Appearance.animationsEnabled
                        NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                    }
                }

                Item {
                    id: contentContainer
                    anchors.fill: parent
                    
                    // Elevated shadow when dragging
                    RectangularShadow {
                        anchors.fill: contentLoader
                        radius: contentLoader.item?.radius ?? Appearance.rounding.small
                        opacity: widgetWrapper.isBeingDragged ? 0.5 : 0
                        blur: 24
                        spread: 0.15
                        color: Appearance.colors.colShadow
                        
                        Behavior on opacity {
                            enabled: Appearance.animationsEnabled
                            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                        }
                    }

                    Loader {
                        id: contentLoader
                        width: parent.width
                        
                        // Visual feedback when dragging
                        scale: widgetWrapper.isBeingDragged ? 1.02 : 1
                        opacity: widgetWrapper.isBeingDragged ? 0.95 : 1
                        
                        Behavior on scale {
                            enabled: Appearance.animationsEnabled
                            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                        }
                        Behavior on opacity {
                            enabled: Appearance.animationsEnabled
                            NumberAnimation { duration: 150 }
                        }
                        
                        sourceComponent: {
                            switch(widgetWrapper.modelData) {
                                case "media": return mediaWidget
                                case "week": return weekWidget
                                case "context": return contextWidget
                                case "note": return noteWidget
                                case "launch": return launchWidget
                                case "controls": return controlsWidget
                                case "status": return statusWidget
                                case "crypto": return cryptoWidget
                                case "wallpaper": return wallpaperWidget
                                default: return null
                            }
                        }
                    }
                    
                    // Accent tint when dragging
                    Rectangle {
                        anchors.fill: contentLoader
                        radius: contentLoader.item?.radius ?? Appearance.rounding.small
                        color: Appearance.colors.colPrimary
                        opacity: widgetWrapper.isBeingDragged ? 0.08 : 0
                        
                        Behavior on opacity {
                            enabled: Appearance.animationsEnabled
                            NumberAnimation { duration: 150 }
                        }
                    }
                    
                    // Drag handle overlay (visible on long press)
                    Rectangle {
                        id: dragHandleOverlay
                        anchors.fill: contentLoader
                        radius: contentLoader.item?.radius ?? Appearance.rounding.small
                        color: "transparent"
                        border.width: widgetWrapper.isBeingDragged ? 2 : 0
                        border.color: Appearance.colors.colPrimary
                        
                        Behavior on border.width {
                            enabled: Appearance.animationsEnabled
                            NumberAnimation { duration: 150 }
                        }
                    }
                }

                // Long press to drag - behind content so buttons work
                MouseArea {
                    id: dragArea
                    anchors.fill: parent
                    z: -1  // Behind content - only catches clicks on empty areas
                    acceptedButtons: Qt.LeftButton
                    
                    property bool longPressTriggered: false
                    property real pressY: 0
                    
                    onWheel: (wheel) => wheel.accepted = false

                    onPressed: (mouse) => {
                        longPressTriggered = false
                        pressY = mapToItem(column, mouse.x, mouse.y).y
                        longPressTimer.restart()
                    }
                    
                    onPositionChanged: (mouse) => {
                        if (root.editMode && root.dragIndex === widgetWrapper.index) {
                            const globalY = mapToItem(column, mouse.x, mouse.y).y
                            root.updateDrag(globalY)
                        } else if (!longPressTriggered) {
                            // Cancel long press if moved too much
                            const globalY = mapToItem(column, mouse.x, mouse.y).y
                            if (Math.abs(globalY - pressY) > 10) {
                                longPressTimer.stop()
                            }
                        }
                    }
                    
                    onReleased: {
                        longPressTimer.stop()
                        if (root.editMode) {
                            root.endDrag()
                        }
                        longPressTriggered = false
                    }
                    
                    onCanceled: {
                        longPressTimer.stop()
                        if (root.editMode) {
                            root.cancelDrag()
                        }
                        longPressTriggered = false
                    }
                    
                    Timer {
                        id: longPressTimer
                        interval: 400
                        onTriggered: {
                            dragArea.longPressTriggered = true
                            const globalY = dragArea.mapToItem(column, dragArea.mouseX, dragArea.mouseY).y
                            root.startDrag(widgetWrapper.index, globalY)
                        }
                    }
                }
            }
        }
    }

    Component { id: mediaWidget; MediaPlayerWidget {} }
    Component { id: weekWidget; WeekStrip {} }
    Component { id: contextWidget; ContextCard {} }
    Component { id: noteWidget; QuickNote {} }
    Component { id: launchWidget; QuickLaunch {} }
    Component { id: controlsWidget; ControlsCard {} }
    Component { id: statusWidget; StatusRings {} }
    Component { id: cryptoWidget; CryptoWidget {} }
    Component { id: wallpaperWidget; QuickWallpaper {} }
}
