import QtQuick

Item {
    id: root

    property var monitors: []

    property string selectedMonitor: ""

    signal monitorClicked(string name)

    implicitWidth: 500
    implicitHeight: 250

    /*
     * Padding around the complete monitor layout.
     */
    readonly property real padding: 24

    readonly property real availableWidth:
        width - padding * 2

    readonly property real availableHeight:
        height - padding * 2

    property real minX: 0
    property real maxX: 0
    property real minY: 0
    property real maxY: 0

    property real layoutWidth: 1
    property real layoutHeight: 1

    function updateBounds() {
        if (
            !root.monitors ||
            root.monitors.length === 0
        ) {
            root.minX = 0
            root.maxX = 1
            root.minY = 0
            root.maxY = 1
            return
        }

        let minX = Infinity
        let maxX = -Infinity
        let minY = Infinity
        let maxY = -Infinity

        for (
            const monitor of root.monitors
        ) {
            minX = Math.min(
                minX,
                monitor.x
            )

            minY = Math.min(
                minY,
                monitor.y
            )

            maxX = Math.max(
                maxX,
                monitor.x +
                monitor.width
            )

            maxY = Math.max(
                maxY,
                monitor.y +
                monitor.height
            )
        }

        root.minX = minX
        root.maxX = maxX
        root.minY = minY
        root.maxY = maxY

        root.layoutWidth =
            Math.max(
                1,
                maxX - minX
            )

        root.layoutHeight =
            Math.max(
                1,
                maxY - minY
            )
    }

    function monitorX(monitor) {
        return (
            padding +
            (
                (
                    monitor.x -
                    minX
                ) /
                layoutWidth
            ) *
            availableWidth
        )
    }

    function monitorY(monitor) {
        return (
            padding +
            (
                (
                    monitor.y -
                    minY
                ) /
                layoutHeight
            ) *
            availableHeight
        )
    }

    function monitorWidth(monitor) {
        return (
            (
                monitor.width /
                layoutWidth
            ) *
            availableWidth
        )
    }

    function monitorHeight(monitor) {
        return (
            (
                monitor.height /
                layoutHeight
            ) *
            availableHeight
        )
    }

    onMonitorsChanged: {
        Qt.callLater(
            updateBounds
        )
    }

    onWidthChanged: {
        Qt.callLater(
            updateBounds
        )
    }

    onHeightChanged: {
        Qt.callLater(
            updateBounds
        )
    }

    Component.onCompleted: {
        updateBounds()
    }

    Rectangle {
        anchors.fill: parent

        radius: 18

        color:
            ThemeColors.surface

        border.width: 1

        border.color:
            ThemeColors.border

        opacity: 0.72
    }

    /*
     * Center lines make the virtual layout easier
     * to understand without making the preview busy.
     */
    Rectangle {
        x:
            root.padding +
            (
                (
                    0 -
                    root.minX
                ) /
                root.layoutWidth
            ) *
            root.availableWidth

        y: root.padding

        width: 1

        height:
            root.availableHeight

        color:
            ThemeColors.border

        opacity: 0.35

        visible:
            root.minX <= 0 &&
            root.maxX >= 0
    }

    Rectangle {
        x: root.padding

        y:
            root.padding +
            (
                (
                    0 -
                    root.minY
                ) /
                root.layoutHeight
            ) *
            root.availableHeight

        width:
            root.availableWidth

        height: 1

        color:
            ThemeColors.border

        opacity: 0.35

        visible:
            root.minY <= 0 &&
            root.maxY >= 0
    }

    Repeater {
        model:
            root.monitors

        delegate: Item {
            id: monitorItem

            required property var modelData

            x:
                root.monitorX(
                    modelData
                )

            y:
                root.monitorY(
                    modelData
                )

            width:
                Math.max(
                    58,
                    root.monitorWidth(
                        modelData
                    )
                )

            height:
                Math.max(
                    42,
                    root.monitorHeight(
                        modelData
                    )
                )

            Rectangle {
                anchors.fill: parent

                radius: 14

                color:
                    root.selectedMonitor ===
                    modelData.name
                        ? ThemeColors.accent
                        : ThemeColors.background

                border.width:
                    root.selectedMonitor ===
                    modelData.name
                        ? 2
                        : 1

                border.color:
                    root.selectedMonitor ===
                    modelData.name
                        ? ThemeColors.accent
                        : ThemeColors.border

                opacity:
                    modelData.disabled
                        ? 0.4
                        : 1.0

                Behavior on color {
                    ColorAnimation {
                        duration: 140
                    }
                }

                Behavior on border.color {
                    ColorAnimation {
                        duration: 140
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 140
                    }
                }
            }

            Column {
                anchors.centerIn: parent

                spacing: 3

                Text {
                    anchors.horizontalCenter:
                        parent.horizontalCenter

                    text:
                        modelData.name

                    color:
                        root.selectedMonitor ===
                        modelData.name
                            ? ThemeColors.background
                            : ThemeColors.text

                    font.pixelSize:
                        Math.min(
                            13,
                            Math.max(
                                9,
                                monitorItem.width / 18
                            )
                        )

                    font.weight:
                        Font.DemiBold
                }

                Text {
                    anchors.horizontalCenter:
                        parent.horizontalCenter

                    text:
                        modelData.width +
                        " × " +
                        modelData.height

                    color:
                        root.selectedMonitor ===
                        modelData.name
                            ? ThemeColors.background
                            : ThemeColors.textMuted

                    font.pixelSize: 8
                }

                Text {
                    visible:
                        modelData.mirrorOf !== ""

                    anchors.horizontalCenter:
                        parent.horizontalCenter

                    text: "MIRROR"

                    color:
                        root.selectedMonitor ===
                        modelData.name
                            ? ThemeColors.background
                            : ThemeColors.accent

                    font.pixelSize: 7

                    font.weight:
                        Font.DemiBold
                }
            }

            HoverHandler {
                id: hoverHandler

                cursorShape:
                    Qt.PointingHandCursor
            }

            TapHandler {
                onTapped:
                    root.monitorClicked(
                        modelData.name
                    )
            }

            scale:
                hoverHandler.hovered
                    ? 1.015
                    : 1.0

            Behavior on scale {
                NumberAnimation {
                    duration: 110

                    easing.type:
                        Easing.OutCubic
                }
            }
        }
    }
}