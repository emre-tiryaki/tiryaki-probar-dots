import QtQuick

import "../../common"
import "../../services"

Item {
    id: root

    signal backRequested()
    signal cpuClicked()
    signal gpuClicked()

    implicitWidth: 540
    implicitHeight: contentColumn.height + 24

    function formatBytes(bytes) {
        if (!bytes || bytes <= 0)
            return "0 B"

        const units = ["B", "KB", "MB", "GB", "TB"]

        let value = bytes
        let unit = 0

        while (value >= 1024 && unit < units.length - 1) {
            value /= 1024
            unit++
        }

        return value.toFixed(
            unit === 0 ? 0 : 1
        ) + " " + units[unit]
    }

    Rectangle {
        anchors.fill: parent

        radius: 18

        color: ThemeColors.background

        clip: true
    }

    Column {
        id: contentColumn

        width: parent.width - 32

        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }

        y: 12

        spacing: 14

        PageHeader {
            width: parent.width
            height: 48

            title: "System Stats"
            subtitle: "Hardware usage and storage"

            onBackClicked:
                root.backRequested()
        }

        // Hardware gauges
        Item {
            width: parent.width
            height: 190

            Row {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }

                spacing: 12

                SystemStatGauge {
                    width: 150
                    height: 190

                    label: "CPU"

                    value:
                        SystemStatsService.cpuUsage

                    temperature:
                        SystemStatsService.cpuTemperature

                    detail:
                        SystemStatsService.cpuModel

                    onClicked:
                        root.cpuClicked()
                }

                SystemStatGauge {
                    width: 150
                    height: 190

                    label: "Memory"

                    value:
                        SystemStatsService.memoryUsage

                    detail:
                        formatBytes(
                            SystemStatsService.memoryUsed
                        )
                        + " / "
                        + formatBytes(
                            SystemStatsService.memoryTotal
                        )

                    clickable: false
                }

                SystemStatGauge {
                    width: 150
                    height: 190

                    label: "GPU"

                    value:
                        SystemStatsService.gpuAvailable
                            ? SystemStatsService.gpuUsage
                            : 0

                    temperature:
                        SystemStatsService.gpuAvailable
                            ? SystemStatsService.gpuTemperature
                            : -1

                    detail:
                        SystemStatsService.gpuAvailable
                            ? SystemStatsService.gpuName
                            : "Unavailable"

                    clickable:
                        SystemStatsService.gpuAvailable

                    onClicked:
                        root.gpuClicked()
                }
            }
        }

        // Internal storage
        Column {
            width: parent.width

            spacing: 8

            Text {
                text: "Storage"

                color: ThemeColors.text

                font.pixelSize: 13
                font.weight: Font.DemiBold
            }

            Column {
                width: parent.width

                spacing: 8

                Repeater {
                    model: SystemStatsService.disks

                    delegate: Rectangle {
                        width: parent.width
                        height: 78

                        radius: 13

                        color: ThemeColors.surface

                        border.width: 1
                        border.color: ThemeColors.border

                        Column {
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                leftMargin: 14
                                rightMargin: 14
                                topMargin: 11
                            }

                            spacing: 5

                            Row {
                                width: parent.width
                                height: 18

                                Text {
                                    width:
                                        parent.width - 60

                                    text:
                                        modelData.filesystem ||
                                        "Unknown"

                                    color: ThemeColors.text

                                    font.pixelSize: 10
                                    font.weight: Font.DemiBold

                                    elide:
                                        Text.ElideRight
                                }

                                Text {
                                    width: 60

                                    text:
                                        Math.round(
                                            Number(
                                                modelData.usage || 0
                                            )
                                        ) + "%"

                                    color: ThemeColors.text

                                    font.pixelSize: 10
                                    font.weight: Font.DemiBold

                                    horizontalAlignment:
                                        Text.AlignRight
                                }
                            }

                            Text {
                                width: parent.width

                                text:
                                    modelData.mountPoint ||
                                    "/"

                                color: ThemeColors.textMuted

                                font.pixelSize: 9

                                elide:
                                    Text.ElideMiddle
                            }

                            Rectangle {
                                width: parent.width
                                height: 5

                                radius: 3

                                color: ThemeColors.background

                                Rectangle {
                                    width:
                                        parent.width *
                                        Math.min(
                                            100,
                                            Math.max(
                                                0,
                                                Number(
                                                    modelData.usage || 0
                                                )
                                            )
                                        ) / 100

                                    height: parent.height

                                    radius: 3

                                    color: ThemeColors.accent
                                }
                            }

                            Text {
                                width: parent.width

                                text:
                                    formatBytes(
                                        Number(
                                            modelData.used || 0
                                        )
                                    )
                                    + " / "
                                    + formatBytes(
                                        Number(
                                            modelData.total || 0
                                        )
                                    )

                                color: ThemeColors.textMuted

                                font.pixelSize: 9

                                elide:
                                    Text.ElideRight
                            }
                        }
                    }
                }
            }
        }

        // External storage
        Column {
            visible:
                SystemStatsService.externalDisks.length > 0

            width: parent.width

            spacing: 8

            Text {
                text: "External Storage"

                color: ThemeColors.text

                font.pixelSize: 13
                font.weight: Font.DemiBold
            }

            Column {
                width: parent.width

                spacing: 8

                Repeater {
                    model:
                        SystemStatsService.externalDisks

                    delegate: Rectangle {
                        width: parent.width
                        height: 78

                        radius: 13

                        color: ThemeColors.surface

                        border.width: 1
                        border.color: ThemeColors.border

                        Column {
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                leftMargin: 14
                                rightMargin: 14
                                topMargin: 11
                            }

                            spacing: 5

                            Row {
                                width: parent.width
                                height: 18

                                Text {
                                    width:
                                        parent.width - 60

                                    text:
                                        modelData.filesystem ||
                                        "External"

                                    color: ThemeColors.text

                                    font.pixelSize: 10
                                    font.weight: Font.DemiBold

                                    elide:
                                        Text.ElideRight
                                }

                                Text {
                                    width: 60

                                    text:
                                        Math.round(
                                            Number(
                                                modelData.usage || 0
                                            )
                                        ) + "%"

                                    color: ThemeColors.text

                                    font.pixelSize: 10
                                    font.weight: Font.DemiBold

                                    horizontalAlignment:
                                        Text.AlignRight
                                }
                            }

                            Text {
                                width: parent.width

                                text:
                                    modelData.mountPoint ||
                                    "External drive"

                                color: ThemeColors.textMuted

                                font.pixelSize: 9

                                elide:
                                    Text.ElideMiddle
                            }

                            Rectangle {
                                width: parent.width
                                height: 5

                                radius: 3

                                color: ThemeColors.background

                                Rectangle {
                                    width:
                                        parent.width *
                                        Math.min(
                                            100,
                                            Math.max(
                                                0,
                                                Number(
                                                    modelData.usage || 0
                                                )
                                            )
                                        ) / 100

                                    height: parent.height

                                    radius: 3

                                    color: ThemeColors.accent
                                }
                            }

                            Text {
                                width: parent.width

                                text:
                                    formatBytes(
                                        Number(
                                            modelData.used || 0
                                        )
                                    )
                                    + " / "
                                    + formatBytes(
                                        Number(
                                            modelData.total || 0
                                        )
                                    )

                                color: ThemeColors.textMuted

                                font.pixelSize: 9

                                elide:
                                    Text.ElideRight
                            }
                        }
                    }
                }
            }
        }
    }
}