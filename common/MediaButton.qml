import QtQuick

Rectangle {
    id: button

    property var pal
    property string icon
    property int size: 30
    property bool primary: false
    property bool active: false
    property bool available: true

    signal clicked()

    width: primary ? 40 : size
    height: width
    radius: width / 2
    color: primary ? pal.accent : buttonHover.hovered && available ? pal.surface : "transparent"
    opacity: available ? 1 : 0.35
    scale: buttonHover.hovered && available ? 1.08 : 1

    Text {
        anchors.centerIn: parent
        text: button.icon
        color: button.primary ? button.pal.onAccent : button.active ? button.pal.accent : button.pal.text
        font.family: "Symbols Nerd Font"
        font.pixelSize: button.primary ? 20 : Math.round(button.size * 0.55)
    }

    Rectangle {
        visible: button.active && !button.primary
        width: 4
        height: 4
        radius: 2
        color: button.pal.accent

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 2
        }
    }

    HoverHandler {
        id: buttonHover

        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        enabled: button.available
        onTapped: button.clicked()
    }

    Behavior on scale {
        NumberAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }
    }
}