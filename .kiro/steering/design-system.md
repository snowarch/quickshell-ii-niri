---
inclusion: always
---

# Design System

## Panel Families

| Family | Style | Color System | Icons |
|--------|-------|--------------|-------|
| `ii` | Material Design | `Appearance.colors.*` | MaterialSymbol |
| `waffle` | Windows 11 | `Looks.colors.*` | FluentIcon |

## Color Tokens

```qml
// ii family (Material)
Appearance.colors.colLayer0        // Deepest background
Appearance.colors.colLayer1        // Card/panel background
Appearance.colors.colLayer2        // Elevated surfaces
Appearance.colors.colPrimary       // Primary accent
Appearance.colors.colOnPrimary     // Text on primary

// waffle family (Fluent)
Looks.colors.bg0                   // Background
Looks.colors.bg2Base               // Surface
Looks.colors.accent                // Accent
Looks.colors.fg                    // Foreground text
Looks.colors.subfg                 // Secondary text
```

## Typography

```qml
Appearance.font.family.main        // "Noto Sans"
Appearance.font.family.monospace   // Code font
Appearance.font.pixelSize.small    // 12px
Appearance.font.pixelSize.normal   // 14px
Appearance.font.pixelSize.large    // 16px
Appearance.font.pixelSize.title    // 20px
```

## Spacing & Rounding

```qml
Appearance.rounding.small          // 4px
Appearance.rounding.normal         // 8px
Appearance.rounding.large          // 12px
// Note: Appearance.rounding.full does NOT exist

Looks.radius.*                     // none, small, medium, large, xLarge (no 'full')
```

## Animations

```qml
// ii family
Appearance.animation.elementMove.duration      // 200ms
Appearance.animation.elementMoveFast.duration  // 100ms
Appearance.animation.elementMove.easing        // Easing.OutCubic

// waffle family - Fluent Design inspired
Looks.transition.enabled                       // Respects GameMode
Looks.transition.duration.fast                 // 100ms
Looks.transition.duration.normal               // 150ms
Looks.transition.duration.medium               // 200ms
Looks.transition.duration.slow                 // 300ms
Looks.transition.duration.panel                // 280ms

// Easing curves (Fluent Design)
Looks.transition.easing.bezierCurve.decelerate // Fast start, smooth stop (entries)
Looks.transition.easing.bezierCurve.accelerate // Smooth start, fast end (exits)
Looks.transition.easing.bezierCurve.standard   // Balanced movement
Looks.transition.easing.bezierCurve.spring     // Slight overshoot

// Transition components
Looks.transition.enter                         // Panel/item entry
Looks.transition.exit                          // Panel/item exit
Looks.transition.move                          // Position changes
Looks.transition.color                         // Color transitions
Looks.transition.opacity                       // Fade transitions
Looks.transition.panelSlide                    // Panel slide animations
Looks.transition.panelScale                    // Panel scale with spring
Looks.transition.itemEnter                     // List item entry (OutBack)
Looks.transition.hover                         // Hover state changes
Looks.transition.press                         // Press/active states

// Stagger helper for list animations
Looks.transition.staggerDelay(index, baseDelay) // Returns delay in ms
```

## Icons

```qml
// Material (ii)
MaterialSymbol { iconName: "settings" }

// Fluent (waffle)
FluentIcon { iconName: "settings" }
// Note: FluentIcon has NO horizontalAlignment - use anchors.centerIn

// System icons
Image { source: Quickshell.iconPath("firefox") }
```

## Required Patterns

Never hardcode colors:
```qml
// ❌ Rectangle { color: "#1a1a1a" }
// ✅ Rectangle { color: Appearance.colors.colLayer1 }
```

Use anchors for layout:
```qml
// ❌ x: parent.width - width - 10
// ✅ anchors.right: parent.right; anchors.rightMargin: 10
```

## File Locations

| Purpose | ii family | waffle family |
|---------|-----------|---------------|
| Widgets | `modules/common/widgets/` | `modules/waffle/looks/` |
| Bar | `modules/bar/` | `modules/waffle/bar/` |
| Settings | `modules/settings/` | `modules/waffle/settings/` |
| Icons | `assets/icons/fluent/` | `assets/icons/fluent/` |
