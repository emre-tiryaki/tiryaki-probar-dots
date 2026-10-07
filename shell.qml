import QtQuick
import Quickshell
import Quickshell.Wayland

import "./bars"

ShellRoot {

    Variants {
        model: Quickshell.screens

        delegate: Component {

            PanelWindow {

                id: window

                required property var modelData

                screen: modelData

                visible: modelData.name === "eDP-1"

                anchors {
                    top: true
                    left: true
                    right: true
                }

                /*
                 * The surface is large enough for the expanded
                 * RightBar, but only the actual bars receive input.
                 */
                implicitHeight: 520

                exclusiveZone: 40

                exclusionMode: ExclusionMode.Normal

                color: "transparent"

                WlrLayershell.namespace: "probar"

                /*
                 * Only these items are clickable.
                 *
                 * Everything else in the 520px surface is
                 * click-through and goes to the application below.
                 */
                mask: Region {

                    Region {
                        item: leftBar
                    }

                    Region {
                        item: centerBar
                    }

                    Region {
                        item: rightBar
                    }
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
            }
        }
    }
}