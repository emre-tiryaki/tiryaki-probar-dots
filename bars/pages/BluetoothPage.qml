import QtQuick

import "../../common"
import "../../services"

Item {
    id: root

    signal backRequested()
    property string connectingDevice: ""
    property bool scanning: false
    readonly property string connectedText: BluetoothService.connectedCount + (BluetoothService.connectedCount === 1 ? " device connected" : " devices connected")

    // Keep the page within the expanded panel.
    property real maxPageHeight: 430

    implicitHeight: Math.min(
        contentColumn.implicitHeight,
        maxPageHeight
    )

    function toggleDevice(device) {
        if (!device)
            return

        if (device.connected) {
            BluetoothService.disconnect(device)
            return
        }

        connectingDevice = device.name
        BluetoothService.connect(device)
    }

    function pairDevice(device) {
        if (!device)
            return

        connectingDevice = device.name
        BluetoothService.pair(device)
    }

    function deviceIcon(name) {
        const value = (name || "").toLowerCase()

        if (
            value.includes("headphone") ||
            value.includes("headset") ||
            value.includes("earbud") ||
            value.includes("buds") ||
            value.includes("airpods") ||
            value.includes("wh-") ||
            value.includes("soundcore") ||
            value.includes("jbl") ||
            value.includes("sony")
        )
            return "󰋋"

        if (
            value.includes("controller") ||
            value.includes("gamepad") ||
            value.includes("xbox") ||
            value.includes("playstation") ||
            value.includes("dualshock") ||
            value.includes("dualsense") ||
            value.includes("joy-con") ||
            value.includes("joycon")
        )
            return "󰖺"

        if (
            value.includes("mouse") ||
            value.includes("mx master") ||
            value.includes("mx anywhere")
        )
            return "󰍽"

        if (
            value.includes("keyboard") ||
            value.includes("keychron") ||
            value.includes("k380") ||
            value.includes("k780")
        )
            return "󰌌"

        if (
            value.includes("iphone") ||
            value.includes("android") ||
            value.includes("phone") ||
            value.includes("galaxy") ||
            value.includes("pixel")
        )
            return "󰄜"

        if (
            value.includes("speaker") ||
            value.includes("soundbar") ||
            value.includes("homepod")
        )
            return "󰓃"

        if (
            value.includes("laptop") ||
            value.includes("macbook") ||
            value.includes("thinkpad") ||
            value.includes("desktop") ||
            value.includes("computer")
        )
            return "󰌢"

        return "󰂯"
    }

    function scanDevices() {
        if (!BluetoothService.enabled)
            return

        scanning = true
        BluetoothService.scan()
        scanTimer.restart()
    }

    Timer {
        id: scanTimer

        interval: 4000
        repeat: false

        onTriggered: {
            root.scanning = false
        }
    }

    Connections {
        target: BluetoothService

        function onConnectedCountChanged() {
            if (BluetoothService.connectedCount > 0)
                root.connectingDevice = ""
        }
    }

    Column {
        id: contentColumn

        width: parent.width
        spacing: 16

        PageHeader {
            width: parent.width
            centered: false
            title: "Bluetooth"
            subtitle: BluetoothService.enabled ? (BluetoothService.connectedCount > 0 ? root.connectedText : "Enabled") : "Disabled"
            onBackClicked: root.backRequested()
        }

        ToggleCard {
            width: parent.width
            icon: "󰂯"
            title: "Bluetooth"
            subtitle: BluetoothService.enabled ? (BluetoothService.connectedCount > 0 ? root.connectedText : "Ready to connect") : "Disabled"
            checked: BluetoothService.enabled
            onToggled: BluetoothService.toggle()
        }

        // Devices header
        Item {
            width: parent.width
            height: 30

            SectionTitle {
                anchors.verticalCenter: parent.verticalCenter
                text: "Devices"
            }

            Rectangle {
                id: scanButton

                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }

                width: 112
                height: 30

                radius: 10

                color: scanMouse.pressed
                    ? ThemeColors.background
                    : scanMouse.containsMouse
                        ? ThemeColors.surfaceHover
                        : ThemeColors.surface

                scale: scanMouse.pressed
                    ? 0.96
                    : scanMouse.containsMouse
                        ? 1.02
                        : 1.0

                Behavior on color {
                    ColorAnimation {
                        duration: 100
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 100
                        easing.type: Easing.OutCubic
                    }
                }

                Row {
                    anchors.centerIn: parent

                    spacing: 6

                    Text {
                        text: "󰑐"

                        color: ThemeColors.text

                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 14

                        anchors.verticalCenter: parent.verticalCenter

                        RotationAnimation on rotation {
                            running: root.scanning

                            loops: Animation.Infinite

                            from: 0
                            to: 360

                            duration: 900
                        }
                    }

                    Text {
                        text: root.scanning
                            ? "Scanning..."
                            : "Scan for devices"

                        color: ThemeColors.text

                        font.pixelSize: 9
                        font.weight: Font.DemiBold

                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: scanMouse

                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: {
                        root.scanDevices()
                    }
                }
            }
        }

        // Device list
        Item {
            id: deviceListContainer

            width: parent.width

            // Show only as much as needed, but never let the list
            // make the entire panel taller than the available space.
            height: Math.min(
                deviceListContent.implicitHeight,
                260
            )

            Flickable {
                id: deviceListFlickable

                anchors.fill: parent

                contentWidth: width
                contentHeight: deviceListContent.implicitHeight

                clip: true

                boundsBehavior: Flickable.StopAtBounds

                flickableDirection: Flickable.VerticalFlick

                Column {
                    id: deviceListContent

                    width: deviceListFlickable.width

                    spacing: 6

                    Repeater {
                        model: BluetoothService.devices

                        delegate: Rectangle {
                            required property var modelData

                            width: deviceListContent.width
                            height: 64

                            radius: 14

                            property bool isConnecting:
                                root.connectingDevice !== "" &&
                                root.connectingDevice === modelData.name

                            color: modelData.connected
                                ? ThemeColors.surfaceHover
                                : isConnecting
                                    ? ThemeColors.surfaceHover
                                    : deviceMouse.containsMouse
                                        ? ThemeColors.surfaceHover
                                        : ThemeColors.surface

                            scale: deviceMouse.pressed
                                ? 0.98
                                : deviceMouse.containsMouse
                                    ? 1.01
                                    : 1.0

                            opacity: isConnecting
                                ? 0.75
                                : 1.0

                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 100
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 180
                                }
                            }

                            // Device icon
                            Rectangle {
                                width: 42
                                height: 42

                                radius: 12

                                anchors {
                                    left: parent.left
                                    leftMargin: 10
                                    verticalCenter: parent.verticalCenter
                                }

                                color: modelData.connected
                                    ? ThemeColors.accent
                                    : ThemeColors.background

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 150
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent

                                    text: root.deviceIcon(
                                        modelData.name
                                    )

                                    color: modelData.connected
                                        ? ThemeColors.background
                                        : ThemeColors.textMuted

                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 20
                                }
                            }

                            // Device information
                            Column {
                                anchors {
                                    left: parent.left
                                    leftMargin: 62
                                    right: actionButton.left
                                    rightMargin: 10
                                    verticalCenter: parent.verticalCenter
                                }

                                spacing: 2

                                Text {
                                    width: parent.width

                                    text: modelData.name ||
                                          "Unknown device"

                                    color: ThemeColors.text

                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold

                                    elide: Text.ElideRight
                                }

                                Text {
                                    width: parent.width

                                    text: isConnecting
                                        ? "Connecting..."
                                        : modelData.connected
                                            ? "Connected"
                                            : modelData.paired
                                                ? "Paired"
                                                : "Available"

                                    color: modelData.connected
                                        ? ThemeColors.accent
                                        : ThemeColors.textMuted

                                    font.pixelSize: 9

                                    elide: Text.ElideRight
                                }
                            }

                            // Action button
                            Rectangle {
                                id: actionButton

                                anchors {
                                    right: forgetButton.visible
                                        ? forgetButton.left
                                        : parent.right

                                    rightMargin: forgetButton.visible
                                        ? 6
                                        : 10

                                    verticalCenter: parent.verticalCenter
                                }

                                width: 70
                                height: 30

                                radius: 10

                                color: actionMouse.pressed
                                    ? ThemeColors.background
                                    : actionMouse.containsMouse
                                        ? ThemeColors.surface
                                        : ThemeColors.background

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 100
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent

                                    text: modelData.connected
                                        ? "Disconnect"
                                        : modelData.paired
                                            ? "Connect"
                                            : "Pair"

                                    color: ThemeColors.text

                                    font.pixelSize: 9
                                    font.weight: Font.DemiBold
                                }

                                MouseArea {
                                    id: actionMouse

                                    anchors.fill: parent
                                    hoverEnabled: true

                                    onClicked: {
                                        if (modelData.connected) {
                                            BluetoothService.disconnect(
                                                modelData
                                            )
                                        } else if (modelData.paired) {
                                            root.toggleDevice(
                                                modelData
                                            )
                                        } else {
                                            root.pairDevice(
                                                modelData
                                            )
                                        }
                                    }
                                }
                            }

                            // Forget button
                            Rectangle {
                                id: forgetButton

                                visible: modelData.paired || modelData.bonded

                                anchors {
                                    right: parent.right
                                    rightMargin: 10
                                    verticalCenter: parent.verticalCenter
                                }

                                width: 60
                                height: 30

                                radius: 10

                                color: forgetMouse.pressed
                                    ? ThemeColors.background
                                    : forgetMouse.containsMouse
                                        ? ThemeColors.surfaceHover
                                        : ThemeColors.background

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 100
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent

                                    text: "Forget"

                                    color: ThemeColors.textMuted

                                    font.pixelSize: 9
                                    font.weight: Font.DemiBold
                                }

                                MouseArea {
                                    id: forgetMouse

                                    anchors.fill: parent

                                    hoverEnabled: true

                                    onClicked: {
                                        root.forgetDevice(modelData)
                                    }
                                }
                            }

                            MouseArea {
                                id: deviceMouse

                                anchors.fill: parent
                                hoverEnabled: true

                                onClicked: {
                                    if (!modelData.connected &&
                                        !modelData.paired) {
                                        root.pairDevice(modelData)
                                    }
                                }

                                z: -1
                            }
                        }
                    }

                    // Empty state
                    Rectangle {
                        visible: BluetoothService.devices.length === 0

                        width: deviceListContent.width
                        height: 90

                        radius: 16

                        color: ThemeColors.surface

                        Column {
                            anchors.centerIn: parent

                            spacing: 5

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter

                                text: root.scanning
                                    ? "󰑐"
                                    : "󰂯"

                                color: ThemeColors.textMuted

                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 24

                                RotationAnimation on rotation {
                                    running: root.scanning

                                    loops: Animation.Infinite

                                    from: 0
                                    to: 360

                                    duration: 900
                                }
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter

                                text: root.scanning
                                    ? "Scanning for devices..."
                                    : "No Bluetooth devices found"

                                color: ThemeColors.textMuted

                                font.pixelSize: 10
                            }
                        }
                    }
                }
            }
        }
    }
}