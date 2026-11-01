import "../../common"
import "../../services"
import QtQuick
import QtQuick.Effects

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
    implicitHeight: visible ? 176 : 0
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

        Row {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 16

            Item {
                id: art

                width: 148
                height: 148

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
                    sourceSize.width: 296
                    sourceSize.height: 296
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
                        size: 56
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

            Item {
                id: info

                width: parent.width - art.width - parent.spacing
                height: parent.height

                Item {
                    id: header

                    width: parent.width
                    height: 54

                    Rectangle {
                        id: chip

                        width: 32
                        height: 32
                        radius: 11
                        color: chipHover.hovered ? colors.track : colors.surface

                        anchors {
                            top: parent.top
                            right: parent.right
                        }

                        SourceIcon {
                            anchors.centerIn: parent
                            size: 20
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
                                topMargin: -3
                                rightMargin: -3
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

                    Column {
                        spacing: 2

                        anchors {
                            top: parent.top
                            left: parent.left
                            right: chip.left
                            rightMargin: 12
                        }

                        Text {
                            width: parent.width
                            text: MediaService.title
                            color: colors.text
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            text: MediaService.artist
                            color: colors.accent
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            visible: MediaService.album !== ""
                            text: MediaService.album
                            color: colors.textMuted
                            font.pixelSize: 10
                            elide: Text.ElideRight
                        }
                    }
                }

                Item {
                    id: progressRow

                    width: parent.width
                    height: 16

                    anchors {
                        bottom: controls.top
                        bottomMargin: 8
                    }

                    Text {
                        id: positionText

                        width: 34
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.formatTime(progress.shown * MediaService.length)
                        color: colors.textMuted
                        font.pixelSize: 9
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

                    Text {
                        id: lengthText

                        width: 34
                        horizontalAlignment: Text.AlignRight
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        text: MediaService.length > 0 ? root.formatTime(MediaService.length) : "--:--"
                        color: colors.textMuted
                        font.pixelSize: 9
                    }
                }

                Item {
                    id: controls

                    width: parent.width
                    height: 40

                    anchors.bottom: parent.bottom

                    Row {
                        spacing: 4

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
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked: MediaService.toggleShuffle()
                        }

                        MediaButton {
                            pal: colors
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
                            icon: "󰒭"
                            available: MediaService.player ? MediaService.player.canGoNext : false
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked: MediaService.next()
                        }

                        MediaButton {
                            pal: colors
                            size: 28
                            icon: MediaService.loopMode === "track" ? "󰑘" : "󰑖"
                            active: MediaService.loopMode !== "none"
                            available: MediaService.loopSupported
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked: MediaService.cycleLoop()
                        }
                    }

                    Row {
                        spacing: 4
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
                            width: 76
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