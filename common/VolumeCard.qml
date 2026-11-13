import QtQuick
import Quickshell

// Icon + title + percentage + draggable volume bar.
// value is 0..maxValue; moved(v) fires while dragging, clicked() on tap outside the bar.
Rectangle {
    id: card

    property string icon
    property string iconName: ""     // optional desktop icon name, shown instead of `icon`
    property string title
    property string subtitle: ""
    property color subtitleColor: ThemeColors.textMuted
    property real value: 0
    property real maxValue: 1        // slider range upper bound (e.g. 2 for 200%)
    property bool muted: false
    property bool highlighted: false

    signal moved(real value)
    signal clicked()

    height: 76
    radius: 15
    color: highlighted ? ThemeColors.surfaceHover : ThemeColors.surface
    border.width: 1
    border.color: highlighted ? ThemeColors.accent : hover.hovered ? ThemeColors.textMuted : ThemeColors.border

    Behavior on border.color { ColorAnimation { duration: 120 } }

    HoverHandler {
        id: hover
    }

    TapHandler {
        onTapped: card.clicked()
    }

    Column {
        spacing: 6

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: 14
            rightMargin: 14
            topMargin: 11
        }

        Row {
            width: parent.width
            height: 32
            spacing: 9

            Item {
                width: 24
                height: 24
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    id: appIcon

                    anchors.centerIn: parent
                    width: 22
                    height: 22
                    fillMode: Image.PreserveAspectFit
                    source: card.iconName !== "" ? Quickshell.iconPath(card.iconName, true) : ""
                    visible: status === Image.Ready
                }

                Icon {
                    anchors.centerIn: parent
                    visible: !appIcon.visible
                    text: card.icon
                    color: card.muted ? ThemeColors.textMuted : ThemeColors.text
                    font.pixelSize: 20
                }
            }

            Column {
                width: parent.width - 75
                spacing: 1
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    width: parent.width
                    text: card.title
                    color: ThemeColors.text
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    visible: card.subtitle !== ""
                    text: card.subtitle
                    color: card.subtitleColor
                    font.pixelSize: 9
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
            }

            Text {
                text: Math.round(card.value * 100) + "%"
                color: ThemeColors.textMuted
                font.pixelSize: 10
                font.weight: Font.DemiBold
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        FlatSlider {
            width: parent.width
            height: 10
            value: card.value / card.maxValue
            fillColor: card.muted ? ThemeColors.textMuted : card.value > 1 ? ThemeColors.warning : ThemeColors.accent
            onMoved: v => card.moved(v * card.maxValue)
        }
    }
}
