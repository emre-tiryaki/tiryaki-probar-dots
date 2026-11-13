import QtQuick

import "../../common"
import "../../services"

Column {
    id: root

    signal backRequested()

    property var selectedNetwork: null
    property string password: ""
    property string errorMessage: ""

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

    PageHeader {
        width: parent.width
        centered: false
        title: root.selectedNetwork ? root.selectedNetwork.name : "Wi-Fi"
        subtitle: root.selectedNetwork ? "Enter password" : NetworkService.connecting ? "Connecting to " + NetworkService.connectingNetwork : NetworkService.connected ? NetworkService.currentNetwork : "Disconnected"
        onBackClicked: {
            if (root.selectedNetwork) {
                root.selectedNetwork = null;
                root.password = "";
                root.errorMessage = "";
            } else {
                root.backRequested();
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

            color: ThemeColors.error

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

        ToggleCard {
            width: parent.width
            icon: NetworkService.enabled ? "󰤨" : "󰤭"
            title: "Wi-Fi"
            subtitle: NetworkService.connecting ? "Connecting to " + NetworkService.connectingNetwork : NetworkService.enabled ? (NetworkService.connected ? NetworkService.currentNetwork : "Enabled") : "Disabled"
            checked: NetworkService.enabled
            onToggled: NetworkService.toggle()
        }

        SectionTitle {
            text: "Networks"
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