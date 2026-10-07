import QtQuick

import "../common"

Rectangle {
    id: root

    width: 140
    height: 30

    topLeftRadius: 0
    topRightRadius: 0
    bottomLeftRadius: height / 2
    bottomRightRadius: height / 2

    color: ThemeColors.background

    Text {
        anchors.centerIn: parent

        text: "CENTER"

        color: ThemeColors.text

        font.pixelSize: 12
        font.weight: Font.DemiBold
    }
}