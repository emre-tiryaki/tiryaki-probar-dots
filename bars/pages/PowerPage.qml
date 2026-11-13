import "../../common"
import "../../services"
import QtQuick

Item {
    id: root

    // confirm: true requires a second click within 3 s.
    readonly property var actions: [
        { id: "lock",     title: "Lock",     description: "Lock session",   icon: "󰌾", run: () => PowerService.lock() },
        { id: "shutdown", title: "Shutdown", description: "Power off",      icon: "󰐥", run: () => PowerService.shutdown(), confirm: true },
        { id: "reboot",   title: "Reboot",   description: "Restart system", icon: "󰑐", run: () => PowerService.reboot(),   confirm: true },
        { id: "logout",   title: "Logout",   description: "End session",    icon: "󰍃", run: () => PowerService.logout(),   confirm: true },
        { id: "sleep",    title: "Sleep",    description: "Suspend system", icon: "󰒲", run: () => PowerService.sleep() }
    ]
    property string pendingAction: ""

    signal backRequested()

    function trigger(action) {
        if (action.confirm && pendingAction !== action.id) {
            pendingAction = action.id;
            confirmationTimer.restart();
            return;
        }
        confirmationTimer.stop();
        pendingAction = "";
        action.run();
    }

    implicitWidth: 540
    implicitHeight: content.height + 20

    Timer {
        id: confirmationTimer

        interval: 3000
        onTriggered: root.pendingAction = ""
    }

    Column {
        id: content

        width: parent.width - 36
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 14

        PageHeader {
            width: parent.width
            title: "Power"
            subtitle: "Manage your session and system power"
            onBackClicked: root.backRequested()
        }

        Separator {}

        Row {
            id: buttons

            width: parent.width
            spacing: 10

            Repeater {
                model: root.actions

                Card {
                    id: button

                    required property var modelData
                    readonly property bool pending: root.pendingAction === modelData.id
                    readonly property color tint: pending ? ThemeColors.error : hovered ? ThemeColors.accent : ThemeColors.text

                    width: (buttons.width - buttons.spacing * (root.actions.length - 1)) / root.actions.length
                    height: 96
                    hoverScale: 1.025
                    border.color: pending ? ThemeColors.error : hovered ? ThemeColors.accent : ThemeColors.border
                    onClicked: root.trigger(modelData)

                    Column {
                        anchors.centerIn: parent
                        spacing: 5

                        Icon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: button.pending ? "󰄬" : button.modelData.icon
                            color: button.tint
                            font.pixelSize: 24
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: button.pending ? "Confirm" : button.modelData.title
                            color: ThemeColors.text
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: button.pending ? "Click again" : button.modelData.description
                            color: ThemeColors.textMuted
                            font.pixelSize: 7
                        }
                    }
                }
            }
        }
    }
}
