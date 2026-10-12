import Quickshell
pragma Singleton

Singleton {
    id: root

    function shutdown() {
        Quickshell.execDetached(["systemctl", "poweroff"]);
    }

    function reboot() {
        Quickshell.execDetached(["systemctl", "reboot"]);
    }

    function lock() {
        Quickshell.execDetached(["hyprlock"]);
    }

    function logout() {
        const sessionId = Quickshell.env("XDG_SESSION_ID");
        if (!sessionId)
            return ;

        Quickshell.execDetached(["loginctl", "terminate-session", sessionId]);
    }

    function sleep() {
        Quickshell.execDetached(["systemctl", "suspend"]);
    }

}
