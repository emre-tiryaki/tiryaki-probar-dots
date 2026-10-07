import QtQuick

import "."

Rectangle {
    id: root

    property bool active: false
    property alias title: titleText.text
    property alias subtitle: subtitleText.text
    property alias icon: iconText.text

    signal clicked()

    property bool hovered: false
    property bool pressed: false

    width: 180
    height: 64

    radius: 16

    color: pressed
        ? ThemeColors.surfaceHover
        : hovered
            ? ThemeColors.surfaceHover
            : active
                ? ThemeColors.surfaceHover
                : ThemeColors.surface

    border.width: active ? 1 : 0
    border.color: ThemeColors.accent

    scale: pressed
        ? 0.97
        : hovered
            ? 1.01
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

    HoverHandler {
        cursorShape: Qt.PointingHandCursor

        onHoveredChanged: {
            root.hovered = hovered
        }
    }

    TapHandler {
        onPressedChanged: {
            root.pressed = pressed
        }

        onTapped: {
            root.clicked()
        }
    }

    Row {
        anchors {
            left: parent.left
            leftMargin: 14
            verticalCenter: parent.verticalCenter
        }

        spacing: 10

        Text {
            id: iconText

            color: root.active
                ? ThemeColors.text
                : ThemeColors.textMuted

            font.family: "Symbols Nerd Font"
            font.pixelSize: 22

            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
            spacing: 2

            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: titleText

                color: ThemeColors.text

                font.pixelSize: 12
                font.weight: Font.DemiBold
            }

            Text {
                id: subtitleText

                color: ThemeColors.textMuted

                font.pixelSize: 10

                elide: Text.ElideRight
                width: 125
            }
        }
    }
}