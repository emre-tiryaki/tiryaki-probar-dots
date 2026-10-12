
import QtQuick
import "../../common"
import "../../services"

Item {
    id: root

    signal backRequested()

    implicitWidth: 440
    implicitHeight: 470

    Column {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 14

        PageHeader {
            width: parent.width
            title: "Weather"
            subtitle: WeatherService.city

            onBackClicked: root.backRequested()
        }

        Rectangle {
            width: parent.width
            height: 150
            radius: 20
            color: ThemeColors.surface
            border.width: 1
            border.color: ThemeColors.border

            Column {
                anchors.centerIn: parent
                spacing: 5

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: WeatherService.loading
                        ? "󰑐"
                        : "󰖙"
                    color: ThemeColors.accent
                    font.pixelSize: 32
                    font.family: "Symbols Nerd Font"
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: WeatherService.loading
                        ? "Loading weather..."
                        : WeatherService.error.length
                            ? WeatherService.error
                            : Math.round(WeatherService.temperature) + "°C"
                    color: ThemeColors.text
                    font.pixelSize: 30
                    font.weight: Font.DemiBold
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: WeatherService.condition
                    color: ThemeColors.textMuted
                    font.pixelSize: 12
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Feels like " + Math.round(WeatherService.feelsLike) + "°C"
                    color: ThemeColors.textMuted
                    font.pixelSize: 10
                }
            }
        }

        Row {
            width: parent.width
            spacing: 10

            Repeater {
                model: [
                    {
                        title: "Humidity",
                        value: WeatherService.humidity + "%",
                        icon: "󰖌"
                    },
                    {
                        title: "Wind",
                        value: WeatherService.windSpeed + " km/h",
                        icon: "󰖝"
                    }
                ]

                delegate: Rectangle {
                    required property var modelData

                    width: (parent.width - 10) / 2
                    height: 82
                    radius: 15
                    color: ThemeColors.surface
                    border.width: 1
                    border.color: ThemeColors.border

                    Column {
                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.icon
                            color: ThemeColors.accent
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 20
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.value
                            color: ThemeColors.text
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.title
                            color: ThemeColors.textMuted
                            font.pixelSize: 10
                        }
                    }
                }
            }
        }

        Row {
            width: parent.width

            Text {
                text: "Hourly forecast"
                color: ThemeColors.text
                font.pixelSize: 13
                font.weight: Font.DemiBold
            }

            Item { width: 1; height: 1 }
        }

        ListView {
            width: parent.width
            height: 100
            orientation: ListView.Horizontal
            spacing: 8
            clip: true
            model: WeatherService.hourly

            delegate: Rectangle {
                required property var modelData

                width: 82
                height: 92
                radius: 13
                color: ThemeColors.surface
                border.width: 1
                border.color: ThemeColors.border

                Column {
                    anchors.centerIn: parent
                    spacing: 7

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: {
                            const raw = Number(modelData.time)
                            return raw === 0
                                ? "00:00"
                                : String(Math.floor(raw / 100)).padStart(2, "0") + ":00"
                        }
                        color: ThemeColors.textMuted
                        font.pixelSize: 10
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰖙"
                        color: ThemeColors.accent
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 20
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: modelData.temperature + "°"
                        color: ThemeColors.text
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                    }
                }
            }
        }

        Item {
            width: parent.width
            height: 28

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: WeatherService.error.length
                    ? WeatherService.error
                    : "Updated: " + WeatherService.updatedAt
                color: ThemeColors.textMuted
                font.pixelSize: 9
                elide: Text.ElideRight
                width: parent.width - 42
            }

            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 30
                height: 28
                radius: 9
                color: ThemeColors.surface

                Text {
                    anchors.centerIn: parent
                    text: "󰑐"
                    color: ThemeColors.text
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 16
                }

                TapHandler {
                    onTapped: WeatherService.refresh()
                }
            }
        }
    }
}
