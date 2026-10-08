import "../../common"
import "../../services"
import QtQuick

Item {
    id: root

    signal backRequested()
    signal cpuClicked()
    signal gpuClicked()

    function formatBytes(bytes) {
        if (!bytes || bytes <= 0)
            return "0 B";

        if (bytes >= 1024 * 1024 * 1024 * 1024)
            return (bytes / 1024 / 1024 / 1024 / 1024).toFixed(1) + " TB";

        if (bytes >= 1024 * 1024 * 1024)
            return (bytes / 1024 / 1024 / 1024).toFixed(1) + " GB";

        if (bytes >= 1024 * 1024)
            return (bytes / 1024 / 1024).toFixed(1) + " MB";

        if (bytes >= 1024)
            return (bytes / 1024).toFixed(1) + " KB";

        return bytes + " B";
    }

    implicitWidth: 540
    implicitHeight: contentColumn.height + 20

    Column {
        id: contentColumn

        width: parent.width - 36
        spacing: 12

        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }

        PageHeader {
            width: parent.width
            title: "System Stats"
            subtitle: "Hardware usage and storage"
            onBackClicked: root.backRequested()
        }

        Rectangle {
            width: parent.width
            height: 1
            color: ThemeColors.border
            opacity: 0.6
        }

        Row {
            width: parent.width
            spacing: 10

            SystemStatGauge {
                width: (parent.width - 20) / 3
                label: "CPU"
                value: SystemStatsService.cpuUsage
                temperature: SystemStatsService.cpuTemperature
                detail: SystemStatsService.cpuModel
                onClicked: root.cpuClicked()
            }

            SystemStatGauge {
                width: (parent.width - 20) / 3
                label: "RAM"
                value: SystemStatsService.memoryUsage
                detail: SystemStatsService.memoryTotal > 0 ? ((SystemStatsService.memoryUsed / 1024 / 1024 / 1024).toFixed(1) + " / " + (SystemStatsService.memoryTotal / 1024 / 1024 / 1024).toFixed(1) + " GB") : "Unavailable"
                clickable: false
            }

            SystemStatGauge {
                width: (parent.width - 20) / 3
                label: "GPU"
                value: SystemStatsService.gpuAvailable ? SystemStatsService.gpuUsage : 0
                temperature: SystemStatsService.gpuAvailable ? SystemStatsService.gpuTemperature : -1
                detail: SystemStatsService.gpuAvailable ? SystemStatsService.gpuName : "GPU unavailable"
                clickable: SystemStatsService.gpuAvailable
                onClicked: root.gpuClicked()
            }

        }

        Text {
            text: "Storage"
            color: ThemeColors.text
            font.pixelSize: 11
            font.weight: Font.DemiBold
        }

        Column {
            width: parent.width
            spacing: 7

            Repeater {
                model: SystemStatsService.disks

                delegate: Rectangle {
                    width: parent.width
                    height: 72
                    radius: 12
                    color: ThemeColors.surface
                    border.width: 1
                    border.color: ThemeColors.border

                    Column {
                        spacing: 6

                        anchors {
                            fill: parent
                            leftMargin: 14
                            rightMargin: 14
                            topMargin: 11
                            bottomMargin: 11
                        }

                        Row {
                            width: parent.width
                            height: 18

                            Text {
                                width: parent.width - percentage.width
                                text: modelData.filesystem !== "" ? modelData.filesystem : "Disk"
                                color: ThemeColors.text
                                font.pixelSize: 9
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }

                            Text {
                                id: percentage

                                width: 45
                                text: Math.round(Math.max(0, Math.min(100, modelData.usage))) + "%"
                                color: ThemeColors.text
                                font.pixelSize: 9
                                font.weight: Font.DemiBold
                                horizontalAlignment: Text.AlignRight
                            }

                        }

                        Row {
                            width: parent.width
                            height: 10

                            Text {
                                width: parent.width - sizeText.width - 8
                                text: modelData.mountPoint !== "" ? modelData.mountPoint : "Unknown mount"
                                color: ThemeColors.textMuted
                                font.pixelSize: 7
                                elide: Text.ElideRight
                            }

                            Text {
                                id: sizeText

                                width: 120
                                text: formatBytes(modelData.used) + " / " + formatBytes(modelData.total)
                                color: ThemeColors.textMuted
                                font.pixelSize: 7
                                horizontalAlignment: Text.AlignRight
                            }

                        }

                        Rectangle {
                            width: parent.width
                            height: 4
                            radius: 2
                            color: ThemeColors.background

                            Rectangle {
                                width: parent.width * Math.max(0, Math.min(100, modelData.usage)) / 100
                                height: parent.height
                                radius: 2
                                color: modelData.usage >= 90 ? "#f38ba8" : modelData.usage >= 75 ? "#fab387" : ThemeColors.accent

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

            }

        }

        Text {
            visible: SystemStatsService.externalDisks.length > 0
            text: "External Storage"
            color: ThemeColors.text
            font.pixelSize: 11
            font.weight: Font.DemiBold
            topPadding: 4
        }

        Column {
            width: parent.width
            spacing: 7
            visible: SystemStatsService.externalDisks.length > 0

            Repeater {
                model: SystemStatsService.externalDisks

                delegate: Rectangle {
                    width: parent.width
                    height: 72
                    radius: 12
                    color: ThemeColors.surface
                    border.width: 1
                    border.color: ThemeColors.border

                    Column {
                        spacing: 6

                        anchors {
                            fill: parent
                            leftMargin: 14
                            rightMargin: 14
                            topMargin: 11
                            bottomMargin: 11
                        }

                        Row {
                            width: parent.width
                            height: 18

                            Text {
                                width: parent.width - percentage.width
                                text: modelData.filesystem !== "" ? modelData.filesystem : "External Disk"
                                color: ThemeColors.text
                                font.pixelSize: 9
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }

                            Text {
                                id: percentage

                                width: 45
                                text: Math.round(Math.max(0, Math.min(100, modelData.usage))) + "%"
                                color: ThemeColors.text
                                font.pixelSize: 9
                                font.weight: Font.DemiBold
                                horizontalAlignment: Text.AlignRight
                            }

                        }

                        Row {
                            width: parent.width
                            height: 10

                            Text {
                                width: parent.width - sizeText.width - 8
                                text: modelData.mountPoint !== "" ? modelData.mountPoint : "Unknown mount"
                                color: ThemeColors.textMuted
                                font.pixelSize: 7
                                elide: Text.ElideRight
                            }

                            Text {
                                id: sizeText

                                width: 120
                                text: formatBytes(modelData.used) + " / " + formatBytes(modelData.total)
                                color: ThemeColors.textMuted
                                font.pixelSize: 7
                                horizontalAlignment: Text.AlignRight
                            }

                        }

                        Rectangle {
                            width: parent.width
                            height: 4
                            radius: 2
                            color: ThemeColors.background

                            Rectangle {
                                width: parent.width * Math.max(0, Math.min(100, modelData.usage)) / 100
                                height: parent.height
                                radius: 2
                                color: modelData.usage >= 90 ? "#f38ba8" : modelData.usage >= 75 ? "#fab387" : ThemeColors.accent

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

            }

        }

    }

}
