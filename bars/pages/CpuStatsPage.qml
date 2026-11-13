import "../../common"
import "../../services"
import QtQuick
import "."

StatsDetailPage {
    title: "CPU"
    subtitle: SystemStatsService.cpuModel
    usage: SystemStatsService.cpuUsage
    temperature: SystemStatsService.cpuTemperature
    countText: SystemStatsService.cpuCores.length + " cores"
    processTitle: "Top Processes"
    processes: SystemStatsService.processes
    valueHeader: "CPU"
    processValue: p => Number(p.cpu || 0).toFixed(1) + "%"

    // Per-core usage
    Card {
        width: parent.width
        height: 176
        radius: 14
        interactive: false

        Column {
            spacing: 8

            anchors {
                fill: parent
                leftMargin: 15
                rightMargin: 15
                topMargin: 13
                bottomMargin: 10
            }

            SectionTitle {
                text: "Core Usage"
            }

            Row {
                id: coreRow

                readonly property int count: Math.max(1, SystemStatsService.cpuCores.length)

                width: parent.width
                height: 122
                spacing: 6

                Repeater {
                    model: SystemStatsService.cpuCores

                    Column {
                        required property var modelData
                        required property int index
                        readonly property real usage: typeof modelData === "number" ? modelData : Number(modelData.usage ?? modelData.value ?? 0)

                        width: (coreRow.width - (coreRow.count - 1) * coreRow.spacing) / coreRow.count
                        height: coreRow.height
                        spacing: 5

                        Item {
                            width: parent.width
                            height: 96

                            Rectangle {
                                width: 8
                                height: Math.max(2, parent.height * Math.min(100, Math.max(0, parent.parent.usage)) / 100)
                                radius: 4
                                color: ThemeColors.accent
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
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
