import "../services"
import QtQuick

Item {
    id: root

    property real size: 18
    property color glyphColor: "white"

    width: size
    height: size

    Image {
        id: image

        anchors.fill: parent
        source: MediaService.sourceIconPath
        sourceSize.width: root.size * 2
        sourceSize.height: root.size * 2
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        visible: status === Image.Ready
    }

    Text {
        anchors.centerIn: parent
        visible: image.status !== Image.Ready
        text: MediaService.sourceIcon
        color: root.glyphColor
        font.family: "Symbols Nerd Font"
        font.pixelSize: root.size
    }
}