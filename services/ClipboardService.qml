pragma Singleton

import QtQuick
import QtQml
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var entries: []
    property bool loading: false
    property string error: ""

    function refresh() {
        loading = true
        error = ""
        listProcess.running = true
    }

    function copy(id) {
        if (!/^\d+$/.test(String(id)))
            return

        Quickshell.execDetached([
            "sh", "-c",
            "cliphist decode " + String(id) + " | wl-copy"
        ])
    }

    function remove(id) {
        if (!/^\d+$/.test(String(id)))
            return

        Quickshell.execDetached([
            "cliphist", "delete", String(id)
        ])

        refreshTimer.restart()
    }

    Process {
        id: listProcess

        command: ["cliphist", "list"]

        stdout: StdioCollector {
            id: listOutput
        }

        stderr: StdioCollector {
            id: listError
        }

        onExited: (exitCode, exitStatus) => {
            root.loading = false

            if (exitCode !== 0) {
                root.error = "Failed to load clipboard history"
                root.entries = []
                return
            }

            const lines = listOutput.text.split("\n")
            const result = []

            for (const line of lines) {
                if (!line.trim())
                    continue

                const separator = line.indexOf("\t")

                if (separator < 0)
                    continue

                const id = line.substring(0, separator).trim()
                const content = line.substring(separator + 1)

                if (!/^\d+$/.test(id))
                    continue

                result.push({
                    id: id,
                    text: content.replace(/\\n/g, "\n")
                })
            }

            root.entries = result
        }
    }

    Timer {
        id: refreshTimer
        interval: 250
        onTriggered: root.refresh()
    }

    Component.onCompleted: refresh()
}