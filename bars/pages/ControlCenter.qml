import QtQuick

import "../../common"
import "../../services"

Column {
    id: root

    property var openWifiPage
    property var openBluetoothPage
    property var openAudioPage
    property var openInputPage

    width: parent ? parent.width : 0
    spacing: 10

    Grid {
        width: parent.width

        columns: 2

        columnSpacing: 8
        rowSpacing: 8

        ControlTile {
            width: 180
            height: 64

            icon: NetworkService.connected ? "󰤨" : "󰤭"
            title: "Wi-Fi"
            subtitle: NetworkService.connecting ? "Connecting..." : NetworkService.connected ? NetworkService.currentNetwork : "Offline"
            active: NetworkService.connected

            onClicked: {
                if (root.openWifiPage)
                    root.openWifiPage()
            }
        }

        ControlTile {
            width: 180
            height: 64

            icon: "󰂯"
            title: "Bluetooth"
            subtitle: BluetoothService.connectedCount > 0 ? BluetoothService.connectedCount + " connected" : BluetoothService.enabled ? "Enabled" : "Disabled"
            active: BluetoothService.enabled

            onClicked: {
                if (root.openBluetoothPage)
                    root.openBluetoothPage()
            }
        }

        ControlTile {
            width: 180
            height: 64

            icon: "󰀝"
            title: "Airplane"
            subtitle: "Flight mode"
            active: false

            onClicked: {}
        }

        ControlTile {
            width: 180
            height: 64

            icon: {
                if (!BatteryService.available)
                    return "󰂑"
                if (BatteryService.charging)
                    return "󰂄"
                if (BatteryService.percentage >= 80)
                    return "󰁹"
                if (BatteryService.percentage >= 50)
                    return "󰂀"
                if (BatteryService.percentage >= 30)
                    return "󰁾"
                return "󰁺"
            }

            title: "Battery"
            subtitle: BatteryService.available ? BatteryService.percentage + "%" : "Unavailable"
            active: BatteryService.charging

            onClicked: {}
        }
    }

    // Audio
    Rectangle {
        id: audioCard

        width: parent.width
        height: 78
        radius: 15
        color: ThemeColors.surface
        border.width: 1
        border.color: audioHover.hovered ? ThemeColors.textMuted : ThemeColors.border

        Behavior on border.color { ColorAnimation { duration: 120 } }

        HoverHandler { id: audioHover }

        Column {
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                leftMargin: 14
                rightMargin: 14
                topMargin: 11
            }

            spacing: 9

            Row {
                width: parent.width
                height: 22
                spacing: 8

                Text {
                    text: SoundService.muted ? "󰖁" : "󰕾"
                    color: SoundService.muted ? ThemeColors.textMuted : ThemeColors.text
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 19
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Audio"
                    color: ThemeColors.text
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item {
                    width: parent.width - 100
                    height: 1
                }

                Text {
                    text: Math.round(SoundService.volume * 100) + "%"
                    color: ThemeColors.textMuted
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                width: parent.width
                height: 5
                radius: height / 2
                color: ThemeColors.border

                Rectangle {
                    width: parent.width * Math.max(0, Math.min(1, SoundService.volume))
                    height: parent.height
                    radius: height / 2
                    color: SoundService.muted ? ThemeColors.textMuted : ThemeColors.accent

                    Behavior on width {
                        NumberAnimation { duration: 100 }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onPressed: function(mouse) { SoundService.setVolume(mouse.x / width) }
                    onPositionChanged: function(mouse) {
                        if (!pressed) return
                        SoundService.setVolume(mouse.x / width)
                    }
                }
            }
        }

        MouseArea {
            anchors {
                left: parent.left
                top: parent.top
                right: parent.right
            }

            height: 32

            onClicked: {
                if (root.openAudioPage)
                    root.openAudioPage()
            }
        }
    }

    // Input
    Rectangle {
        id: inputCard

        width: parent.width
        height: 78
        radius: 15
        color: ThemeColors.surface
        border.width: 1
        border.color: inputHover.hovered ? ThemeColors.textMuted : ThemeColors.border

        Behavior on border.color { ColorAnimation { duration: 120 } }

        HoverHandler { id: inputHover }

        Column {
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                leftMargin: 14
                rightMargin: 14
                topMargin: 11
            }

            spacing: 9

            Row {
                width: parent.width
                height: 22
                spacing: 8

                Text {
                    text: SoundService.microphoneMuted ? "󰍭" : "󰍬"
                    color: SoundService.microphoneMuted ? ThemeColors.textMuted : ThemeColors.text
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 19
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Input"
                    color: ThemeColors.text
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item {
                    width: parent.width - 100
                    height: 1
                }

                Text {
                    text: Math.round(SoundService.microphoneVolume * 100) + "%"
                    color: ThemeColors.textMuted
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                width: parent.width
                height: 5
                radius: height / 2
                color: ThemeColors.border

                Rectangle {
                    width: parent.width * Math.max(0, Math.min(1, SoundService.microphoneVolume))
                    height: parent.height
                    radius: height / 2
                    color: SoundService.microphoneMuted ? ThemeColors.textMuted : ThemeColors.accent

                    Behavior on width {
                        NumberAnimation { duration: 100 }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onPressed: function(mouse) { SoundService.setMicrophoneVolume(mouse.x / width) }
                    onPositionChanged: function(mouse) {
                        if (!pressed) return
                        SoundService.setMicrophoneVolume(mouse.x / width)
                    }
                }
            }
        }

        MouseArea {
            anchors {
                left: parent.left
                top: parent.top
                right: parent.right
            }

            height: 32

            onClicked: {
                if (root.openInputPage)
                    root.openInputPage()
            }
        }
    }

    Rectangle {
        width: parent.width
        height: 1
        color: ThemeColors.border
        opacity: 0.6
    }

    NotificationList {
        width: parent.width
    }
}