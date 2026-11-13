import QtQuick

import "../../common"
import "../../services"

Column {
    id: root

    signal backRequested()

    function outputIcon(node) {
        const name = (node.description || node.name || "").toLowerCase();
        if (name.includes("headphone") || name.includes("headset"))
            return "󰋋";
        if (name.includes("hdmi") || name.includes("display"))
            return "󰍹";
        return "󰓃";
    }

    spacing: 14

    PageHeader {
        width: parent.width
        centered: false
        title: "Audio"
        onBackClicked: root.backRequested()
    }

    Flickable {
        width: parent.width
        height: Math.min(content.implicitHeight, 470)
        contentWidth: width
        contentHeight: content.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: content

            width: parent.width
            spacing: 8

            SectionTitle {
                muted: true
                text: "Output Devices"
            }

            Repeater {
                model: SoundService.outputDevices

                AudioNodeCard {
                    required property var modelData
                    readonly property bool isDefault: modelData === SoundService.sink

                    node: modelData
                    width: parent.width
                    highlighted: isDefault
                    icon: root.outputIcon(modelData)
                    title: modelData.description || modelData.name || "Output Device"
                    subtitle: isDefault ? "Default" : ""
                    subtitleColor: ThemeColors.accent
                    onClicked: isDefault ? SoundService.toggleNodeMute(modelData) : SoundService.setDefaultOutput(modelData)
                }
            }

            SectionTitle {
                visible: SoundService.applicationStreams.length > 0
                topPadding: 8
                muted: true
                text: "Applications"
            }

            Repeater {
                model: SoundService.applicationStreams

                AudioNodeCard {
                    required property var modelData

                    node: modelData
                    width: parent.width
                    icon: "󰍹"
                    iconName: modelData.properties["application.icon-name"] || ""
                    title: modelData.properties["application.name"] || modelData.description || modelData.name || "Application"
                    subtitle: modelData.name || ""
                    onClicked: SoundService.toggleNodeMute(modelData)
                }
            }
        }
    }
}
