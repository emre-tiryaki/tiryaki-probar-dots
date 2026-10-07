import QtQuick

import "../../common"
import "../../services"

Column {
    id: root

    property var openWifiPage

    width: parent ? parent.width : 0

    spacing: 16

    // Header
    Text {
        text: "Control Center"

        color: ThemeColors.text

        font.pixelSize: 16
        font.weight: Font.DemiBold
    }

    // Quick controls
    Grid {
        id: quickGrid

        width: parent.width

        columns: 2

        columnSpacing: 8
        rowSpacing: 8

        // Wi-Fi
        ControlTile {
            width: (quickGrid.width - 8) / 2

            active: NetworkService.connected

            icon: NetworkService.connected
                ? "󰤨"
                : "󰤭"

            title: "Wi-Fi"

            subtitle: NetworkService.connected
                ? NetworkService.currentNetwork
                : "Disconnected"

            onClicked: {
                if (root.openWifiPage)
                    root.openWifiPage()
            }
        }

        // Bluetooth
        ControlTile {
            width: (quickGrid.width - 8) / 2

            active: BluetoothService.enabled

            icon: "󰂯"

            title: "Bluetooth"

            subtitle: BluetoothService.enabled
                ? BluetoothService.connectedCount + " connected"
                : "Disabled"

            onClicked: BluetoothService.toggle()
        }

        // Airplane
        ControlTile {
            width: (quickGrid.width - 8) / 2

            icon: "󰀝"

            title: "Airplane"

            subtitle: "Wi-Fi + Bluetooth"

            onClicked: {
                NetworkService.setEnabled(false)
                BluetoothService.setEnabled(false)
            }
        }

        // Battery
        ControlTile {
            width: (quickGrid.width - 8) / 2

            active: BatteryService.charging

            icon: BatteryService.charging
                ? "󰂄"
                : "󰁹"

            title: "Battery"

            subtitle: BatteryService.available
                ? BatteryService.percentage + "%"
                : "Unavailable"
        }
    }

    // Divider
    Rectangle {
        width: parent.width
        height: 1

        color: ThemeColors.border
    }

    // Audio
    Text {
        text: "Audio"

        color: ThemeColors.text

        font.pixelSize: 13
        font.weight: Font.DemiBold
    }

    // Output
    Rectangle {
        width: parent.width
        height: 82

        radius: 16

        color: ThemeColors.surface

        Row {
            anchors {
                left: parent.left
                leftMargin: 12
                verticalCenter: parent.verticalCenter
            }

            spacing: 12

            Rectangle {
                width: 42
                height: 42

                radius: 13

                color: ThemeColors.background

                Text {
                    anchors.centerIn: parent

                    text: SoundService.muted
                        ? "󰖁"
                        : "󰕾"

                    color: ThemeColors.text

                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 19
                }

                TapHandler {
                    onTapped: SoundService.toggleMute()
                }
            }

            Column {
                width: 280

                spacing: 6

                anchors.verticalCenter: parent.verticalCenter

                Row {
                    width: parent.width

                    Text {
                        text: "Output"

                        color: ThemeColors.text

                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                    }

                    Item {
                        width: parent.width - 60
                        height: 1
                    }

                    Text {
                        text: Math.round(
                            SoundService.volume * 100
                        ) + "%"

                        color: ThemeColors.textMuted

                        font.pixelSize: 10
                    }
                }

                Rectangle {
                    id: outputTrack

                    width: parent.width
                    height: 6

                    radius: 3

                    color: ThemeColors.background

                    Rectangle {
                        width: parent.width * SoundService.volume
                        height: parent.height

                        radius: height / 2

                        color: ThemeColors.accent
                    }

                    Rectangle {
                        width: 12
                        height: 12

                        radius: width / 2

                        anchors.verticalCenter: parent.verticalCenter

                        x: Math.max(
                            0,
                            Math.min(
                                parent.width - width,
                                parent.width * SoundService.volume - width / 2
                            )
                        )

                        color: ThemeColors.text

                        MouseArea {
                            anchors.fill: parent

                            onPressed: function(mouse) {
                                updateVolume(mouse.x)
                            }

                            onPositionChanged: function(mouse) {
                                if (pressed)
                                    updateVolume(mouse.x)
                            }

                            function updateVolume(mouseX) {
                                let value =
                                    (
                                        outputTrack.width *
                                        SoundService.volume +
                                        mouseX -
                                        width / 2
                                    ) / outputTrack.width

                                value = Math.max(0, Math.min(1, value))

                                SoundService.setVolume(value)
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent

                        z: -1

                        onClicked: function(mouse) {
                            let value =
                                mouse.x / outputTrack.width

                            value = Math.max(0, Math.min(1, value))

                            SoundService.setVolume(value)
                        }
                    }
                }
            }
        }
    }

    // Input
    Rectangle {
        width: parent.width
        height: 82

        radius: 16

        color: ThemeColors.surface

        Row {
            anchors {
                left: parent.left
                leftMargin: 12
                verticalCenter: parent.verticalCenter
            }

            spacing: 12

            Rectangle {
                width: 42
                height: 42

                radius: 13

                color: ThemeColors.background

                Text {
                    anchors.centerIn: parent

                    text: SoundService.microphoneMuted
                        ? "󰍭"
                        : "󰍬"

                    color: ThemeColors.text

                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 19
                }

                TapHandler {
                    onTapped: SoundService.toggleMicrophoneMute()
                }
            }

            Column {
                width: 280

                spacing: 6

                anchors.verticalCenter: parent.verticalCenter

                Row {
                    width: parent.width

                    Text {
                        text: "Input"

                        color: ThemeColors.text

                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                    }

                    Item {
                        width: parent.width - 60
                        height: 1
                    }

                    Text {
                        text: Math.round(
                            SoundService.microphoneVolume * 100
                        ) + "%"

                        color: ThemeColors.textMuted

                        font.pixelSize: 10
                    }
                }

                Rectangle {
                    id: inputTrack

                    width: parent.width
                    height: 6

                    radius: 3

                    color: ThemeColors.background

                    Rectangle {
                        width: parent.width *
                               SoundService.microphoneVolume

                        height: parent.height

                        radius: height / 2

                        color: ThemeColors.accent
                    }

                    Rectangle {
                        width: 12
                        height: 12

                        radius: width / 2

                        anchors.verticalCenter: parent.verticalCenter

                        x: Math.max(
                            0,
                            Math.min(
                                parent.width - width,
                                parent.width *
                                SoundService.microphoneVolume -
                                width / 2
                            )
                        )

                        color: ThemeColors.text

                        MouseArea {
                            anchors.fill: parent

                            onPressed: function(mouse) {
                                updateVolume(mouse.x)
                            }

                            onPositionChanged: function(mouse) {
                                if (pressed)
                                    updateVolume(mouse.x)
                            }

                            function updateVolume(mouseX) {
                                let value =
                                    (
                                        inputTrack.width *
                                        SoundService.microphoneVolume +
                                        mouseX -
                                        width / 2
                                    ) / inputTrack.width

                                value = Math.max(0, Math.min(1, value))

                                SoundService.setMicrophoneVolume(value)
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent

                        z: -1

                        onClicked: function(mouse) {
                            let value =
                                mouse.x / inputTrack.width

                            value = Math.max(0, Math.min(1, value))

                            SoundService.setMicrophoneVolume(value)
                        }
                    }
                }
            }
        }
    }
}