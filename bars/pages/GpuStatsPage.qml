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
            title: "GPU"
            subtitle: SystemStatsService.gpuName
            onBackClicked: root.backRequested()
        }

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
                            text: "GPU Usage"
                            color: ThemeColors.textMuted
                            font.pixelSize: 10
                            font.weight: Font.Medium
                        }

                        Text {
                            text: Math.round(SystemStatsService.gpuUsage) + "%"
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
                            text: SystemStatsService.gpuTemperature > 0 ? Math.round(SystemStatsService.gpuTemperature) + "°C" : "N/A"
                            color: ThemeColors.text
                            font.pixelSize: 17
                            font.weight: Font.DemiBold
                            horizontalAlignment: Text.AlignRight
                        }

                        Text {
                            width: parent.width
                            text: SystemStatsService.gpuProcesses.length + " processes"
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
                        width: parent.width * Math.max(0, Math.min(100, SystemStatsService.gpuUsage)) / 100
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

        Column {
            width: parent.width
            spacing: 7

            Text {
                text: "GPU Processes"
                color: ThemeColors.text
                font.pixelSize: 13
                font.weight: Font.DemiBold
            }

            Rectangle {
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
                            width: parent.width - 60 - 85
                            text: "Process"
                            color: ThemeColors.textMuted
                            font.pixelSize: 9
                            font.weight: Font.DemiBold
                        }

                        Text {
                            width: 85
                            text: "VRAM"
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
                                model: SystemStatsService.gpuProcesses

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
                                        width: parent.width - 60 - 85
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: modelData.process_name || modelData.command || "Unknown"
                                        color: ThemeColors.text
                                        font.pixelSize: 10
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        width: 85
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: modelData.used_memory !== undefined ? modelData.used_memory + " MiB" : "-"
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
