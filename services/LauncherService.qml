pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool active: false

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            root.active = !root.active;
        }

        function open(): void {
            root.active = true;
        }

        function close(): void {
            root.active = false;
        }
    }
}