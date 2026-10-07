import QtQuick

import "../common"
import "../state"
import "../services"
import "./pages"

Item {
    id: root

    width: expanded
        ? expandedBar.width
        : collapsedBar.width

    height: expanded
        ? expandedBar.height
        : collapsedBar.height

    property bool expanded: BarState.rightExpanded
    property bool collapsedHovered: false
    property string page: "control"

    // ------------------------------------------------------------
    // Close timer
    // ------------------------------------------------------------

    Timer {
        id: closeTimer

        interval: 120
        repeat: false

        onTriggered: {
            if (root.expanded) {
                BarState.rightExpanded = false
                root.page = "control"
            }
        }
    }

    // ------------------------------------------------------------
    // Collapsed bar
    // ------------------------------------------------------------

    Rectangle {
        id: collapsedBar

        visible: !root.expanded

        width: collapsedContent.implicitWidth + 20
        height: 35

        color: root.collapsedHovered
            ? ThemeColors.surfaceHover
            : ThemeColors.background

        bottomLeftRadius: 18

        Row {
            id: collapsedContent

            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: 10
            }

            spacing: 10

            // Wi-Fi
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

                    opacity: NetworkService.connecting ? 0.45 : 1

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

            // Audio
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

            // Bluetooth
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
                    visible: BluetoothService.connectedCount > 0

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

            // Battery
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

    // ------------------------------------------------------------
    // Expanded control center
    // ------------------------------------------------------------

    Rectangle {
        id: expandedBar

        visible: root.expanded

        anchors {
            top: parent.top
            right: parent.right
        }

        width: 390

        height: contentLoader.implicitHeight + 32

        color: ThemeColors.background

        bottomLeftRadius: 18

        HoverHandler {
            onHoveredChanged: {
                if (hovered)
                    closeTimer.stop()
                else
                    closeTimer.restart()
            }
        }

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

            sourceComponent: root.page === "wifi"
                ? wifiPage
                : controlPage
        }
    }

    // ------------------------------------------------------------
    // Pages
    // ------------------------------------------------------------

    Component {
        id: controlPage

        ControlCenter {
            openWifiPage: function() {
                root.page = "wifi"
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
}