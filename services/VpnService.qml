pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Cloudflare WARP VPN via warp-cli.
Singleton {
    id: root

    // "Connected", "Disconnected", "Connecting", ... ("" = unknown / daemon unreachable)
    property string status: ""
    property bool busy: false

    readonly property bool connected: status === "Connected"
    readonly property bool connecting: busy || status === "Connecting"
    readonly property bool available: status !== ""

    function refresh() {
        if (!statusProc.running)
            statusProc.running = true;
    }

    function connect() {
        busy = true;
        actionProc.exec(["warp-cli", "--accept-tos", "connect"]);
    }

    function disconnect() {
        busy = true;
        actionProc.exec(["warp-cli", "--accept-tos", "disconnect"]);
    }

    function toggle() {
        if (busy)
            return;
        if (connected || status === "Connecting")
            disconnect();
        else
            connect();
    }

    function parseStatus(line) {
        const m = line.match(/^Status update:\s*(\S+)/);
        if (m)
            root.status = m[1];
    }

    Process {
        id: statusProc

        command: ["warp-cli", "--accept-tos", "status"]
        running: true

        stdout: SplitParser {
            onRead: line => root.parseStatus(line)
        }

        onExited: code => {
            if (code !== 0)
                root.status = "";
        }
    }

    Process {
        id: actionProc

        onExited: {
            root.busy = false;
            root.refresh();
        }
    }

    // Live status stream; restart if the daemon drops the connection.
    Process {
        id: listenProc

        command: ["warp-cli", "--accept-tos", "-l", "status"]
        running: true

        stdout: SplitParser {
            onRead: line => root.parseStatus(line)
        }

        onExited: {
            root.refresh();
            listenRestart.restart();
        }
    }

    Timer {
        id: listenRestart

        interval: 5000
        onTriggered: listenProc.running = true
    }
}
