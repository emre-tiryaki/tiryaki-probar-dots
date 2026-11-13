import QtQuick

import "../../common"
import "../../services"

Column {
    id: root

    signal backRequested()

    function levelInfo(level, max) {
        if (level === 0)
            return { title: "Off", icon: "󰌌" };
        if (level === max)
            return { title: max === 1 ? "On" : "High", icon: "󰥻" };
        if (max === 2)
            return { title: "Low", icon: "󰥻" };
        return { title: Math.round(level / max * 100) + "%", icon: "󰥻" };
    }

    spacing: 14

    PageHeader {
        width: parent.width
        centered: false
        title: "Brightness"
        onBackClicked: root.backRequested()
    }

    SectionTitle {
        muted: true
        text: "Display"
    }

    VolumeCard {
        width: parent.width
        icon: BrightnessService.icon
        title: "Screen"
        subtitle: BrightnessService.available ? BrightnessService.screenDevice : "Unavailable"
        value: BrightnessService.brightness
        onMoved: v => BrightnessService.setBrightness(v)
    }

    SectionTitle {
        muted: true
        text: "Keyboard Backlight"
    }

    Text {
        visible: !BrightnessService.keyboardAvailable
        text: "No keyboard backlight found"
        color: ThemeColors.textMuted
        font.pixelSize: 11
    }

    Row {
        id: levelsRow

        readonly property int count: BrightnessService.keyboardMax + 1

        visible: BrightnessService.keyboardAvailable
        width: parent.width
        spacing: 8

        Repeater {
            model: BrightnessService.keyboardAvailable ? levelsRow.count : 0

            Card {
                required property int index
                readonly property bool current: BrightnessService.keyboardLevel === index
                readonly property var info: root.levelInfo(index, BrightnessService.keyboardMax)
                readonly property color foreground: current ? ThemeColors.background : ThemeColors.text

                width: (levelsRow.width - levelsRow.spacing * (levelsRow.count - 1)) / levelsRow.count
                height: 72
                hoverScale: 1.025
                color: current ? ThemeColors.accent : hovered ? ThemeColors.surfaceHover : ThemeColors.surface
                border.color: current ? ThemeColors.accent : hovered ? ThemeColors.accent : ThemeColors.border
                onClicked: BrightnessService.setKeyboardLevel(index)

                Column {
                    anchors.centerIn: parent
                    spacing: 6

                    Icon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: parent.parent.info.icon
                        color: parent.parent.foreground
                        opacity: parent.parent.index === 0 && !parent.parent.current ? 0.6 : 1
                        font.pixelSize: 22
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
