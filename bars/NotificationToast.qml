import QtQuick
import Quickshell
import Quickshell.Wayland
import "../common"
import "../services"
import "../state"

PanelWindow {
    id: win

    property int topOffset: 41
    property int rightOffset: 0

    visible: NotificationService.toasts.count > 0 && !BarState.rightExpanded
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: 390
    implicitHeight: Math.max(1, stack.implicitHeight)

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "probar-toast"

    anchors {
        top: true
        right: true
    }

    margins {
        top: win.topOffset
        right: win.rightOffset
    }

    Connections {
        target: BarState

        function onRightExpandedChanged() {
            if (BarState.rightExpanded)
                NotificationService.clearToasts()
        }
    }

    Column {
        id: stack

        spacing: 8

        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 160 }
        }

        move: Transition {
            NumberAnimation { properties: "y"; duration: 160; easing.type: Easing.OutCubic }
        }

        Repeater {
            model: NotificationService.toasts

            delegate: Rectangle {
                id: toast

                required property int notifId
                required property string summary
                required property string body
                required property string appName
                required property string appIcon
                required property int urgency
                required property int timeout

                readonly property string iconSource: {
                    if (appIcon.length === 0)
                        return ""
                    if (appIcon.startsWith("/"))
                        return "file://" + appIcon
                    return Quickshell.iconPath(appIcon, true)
                }

                width: 390
                height: toastContent.implicitHeight + 24
                radius: 14
                color: area.containsMouse ? ThemeColors.surfaceHover : ThemeColors.background
                border.width: 1
                border.color: urgency === 2 ? ThemeColors.accent : ThemeColors.border

                Timer {
                    interval: toast.timeout
                    running: !area.containsMouse
                    repeat: false
                    onTriggered: NotificationService.expireToast(toast.notifId)
                }

                MouseArea {
                    id: area

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NotificationService.openFromToast(toast.notifId)
                }

                Item {
                    id: toastContent

                    implicitHeight: Math.max(textCol.implicitHeight, 28)

                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: 12
                    }

                    Item {
                        id: iconBox

                        width: 28
                        height: 28

                        Image {
                            id: iconImage

                            anchors.fill: parent
                            source: toast.iconSource
                            sourceSize: Qt.size(56, 56)
                            visible: status === Image.Ready
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: iconImage.status !== Image.Ready
                            text: "󰂚"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 20
                            color: ThemeColors.textMuted
                        }
                    }

                    Column {
                        id: textCol

                        spacing: 2

                        anchors {
                            left: iconBox.right
                            right: closeBtn.left
                            top: parent.top
                            leftMargin: 10
                            rightMargin: 8
                        }

                        Text {
                            width: parent.width
                            visible: text.length > 0
                            text: toast.appName
                            color: ThemeColors.textMuted
                            font.pixelSize: 9
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            visible: text.length > 0
                            text: toast.summary
                            color: ThemeColors.text
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            visible: text.length > 0
                            text: toast.body
                            color: ThemeColors.textMuted
                            font.pixelSize: 10
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            textFormat: Text.PlainText
                        }
                    }

                    Item {
                        id: closeBtn

                        width: 18
                        height: 18

                        anchors {
                            right: parent.right
                            top: parent.top
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "󰅖"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 13
                            color: ThemeColors.textMuted
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: NotificationService.expireToast(toast.notifId)
                        }
                    }
                }
            }
        }
    }
}