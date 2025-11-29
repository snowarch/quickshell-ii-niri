import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Button {
    id: root
    z: showActions ? 100 : 0  // Bring to front when menu is open
    property var imageData
    property var rowHeight
    property bool manualDownload: false
    property string previewDownloadPath
    property string downloadPath
    property string nsfwPath
    property string fileName: decodeURIComponent((imageData.file_url).substring((imageData.file_url).lastIndexOf('/') + 1))
    property string filePath: `${root.previewDownloadPath}/${root.fileName}`
    property int maxTagStringLineLength: 50
    property real imageRadius: Appearance.rounding.small
    property bool showBackground: true  // When false, no background rectangle behind image

    // Allow consumers (e.g. Wallhaven) to opt-out of hover tooltips
    property bool enableTooltip: true

    property bool showActions: GlobalStates.activeBooruImageMenu === root
    
    function openMenu() {
        GlobalStates.activeBooruImageMenu = root
    }
    
    function closeMenu() {
        if (GlobalStates.activeBooruImageMenu === root) {
            GlobalStates.activeBooruImageMenu = null
        }
    }
    
    function toggleMenu() {
        if (showActions) {
            closeMenu()
        } else {
            openMenu()
        }
    }
    
    Process {
        id: downloadProcess
        running: false
        command: ["bash", "-c", `mkdir -p '${root.previewDownloadPath}' && [ -f ${root.filePath} ] || curl -sSL '${root.imageData.preview_url ?? root.imageData.sample_url}' -o '${root.filePath}'`]
        onExited: (exitCode, exitStatus) => {
            imageObject.source = `${previewDownloadPath}/${root.fileName}`
        }
    }

    Component.onCompleted: {
        if (root.manualDownload) {
            downloadProcess.running = true
        }
    }

    StyledToolTip {
        visible: root.enableTooltip && root.imageData && root.imageData.tags && root.imageData.tags.length > 0
        text: `${StringUtils.wordWrap(root.imageData.tags, root.maxTagStringLineLength)}`
    }

    padding: 0
    implicitWidth: root.rowHeight * modelData.aspect_ratio
    implicitHeight: root.rowHeight

    background: Rectangle {
        implicitWidth: root.rowHeight * modelData.aspect_ratio
        implicitHeight: root.rowHeight
        radius: imageRadius
        color: root.showBackground ? Appearance.colors.colLayer2 : "transparent"
    }

    contentItem: Item {
        anchors.fill: parent

        StyledImage {
            id: imageObject
            anchors.fill: parent
            width: root.rowHeight * modelData.aspect_ratio
            height: root.rowHeight
            fillMode: Image.PreserveAspectFit
            source: modelData.preview_url
            sourceSize.width: root.rowHeight * modelData.aspect_ratio
            sourceSize.height: root.rowHeight

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: root.rowHeight * modelData.aspect_ratio
                    height: root.rowHeight
                    radius: imageRadius
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            hoverEnabled: false
            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    root.toggleMenu()
                    mouse.accepted = true
                }
            }
        }

        RippleButton {
            id: menuButton
            anchors.top: parent.top
            anchors.right: parent.right
            property real buttonSize: 26
            anchors.margins: 6
            implicitHeight: buttonSize
            implicitWidth: buttonSize

            buttonRadius: Appearance.rounding.full
            colBackground: ColorUtils.transparentize(Appearance.m3colors.m3surface, 0.3)
            colBackgroundHover: ColorUtils.transparentize(ColorUtils.mix(Appearance.m3colors.m3surface, Appearance.m3colors.m3onSurface, 0.8), 0.2)
            colRipple: ColorUtils.transparentize(ColorUtils.mix(Appearance.m3colors.m3surface, Appearance.m3colors.m3onSurface, 0.6), 0.1)

            contentItem: MaterialSymbol {
                horizontalAlignment: Text.AlignHCenter
                iconSize: Appearance.font.pixelSize.large
                color: Appearance.m3colors.m3onSurface
                text: "more_vert"
            }

            onClicked: {
                root.toggleMenu()
            }
        }

        Loader {
            id: contextMenuLoader
            z: 10
            active: root.showActions
            anchors.top: menuButton.bottom
            anchors.right: parent.right
            anchors.margins: 8

            sourceComponent: Item {
                width: contextMenu.width
                height: contextMenu.height

                StyledRectangularShadow {
                    target: contextMenu
                }
                Rectangle {
                    id: contextMenu
                    anchors.centerIn: parent
                    opacity: root.showActions ? 1 : 0
                    visible: opacity > 0
                    radius: Appearance.rounding.small
                    color: Appearance.colors.colSurfaceContainer
                    implicitHeight: contextMenuColumnLayout.implicitHeight + radius * 2
                    implicitWidth: contextMenuColumnLayout.implicitWidth

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Appearance.animation.elementMoveFast.duration
                            easing.type: Appearance.animation.elementMoveFast.type
                            easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
                        }
                    }

                    ColumnLayout {
                        id: contextMenuColumnLayout
                        anchors.centerIn: parent
                        spacing: 0

                        MenuButton {
                            id: openFileLinkButton
                            Layout.fillWidth: true
                            buttonText: Translation.tr("Open file link")
                            onClicked: {
                                root.closeMenu()
                                if (CompositorService.isHyprland) Hyprland.dispatch("keyword cursor:no_warps true")
                                Qt.openUrlExternally(root.imageData.file_url)
                                if (CompositorService.isHyprland) Hyprland.dispatch("keyword cursor:no_warps false")
                            }
                        }
                        MenuButton {
                            id: sourceButton
                            visible: root.imageData.source && root.imageData.source.length > 0
                            Layout.fillWidth: true
                            buttonText: Translation.tr("Go to source (%1)").arg(StringUtils.getDomain(root.imageData.source))
                            enabled: root.imageData.source && root.imageData.source.length > 0
                            onClicked: {
                                root.closeMenu()
                                if (CompositorService.isHyprland) Hyprland.dispatch("keyword cursor:no_warps true")
                                Qt.openUrlExternally(root.imageData.source)
                                if (CompositorService.isHyprland) Hyprland.dispatch("keyword cursor:no_warps false")
                            }
                        }
                        MenuButton {
                            id: downloadButton
                            Layout.fillWidth: true
                            buttonText: Translation.tr("Download")
                            onClicked: {
                                root.closeMenu()
                                const targetPath = root.imageData.is_nsfw ? root.nsfwPath : root.downloadPath;
                                const localPath = `${targetPath}/${root.fileName}`;
                                Quickshell.execDetached(["bash", "-c", 
                                    `mkdir -p '${targetPath}' && curl '${root.imageData.file_url}' -o '${localPath}' && notify-send '${Translation.tr("Download complete")}' '${localPath}' -a 'Shell'`
                                ])
                                Quickshell.execDetached(["xdg-open", targetPath])
                            }
                        }
                        MenuButton {
                            id: setWallpaperButton
                            Layout.fillWidth: true
                            buttonText: Translation.tr("Set as wallpaper")
                            onClicked: {
                                root.closeMenu()
                                const targetPath = root.imageData.is_nsfw ? root.nsfwPath : root.downloadPath;
                                const localPath = `${targetPath}/${root.fileName}`;
                                const mode = Appearance.m3colors.darkmode ? "dark" : "light";
                                Quickshell.execDetached(["bash", "-c",
                                    `mkdir -p '${targetPath}' && curl -sSL '${root.imageData.file_url}' -o '${localPath}' && '${Directories.wallpaperSwitchScriptPath}' --image '${localPath}' --mode '${mode}'`
                                ])
                            }
                        }
                    }
                }
            }
        }
    }
}