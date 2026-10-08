import QtQuick

Item {
    id: root

    property string label
    property string detail: ""
    property real value: 0
    property real temperature: -1
    property bool clickable: true

    signal clicked()

    width: 150
    height: 190

    Rectangle {
        id: circle

        width: 128
        height: 128
        radius: width / 2
        color: ThemeColors.surface
        border.width: 1
        border.color: hoverHandler.hovered && root.clickable ? ThemeColors.accent : ThemeColors.border
        scale: hoverHandler.hovered && root.clickable ? 1.035 : 1

        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }

        Canvas {
            id: gauge

            anchors.fill: parent
            onPaint: {
                const ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                const centerX = width / 2;
                const centerY = height / 2;
                const radius = width / 2 - 10;
                ctx.lineWidth = 7;
                ctx.lineCap = "round";
                // Background ring
                ctx.beginPath();
                ctx.arc(centerX, centerY, radius, 0, Math.PI * 2);
                ctx.strokeStyle = ThemeColors.background;
                ctx.stroke();
                // Value ring
                if (root.value > 0) {
                    ctx.beginPath();
                    ctx.arc(centerX, centerY, radius, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * Math.min(100, Math.max(0, root.value)) / 100);
                    ctx.strokeStyle = ThemeColors.accent;
                    ctx.stroke();
                }
            }
            Component.onCompleted: {
                requestPaint();
            }

            Connections {
                function onValueChanged() {
                    gauge.requestPaint();
                }

                target: root
            }

        }

        Column {
            anchors.centerIn: parent
            spacing: 1

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Math.round(root.value) + "%"
                color: ThemeColors.text
                font.pixelSize: 25
                font.weight: Font.DemiBold
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.label
                color: ThemeColors.textMuted
                font.pixelSize: 10
                font.weight: Font.Medium
            }

        }

        HoverHandler {
            id: hoverHandler

            enabled: root.clickable
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            enabled: root.clickable
            onTapped: root.clicked()
        }

        Behavior on scale {
            NumberAnimation {
                duration: 140
                easing.type: Easing.OutCubic
            }

        }

        Behavior on border.color {
            ColorAnimation {
                duration: 140
            }

        }

    }

    Text {
        text: root.temperature >= 0 ? Math.round(root.temperature) + "°C" : root.detail
        horizontalAlignment: Text.AlignHCenter
        color: ThemeColors.text
        font.pixelSize: 10
        font.weight: Font.DemiBold
        elide: Text.ElideMiddle
        maximumLineCount: 1

        anchors {
            top: circle.bottom
            topMargin: 8
            left: parent.left
            right: parent.right
        }

    }

    Text {
        visible: root.temperature >= 0 && root.detail !== ""
        text: root.detail
        horizontalAlignment: Text.AlignHCenter
        color: ThemeColors.textMuted
        font.pixelSize: 8
        elide: Text.ElideMiddle
        maximumLineCount: 1

        anchors {
            top: circle.bottom
            topMargin: 26
            left: parent.left
            right: parent.right
        }

    }

}
