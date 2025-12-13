pragma Singleton
import Quickshell
import qs.services
import qs.modules.common

Singleton {
    id: root

    function closeAllWindows() {
        // Sólo tiene sentido en sesiones Hyprland; en Niri no hay HyprlandData
        if (!CompositorService.isHyprland)
            return;

        HyprlandData.windowList.map(w => w.pid).forEach(pid => {
            Quickshell.execDetached(["kill", pid]);
        });
    }

    function lock() {
        Quickshell.execDetached(["qs", "-c", "ii", "ipc", "call", "lock", "activate"]);
    }

    function suspend() {
        if (Config.options?.idle?.lockBeforeSleep !== false) {
            lock()
            Quickshell.execDetached(["bash", "-c", "sleep 0.5 && systemctl suspend -i"])
        } else {
            Quickshell.execDetached(["systemctl", "suspend", "-i"])
        }
    }

    function logout() {
        if (CompositorService.isNiri) {
            NiriService.quit();
            return;
        }

        closeAllWindows();
        Quickshell.execDetached(["pkill", "-i", "Hyprland"]);
    }

    function launchTaskManager() {
        const cmd = Config.options?.apps?.taskManager ?? "missioncenter"
        Quickshell.execDetached(["fish", "-c", cmd])
    }

    function hibernate() {
        lock();
        Quickshell.execDetached(["bash", "-c", `sleep 0.5 && (systemctl hibernate || loginctl hibernate)`]);
    }

    function poweroff() {
        closeAllWindows();
        Quickshell.execDetached(["bash", "-c", `systemctl poweroff || loginctl poweroff`]);
    }

    function reboot() {
        closeAllWindows();
        Quickshell.execDetached(["bash", "-c", `reboot || loginctl reboot`]);
    }

    function rebootToFirmware() {
        closeAllWindows();
        Quickshell.execDetached(["bash", "-c", `systemctl reboot --firmware-setup || loginctl reboot --firmware-setup`]);
    }
}
