pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Io

Singleton {
    id: root

    readonly property var battery:
        UPower.displayDevice

    readonly property bool available:
        battery !== null &&
        battery.isPresent

    readonly property int percentage:
        available
            ? Math.round(battery.percentage * 100)
            : 0

    readonly property var state:
        available
            ? battery.state
            : null

    readonly property bool charging:
        available &&
        battery.state === UPowerDeviceState.Charging

    readonly property bool fullyCharged:
        available &&
        battery.state === UPowerDeviceState.FullyCharged

    readonly property bool discharging:
        available &&
        battery.state === UPowerDeviceState.Discharging

    readonly property string icon: {
        if (!available)
            return "󰂑"
        if (charging)
            return "󰂄"
        if (percentage >= 80)
            return "󰁹"
        if (percentage >= 50)
            return "󰂀"
        if (percentage >= 30)
            return "󰁾"
        return "󰁺"
    }

    readonly property string statusText: {
        if (!available)
            return "Unavailable"

        if (charging)
            return "Charging"

        if (fullyCharged)
            return "Fully charged"

        if (discharging)
            return "Discharging"

        return "Unknown"
    }

    // ------------------------------------------------------------
    // Battery health
    // ------------------------------------------------------------

    property real energyFull: 0
    property real energyFullDesign: 0

    readonly property int health:
        energyFullDesign > 0
            ? Math.round(
                (energyFull / energyFullDesign) * 100
            )
            : 0

    Process {
        id: energyFullProcess

        command: [
            "bash",
            "-c",
            "cat /sys/class/power_supply/BAT*/energy_full 2>/dev/null | head -n1"
        ]

        stdout: StdioCollector {}

        onExited: {
            var value = parseFloat(stdout.text.trim())

            if (!isNaN(value))
                root.energyFull = value
        }
    }

    Process {
        id: energyFullDesignProcess

        command: [
            "bash",
            "-c",
            "cat /sys/class/power_supply/BAT*/energy_full_design 2>/dev/null | head -n1"
        ]

        stdout: StdioCollector {}

        onExited: {
            var value = parseFloat(stdout.text.trim())

            if (!isNaN(value))
                root.energyFullDesign = value
        }
    }

    Component.onCompleted: {
        energyFullProcess.running = true
        energyFullDesignProcess.running = true
    }
}