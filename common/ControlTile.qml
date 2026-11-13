import QtQuick

Card {
    id: tile

    property string icon
    property string title
    property string subtitle
    property bool active: false

    width: 180
    height: 64
    radius: 14
    hoverScale: 1
    color: active ? Qt.alpha(ThemeColors.accent, 0.14) : hovered ? ThemeColors.surfaceHover : ThemeColors.surface
    border.color: active ? ThemeColors.accent : hovered ? ThemeColors.textMuted : ThemeColors.border

    Row {
        spacing: 10

        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 14
            rightMargin: 12
        }

        Icon {
            text: tile.icon
            color: tile.active ? ThemeColors.accent : ThemeColors.text
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
}
