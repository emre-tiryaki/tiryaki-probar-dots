import "../../common"
import "../../services"
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

Item {
    id: root

    function formatTime(seconds) {
        const total = Math.max(0, Math.floor(seconds));
        const m = Math.floor(total / 60);
        const s = total % 60;
        return m + ":" + (s < 10 ? "0" : "") + s;
    }

    function volumeIcon(v) {
        return v <= 0 ? "󰖁" : v < 0.34 ? "󰕿" : v < 0.67 ? "󰖀" : "󰕾";
    }

    visible: MediaService.hasPlayer
    implicitHeight: visible ? 144 : 0
    height: implicitHeight

    ArtPalette {
        id: colors

        source: MediaService.artUrl
        fallback: ThemeColors.accent
    }

    Timer {
        running: MediaService.isPlaying && root.visible
        interval: 1000
        repeat: true
        onTriggered: MediaService.player.positionChanged()
    }

    Rectangle {
        id: card

        anchors.fill: parent
        radius: 20
        color: colors.background

        Rectangle {
            id: cardMask

            anchors.fill: parent
            radius: card.radius
            visible: false
            layer.enabled: true
        }

        Image {
            anchors.fill: parent
            source: MediaService.artUrl
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            sourceSize.width: 96
            sourceSize.height: 96
            opacity: status === Image.Ready ? 0.3 : 0
            visible: opacity > 0
            layer.enabled: true

            layer.effect: MultiEffect {
                blurEnabled: true
                blur: 1
                blurMax: 32
                maskEnabled: true
                maskSource: cardMask
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                }
            }
        }

        Item {
            id: art

            width: 116
            height: 116

            anchors {
                left: parent.left
                leftMargin: 14
                verticalCenter: parent.verticalCenter
            }

            Rectangle {
                id: artMask

                anchors.fill: parent
                radius: 14
                visible: false
                layer.enabled: true
            }

            Image {
                id: artImage

                anchors.fill: parent
                source: MediaService.artUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize.width: 232
                sourceSize.height: 232
                visible: status === Image.Ready
                layer.enabled: true

                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: artMask
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: 14
                color: colors.surface
                visible: artImage.status !== Image.Ready

                SourceIcon {
                    anchors.centerIn: parent
                    size: 52
                    glyphColor: colors.accent
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: 14
                color: "transparent"
                border.width: 1
                border.color: Qt.alpha(colors.accent, 0.25)
            }
        }

        Column {
            id: info

            spacing: 4

            anchors {
                left: art.right
                leftMargin: 16
                right: parent.right
                rightMargin: 14
                verticalCenter: parent.verticalCenter
            }

            Item {
                width: parent.width
                height: 22

                Rectangle {
                    id: chip

                    width: 24
                    height: 24
                    radius: 8
                    color: chipHover.hovered ? colors.track : colors.surface

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }

                    SourceIcon {
                        anchors.centerIn: parent
                        size: 15
                        glyphColor: colors.accent
                    }

                    Rectangle {
                        visible: MediaService.players.length > 1
                        width: 12
                        height: 12
                        radius: 6
                        color: colors.accent

                        anchors {
                            top: parent.top
                            right: parent.right
                            topMargin: -4
                            rightMargin: -4
                        }

                        Text {
                            anchors.centerIn: parent
                            text: MediaService.players.length
                            color: colors.onAccent
                            font.pixelSize: 8
                            font.weight: Font.Bold
                        }
                    }

                    HoverHandler {
                        id: chipHover

                        cursorShape: MediaService.players.length > 1 ? Qt.PointingHandCursor : Qt.ArrowCursor
                    }

                    TapHandler {
                        onTapped: MediaService.cycle()
                    }
                }

                MarqueeText {
                    text: MediaService.title
                    color: colors.text
                    pixelSize: 15
                    anchors.verticalCenter: parent.verticalCenter

                    anchors {
                        left: parent.left
                        right: chip.left
                        rightMargin: 10
                    }
                }
            }

            RowLayout {
                id: metaRow

                width: parent.width
                height: 16
                spacing: 6

                Text {
                    text: MediaService.artist
                    color: colors.accent
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                    Layout.maximumWidth: metaRow.width * (MediaService.album !== "" ? 0.6 : 1)
                }

                Text {
                    visible: MediaService.album !== ""
                    text: "·"
                    color: colors.textMuted
                    font.pixelSize: 11
                }

                Text {
                    visible: MediaService.album !== ""
                    text: MediaService.album
                    color: colors.textMuted
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Item {
                    Layout.fillWidth: true
                    visible: MediaService.album === ""
                }
            }

            Item {
                width: parent.width
                height: 24

                Text {
                    id: positionText

                    width: 34
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.formatTime(progress.shown * MediaService.length)
                    color: colors.textMuted
                    font.pixelSize: 9
                }

                Text {
                    id: lengthText

                    width: 34
                    horizontalAlignment: Text.AlignRight
                    text: MediaService.length > 0 ? root.formatTime(MediaService.length) : "--:--"
                    color: colors.textMuted
                    font.pixelSize: 9

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                }

                FlatSlider {
                    id: progress

                    pal: colors
                    interactive: MediaService.canSeek
                    value: MediaService.length > 0 ? Math.min(1, MediaService.position / MediaService.length) : 0
                    onCommitted: v => MediaService.seek(v * MediaService.length)

                    anchors {
                        left: positionText.right
                        right: lengthText.left
                        leftMargin: 6
                        rightMargin: 6
                        verticalCenter: parent.verticalCenter
                    }
                }
            }

            Item {
                width: parent.width
                height: 40

                Row {
                    spacing: 2

                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                    }

                    MediaButton {
                        pal: colors
                        size: 28
                        icon: "󰒟"
                        active: MediaService.shuffle
                        available: MediaService.shuffleSupported
                        onClicked: MediaService.toggleShuffle()
                    }

                    MediaButton {
                        pal: colors
                        size: 28
                        icon: MediaService.loopMode === "track" ? "󰑘" : "󰑖"
                        active: MediaService.loopMode !== "none"
                        available: MediaService.loopSupported
                        onClicked: MediaService.cycleLoop()
                    }
                }

                Row {
                    spacing: 6
                    anchors.centerIn: parent

                    MediaButton {
                        pal: colors
                        size: 32
                        icon: "󰒮"
                        available: MediaService.player ? MediaService.player.canGoPrevious : false
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: MediaService.previous()
                    }

                    MediaButton {
                        pal: colors
                        primary: true
                        icon: MediaService.isPlaying ? "󰏤" : "󰐊"
                        available: MediaService.player ? MediaService.player.canTogglePlaying : false
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: MediaService.toggle()
                    }

                    MediaButton {
                        pal: colors
                        size: 32
                        icon: "󰒭"
                        available: MediaService.player ? MediaService.player.canGoNext : false
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: MediaService.next()
                    }
                }

                Row {
                    spacing: 2
                    opacity: MediaService.volumeSupported ? 1 : 0.35

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }

                    MediaButton {
                        pal: colors
                        size: 26
                        icon: root.volumeIcon(MediaService.volume)
                        available: MediaService.volumeSupported
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: MediaService.toggleMute()
                    }

                    FlatSlider {
                        width: 60
                        pal: colors
                        thickness: 4
                        interactive: MediaService.volumeSupported
                        value: MediaService.volume
                        anchors.verticalCenter: parent.verticalCenter
                        onMoved: v => MediaService.setVolume(v)
                    }
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: card.radius
            color: "transparent"
            border.width: 1
            border.color: Qt.alpha(colors.accent, 0.2)
        }
    }
}
