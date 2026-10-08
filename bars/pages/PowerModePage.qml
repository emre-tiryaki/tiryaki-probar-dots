import QtQuick

import "../../common"
import "../../services"

Item {
    id: root

    signal backRequested()

    implicitWidth: modesRow.width + 24
    implicitHeight: content.height + 24

    Rectangle {
        anchors.fill: parent

        radius: 18
        color: ThemeColors.background
        clip: true
    }

    Column {
        id: content

        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }

        y: 12

        spacing: 14

        PageHeader {
            width: modesRow.width
            height: 48

            title: "Power Mode"
            subtitle: "Choose your performance profile"

            onBackClicked:
                root.backRequested()
        }

        Row {
            id: modesRow

            anchors.horizontalCenter: parent.horizontalCenter

            spacing: 8

            Repeater {
                model: PowerModeService.profiles

                delegate: Rectangle {
                    required property string modelData

                    width: 130
                    height: 82

                    radius: 16

                    color:
                        PowerModeService.currentProfile === modelData
                            ? ThemeColors.accent
                            : ThemeColors.surface

                    border.width: 1

                    border.color:
                        PowerModeService.currentProfile === modelData
                            ? ThemeColors.accent
                            : ThemeColors.border

                    Behavior on color {
                        ColorAnimation {
                            duration: 140
                        }
                    }

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 140
                        }
                    }

                    Column {
                        anchors.centerIn: parent

                        spacing: 6

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter

                            text: profileIcon(modelData)

                            color:
                                PowerModeService.currentProfile === modelData
                                    ? ThemeColors.background
                                    : ThemeColors.text

                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 25
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter

                            text: profileTitle(modelData)

                            color:
                                PowerModeService.currentProfile === modelData
                                    ? ThemeColors.background
                                    : ThemeColors.text

                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                        }
                    }

                    HoverHandler {
                        id: hoverHandler

                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped:
                            PowerModeService.setProfile(modelData)
                    }

                    scale:
                        hoverHandler.hovered
                            ? 1.025
                            : 1.0

                    Behavior on scale {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }

    function profileTitle(profile) {
        switch (profile) {
        case "power-saver":
            return "Power Saver"

        case "balanced":
            return "Balanced"

        case "performance":
            return "Performance"

        default:
            return profile
        }
    }

    function profileIcon(profile) {
        switch (profile) {
        case "power-saver":
            return "󰾆"

        case "balanced":
            return "󰾅"

        case "performance":
            return "󰓅"

        default:
            return "󰚥"
        }
    }
}