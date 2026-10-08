import "../../common"
import "../../services"
import QtQuick

Item {
    id: root

    property real horizontalPadding: 16
    property real topPadding: 12
    property real bottomPadding: 16

    signal backRequested()

    implicitWidth: 540
    implicitHeight: contentColumn.y + contentColumn.height + root.bottomPadding

    Rectangle {
        id: surface

        anchors.fill: parent
        radius: 18
        color: ThemeColors.background
        clip: true
    }

    Column {
        id: contentColumn

        width: parent.width - root.horizontalPadding * 2
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.topPadding
        spacing: 12

        PageHeader {
            width: parent.width
            height: 48
            title: "CPU"
            subtitle: SystemStatsService.cpuModel
            onBackClicked: root.backRequested()
        }

        // CPU summary
        Rectangle {
            width: parent.width
            height: 118
            radius: 16
            color: ThemeColors.surface
            border.width: 1
            border.color: ThemeColors.border

            Column {
                anchors.fill: parent
                spacing: 10

                anchors {
                    leftMargin: 16
                    rightMargin: 16
                    topMargin: 14
                    bottomMargin: 14
                }

                Row {
                    width: parent.width
                    height: 58

                    Column {
                        width: parent.width - 150
                        spacing: 2

                        Text {
                            text: "CPU Usage"
                            color: ThemeColors.textMuted
                            font.pixelSize: 10
                            font.weight: Font.Medium
                        }

                        Text {
                            text: Math.round(SystemStatsService.cpuUsage) + "%"
                            color: ThemeColors.text
                            font.pixelSize: 30
                            font.weight: Font.DemiBold
                        }

                    }

                    Column {
                        width: 150
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 3

                        Text {
                            width: parent.width
                            text: "Temperature"
                            color: ThemeColors.textMuted
                            font.pixelSize: 9
                            horizontalAlignment: Text.AlignRight
                        }

                        Text {
                            width: parent.width
                            text: SystemStatsService.cpuTemperature > 0 ? Math.round(SystemStatsService.cpuTemperature) + "°C" : "N/A"
                            color: ThemeColors.text
                            font.pixelSize: 17
                            font.weight: Font.DemiBold
                            horizontalAlignment: Text.AlignRight
                        }

                        Text {
                            width: parent.width
                            text: SystemStatsService.cpuCores.length + " cores"
                            color: ThemeColors.textMuted
                            font.pixelSize: 8
                            horizontalAlignment: Text.AlignRight
                        }

                    }

                }

                Rectangle {
                    width: parent.width
                    height: 5
                    radius: 3
                    color: ThemeColors.background

                    Rectangle {
                        width: parent.width * Math.max(0, Math.min(100, SystemStatsService.cpuUsage)) / 100
                        height: parent.height
                        radius: 3
                        color: ThemeColors.accent

                        Behavior on width {
                            NumberAnimation {
                                duration: 250
                                easing.type: Easing.OutCubic
                            }

                        }

                    }

                }

            }

        }

        // Per-core usage
        Rectangle {
            width: parent.width
            height: 176
            radius: 14
            color: ThemeColors.surface
            border.width: 1
            border.color: ThemeColors.border

            Column {
                anchors.fill: parent
                spacing: 8

                anchors {
                    leftMargin: 15
                    rightMargin: 15
                    topMargin: 13
                    bottomMargin: 10
                }

                Text {
                    text: "Core Usage"
                    color: ThemeColors.text
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                }

                Row {
                    id: coreRow

                    width: parent.width
                    height: 122
                    spacing: 6

                    Repeater {
                        model: SystemStatsService.cpuCores

                        delegate: Item {
                            required property var modelData
                            required property int index
                            property real usage: typeof modelData === "number" ? modelData : Number(modelData.usage !== undefined ? modelData.usage : modelData.value !== undefined ? modelData.value : 0)

                            width: (coreRow.width - (Math.max(1, SystemStatsService.cpuCores.length) - 1) * coreRow.spacing) / Math.max(1, SystemStatsService.cpuCores.length)
                            height: coreRow.height

                            Column {
                                anchors.fill: parent
                                spacing: 5

                                Item {
                                    width: parent.width
                                    height: 96

                                    Rectangle {
                                        width: 8
                                        height: Math.max(2, parent.height * Math.min(100, Math.max(0, parent.parent.parent.usage)) / 100)
                                        radius: 4
                                        color: ThemeColors.accent

                                        anchors {
                                            bottom: parent.bottom
                                            horizontalCenter: parent.horizontalCenter
                                        }

                                    }

                                }

                                Text {
                                    width: parent.width
                                    text: "C" + index
                                    color: ThemeColors.textMuted
                                    font.pixelSize: 9
                                    horizontalAlignment: Text.AlignHCenter
                                }

                            }

                        }

                    }

                }

            }

        }

        // Top processes
        Column {
            width: parent.width
            spacing: 7

            Text {
                text: "Top Processes"
                color: ThemeColors.text
                font.pixelSize: 13
                font.weight: Font.DemiBold
            }

            Rectangle {
                id: processPanel

                width: parent.width
                height: 220
                radius: 14
                color: ThemeColors.surface
                border.width: 1
                border.color: ThemeColors.border
                clip: true

                Column {
                    anchors.fill: parent
                    spacing: 0

                    anchors {
                        leftMargin: 14
                        rightMargin: 14
                        topMargin: 9
                        bottomMargin: 9
                    }

                    Row {
                        width: parent.width
                        height: 26

                        Text {
                            width: 60
                            text: "PID"
                            color: ThemeColors.textMuted
                            font.pixelSize: 9
                            font.weight: Font.DemiBold
                        }

                        Text {
                            width: parent.width - 60 - 65
                            text: "Process"
                            color: ThemeColors.textMuted
                            font.pixelSize: 9
                            font.weight: Font.DemiBold
                        }

                        Text {
                            width: 65
                            text: "CPU"
                            color: ThemeColors.textMuted
                            font.pixelSize: 9
                            font.weight: Font.DemiBold
                            horizontalAlignment: Text.AlignRight
                        }

                    }

                    Flickable {
                        id: processFlickable

                        width: parent.width
                        height: parent.height - 26
                        clip: true
                        contentWidth: width
                        contentHeight: processColumn.height
                        boundsBehavior: Flickable.StopAtBounds
                        interactive: contentHeight > height

                        Column {
                            id: processColumn

                            width: processFlickable.width
                            spacing: 0

                            Repeater {
                                model: SystemStatsService.processes

                                delegate: Row {
                                    required property var modelData

                                    width: parent.width
                                    height: 32

                                    Text {
                                        width: 60
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: String(modelData.pid || "-")
                                        color: ThemeColors.textMuted
                                        font.pixelSize: 10
                                    }

                                    Text {
                                        width: parent.width - 60 - 65
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: modelData.command !== "" ? modelData.command : "Unknown"
                                        color: ThemeColors.text
                                        font.pixelSize: 10
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        width: 65
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: Number(modelData.cpu || 0).toFixed(1) + "%"
                                        color: ThemeColors.accent
                                        font.pixelSize: 10
                                        font.weight: Font.DemiBold
                                        horizontalAlignment: Text.AlignRight
                                    }

                                }

                            }

                        }

                    }

                }

            }

        }

    }

}
