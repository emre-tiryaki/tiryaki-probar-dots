import QtQuick
import "."

import "../../common"
import "../../services"

Column {
    id: root

    signal openPage(string id)

    spacing: 10

    Grid {
        id: tileGrid

        width: parent.width
        columns: 2
        columnSpacing: 8
        rowSpacing: 8

        ControlTile {
            icon: NetworkService.connected ? "󰤨" : "󰤭"
            title: "Wi-Fi"
            subtitle: NetworkService.connecting ? "Connecting..." : NetworkService.connected ? NetworkService.currentNetwork : "Offline"
            active: NetworkService.connected
            onClicked: root.openPage("wifi")
        }

        ControlTile {
            icon: "󰂯"
            title: "Bluetooth"
            subtitle: BluetoothService.connectedCount > 0 ? BluetoothService.connectedCount + " connected" : BluetoothService.enabled ? "Enabled" : "Disabled"
            active: BluetoothService.enabled
            onClicked: root.openPage("bluetooth")
        }

        ControlTile {
            icon: "󰀝"
            title: "Airplane"
            subtitle: "Flight mode"
        }

        ControlTile {
            icon: BatteryService.icon
            title: "Battery"
            subtitle: BatteryService.available ? BatteryService.percentage + "%" : "Unavailable"
            active: BatteryService.charging
        }
    }

    // Full-width pills (span both grid columns). Add new wide tiles here.
    Column {
        width: tileGrid.implicitWidth
        spacing: 8

        ControlTile {
            width: parent.width
            icon: VpnService.connected ? "󰦝" : "󰦞"
            title: "VPN"
            subtitle: VpnService.connecting ? "Connecting..." : VpnService.connected ? "Cloudflare WARP" : VpnService.available ? "Disconnected" : "WARP unavailable"
            active: VpnService.connected
            onClicked: VpnService.toggle()
        }
    }

    VolumeCard {
        width: parent.width
        icon: SoundService.muted ? "󰖁" : "󰕾"
        title: "Audio"
        value: SoundService.volume
        maxValue: SoundService.maxVolume
        muted: SoundService.muted
        onMoved: v => SoundService.setVolume(v)
        onClicked: root.openPage("audio")
    }

    VolumeCard {
        width: parent.width
        icon: BrightnessService.icon
        title: "Brightness"
        value: BrightnessService.brightness
        onMoved: v => BrightnessService.setBrightness(v)
        onClicked: root.openPage("brightness")
    }

    Separator {}

    NotificationList {
        width: parent.width
    }
}
