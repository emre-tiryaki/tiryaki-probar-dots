import QtQuick

import "../../common"

Item {
    id: root

    signal openPage(string page)

    implicitWidth: rows.implicitWidth + 32
    implicitHeight: rows.implicitHeight + 32

    Column {
        id: rows

        anchors.centerIn: parent

        spacing: 10

        Row {
            anchors.horizontalCenter:
                parent.horizontalCenter

            spacing: 10

            CenterModuleCard {
                title: "Power"
                description: "Shutdown & restart"
                icon: "󰐥"

                onClicked:
                    root.openPage("power")
            }

            CenterModuleCard {
                title: "System Stats"
                description: "CPU, GPU & memory"
                icon: "󰍛"

                onClicked:
                    root.openPage("stats")
            }

            CenterModuleCard {
                title: "Power Mode"
                description: "Performance profiles"
                icon: "󰂄"

                onClicked:
                    root.openPage("power-mode")
            }
        }

        Row {
            anchors.horizontalCenter:
                parent.horizontalCenter

            spacing: 10

            CenterModuleCard {
                title: "Clock"
                description: "Clock & stopwatch"
                icon: "󰥔"

                onClicked:
                    root.openPage("clock")
            }

            CenterModuleCard {
                title: "Calendar"
                description: "View your calendar"
                icon: "󰃭"

                onClicked:
                    root.openPage("calendar")
            }

            CenterModuleCard {
                title: "Monitors"
                description: "Displays & refresh rate"
                icon: "󰍹"

                onClicked:
                    root.openPage("monitors")
            }
        }
    }
}