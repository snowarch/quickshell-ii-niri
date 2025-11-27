pragma ComponentBehavior: Bound
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Item {
    id: root
    required property var panelWindow

    readonly property int workspacesShown: Config.options.overview.rows * Config.options.overview.columns
    readonly property var workspacesForOutput: NiriService.currentOutputWorkspaces
    readonly property var outputWorkspaceNumbers: NiriService.getCurrentOutputWorkspaceNumbers ? NiriService.getCurrentOutputWorkspaceNumbers() : []
    readonly property int currentWorkspaceNumber: NiriService.getCurrentWorkspaceNumber ? NiriService.getCurrentWorkspaceNumber() : 1
    readonly property int currentWorkspaceSlot: {
        if (!outputWorkspaceNumbers || outputWorkspaceNumbers.length === 0)
            return 0;
        const idx = outputWorkspaceNumbers.indexOf(currentWorkspaceNumber);
        return idx >= 0 ? idx : 0;
    }
    readonly property int totalWorkspacesForOutput: workspacesForOutput ? workspacesForOutput.length : 0
    readonly property int firstVisibleWorkspaceSlot: {
        const total = totalWorkspacesForOutput;
        if (total <= 0)
            return 0;
        const cur = currentWorkspaceSlot;
        const slots = workspacesShown <= 0 ? 1 : workspacesShown;
        const half = Math.floor(slots / 2);
        var start = cur - half;
        if (start < 0)
            start = 0;
        if (start + slots > total)
            start = Math.max(0, total - slots);
        return start;
    }

    property real scale: Config.options.overview.scale
    property real clampedPanelWidthRatio: {
        const ov = Config.options.overview;
        const r = ov && ov.maxPanelWidthRatio !== undefined ? ov.maxPanelWidthRatio : 1.0;
        return Math.max(0.1, Math.min(1.0, r));
    }
    property color activeBorderColor: Appearance.colors.colSecondary
    property bool focusAnimEnabled: !Config.options.overview || Config.options.overview.focusAnimationEnable !== false
    property int focusAnimDuration: (Config.options.overview && Config.options.overview.focusAnimationDurationMs !== undefined)
                                    ? Config.options.overview.focusAnimationDurationMs
                                    : 180
    property bool keepOverviewOpenOnWindowClick: !Config.options.overview
                                                 || Config.options.overview.keepOverviewOpenOnWindowClick !== false
    property bool showWorkspaceNumber: !Config.options.overview
                                       || Config.options.overview.showWorkspaceNumbers !== false

    // Wallpaper de fondo a reutilizar en cada workspace
    property bool wallpaperIsVideo: Config.options.background.wallpaperPath.endsWith(".mp4")
                                    || Config.options.background.wallpaperPath.endsWith(".webm")
                                    || Config.options.background.wallpaperPath.endsWith(".mkv")
                                    || Config.options.background.wallpaperPath.endsWith(".avi")
                                    || Config.options.background.wallpaperPath.endsWith(".mov")
    property string wallpaperPath: wallpaperIsVideo ? Config.options.background.thumbnailPath
                                                    : Config.options.background.wallpaperPath

    property string currentOutput: NiriService.currentOutput
    property var outputs: NiriService.outputs

    property var currentOutputInfo: (!currentOutput && Object.keys(outputs).length > 0)
                                    ? outputs[Object.keys(outputs)[0]]
                                    : outputs[currentOutput]

    property int logicalWidth: currentOutputInfo && currentOutputInfo.logical ? currentOutputInfo.logical.width : 1920
    property int logicalHeight: currentOutputInfo && currentOutputInfo.logical ? currentOutputInfo.logical.height : 1080
    property real logicalScale: currentOutputInfo && currentOutputInfo.logical && currentOutputInfo.logical.scale !== undefined
                                 ? currentOutputInfo.logical.scale : 1.0

    property real baseWorkspaceWidth: (logicalWidth * root.scale) / logicalScale
    property real baseWorkspaceHeight: (logicalHeight * root.scale) / logicalScale
    property real workspaceImplicitWidth: {
        const cols = Config.options.overview.columns;
        const spacing = root.workspaceSpacing;
        const totalBase = baseWorkspaceWidth * cols + spacing * Math.max(0, cols - 1);
        const maxWidth = (panelWindow ? panelWindow.width : (logicalWidth / logicalScale)) * clampedPanelWidthRatio;
        if (cols <= 0 || totalBase <= maxWidth)
            return baseWorkspaceWidth;
        return (maxWidth - spacing * Math.max(0, cols - 1)) / cols;
    }
    property real workspaceImplicitHeight: {
        const aspect = baseWorkspaceHeight <= 0 || baseWorkspaceWidth <= 0 ? 1 : baseWorkspaceHeight / baseWorkspaceWidth;
        return workspaceImplicitWidth * aspect;
    }

    property real workspaceNumberMargin: 80
    property real workspaceNumberSize: 250
    property int workspaceZ: 0
    property int windowZ: 1
    property int windowDraggingZ: 99999
    property real workspaceSpacing: Config.options.overview.workspaceSpacing

    // Context menu
    property bool contextVisible: false
    property var contextWindowData: null
    property real contextMenuX: 0
    property real contextMenuY: 0

    // Contador para suavizar el scroll de cambio de workspace
    property int wheelStepCounter: 0
    property int wheelStepsRequired: (Config.options.overview && Config.options.overview.scrollWorkspaceSteps !== undefined)
                                     ? Math.max(1, Config.options.overview.scrollWorkspaceSteps)
                                     : 2

    property int draggingFromWorkspace: -1    // Niri workspace idx
    property int draggingTargetWorkspace: -1  // Niri workspace idx

    implicitWidth: overviewBackground.implicitWidth + Appearance.sizes.elevationMargin * 2
    implicitHeight: overviewBackground.implicitHeight + Appearance.sizes.elevationMargin * 2

    Timer {
        id: dragCleanupTimer
        interval: 100
        onTriggered: {
            root.draggingFromWorkspace = -1
            root.draggingTargetWorkspace = -1
        }
    }

    function openWindowContext(windowItem, mouseX, mouseY) {
        if (!windowItem || !windowItem.windowData) return
        contextWindowData = windowItem.windowData
        const pos = windowItem.mapToItem(windowSpace, mouseX, mouseY)
        contextMenuX = pos.x
        contextMenuY = pos.y
        contextVisible = true
    }

    function closeWindowContext() {
        contextVisible = false
        contextWindowData = null
    }

    Connections {
        target: GlobalStates
        function onOverviewOpenChanged() {
            if (!GlobalStates.overviewOpen) {
                root.closeWindowContext()
            }
        }
    }

    // Scroll del mouse para subir/bajar de workspace en Niri
    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: (event) => {
            const deltaY = event.angleDelta.y
            if (deltaY === 0)
                return

            // Requerir varios pasos de rueda antes de cambiar de workspace
            root.wheelStepCounter += 1
            if (root.wheelStepCounter < root.wheelStepsRequired)
                return
            root.wheelStepCounter = 0

            const direction = deltaY < 0 ? 1 : -1

            const wsList = root.outputWorkspaceNumbers
            if (!wsList || wsList.length < 2)
                return

            const currentNumber = root.currentWorkspaceNumber
            const currentIndex = wsList.indexOf(currentNumber)
            const validIndex = currentIndex === -1 ? 0 : currentIndex
            const nextIndex = direction > 0
                    ? Math.min(validIndex + 1, wsList.length - 1)
                    : Math.max(validIndex - 1, 0)
            if (nextIndex === validIndex)
                return

            const nextNumber = wsList[nextIndex]
            // wsList already contains Niri idx (1-based) for this output.
            NiriService.switchToWorkspace(nextNumber)
        }
    }

    StyledRectangularShadow {
        target: overviewBackground
    }

    Rectangle {
        id: overviewBackground
        property real padding: 10
        anchors.fill: parent
        anchors.margins: Appearance.sizes.elevationMargin

        implicitWidth: workspaceColumnLayout.implicitWidth + padding * 2
        implicitHeight: workspaceColumnLayout.implicitHeight + padding * 2
        radius: Appearance.rounding.large + padding
        clip: false
        color: Appearance.colors.colBackgroundSurfaceContainer

        Column {
            id: workspaceColumnLayout

            z: root.workspaceZ
            anchors.centerIn: parent
            spacing: workspaceSpacing

            Repeater {
                model: Config.options.overview.rows
                delegate: Row {
                    id: row
                    required property int index
                    spacing: workspaceSpacing

                    Repeater {
                        model: Config.options.overview.columns
                        Rectangle {
                            id: workspace
                            required property int index
                            property int colIndex: index
                            property int workspaceIndex: root.firstVisibleWorkspaceSlot + row.index * Config.options.overview.columns + colIndex

                            property var workspaceObj: {
                                const wsList = root.workspacesForOutput
                                if (!wsList || wsList.length === 0)
                                    return null
                                if (workspaceIndex < 0 || workspaceIndex >= wsList.length)
                                    return null
                                return wsList[workspaceIndex]
                            }

                            // Número mostrado en el recuadro (1..N dentro del output actual)
                            property int workspaceValue: workspaceIndex + 1

                            property bool workspaceExists: workspaceObj !== null
                            property bool isActive: workspaceObj && workspaceObj.is_active
                            property color defaultWorkspaceColor: workspaceExists
                                ? Appearance.colors.colBackgroundSurfaceContainer
                                : ColorUtils.transparentize(Appearance.colors.colBackgroundSurfaceContainer, 0.3)
                            property color hoveredWorkspaceColor: ColorUtils.mix(defaultWorkspaceColor, Appearance.colors.colLayer1Hover, 0.1)
                            property color hoveredBorderColor: Appearance.colors.colLayer2Hover
                            property bool hoveredWhileDragging: false

                            implicitWidth: root.workspaceImplicitWidth
                            implicitHeight: root.workspaceImplicitHeight
                            color: "transparent"
                            clip: true

                            property bool workspaceAtLeft: colIndex === 0
                            property bool workspaceAtRight: colIndex === Config.options.overview.columns - 1
                            property bool workspaceAtTop: row.index === 0
                            property bool workspaceAtBottom: row.index === Config.options.overview.rows - 1
                            property real largeWorkspaceRadius: Appearance.rounding.large
                            property real smallWorkspaceRadius: Appearance.rounding.verysmall
                            topLeftRadius: (workspaceAtLeft && workspaceAtTop) ? largeWorkspaceRadius : smallWorkspaceRadius
                            topRightRadius: (workspaceAtRight && workspaceAtTop) ? largeWorkspaceRadius : smallWorkspaceRadius
                            bottomLeftRadius: (workspaceAtLeft && workspaceAtBottom) ? largeWorkspaceRadius : smallWorkspaceRadius
                            bottomRightRadius: (workspaceAtRight && workspaceAtBottom) ? largeWorkspaceRadius : smallWorkspaceRadius
                            border.width: 0
                            border.color: "transparent"

                            // Wallpaper de fondo recortado al workspace, con blur + dim para mejorar legibilidad
                            Image {
                                id: workspaceWallpaperSource
                                anchors.fill: parent
                                source: root.wallpaperPath
                                asynchronous: true
                                fillMode: Image.PreserveAspectCrop
                                visible: false
                            }

                            FastBlur {
                                anchors.fill: parent
                                source: workspaceWallpaperSource
                                radius: {
                                    const ov = Config.options.overview
                                    if (!ov || ov.backgroundBlurEnable === false || Config.options.performance.lowPower)
                                        return 0
                                    const r = (ov.backgroundBlurRadius !== undefined) ? ov.backgroundBlurRadius : 22
                                    return r * root.scale
                                }
                                transparentBorder: true
                                layer.enabled: true
                                layer.effect: OpacityMask {
                                    maskSource: Rectangle {
                                        width: workspace.width
                                        height: workspace.height
                                        topLeftRadius: workspace.topLeftRadius
                                        topRightRadius: workspace.topRightRadius
                                        bottomLeftRadius: workspace.bottomLeftRadius
                                        bottomRightRadius: workspace.bottomRightRadius
                                    }
                                }
                            }

                            // Dim overlay encima del wallpaper (misma forma que el workspace)
                            Rectangle {
                                anchors.fill: parent
                                color: {
                                    const ov = Config.options.overview
                                    const base = (ov && ov.backgroundDim !== undefined) ? ov.backgroundDim : 35
                                    const delta = workspace.isActive ? -10 : 0 // activo un poco menos dim
                                    const v = base + delta
                                    const clamped = Math.max(0, Math.min(100, v))
                                    const a = clamped / 100
                                    return Qt.rgba(0, 0, 0, a)
                                }
                                topLeftRadius: workspace.topLeftRadius
                                topRightRadius: workspace.topRightRadius
                                bottomLeftRadius: workspace.bottomLeftRadius
                                bottomRightRadius: workspace.bottomRightRadius
                                border.width: 0
                            }

                            // Overlay de hover/drag (respeta esquinas redondeadas)
                            Rectangle {
                                anchors.fill: parent
                                color: (workspaceArea.containsMouse || hoveredWhileDragging)
                                       ? hoveredWorkspaceColor
                                       : "transparent"
                                opacity: (workspaceArea.containsMouse || hoveredWhileDragging) ? 0.25 : 0.0
                                topLeftRadius: workspace.topLeftRadius
                                topRightRadius: workspace.topRightRadius
                                bottomLeftRadius: workspace.bottomLeftRadius
                                bottomRightRadius: workspace.bottomRightRadius
                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 140
                                        easing.type: Easing.InOutQuad
                                    }
                                }
                            }

                            // Border Overlay
                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                border.width: 2
                                // Usar este borde sólo para hover/drag.
                                // El estado activo se dibuja con focusedWorkspaceIndicator para evitar solapamientos.
                                border.color: hoveredWhileDragging ? hoveredBorderColor : "transparent"
                                topLeftRadius: workspace.topLeftRadius
                                topRightRadius: workspace.topRightRadius
                                bottomLeftRadius: workspace.bottomLeftRadius
                                bottomRightRadius: workspace.bottomRightRadius
                            }

                            StyledText {
                                anchors.centerIn: parent
                                text: workspace.workspaceValue
                                font {
                                    pixelSize: root.workspaceNumberSize * root.scale
                                    weight: Font.DemiBold
                                    family: Appearance.font.family.expressive
                                }
                                color: ColorUtils.transparentize(Appearance.colors.colOnLayer1, 0.8)
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                visible: root.showWorkspaceNumber
                            }

                            MouseArea {
                                id: workspaceArea
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton
                                onPressed: {
                                    if (root.draggingTargetWorkspace === -1 && workspace.workspaceObj) {
                                        GlobalStates.overviewOpen = false
                                        // Usar idx real de Niri para FocusWorkspace
                                        NiriService.switchToWorkspace(workspace.workspaceObj.idx)
                                    }
                                }
                            }

                            DropArea {
                                anchors.fill: parent
                                onEntered: {
                                    root.draggingTargetWorkspace = workspace.workspaceObj ? workspace.workspaceObj.idx : -1
                                    if (root.draggingFromWorkspace === root.draggingTargetWorkspace)
                                        return
                                    hoveredWhileDragging = true
                                }
                                onExited: {
                                    hoveredWhileDragging = false
                                    if (workspace.workspaceObj && root.draggingTargetWorkspace === workspace.workspaceObj.idx)
                                        root.draggingTargetWorkspace = -1
                                }
                            }
                        }
                    }
                }
            }
        }

        Item {
            id: windowSpace
            anchors.centerIn: parent
            implicitWidth: workspaceColumnLayout.implicitWidth
            implicitHeight: workspaceColumnLayout.implicitHeight

            Repeater {
                model: ScriptModel {
                    values: {
                        if (!GlobalStates.overviewOpen)
                            return []
                        
                        const wins = NiriService.windows || []
                        const wsList = root.workspacesForOutput || []
                        if (wsList.length === 0 || wins.length === 0)
                            return []

                        const workspaceSlotById = {}
                        for (let i = 0; i < wsList.length; ++i) {
                            const ws = wsList[i]
                            if (ws)
                                workspaceSlotById[ws.id] = i
                        }

                        const startSlot = root.firstVisibleWorkspaceSlot
                        const endSlot = Math.min(startSlot + root.workspacesShown - 1, wsList.length - 1)

                        const collected = []
                        const counters = {}
                        const maxPerWorkspace = {}

                        for (let i = 0; i < wins.length; ++i) {
                            const w = wins[i]
                            const slot = workspaceSlotById[w.workspace_id]
                            if (slot === undefined)
                                continue
                            if (slot < startSlot || slot > endSlot)
                                continue

                            const wsNumber = slot + 1

                            const pos = w.layout && w.layout.pos_in_scrolling_layout ? w.layout.pos_in_scrolling_layout : [1, 1]
                            const col = pos.length >= 1 && pos[0] ? pos[0] : 1
                            const row = pos.length >= 2 && pos[1] ? pos[1] : 1

                            const keyWs = wsNumber.toString()
                            const info = maxPerWorkspace[keyWs] || { maxCol: 1, maxRow: 1 }
                            info.maxCol = Math.max(info.maxCol, col)
                            info.maxRow = Math.max(info.maxRow, row)
                            maxPerWorkspace[keyWs] = info

                            collected.push({ window: w, workspaceNumber: wsNumber, workspaceSlot: slot })
                        }

                        const result = []
                        for (let i = 0; i < collected.length; ++i) {
                            const entry = collected[i]
                            const wsKey = entry.workspaceNumber.toString()
                            const key = wsKey
                            const count = counters[key] || 0
                            counters[key] = count + 1

                            const gridInfo = maxPerWorkspace[wsKey] || { maxCol: 1, maxRow: 1 }

                            result.push({
                                "window": entry.window,
                                "workspaceNumber": entry.workspaceNumber,
                                "workspaceSlot": entry.workspaceSlot,
                                "indexInWorkspace": count,
                                "maxCol": gridInfo.maxCol,
                                "maxRow": gridInfo.maxRow
                            })
                        }

                        return result
                    }
                }

                delegate: Item {
                    id: windowItem
                    required property var modelData

                    readonly property var windowData: modelData.window
                    readonly property int workspaceNumber: modelData.workspaceNumber
                    readonly property int workspaceSlot: modelData.workspaceSlot
                    readonly property int indexInWorkspace: modelData.indexInWorkspace

                    readonly property int workspaceMaxCol: modelData.maxCol || 1
                    readonly property int workspaceMaxRow: modelData.maxRow || 1

                    readonly property int workspaceIndex: workspaceSlot - root.firstVisibleWorkspaceSlot
                    readonly property int workspaceColIndex: workspaceIndex % Config.options.overview.columns
                    readonly property int workspaceRowIndex: Math.floor(workspaceIndex / Config.options.overview.columns)

                    readonly property real xOffset: (root.workspaceImplicitWidth + workspaceSpacing) * workspaceColIndex
                    readonly property real yOffset: (root.workspaceImplicitHeight + workspaceSpacing) * workspaceRowIndex

                    readonly property var layoutPos: (windowData.layout && windowData.layout.pos_in_scrolling_layout) ? windowData.layout.pos_in_scrolling_layout : [1, 1]
                    readonly property int layoutCol: layoutPos.length >= 1 && layoutPos[0] ? layoutPos[0] : 1
                    readonly property int layoutRow: layoutPos.length >= 2 && layoutPos[1] ? layoutPos[1] : 1

                    readonly property real tileWidth: root.workspaceImplicitWidth / workspaceMaxCol
                    readonly property real tileHeight: root.workspaceImplicitHeight / workspaceMaxRow
                    readonly property real tileMargin: (Config.options.overview.windowTileMargin !== undefined ? Config.options.overview.windowTileMargin : 6) * root.scale

                    readonly property real baseX: xOffset + (layoutCol - 1) * tileWidth
                    readonly property real baseY: yOffset + (layoutRow - 1) * tileHeight

                    x: baseX + tileMargin
                    y: baseY + tileMargin
                    width: Math.max(10, tileWidth - 2 * tileMargin)
                    height: Math.max(10, tileHeight - 2 * tileMargin)
                    z: root.windowZ

                    Behavior on x {
                        enabled: !windowItem.Drag.active
                        NumberAnimation {
                            duration: 140
                            easing.type: Easing.InOutQuad
                        }
                    }
                    Behavior on y {
                        enabled: !windowItem.Drag.active
                        NumberAnimation {
                            duration: 140
                            easing.type: Easing.InOutQuad
                        }
                    }

                    readonly property var toplevel: {
                        const tlMap = ToplevelManager.toplevels
                        if (!tlMap || !tlMap.values)
                            return null
                        const arr = Array.from(tlMap.values)
                        for (let i = 0; i < arr.length; ++i) {
                            const tl = arr[i]
                            if (!tl)
                                continue
                            const match = NiriService.findNiriWindow(tl)
                            if (match && match.niriWindow && match.niriWindow.id === windowData.id)
                                return tl
                        }
                        return null
                    }

                    property bool hovered: false
                    property bool pressed: false
                    readonly property bool isFocused: !!windowData && (windowData.is_focused
                                                                         || (NiriService.activeWindow
                                                                             && NiriService.activeWindow.id === windowData.id))

                    Rectangle {
                        anchors.fill: parent
                        radius: Appearance.rounding.small
                        color: "transparent"
                        border.width: windowItem.isFocused ? 2 : 0
                        border.color: windowItem.isFocused ? Appearance.colors.colLayer2Active : "transparent"

                        // Fondo de hover/pressed (sin contenido de ventana)
                        Rectangle {
                            anchors.fill: parent
                            // When focused, inset slightly so hover/press highlight doesn't cover the focus border
                            anchors.margins: windowItem.isFocused ? 2 : 0
                            radius: Appearance.rounding.small
                            color: windowItem.pressed
                                   ? ColorUtils.transparentize(Appearance.colors.colLayer2Active, 0.45)
                                   : windowItem.hovered
                                       ? ColorUtils.transparentize(Appearance.colors.colLayer2Hover, 0.55)
                                       : "transparent"
                            border.color: ColorUtils.transparentize(Appearance.m3colors.m3outline, 0.7)
                            border.width: windowItem.hovered || windowItem.pressed ? 1 : 0
                        }

                        // Icono de la app centrado en el tile
                        Image {
                            id: windowIcon
                            anchors.centerIn: parent
                            width: {
                                var size = Math.min(parent.width, parent.height) * 0.35;
                                const ov = Config.options.overview;
                                const min = ov && ov.iconMinSize !== undefined ? ov.iconMinSize : 0;
                                const max = ov && ov.iconMaxSize !== undefined ? ov.iconMaxSize : 0;
                                if (min > 0) size = Math.max(size, min);
                                if (max > 0) size = Math.min(size, max);
                                return size;
                            }
                            height: width
                            source: Quickshell.iconPath(AppSearch.guessIcon(windowData.app_id || windowData.appId || ""), "image-missing")
                            asynchronous: true
                            fillMode: Image.PreserveAspectFit
                            scale: windowItem.hovered ? 1.08 : 1.0
                            Behavior on scale {
                                NumberAnimation {
                                    duration: 120
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        }

                        MouseArea {
                            id: windowMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            drag.target: windowItem
                            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                            property real pressX: 0
                            property real pressY: 0
                            onEntered: windowItem.hovered = true
                            onExited: windowItem.hovered = false
                            onPressed: (mouse) => {
                                if (!windowData)
                                    return
                                pressX = mouse.x
                                pressY = mouse.y
                                if (mouse.button === Qt.RightButton) {
                                    // Click derecho: no iniciar drag, sólo registrar posición
                                    return
                                }
                                windowItem.pressed = true
                                const ws = NiriService.workspaces[windowData.workspace_id]
                                root.draggingFromWorkspace = ws ? ws.idx : -1
                                windowItem.Drag.active = true
                                windowItem.Drag.source = windowItem
                                windowItem.Drag.hotSpot.x = mouse.x
                                windowItem.Drag.hotSpot.y = mouse.y
                            }
                            onReleased: (event) => {
                                const dx = Math.abs(event.x - pressX)
                                const dy = Math.abs(event.y - pressY)
                                const isClick = dx <= 4 && dy <= 4

                                if (!windowData) return

                                if (event.button === Qt.RightButton) {
                                    if (isClick) root.openWindowContext(windowItem, event.x, event.y)
                                    windowItem.pressed = false
                                    windowItem.Drag.active = false
                                    root.draggingFromWorkspace = -1
                                    root.draggingTargetWorkspace = -1
                                    return
                                }

                                const fromWorkspace = root.draggingFromWorkspace
                                const targetWorkspace = root.draggingTargetWorkspace
                                windowItem.pressed = false
                                windowItem.Drag.active = false
                                dragCleanupTimer.restart()

                                const movedToOtherWorkspace = (targetWorkspace !== -1 && targetWorkspace !== fromWorkspace)

                                if (movedToOtherWorkspace) {
                                    // Drop válido en otro workspace: mover ventana allí
                                    NiriService.moveWindowToWorkspace(windowData.id, targetWorkspace, true)
                                } else {
                                    // Drop fuera de cualquier workspace diferente o mismo workspace: efecto imán
                                    windowItem.x = Qt.binding(function() { return windowItem.baseX + windowItem.tileMargin })
                                    windowItem.y = Qt.binding(function() { return windowItem.baseY + windowItem.tileMargin })

                                    // Comportamiento de click (sin drag real)
                                    if (isClick && event.button === Qt.LeftButton) {
                                        NiriService.focusWindow(windowData.id)
                                        if (!root.keepOverviewOpenOnWindowClick) {
                                            GlobalStates.overviewOpen = false
                                        }
                                    } else if (isClick && event.button === Qt.MiddleButton) {
                                        NiriService.closeWindow(windowData.id)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            MouseArea {
                anchors.fill: parent
                visible: root.contextVisible
                z: root.windowZ + 50
                onClicked: root.closeWindowContext()
            }

            Rectangle {
                visible: root.contextVisible
                x: root.contextMenuX
                y: root.contextMenuY
                z: root.windowZ + 51
                width: col.implicitWidth
                height: col.implicitHeight
                radius: Appearance.rounding.normal
                color: Appearance.colors.colLayer4
                border.width: 1
                border.color: ColorUtils.transparentize(Appearance.m3colors.m3outline, 0.5)

                Column {
                    id: col
                    spacing: 0
                    topPadding: 4
                    bottomPadding: 4
                    leftPadding: 4
                    rightPadding: 4

                    RippleButton {
                        implicitWidth: contentItem.implicitWidth + 24
                        height: 32
                        buttonRadius: Appearance.rounding.small
                        buttonText: Translation.tr("Focus")
                        colBackgroundHover: Appearance.colors.colLayer4Hover
                        onClicked: {
                            if (!root.contextWindowData) return
                            NiriService.focusWindow(root.contextWindowData.id)
                            if (!root.keepOverviewOpenOnWindowClick) GlobalStates.overviewOpen = false
                            root.closeWindowContext()
                        }
                    }

                    RippleButton {
                        implicitWidth: contentItem.implicitWidth + 24
                        height: 32
                        buttonRadius: Appearance.rounding.small
                        buttonText: Translation.tr("Close")
                        colBackgroundHover: Appearance.colors.colLayer4Hover
                        onClicked: {
                            if (!root.contextWindowData) return
                            NiriService.closeWindow(root.contextWindowData.id)
                            root.closeWindowContext()
                        }
                    }
                }
            }

            Rectangle {
                id: focusedWorkspaceIndicator
                readonly property int activeSlot: root.currentWorkspaceSlot
                readonly property int activeSlotInGroup: activeSlot - root.firstVisibleWorkspaceSlot
                readonly property int rowIndex: Math.floor(activeSlotInGroup / Config.options.overview.columns)
                readonly property int colIndex: activeSlotInGroup % Config.options.overview.columns

                x: (root.workspaceImplicitWidth + workspaceSpacing) * colIndex
                y: (root.workspaceImplicitHeight + workspaceSpacing) * rowIndex
                z: root.windowZ
                width: root.workspaceImplicitWidth
                height: root.workspaceImplicitHeight
                color: "transparent"

                property bool workspaceAtLeft: colIndex === 0
                property bool workspaceAtRight: colIndex === Config.options.overview.columns - 1
                property bool workspaceAtTop: rowIndex === 0
                property bool workspaceAtBottom: rowIndex === Config.options.overview.rows - 1
                property real largeWorkspaceRadius: Appearance.rounding.large
                property real smallWorkspaceRadius: Appearance.rounding.verysmall
                topLeftRadius: (workspaceAtLeft && workspaceAtTop) ? largeWorkspaceRadius : smallWorkspaceRadius
                topRightRadius: (workspaceAtRight && workspaceAtTop) ? largeWorkspaceRadius : smallWorkspaceRadius
                bottomLeftRadius: (workspaceAtLeft && workspaceAtBottom) ? largeWorkspaceRadius : smallWorkspaceRadius
                bottomRightRadius: (workspaceAtLeft && workspaceAtBottom) ? largeWorkspaceRadius : smallWorkspaceRadius

                border.width: 2
                border.color: root.activeBorderColor

                Behavior on x {
                    enabled: root.focusAnimEnabled
                    animation: NumberAnimation {
                        duration: root.focusAnimDuration
                        easing.type: Appearance.animation.elementMoveFast.type
                        easing.bezierCurve: Appearance.animationCurves.emphasizedLastHalf
                    }
                }
                Behavior on y {
                    enabled: root.focusAnimEnabled
                    animation: NumberAnimation {
                        duration: root.focusAnimDuration
                        easing.type: Appearance.animation.elementMoveFast.type
                        easing.bezierCurve: Appearance.animationCurves.emphasizedLastHalf
                    }
                }
                Behavior on topLeftRadius {
                    enabled: root.focusAnimEnabled
                    animation: NumberAnimation {
                        duration: root.focusAnimDuration
                        easing.type: Appearance.animation.elementMoveEnter.type
                        easing.bezierCurve: Appearance.animationCurves.emphasizedLastHalf
                    }
                }
                Behavior on topRightRadius {
                    enabled: root.focusAnimEnabled
                    animation: NumberAnimation {
                        duration: root.focusAnimDuration
                        easing.type: Appearance.animation.elementMoveEnter.type
                        easing.bezierCurve: Appearance.animationCurves.emphasizedLastHalf
                    }
                }
                Behavior on bottomLeftRadius {
                    enabled: root.focusAnimEnabled
                    animation: NumberAnimation {
                        duration: root.focusAnimDuration
                        easing.type: Appearance.animation.elementMoveEnter.type
                        easing.bezierCurve: Appearance.animationCurves.emphasizedLastHalf
                    }
                }
                Behavior on bottomRightRadius {
                    enabled: root.focusAnimEnabled
                    animation: NumberAnimation {
                        duration: root.focusAnimDuration
                        easing.type: Appearance.animation.elementMoveEnter.type
                        easing.bezierCurve: Appearance.animationCurves.emphasizedLastHalf
                    }
                }
            }
        }
    }
}
