pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions

/**
 * WindowPreviewService - Window preview caching for TaskView
 * 
 * Strategy:
 * - Capture previews ONLY when TaskView opens
 * - Cache in ~/.cache/ii-niri/window-previews/
 * - Only capture windows that don't have a recent preview
 * - Clean up on window close
 */
Singleton {
    id: root

    readonly property string previewDir: FileUtils.trimFileProtocol(Directories.genericCache) + "/ii-niri/window-previews"
    
    // Map of windowId -> { path, timestamp }
    property var previewCache: ({})
    
    property bool initialized: false
    property bool capturing: false
    property bool _previewDirReady: false
    
    // Preview validity duration (5 minutes)
    readonly property int previewValidityMs: 300000
    
    signal captureComplete()
    signal previewUpdated(int windowId)

    Component.onCompleted: {
        // Lazy init: only when TaskView actually requests previews.
    }
    
    function initialize(): void {
        if (initialized) return
        initialized = true
        root._previewDirReady = false
        ensureDirProcess.running = true
    }

    function _toEpochMs(value): int {
        if (value === null || value === undefined)
            return 0
        if (typeof value === "number")
            return Math.floor(value)
        try {
            if (value.getTime)
                return value.getTime()
        } catch (e) {}
        try {
            const d = new Date(value)
            const t = d.getTime()
            return isNaN(t) ? 0 : t
        } catch (e) {
            return 0
        }
    }

    function _rebuildCacheFromDisk(): void {
        if (!root.initialized)
            return
        if (previewFolderModel.status !== FolderListModel.Ready)
            return

        const newCache = ({})

        for (let i = 0; i < previewFolderModel.count; i++) {
            const filename = String(previewFolderModel.get(i, "fileName") || "")
            const match = filename.match(/^window-(\d+)\.png$/)
            if (!match)
                continue

            const id = parseInt(match[1])
            const filePath = previewFolderModel.get(i, "filePath") || FileUtils.trimFileProtocol(previewFolderModel.get(i, "fileURL"))
            const ts = root._toEpochMs(previewFolderModel.get(i, "fileModified"))

            if (!filePath)
                continue

            newCache[id] = {
                path: filePath,
                timestamp: ts
            }
        }

        root.previewCache = newCache
        console.log("[WindowPreviewService] Loaded", Object.keys(root.previewCache).length, "cached previews")
        root.cleanupOrphans()
    }

    Timer {
        id: rebuildDebounce
        interval: 50
        repeat: false
        onTriggered: root._rebuildCacheFromDisk()
    }

    FolderListModel {
        id: previewFolderModel
        folder: (root.initialized && root._previewDirReady) ? Qt.resolvedUrl("file://" + root.previewDir) : ""
        nameFilters: ["window-*.png"]
        showDirs: false
        showDotAndDotDot: false
        sortField: FolderListModel.Name
        sortReversed: false

        onStatusChanged: {
            if (status === FolderListModel.Ready)
                rebuildDebounce.restart()
        }
        onCountChanged: rebuildDebounce.restart()
    }

    Process {
        id: ensureDirProcess
        command: ["/usr/bin/mkdir", "-p", root.previewDir]
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                console.warn("[WindowPreviewService] Failed to create preview dir", root.previewDir, "exit", exitCode, exitStatus)
                return
            }
            root._previewDirReady = true
            rebuildDebounce.restart()
        }
    }
    
    // Remove previews for windows that no longer exist
    function cleanupOrphans(): void {
        const windows = NiriService.windows ?? []
        const windowIds = new Set(windows.map(w => w.id))
        
        const toDelete = []
        for (const id in previewCache) {
            if (!windowIds.has(parseInt(id))) {
                toDelete.push(id)
            }
        }
        
        if (toDelete.length > 0) {
            for (const id of toDelete) {
                delete previewCache[id]
            }
            previewCache = Object.assign({}, previewCache)
            
            // Delete files
            const cmd = ["/usr/bin/rm", "-f"]
            for (const id of toDelete) {
                cmd.push(root.previewDir + "/window-" + id + ".png")
            }
            Quickshell.execDetached(cmd)
        }
    }

    // Track if we've done initial capture this session
    property bool initialCapturesDone: false
    
    // Called when TaskView opens - capture windows that need it
    function captureForTaskView(): void {
        if (capturing) return

        if (!initialized) initialize()
        
        const windows = NiriService.windows ?? []
        if (windows.length === 0) return
        
        const now = Date.now()
        const idsToCapture = []
        
        for (const win of windows) {
            const cached = previewCache[win.id]
            // Capture if: no preview, preview is stale, or first open this session
            const needsCapture = !cached || 
                                 (now - cached.timestamp) > previewValidityMs ||
                                 !initialCapturesDone
            if (needsCapture) {
                idsToCapture.push(win.id)
            }
        }
        
        if (idsToCapture.length === 0) {
            captureComplete()
            return
        }
        
        console.log("[WindowPreviewService] Capturing", idsToCapture.length, "windows")
        capturing = true
        initialCapturesDone = true
        
        // Build command with IDs
        const cmd = ["/usr/bin/fish", Quickshell.shellPath("scripts/capture-windows.fish")]
        for (const id of idsToCapture) {
            cmd.push(id.toString())
        }
        
        captureProcess.idsToCapture = idsToCapture
        captureProcess.command = cmd
        captureProcess.running = true
    }
    
    // Capture ALL windows (force refresh)
    function captureAllWindows(): void {
        if (capturing) return

        if (!initialized) initialize()
        
        const windows = NiriService.windows ?? []
        if (windows.length === 0) return
        
        console.log("[WindowPreviewService] Force capturing all", windows.length, "windows")
        capturing = true
        
        const ids = windows.map(w => w.id)
        captureProcess.idsToCapture = ids
        captureProcess.command = [
            "/usr/bin/fish",
            Quickshell.shellPath("scripts/capture-windows.fish"),
            "--all"
        ]
        captureProcess.running = true
    }
    
    Process {
        id: captureProcess
        property var idsToCapture: []

        stdout: SplitParser {
            onRead: (line) => console.log("[WindowPreviewService:capture]", line)
        }
        stderr: SplitParser {
            onRead: (line) => console.log("[WindowPreviewService:capture][err]", line)
        }
        
        onExited: (exitCode, exitStatus) => {
            root.capturing = false

            if (exitCode !== 0) {
                console.log("[WindowPreviewService] capture process failed", exitCode, exitStatus)
            } else {
                const timestamp = Date.now()
                for (const id of idsToCapture) {
                    const path = root.previewDir + "/window-" + id + ".png"
                    root.previewCache[id] = {
                        path: path,
                        timestamp: timestamp
                    }
                    root.previewUpdated(id)
                }
                root.previewCache = Object.assign({}, root.previewCache)
            }
            
            idsToCapture = []
            root.captureComplete()
        }
    }
    
    // Clean up when window closes
    Connections {
        target: NiriService
        
        function onWindowsChanged(): void {
            if (!root.initialized) return
            cleanupTimer.restart()
        }
    }
    
    Timer {
        id: cleanupTimer
        interval: 1000
        onTriggered: root.cleanupOrphans()
    }
    
    // Public API
    function getPreviewUrl(windowId: int): string {
        const cached = previewCache[windowId]
        if (!cached) return ""
        return "file://" + cached.path + "?" + cached.timestamp
    }
    
    function hasPreview(windowId: int): bool {
        return previewCache[windowId] !== undefined
    }
    
    function clearPreviews(): void {
        Quickshell.execDetached(["/usr/bin/rm", "-rf", previewDir])
        previewCache = {}
    }
}
