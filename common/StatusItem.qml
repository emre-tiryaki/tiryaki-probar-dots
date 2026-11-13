import QtQuick

// Collapsed-bar indicator: icon, optional label, optional badge.
// Draws a divider before itself unless it is the first item in its Row.
Row {
    id: root

    property string icon
    property color iconColor: ThemeColors.text
    property real iconOpacity: 1
    property string label: ""
    property string badge: ""

    spacing: 10

    Separator {
        vertical: true
        visible: !root.Positioner.isFirstItem
        anchors.verticalCenter: parent.verticalCenter
    }

    Row {
        spacing: 5
        anchors.verticalCenter: parent.verticalCenter

        Item {
            width: 22
            height: 22
            anchors.verticalCenter: parent.verticalCenter

            Icon {
                anchors.centerIn: parent
                text: root.icon
                color: root.iconColor
                opacity: root.iconOpacity

                Behavior on opacity { NumberAnimation { duration: 180 } }
            }

            Rectangle {
                visible: root.badge !== ""
                width: Math.max(12, badgeText.implicitWidth + 4)
                height: 12
                radius: 6
                color: ThemeColors.accent

                anchors {
                    top: parent.top
                    right: parent.right
                    topMargin: -2
                    rightMargin: -4
                }

                Text {
                    id: badgeText

                    anchors.centerIn: parent
                    text: root.badge
                    color: ThemeColors.background
                    font.pixelSize: 8
                    font.weight: Font.Bold
                }
            }
        }

        Text {
            visible: root.label !== ""
            text: root.label
            color: ThemeColors.text
            font.pixelSize: 11
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
