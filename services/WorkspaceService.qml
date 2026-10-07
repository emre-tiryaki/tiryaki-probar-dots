pragma Singleton

import Quickshell
import Quickshell.Hyprland

Singleton {

    readonly property int activeWorkspace:
        Hyprland.focusedWorkspace?.id ?? 1

    function isActive(id) {
        return activeWorkspace === id
    }
}