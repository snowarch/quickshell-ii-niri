import QtQuick
import Quickshell
import qs.modules.common
import qs.services
pragma Singleton

Singleton {
    id: root

    readonly property string currentTheme: Config.options?.appearance?.theme ?? "auto"
    readonly property bool isAutoTheme: currentTheme === "auto"

    onCurrentThemeChanged: {
        if (Config.ready) {
            console.log("[ThemeService] currentTheme changed to:", currentTheme, "- applying");
            Qt.callLater(applyCurrentTheme);
        }
    }

    function setTheme(themeId) {
        console.log("[ThemeService] setTheme called with:", themeId);
        Config.options.appearance.theme = themeId;
        console.log("[ThemeService] Config updated, now applying theme");
        if (themeId === "auto") {
            console.log("[ThemeService] Auto theme, regenerating from wallpaper");
            // Force regeneration of colors from wallpaper
            Quickshell.execDetached(["bash", "-c", `${Directories.wallpaperSwitchScriptPath} --noswitch`]);
        } else {
            console.log("[ThemeService] Manual theme, calling ThemePresets.applyPreset");
            ThemePresets.applyPreset(themeId);
        }
        console.log("[ThemeService] setTheme completed");
    }

    function applyCurrentTheme() {
        console.log("[ThemeService] applyCurrentTheme called, currentTheme:", currentTheme, "isAutoTheme:", isAutoTheme);
        if (isAutoTheme) {
            console.log("[ThemeService] Delegating to MaterialThemeLoader");
            MaterialThemeLoader.reapplyTheme();
        } else {
            console.log("[ThemeService] Applying manual theme:", currentTheme);
            ThemePresets.applyPreset(currentTheme);
        }
    }
}
