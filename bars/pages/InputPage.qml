import QtQuick

import "../../common"
import "../../services"

Column {
    id: root

    signal openPage(string id)

    spacing: 14

    PageHeader {
        width: parent.width
        centered: false
        title: "Input"
        onBackClicked: root.openPage("audio")
    }

    SectionTitle {
        muted: true
        text: "Input Devices"
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

            Repeater {
                model: SoundService.inputDevices

                AudioNodeCard {
                    required property var modelData
                    readonly property bool isDefault: modelData === SoundService.source

                    node: modelData
                    width: parent.width
                    highlighted: isDefault
                    icon: modelData.audio.muted ? "󰍭" : "󰍬"
                    title: modelData.description || modelData.name || "Microphone"
                    subtitle: isDefault ? "Default" : ""
                    subtitleColor: ThemeColors.accent
                    onClicked: isDefault ? SoundService.toggleNodeMute(modelData) : SoundService.setDefaultInput(modelData)
                }
            }
        }
    }
}
