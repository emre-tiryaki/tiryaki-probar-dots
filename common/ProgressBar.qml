import QtQuick

// Read-only bar. value is 0..1.
Rectangle {
    id: bar

    property real value: 0
    property color fillColor: ThemeColors.accent

    height: 5
    radius: height / 2
    color: ThemeColors.background

    Rectangle {
        width: parent.width * Math.max(0, Math.min(1, bar.value))
        height: parent.height
        radius: parent.radius
        color: bar.fillColor

        Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
    }
}
