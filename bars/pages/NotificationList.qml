import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "../../common"
import "../../services"

Column {
    id: root

    property int expandedId: -1
    property int highlightId: -1
    property real maxListHeight: 220

    spacing: 8

    function focusNotification(id) {
        const idx = NotificationService.indexOfId(id)
        NotificationService.consumeFocus()
        if (idx < 0)
            return

        expandedId = id
        highlightId = id
        scrollTimer.targetIndex = idx
        scrollTimer.restart()
        highlightTimer.restart()
    }

    Component.onCompleted: {
        if (NotificationService.pendingFocusId >= 0)
            focusNotification(NotificationService.pendingFocusId)
    }

    Connections {
        target: NotificationService

        function onFocusRequested(id) {
            root.focusNotification(id)
        }
    }

    Timer {
        id: scrollTimer

        property int targetIndex: 0

        interval: 180
        onTriggered: listView.positionViewAtIndex(targetIndex, ListView.Contain)
    }

    Timer {
        id: highlightTimer

        interval: 1800
        onTriggered: root.highlightId = -1
    }

    RowLayout {
        width: parent.width
        spacing: 6

        Text {
            Layout.fillWidth: true
            text: "Notifications (" + NotificationService.count + ")"
            color: ThemeColors.text
            font.pixelSize: 12
            font.weight: Font.Bold
        }

        Rectangle {
            Layout.preferredWidth: 50
            Layout.preferredHeight: 22
            radius: 6
            color: clearArea.containsMouse ? ThemeColors.surfaceHover : ThemeColors.surface
            border.width: 1
            border.color: clearArea.containsMouse ? ThemeColors.textMuted : ThemeColors.border
            visible: NotificationService.count > 0

            Text {
                anchors.centerIn: parent
                text: "Clear"
                color: ThemeColors.textMuted
                font.pixelSize: 9
                font.weight: Font.Medium
            }

            MouseArea {
                id: clearArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: NotificationService.clearAll()
            }
        }

        Rectangle {
            Layout.preferredWidth: 28
            Layout.preferredHeight: 22
            radius: 6
            color: NotificationService.dnd ? ThemeColors.accent : dndArea.containsMouse ? ThemeColors.surfaceHover : ThemeColors.surface
            border.width: 1
            border.color: NotificationService.dnd ? ThemeColors.accent : dndArea.containsMouse ? ThemeColors.textMuted : ThemeColors.border

            Text {
                anchors.centerIn: parent
                text: NotificationService.dnd ? "󰂛" : "󰂚"
                font.family: "Symbols Nerd Font"
                color: NotificationService.dnd ? ThemeColors.background : ThemeColors.text
                font.pixelSize: 11
            }

            MouseArea {
                id: dndArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: NotificationService.toggleDnd()
            }
        }
    }

    Rectangle {
        width: parent.width
        height: 44
        radius: 12
        color: ThemeColors.surface
        border.width: 1
        border.color: ThemeColors.border
        visible: NotificationService.count === 0

        Text {
            anchors.centerIn: parent
            text: NotificationService.dnd ? "Do not disturb is on" : "No new notifications"
            color: ThemeColors.textMuted
            font.pixelSize: 11
        }
    }

    ListView {
        id: listView

        readonly property bool scrollable: contentHeight > height

        width: parent.width
        height: Math.min(contentHeight, root.maxListHeight)
        clip: true
        spacing: 6
        cacheBuffer: 4000
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        interactive: scrollable
        visible: NotificationService.count > 0
        model: NotificationService.notifications

        ScrollBar.vertical: ScrollBar {
            id: vbar

            policy: listView.scrollable ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
            width: 6

            contentItem: Rectangle {
                implicitWidth: 4
                radius: 2
                color: vbar.pressed || vbar.hovered ? ThemeColors.accent : ThemeColors.textMuted
                opacity: vbar.active ? 0.9 : 0.45

                Behavior on opacity { NumberAnimation { duration: 150 } }
            }

            background: Item {}
        }

        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 140 }
        }

        remove: Transition {
            NumberAnimation { property: "opacity"; to: 0; duration: 120 }
        }

        displaced: Transition {
            NumberAnimation { properties: "y"; duration: 140; easing.type: Easing.OutCubic }
        }

        delegate: NotificationCard {
            width: ListView.view.width - (ListView.view.scrollable ? 10 : 0)
            expanded: notifId === root.expandedId
            highlighted: notifId === root.highlightId
            onToggled: root.expandedId = expanded ? -1 : notifId
        }
    }
}