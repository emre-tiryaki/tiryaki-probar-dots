import "../common"
import "../services"
import "../state"
import QtQuick

Item {
    id: root

    property bool expanded: BarState.centerExpanded
    property bool hovered: false
    property real collapsedWidth: 140
    property real collapsedHeight: 30
    readonly property bool launcherActive: LauncherService.active

    function open() {
        closeTimer.stop();
        pages.current = pages.home;
        BarState.centerExpanded = true;
    }

    function close() {
        LauncherService.active = false;
        closeTimer.stop();
        BarState.centerExpanded = false;
        pages.current = pages.home;
    }

    onLauncherActiveChanged: {
        if (launcherActive) {
            closeTimer.stop();
            pages.current = "launcher";
            BarState.centerExpanded = true;
        } else if (pages.current === "launcher") {
            root.close();
        }
    }

    width: expanded && pages.item ? Math.max(collapsedWidth, pages.item.implicitWidth) : collapsedWidth
    height: expanded && pages.item ? Math.max(collapsedHeight, pages.item.implicitHeight) : collapsedHeight

    Timer {
        id: closeTimer

        interval: 120
        onTriggered: {
            if (!root.hovered && pages.current !== "launcher")
                root.close();
        }
    }

    Rectangle {
        anchors.fill: parent
        clip: true
        color: !root.expanded && root.hovered ? ThemeColors.surfaceHover : ThemeColors.background
        bottomLeftRadius: 18
        bottomRightRadius: 18

        Text {
            anchors.centerIn: parent
            visible: !root.expanded
            text: ClockService.time + "  ·  " + Qt.formatDate(ClockService.currentTime, "dd.MM.yyyy")
            color: ThemeColors.text
            font.pixelSize: 12
            font.weight: Font.DemiBold
        }

        PageStack {
            id: pages

            visible: root.expanded
            dir: "bars/pages/"
            pages: PageRegistry.center
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

    Behavior on width { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
    Behavior on height { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
}
