import QtQuick
import QtQuick.Controls

import "../../common"
import "../../services"

Item {
    id: root

    signal backRequested()

    implicitWidth: 420
    implicitHeight: 480

    property string searchText: ""

    Column {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 12

        PageHeader {
            width: parent.width
            title: "Clipboard"
            subtitle: "Your clipboard history"

            onBackClicked: root.backRequested()
        }

        Row {
            width: parent.width
            spacing: 8

            Rectangle {
                width: parent.width - 44
                height: 38
                radius: 12
                color: ThemeColors.surface
                border.width: 1
                border.color: ThemeColors.border

                TextInput {
                    anchors.fill: parent
                    anchors.margins: 10
                    verticalAlignment: TextInput.AlignVCenter
                    color: ThemeColors.text
                    selectionColor: ThemeColors.accent
                    selectedTextColor: ThemeColors.background
                    font.pixelSize: 12
                    clip: true

                    onTextChanged: root.searchText = text

                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        visible: parent.text.length === 0
                        text: "Search clipboard..."
                        color: ThemeColors.textMuted
                        font.pixelSize: 12
                    }
                }
            }

            Rectangle {
                width: 36
                height: 38
                radius: 12
                color: ThemeColors.surface

                Text {
                    anchors.centerIn: parent
                    text: "󰑐"
                    color: ThemeColors.text
                    font.pixelSize: 17
                }

                TapHandler {
                    onTapped: ClipboardService.refresh()
                }
            }
        }

        Text {
            visible: ClipboardService.loading
            text: "Loading clipboard history..."
            color: ThemeColors.textMuted
            font.pixelSize: 11
        }

        Text {
            visible: ClipboardService.error.length > 0
            text: ClipboardService.error
            color: ThemeColors.error
            font.pixelSize: 11
        }

        ListView {
            id: clipboardList

            width: parent.width
            height: Math.max(0, parent.height - y)
            clip: true
            spacing: 8
            model: ClipboardService.entries.filter(
                entry => entry.text.toLowerCase().includes(
                    root.searchText.toLowerCase()
                )
            )

            ScrollBar.vertical: ScrollBar {}

            delegate: Rectangle {
                required property var modelData

                width: clipboardList.width
                height: Math.min(Math.max(contentText.implicitHeight + 42, 64), 110)
                radius: 12

                color: itemHover.hovered
                    ? ThemeColors.surfaceHover
                    : ThemeColors.surface

                border.width: 1
                border.color: itemHover.hovered
                    ? ThemeColors.accent
                    : ThemeColors.border

                Text {
                    id: contentText

                    anchors {
                        left: parent.left
                        right: copyButton.left
                        top: parent.top
                        bottom: parent.bottom
                        margins: 12
                    }

                    text: modelData.text
                    color: ThemeColors.text
                    font.pixelSize: 11
                    wrapMode: Text.Wrap
                    maximumLineCount: 4
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }

                Rectangle {
                    id: copyButton

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: 10
                    }

                    width: 30
                    height: 30
                    radius: 9
                    color: copyHover.hovered
                        ? ThemeColors.accent
                        : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "󰆏"
                        color: copyHover.hovered
                            ? ThemeColors.background
                            : ThemeColors.text
                        font.pixelSize: 17
                    }

                    HoverHandler {
                        id: copyHover
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: ClipboardService.copy(modelData.id)
                    }
                }

                HoverHandler {
                    id: itemHover
                }

                TapHandler {
                    onDoubleTapped: ClipboardService.copy(modelData.id)
                }

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: clipboardList.count === 0
                text: "No clipboard entries"
                color: ThemeColors.textMuted
                font.pixelSize: 12
            }
        }
    }
}