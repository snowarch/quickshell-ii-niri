import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.modules.sidebarLeft.anime
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
    property bool buttonHovered: false
    
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
            hoverEnabled: true
            onEntered: root.buttonHovered = true
            onExited: root.buttonHovered = false
            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    contextMenu.active = true
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
                contextMenu.active = true
            }
        }

        // Invisible anchor point at center of image for context menu positioning
        Item {
            id: menuAnchor
            anchors.centerIn: parent
            width: 1
            height: 1
            z: 1000
        }

        BooruImageContextMenu {
            id: contextMenu
            z: 1000
            anchorItem: menuAnchor
            anchorHovered: root.hovered || root.buttonHovered
            
            model: [
                {
                    iconName: "open_in_new",
                    text: Translation.tr("Open file link"),
                    action: () => {
                        if (CompositorService.isHyprland) Hyprland.dispatch("keyword cursor:no_warps true")
                        Qt.openUrlExternally(root.imageData.file_url)
                        if (CompositorService.isHyprland) Hyprland.dispatch("keyword cursor:no_warps false")
                    }
                },
                ...(root.imageData.source && root.imageData.source.length > 0 ? [{
                    iconName: "link",
                    text: Translation.tr("Go to source (%1)").arg(StringUtils.getDomain(root.imageData.source)),
                    action: () => {
                        if (CompositorService.isHyprland) Hyprland.dispatch("keyword cursor:no_warps true")
                        Qt.openUrlExternally(root.imageData.source)
                        if (CompositorService.isHyprland) Hyprland.dispatch("keyword cursor:no_warps false")
                    }
                }] : []),
                { type: "separator" },
                {
                    iconName: "download",
                    text: Translation.tr("Download"),
                    action: () => {
                        const targetPath = root.imageData.is_nsfw ? root.nsfwPath : root.downloadPath;
                        const localPath = `${targetPath}/${root.fileName}`;
                        Quickshell.execDetached(["bash", "-c", 
                            `mkdir -p '${targetPath}' && curl '${root.imageData.file_url}' -o '${localPath}' && notify-send '${Translation.tr("Download complete")}' '${localPath}' -a 'Shell'`
                        ])
                        Quickshell.execDetached(["xdg-open", targetPath])
                    }
                },
                {
                    iconName: "wallpaper",
                    text: Translation.tr("Set as wallpaper"),
                    action: () => {
                        const targetPath = root.imageData.is_nsfw ? root.nsfwPath : root.downloadPath;
                        const localPath = `${targetPath}/${root.fileName}`;
                        const mode = Appearance.m3colors.darkmode ? "dark" : "light";
                        Quickshell.execDetached(["bash", "-c",
                            `mkdir -p '${targetPath}' && curl -sSL '${root.imageData.file_url}' -o '${localPath}' && '${Directories.wallpaperSwitchScriptPath}' --image '${localPath}' --mode '${mode}'`
                        ])
                    }
                }
            ]
        }
    }
}