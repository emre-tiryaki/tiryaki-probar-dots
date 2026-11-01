import "../common"
import "../services"
import "../state"
import "./pages"
import QtQuick

Item {
    id: root

    property bool expanded: BarState.centerExpanded
    property bool hovered: false
    property string page: "home"
    property real collapsedWidth: 140
    property real collapsedHeight: 30
    readonly property bool launcherActive: LauncherService.active

    function open() {
        closeTimer.stop();
        root.page = "home";
        BarState.centerExpanded = true;
    }

    function close() {
        LauncherService.active = false;
        closeTimer.stop();
        BarState.centerExpanded = false;
        root.page = "home";
    }

    onLauncherActiveChanged: {
        if (launcherActive) {
            closeTimer.stop();
            root.page = "launcher";
            BarState.centerExpanded = true;
        } else if (root.page === "launcher") {
            root.close();
        }
    }
    width: expanded ? pageLoader.item ? Math.max(collapsedWidth, pageLoader.item.implicitWidth) : collapsedWidth : collapsedWidth
    height: expanded ? pageLoader.item ? Math.max(collapsedHeight, pageLoader.item.implicitHeight) : collapsedHeight : collapsedHeight

    Timer {
        id: closeTimer

        interval: 120
        repeat: false
        onTriggered: {
            if (!root.hovered && root.page !== "launcher")
                root.close();

        }
    }

    Rectangle {
        id: surface

        anchors.fill: parent
        clip: true
        color: root.expanded ? ThemeColors.background : root.hovered ? ThemeColors.surfaceHover : ThemeColors.background
        bottomLeftRadius: 18
        bottomRightRadius: 18

        Text {
            anchors.centerIn: parent
            visible: !root.expanded
            text: ClockService.time + "  ·  " + Qt.formatDateTime(new Date(), "dd.MM.yyyy")
            color: ThemeColors.text
            font.pixelSize: 12
            font.weight: Font.DemiBold
        }

        Loader {
            id: pageLoader

            visible: root.expanded
            sourceComponent: {
                switch (root.page) {
                case "home":
                    return homePage;
                case "power":
                    return powerPage;
                case "stats":
                    return statsPage;
                case "power-mode":
                    return powerModePage;
                case "clock":
                    return clockPage;
                case "calendar":
                    return calendarPage;
                case "clipboard":
                    return clipboardPage;
                case "launcher":
                    return launcherPage;
                case "weather":
                    return weatherPage;
                default:
                    return homePage;
                }
            }
        }

        HoverHandler {
            onHoveredChanged: {
                root.hovered = hovered;
                if (hovered) {
                    closeTimer.stop();
                    if (!root.expanded)
                        root.open();

                } else {
                    closeTimer.restart();
                }
            }
        }

        TapHandler {
            onTapped: {
                if (!root.expanded)
                    root.open();

            }
        }

    }

    Component {
        id: homePage

        CenterHome {
            onOpenPage: function(page) {
                root.page = page;
            }
        }

    }

    Component {
        id: powerPage

        PowerPage {
            onBackRequested: root.page = "home"
        }

    }

    Component {
        id: statsPage

        StatsPage {
            onBackRequested: root.page = "home"
        }

    }

    Component {
        id: powerModePage

        PowerModePage {
            onBackRequested: root.page = "home"
        }

    }

    Component {
        id: clockPage

        ClockPage {
            onBackRequested: root.page = "home"
        }

    }

    Component {
        id: calendarPage

        CalendarPage {
            onBackRequested: root.page = "home"
        }

    }

    Component {
        id: clipboardPage

        ClipboardPage {
            onBackRequested: root.page = "home"
        }

    }

    Component {
        id: launcherPage

        LauncherPage {
        }

    }

    Component {
        id: weatherPage

        WeatherPage {
            onBackRequested: root.page = "home"
        }

    }

    Behavior on width {
        NumberAnimation {
            duration: 280
            easing.type: Easing.OutCubic
        }

    }

    Behavior on height {
        NumberAnimation {
            duration: 280
            easing.type: Easing.OutCubic
        }

    }

}
