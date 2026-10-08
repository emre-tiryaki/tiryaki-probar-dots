pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string currentProfile: ""
    property var profiles: []

    property bool available: false
    property bool changing: false

    Process {
        id: profileProcess

        command: [
            "powerprofilesctl",
            "get"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const value = text.trim()

                if (value !== "") {
                    root.currentProfile = value
                    root.available = true
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim() !== "")
                    root.available = false
            }
        }
    }

    Process {
        id: profilesProcess

        command: [
            "powerprofilesctl",
            "list"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.parseProfiles(text)
            }
        }
    }

    Timer {
        id: refreshTimer

        interval: 2000

        repeat: true
        running: true

        onTriggered: {
            profileProcess.running = true
            profilesProcess.running = true
        }
    }

    function parseProfiles(output) {
        const result = []

        const lines = output.split("\n")

        for (const line of lines) {
            const match =
                line.match(
                    /^\s*(\*?)\s*(power-saver|balanced|performance)\s*:/
                )

            if (!match)
                continue

            const name = match[2]

            if (result.indexOf(name) === -1)
                result.push(name)
        }

        if (result.length === 0) {
            result.push("power-saver")
            result.push("balanced")
        }

        root.profiles = result
        root.available = true
    }

    function setProfile(profile) {
        if (!profile || root.changing)
            return

        if (profile === root.currentProfile)
            return

        root.changing = true

        Quickshell.execDetached([
            "powerprofilesctl",
            "set",
            profile
        ])

        refreshTimer.restart()

        changeTimer.restart()
    }

    Timer {
        id: changeTimer

        interval: 250

        repeat: false

        onTriggered: {
            root.changing = false

            profileProcess.running = true
            profilesProcess.running = true
        }
    }
}