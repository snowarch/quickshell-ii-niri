import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.services

// Elegant overlay that shows family name during transition
// Covers the screen while modules load to prevent flickering
Scope {
    id: root

    signal exitComplete()
    signal enterComplete()

    readonly property int animDuration: Appearance.animationsEnabled ? 250 : 20
    readonly property int holdDuration: 350 // Time to hold overlay while modules load
    readonly property int fadeOutDuration: Appearance.animationsEnabled ? 400 : 30
    
    property string _targetFamilyName: ""
    property string _targetFamilyIcon: ""
    property string _targetSubtitle: ""
    property bool _fadingOut: false
    property bool _visible: false

    Connections {
        target: GlobalStates
        function onFamilyTransitionActiveChanged() {
            if (GlobalStates.familyTransitionActive) {
                const isGoingToWaffle = GlobalStates.familyTransitionDirection === "left"
                root._targetFamilyName = isGoingToWaffle ? "Waffle" : "Material ii"
                root._targetFamilyIcon = isGoingToWaffle ? "grid_view" : "dashboard"
                root._targetSubtitle = isGoingToWaffle ? "Windows 11 Style" : "Material Design"
                root._fadingOut = false
                root._visible = true
                console.log("[FamilyTransition] Showing overlay for:", root._targetFamilyName)
                switchTimer.start()
            }
        }
    }

    // Timer to switch family (while overlay is fully visible)
    Timer {
        id: switchTimer
        interval: root.animDuration + 50
        onTriggered: {
            console.log("[FamilyTransition] Switching family")
            root.exitComplete()
            holdTimer.start()
        }
    }
    
    // Timer to hold overlay while new modules initialize
    Timer {
        id: holdTimer
        interval: root.holdDuration
        onTriggered: {
            console.log("[FamilyTransition] Starting fade out")
            root._fadingOut = true
            fadeOutTimer.start()
        }
    }
    
    // Timer to complete transition after fade out
    Timer {
        id: fadeOutTimer
        interval: root.fadeOutDuration + 50
        onTriggered: {
            console.log("[FamilyTransition] Complete")
            root._visible = false
            root._fadingOut = false
            root.enterComplete()
        }
    }

    // Overlay panel
    Loader {
        id: overlayLoader
        active: GlobalStates.familyTransitionActive || root._visible

        sourceComponent: PanelWindow {
            id: overlayPanel
            visible: true
            
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: -1 // Cover entire screen including other panels

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            WlrLayershell.namespace: "quickshell:familyTransition"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            
            // Use screen dimensions directly
            implicitWidth: screen?.width ?? 1920
            implicitHeight: screen?.height ?? 1080

            // Blurred wallpaper background
            Item {
                id: blurredBackground
                anchors.fill: parent
                opacity: root._fadingOut ? 0 : 1
                
                Behavior on opacity {
                    NumberAnimation { 
                        duration: root.fadeOutDuration
                        easing.type: Easing.InOutQuad
                    }
                }

                // Wallpaper image
                Image {
                    id: wallpaperImage
                    anchors.fill: parent
                    source: Config.options?.background?.wallpaperPath 
                        ? Qt.resolvedUrl(Config.options.background.wallpaperPath)
                        : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true

                    layer.enabled: Appearance.effectsEnabled
                    layer.effect: MultiEffect {
                        source: wallpaperImage
                        anchors.fill: source
                        saturation: 0.3
                        blurEnabled: true
                        blurMax: 80
                        blur: 1.0
                    }
                }

                // Dark overlay on top of blurred wallpaper
                Rectangle {
                    anchors.fill: parent
                    color: ColorUtils.transparentize(Appearance.m3colors.m3background, 0.25)
                }
            }

            // Center card with family info
            Rectangle {
                id: card
                anchors.centerIn: parent
                width: cardContent.width + 80
                height: cardContent.height + 60
                radius: Appearance.rounding.large
                color: Appearance.colors.colLayer1
                border.width: 1
                border.color: Appearance.colors.colLayer0Border
                
                // Shadow
                layer.enabled: Appearance.effectsEnabled && !root._fadingOut
                layer.effect: StyledDropShadow {
                    target: card
                    radius: 20
                }
                
                // Entrance/exit animation
                scale: {
                    if (root._fadingOut) return 1.05
                    if (root._visible) return 1
                    return 0.9
                }
                opacity: root._fadingOut ? 0 : (root._visible ? 1 : 0)
                
                Behavior on scale {
                    NumberAnimation { 
                        duration: root._fadingOut ? root.fadeOutDuration * 0.5 : root.animDuration
                        easing.type: root._fadingOut ? Easing.InQuad : Easing.OutBack
                        easing.overshoot: root._fadingOut ? 0 : 1.2
                    }
                }
                Behavior on opacity {
                    NumberAnimation { 
                        duration: root._fadingOut ? root.fadeOutDuration * 0.4 : root.animDuration
                        easing.type: Easing.OutQuad
                    }
                }

                Column {
                    id: cardContent
                    anchors.centerIn: parent
                    spacing: 16

                    // Icon with glow effect
                    Item {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 80
                        height: 80
                        
                        // Glow behind icon
                        Rectangle {
                            anchors.centerIn: parent
                            width: 60
                            height: 60
                            radius: 30
                            color: Appearance.colors.colPrimary
                            opacity: 0.15
                            
                            // Pulse animation
                            SequentialAnimation on scale {
                                loops: Animation.Infinite
                                running: root._visible && !root._fadingOut
                                NumberAnimation { to: 1.2; duration: 1000; easing.type: Easing.InOutQuad }
                                NumberAnimation { to: 1.0; duration: 1000; easing.type: Easing.InOutQuad }
                            }
                        }

                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: root._targetFamilyIcon
                            iconSize: 72
                            color: Appearance.colors.colPrimary
                        }
                    }

                    // Family name
                    StyledText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root._targetFamilyName
                        font.pixelSize: 38
                        font.family: Appearance.font.family.title
                        color: Appearance.m3colors.m3onSurface
                    }

                    // Subtitle
                    StyledText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root._targetSubtitle
                        font.pixelSize: Appearance.font.pixelSize.normal
                        color: Appearance.colors.colSubtext
                        opacity: 0.8
                    }
                    
                    // Loading indicator
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 8
                        opacity: root._fadingOut ? 0 : 0.6
                        
                        Behavior on opacity {
                            NumberAnimation { duration: 200 }
                        }
                        
                        Repeater {
                            model: 3
                            Rectangle {
                                required property int index
                                width: 8
                                height: 8
                                radius: 4
                                color: Appearance.colors.colPrimary
                                
                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite
                                    running: root._visible && !root._fadingOut
                                    PauseAnimation { duration: index * 150 }
                                    NumberAnimation { to: 1; duration: 300; easing.type: Easing.OutQuad }
                                    NumberAnimation { to: 0.3; duration: 300; easing.type: Easing.InQuad }
                                    PauseAnimation { duration: (2 - index) * 150 }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
