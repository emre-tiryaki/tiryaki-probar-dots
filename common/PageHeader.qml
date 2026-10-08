import QtQuick

Item {
    id: root

    property string title: ""
    property string subtitle: ""

    property bool showBack: true

    signal backClicked()

    implicitWidth: 540
    implicitHeight: 48

    Rectangle {
        id: backButton

        visible: root.showBack

        width: 40
        height: 40

        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }

        radius: 13

        color:
            backHover.hovered
                ? ThemeColors.surfaceHover
                : ThemeColors.surface

        border.width: 1

        border.color:
            backHover.hovered
                ? ThemeColors.accent
                : ThemeColors.border

        scale:
            backHover.hovered
                ? 1.04
                : 1.0

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

        Text {
            anchors.centerIn: parent

            text: "󰁍"

            color:
                backHover.hovered
                    ? ThemeColors.accent
                    : ThemeColors.text

            font.family: "Symbols Nerd Font"
            font.pixelSize: 18

            Behavior on color {
                ColorAnimation {
                    duration: 120
                }
            }
        }

        HoverHandler {
            id: backHover

            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped:
                root.backClicked()
        }
    }

    Column {
        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }

        spacing:
            root.subtitle !== ""
                ? 2
                : 0

        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: root.title

            color: ThemeColors.text

            font.pixelSize: 15
            font.weight: Font.DemiBold

            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            visible: root.subtitle !== ""

            anchors.horizontalCenter: parent.horizontalCenter

            text: root.subtitle

            color: ThemeColors.textMuted

            font.pixelSize: 8

            horizontalAlignment: Text.AlignHCenter

            elide: Text.ElideRight
        }
    }
}