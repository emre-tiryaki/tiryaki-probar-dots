import "../../common"
import "../../services"
import QtQuick

Item {
    id: root

    property string pendingAction: ""

    signal backRequested()

    function requestAction(action) {
        if (root.pendingAction === action) {
            confirmationTimer.stop();
            root.pendingAction = "";
            switch (action) {
            case "shutdown":
                PowerService.shutdown();
                break;
            case "reboot":
                PowerService.reboot();
                break;
            case "logout":
                PowerService.logout();
                break;
            }
            return ;
        }
        root.pendingAction = action;
        confirmationTimer.restart();
    }

    function lock() {
        PowerService.lock();
    }

    implicitWidth: 540
    implicitHeight: contentColumn.height + 20

    Timer {
        id: confirmationTimer

        interval: 3000
        repeat: false
        onTriggered: {
            root.pendingAction = "";
        }
    }

    Column {
        id: contentColumn

        width: parent.width - 36
        spacing: 14

        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }

        PageHeader {
            width: parent.width
            title: "Power"
            subtitle: "Manage your session and system power"
            onBackClicked: root.backRequested()
        }

        Rectangle {
            width: parent.width
            height: 1
            color: ThemeColors.border
            opacity: 0.6
        }

        Row {
            width: parent.width
            spacing: 10

            PowerButton {
                width: (parent.width - 40) / 5
                title: "Lock"
                description: "Lock session"
                icon: "󰌾"
                accent: ThemeColors.accent
                onClicked: root.lock()
            }

            PowerButton {
                width: (parent.width - 40) / 5
                title: root.pendingAction === "shutdown" ? "Confirm" : "Shutdown"
                description: root.pendingAction === "shutdown" ? "Click again" : "Power off"
                icon: root.pendingAction === "shutdown" ? "󰄬" : "󰐥"
                destructive: root.pendingAction === "shutdown"
                onClicked: root.requestAction("shutdown")
            }

            PowerButton {
                width: (parent.width - 40) / 5
                title: root.pendingAction === "reboot" ? "Confirm" : "Reboot"
                description: root.pendingAction === "reboot" ? "Click again" : "Restart system"
                icon: root.pendingAction === "reboot" ? "󰄬" : "󰑐"
                destructive: root.pendingAction === "reboot"
                onClicked: root.requestAction("reboot")
            }

            PowerButton {
                width: (parent.width - 40) / 5
                title: root.pendingAction === "logout" ? "Confirm" : "Logout"
                description: root.pendingAction === "logout" ? "Click again" : "End session"
                icon: root.pendingAction === "logout" ? "󰄬" : "󰍃"
                destructive: root.pendingAction === "logout"
                onClicked: root.requestAction("logout")
            }

            PowerButton {
                width: (parent.width - 40) / 5
                title: "Sleep"
                description: "Suspend system"
                icon: "󰒲"
                accent: ThemeColors.accent
                onClicked: PowerService.sleep()
            }

        }

    }

    component PowerButton: Rectangle {
        id: button

        property string title
        property string description
        property string icon
        property color accent: ThemeColors.accent
        property bool destructive: false

        signal clicked()

        height: 96
        radius: 16
        color: buttonHover.hovered ? ThemeColors.surfaceHover : ThemeColors.surface
        border.width: 1
        border.color: button.destructive ? "#f38ba8" : buttonHover.hovered ? button.accent : ThemeColors.border
        scale: buttonHover.hovered ? 1.025 : 1

        Column {
            anchors.centerIn: parent
            spacing: 5

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: button.icon
                color: button.destructive ? "#f38ba8" : buttonHover.hovered ? button.accent : ThemeColors.text
                font.family: "Symbols Nerd Font"
                font.pixelSize: 24
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: button.title
                color: ThemeColors.text
                font.pixelSize: 10
                font.weight: Font.DemiBold
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: button.description
                color: ThemeColors.textMuted
                font.pixelSize: 7
            }

        }

        HoverHandler {
            id: buttonHover

            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: button.clicked()
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

        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }

        }

    }

}
