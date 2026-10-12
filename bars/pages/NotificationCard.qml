import QtQuick
import Quickshell
import "../../common"
import "../../services"

Rectangle {
    id: card

    required property int notifId
    required property string summary
    required property string body
    required property string appName
    required property string appIcon
    required property int urgency
    required property string time
    required property string actionsJson

    property bool expanded: false
    property bool highlighted: false
    property string copiedKind: ""

    readonly property var actions: JSON.parse(actionsJson || "[]")
    readonly property var urgencyLabels: ["Low", "Normal", "Critical"]
    readonly property string iconSource: {
        if (appIcon.length === 0)
            return ""
        if (appIcon.startsWith("/"))
            return "file://" + appIcon
        return Quickshell.iconPath(appIcon, true)
    }

    signal toggled()

    function copyText(kind, text) {
        NotificationService.copy(text)
        copiedKind = kind
        copiedTimer.restart()
    }

    implicitHeight: content.implicitHeight + 20
    height: implicitHeight
    radius: 12
    color: toggleArea.containsMouse ? ThemeColors.surfaceHover : ThemeColors.surface
    border.width: 1
    border.color: highlighted ? ThemeColors.accent : toggleArea.containsMouse ? ThemeColors.textMuted : ThemeColors.border

    Behavior on border.color { ColorAnimation { duration: 120 } }

    Behavior on implicitHeight {
        NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
    }

    Timer {
        id: copiedTimer

        interval: 1200
        onTriggered: card.copiedKind = ""
    }

    component Chip: Rectangle {
        id: chip

        property string label

        signal clicked()

        width: chipText.implicitWidth + 16
        height: 22
        radius: 6
        color: chipArea.containsMouse ? ThemeColors.accent : ThemeColors.border
        border.width: 1
        border.color: chipArea.containsMouse ? ThemeColors.accent : ThemeColors.textMuted

        Text {
            id: chipText

            anchors.centerIn: parent
            text: chip.label
            color: chipArea.containsMouse ? ThemeColors.background : ThemeColors.text
            font.pixelSize: 9
            font.weight: Font.Medium
        }

        MouseArea {
            id: chipArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: chip.clicked()
        }
    }

    MouseArea {
        id: toggleArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: card.toggled()
    }

    Column {
        id: content

        spacing: 6

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 10
        }

        Item {
            width: parent.width
            height: 16

            Row {
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter

                Item {
                    width: 14
                    height: 14
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        id: iconImage

                        anchors.fill: parent
                        source: card.iconSource
                        sourceSize: Qt.size(28, 28)
                        visible: status === Image.Ready
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: iconImage.status !== Image.Ready
                        text: "󰂚"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 12
                        color: ThemeColors.textMuted
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: card.appName || "Unknown"
                    color: card.urgency === 2 ? ThemeColors.accent : ThemeColors.textMuted
                    font.pixelSize: 9
                    font.weight: Font.DemiBold
                }
            }

            Row {
                spacing: 6

                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: card.time
                    color: ThemeColors.textMuted
                    font.pixelSize: 9
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: card.expanded ? "▴" : "▾"
                    color: ThemeColors.textMuted
                    font.pixelSize: 10
                }
            }
        }

        Text {
            width: parent.width
            visible: text.length > 0
            text: card.summary
            color: ThemeColors.text
            font.pixelSize: 11
            font.weight: Font.Bold
            wrapMode: card.expanded ? Text.Wrap : Text.NoWrap
            elide: card.expanded ? Text.ElideNone : Text.ElideRight
            textFormat: Text.PlainText
        }

        Text {
            width: parent.width
            visible: text.length > 0
            text: card.body
            color: ThemeColors.textMuted
            font.pixelSize: 10
            wrapMode: card.expanded ? Text.Wrap : Text.NoWrap
            elide: card.expanded ? Text.ElideNone : Text.ElideRight
            textFormat: Text.PlainText
        }

        Column {
            width: parent.width
            spacing: 8
            visible: card.expanded

            Text {
                width: parent.width
                text: card.appName + "  ·  " + card.urgencyLabels[card.urgency] + "  ·  " + card.time
                color: ThemeColors.textMuted
                font.pixelSize: 9
                elide: Text.ElideRight
            }

            Flow {
                width: parent.width
                spacing: 6

                Chip {
                    label: card.copiedKind === "all" ? "Copied" : "Copy"
                    onClicked: card.copyText("all", card.body.length > 0 ? card.summary + "\n" + card.body : card.summary)
                }

                Chip {
                    visible: card.body.length > 0
                    label: card.copiedKind === "body" ? "Copied" : "Copy body"
                    onClicked: card.copyText("body", card.body)
                }

                Repeater {
                    model: card.actions

                    Chip {
                        required property var modelData

                        label: modelData.text
                        onClicked: NotificationService.invokeAction(card.notifId, modelData.identifier)
                    }
                }

                Chip {
                    label: "Dismiss"
                    onClicked: NotificationService.dismissById(card.notifId)
                }
            }
        }
    }
}