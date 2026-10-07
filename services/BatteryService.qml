pragma Singleton

import Quickshell
import Quickshell.Services.UPower

Singleton {

    readonly property var battery: UPower.displayDevice

    readonly property bool available: {
        return battery !== null && battery.isPresent
    }

    readonly property int percentage: {
        if (!available)
            return 0

        return Math.round(battery.percentage * 100)
    }

    readonly property var state: {
        if (!available)
            return null

        return battery.state
    }

    readonly property bool charging: {
        if (!available)
            return false

        return battery.state === UPowerDeviceState.Charging
    }

    readonly property bool fullyCharged: {
        if (!available)
            return false

        return battery.state === UPowerDeviceState.FullyCharged
    }
}