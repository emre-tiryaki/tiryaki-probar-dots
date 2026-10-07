import QtQuick

import "../../common"
import "../../services"

Column {
    id: root

    property var goBack

    width: parent ? parent.width : 0

    spacing: 14

    Row {
        width: parent.width
        height: 28

        spacing: 10

        Text {
            text: "󰁍"

            color: ThemeColors.textMuted

            font.family: "Symbols Nerd Font"
            font.pixelSize: 17

            anchors.verticalCenter:
                parent.verticalCenter

            TapHandler {
                cursorShape:
                    Qt.PointingHandCursor

                onTapped: {
                    if (root.goBack)
                        root.goBack()
                }
            }
        }

        Text {
            text: "Input"

            color: ThemeColors.text

            font.pixelSize: 16
            font.weight: Font.DemiBold

            anchors.verticalCenter:
                parent.verticalCenter
        }
    }

    Text {
        text: "Input Devices"

        color: ThemeColors.textMuted

        font.pixelSize: 11
        font.weight: Font.DemiBold
    }

    Flickable {
        id: flick

        width: parent.width

        height: Math.min(
            inputColumn.implicitHeight,
            470
        )

        contentWidth: width
        contentHeight:
            inputColumn.implicitHeight

        clip: true

        boundsBehavior:
            Flickable.StopAtBounds

        Column {
            id: inputColumn

            width: flick.width

            spacing: 8

            Repeater {
                model:
                    SoundService.inputDevices

                delegate: Rectangle {
                    required property var modelData

                    width: parent.width
                    height: 76

                    radius: 15

                    color:
                        modelData ===
                        SoundService.source
                            ? ThemeColors.surfaceHover
                            : ThemeColors.surface

                    border.width:
                        modelData ===
                        SoundService.source
                            ? 1
                            : 0

                    border.color:
                        ThemeColors.accent

                    Column {
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top

                            leftMargin: 14
                            rightMargin: 14
                            topMargin: 11
                        }

                        spacing: 8

                        Row {
                            width: parent.width

                            spacing: 9

                            Text {
                                text:
                                    modelData.audio.muted
                                        ? "󰍭"
                                        : "󰍬"

                                color:
                                    modelData.audio.muted
                                        ? ThemeColors.textMuted
                                        : ThemeColors.text

                                font.family:
                                    "Symbols Nerd Font"

                                font.pixelSize: 20

                                anchors.verticalCenter:
                                    parent.verticalCenter
                            }

                            Column {
                                width:
                                    parent.width - 75

                                spacing: 1

                                anchors.verticalCenter:
                                    parent.verticalCenter

                                Text {
                                    width:
                                        parent.width

                                    text:
                                        modelData.description ||
                                        modelData.name ||
                                        "Microphone"

                                    color:
                                        ThemeColors.text

                                    font.pixelSize: 11
                                    font.weight:
                                        Font.DemiBold

                                    elide:
                                        Text.ElideRight
                                }

                                Text {
                                    visible:
                                        modelData ===
                                        SoundService.source

                                    text: "Default"

                                    color:
                                        ThemeColors.accent

                                    font.pixelSize: 9
                                    font.weight:
                                        Font.DemiBold
                                }
                            }

                            Text {
                                text:
                                    Math.round(
                                        modelData.audio.volume *
                                        100
                                    ) + "%"

                                color:
                                    ThemeColors.textMuted

                                font.pixelSize: 10
                                font.weight:
                                    Font.DemiBold

                                anchors.verticalCenter:
                                    parent.verticalCenter
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 5

                            radius: height / 2

                            color:
                                ThemeColors.border

                            Rectangle {
                                width:
                                    parent.width *
                                    Math.max(
                                        0,
                                        Math.min(
                                            1,
                                            modelData.audio.volume
                                        )
                                    )

                                height:
                                    parent.height

                                radius:
                                    height / 2

                                color:
                                    modelData.audio.muted
                                        ? ThemeColors.textMuted
                                        : ThemeColors.accent

                                Behavior on width {
                                    NumberAnimation {
                                        duration: 100
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent

                                cursorShape:
                                    Qt.PointingHandCursor

                                onPressed:
                                    function(mouse) {
                                        SoundService.setNodeVolume(
                                            modelData,
                                            Math.max(
                                                0,
                                                Math.min(
                                                    1,
                                                    mouse.x /
                                                    width
                                                )
                                            )
                                        )
                                    }

                                onPositionChanged:
                                    function(mouse) {
                                        if (!pressed)
                                            return

                                        SoundService.setNodeVolume(
                                            modelData,
                                            Math.max(
                                                0,
                                                Math.min(
                                                    1,
                                                    mouse.x /
                                                    width
                                                )
                                            )
                                        )
                                    }
                            }
                        }
                    }

                    TapHandler {
                        onTapped: {
                            if (
                                modelData ===
                                SoundService.source
                            ) {
                                SoundService.toggleNodeMute(
                                    modelData
                                )
                            } else {
                                SoundService.setDefaultInput(
                                    modelData
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}