import QtQuick

import "../../common"
import "../../services"

Item {
    id: root

    signal backRequested()
    signal openPage(string id)

    function formatBytes(bytes) {
        if (!bytes || bytes <= 0)
            return "0 B";
        const units = ["B", "KB", "MB", "GB", "TB"];
        let value = bytes;
        let unit = 0;
        while (value >= 1024 && unit < units.length - 1) {
            value /= 1024;
            unit++;
        }
        return value.toFixed(unit === 0 ? 0 : 1) + " " + units[unit];
    }

    implicitWidth: 540
    implicitHeight: content.height + 24

    Column {
        id: content

        width: parent.width - 32
        anchors.horizontalCenter: parent.horizontalCenter
        y: 12
        spacing: 14

        PageHeader {
            width: parent.width
            title: "System Stats"
            subtitle: "Hardware usage and storage"
            onBackClicked: root.backRequested()
        }

        Row {
            height: 190
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 12

            SystemStatGauge {
                label: "CPU"
                value: SystemStatsService.cpuUsage
                temperature: SystemStatsService.cpuTemperature
                detail: SystemStatsService.cpuModel
                onClicked: root.openPage("cpu")
            }

            SystemStatGauge {
                label: "Memory"
                value: SystemStatsService.memoryUsage
                detail: root.formatBytes(SystemStatsService.memoryUsed) + " / " + root.formatBytes(SystemStatsService.memoryTotal)
                clickable: false
            }

            SystemStatGauge {
                readonly property bool available: SystemStatsService.gpuAvailable

                label: "GPU"
                value: available ? SystemStatsService.gpuUsage : 0
                temperature: available ? SystemStatsService.gpuTemperature : -1
                detail: available ? SystemStatsService.gpuName : "Unavailable"
                clickable: available
                onClicked: root.openPage("gpu")
            }
        }

        DiskSection {
            title: "Storage"
            disks: SystemStatsService.disks
            fallbackName: "Unknown"
            fallbackMount: "/"
        }

        DiskSection {
            title: "External Storage"
            disks: SystemStatsService.externalDisks
            fallbackName: "External"
            fallbackMount: "External drive"
            visible: disks.length > 0
        }
    }

    component DiskSection: Column {
        id: section

        property string title
        property var disks: []
        property string fallbackName
        property string fallbackMount

        width: parent.width
        spacing: 8

        SectionTitle {
            text: section.title
        }

        Repeater {
            model: section.disks

            Card {
                required property var modelData
                readonly property real usage: Number(modelData.usage || 0)

                width: parent.width
                height: 78
                radius: 13
                interactive: false

                Column {
                    spacing: 5

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
                        height: 18

                        Text {
                            width: parent.width - 60
                            text: modelData.filesystem || section.fallbackName
                            color: ThemeColors.text
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        Text {
                            width: 60
                            text: Math.round(usage) + "%"
                            color: ThemeColors.text
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    Text {
                        width: parent.width
                        text: modelData.mountPoint || section.fallbackMount
                        color: ThemeColors.textMuted
                        font.pixelSize: 9
                        elide: Text.ElideMiddle
                    }

                    ProgressBar {
                        width: parent.width
                        value: usage / 100
                    }

                    Text {
                        width: parent.width
                        text: root.formatBytes(Number(modelData.used || 0)) + " / " + root.formatBytes(Number(modelData.total || 0))
                        color: ThemeColors.textMuted
                        font.pixelSize: 9
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}
