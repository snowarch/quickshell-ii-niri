pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.modules.common

Singleton {
    id: root

    // Built-in style presets
    readonly property var presets: [
        {
            id: "default",
            name: "Default",
            icon: "tune",
            description: "Balanced defaults",
            typography: {
                sizeScale: 1.0,
                variableAxes: { wght: 300, wdth: 105, grad: 175 }
            }
        },
        {
            id: "compact",
            name: "Compact",
            icon: "density_small",
            description: "Smaller text, tighter spacing",
            typography: {
                sizeScale: 0.9,
                variableAxes: { wght: 350, wdth: 100, grad: 150 }
            }
        },
        {
            id: "spacious",
            name: "Spacious",
            icon: "density_large",
            description: "Larger text, more breathing room",
            typography: {
                sizeScale: 1.15,
                variableAxes: { wght: 280, wdth: 110, grad: 175 }
            }
        },
        {
            id: "sharp",
            name: "Sharp",
            icon: "square",
            description: "Crisp, high contrast text",
            typography: {
                sizeScale: 1.0,
                variableAxes: { wght: 400, wdth: 100, grad: 200 }
            }
        },
        {
            id: "soft",
            name: "Soft",
            icon: "blur_on",
            description: "Light, airy typography",
            typography: {
                sizeScale: 1.0,
                variableAxes: { wght: 250, wdth: 108, grad: 100 }
            }
        },
        {
            id: "minimal",
            name: "Minimal",
            icon: "remove",
            description: "Clean, understated look",
            typography: {
                sizeScale: 0.95,
                variableAxes: { wght: 300, wdth: 100, grad: 150 }
            }
        }
    ]

    function getPreset(id) {
        for (let i = 0; i < presets.length; i++) {
            if (presets[i].id === id) return presets[i]
        }
        return presets[0]
    }

    function applyPreset(presetId) {
        let preset = getPreset(presetId)
        if (!preset) return false

        // Apply typography settings
        if (preset.typography) {
            if (preset.typography.sizeScale !== undefined)
                Config.setNestedValue('appearance.typography.sizeScale', preset.typography.sizeScale)
            if (preset.typography.variableAxes) {
                if (preset.typography.variableAxes.wght !== undefined)
                    Config.setNestedValue('appearance.typography.variableAxes.wght', preset.typography.variableAxes.wght)
                if (preset.typography.variableAxes.wdth !== undefined)
                    Config.setNestedValue('appearance.typography.variableAxes.wdth', preset.typography.variableAxes.wdth)
                if (preset.typography.variableAxes.grad !== undefined)
                    Config.setNestedValue('appearance.typography.variableAxes.grad', preset.typography.variableAxes.grad)
            }
        }
        return true
    }

    function resetTypographyToDefaults() {
        Config.setNestedValue('appearance.typography.mainFont', "Roboto Flex")
        Config.setNestedValue('appearance.typography.titleFont', "Gabarito")
        Config.setNestedValue('appearance.typography.monospaceFont', "JetBrains Mono NF")
        Config.setNestedValue('appearance.typography.sizeScale', 1.0)
        Config.setNestedValue('appearance.typography.variableAxes.wght', 300)
        Config.setNestedValue('appearance.typography.variableAxes.wdth', 105)
        Config.setNestedValue('appearance.typography.variableAxes.grad', 175)
    }
}
