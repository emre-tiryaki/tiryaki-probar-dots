import QtQuick

Rectangle {
    id: tile

    property string icon
    property string title
    property string subtitle
    property bool active: false

    signal clicked()

    radius: 14
    color: active ? Qt.alpha(ThemeColors.accent, 0.14) : area.containsMouse ? ThemeColors.surfaceHover : ThemeColors.surface
    border.width: 1
    border.color: active ? ThemeColors.accent : area.containsMouse ? ThemeColors.textMuted : ThemeColors.border
    scale: area.pressed ? 0.97 : 1

    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }
    Behavior on scale { NumberAnimation { duration: 80 } }

    Row {
        spacing: 10

        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 14
            rightMargin: 12
        }

        Text {
            text: tile.icon
            color: tile.active ? ThemeColors.accent : ThemeColors.text
            font.family: "Symbols Nerd Font"
            font.pixelSize: 22
            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
            width: parent.width - 32
            spacing: 2
            anchors.verticalCenter: parent.verticalCenter

            Text {
                width: parent.width
                text: tile.title
                color: ThemeColors.text
                font.pixelSize: 11
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                text: tile.subtitle
                color: ThemeColors.textMuted
                font.pixelSize: 9
                elide: Text.ElideRight
            }
        }
    }

    MouseArea {
        id: area

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: tile.clicked()
    }
}