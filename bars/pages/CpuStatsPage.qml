import "../../common"
import "../../services"
import QtQuick

Item {
    id: root

    signal backRequested()

    function formatBytes(bytes) {
        if (!bytes || bytes <= 0)
            return "0 B";

        if (bytes >= 1024 * 1024 * 1024)
            return (bytes / 1024 / 1024 / 1024).toFixed(1) + " GB";

        if (bytes >= 1024 * 1024)
            return (bytes / 1024 / 1024).toFixed(1) + " MB";

        if (bytes >= 1024)
            return (bytes / 1024).toFixed(1) + " KB";

        return bytes + " B";
    }

    implicitWidth: 540
    implicitHeight: contentColumn.height + 24

    Column {
        id: contentColumn

        width: parent.width
        spacing: 12

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        PageHeader {
            width: parent.width
            title: "CPU"
            subtitle: SystemStatsService.cpuModel
            onBackClicked: root.backRequested()
        }

        // CPU summary
        Rectangle {
            width: parent.width
            height: 86
            radius: 14
            color: ThemeColors.surface
            border.width: 1
            border.color: ThemeColors.border

            Row {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 24

                Column {
                    width: 110
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Text {
                        text: "Usage"
                        color: ThemeColors.textMuted
                        font.pixelSize: 9
                    }

                    Text {
                        text: Math.round(SystemStatsService.cpuUsage) + "%"
                        color: ThemeColors.text
                        font.pixelSize: 24
                        font.weight: Font.DemiBold
                    }

                }

                Column {
                    width: 110
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Text {
                        text: "Temperature"
                        color: ThemeColors.textMuted
                        font.pixelSize: 9
                    }

                    Text {
                        text: SystemStatsService.cpuTemperature > 0 ? Math.round(SystemStatsService.cpuTemperature) + "°C" : "N/A"
                        color: ThemeColors.text
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                    }

                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Text {
                        text: "Cores"
                        color: ThemeColors.textMuted
                        font.pixelSize: 9
                    }

                    Text {
                        text: SystemStatsService.cpuCores.length
                        color: ThemeColors.text
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                    }

                }

            }

        }

        // Per-core usage
        Rectangle {
            width: parent.width
            height: 180
            radius: 14
            color: ThemeColors.surface
            border.width: 1
            border.color: ThemeColors.border

            Column {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                Text {
                    text: "Core Usage"
                    color: ThemeColors.text
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                }

                Row {
                    width: parent.width
                    height: 130
                    spacing: 8

                    Repeater {
                        model: SystemStatsService.cpuCores

                        delegate: Column {
                            width: Math.max(28, (parent.width - (SystemStatsService.cpuCores.length - 1) * 8) / Math.max(1, SystemStatsService.cpuCores.length))
                            spacing: 5

                            Item {
                                width: parent.width
                                height: 100

                                Rectangle {
                                    width: 8
                                    height: Math.max(2, parent.height * Math.min(100, Math.max(0, modelData)) / 100)
                                    radius: 4
                                    color: ThemeColors.accent

                                    anchors {
                                        bottom: parent.bottom
                                        horizontalCenter: parent.horizontalCenter
                                    }

                                    Behavior on height {
                                        NumberAnimation {
                                            duration: 250
                                            easing.type: Easing.OutCubic
                                        }

                                    }

                                }

                            }

                            Text {
                                width: parent.width
                                text: "C" + index
                                color: ThemeColors.textMuted
                                font.pixelSize: 7
                                horizontalAlignment: Text.AlignHCenter
                            }

                        }

                    }

                }

            }

        }

        // Process list
        Column {
            width: parent.width
            spacing: 8

            Text {
                text: "Top Processes"
                color: ThemeColors.text
                font.pixelSize: 11
                font.weight: Font.DemiBold
            }

            Rectangle {
                width: parent.width
                height: Math.max(90, 16 + SystemStatsService.processes.length * 70)
                radius: 14
                color: ThemeColors.surface
                border.width: 1
                border.color: ThemeColors.border

                Column {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 4

                    Repeater {
                        model: SystemStatsService.processes

                        delegate: Item {
                            required property var modelData

                            width: parent.width
                            height: 66

                            Column {
                                anchors.fill: parent
                                spacing: 3

                                Row {
                                    width: parent.width
                                    height: 17

                                    Text {
                                        width: parent.width - cpuText.width - 12
                                        text: modelData.command !== "" ? modelData.command : "Unknown process"
                                        color: ThemeColors.text
                                        font.pixelSize: 9
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        id: cpuText

                                        width: 52
                                        text: Number(modelData.cpu || 0).toFixed(1) + "%"
                                        color: ThemeColors.accent
                                        font.pixelSize: 9
                                        font.weight: Font.DemiBold
                                        horizontalAlignment: Text.AlignRight
                                    }

                                }

                                Text {
                                    width: parent.width
                                    text: modelData.args !== "" ? modelData.args : modelData.command
                                    color: ThemeColors.textMuted
                                    font.pixelSize: 7
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                }

                                Row {
                                    width: parent.width
                                    height: 16
                                    spacing: 16

                                    Text {
                                        text: "PID " + String(modelData.pid || "-")
                                        color: ThemeColors.textMuted
                                        font.pixelSize: 7
                                    }

                                    Text {
                                        text: "User " + String(modelData.user || "-")
                                        color: ThemeColors.textMuted
                                        font.pixelSize: 7
                                    }

                                    Text {
                                        text: "RAM " + Number(modelData.memory || 0).toFixed(1) + "%"
                                        color: ThemeColors.textMuted
                                        font.pixelSize: 7
                                    }

                                    Text {
                                        text: "RSS " + root.formatBytes(Number(modelData.rssKb || 0) * 1024)
                                        color: ThemeColors.textMuted
                                        font.pixelSize: 7
                                    }

                                    Text {
                                        text: "Time " + String(modelData.elapsed || "-")
                                        color: ThemeColors.textMuted
                                        font.pixelSize: 7
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
