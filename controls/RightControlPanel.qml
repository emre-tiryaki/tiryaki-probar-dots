Column {
    width: parent.width

    spacing: 12

    // ============================================================
    // Quick Settings
    // ============================================================

    Grid {
        width: parent.width

        columns: 2

        rowSpacing: 8
        columnSpacing: 8

        // --------------------------------------------------------
        // Wi-Fi
        // --------------------------------------------------------

        Rectangle {
            width: (parent.width - 8) / 2
            height: 72

            radius: 14

            color: ThemeColors.surface

            Column {
                anchors.centerIn: parent

                spacing: 6

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: "󰤨"

                    color: NetworkService.connected
                        ? ThemeColors.accent
                        : ThemeColors.textMuted

                    font.pixelSize: 22
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter

                    width: 130

                    text: NetworkService.connected
                        ? NetworkService.currentNetwork
                        : "Wi-Fi Off"

                    color: ThemeColors.text

                    font.pixelSize: 10
                    font.weight: Font.DemiBold

                    horizontalAlignment: Text.AlignHCenter

                    elide: Text.ElideRight
                }
            }

            TapHandler {
                onTapped: {
                    NetworkService.toggle()
                }
            }
        }

        // --------------------------------------------------------
        // Bluetooth
        // --------------------------------------------------------

        Rectangle {
            width: (parent.width - 8) / 2
            height: 72

            radius: 14

            color: ThemeColors.surface

            Column {
                anchors.centerIn: parent

                spacing: 6

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: "󰂯"

                    color: BluetoothService.enabled
                        ? ThemeColors.accent
                        : ThemeColors.textMuted

                    font.pixelSize: 22
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: BluetoothService.enabled
                        ? BluetoothService.connectedCount + " connected"
                        : "Bluetooth Off"

                    color: ThemeColors.text

                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                }
            }

            TapHandler {
                onTapped: {
                    BluetoothService.toggle()
                }
            }
        }

        // --------------------------------------------------------
        // Airplane Mode
        // --------------------------------------------------------

        Rectangle {
            width: (parent.width - 8) / 2
            height: 72

            radius: 14

            color: ThemeColors.surface

            Column {
                anchors.centerIn: parent

                spacing: 6

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: "󰀝"

                    color: ThemeColors.text

                    font.pixelSize: 22
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: "Airplane Mode"

                    color: ThemeColors.text

                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                }
            }

            TapHandler {
                onTapped: {
                    NetworkService.setEnabled(false)
                    BluetoothService.setEnabled(false)
                }
            }
        }

        // --------------------------------------------------------
        // Battery
        // --------------------------------------------------------

        Rectangle {
            width: (parent.width - 8) / 2
            height: 72

            radius: 14

            color: ThemeColors.surface

            Column {
                anchors.centerIn: parent

                spacing: 6

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: "󰁹"

                    color: ThemeColors.accent

                    font.pixelSize: 22
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: BatteryService.percentage + "%"

                    color: ThemeColors.text

                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                }
            }
        }
    }
}