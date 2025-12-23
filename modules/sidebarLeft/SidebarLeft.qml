import qs
import qs.services
import qs.modules.common
import qs.modules.common.models
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Effects
import Quickshell.Io
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Qt5Compat.GraphicalEffects as GE

Scope { // Scope
    id: root
    property bool detach: false
    property Component contentComponent: SidebarLeftContent {}
    property Item sidebarContent

    Component.onCompleted: {
        root.sidebarContent = contentComponent.createObject(null, {
            "scopeRoot": root,
        });
        sidebarLoader.item.contentParent.children = [root.sidebarContent];
    }

    onDetachChanged: {
        if (root.detach) {
            sidebarContent.parent = null; // Detach content from sidebar
            sidebarLoader.active = false; // Unload sidebar
            detachedSidebarLoader.active = true; // Load detached window
            detachedSidebarLoader.item.contentParent.children = [sidebarContent];
        } else {
            sidebarContent.parent = null; // Detach content from window
            detachedSidebarLoader.active = false; // Unload detached window
            sidebarLoader.active = true; // Load sidebar
            sidebarLoader.item.contentParent.children = [sidebarContent];
        }
    }

    Loader {
        id: sidebarLoader
        active: true
        
        sourceComponent: PanelWindow { // Window
            id: sidebarRoot
            visible: GlobalStates.sidebarLeftOpen
            
            property bool extend: false
            property real sidebarWidth: sidebarRoot.extend ? Appearance.sizes.sidebarWidthExtended : Appearance.sizes.sidebarWidth
            property var contentParent: sidebarLeftBackground

            function hide() {
                GlobalStates.sidebarLeftOpen = false
            }

            exclusiveZone: 0
            implicitWidth: Appearance.sizes.sidebarWidthExtended + Appearance.sizes.elevationMargin
            WlrLayershell.namespace: "quickshell:sidebarLeft"
            // Ensure the sidebar can receive keyboard focus even on compositors without Hyprland
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            color: "transparent"

            anchors {
                top: true
                left: true
                bottom: true
                right: true
            }

            CompositorFocusGrab { // Click outside to close (Hyprland only)
                id: grab
                windows: [ sidebarRoot ]
                active: CompositorService.isHyprland && sidebarRoot.visible
                onActiveChanged: { // Focus the selected tab
                    if (active) sidebarLeftBackground.children[0].focusActiveItem()
                }
                onCleared: () => {
                    if (!active) sidebarRoot.hide()
                }
            }

            MouseArea {
                id: backdropClickArea
                anchors.fill: parent
                onClicked: mouse => {
                    const localPos = mapToItem(sidebarLeftBackground, mouse.x, mouse.y)
                    if (localPos.x < 0 || localPos.x > sidebarLeftBackground.width
                            || localPos.y < 0 || localPos.y > sidebarLeftBackground.height) {
                        sidebarRoot.hide()
                    }
                }
            }

            // Content
            StyledRectangularShadow {
                target: sidebarLeftBackground
                radius: sidebarLeftBackground.radius
            }
            Rectangle {
                id: sidebarLeftBackground
                anchors.left: parent.left
                anchors.topMargin: Appearance.sizes.hyprlandGapsOut
                anchors.leftMargin: Appearance.sizes.hyprlandGapsOut
                width: sidebarRoot.sidebarWidth - Appearance.sizes.hyprlandGapsOut - Appearance.sizes.elevationMargin
                height: parent.height - Appearance.sizes.hyprlandGapsOut * 2
                property bool cardStyle: Config.options.sidebar?.cardStyle ?? false
                readonly property bool auroraEverywhere: (Config.options?.bar?.blurBackground?.enabled ?? false) && !(Config.options?.bar?.showBackground ?? true)
                readonly property string wallpaperUrl: Wallpapers.effectiveWallpaperUrl

                ColorQuantizer {
                    id: sidebarLeftWallpaperQuantizer
                    source: sidebarLeftBackground.wallpaperUrl
                    depth: 0
                    rescaleSize: 10
                }

                readonly property color wallpaperDominantColor: (sidebarLeftWallpaperQuantizer?.colors?.[0] ?? Appearance.colors.colPrimary)
                readonly property QtObject blendedColors: AdaptedMaterialScheme {
                    color: ColorUtils.mix(sidebarLeftBackground.wallpaperDominantColor, Appearance.colors.colPrimaryContainer, 0.8) || Appearance.m3colors.m3secondaryContainer
                }

                color: auroraEverywhere ? ColorUtils.applyAlpha((blendedColors?.colLayer0 ?? Appearance.colors.colLayer0), 1) : (cardStyle ? Appearance.colors.colLayer1 : Appearance.colors.colLayer0)
                border.width: 1
                border.color: Appearance.colors.colLayer0Border
                radius: cardStyle ? Appearance.rounding.normal : (Appearance.rounding.screenRounding - Appearance.sizes.hyprlandGapsOut + 1)

                clip: true

                layer.enabled: auroraEverywhere
                layer.effect: GE.OpacityMask {
                    maskSource: Rectangle {
                        width: sidebarLeftBackground.width
                        height: sidebarLeftBackground.height
                        radius: sidebarLeftBackground.radius
                    }
                }

                Image {
                    id: sidebarLeftBlurredWallpaper
                    anchors.fill: parent
                    visible: sidebarLeftBackground.auroraEverywhere
                    source: sidebarLeftBackground.wallpaperUrl
                    fillMode: Image.PreserveAspectCrop
                    cache: true
                    asynchronous: true
                    antialiasing: true

                    layer.enabled: Appearance.effectsEnabled
                    layer.effect: StyledBlurEffect {
                        source: sidebarLeftBlurredWallpaper
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: ColorUtils.transparentize((sidebarLeftBackground.blendedColors?.colLayer0 ?? Appearance.colors.colLayer0), Appearance.aurora.overlayTransparentize)
                    }
                }

                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Escape) {
                        sidebarRoot.hide();
                    }
                    if (event.modifiers === Qt.ControlModifier) {
                        if (event.key === Qt.Key_O) {
                            sidebarRoot.extend = !sidebarRoot.extend;
                        }
                        else if (event.key === Qt.Key_P) {
                            root.detach = !root.detach;
                        }
                        event.accepted = true;
                    }
                }
            }

            // Also focus active tab when the sidebar becomes visible (for compositors without CompositorFocusGrab)
            onVisibleChanged: {
                if (visible && sidebarLeftBackground.children.length > 0) {
                    Qt.callLater(() => sidebarLeftBackground.children[0].focusActiveItem());
                }
            }
        }
    }

    Loader {
        id: detachedSidebarLoader
        active: false

        sourceComponent: FloatingWindow {
            id: detachedSidebarRoot
            property var contentParent: detachedSidebarBackground
            color: "transparent"

            visible: GlobalStates.sidebarLeftOpen
            onVisibleChanged: {
                if (visible && detachedSidebarBackground.children.length > 0) {
                    Qt.callLater(() => detachedSidebarBackground.children[0].focusActiveItem());
                }
                if (!visible) GlobalStates.sidebarLeftOpen = false;
            }
            
            Rectangle {
                id: detachedSidebarBackground
                anchors.fill: parent
                color: Appearance.colors.colLayer0

                Keys.onPressed: (event) => {
                    if (event.modifiers === Qt.ControlModifier) {
                        if (event.key === Qt.Key_P) {
                            root.detach = !root.detach;
                        }
                        event.accepted = true;
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "sidebarLeft"

        function toggle(): void {
            GlobalStates.sidebarLeftOpen = !GlobalStates.sidebarLeftOpen
        }

        function close(): void {
            GlobalStates.sidebarLeftOpen = false
        }

        function open(): void {
            GlobalStates.sidebarLeftOpen = true
        }
    }
    Loader {
        active: CompositorService.isHyprland
        sourceComponent: Item {
            GlobalShortcut {
                name: "sidebarLeftToggle"
                description: "Toggles left sidebar on press"

                onPressed: {
                    GlobalStates.sidebarLeftOpen = !GlobalStates.sidebarLeftOpen;
                }
            }

            GlobalShortcut {
                name: "sidebarLeftOpen"
                description: "Opens left sidebar on press"

                onPressed: {
                    GlobalStates.sidebarLeftOpen = true;
                }
            }

            GlobalShortcut {
                name: "sidebarLeftClose"
                description: "Closes left sidebar on press"

                onPressed: {
                    GlobalStates.sidebarLeftOpen = false;
                }
            }

            GlobalShortcut {
                name: "sidebarLeftToggleDetach"
                description: "Detach left sidebar into a window/Attach it back"

                onPressed: {
                    root.detach = !root.detach;
                }
            }
        }
    }

}
