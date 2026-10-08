import "../../common"
import "../../services"
import QtQuick

Item {
    id: root

    signal backRequested()

    implicitWidth: 540
    implicitHeight: contentColumn.height + 20

    Column {
        id: contentColumn

        width: parent.width - 36
        height: childrenRect.height
        spacing: 12

        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }

        PageHeader {
            width: parent.width
            title: "GPU"
            subtitle: SystemStatsService.gpuAvailable ? SystemStatsService.gpuName : "GPU unavailable"
            onBackClicked: root.backRequested()
        }

        Rectangle {
            width: parent.width
            height: 120
            radius: 14
            color: ThemeColors.surface
            border.width: 1
            border.color: ThemeColors.border

            Row {
                spacing: 20

                anchors {
                    fill: parent
                    leftMargin: 18
                    rightMargin: 18
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 120

                    Text {
                        text: SystemStatsService.gpuAvailable ? Math.round(SystemStatsService.gpuUsage) + "%" : "—"
                        color: ThemeColors.text
                        font.pixelSize: 30
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: "GPU Usage"
                        color: ThemeColors.textMuted
                        font.pixelSize: 8
                    }

                }

                Rectangle {
                    width: 1
                    height: 64
                    anchors.verticalCenter: parent.verticalCenter
                    color: ThemeColors.border
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 5

                    Text {
                        width: 330
                        text: SystemStatsService.gpuAvailable ? SystemStatsService.gpuName : "GPU unavailable"
                        color: ThemeColors.text
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }

                    Text {
                        text: SystemStatsService.gpuAvailable ? Math.round(SystemStatsService.gpuTemperature) + "°C" : "Temperature unavailable"
                        color: ThemeColors.textMuted
                        font.pixelSize: 8
                    }

                }

            }

        }

        Text {
            text: "GPU Processes"
            color: ThemeColors.text
            font.pixelSize: 11
            font.weight: Font.DemiBold
        }

        Column {
            width: parent.width
            spacing: 7
            visible: SystemStatsService.gpuAvailable

            Repeater {
                model: SystemStatsService.gpuProcesses

                delegate: Rectangle {
                    width: parent.width
                    height: 62
                    radius: 12
                    color: ThemeColors.surface
                    border.width: 1
                    border.color: ThemeColors.border

                    Row {
                        spacing: 12

                        anchors {
                            fill: parent
                            leftMargin: 14
                            rightMargin: 14
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "󰢮"
                            color: ThemeColors.accent
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 18
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 130
                            spacing: 3

                            Text {
                                width: parent.width
                                text: modelData.name
                                color: ThemeColors.text
                                font.pixelSize: 9
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }

                            Text {
                                width: parent.width
                                text: "PID " + modelData.pid
                                color: ThemeColors.textMuted
                                font.pixelSize: 7
                            }

                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: Number(modelData.memory).toFixed(0) + " MB"
                                color: ThemeColors.text
                                font.pixelSize: 9
                                font.weight: Font.DemiBold
                            }

                            Text {
                                text: "VRAM"
                                color: ThemeColors.textMuted
                                font.pixelSize: 7
                            }

                        }

                    }

                }

            }

        }

        Rectangle {
            visible: SystemStatsService.gpuAvailable && SystemStatsService.gpuProcesses.length === 0
            width: parent.width
            height: 62
            radius: 12
            color: ThemeColors.surface
            border.width: 1
            border.color: ThemeColors.border

            Text {
                anchors.centerIn: parent
                text: "No GPU processes"
                color: ThemeColors.textMuted
                font.pixelSize: 9
            }

        }

        Rectangle {
            visible: !SystemStatsService.gpuAvailable
            width: parent.width
            height: 70
            radius: 12
            color: ThemeColors.surface
            border.width: 1
            border.color: ThemeColors.border

            Column {
                anchors.centerIn: parent
                spacing: 3

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "GPU unavailable"
                    color: ThemeColors.text
                    font.pixelSize: 9
                    font.weight: Font.DemiBold
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "No NVIDIA GPU data is available"
                    color: ThemeColors.textMuted
                    font.pixelSize: 7
                }

            }

        }

    }

}
