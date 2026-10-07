import QtQuick
import Quickshell

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
            text: "Audio"

            color: ThemeColors.text

            font.pixelSize: 16
            font.weight: Font.DemiBold

            anchors.verticalCenter:
                parent.verticalCenter
        }
    }

    Flickable {
        id: flick

        width: parent.width

        height: Math.min(
            contentColumn.implicitHeight,
            470
        )

        contentWidth: width
        contentHeight:
            contentColumn.implicitHeight

        clip: true

        boundsBehavior:
            Flickable.StopAtBounds

        Column {
            id: contentColumn

            width: flick.width

            spacing: 16

            /*
             * OUTPUT DEVICES
             */

            Text {
                text: "Output Devices"

                color: ThemeColors.textMuted

                font.pixelSize: 11
                font.weight: Font.DemiBold
            }

            Column {
                width: parent.width

                spacing: 8

                Repeater {
                    model:
                        SoundService.outputDevices

                    delegate: Rectangle {
                        required property var modelData

                        width: parent.width
                        height: 76

                        radius: 15

                        color:
                            modelData ===
                            SoundService.sink
                                ? ThemeColors.surfaceHover
                                : ThemeColors.surface

                        border.width:
                            modelData ===
                            SoundService.sink
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
                                    text: {
                                        var name =
                                            (
                                                modelData.description ||
                                                modelData.name ||
                                                ""
                                            ).toLowerCase()

                                        if (
                                            name.includes(
                                                "headphone"
                                            ) ||
                                            name.includes(
                                                "headset"
                                            )
                                        )
                                            return "󰋋"

                                        if (
                                            name.includes(
                                                "hdmi"
                                            ) ||
                                            name.includes(
                                                "display"
                                            )
                                        )
                                            return "󰍹"

                                        return "󰓃"
                                    }

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
                                            "Output Device"

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
                                            SoundService.sink

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
                                    SoundService.sink
                                ) {
                                    SoundService.toggleNodeMute(
                                        modelData
                                    )
                                } else {
                                    SoundService.setDefaultOutput(
                                        modelData
                                    )
                                }
                            }
                        }
                    }
                }
            }

            /*
             * APPLICATIONS
             */

            Text {
                text: "Applications"

                color: ThemeColors.textMuted

                font.pixelSize: 11
                font.weight: Font.DemiBold

                visible:
                    SoundService.applicationStreams.length > 0
            }

            Column {
                width: parent.width

                spacing: 8

                visible:
                    SoundService.applicationStreams.length > 0

                Repeater {
                    model:
                        SoundService.applicationStreams

                    delegate: Rectangle {
                        required property var modelData

                        width: parent.width
                        height: 76

                        radius: 15

                        color: ThemeColors.surface

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

                                Item {
                                    width: 24
                                    height: 24

                                    anchors.verticalCenter:
                                        parent.verticalCenter

                                    Image {
                                        id: applicationIcon

                                        anchors.centerIn:
                                            parent

                                        width: 22
                                        height: 22

                                        fillMode:
                                            Image.PreserveAspectFit

                                        source: {
                                            var icon =
                                                modelData.properties[
                                                    "application.icon-name"
                                                ]

                                            if (
                                                !icon ||
                                                icon === ""
                                            )
                                                return ""

                                            return Quickshell.iconPath(
                                                icon,
                                                true
                                            )
                                        }

                                        visible:
                                            source !== ""
                                    }

                                    Text {
                                        anchors.centerIn:
                                            parent

                                        text: "󰍹"

                                        color:
                                            ThemeColors.textMuted

                                        font.family:
                                            "Symbols Nerd Font"

                                        font.pixelSize: 20

                                        visible:
                                            !applicationIcon.visible
                                    }
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
                                            modelData.properties[
                                                "application.name"
                                            ] ||
                                            modelData.description ||
                                            modelData.name ||
                                            "Application"

                                        color:
                                            ThemeColors.text

                                        font.pixelSize: 11
                                        font.weight:
                                            Font.DemiBold

                                        elide:
                                            Text.ElideRight
                                    }

                                    Text {
                                        width:
                                            parent.width

                                        text:
                                            modelData.name ||
                                            ""

                                        color:
                                            ThemeColors.textMuted

                                        font.pixelSize: 9

                                        elide:
                                            Text.ElideRight

                                        visible:
                                            text !== ""
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
                                SoundService.toggleNodeMute(
                                    modelData
                                )
                            }
                        }
                    }
                }
            }

            Item {
                width: 1
                height: 4
            }
        }
    }
}