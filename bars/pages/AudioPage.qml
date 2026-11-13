import QtQuick

import "../../common"
import "../../services"

Column {
    id: root

    signal backRequested()
    signal openPage(string id)

    function outputIcon(node) {
        const name = (node.description || node.name || "").toLowerCase();
        if (name.includes("headphone") || name.includes("headset"))
            return "󰋋";
        if (name.includes("hdmi") || name.includes("display"))
            return "󰍹";
        return "󰓃";
    }

    spacing: 14

    Item {
        width: parent.width
        height: header.implicitHeight

        PageHeader {
            id: header

            anchors.fill: parent
            anchors.rightMargin: boostButton.width + 12
            centered: false
            title: "Audio"
            onBackClicked: root.backRequested()
        }

        Card {
            id: boostButton

            readonly property bool active: SoundService.boostEnabled

            width: boostRow.implicitWidth + 24
            height: 36
            radius: 12
            hoverScale: 1.04
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            color: active ? ThemeColors.warning : hovered ? ThemeColors.surfaceHover : ThemeColors.surface
            border.color: active ? ThemeColors.warning : hovered ? ThemeColors.accent : ThemeColors.border
            onClicked: SoundService.toggleBoost()

            Row {
                id: boostRow

                anchors.centerIn: parent
                spacing: 6

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰝝"
                    color: boostButton.active ? ThemeColors.background : ThemeColors.text
                    font.pixelSize: 15
                }
                
            }
        }
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
                text: "Microphone"
            }

            VolumeCard {
                width: parent.width
                icon: SoundService.microphoneMuted ? "󰍭" : "󰍬"
                title: "Input"
                subtitle: SoundService.source ? (SoundService.source.description || SoundService.source.name || "") : ""
                value: SoundService.microphoneVolume
                muted: SoundService.microphoneMuted
                onMoved: v => SoundService.setMicrophoneVolume(v)
                onClicked: root.openPage("input")
            }

            SectionTitle {
                topPadding: 8
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
