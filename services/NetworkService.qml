pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Networking
import Quickshell.Io

Singleton {
    id: root

    property bool connecting: false
    property string connectingNetwork: ""

    readonly property var wifiDevice: {
        for (const device of Networking.devices.values) {
            if (device.type === DeviceType.Wifi)
                return device
        }

        return null
    }

    readonly property string currentNetwork: {
        if (!wifiDevice)
            return ""

        for (const network of wifiDevice.networks.values) {
            if (network.connected)
                return network.name
        }

        return ""
    }

    readonly property bool connected:
        currentNetwork !== ""

    readonly property bool enabled:
        wifiState.stdout.text.trim() === "enabled"

    readonly property string statusNetwork: {
        if (connecting && connectingNetwork !== "")
            return connectingNetwork

        return currentNetwork
    }

    readonly property var networks: {
        if (!wifiDevice)
            return []

        return wifiDevice.networks.values
    }

    Process {
        id: wifiState

        command: [
            "nmcli",
            "radio",
            "wifi"
        ]

        stdout: StdioCollector {}

        Component.onCompleted: {
            running = true
        }
    }

    Process {
        id: wifiToggle

        command: []

        onExited: {
            wifiState.running = true
        }
    }

    onCurrentNetworkChanged: {
        if (currentNetwork !== "") {
            connecting = false
            connectingNetwork = ""
        }
    }

    function refresh() {
        if (!wifiState.running)
            wifiState.running = true
    }

    function setEnabled(value) {
        wifiToggle.exec([
            "nmcli",
            "radio",
            "wifi",
            value ? "on" : "off"
        ])

        refresh()
    }

    function toggle() {
        setEnabled(!root.enabled)
    }

    function scan() {
        if (!wifiDevice)
            return

        wifiDevice.scannerEnabled = true
    }

    function connect(network) {
        if (!network)
            return

        connecting = true
        connectingNetwork = network.name

        network.connect()
    }

    function connectWithPassword(network, password) {
        if (!network || password === "")
            return

        connecting = true
        connectingNetwork = network.name

        network.connectWithPsk(password)
    }

    function disconnect(network) {
        if (!network)
            return

        network.disconnect()
    }
}