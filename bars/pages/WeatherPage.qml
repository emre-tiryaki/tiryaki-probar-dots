
import QtQuick
import QtQuick.Controls
import "../../common"
import "../../services"

Item {
    id: root

    signal backRequested()

    implicitWidth: 560
    implicitHeight: 620

    function hourLabel(value) {
        return value.substring(11, 16)
    }

    function dayLabel(value) {
        const date = new Date(value + "T12:00:00")
        return date.toLocaleDateString(Qt.locale(), "ddd, d MMM")
    }

    function clockLabel(value) {
        return value ? value.substring(11, 16) : "--:--"
    }

    ScrollView {
        anchors.fill: parent
        clip: true
        contentWidth: availableWidth

        Column {
            width: parent.width
            spacing: 16
            padding: 20

            PageHeader {
                width: parent.width
                title: "Weather"
                subtitle: WeatherService.city
                    + (WeatherService.region
                       ? ", " + WeatherService.region : "")

                onBackClicked: root.backRequested()
            }

            Row {
                width: parent.width
                spacing: 16

                Column {
                    width: parent.width * 0.57
                    spacing: 8

                    Text {
                        text: WeatherService.loading
                            ? "Updating..."
                            : WeatherService.current.temperature_2m !== undefined
                                ? Math.round(WeatherService.current.temperature_2m) + "°"
                                : "--°"
                        color: ThemeColors.text
                        font.pixelSize: 64
                        font.weight: Font.Light
                    }

                    Text {
                        text: WeatherService.current.weather_code !== undefined
                            ? WeatherService.weatherDescription(
                                WeatherService.current.weather_code)
                            : "Waiting for weather data"
                        color: ThemeColors.text
                        font.pixelSize: 16
                    }

                    Text {
                        text: WeatherService.current.apparent_temperature !== undefined
                            ? "Feels like " + Math.round(
                                WeatherService.current.apparent_temperature) + "°C"
                            : ""
                        color: ThemeColors.textMuted
                        font.pixelSize: 12
                    }

                    Text {
                        text: WeatherService.daily.length
                            ? "H: " + Math.round(WeatherService.daily[0].high)
                                + "°   L: " + Math.round(WeatherService.daily[0].low) + "°"
                            : ""
                        color: ThemeColors.textMuted
                        font.pixelSize: 12
                    }
                }

                Item {
                    width: parent.width * 0.35
                    height: 130

                    Text {
                        anchors.centerIn: parent
                        text: WeatherService.weatherIcon(
                            WeatherService.current.weather_code ?? -1,
                            WeatherService.current.is_day ?? 1)
                        color: ThemeColors.accent
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 76
                    }
                }
            }

            Text {
                visible: WeatherService.error.length > 0
                width: parent.width
                text: WeatherService.error
                color: ThemeColors.error
                wrapMode: Text.Wrap
            }

            Row {
                width: parent.width
                spacing: 10

                Repeater {
                    model: [
                        {
                            title: "Humidity",
                            value: WeatherService.current.relative_humidity_2m,
                            unit: "%",
                            icon: "󰖌"
                        },
                        {
                            title: "Wind",
                            value: WeatherService.current.wind_speed_10m,
                            unit: " km/h",
                            icon: "󰖝"
                        },
                        {
                            title: "UV index",
                            value: WeatherService.daily.length
                                ? WeatherService.daily[0].uv : "--",
                            unit: "",
                            icon: "󰖙"
                        }
                    ]

                    delegate: Rectangle {
                        required property var modelData
                        width: (parent.width - 20) / 3
                        height: 100
                        radius: 16
                        color: ThemeColors.surface
                        border.width: 1
                        border.color: ThemeColors.border

                        Column {
                            anchors.centerIn: parent
                            spacing: 7

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.icon
                                color: ThemeColors.accent
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 20
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.value === undefined
                                    ? "--" : modelData.value + modelData.unit
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

            Grid {
                width: parent.width
                columns: 2
                spacing: 10

                Repeater {
                    model: [
                        {
                            title: "Rain chance",
                            value: WeatherService.hourly.length
                                ? WeatherService.hourly[0].rainChance + "%" : "--"
                        },
                        {
                            title: "Precipitation",
                            value: WeatherService.current.precipitation !== undefined
                                ? WeatherService.current.precipitation + " mm" : "--"
                        },
                        {
                            title: "Pressure",
                            value: WeatherService.current.pressure_msl !== undefined
                                ? WeatherService.current.pressure_msl + " hPa" : "--"
                        },
                        {
                            title: "Cloud cover",
                            value: WeatherService.current.cloud_cover !== undefined
                                ? WeatherService.current.cloud_cover + "%" : "--"
                        },
                        {
                            title: "Wind gusts",
                            value: WeatherService.current.wind_gusts_10m !== undefined
                                ? WeatherService.current.wind_gusts_10m + " km/h" : "--"
                        },
                        {
                            title: "Sunrise / sunset",
                            value: WeatherService.daily.length
                                ? root.clockLabel(WeatherService.daily[0].sunrise)
                                    + " / "
                                    + root.clockLabel(WeatherService.daily[0].sunset)
                                : "--"
                        }
                    ]

                    delegate: Rectangle {
                        required property var modelData
                        width: (parent.width - 10) / 2
                        height: 66
                        radius: 12
                        color: ThemeColors.surface

                        Column {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 14
                            spacing: 5

                            Text {
                                text: modelData.title
                                color: ThemeColors.textMuted
                                font.pixelSize: 11
                            }

                            Text {
                                text: modelData.value
                                color: ThemeColors.text
                                font.pixelSize: 14
                                font.weight: Font.DemiBold
                            }
                        }
                    }
                }
            }

            Row {
                width: parent.width

                Text {
                    text: "Next 24 hours"
                    color: ThemeColors.text
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                }

                Item { width: 1; height: 1 }
            }

            ListView {
                width: parent.width
                height: 125
                orientation: ListView.Horizontal
                spacing: 8
                clip: true
                model: WeatherService.hourly

                delegate: Rectangle {
                    required property var modelData
                    width: 84
                    height: 116
                    radius: 14
                    color: ThemeColors.surface

                    Column {
                        anchors.centerIn: parent
                        spacing: 7

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.hourLabel(modelData.time)
                            color: ThemeColors.textMuted
                            font.pixelSize: 10
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: WeatherService.weatherIcon(modelData.code, 1)
                            color: ThemeColors.accent
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 23
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Math.round(modelData.temperature) + "°"
                            color: ThemeColors.text
                            font.pixelSize: 16
                            font.weight: Font.DemiBold
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.rainChance + "% rain"
                            color: ThemeColors.textMuted
                            font.pixelSize: 9
                        }
                    }
                }
            }

            Text {
                text: "7-day forecast"
                color: ThemeColors.text
                font.pixelSize: 16
                font.weight: Font.DemiBold
            }

            Repeater {
                model: WeatherService.daily

                delegate: Rectangle {
                    required property var modelData
                    width: parent.width
                    height: 66
                    radius: 13
                    color: ThemeColors.surface

                    Row {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Text {
                            width: 90
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.dayLabel(modelData.date)
                            color: ThemeColors.text
                            font.pixelSize: 11
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: WeatherService.weatherIcon(modelData.code, 1)
                            color: ThemeColors.accent
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 22
                        }

                        Text {
                            width: 90
                            anchors.verticalCenter: parent.verticalCenter
                            text: WeatherService.weatherDescription(modelData.code)
                            color: ThemeColors.textMuted
                            font.pixelSize: 10
                            elide: Text.ElideRight
                        }

                        Item {
                            width: 1
                            height: 1
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: Math.round(modelData.low) + "° / "
                                + Math.round(modelData.high) + "°"
                            color: ThemeColors.text
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                        }
                    }
                }
            }

            Row {
                width: parent.width
                spacing: 12

                Text {
                    width: parent.width - 50
                    text: WeatherService.latitude.toFixed(3) + ", "
                        + WeatherService.longitude.toFixed(3)
                    color: ThemeColors.textMuted
                    font.pixelSize: 10
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: 38
                    height: 34
                    radius: 10
                    color: ThemeColors.surface

                    Text {
                        anchors.centerIn: parent
                        text: "󰑐"
                        color: ThemeColors.text
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 18
                    }

                    TapHandler {
                        onTapped: WeatherService.refreshLocation()
                    }
                }
            }
        }
    }
}
