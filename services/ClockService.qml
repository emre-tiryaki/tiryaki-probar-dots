pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property date currentTime: new Date()

    readonly property string time:
        Qt.formatTime(
            root.currentTime,
            "HH:mm"
        )

    readonly property string seconds:
        Qt.formatTime(
            root.currentTime,
            "ss"
        )

    readonly property string date:
        Qt.formatDate(
            root.currentTime,
            "dddd, d MMMM yyyy"
        )

    Timer {
        interval: 1000
        repeat: true
        running: true

        onTriggered: {
            root.currentTime = new Date()
        }
    }
}