import QtQuick

Rectangle {
    id: root

    property string title
    property string description
    property string icon

    signal clicked()

    width: 145
    height: 78

    radius: 16

    color:
        hoverHandler.hovered
            ? ThemeColors.surfaceHover
            : ThemeColors.surface

    border.width: 1

    border.color:
        hoverHandler.hovered
            ? ThemeColors.accent
            : ThemeColors.border

    scale:
        hoverHandler.hovered
            ? 1.02
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

    Row {
        anchors {
            left: parent.left
            leftMargin: 13

            right: parent.right
            rightMargin: 8

            verticalCenter: parent.verticalCenter
        }

        spacing: 10

        Text {
            text: root.icon

            color:
                hoverHandler.hovered
                    ? ThemeColors.accent
                    : ThemeColors.text

            font.family:
                "Symbols Nerd Font"

            font.pixelSize: 23

            anchors.verticalCenter:
                parent.verticalCenter
        }

        Column {
            anchors.verticalCenter:
                parent.verticalCenter

            spacing: 3

            width:
                parent.width -
                33

            Text {
                text: root.title

                color:
                    ThemeColors.text

                font.pixelSize: 12
                font.weight:
                    Font.DemiBold

                width: parent.width

                elide:
                    Text.ElideRight
            }

            Text {
                text: root.description

                color:
                    ThemeColors.textMuted

                font.pixelSize: 9

                width: parent.width

                elide:
                    Text.ElideRight
            }
        }
    }

    HoverHandler {
        id: hoverHandler

        cursorShape:
            Qt.PointingHandCursor
    }

    TapHandler {
        onTapped:
            root.clicked()
    }
}