import QtQuick

import "../common"
import "../services"

Row {
    id: root

    spacing: 8

    Repeater {
        model: 5

        delegate: Rectangle {
            required property int index

            readonly property bool active: WorkspaceService.isActive(index + 1)

            // Aktifse geniş kapsül (22px), inaktifse küçük nokta (8px)
            width: active ? 22 : 8
            height: 8

            radius: 4

            color: active
                ? ThemeColors.workspaceActive
                : ThemeColors.workspaceInactive

            // Aktiflik durumuna göre genişlik değişimi animasyonu
            Behavior on width {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            // Renk geçiş animasyonu
            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
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