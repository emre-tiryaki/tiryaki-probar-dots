import "./bars"
import "./services"
import QtQuick
import Quickshell
import Quickshell.Wayland

ShellRoot {
    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: window

                required property var modelData

                WlrLayershell.keyboardFocus: LauncherService.active ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
                WlrLayershell.namespace: "probar"
                screen: modelData
                visible: modelData.name === "eDP-1"
                implicitHeight: 700
                exclusiveZone: 40
                exclusionMode: ExclusionMode.Normal
                color: "transparent"

                anchors {
                    top: true
                    left: true
                    right: true
                }

                LeftBar {
                    id: leftBar

                    anchors {
                        top: parent.top
                        left: parent.left
                    }
                }

                CenterBar {
                    id: centerBar

                    anchors {
                        top: parent.top
                        horizontalCenter: parent.horizontalCenter
                    }
                }

                RightBar {
                    id: rightBar

                    anchors {
                        top: parent.top
                        right: parent.right
                    }
                }

                NotificationToast {}

                mask: Region {
                    Region { item: leftBar }
                    Region { item: centerBar }
                    Region { item: rightBar }
                }
            }
        }
    }
}