import QtQuick

import "../common"
import "../state"
import "../services"
import "./pages"

Item {
    id: root

    property bool expanded: BarState.rightExpanded
    property bool collapsedHovered: false
    property string page: "control"

    property real collapsedWidth:
        collapsedContent.implicitWidth + 20

    property real expandedWidth: 390

    property real collapsedHeight: 35

    property real expandedHeight:
        contentLoader.item
            ? contentLoader.item.implicitHeight + 32
            : 35

    width: expanded
        ? expandedWidth
        : collapsedWidth

    height: expanded
        ? expandedHeight
        : collapsedHeight

    Behavior on width {
        NumberAnimation {
            duration: 260
            easing.type: Easing.OutCubic
        }
    }

    Behavior on height {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    Timer {
        id: closeTimer

        interval: 120
        repeat: false

        onTriggered: {
            if (!root.expanded)
                return

            BarState.rightExpanded = false
            root.page = "control"
        }
    }

    Rectangle {
        id: surface

        anchors {
            top: parent.top
            right: parent.right
        }

        width: parent.width
        height: parent.height

        clip: true

        color: root.expanded
            ? ThemeColors.background
            : root.collapsedHovered
                ? ThemeColors.surfaceHover
                : ThemeColors.background

        bottomLeftRadius: 18

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }

        // ========================================================
        // Collapsed bar
        // ========================================================

        Item {
            id: collapsedLayer

            anchors.fill: parent

            visible: !root.expanded

            Row {
                id: collapsedContent

                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: 10
                }

                spacing: 10

                // ------------------------------------------------
                // Wi-Fi
                // ------------------------------------------------

                Row {
                    spacing: 5

                    Text {
                        text: NetworkService.connecting
                            ? "󰤨"
                            : NetworkService.connected
                                ? "󰤨"
                                : "󰤭"

                        color: ThemeColors.text

                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 16

                        anchors.verticalCenter: parent.verticalCenter

                        opacity: NetworkService.connecting
                            ? 0.45
                            : 1

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 180
                            }
                        }
                    }

                    Text {
                        text: NetworkService.connecting
                            ? "Connecting..."
                            : NetworkService.connected
                                ? NetworkService.currentNetwork
                                : "Offline"

                        color: ThemeColors.text

                        font.pixelSize: 11
                        font.weight: Font.Medium

                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Rectangle {
                    width: 1
                    height: 16

                    color: ThemeColors.border

                    anchors.verticalCenter: parent.verticalCenter
                }

                // ------------------------------------------------
                // Sound
                // ------------------------------------------------

                Row {
                    spacing: 5

                    Text {
                        text: SoundService.muted
                            ? "󰖁"
                            : "󰕾"

                        color: ThemeColors.text

                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 16

                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: Math.round(
                            SoundService.volume * 100
                        ) + "%"

                        color: ThemeColors.text

                        font.pixelSize: 11
                        font.weight: Font.Medium

                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Rectangle {
                    width: 1
                    height: 16

                    color: ThemeColors.border

                    anchors.verticalCenter: parent.verticalCenter
                }

                // ------------------------------------------------
                // Bluetooth
                // ------------------------------------------------

                Item {
                    width: 22
                    height: 22

                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent

                        text: "󰂯"

                        color: BluetoothService.enabled
                            ? ThemeColors.text
                            : ThemeColors.textMuted

                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 17
                    }

                    Rectangle {
                        visible:
                            BluetoothService.connectedCount > 0

                        width: 11
                        height: 11

                        radius: width / 2

                        anchors {
                            right: parent.right
                            bottom: parent.bottom
                        }

                        color: ThemeColors.accent

                        Text {
                            anchors.centerIn: parent

                            text: BluetoothService.connectedCount

                            color: ThemeColors.background

                            font.pixelSize: 7
                            font.weight: Font.Bold
                        }
                    }
                }

                // ------------------------------------------------
                // Battery
                // ------------------------------------------------

                Row {
                    spacing: 5

                    Text {
                        text: BatteryService.charging
                            ? "󰂄"
                            : "󰁹"

                        color: ThemeColors.text

                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 16

                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: BatteryService.available
                            ? BatteryService.percentage + "%"
                            : "--"

                        color: ThemeColors.text

                        font.pixelSize: 11
                        font.weight: Font.Medium

                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // ----------------------------------------------------
            // Collapsed interaction
            // ----------------------------------------------------

            TapHandler {
                onTapped: {
                    closeTimer.stop()

                    root.page = "control"
                    BarState.rightExpanded = true
                }
            }

            HoverHandler {
                onHoveredChanged: {
                    root.collapsedHovered = hovered
                }
            }
        }

        // ========================================================
        // Expanded content
        // ========================================================

        Item {
            id: expandedLayer

            anchors.fill: parent

            visible: root.expanded

            Loader {
                id: contentLoader

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right

                    topMargin: 16
                    leftMargin: 16
                    rightMargin: 16
                }

                sourceComponent: {
                    if (root.page === "wifi")
                        return wifiPage

                    if (root.page === "bluetooth")
                        return bluetoothPage

                    return controlPage
                }
            }

            HoverHandler {
                onHoveredChanged: {
                    if (hovered) {
                        closeTimer.stop()
                    } else {
                        closeTimer.restart()
                    }
                }
            }
        }
    }

    // ============================================================
    // Pages
    // ============================================================

    Component {
        id: controlPage

        ControlCenter {
            openWifiPage: function() {
                root.page = "wifi"
            }

            openBluetoothPage: function() {
                root.page = "bluetooth"
            }
        }
    }

    Component {
        id: wifiPage

        WifiPage {
            goBack: function() {
                root.page = "control"
            }
        }
    }

    Component {
        id: bluetoothPage

        BluetoothPage {
            goBack: function() {
                root.page = "control"
            }
        }
    }
}