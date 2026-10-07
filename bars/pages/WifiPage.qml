import QtQuick

import "../../common"
import "../../services"

Column {
    id: root

    property var goBack

    property var selectedNetwork: null
    property string password: ""
    property string errorMessage: ""

    width: parent ? parent.width : 0

    spacing: 16

    function selectNetwork(network) {
        if (!network)
            return

        errorMessage = ""

        if (network.connected) {
            NetworkService.disconnect(network)
            return
        }

        if (network.known) {
            NetworkService.connect(network)
            return
        }

        selectedNetwork = network
        password = ""

        passwordInput.forceActiveFocus()
    }

    function connectWithPassword() {
        if (!selectedNetwork)
            return

        if (password.length === 0) {
            errorMessage = "Password is required"
            return
        }

        errorMessage = ""

        NetworkService.connectWithPassword(
            selectedNetwork,
            password
        )

        selectedNetwork = null
        password = ""
    }

    // Header
    Row {
        width: parent.width
        spacing: 12

        Rectangle {
            width: 40
            height: 40

            radius: 12

            color: ThemeColors.surface

            Text {
                anchors.centerIn: parent

                text: "󰁍"

                color: ThemeColors.text

                font.family: "Symbols Nerd Font"
                font.pixelSize: 20
            }

            TapHandler {
                onTapped: {
                    if (root.selectedNetwork) {
                        root.selectedNetwork = null
                        root.password = ""
                        root.errorMessage = ""
                    } else if (root.goBack) {
                        root.goBack()
                    }
                }
            }
        }

        Column {
            spacing: 2

            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: root.selectedNetwork
                    ? root.selectedNetwork.name
                    : "Wi-Fi"

                color: ThemeColors.text

                font.pixelSize: 16
                font.weight: Font.DemiBold
            }

            Text {
                text: root.selectedNetwork
                    ? "Enter password"
                    : NetworkService.connecting
                        ? "Connecting to " +
                          NetworkService.connectingNetwork
                        : NetworkService.connected
                            ? NetworkService.currentNetwork
                            : "Disconnected"

                color: ThemeColors.textMuted

                font.pixelSize: 10
            }
        }
    }

    // Password page
    Column {
        visible: root.selectedNetwork !== null

        width: parent.width

        spacing: 12

        Rectangle {
            width: parent.width
            height: 58

            radius: 14

            color: ThemeColors.surface

            TextInput {
                id: passwordInput

                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter

                    leftMargin: 14
                    rightMargin: 14
                }

                text: root.password

                color: ThemeColors.text

                font.pixelSize: 12

                echoMode: TextInput.Password

                clip: true

                selectByMouse: true

                onTextChanged: {
                    root.password = text
                }

                Keys.onReturnPressed: {
                    root.connectWithPassword()
                }
            }

            Text {
                visible: passwordInput.text.length === 0

                anchors {
                    left: passwordInput.left
                    verticalCenter: passwordInput.verticalCenter
                }

                text: "Password"

                color: ThemeColors.textMuted

                font.pixelSize: 12

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        passwordInput.forceActiveFocus()
                    }
                }
            }
        }

        Text {
            visible: root.errorMessage !== ""

            text: root.errorMessage

            color: "#f38ba8"

            font.pixelSize: 10
        }

        Rectangle {
            width: parent.width
            height: 48

            radius: 14

            color: ThemeColors.accent

            Text {
                anchors.centerIn: parent

                text: "Connect"

                color: ThemeColors.background

                font.pixelSize: 12
                font.weight: Font.DemiBold
            }

            TapHandler {
                onTapped: {
                    root.connectWithPassword()
                }
            }
        }
    }

    // Main Wi-Fi page
    Column {
        visible: root.selectedNetwork === null

        width: parent.width

        spacing: 12

        // Wi-Fi toggle
        Rectangle {
            width: parent.width
            height: 60

            radius: 16

            color: ThemeColors.surface

            Behavior on color {
                ColorAnimation {
                    duration: 180
                }
            }

            // Wi-Fi icon
            Text {
                id: wifiToggleIcon

                anchors {
                    left: parent.left
                    leftMargin: 14
                    verticalCenter: parent.verticalCenter
                }

                text: NetworkService.enabled
                    ? "󰤨"
                    : "󰤭"

                color: ThemeColors.text

                font.family: "Symbols Nerd Font"
                font.pixelSize: 22
            }

            // Wi-Fi information
            Column {
                anchors {
                    left: wifiToggleIcon.right
                    leftMargin: 12
                    right: wifiToggleSwitch.left
                    rightMargin: 12
                    verticalCenter: parent.verticalCenter
                }

                spacing: 2

                Text {
                    width: parent.width

                    text: "Wi-Fi"

                    color: ThemeColors.text

                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                }

                Text {
                    width: parent.width

                    text: NetworkService.connecting
                        ? "Connecting to " +
                        NetworkService.connectingNetwork
                        : NetworkService.enabled
                            ? NetworkService.connected
                                ? NetworkService.currentNetwork
                                : "Enabled"
                            : "Disabled"

                    color: ThemeColors.textMuted

                    font.pixelSize: 10

                    elide: Text.ElideRight
                }
            }

            // Wi-Fi switch
            Rectangle {
                id: wifiToggleSwitch

                anchors {
                    right: parent.right
                    rightMargin: 14
                    verticalCenter: parent.verticalCenter
                }

                width: 42
                height: 24

                radius: 12

                color: NetworkService.enabled
                    ? ThemeColors.accent
                    : ThemeColors.background

                Behavior on color {
                    ColorAnimation {
                        duration: 180
                    }
                }

                Rectangle {
                    width: 18
                    height: 18

                    radius: 9

                    anchors.verticalCenter: parent.verticalCenter

                    x: NetworkService.enabled
                        ? parent.width - width - 3
                        : 3

                    color: ThemeColors.text

                    Behavior on x {
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                TapHandler {
                    onTapped: {
                        NetworkService.toggle()
                    }
                }
            }
        }

        Text {
            text: "Networks"

            color: ThemeColors.text

            font.pixelSize: 13
            font.weight: Font.DemiBold
        }

        Column {
            width: parent.width

            spacing: 6

            Repeater {
                model: NetworkService.networks

                delegate: Rectangle {
                    required property var modelData

                    width: parent.width
                    height: 56

                    radius: 14

                    property bool isConnecting:
                        NetworkService.connecting &&
                        NetworkService.connectingNetwork ===
                        modelData.name

                    color: isConnecting
                        ? ThemeColors.surfaceHover
                        : modelData.connected
                            ? ThemeColors.surfaceHover
                            : ThemeColors.surface

                    opacity: isConnecting
                        ? 1
                        : modelData.connected
                            ? 1
                            : 0.92

                    scale: isConnecting
                        ? 1.01
                        : 1.0

                    Behavior on color {
                        ColorAnimation {
                            duration: 180
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 180
                        }
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
                    }

                    Row {
                        anchors {
                            left: parent.left
                            leftMargin: 14

                            verticalCenter: parent.verticalCenter
                        }

                        spacing: 12

                        Text {
                            text: modelData.connected
                                ? "󰤨"
                                : "󰤯"

                            color: ThemeColors.text

                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 19

                            anchors.verticalCenter: parent.verticalCenter

                            opacity: isConnecting
                                ? 0.5
                                : 1

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 180
                                }
                            }
                        }

                        Column {
                            spacing: 2

                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: modelData.name

                                color: ThemeColors.text

                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                            }

                            Text {
                                text: isConnecting
                                    ? "Connecting..."
                                    : modelData.connected
                                        ? "Connected"
                                        : modelData.known
                                            ? "Saved"
                                            : "Available"

                                color: ThemeColors.textMuted

                                font.pixelSize: 9
                            }
                        }
                    }

                    TapHandler {
                        onTapped: {
                            root.selectNetwork(modelData)
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        NetworkService.scan()
    }
}