pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.modules.common.functions
import qs.services

Singleton {
    id: root
    property QtObject m3colors
    property QtObject animation
    property QtObject animationCurves
    property QtObject aurora
    property QtObject inir
    property QtObject colors
    property QtObject rounding
    property QtObject font
    property QtObject sizes
    property string syntaxHighlightingTheme

    // Transparency. The quadratic functions were derived from analysis of hand-picked transparency values.
    ColorQuantizer {
        id: wallColorQuant
        property string wallpaperPath: Config.options.background.wallpaperPath
        property bool wallpaperIsVideo: wallpaperPath.endsWith(".mp4") || wallpaperPath.endsWith(".webm") || wallpaperPath.endsWith(".mkv") || wallpaperPath.endsWith(".avi") || wallpaperPath.endsWith(".mov")
        source: Qt.resolvedUrl(wallpaperIsVideo ? Config.options.background.thumbnailPath : Config.options.background.wallpaperPath)
        depth: 0 // 2^0 = 1 color
        rescaleSize: 10
    }
    property real wallpaperVibrancy: (wallColorQuant.colors[0]?.hslSaturation + wallColorQuant.colors[0]?.hslLightness) / 2
    property real autoBackgroundTransparency: { // y = 0.5768x^2 - 0.759x + 0.2896
        let x = wallpaperVibrancy
        let y = 0.5768 * (x * x) - 0.759 * (x) + 0.2896
        return Math.max(0, Math.min(0.22, y))
    }
    property real autoContentTransparency: 0.9
    
    // Transparency - respects enable toggle
    readonly property bool _transparencyEnabled: Config?.options?.appearance?.transparency?.enable ?? false
    readonly property bool _transparencyAutomatic: Config?.options?.appearance?.transparency?.automatic ?? true
    property real backgroundTransparency: _transparencyEnabled 
        ? (_transparencyAutomatic ? autoBackgroundTransparency : (Config?.options?.appearance?.transparency?.backgroundTransparency ?? 0)) 
        : 0
    property real contentTransparency: _transparencyEnabled 
        ? (_transparencyAutomatic ? autoContentTransparency : (Config?.options?.appearance?.transparency?.contentTransparency ?? 0)) 
        : 0

    // Global style - centralized style detection (reactive bindings)
    readonly property string globalStyle: Config?.options?.appearance?.globalStyle ?? "material"
    readonly property bool inirEverywhere: globalStyle === "inir"
    // auroraEverywhere controls blur/glass backgrounds
    readonly property bool auroraEverywhere: globalStyle === "aurora"
    
    // Aurora light mode: when aurora + light theme, use ink-colored text for contrast
    // Ink colors are muted dark tones (not pure black) that work well over light/transparent backgrounds
    readonly property bool _auroraLightMode: auroraEverywhere && !(m3colors?.darkmode ?? true)

    // GameMode integration - disable effects/animations when fullscreen detected
    property bool _gameModeActive: GameMode?.active ?? false
    property bool _gameModeDisablesEffects: _gameModeActive && (GameMode?.disableEffects ?? true)
    property bool _gameModeDisablesAnimations: _gameModeActive && (GameMode?.disableAnimations ?? true)
    property bool _gameModeMinimalMode: _gameModeActive && (GameMode?.minimalMode ?? true)

    // Master switches for effects and animations
    property bool effectsEnabled: !Config.options?.performance?.lowPower && !_gameModeDisablesEffects
    property bool animationsEnabled: !_gameModeDisablesAnimations && !(Config.options?.performance?.reduceAnimations ?? false)
    
    // Minimal mode: panels become transparent, no backgrounds, reduced visual weight
    // Components should check this to hide backgrounds/shadows during GameMode
    readonly property bool gameModeMinimal: _gameModeMinimalMode

    onEffectsEnabledChanged: console.log("[Appearance] effectsEnabled:", effectsEnabled, "gameModeActive:", _gameModeActive)
    onAnimationsEnabledChanged: console.log("[Appearance] animationsEnabled:", animationsEnabled)

    // Helper for calculating effective animation duration
    function calcEffectiveDuration(baseDuration) {
        return animationsEnabled ? baseDuration : 0
    }

    m3colors: QtObject {
        property bool darkmode: true
        property bool transparent: false
        // Dark blue/grey background tuned for dark wallpapers
        property color m3background: "#06070b"
        property color m3onBackground: "#E3E6F0"
        property color m3surface: "#06070b"
        property color m3surfaceDim: "#05060a"
        property color m3surfaceBright: "#141825"
        property color m3surfaceContainerLowest: "#040508"
        property color m3surfaceContainerLow: "#0B0E16"
        property color m3surfaceContainer: "#111522"
        property color m3surfaceContainerHigh: "#161B28"
        property color m3surfaceContainerHighest: "#1B2233"
        property color m3onSurface: "#E3E6F0"
        property color m3surfaceVariant: "#3D455A"
        property color m3onSurfaceVariant: "#C3CAD9"
        property color m3inverseSurface: "#E3E6F0"
        property color m3inverseOnSurface: "#151822"
        property color m3outline: "#707894"
        property color m3outlineVariant: "#3D455A"
        property color m3shadow: "#000000"
        property color m3scrim: "#000000"
        // Primary accent shifted to an electric-ish blue
        property color m3surfaceTint: "#1F6CFF"
        property color m3primary: "#1F6CFF"
        property color m3onPrimary: "#0A1020"
        property color m3primaryContainer: "#12244A"
        property color m3onPrimaryContainer: "#C7D4FF"
        property color m3inversePrimary: "#8CACFF"
        property color m3secondary: "#9AA5C0"
        property color m3onSecondary: "#151925"
        property color m3secondaryContainer: "#242C40"
        property color m3onSecondaryContainer: "#D6DDF0"
        property color m3tertiary: "#d1c3c6"
        property color m3onTertiary: "#372e30"
        property color m3tertiaryContainer: "#31292b"
        property color m3onTertiaryContainer: "#c1b4b7"
        property color m3error: "#ffb4ab"
        property color m3onError: "#690005"
        property color m3errorContainer: "#93000a"
        property color m3onErrorContainer: "#ffdad6"
        property color m3primaryFixed: "#e7e0e7"
        property color m3primaryFixedDim: "#cbc4cb"
        property color m3onPrimaryFixed: "#1d1b1f"
        property color m3onPrimaryFixedVariant: "#49454b"
        property color m3secondaryFixed: "#e6e1e4"
        property color m3secondaryFixedDim: "#cac5c8"
        property color m3onSecondaryFixed: "#1d1b1d"
        property color m3onSecondaryFixedVariant: "#484648"
        property color m3tertiaryFixed: "#eddfe1"
        property color m3tertiaryFixedDim: "#d1c3c6"
        property color m3onTertiaryFixed: "#211a1c"
        property color m3onTertiaryFixedVariant: "#4e4447"
        property color m3success: "#B5CCBA"
        property color m3onSuccess: "#213528"
        property color m3successContainer: "#374B3E"
        property color m3onSuccessContainer: "#D1E9D6"
        property color term0: "#EDE4E4"
        property color term1: "#B52755"
        property color term2: "#A97363"
        property color term3: "#AF535D"
        property color term4: "#A67F7C"
        property color term5: "#B2416B"
        property color term6: "#8D76AD"
        property color term7: "#272022"
        property color term8: "#0E0D0D"
        property color term9: "#B52755"
        property color term10: "#A97363"
        property color term11: "#AF535D"
        property color term12: "#A67F7C"
        property color term13: "#B2416B"
        property color term14: "#8D76AD"
        property color term15: "#221A1A"
    }

    colors: QtObject {
        // Ink colors for aurora light mode - sumi-e inspired (Japanese ink wash)
        // Warm, muted tones instead of pure gray/black
        readonly property color _inkPrimary: "#2b2622"      // Warm charcoal - main text
        readonly property color _inkSecondary: "#5c534a"    // Warm gray - secondary text
        readonly property color _inkMuted: "#8a7f73"        // Warm taupe - inactive/disabled
        
        property color colSubtext: root._auroraLightMode ? _inkSecondary : m3colors.m3outline
        // Layer 0
        property color colLayer0Base: ColorUtils.mix(m3colors.m3background, m3colors.m3primary, Config?.options?.appearance?.extraBackgroundTint ? 0.99 : 1)
        property color colLayer0: ColorUtils.transparentize(colLayer0Base, root.backgroundTransparency)
        property color colOnLayer0: root._auroraLightMode ? _inkPrimary : m3colors.m3onBackground
        property color colLayer0Hover: ColorUtils.transparentize(ColorUtils.mix(colLayer0, colOnLayer0, 0.9, root.contentTransparency))
        property color colLayer0Active: ColorUtils.transparentize(ColorUtils.mix(colLayer0, colOnLayer0, 0.8, root.contentTransparency))
        property color colLayer0Border: ColorUtils.mix(root.m3colors.m3outlineVariant, colLayer0, 0.4)
        // Layer 1
        property color colLayer1Base: m3colors.m3surfaceContainerLow
        property color colLayer1: ColorUtils.solveOverlayColor(colLayer0Base, colLayer1Base, 1 - root.contentTransparency)
        property color colOnLayer1: root._auroraLightMode ? _inkPrimary : m3colors.m3onSurfaceVariant
        property color colOnLayer1Inactive: root._auroraLightMode ? _inkMuted : ColorUtils.mix(colOnLayer1, colLayer1, 0.45)
        property color colLayer1Hover: ColorUtils.transparentize(ColorUtils.mix(colLayer1, colOnLayer1, 0.92), root.contentTransparency)
        property color colLayer1Active: ColorUtils.transparentize(ColorUtils.mix(colLayer1, colOnLayer1, 0.85), root.contentTransparency)
        // Layer 2
        property color colLayer2Base: m3colors.m3surfaceContainer
        property color colLayer2: ColorUtils.solveOverlayColor(colLayer1Base, colLayer2Base, 1 - root.contentTransparency)
        property color colLayer2Hover: ColorUtils.solveOverlayColor(colLayer1Base, ColorUtils.mix(colLayer2Base, colOnLayer2, 0.90), 1 - root.contentTransparency)
        property color colLayer2Active: ColorUtils.solveOverlayColor(colLayer1Base, ColorUtils.mix(colLayer2Base, colOnLayer2, 0.80), 1 - root.contentTransparency)
        property color colLayer2Disabled: ColorUtils.solveOverlayColor(colLayer1Base, ColorUtils.mix(colLayer2Base, m3colors.m3background, 0.8), 1 - root.contentTransparency)
        property color colOnLayer2: root._auroraLightMode ? _inkPrimary : m3colors.m3onSurface
        property color colOnLayer2Disabled: root._auroraLightMode ? _inkMuted : ColorUtils.mix(colOnLayer2, m3colors.m3background, 0.4)
        // Layer 3
        property color colLayer3Base: m3colors.m3surfaceContainerHigh
        property color colLayer3: ColorUtils.solveOverlayColor(colLayer2Base, colLayer3Base, 1 - root.contentTransparency)
        property color colLayer3Hover: ColorUtils.solveOverlayColor(colLayer2Base, ColorUtils.mix(colLayer3Base, colOnLayer3, 0.90), 1 - root.contentTransparency)
        property color colLayer3Active: ColorUtils.solveOverlayColor(colLayer2Base, ColorUtils.mix(colLayer3Base, colOnLayer3, 0.80), 1 - root.contentTransparency)
        property color colOnLayer3: root._auroraLightMode ? _inkPrimary : m3colors.m3onSurface
        // Layer 4
        property color colLayer4Base: m3colors.m3surfaceContainerHighest
        property color colLayer4: ColorUtils.solveOverlayColor(colLayer3Base, colLayer4Base, 1 - root.contentTransparency)
        property color colLayer4Hover: ColorUtils.solveOverlayColor(colLayer3Base, ColorUtils.mix(colLayer4Base, colOnLayer4, 0.90), 1 - root.contentTransparency)
        property color colLayer4Active: ColorUtils.solveOverlayColor(colLayer3Base, ColorUtils.mix(colLayer4Base, colOnLayer4, 0.80), 1 - root.contentTransparency)
        property color colOnLayer4: root._auroraLightMode ? _inkPrimary : m3colors.m3onSurface
        // Primary
        property color colPrimary: m3colors.m3primary
        property color colOnPrimary: m3colors.m3onPrimary
        property color colPrimaryHover: ColorUtils.mix(colors.colPrimary, colLayer1Hover, 0.87)
        property color colPrimaryActive: ColorUtils.mix(colors.colPrimary, colLayer1Active, 0.7)
        property color colPrimaryContainer: m3colors.m3primaryContainer
        property color colPrimaryContainerHover: ColorUtils.mix(colors.colPrimaryContainer, colors.colOnPrimaryContainer, 0.9)
        property color colPrimaryContainerActive: ColorUtils.mix(colors.colPrimaryContainer, colors.colOnPrimaryContainer, 0.8)
        property color colOnPrimaryContainer: m3colors.m3onPrimaryContainer
        // Secondary
        property color colSecondary: m3colors.m3secondary
        property color colSecondaryHover: ColorUtils.mix(m3colors.m3secondary, colLayer1Hover, 0.85)
        property color colSecondaryActive: ColorUtils.mix(m3colors.m3secondary, colLayer1Active, 0.4)
        property color colOnSecondary: m3colors.m3onSecondary
        property color colSecondaryContainer: m3colors.m3secondaryContainer
        property color colSecondaryContainerHover: ColorUtils.mix(m3colors.m3secondaryContainer, m3colors.m3onSecondaryContainer, 0.90)
        property color colSecondaryContainerActive: ColorUtils.mix(m3colors.m3secondaryContainer, m3colors.m3onSecondaryContainer, 0.54)
        property color colOnSecondaryContainer: m3colors.m3onSecondaryContainer
        // Tertiary
        property color colTertiary: m3colors.m3tertiary
        property color colTertiaryHover: ColorUtils.mix(m3colors.m3tertiary, colLayer1Hover, 0.85)
        property color colTertiaryActive: ColorUtils.mix(m3colors.m3tertiary, colLayer1Active, 0.4)
        property color colTertiaryContainer: m3colors.m3tertiaryContainer
        property color colTertiaryContainerHover: ColorUtils.mix(m3colors.m3tertiaryContainer, m3colors.m3onTertiaryContainer, 0.90)
        property color colTertiaryContainerActive: ColorUtils.mix(m3colors.m3tertiaryContainer, colLayer1Active, 0.54)
        property color colOnTertiary: m3colors.m3onTertiary
        property color colOnTertiaryContainer: m3colors.m3onTertiaryContainer
        // Surface
        property color colBackgroundSurfaceContainer: ColorUtils.transparentize(m3colors.m3surfaceContainer, root.backgroundTransparency)
        property color colSurfaceContainerLow: ColorUtils.solveOverlayColor(m3colors.m3background, m3colors.m3surfaceContainerLow, 1 - root.contentTransparency)
        property color colSurfaceContainer: ColorUtils.solveOverlayColor(m3colors.m3surfaceContainerLow, m3colors.m3surfaceContainer, 1 - root.contentTransparency)
        property color colSurfaceContainerHigh: ColorUtils.solveOverlayColor(m3colors.m3surfaceContainer, m3colors.m3surfaceContainerHigh, 1 - root.contentTransparency)
        property color colSurfaceContainerHighest: ColorUtils.solveOverlayColor(m3colors.m3surfaceContainerHigh, m3colors.m3surfaceContainerHighest, 1 - root.contentTransparency)
        property color colSurfaceContainerHighestHover: ColorUtils.mix(m3colors.m3surfaceContainerHighest, m3colors.m3onSurface, 0.95)
        property color colSurfaceContainerHighestActive: ColorUtils.mix(m3colors.m3surfaceContainerHighest, m3colors.m3onSurface, 0.85)
        property color colOnSurface: m3colors.m3onSurface
        property color colOnSurfaceVariant: m3colors.m3onSurfaceVariant
        // Misc
        property color colTooltip: m3colors.m3inverseSurface
        property color colOnTooltip: m3colors.m3inverseOnSurface
        property color colScrim: ColorUtils.transparentize(m3colors.m3scrim, 0.5)
        property color colShadow: ColorUtils.transparentize(m3colors.m3shadow, 0.7)
        property color colOutline: m3colors.m3outline
        property color colOutlineVariant: m3colors.m3outlineVariant
        property color colError: m3colors.m3error
        property color colErrorHover: ColorUtils.mix(m3colors.m3error, colLayer1Hover, 0.85)
        property color colErrorActive: ColorUtils.mix(m3colors.m3error, colLayer1Active, 0.7)
        property color colOnError: m3colors.m3onError
        property color colErrorContainer: m3colors.m3errorContainer
        property color colErrorContainerHover: ColorUtils.mix(m3colors.m3errorContainer, m3colors.m3onErrorContainer, 0.90)
        property color colErrorContainerActive: ColorUtils.mix(m3colors.m3errorContainer, m3colors.m3onErrorContainer, 0.70)
        property color colOnErrorContainer: m3colors.m3onErrorContainer
    }

    rounding: QtObject {
        property int unsharpen: 2
        property int unsharpenmore: 6
        property int verysmall: 8
        property int small: 12
        property int normal: 17
        property int large: 23
        property int verylarge: 30
        property int full: 9999
        property int screenRounding: large
        property int windowRounding: 18
    }

    // Typography scale factor from config
    property real fontSizeScale: Config.options?.appearance?.typography?.sizeScale ?? 1.0

    font: QtObject {
        property QtObject family: QtObject {
            property string main: Config.options?.appearance?.typography?.mainFont ?? "Roboto Flex"
            property string numbers: "Rubik"
            property string title: Config.options?.appearance?.typography?.titleFont ?? "Gabarito"
            property string iconMaterial: "Material Symbols Rounded"
            property string iconNerd: "JetBrains Mono NF"
            property string monospace: Config.options?.appearance?.typography?.monospaceFont ?? "JetBrainsMono Nerd Font"
            property string reading: "Readex Pro"
            property string expressive: "Space Grotesk"
        }
        property QtObject variableAxes: QtObject {
            // Roboto Flex is customized to feel geometric, unserious yet not overly kiddy
            property var main: ({
                "YTUC": 716,
                "YTFI": 716,
                "YTAS": 716,
                "YTLC": 490,
                "XTRA": 488,
                "wdth": Config.options?.appearance?.typography?.variableAxes?.wdth ?? 105,
                "GRAD": Config.options?.appearance?.typography?.variableAxes?.grad ?? 175,
                "wght": Config.options?.appearance?.typography?.variableAxes?.wght ?? 300,
            })
            property var numbers: ({
                "wght": 400,
            })
            property var title: ({
                "wght": 900,
            })
        }
        property QtObject pixelSize: QtObject {
            property int smallest: Math.round(10 * root.fontSizeScale)
            property int smaller: Math.round(12 * root.fontSizeScale)
            property int smallie: Math.round(13 * root.fontSizeScale)
            property int small: Math.round(15 * root.fontSizeScale)
            property int normal: Math.round(16 * root.fontSizeScale)
            property int large: Math.round(17 * root.fontSizeScale)
            property int larger: Math.round(19 * root.fontSizeScale)
            property int huge: Math.round(22 * root.fontSizeScale)
            property int hugeass: Math.round(23 * root.fontSizeScale)
            property int title: huge
        }
    }

    animationCurves: QtObject {
        readonly property list<real> expressiveFastSpatial: [0.42, 1.67, 0.21, 0.90, 1, 1] // Default, 350ms
        readonly property list<real> expressiveDefaultSpatial: [0.38, 1.21, 0.22, 1.00, 1, 1] // Default, 500ms
        readonly property list<real> expressiveSlowSpatial: [0.39, 1.29, 0.35, 0.98, 1, 1] // Default, 650ms
        readonly property list<real> expressiveEffects: [0.34, 0.80, 0.34, 1.00, 1, 1] // Default, 200ms
        readonly property list<real> emphasized: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
        readonly property list<real> emphasizedFirstHalf: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82]
        readonly property list<real> emphasizedLastHalf: [5 / 24, 0.82, 0.25, 1, 1, 1]
        readonly property list<real> emphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1]
        readonly property list<real> emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]
        readonly property list<real> standard: [0.2, 0, 0, 1, 1, 1]
        readonly property list<real> standardAccel: [0.3, 0, 1, 1, 1, 1]
        readonly property list<real> standardDecel: [0, 0, 0, 1, 1, 1]
        readonly property real expressiveFastSpatialDuration: 350
        readonly property real expressiveDefaultSpatialDuration: 500
        readonly property real expressiveSlowSpatialDuration: 650
        readonly property real expressiveEffectsDuration: 200
    }

    animation: QtObject {
        property QtObject elementMove: QtObject {
            property int duration: root.calcEffectiveDuration(animationCurves.expressiveDefaultSpatialDuration)
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.expressiveDefaultSpatial
            property int velocity: 650
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.elementMove.duration
                    easing.type: root.animation.elementMove.type
                    easing.bezierCurve: root.animation.elementMove.bezierCurve
                }
            }
        }

        property QtObject elementMoveEnter: QtObject {
            property int duration: root.calcEffectiveDuration(400)
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.emphasizedDecel
            property int velocity: 650
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.elementMoveEnter.duration
                    easing.type: root.animation.elementMoveEnter.type
                    easing.bezierCurve: root.animation.elementMoveEnter.bezierCurve
                }
            }
        }

        property QtObject elementMoveExit: QtObject {
            property int duration: root.calcEffectiveDuration(200)
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.emphasizedAccel
            property int velocity: 650
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.elementMoveExit.duration
                    easing.type: root.animation.elementMoveExit.type
                    easing.bezierCurve: root.animation.elementMoveExit.bezierCurve
                }
            }
        }

        property QtObject elementMoveFast: QtObject {
            property int duration: root.calcEffectiveDuration(animationCurves.expressiveEffectsDuration)
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.expressiveEffects
            property int velocity: 850
            property Component colorAnimation: Component { ColorAnimation {
                duration: root.animation.elementMoveFast.duration
                easing.type: root.animation.elementMoveFast.type
                easing.bezierCurve: root.animation.elementMoveFast.bezierCurve
            }}
            property Component numberAnimation: Component { NumberAnimation {
                    duration: root.animation.elementMoveFast.duration
                    easing.type: root.animation.elementMoveFast.type
                    easing.bezierCurve: root.animation.elementMoveFast.bezierCurve
            }}
        }

        property QtObject elementResize: QtObject {
            property int duration: root.calcEffectiveDuration(300)
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.emphasized
            property int velocity: 650
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.elementResize.duration
                    easing.type: root.animation.elementResize.type
                    easing.bezierCurve: root.animation.elementResize.bezierCurve
                }
            }
        }

        property QtObject clickBounce: QtObject {
            property int duration: root.calcEffectiveDuration(400)
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.expressiveDefaultSpatial
            property int velocity: 850
            property Component numberAnimation: Component { NumberAnimation {
                    duration: root.animation.clickBounce.duration
                    easing.type: root.animation.clickBounce.type
                    easing.bezierCurve: root.animation.clickBounce.bezierCurve
            }}
        }
        
        property QtObject scroll: QtObject {
            property int duration: root.calcEffectiveDuration(200)
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.standardDecel
        }

        property QtObject menuDecel: QtObject {
            property int duration: root.calcEffectiveDuration(350)
            property int type: Easing.OutExpo
        }
    }

    aurora: QtObject {
        // Aurora glass effect - professional, elegant transparency
        // Values tuned for visual hierarchy while maintaining readability
        
        // Transparency levels (higher = more transparent)
        readonly property real overlayTransparentize: 0.38      // Main panels: 62% opaque - subtle glass
        readonly property real subSurfaceTransparentize: 0.52   // Cards/groups: 48% opaque - visible hierarchy
        readonly property real popupTransparentize: 0.42        // Popups/menus: 58% opaque - prominent
        readonly property real tooltipTransparentize: 0.35      // Tooltips: 65% opaque - high contrast
        
        // === Main Panel Overlay (Layer 0) ===
        readonly property color colOverlay: ColorUtils.transparentize(root.colors.colLayer0Base, overlayTransparentize)
        readonly property color colOverlayHover: ColorUtils.transparentize(
            ColorUtils.mix(root.colors.colLayer0Base, root.colors.colOnLayer0, 0.95), overlayTransparentize)
        
        // === Sub-Surface (Layer 1 - cards, groups within panels) ===
        readonly property color colSubSurface: ColorUtils.transparentize(root.colors.colLayer1Base, subSurfaceTransparentize)
        readonly property color colSubSurfaceHover: ColorUtils.transparentize(
            ColorUtils.mix(root.colors.colLayer1Base, root.colors.colOnLayer1, 0.92), subSurfaceTransparentize)
        readonly property color colSubSurfaceActive: ColorUtils.transparentize(
            ColorUtils.mix(root.colors.colLayer1Base, root.colors.colOnLayer1, 0.85), subSurfaceTransparentize)
        
        // === Elevated Surface (Layer 2 - elevated cards) ===
        readonly property color colElevatedSurface: ColorUtils.transparentize(root.colors.colLayer2Base, subSurfaceTransparentize * 0.9)
        readonly property color colElevatedSurfaceHover: ColorUtils.transparentize(
            ColorUtils.mix(root.colors.colLayer2Base, root.colors.colOnLayer2, 0.92), subSurfaceTransparentize * 0.9)
        
        // === Popup Surface (menus, dialogs, floating elements) ===
        readonly property color colPopupSurface: ColorUtils.transparentize(root.colors.colLayer2Base, popupTransparentize)
        readonly property color colPopupSurfaceHover: ColorUtils.transparentize(
            ColorUtils.mix(root.colors.colLayer2Base, root.colors.colOnLayer2, 0.92), popupTransparentize)
        readonly property color colPopupSurfaceActive: ColorUtils.transparentize(
            ColorUtils.mix(root.colors.colLayer2Base, root.colors.colOnLayer2, 0.85), popupTransparentize)
        
        // === Tooltip Surface (high contrast for readability) ===
        readonly property color colTooltipSurface: ColorUtils.transparentize(root.colors.colLayer3Base, tooltipTransparentize)
        readonly property color colTooltipBorder: ColorUtils.transparentize(
            ColorUtils.mix(root.colors.colLayer3Base, root.colors.colOnLayer3, 0.85), tooltipTransparentize * 0.8)
        
        // === Dialog Surface (modal dialogs) ===
        readonly property color colDialogSurface: ColorUtils.transparentize(root.colors.colLayer3Base, popupTransparentize * 0.85)
        
        // Legacy alias for backward compatibility
        readonly property real popupSurfaceTransparentize: popupTransparentize
    }

    inir: QtObject {
        // Inir style - Elegant terminal UI aesthetic
        
        // ═══════════════════════════════════════════════════════════════
        // LAYER SYSTEM
        // ═══════════════════════════════════════════════════════════════
        readonly property color colLayer0: root.m3colors.m3background
        readonly property color colLayer1: root.m3colors.m3surfaceContainerLow
        readonly property color colLayer2: root.m3colors.m3surfaceContainer
        readonly property color colLayer3: root.m3colors.m3surfaceContainerHigh
        
        readonly property color colOnLayer0: root.m3colors.m3onBackground
        readonly property color colOnLayer1: root.m3colors.m3onSurface
        readonly property color colOnLayer2: root.m3colors.m3onSurface
        readonly property color colOnLayer3: root.m3colors.m3onSurface
        
        // Hover states (very subtle, calm interactions)
        readonly property color colLayer1Hover: ColorUtils.mix(colLayer1, colOnLayer1, 0.94)
        readonly property color colLayer2Hover: ColorUtils.mix(colLayer2, colOnLayer2, 0.94)
        readonly property color colLayer3Hover: ColorUtils.mix(colLayer3, colOnLayer3, 0.94)
        
        // Active states (slightly more visible)
        readonly property color colLayer1Active: ColorUtils.mix(colLayer1, colOnLayer1, 0.88)
        readonly property color colLayer2Active: ColorUtils.mix(colLayer2, colOnLayer2, 0.88)
        readonly property color colLayer3Active: ColorUtils.mix(colLayer3, colOnLayer3, 0.88)
        
        // ═══════════════════════════════════════════════════════════════
        // BORDER SYSTEM (Elegant, subtle - refined appearance)
        // ═══════════════════════════════════════════════════════════════
        readonly property color colBorder: ColorUtils.transparentize(root.m3colors.m3outlineVariant, 0.3)
        readonly property color colBorderHover: root.m3colors.m3outlineVariant
        readonly property color colBorderAccent: ColorUtils.transparentize(root.m3colors.m3primary, 0.6)
        readonly property color colBorderFocus: ColorUtils.transparentize(root.m3colors.m3primary, 0.3)
        readonly property color colBorderSubtle: ColorUtils.transparentize(root.m3colors.m3outlineVariant, 0.6)
        readonly property color colBorderMuted: ColorUtils.transparentize(root.m3colors.m3outline, 0.7)
        
        // ═══════════════════════════════════════════════════════════════
        // TEXT COLORS (refined hierarchy)
        // ═══════════════════════════════════════════════════════════════
        readonly property color colText: root.m3colors.m3onSurface
        readonly property color colTextSecondary: root.m3colors.m3onSurfaceVariant
        readonly property color colTextMuted: ColorUtils.transparentize(root.m3colors.m3onSurfaceVariant, 0.3)
        readonly property color colTextDisabled: ColorUtils.transparentize(root.m3colors.m3outline, 0.5)
        
        // Labels (subtle accent)
        readonly property color colLabel: root.m3colors.m3primary
        readonly property color colLabelSecondary: root.m3colors.m3secondary
        
        // ═══════════════════════════════════════════════════════════════
        // PRIMARY/ACCENT (calm, not overwhelming)
        // ═══════════════════════════════════════════════════════════════
        readonly property color colPrimary: root.m3colors.m3primary
        readonly property color colPrimaryHover: ColorUtils.mix(root.m3colors.m3primary, root.m3colors.m3onPrimary, 0.9)
        readonly property color colPrimaryActive: ColorUtils.mix(root.m3colors.m3primary, root.m3colors.m3onPrimary, 0.8)
        readonly property color colOnPrimary: root.m3colors.m3onPrimary
        
        // Containers (softer, more elegant)
        readonly property color colPrimaryContainer: ColorUtils.transparentize(root.m3colors.m3primaryContainer, 0.2)
        readonly property color colPrimaryContainerHover: root.m3colors.m3primaryContainer
        readonly property color colPrimaryContainerActive: ColorUtils.mix(root.m3colors.m3primaryContainer, root.m3colors.m3onPrimaryContainer, 0.85)
        readonly property color colOnPrimaryContainer: root.m3colors.m3onPrimaryContainer
        
        readonly property color colSecondary: root.m3colors.m3secondary
        readonly property color colSecondaryContainer: ColorUtils.transparentize(root.m3colors.m3secondaryContainer, 0.3)
        readonly property color colOnSecondaryContainer: root.m3colors.m3onSecondaryContainer
        
        readonly property color colTertiary: root.m3colors.m3tertiary
        
        // ═══════════════════════════════════════════════════════════════
        // SELECTION (subtle, elegant highlighting)
        // ═══════════════════════════════════════════════════════════════
        readonly property color colSelection: ColorUtils.transparentize(root.m3colors.m3primaryContainer, 0.15)
        readonly property color colSelectionHover: root.m3colors.m3primaryContainer
        readonly property color colOnSelection: root.m3colors.m3onPrimaryContainer
        
        // ═══════════════════════════════════════════════════════════════
        // SEMANTIC COLORS (softer variants)
        // ═══════════════════════════════════════════════════════════════
        readonly property color colSuccess: root.m3colors.m3success
        readonly property color colOnSuccess: root.m3colors.m3onSuccess
        readonly property color colSuccessContainer: ColorUtils.transparentize(root.m3colors.m3successContainer, 0.3)
        
        readonly property color colError: root.m3colors.m3error
        readonly property color colOnError: root.m3colors.m3onError
        readonly property color colErrorContainer: ColorUtils.transparentize(root.m3colors.m3errorContainer, 0.3)
        
        readonly property color colWarning: root.m3colors.m3tertiary
        readonly property color colInfo: root.m3colors.m3secondary
        
        // ═══════════════════════════════════════════════════════════════
        // COMPONENT ALIASES
        // ═══════════════════════════════════════════════════════════════
        readonly property color colSurface: colLayer2
        readonly property color colSurfaceHover: colLayer2Hover
        readonly property color colPopupSurface: colLayer3
        readonly property color colOverlay: colLayer1
        readonly property color colTooltip: colLayer3
        readonly property color colTooltipBorder: colBorder
        readonly property color colDialog: colLayer2
        readonly property color colDialogBorder: colBorder
        
        // Input fields
        readonly property color colInput: colLayer1
        readonly property color colInputBorder: colBorderMuted
        readonly property color colInputBorderFocus: colBorderFocus
        readonly property color colInputPlaceholder: colTextMuted
        
        // Scrollbar (very subtle)
        readonly property color colScrollbar: "transparent"
        readonly property color colScrollbarThumb: ColorUtils.transparentize(root.m3colors.m3outline, 0.6)
        readonly property color colScrollbarThumbHover: ColorUtils.transparentize(root.m3colors.m3outline, 0.4)
        
        // ═══════════════════════════════════════════════════════════════
        // ROUNDING (refined, slightly larger for elegance)
        // ═══════════════════════════════════════════════════════════════
        readonly property int roundingSmall: 6
        readonly property int roundingNormal: 8
        readonly property int roundingLarge: 12
    }

    sizes: QtObject {
        property real spacingSmall: 8
        property real spacingMedium: 12
        property real spacingLarge: 16
        property real baseBarHeight: 40
        property real barHeight: (((Config.options?.bar?.cornerStyle ?? 0) === 1) || ((Config.options?.bar?.cornerStyle ?? 0) === 3)) ? 
            (baseBarHeight + root.sizes.hyprlandGapsOut * 2) : baseBarHeight
        property real barCenterSideModuleWidth: Config.options?.bar.verbose ? 360 : 140
        property real barCenterSideModuleWidthShortened: 280
        property real barCenterSideModuleWidthHellaShortened: 190
        property real barShortenScreenWidthThreshold: 1200 // Shorten if screen width is at most this value
        property real barHellaShortenScreenWidthThreshold: 1000 // Shorten even more...
        property real elevationMargin: 10
        property real fabShadowRadius: 5
        property real fabHoveredShadowRadius: 7
        property real hyprlandGapsOut: 5
        property real mediaControlsWidth: 440
        property real mediaControlsHeight: 160
        property real notificationPopupWidth: 410
        property real osdWidth: 180
        property real searchWidthCollapsed: 210
        property real searchWidth: 360
        property real sidebarWidth: 460
        property real sidebarWidthExtended: 750
        property real baseVerticalBarWidth: 46
        property real verticalBarWidth: (((Config.options?.bar?.cornerStyle ?? 0) === 1) || ((Config.options?.bar?.cornerStyle ?? 0) === 3)) ? 
            (baseVerticalBarWidth + root.sizes.hyprlandGapsOut * 2) : baseVerticalBarWidth
        property real wallpaperSelectorWidth: 1200
        property real wallpaperSelectorHeight: 690
        property real wallpaperSelectorItemMargins: 8
        property real wallpaperSelectorItemPadding: 6
    }

    syntaxHighlightingTheme: root.m3colors.darkmode ? "Monokai" : "ayu Light"
}
