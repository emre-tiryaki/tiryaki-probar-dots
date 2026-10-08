import "../common"
import "../state"
import "./pages"
import QtQuick

Item {
    // -----------------------------------------------------
    // Home
    // -----------------------------------------------------

    id: root

    property bool expanded: BarState.centerExpanded
    property bool hovered: false
    property string page: "home"
    property real collapsedWidth: 140
    property real collapsedHeight: 30

    function open() {
        closeTimer.stop();
        root.page = "home";
        BarState.centerExpanded = true;
    }

    function close() {
        closeTimer.stop();
        BarState.centerExpanded = false;
        root.page = "home";
    }

    width: expanded ? pageLoader.item ? pageLoader.item.implicitWidth : collapsedWidth : collapsedWidth
    height: expanded ? pageLoader.item ? pageLoader.item.implicitHeight : collapsedHeight : collapsedHeight
    onExpandedChanged: {
        if (expanded)
            closeTimer.stop();

    }

    Timer {
        id: closeTimer

        interval: 120
        repeat: false
        onTriggered: {
            if (!root.hovered)
                close();

        }
    }

    Rectangle {
        // -------------------------------------------------
        // Collapsed
        // -------------------------------------------------
        // -------------------------------------------------
        // Expanded
        // -------------------------------------------------
        // Hover
        // -------------------------------------------------

        id: surface

        anchors.fill: parent
        clip: true
        color: root.expanded ? ThemeColors.background : root.hovered ? ThemeColors.surfaceHover : ThemeColors.background
        bottomLeftRadius: 18
        bottomRightRadius: 18

        Text {
            anchors.centerIn: parent
            visible: !root.expanded
            text: Qt.formatTime(new Date(), "HH:mm")
            color: ThemeColors.text
            font.pixelSize: 12
            font.weight: Font.DemiBold
        }

        Loader {
            id: pageLoader

            anchors.fill: parent
            visible: root.expanded
            opacity: root.expanded ? 1 : 0
            sourceComponent: {
                switch (root.page) {
                case "home":
                    return homePage;
                case "power":
                    return powerPage;
                default:
                    return homePage;
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }

            }

        }
        // -------------------------------------------------

        HoverHandler {
            onHoveredChanged: {
                root.hovered = hovered;
                if (hovered) {
                    closeTimer.stop();
                    if (!root.expanded)
                        open();

                } else {
                    closeTimer.restart();
                }
            }
        }

        TapHandler {
            onTapped: {
                if (!root.expanded)
                    open();

            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 120
            }

        }

    }

    Component {
        id: homePage

        CenterHome {
            onOpenPage: function(page) {
                root.page = page;
                console.log("Opening center page:", page);
            }
        }

    }

    Component {
        id: powerPage

        PowerPage {
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
