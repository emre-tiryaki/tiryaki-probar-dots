import QtQuick

// Icon + title/subtitle + switch. Tapping anywhere emits toggled().
Card {
    id: card

    property string icon
    property string title
    property string subtitle
    property bool checked: false

    signal toggled()

    height: 60
    hoverScale: 1
    border.width: 0
    onClicked: toggled()

    Icon {
        id: icon

        text: card.icon
        color: card.checked ? ThemeColors.text : ThemeColors.textMuted
        font.pixelSize: 22

        anchors {
            left: parent.left
            leftMargin: 14
            verticalCenter: parent.verticalCenter
        }
    }

    Column {
        spacing: 2

        anchors {
            left: parent.left
            leftMargin: 50
            right: toggle.left
            rightMargin: 12
            verticalCenter: parent.verticalCenter
        }

        Text {
            width: parent.width
            text: card.title
            color: ThemeColors.text
            font.pixelSize: 12
            font.weight: Font.DemiBold
        }

        Text {
            width: parent.width
            text: card.subtitle
            color: ThemeColors.textMuted
            font.pixelSize: 10
            elide: Text.ElideRight
        }
    }

    ToggleSwitch {
        id: toggle

        checked: card.checked
        onToggled: card.toggled()

        anchors {
            right: parent.right
            rightMargin: 14
            verticalCenter: parent.verticalCenter
        }
    }
}
