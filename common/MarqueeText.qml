import QtQuick

Item {
    id: root

    property string text
    property color color: "white"
    property int pixelSize: 15
    property int weight: Font.DemiBold
    readonly property real overflow: Math.max(0, label.implicitWidth - width)
    readonly property bool scrolling: overflow > 0 && visible

    function restart() {
        scroll.stop();
        label.x = 0;
        if (scrolling)
            scroll.start();
    }

    implicitHeight: label.implicitHeight
    clip: true
    onTextChanged: restart()
    onScrollingChanged: restart()
    onOverflowChanged: restart()

    Text {
        id: label

        text: root.text
        color: root.color
        font.pixelSize: root.pixelSize
        font.weight: root.weight
        wrapMode: Text.NoWrap
    }

    SequentialAnimation {
        id: scroll

        loops: Animation.Infinite

        PauseAnimation {
            duration: 1800
        }

        NumberAnimation {
            target: label
            property: "x"
            to: -root.overflow
            duration: Math.max(600, root.overflow * 30)
            easing.type: Easing.InOutSine
        }

        PauseAnimation {
            duration: 1200
        }

        NumberAnimation {
            target: label
            property: "x"
            to: 0
            duration: Math.max(600, root.overflow * 30)
            easing.type: Easing.InOutSine
        }
    }
}