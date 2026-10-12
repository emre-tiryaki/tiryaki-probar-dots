pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var monitors: []

    property string selectedMonitor: ""

    property bool ready: false
    property bool loading: false
    property bool changing: false

    property string errorMessage: ""

    property string pendingRule: ""

    Process {
        id: monitorProcess

        command: [
            "hyprctl",
            "-j",
            "monitors"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.parseMonitors(text)
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                const message = text.trim()

                if (message !== "") {
                    root.errorMessage = message
                    root.loading = false
                }
            }
        }
    }

    Process {
        id: changeProcess

        command: [
            "hyprctl",
            "keyword",
            "monitor",
            root.pendingRule
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const output = text.trim()

                if (
                    output !== "" &&
                    output.toLowerCase() !== "ok"
                ) {
                    root.errorMessage = output
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                const error = text.trim()

                if (error !== "") {
                    root.errorMessage = error
                }
            }
        }

        onExited: {
            root.changing = false

            if (exitCode !== 0) {
                if (root.errorMessage === "") {
                    root.errorMessage =
                        "Hyprland rejected the monitor change."
                }

                return
            }

            changeRefreshTimer.restart()
        }
    }

    Timer {
        id: changeRefreshTimer

        interval: 350
        repeat: false

        onTriggered: {
            root.refresh()
        }
    }

    Timer {
        id: syncTimer

        interval: 3000
        repeat: true
        running: root.ready

        onTriggered: {
            root.refresh()
        }
    }

    Component.onCompleted: {
        root.refresh()
    }

    function refresh() {
        if (monitorProcess.running)
            return

        root.loading = true
        monitorProcess.running = true
    }

    function parseMonitors(output) {
        try {
            const data = JSON.parse(output)

            if (!Array.isArray(data)) {
                root.errorMessage =
                    "Invalid monitor data."

                root.loading = false
                return
            }

            const result = []

            for (const monitor of data) {
                result.push({
                    id:
                        Number(
                            monitor.id || 0
                        ),

                    name:
                        String(
                            monitor.name || ""
                        ),

                    description:
                        String(
                            monitor.description || ""
                        ),

                    make:
                        String(
                            monitor.make || ""
                        ),

                    model:
                        String(
                            monitor.model || ""
                        ),

                    serial:
                        String(
                            monitor.serial || ""
                        ),

                    x:
                        Number(
                            monitor.x || 0
                        ),

                    y:
                        Number(
                            monitor.y || 0
                        ),

                    width:
                        Number(
                            monitor.width || 0
                        ),

                    height:
                        Number(
                            monitor.height || 0
                        ),

                    scale:
                        Number(
                            monitor.scale || 1
                        ),

                    refreshRate:
                        Number(
                            monitor.refreshRate || 0
                        ),

                    transform:
                        Number(
                            monitor.transform || 0
                        ),

                    focused:
                        Boolean(
                            monitor.focused
                        ),

                    disabled:
                        Boolean(
                            monitor.disabled
                        ),

                    dpmsStatus:
                        Boolean(
                            monitor.dpmsStatus
                        ),

                    mirrorOf:
                        monitor.mirrorOf &&
                        monitor.mirrorOf !== "none"
                            ? String(
                                monitor.mirrorOf
                            )
                            : "",

                    availableModes:
                        Array.isArray(
                            monitor.availableModes
                        )
                            ? monitor.availableModes.slice()
                            : [],

                    activeWorkspace:
                        monitor.activeWorkspace
                            ? String(
                                monitor.activeWorkspace.name ||
                                monitor.activeWorkspace.id ||
                                ""
                            )
                            : ""
                })
            }

            root.monitors = result

            if (
                root.selectedMonitor === "" ||
                root.findMonitor(
                    root.selectedMonitor
                ) === null
            ) {
                let selected = null

                for (const monitor of result) {
                    if (monitor.focused) {
                        selected = monitor
                        break
                    }
                }

                if (
                    selected === null &&
                    result.length > 0
                ) {
                    selected = result[0]
                }

                root.selectedMonitor =
                    selected !== null
                        ? selected.name
                        : ""
            }

            root.ready =
                result.length > 0

            root.loading = false

            /*
             * Only clear the error after a successful
             * monitor refresh.
             */
            if (!root.changing)
                root.errorMessage = ""

        } catch (error) {
            root.errorMessage =
                "Could not parse monitor information."

            root.loading = false
        }
    }

    function findMonitor(name) {
        if (!name)
            return null

        for (const monitor of root.monitors) {
            if (monitor.name === name)
                return monitor
        }

        return null
    }

    function formatResolution(monitor) {
        if (!monitor)
            return "—"

        return (
            monitor.width +
            " × " +
            monitor.height
        )
    }

    function formatRefreshRate(value) {
        if (!value || value <= 0)
            return "—"

        return (
            Number(value).toFixed(0) +
            " Hz"
        )
    }

    function formatScale(value) {
        if (!value)
            return "1×"

        const number = Number(value)

        if (
            Math.abs(
                number -
                Math.round(number)
            ) < 0.001
        ) {
            return (
                Math.round(number) +
                "×"
            )
        }

        return (
            number.toFixed(2) +
            "×"
        )
    }

    function formatPosition(monitor) {
        if (!monitor)
            return "—"

        return (
            monitor.x +
            " × " +
            monitor.y
        )
    }

    function isMirrored(monitor) {
        return (
            monitor !== null &&
            monitor.mirrorOf !== ""
        )
    }

    function mirrorTarget(monitor) {
        if (!monitor)
            return null

        return findMonitor(
            monitor.mirrorOf
        )
    }

    function modeFor(monitor) {
        if (!monitor)
            return "preferred"

        if (
            monitor.refreshRate <= 0
        ) {
            return (
                monitor.width +
                "x" +
                monitor.height
            )
        }

        return (
            monitor.width +
            "x" +
            monitor.height +
            "@" +
            Number(
                monitor.refreshRate
            ).toFixed(2)
        )
    }

    function buildRule(
        monitor,
        mirrorTargetName
    ) {
        if (!monitor)
            return ""

        const parts = [
            monitor.name,
            modeFor(monitor),
            monitor.x +
                "x" +
                monitor.y,
            String(
                monitor.scale
            )
        ]

        if (
            mirrorTargetName &&
            mirrorTargetName !== ""
        ) {
            parts.push("mirror")
            parts.push(
                mirrorTargetName
            )
        }

        return parts.join(",")
    }

    function applyRule(
        monitor,
        mirrorTargetName
    ) {
        if (!monitor)
            return false

        if (changeProcess.running)
            return false

        const rule =
            buildRule(
                monitor,
                mirrorTargetName
            )

        if (rule === "")
            return false

        root.pendingRule = rule
        root.errorMessage = ""
        root.changing = true

        changeProcess.running = true

        return true
    }

    function setExtended(monitor) {
        if (!monitor)
            return false

        /*
         * No mirror argument means the monitor
         * becomes an independent display again.
         */
        return applyRule(
            monitor,
            ""
        )
    }

    function setMirror(
        monitor,
        target
    ) {
        if (!monitor || !target)
            return false

        if (
            monitor.name ===
            target.name
        ) {
            return false
        }

        return applyRule(
            monitor,
            target.name
        )
    }
}