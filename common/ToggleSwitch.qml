import QtQuick

Rectangle {
    id: toggle

    property bool checked: false

    signal toggled()

    width: 42
    height: 24
    radius: height / 2
    color: checked ? ThemeColors.accent : ThemeColors.background

    Behavior on color { ColorAnimation { duration: 180 } }

    Rectangle {
        width: 18
        height: 18
        radius: 9
        anchors.verticalCenter: parent.verticalCenter
        x: toggle.checked ? parent.width - width - 3 : 3
        color: ThemeColors.text

        Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
    }

    TapHandler {
        cursorShape: Qt.PointingHandCursor
        onTapped: toggle.toggled()
    }
}
