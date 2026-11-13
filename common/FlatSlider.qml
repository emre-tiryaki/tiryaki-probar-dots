import QtQuick

Item {
    id: slider

    property var pal: null // optional palette { track, accent, text }; defaults to theme
    property color trackColor: pal ? pal.track : ThemeColors.border
    property color fillColor: pal ? pal.accent : ThemeColors.accent
    property color knobColor: pal ? pal.text : ThemeColors.text
    property real value: 0
    property bool interactive: true
    property real thickness: 5
    property real dragValue: 0
    readonly property bool dragging: area.pressed
    readonly property real shown: dragging ? dragValue : Math.max(0, Math.min(1, value))

    signal moved(real v)
    signal committed(real v)

    height: 16

    Rectangle {
        id: groove

        width: parent.width
        height: slider.thickness
        radius: height / 2
        color: slider.trackColor
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
            width: parent.width * slider.shown
            height: parent.height
            radius: parent.radius
            color: slider.fillColor

            Behavior on width {
                enabled: !slider.dragging

                NumberAnimation {
                    duration: 200
                }
            }
        }
    }

    Rectangle {
        width: slider.thickness + 7
        height: width
        radius: width / 2
        color: slider.knobColor
        x: groove.width * slider.shown - width / 2
        anchors.verticalCenter: parent.verticalCenter
        opacity: slider.interactive && (area.containsMouse || slider.dragging) ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 120
            }
        }
    }

    MouseArea {
        id: area

        function update(px) {
            slider.dragValue = Math.max(0, Math.min(1, px / width));
            slider.moved(slider.dragValue);
        }

        anchors.fill: parent
        enabled: slider.interactive
        hoverEnabled: true
        preventStealing: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onPressed: mouse => update(mouse.x)
        onPositionChanged: mouse => {
            if (pressed)
                update(mouse.x);
        }
        onReleased: slider.committed(slider.dragValue)
    }
}