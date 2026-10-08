import QtQuick

import "../../common"
import "../../services"

Item {
    id: root

    implicitWidth: 500
    implicitHeight: 210

    property string pendingAction: ""

    Timer {
        id: confirmTimer

        interval: 3000
        repeat: false

        onTriggered: {
            root.pendingAction = ""
        }
    }

    function requestAction(action) {
        if (root.pendingAction === action) {
            executeAction(action)
            return
        }

        root.pendingAction = action
        confirmTimer.restart()
    }

    function executeAction(action) {
        confirmTimer.stop()
        root.pendingAction = ""

        switch (action) {

        case "shutdown":
            PowerService.shutdown()
            break

        case "reboot":
            PowerService.reboot()
            break

        case "lock":
            PowerService.lock()
            break

        case "logout":
            PowerService.logout()
            break
        }
    }

    Column {
        anchors.centerIn: parent

        spacing: 18

        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: "Power"

            color: ThemeColors.text

            font.pixelSize: 20
            font.weight: Font.DemiBold
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter

            spacing: 10

            PowerButton {
                action: "shutdown"
                icon: "󰐥"
                label: "Shutdown"
                confirmLabel: "Confirm"

                confirmable: true

                onTriggered: root.requestAction(action)
            }

            PowerButton {
                action: "reboot"
                icon: "󰜉"
                label: "Reboot"
                confirmLabel: "Confirm"

                confirmable: true

                onTriggered: root.requestAction(action)
            }

            PowerButton {
                action: "lock"
                icon: "󰌾"
                label: "Lock"

                confirmable: false

                onTriggered: root.executeAction(action)
            }

            PowerButton {
                action: "logout"
                icon: "󰍃"
                label: "Logout"
                confirmLabel: "Confirm"

                confirmable: true

                onTriggered: root.requestAction(action)
            }
        }
    }

    component PowerButton: Rectangle {

        property string action
        property string icon
        property string label
        property string confirmLabel: ""
        property bool confirmable: true

        signal triggered()

        width: 112
        height: 82

        radius: 16

        color: {
            if (root.pendingAction === action)
                return "#c94f5b"

            return hoverHandler.hovered
                ? ThemeColors.surfaceHover
                : ThemeColors.surface
        }

        border.width: 1

        border.color: {
            if (root.pendingAction === action)
                return "#e06c75"

            return ThemeColors.border
        }

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: 120
            }
        }

        Column {
            anchors.centerIn: parent

            spacing: 6

            Text {
                anchors.horizontalCenter: parent.horizontalCenter

                text:
                    root.pendingAction === action
                        ? "󰀦"
                        : icon

                color: "#ffffff"

                font.family: "Symbols Nerd Font"
                font.pixelSize: 25
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter

                text:
                    root.pendingAction === action
                        ? confirmLabel
                        : label

                color: "#ffffff"

                font.pixelSize: 10
                font.weight: Font.DemiBold
            }
        }

        HoverHandler {
            id: hoverHandler

            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: triggered()
        }
    }
}