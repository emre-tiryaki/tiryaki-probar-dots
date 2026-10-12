import QtQuick
import "../common"
import "../services"

Column {
    id: panelRoot

    width: parent ? parent.width : 350
    // İçerik değiştikçe yüksekliğini dışarıya bildirir
    implicitHeight: childrenRect.height

    spacing: 12

    // ============================================================
    // Quick Settings Grid
    // ============================================================
    Grid {
        width: parent.width
        columns: 2
        rowSpacing: 8
        columnSpacing: 8

        // Wi-Fi
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
                    color: NetworkService.connected ? ThemeColors.accent : ThemeColors.textMuted
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 22
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 130
                    text: NetworkService.connected ? NetworkService.currentNetwork : "Wi-Fi Off"
                    color: ThemeColors.text
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                }
            }

            TapHandler {
                onTapped: NetworkService.toggle()
            }
        }

        // Bluetooth
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
                    color: BluetoothService.enabled ? ThemeColors.accent : ThemeColors.textMuted
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 22
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: BluetoothService.enabled ? BluetoothService.connectedCount + " connected" : "Bluetooth Off"
                    color: ThemeColors.text
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                }
            }

            TapHandler {
                onTapped: BluetoothService.toggle()
            }
        }

        // Airplane Mode
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
                    font.family: "Symbols Nerd Font"
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

        // Battery
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
                    font.family: "Symbols Nerd Font"
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

    // ============================================================
    // Sound Controls
    // ============================================================
    Rectangle {
        width: parent.width
        height: 52
        radius: 14
        color: ThemeColors.surface

        Row {
            anchors {
                fill: parent
                margins: 12
            }
            spacing: 12

            Text {
                text: SoundService.muted ? "󰖁" : "󰕾"
                color: ThemeColors.text
                font.family: "Symbols Nerd Font"
                font.pixelSize: 18
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                width: parent.width - 40
                height: 6
                radius: 3
                color: ThemeColors.border
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    width: parent.width * SoundService.volume
                    height: parent.height
                    radius: parent.radius
                    color: ThemeColors.accent
                }
            }
        }
    }

    // ============================================================
    // Ayırıcı Çizgi (Separator)
    // ============================================================
    Rectangle {
        width: parent.width
        height: 1
        color: ThemeColors.border
        opacity: 0.6
    }

    // ============================================================
    // Notifications Section
    // ============================================================
    Column {
        width: parent.width
        spacing: 8

        // Başlık ve Üst Butonlar
        Row {
            width: parent.width

            Text {
                text: "Notifications (" + NotificationService.count + ")"
                color: ThemeColors.text
                font.pixelSize: 12
                font.weight: Font.Bold
                anchors.verticalCenter: parent.verticalCenter
            }

            Item {
                width: parent.width - childrenRect.width - 100
                height: 1
            }

            // Clear All Button
            Rectangle {
                width: 50
                height: 22
                radius: 6
                color: ThemeColors.surface
                visible: NotificationService.count > 0

                Text {
                    anchors.centerIn: parent
                    text: "Clear"
                    color: ThemeColors.textMuted
                    font.pixelSize: 9
                    font.weight: Font.Medium
                }

                TapHandler {
                    onTapped: NotificationService.clearAll()
                }
            }

            // DND Toggle Button
            Rectangle {
                width: 28
                height: 22
                radius: 6
                color: NotificationService.dnd ? ThemeColors.accent : ThemeColors.surface

                Text {
                    anchors.centerIn: parent
                    text: NotificationService.dnd ? "󰂛" : "󰂚"
                    font.family: "Symbols Nerd Font"
                    color: NotificationService.dnd ? ThemeColors.background : ThemeColors.text
                    font.pixelSize: 11
                }

                TapHandler {
                    onTapped: NotificationService.toggleDnd()
                }
            }
        }

        // Bildirim Olmadığında Gösterilecek Kart
        Rectangle {
            width: parent.width
            height: 44
            radius: 12
            color: ThemeColors.surface
            visible: NotificationService.count === 0

            Text {
                anchors.centerIn: parent
                text: "No new notifications"
                color: ThemeColors.textMuted
                font.pixelSize: 11
            }
        }

        // Bildirim Listesi
        ListView {
            width: parent.width
            height: Math.min(contentHeight, 220)
            clip: true
            spacing: 6
            visible: NotificationService.count > 0

            model: NotificationService.notifications

            delegate: Rectangle {
                width: ListView.view.width
                height: 52
                radius: 12
                color: ThemeColors.surface

                Row {
                    anchors {
                        fill: parent
                        margins: 10
                    }
                    spacing: 8

                    Column {
                        width: parent.width - 24
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            width: parent.width
                            text: summary !== undefined ? summary : ""
                            color: ThemeColors.text
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            text: body !== undefined ? body : ""
                            color: ThemeColors.textMuted
                            font.pixelSize: 10
                            elide: Text.ElideRight
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰅖"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 13
                        color: ThemeColors.textMuted

                        TapHandler {
                            onTapped: NotificationService.dismiss(index)
                        }
                    }
                }
            }
        }
    }
}