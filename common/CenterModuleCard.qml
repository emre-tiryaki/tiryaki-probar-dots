import QtQuick

Card {
    id: root

    property string title
    property string description
    property string icon

    width: 145
    height: 78

    Row {
        spacing: 10

        anchors {
            left: parent.left
            leftMargin: 13
            right: parent.right
            rightMargin: 8
            verticalCenter: parent.verticalCenter
        }

        Icon {
            text: root.icon
            color: root.hovered ? ThemeColors.accent : ThemeColors.text
            font.pixelSize: 23
            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
            width: parent.width - 33
            spacing: 3
            anchors.verticalCenter: parent.verticalCenter

            Text {
                width: parent.width
                text: root.title
                color: ThemeColors.text
                font.pixelSize: 12
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                text: root.description
                color: ThemeColors.textMuted
                font.pixelSize: 9
                elide: Text.ElideRight
            }
        }
    }
}
