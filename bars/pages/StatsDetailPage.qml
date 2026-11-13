import "../../common"
import QtQuick

// Template for a hardware detail page: header, usage summary, optional extra
// content (default property), and a process table.
Item {
    id: root

    property string title
    property string subtitle
    property real usage: 0            // percent
    property real temperature: 0      // °C, <= 0 means unknown
    property string countText: ""
    property string processTitle: "Processes"
    property var processes: []
    property string valueHeader: ""
    property real valueWidth: 65
    property var processName: p => p.command || "Unknown"
    property var processValue: p => ""
    default property alias extraContent: extra.data

    signal backRequested()

    implicitWidth: 540
    implicitHeight: content.y + content.height + 16

    Column {
        id: content

        width: parent.width - 32
        anchors.horizontalCenter: parent.horizontalCenter
        y: 12
        spacing: 12

        PageHeader {
            width: parent.width
            title: root.title
            subtitle: root.subtitle
            onBackClicked: root.backRequested()
        }

        Card {
            width: parent.width
            height: 118
            interactive: false

            Column {
                spacing: 10

                anchors {
                    fill: parent
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
                            text: root.title + " Usage"
                            color: ThemeColors.textMuted
                            font.pixelSize: 10
                            font.weight: Font.Medium
                        }

                        Text {
                            text: Math.round(root.usage) + "%"
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
                            text: root.temperature > 0 ? Math.round(root.temperature) + "°C" : "N/A"
                            color: ThemeColors.text
                            font.pixelSize: 17
                            font.weight: Font.DemiBold
                            horizontalAlignment: Text.AlignRight
                        }

                        Text {
                            width: parent.width
                            text: root.countText
                            color: ThemeColors.textMuted
                            font.pixelSize: 8
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }

                ProgressBar {
                    width: parent.width
                    value: root.usage / 100
                }
            }
        }

        Column {
            id: extra

            width: parent.width
            visible: children.length > 0
        }

        SectionTitle {
            text: root.processTitle
        }

        Card {
            width: parent.width
            height: 220
            radius: 14
            interactive: false
            clip: true

            Column {
                anchors {
                    fill: parent
                    leftMargin: 14
                    rightMargin: 14
                    topMargin: 9
                    bottomMargin: 9
                }

                ProcessRow {
                    height: 26
                    header: true
                    pid: "PID"
                    name: "Process"
                    value: root.valueHeader
                }

                Flickable {
                    width: parent.width
                    height: parent.height - 26
                    clip: true
                    contentWidth: width
                    contentHeight: rows.height
                    boundsBehavior: Flickable.StopAtBounds
                    interactive: contentHeight > height

                    Column {
                        id: rows

                        width: parent.width

                        Repeater {
                            model: root.processes

                            ProcessRow {
                                required property var modelData

                                pid: String(modelData.pid || "-")
                                name: root.processName(modelData)
                                value: root.processValue(modelData)
                            }
                        }
                    }
                }
            }
        }
    }

    component ProcessRow: Row {
        property bool header: false
        property string pid
        property string name
        property string value

        width: parent.width
        height: 32

        Text {
            width: 60
            anchors.verticalCenter: parent.verticalCenter
            text: parent.pid
            color: ThemeColors.textMuted
            font.pixelSize: parent.header ? 9 : 10
            font.weight: parent.header ? Font.DemiBold : Font.Normal
        }

        Text {
            width: parent.width - 60 - root.valueWidth
            anchors.verticalCenter: parent.verticalCenter
            text: parent.name
            color: parent.header ? ThemeColors.textMuted : ThemeColors.text
            font.pixelSize: parent.header ? 9 : 10
            font.weight: Font.DemiBold
            elide: Text.ElideRight
        }

        Text {
            width: root.valueWidth
            anchors.verticalCenter: parent.verticalCenter
            text: parent.value
            color: parent.header ? ThemeColors.textMuted : ThemeColors.accent
            font.pixelSize: parent.header ? 9 : 10
            font.weight: Font.DemiBold
            horizontalAlignment: Text.AlignRight
        }
    }
}
