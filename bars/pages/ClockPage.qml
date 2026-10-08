import QtQuick

import "../../common"

Item {
    id: root

    signal backRequested()

    implicitWidth: 380
    implicitHeight: content.height + 24

    Rectangle {
        anchors.fill: parent

        radius: 18
        color: ThemeColors.background

        clip: true
    }

    Column {
        id: content

        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }

        y: 12

        spacing: 16

        PageHeader {
            width: 356
            height: 48

            title: "Clock"
            subtitle: "Current time and date"

            onBackClicked:
                root.backRequested()
        }

        Column {
            width: 356

            anchors.horizontalCenter: parent.horizontalCenter

            spacing: 5

            Text {
                id: timeText

                width: parent.width

                horizontalAlignment: Text.AlignHCenter

                color: ThemeColors.text

                font.pixelSize: 46
                font.weight: Font.DemiBold

                text: Qt.formatTime(
                    new Date(),
                    "HH:mm:ss"
                )
            }

            Text {
                id: dateText
                
                width: parent.width

                horizontalAlignment: Text.AlignHCenter

                color: ThemeColors.textMuted

                font.pixelSize: 11
                font.weight: Font.Medium

                text: Qt.formatDate(
                    new Date(),
                    "dddd, dd MMMM yyyy"
                )
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            const now = new Date()

            timeText.text =
                Qt.formatTime(now, "HH:mm:ss")

            dateText.text =
                Qt.formatDate(now, "dddd, dd, MMMM ,yyyy")
        }
    }
}