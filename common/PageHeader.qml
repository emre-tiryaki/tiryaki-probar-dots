import QtQuick

// Back button + title/subtitle. centered: false gives the left-aligned panel style.
Item {
    id: root

    property string title: ""
    property string subtitle: ""
    property bool showBack: true
    property bool centered: true

    signal backClicked()

    implicitWidth: 540
    implicitHeight: 48

    Card {
        id: backButton

        visible: root.showBack
        width: 40
        height: 40
        radius: 13
        hoverScale: 1.04
        anchors.verticalCenter: parent.verticalCenter
        onClicked: root.backClicked()

        Icon {
            anchors.centerIn: parent
            text: "󰁍"
            color: backButton.hovered ? ThemeColors.accent : ThemeColors.text
            font.pixelSize: 18
        }
    }

    Column {
        anchors.verticalCenter: parent.verticalCenter
        x: root.centered ? (parent.width - width) / 2 : (root.showBack ? backButton.width + 12 : 0)
        width: root.centered ? implicitWidth : parent.width - x
        spacing: 2

        Text {
            anchors.horizontalCenter: root.centered ? parent.horizontalCenter : undefined
            width: root.centered ? implicitWidth : parent.width
            text: root.title
            color: ThemeColors.text
            font.pixelSize: root.centered ? 15 : 16
            font.weight: Font.DemiBold
            elide: Text.ElideRight
        }

        Text {
            visible: root.subtitle !== ""
            anchors.horizontalCenter: root.centered ? parent.horizontalCenter : undefined
            width: root.centered ? implicitWidth : parent.width
            text: root.subtitle
            color: ThemeColors.textMuted
            font.pixelSize: root.centered ? 8 : 10
            elide: Text.ElideRight
        }
    }
}
