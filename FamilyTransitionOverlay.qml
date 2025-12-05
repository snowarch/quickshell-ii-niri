import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import org.kde.kirigami as Kirigami
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.services

// Elegant overlay that shows family-specific branding during transition
// Each family has its own unique visual identity
Scope {
    id: root

    signal exitComplete()
    signal enterComplete()

    readonly property int animDuration: Appearance.animationsEnabled ? 300 : 20
    readonly property int holdDuration: 400
    readonly property int fadeOutDuration: Appearance.animationsEnabled ? 450 : 30
    
    property bool _isWaffle: false
    property bool _fadingOut: false
    property bool _visible: false

    Connections {
        target: GlobalStates
        function onFamilyTransitionActiveChanged() {
            if (GlobalStates.familyTransitionActive) {
                root._isWaffle = GlobalStates.familyTransitionDirection === "left"
                root._fadingOut = false
                root._visible = true
                console.log("[FamilyTransition] Showing overlay for:", root._isWaffle ? "Waffle" : "Material ii")
                switchTimer.start()
            }
        }
    }

    Timer {
        id: switchTimer
        interval: root.animDuration + 50
        onTriggered: {
            root.exitComplete()
            holdTimer.start()
        }
    }
    
    Timer {
        id: holdTimer
        interval: root.holdDuration
        onTriggered: {
            root._fadingOut = true
            fadeOutTimer.start()
        }
    }
    
    Timer {
        id: fadeOutTimer
        interval: root.fadeOutDuration + 50
        onTriggered: {
            root._visible = false
            root._fadingOut = false
            root.enterComplete()
        }
    }

    Loader {
        id: overlayLoader
        active: GlobalStates.familyTransitionActive || root._visible

        sourceComponent: PanelWindow {
            id: overlayPanel
            visible: true
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: -1

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            WlrLayershell.namespace: "quickshell:familyTransition"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            
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

                Rectangle {
                    anchors.fill: parent
                    color: ColorUtils.transparentize(Appearance.m3colors.m3background, 0.2)
                }
            }

            // Family-specific content
            Loader {
                anchors.centerIn: parent
                sourceComponent: root._isWaffle ? waffleTransition : materialTransition
                
                opacity: root._fadingOut ? 0 : (root._visible ? 1 : 0)
                scale: root._fadingOut ? 1.05 : (root._visible ? 1 : 0.9)
                
                Behavior on opacity {
                    NumberAnimation { 
                        duration: root._fadingOut ? root.fadeOutDuration * 0.4 : root.animDuration
                        easing.type: Easing.OutQuad
                    }
                }
                Behavior on scale {
                    NumberAnimation { 
                        duration: root._fadingOut ? root.fadeOutDuration * 0.5 : root.animDuration
                        easing.type: root._fadingOut ? Easing.InQuad : Easing.OutBack
                        easing.overshoot: root._fadingOut ? 0 : 1.2
                    }
                }
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // WAFFLE TRANSITION - Windows 11 Style
    // Grid of tiles that animate in with staggered timing
    // ═══════════════════════════════════════════════════════════════════════
    Component {
        id: waffleTransition
        
        Item {
            id: waffleRoot
            width: 320
            height: 280
            
            // Acrylic-style card with subtle border
            Rectangle {
                id: waffleCard
                anchors.fill: parent
                radius: 8
                color: ColorUtils.transparentize("#1C1C1C", 0.15)
                border.width: 1
                border.color: ColorUtils.transparentize("#FFFFFF", 0.9)
                
                layer.enabled: Appearance.effectsEnabled
                layer.effect: MultiEffect {
                    source: waffleCard
                    anchors.fill: source
                    shadowEnabled: true
                    shadowColor: ColorUtils.transparentize("#000000", 0.5)
                    shadowBlur: 0.6
                    shadowVerticalOffset: 8
                    shadowHorizontalOffset: 0
                }
            }
            
            Column {
                anchors.centerIn: parent
                spacing: 24
                
                // Windows logo made of animated tiles
                Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 80
                    height: 80
                    
                    // 2x2 grid of tiles (Windows logo style)
                    Grid {
                        anchors.centerIn: parent
                        columns: 2
                        spacing: 4
                        
                        Repeater {
                            model: 4
                            
                            Rectangle {
                                id: tile
                                required property int index
                                width: 34
                                height: 34
                                radius: 2
                                color: Appearance.colors.colPrimary
                                
                                // Staggered entrance animation
                                opacity: 0
                                scale: 0.5
                                rotation: -15
                                
                                SequentialAnimation on opacity {
                                    running: root._visible && !root._fadingOut
                                    PauseAnimation { duration: tile.index * 80 }
                                    NumberAnimation { 
                                        to: 1
                                        duration: 250
                                        easing.type: Easing.OutQuad
                                    }
                                }
                                
                                SequentialAnimation on scale {
                                    running: root._visible && !root._fadingOut
                                    PauseAnimation { duration: tile.index * 80 }
                                    NumberAnimation { 
                                        to: 1
                                        duration: 300
                                        easing.type: Easing.OutBack
                                        easing.overshoot: 1.5
                                    }
                                }
                                
                                SequentialAnimation on rotation {
                                    running: root._visible && !root._fadingOut
                                    PauseAnimation { duration: tile.index * 80 }
                                    NumberAnimation { 
                                        to: 0
                                        duration: 300
                                        easing.type: Easing.OutBack
                                    }
                                }
                                
                                // Subtle pulse when fully visible
                                SequentialAnimation on opacity {
                                    running: root._visible && !root._fadingOut
                                    loops: Animation.Infinite
                                    PauseAnimation { duration: 600 + tile.index * 80 }
                                    NumberAnimation { to: 0.7; duration: 800; easing.type: Easing.InOutQuad }
                                    NumberAnimation { to: 1; duration: 800; easing.type: Easing.InOutQuad }
                                }
                            }
                        }
                    }
                }
                
                // Text content
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8
                    
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Waffle"
                        font.pixelSize: 32
                        font.family: "Segoe UI Variable"
                        font.weight: Font.DemiBold
                        color: "#FFFFFF"
                    }
                    
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Windows 11 Style"
                        font.pixelSize: 13
                        font.family: "Segoe UI Variable"
                        color: ColorUtils.transparentize("#FFFFFF", 0.3)
                    }
                }
                
                // Loading dots (Windows style - horizontal line)
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6
                    
                    Repeater {
                        model: 5
                        Rectangle {
                            id: loadingDot
                            required property int index
                            width: 4
                            height: 4
                            radius: 2
                            color: Appearance.colors.colPrimary
                            opacity: 0.3
                            
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                running: root._visible && !root._fadingOut
                                PauseAnimation { duration: loadingDot.index * 100 }
                                NumberAnimation { to: 1; duration: 200; easing.type: Easing.OutQuad }
                                NumberAnimation { to: 0.3; duration: 200; easing.type: Easing.InQuad }
                                PauseAnimation { duration: (4 - loadingDot.index) * 100 + 200 }
                            }
                        }
                    }
                }
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // MATERIAL II TRANSITION - Material Design 3 Style
    // Uses the illogical-impulse logo with smooth 3-dot loading indicator
    // ═══════════════════════════════════════════════════════════════════════
    Component {
        id: materialTransition
        
        Rectangle {
            id: materialCard
            width: 320
            height: 280
            radius: Appearance.rounding.large
            color: Appearance.colors.colLayer1
            border.width: 1
            border.color: Appearance.colors.colLayer0Border
            
            layer.enabled: Appearance.effectsEnabled
            layer.effect: StyledDropShadow {
                target: materialCard
                radius: 20
            }
            
            Column {
                anchors.centerIn: parent
                spacing: 24
                
                // Logo container with glow
                Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 100
                    height: 100
                    
                    // Soft pulsing glow
                    Rectangle {
                        anchors.centerIn: parent
                        width: 90
                        height: 90
                        radius: width / 2
                        color: Appearance.colors.colPrimary
                        opacity: 0.12
                        
                        SequentialAnimation on scale {
                            loops: Animation.Infinite
                            running: root._visible && !root._fadingOut
                            NumberAnimation { to: 1.2; duration: 1500; easing.type: Easing.InOutSine }
                            NumberAnimation { to: 1.0; duration: 1500; easing.type: Easing.InOutSine }
                        }
                    }
                    
                    // ii logo
                    Image {
                        id: iiLogo
                        anchors.centerIn: parent
                        width: 64
                        height: 64
                        source: Qt.resolvedUrl("assets/icons/illogical-impulse.svg")
                        sourceSize: Qt.size(64, 64)
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        
                        // Tint to primary color
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            colorization: 1.0
                            colorizationColor: Appearance.colors.colPrimary
                        }
                        
                        // Entrance animation
                        scale: root._visible && !root._fadingOut ? 1 : 0.5
                        opacity: root._visible && !root._fadingOut ? 1 : 0
                        
                        Behavior on scale {
                            NumberAnimation {
                                duration: 400
                                easing.type: Easing.OutBack
                                easing.overshoot: 1.4
                            }
                        }
                        Behavior on opacity {
                            NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
                        }
                    }
                }
                
                // Text content
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6
                    
                    StyledText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Material ii"
                        font.pixelSize: 32
                        font.family: Appearance.font.family.title
                        color: Appearance.m3colors.m3onSurface
                    }
                    
                    StyledText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Material Design"
                        font.pixelSize: Appearance.font.pixelSize.small
                        color: Appearance.colors.colSubtext
                    }
                }
                
                // Simple 3-dot loading indicator (smooth bounce)
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8
                    
                    Repeater {
                        model: 3
                        
                        Rectangle {
                            id: dot
                            required property int index
                            width: 8
                            height: 8
                            radius: 4
                            color: Appearance.colors.colPrimary
                            
                            // Smooth wave animation
                            transform: Translate { id: dotTranslate; y: 0 }
                            
                            SequentialAnimation {
                                loops: Animation.Infinite
                                running: root._visible && !root._fadingOut
                                
                                PauseAnimation { duration: dot.index * 120 }
                                
                                SequentialAnimation {
                                    NumberAnimation {
                                        target: dotTranslate
                                        property: "y"
                                        to: -10
                                        duration: 300
                                        easing.type: Easing.OutQuad
                                    }
                                    NumberAnimation {
                                        target: dotTranslate
                                        property: "y"
                                        to: 0
                                        duration: 300
                                        easing.type: Easing.InQuad
                                    }
                                }
                                
                                PauseAnimation { duration: (2 - dot.index) * 120 + 400 }
                            }
                        }
                    }
                }
            }
        }
    }
}
