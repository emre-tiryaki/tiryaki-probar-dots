import QtQuick

import "../../common"
import "../../services"

Item {
    id: root

    readonly property var profileInfo: ({
        "power-saver": { title: "Power Saver", icon: "󰾆" },
        "balanced":    { title: "Balanced",    icon: "󰾅" },
        "performance": { title: "Performance", icon: "󰓅" }
    })

    signal backRequested()

    implicitWidth: modesRow.width + 24
    implicitHeight: content.height + 24

    Column {
        id: content

        anchors.horizontalCenter: parent.horizontalCenter
        y: 12
        spacing: 14

        PageHeader {
            width: modesRow.width
            title: "Power Mode"
            subtitle: "Choose your performance profile"
            onBackClicked: root.backRequested()
        }

        Row {
            id: modesRow

            spacing: 8

            Repeater {
                model: PowerModeService.profiles

                Card {
                    required property string modelData
                    readonly property bool current: PowerModeService.currentProfile === modelData
                    readonly property var info: root.profileInfo[modelData] || { title: modelData, icon: "󰚥" }
                    readonly property color foreground: current ? ThemeColors.background : ThemeColors.text

                    width: 130
                    height: 82
                    hoverScale: 1.025
                    color: current ? ThemeColors.accent : ThemeColors.surface
                    border.color: current ? ThemeColors.accent : ThemeColors.border
                    onClicked: PowerModeService.setProfile(modelData)

                    Column {
                        anchors.centerIn: parent
                        spacing: 6

                        Icon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: parent.parent.info.icon
                            color: parent.parent.foreground
                            font.pixelSize: 25
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: parent.parent.info.title
                            color: parent.parent.foreground
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                        }
                    }
                }
            }
        }
    }
}
