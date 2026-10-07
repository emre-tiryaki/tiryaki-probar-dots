pragma Singleton

import Quickshell
import Quickshell.Bluetooth

Singleton {

    readonly property var adapters: Bluetooth.adapters.values

    readonly property var adapter: {
        if (adapters.length === 0)
            return null

        return adapters[0]
    }

    readonly property bool enabled: {
        return adapter?.enabled ?? false
    }

    readonly property var devices: {
        if (!adapter)
            return []

        return adapter.devices.values
    }

    readonly property int connectedCount: {
        let count = 0

        for (const device of devices) {
            if (device.connected)
                count++
        }

        return count
    }

    function setEnabled(enabled) {
        if (!adapter)
            return

        adapter.enabled = enabled
    }

    function toggle() {
        if (!adapter)
            return

        adapter.enabled = !adapter.enabled
    }

    function connect(device) {
        if (!device)
            return

        device.connected = true
    }

    function disconnect(device) {
        if (!device)
            return

        device.connected = false
    }

    function pair(device) {
        if (!device)
            return

        device.pair()
    }

    function forget(device) {
        if (!device)
            return

        if (device.connected)
            device.connected = false

        device.forget()
    }

    function trust(device, trusted) {
        if (!device)
            return

        device.trusted = trusted
    }
}