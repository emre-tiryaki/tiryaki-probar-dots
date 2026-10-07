import QtQuick

import "../common"
import "../services"

Row {

    id: root

    spacing: 6

    Repeater {

        model: 5

        delegate: Rectangle {

            required property int index

            width: 28
            height: 28

            radius: 14

            color: WorkspaceService.isActive(index + 1)
                ? ThemeColors.workspaceActive
                : "transparent"

            border.width: WorkspaceService.isActive(index + 1)
                ? 0
                : 1

            border.color: ThemeColors.workspaceInactive

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            Text {

                anchors.centerIn: parent

                text: index + 1

                color: WorkspaceService.isActive(index + 1)
                    ? ThemeColors.background
                    : ThemeColors.workspaceInactive

                font.pixelSize: 12
                font.weight: Font.DemiBold
            }

            MouseArea {

                anchors.fill: parent

                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    Quickshell.execDetached([
                        "hyprctl",
                        "dispatch",
                        "workspace",
                        String(index + 1)
                    ])
                }
            }
        }
    }
}