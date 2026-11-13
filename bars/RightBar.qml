import "../common"
import "../services"
import "../state"
import QtQuick

Item {
    id: root

    property bool expanded: BarState.rightExpanded
    property bool collapsedHovered: false
    property real collapsedWidth: collapsedContent.implicitWidth + 20
    property real expandedWidth: 390
    property real collapsedHeight: 35
    property real expandedHeight: {
        const item = pages.item;
        if (!item)
            return collapsedHeight;
        return (item.implicitHeight > 0 ? item.implicitHeight : item.childrenRect.height) + 32;
    }

    function open() {
        closeTimer.stop();
        pages.current = pages.home;
        BarState.rightExpanded = true;
    }

    width: expanded ? expandedWidth : collapsedWidth
    height: expanded ? expandedHeight : collapsedHeight

    Timer {
        id: closeTimer

        interval: 120
        onTriggered: {
            BarState.rightExpanded = false;
            pages.current = pages.home;
        }
    }

    Connections {
        target: NotificationService

        function onFocusRequested(id) {
            root.open();
        }
    }

    Rectangle {
        anchors.fill: parent
        clip: true
        color: !root.expanded && root.collapsedHovered ? ThemeColors.surfaceHover : ThemeColors.background
        bottomLeftRadius: 18

        Behavior on color { ColorAnimation { duration: 120 } }

        // Collapsed: status indicators. Add a StatusItem here to add one.
        Item {
            anchors.fill: parent
            visible: !root.expanded

            Row {
                id: collapsedContent

                spacing: 10

                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: 10
                }

                StatusItem {
                    icon: NetworkService.connected || NetworkService.connecting ? "󰤨" : "󰤭"
                    iconOpacity: NetworkService.connecting ? 0.45 : 1
                    label: NetworkService.connecting ? "Connecting..." : NetworkService.connected ? NetworkService.currentNetwork : "Offline"
                }

                StatusItem {
                    icon: SoundService.muted ? "󰖁" : "󰕾"
                    label: Math.round(SoundService.volume * 100) + "%"
                }

                StatusItem {
                    icon: "󰂯"
                    iconColor: BluetoothService.enabled ? ThemeColors.text : ThemeColors.textMuted
                    badge: BluetoothService.connectedCount > 0 ? String(BluetoothService.connectedCount) : ""
                }

                StatusItem {
                    icon: NotificationService.dnd ? "󰂛" : "󰂚"
                    iconColor: NotificationService.count > 0 ? ThemeColors.text : ThemeColors.textMuted
                    badge: NotificationService.count > 9 ? "9+" : NotificationService.count > 0 ? String(NotificationService.count) : ""
                }

                StatusItem {
                    icon: BatteryService.icon
                    label: BatteryService.available ? BatteryService.percentage + "%" : "--"
                }
            }

            TapHandler {
                onTapped: root.open()
            }

            HoverHandler {
                onHoveredChanged: root.collapsedHovered = hovered
            }
        }

        // Expanded: pages from PageRegistry.right
        Item {
            anchors.fill: parent
            visible: root.expanded

            PageStack {
                id: pages

                baseUrl: Qt.resolvedUrl("pages/")
                pages: PageRegistry.right

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: 16
                }
            }

            HoverHandler {
                onHoveredChanged: {
                    if (hovered)
                        closeTimer.stop();
                    else if (root.expanded)
                        closeTimer.restart();
                }
            }
        }
    }

    Behavior on width { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
    Behavior on height { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
}
