import "../common"
import "../services"
import "../state"
import "./pages"
import QtQuick

Item {
    id: root

    property bool expanded: BarState.rightExpanded
    property bool collapsedHovered: false
    property string page: "control"
    property real collapsedWidth: collapsedContent.implicitWidth + 20
    property real expandedWidth: 390
    property real collapsedHeight: 35
    property real expandedHeight: {
        if (!contentLoader.item)
            return 35;

        const h = contentLoader.item.implicitHeight > 0 ? contentLoader.item.implicitHeight : contentLoader.item.childrenRect.height;
        return h + 32;
    }

    width: expanded ? expandedWidth : collapsedWidth
    height: expanded ? expandedHeight : collapsedHeight

    Timer {
        id: closeTimer

        interval: 120
        repeat: false
        onTriggered: {
            if (!root.expanded)
                return ;

            BarState.rightExpanded = false;
            root.page = "control";
        }
    }

    Connections {
        target: NotificationService

        function onFocusRequested(id) {
            closeTimer.stop();
            root.page = "control";
            BarState.rightExpanded = true;
        }
    }

    Rectangle {
        id: surface

        width: parent.width
        height: parent.height
        clip: true
        color: root.expanded ? ThemeColors.background : root.collapsedHovered ? ThemeColors.surfaceHover : ThemeColors.background
        bottomLeftRadius: 18

        anchors {
            top: parent.top
            right: parent.right
        }

        // Collapsed
        Item {
            id: collapsedLayer

            anchors.fill: parent
            visible: !root.expanded

            Row {
                id: collapsedContent

                spacing: 10

                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: 10
                }

                // Network
                Row {
                    spacing: 5

                    Text {
                        text: NetworkService.connecting ? "󰤨" : NetworkService.connected ? "󰤨" : "󰤭"
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
                        text: NetworkService.connecting ? "Connecting..." : NetworkService.connected ? NetworkService.currentNetwork : "Offline"
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
                        text: SoundService.muted ? "󰖁" : "󰕾"
                        color: ThemeColors.text
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: Math.round(SoundService.volume * 100) + "%"
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
                        color: BluetoothService.enabled ? ThemeColors.text : ThemeColors.textMuted
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 17
                    }

                    Rectangle {
                        visible: BluetoothService.connectedCount > 0
                        width: 11
                        height: 11
                        radius: width / 2
                        color: ThemeColors.accent

                        anchors {
                            right: parent.right
                            bottom: parent.bottom
                        }

                        Text {
                            anchors.centerIn: parent
                            text: BluetoothService.connectedCount
                            color: ThemeColors.background
                            font.pixelSize: 7
                            font.weight: Font.Bold
                        }

                    }

                }

                Rectangle {
                    width: 1
                    height: 16
                    color: ThemeColors.border
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Notifications icon and badge
                Item {
                    width: 22
                    height: 22
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: NotificationService.dnd ? "󰂛" : "󰂚"
                        color: NotificationService.count > 0 ? ThemeColors.text : ThemeColors.textMuted
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 16
                    }

                    Rectangle {
                        visible: NotificationService.count > 0
                        z: 10
                        width: Math.max(12, badgeText.implicitWidth + 4)
                        height: 12
                        radius: 6
                        color: ThemeColors.accent

                        anchors {
                            top: parent.top
                            right: parent.right
                            topMargin: -2
                            rightMargin: -4
                        }

                        Text {
                            id: badgeText

                            anchors.centerIn: parent
                            text: NotificationService.count > 9 ? "9+" : NotificationService.count
                            color: ThemeColors.background
                            font.pixelSize: 8
                            font.weight: Font.Bold
                        }

                    }

                }

                Rectangle {
                    width: 1
                    height: 16
                    color: ThemeColors.border
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Battery
                Row {
                    spacing: 5

                    Text {
                        text: BatteryService.charging ? "󰂄" : "󰁹"
                        color: ThemeColors.text
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: BatteryService.available ? BatteryService.percentage + "%" : "--"
                        color: ThemeColors.text
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        anchors.verticalCenter: parent.verticalCenter
                    }

                }

            }

            TapHandler {
                onTapped: {
                    closeTimer.stop();
                    root.page = "control";
                    BarState.rightExpanded = true;
                }
            }

            HoverHandler {
                onHoveredChanged: {
                    root.collapsedHovered = hovered;
                }
            }

        }

        // Expanded
        Item {
            id: expandedLayer

            anchors.fill: parent
            visible: root.expanded

            Loader {
                id: contentLoader

                sourceComponent: {
                    if (root.page === "wifi")
                        return wifiPage;

                    if (root.page === "bluetooth")
                        return bluetoothPage;

                    if (root.page === "audio")
                        return audioPage;

                    if (root.page === "input")
                        return inputPage;

                    return controlPage;
                }

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    topMargin: 16
                    leftMargin: 16
                    rightMargin: 16
                }

            }

            HoverHandler {
                onHoveredChanged: {
                    if (hovered)
                        closeTimer.stop();
                    else
                        closeTimer.restart();
                }
            }

        }

        Behavior on color {
            ColorAnimation {
                duration: 120
            }

        }

    }

    Component {
        id: controlPage

        ControlCenter {
            openWifiPage: function() {
                root.page = "wifi";
            }
            openBluetoothPage: function() {
                root.page = "bluetooth";
            }
            openAudioPage: function() {
                root.page = "audio";
            }
            openInputPage: function() {
                root.page = "input";
            }
        }

    }

    Component {
        id: wifiPage

        WifiPage {
            goBack: function() {
                root.page = "control";
            }
        }

    }

    Component {
        id: bluetoothPage

        BluetoothPage {
            goBack: function() {
                root.page = "control";
            }
        }

    }

    Component {
        id: audioPage

        AudioPage {
            goBack: function() {
                root.page = "control";
            }
        }

    }

    Component {
        id: inputPage

        InputPage {
            goBack: function() {
                root.page = "control";
            }
        }

    }

    Behavior on width {
        NumberAnimation {
            duration: 260
            easing.type: Easing.OutCubic
        }

    }

    Behavior on height {
        NumberAnimation {
            duration: 260
            easing.type: Easing.OutCubic
        }

    }

}