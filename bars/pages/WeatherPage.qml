import QtQuick
import QtQuick.Controls
import "../../common"
import "../../services"

Item {
    id: root

    signal backRequested()

    implicitWidth: 560
    implicitHeight: 620

    readonly property int sideMargin: 20
    readonly property int innerWidth: Math.max(0, width - sideMargin * 2)

    readonly property real weekMin: {
        if (!WeatherService.daily.length)
            return 0

        let value = WeatherService.daily[0].low

        for (let i = 1; i < WeatherService.daily.length; i++)
            value = Math.min(value, WeatherService.daily[i].low)

        return value
    }

    readonly property real weekMax: {
        if (!WeatherService.daily.length)
            return 1

        let value = WeatherService.daily[0].high

        for (let i = 1; i < WeatherService.daily.length; i++)
            value = Math.max(value, WeatherService.daily[i].high)

        return value
    }

    function hourLabel(value) {
        return value ? value.substring(11, 16) : "--:--"
    }

    function dayLabel(value) {
        const date = new Date(value + "T12:00:00")
        return date.toLocaleDateString(Qt.locale(), "ddd")
    }

    function fullDayLabel(value) {
        const date = new Date(value + "T12:00:00")
        return date.toLocaleDateString(Qt.locale(), "d MMMM")
    }

    function clockLabel(value) {
        return value ? value.substring(11, 16) : "--:--"
    }

    function temperature(value) {
        return value === undefined || value === null
            ? "--"
            : Math.round(value) + "°"
    }

    function percentage(value) {
        return value === undefined || value === null
            ? "--"
            : Math.round(value) + "%"
    }

    function uvDescription(value) {
        if (value === undefined || value === null)
            return "Unavailable"

        if (value <= 2)
            return "Low"
        if (value <= 5)
            return "Moderate"
        if (value <= 7)
            return "High"
        if (value <= 10)
            return "Very high"

        return "Extreme"
    }

    ScrollView {
        anchors.fill: parent
        clip: true
        contentWidth: availableWidth

        Column {
            width: parent.width
            spacing: 18

            PageHeader {
                x: root.sideMargin
                width: root.innerWidth

                title: "Weather"
                subtitle: WeatherService.city
                    + (WeatherService.region
                       ? ", " + WeatherService.region : "")

                onBackClicked: root.backRequested()
            }

            // CURRENT WEATHER
            Rectangle {
                x: root.sideMargin
                width: root.innerWidth
                height: 226
                radius: 22
                clip: true

                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: Qt.darker(ThemeColors.surface, 1.15)
                    }
                    GradientStop {
                        position: 1.0
                        color: Qt.lighter(ThemeColors.surface, 1.12)
                    }
                }

                border.width: 1
                border.color: ThemeColors.border

                // Decorative background
                Rectangle {
                    width: 180
                    height: 180
                    radius: 90
                    x: parent.width - 120
                    y: -90
                    color: ThemeColors.accent
                    opacity: 0.06
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 10

                    // HEADER
                    Item {
                        width: parent.width
                        height: Math.max(
                            currentWeatherTitle.implicitHeight,
                            currentWeatherDate.implicitHeight
                        )

                        Text {
                            id: currentWeatherTitle

                            anchors.left: parent.left
                            anchors.right: currentWeatherDate.left
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter

                            text: "CURRENT WEATHER"
                            color: ThemeColors.textMuted
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                        }

                        Text {
                            id: currentWeatherDate

                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter

                            width: Math.min(110, parent.width * 0.42)

                            text: Qt.formatDate(new Date(), "dddd, d MMM")

                            color: ThemeColors.textMuted
                            font.pixelSize: 10
                            horizontalAlignment: Text.AlignRight
                            elide: Text.ElideRight
                        }
                    }

                    // MAIN WEATHER
                    Row {
                        width: parent.width
                        height: 100
                        spacing: 4

                        Column {
                            width: parent.width - 100
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: root.temperature(
                                    WeatherService.current.temperature_2m
                                )
                                color: ThemeColors.text
                                font.pixelSize: parent.width < 220 ? 58 : 70
                                font.weight: Font.Light
                                font.letterSpacing: -3
                            }

                            Text {
                                width: parent.width
                                text: WeatherService.current.weather_code !== undefined
                                    ? WeatherService.weatherDescription(
                                        WeatherService.current.weather_code
                                    )
                                    : "Waiting for weather data"

                                color: ThemeColors.text
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }
                        }

                        Item {
                            width: 96
                            height: parent.height

                            Text {
                                anchors.centerIn: parent
                                text: WeatherService.weatherIcon(
                                    WeatherService.current.weather_code ?? -1,
                                    WeatherService.current.is_day ?? 1
                                )
                                color: ThemeColors.accent
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 68
                            }
                        }
                    }

                    // SEPARATOR
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: ThemeColors.border
                        opacity: 0.8
                    }

                    // BOTTOM DETAILS
                    Row {
                        width: parent.width
                        height: 40
                        spacing: 8

                        // FEELS LIKE
                        Column {
                            width: (parent.width - 16) / 3
                            spacing: 4

                            Text {
                                text: "FEELS LIKE"
                                color: ThemeColors.textMuted
                                font.pixelSize: 9
                                font.weight: Font.Bold
                                font.letterSpacing: 0.7
                            }

                            Text {
                                text: root.temperature(
                                    WeatherService.current.apparent_temperature
                                )
                                color: ThemeColors.text
                                font.pixelSize: 15
                                font.weight: Font.DemiBold
                            }
                        }

                        // HIGH
                        Column {
                            width: (parent.width - 16) / 3
                            spacing: 4

                            Text {
                                text: "HIGH"
                                color: ThemeColors.textMuted
                                font.pixelSize: 9
                                font.weight: Font.Bold
                                font.letterSpacing: 0.7
                            }

                            Text {
                                text: WeatherService.daily.length
                                    ? root.temperature(WeatherService.daily[0].high)
                                    : "--"
                                color: ThemeColors.text
                                font.pixelSize: 15
                                font.weight: Font.DemiBold
                            }
                        }

                        // LOW
                        Column {
                            width: (parent.width - 16) / 3
                            spacing: 4

                            Text {
                                text: "LOW"
                                color: ThemeColors.textMuted
                                font.pixelSize: 9
                                font.weight: Font.Bold
                                font.letterSpacing: 0.7
                            }

                            Text {
                                text: WeatherService.daily.length
                                    ? root.temperature(WeatherService.daily[0].low)
                                    : "--"
                                color: ThemeColors.text
                                font.pixelSize: 15
                                font.weight: Font.DemiBold
                            }
                        }
                    }
                }
            }

            // ERROR
            Rectangle {
                x: root.sideMargin
                width: root.innerWidth
                height: errorText.implicitHeight + 24
                radius: 12
                color: Qt.rgba(1, 0.25, 0.2, 0.10)
                visible: WeatherService.error.length > 0

                Text {
                    id: errorText
                    anchors.fill: parent
                    anchors.margins: 12
                    text: WeatherService.error
                    color: ThemeColors.error
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                }
            }

            // QUICK CONDITIONS
            Column {
                x: root.sideMargin
                width: root.innerWidth
                spacing: 10

                Text {
                    text: "Conditions"
                    color: ThemeColors.text
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                }

                Row {
                    width: parent.width
                    spacing: 10

                    Repeater {
                        model: [
                            {
                                title: "Humidity",
                                value: root.percentage(
                                    WeatherService.current.relative_humidity_2m),
                                icon: "󰖌",
                                detail: "Relative humidity"
                            },
                            {
                                title: "Wind",
                                value: WeatherService.current.wind_speed_10m !== undefined
                                    ? Math.round(
                                        WeatherService.current.wind_speed_10m)
                                        + " km/h"
                                    : "--",
                                icon: "󰖝",
                                detail: "Wind speed"
                            },
                            {
                                title: "UV index",
                                value: WeatherService.daily.length
                                    ? WeatherService.daily[0].uv.toFixed(1)
                                    : "--",
                                icon: "󰖙",
                                detail: WeatherService.daily.length
                                    ? root.uvDescription(
                                        WeatherService.daily[0].uv)
                                    : "Unavailable"
                            }
                        ]

                        delegate: Rectangle {
                            required property var modelData

                            width: (parent.width - 20) / 3
                            height: 112
                            radius: 16
                            color: ThemeColors.surface
                            border.width: 1
                            border.color: ThemeColors.border

                            Column {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: 12
                                anchors.rightMargin: 8
                                spacing: 7

                                Text {
                                    text: modelData.icon
                                    color: ThemeColors.accent
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 21
                                }

                                Text {
                                    text: modelData.value
                                    color: ThemeColors.text
                                    font.pixelSize: 17
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: modelData.title
                                    color: ThemeColors.textMuted
                                    font.pixelSize: 10
                                }

                                Text {
                                    text: modelData.detail
                                    color: ThemeColors.textMuted
                                    font.pixelSize: 9
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }

            // TODAY DETAILS
            Rectangle {
                x: root.sideMargin
                width: root.innerWidth
                height: 154
                radius: 18
                color: ThemeColors.surface
                border.width: 1
                border.color: ThemeColors.border

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 14

                    Item {
                        width: parent.width
                        height: Math.max(
                            daylightTitle.implicitHeight,
                            daylightTime.implicitHeight
                        )

                        Text {
                            id: daylightTitle

                            anchors.left: parent.left
                            anchors.right: daylightTime.left
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter

                            text: "Daylight"
                            color: ThemeColors.text
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                        }

                        Text {
                            id: daylightTime

                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter

                            width: Math.min(125, parent.width * 0.48)

                            text: WeatherService.daily.length
                                ? root.clockLabel(WeatherService.daily[0].sunrise)
                                    + " – "
                                    + root.clockLabel(WeatherService.daily[0].sunset)
                                : "--:-- – --:--"

                            color: ThemeColors.textMuted
                            font.pixelSize: 10
                            horizontalAlignment: Text.AlignRight
                            elide: Text.ElideRight
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: 12

                        // SUNRISE
                        Rectangle {
                            width: (parent.width - 12) / 2
                            height: 72
                            radius: 13
                            color: Qt.rgba(
                                ThemeColors.accent.r,
                                ThemeColors.accent.g,
                                ThemeColors.accent.b,
                                0.08
                            )

                            Row {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 10

                                Text {
                                    text: "󰖜"
                                    color: ThemeColors.accent
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 25
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 4

                                    Text {
                                        text: "Sunrise"
                                        color: ThemeColors.textMuted
                                        font.pixelSize: 10
                                    }

                                    Text {
                                        text: WeatherService.daily.length
                                            ? root.clockLabel(
                                                WeatherService.daily[0].sunrise)
                                            : "--:--"

                                        color: ThemeColors.text
                                        font.pixelSize: 17
                                        font.weight: Font.DemiBold
                                    }
                                }
                            }
                        }

                        // SUNSET
                        Rectangle {
                            width: (parent.width - 12) / 2
                            height: 72
                            radius: 13
                            color: Qt.rgba(
                                ThemeColors.accent.r,
                                ThemeColors.accent.g,
                                ThemeColors.accent.b,
                                0.08
                            )

                            Row {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 10

                                Text {
                                    text: "󰖛"
                                    color: ThemeColors.accent
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 25
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 4

                                    Text {
                                        text: "Sunset"
                                        color: ThemeColors.textMuted
                                        font.pixelSize: 10
                                    }

                                    Text {
                                        text: WeatherService.daily.length
                                            ? root.clockLabel(
                                                WeatherService.daily[0].sunset)
                                            : "--:--"

                                        color: ThemeColors.text
                                        font.pixelSize: 17
                                        font.weight: Font.DemiBold
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // HOURLY FORECAST
            Column {
                x: root.sideMargin
                width: root.innerWidth
                spacing: 12
                Item {
                    width: parent.width
                    height: hourlyHeaderColumn.implicitHeight

                    Column {
                        id: hourlyHeaderColumn

                        anchors.left: parent.left
                        anchors.right: hourlyBadge.left
                        anchors.rightMargin: 8

                        spacing: 3

                        Text {
                            text: "Hourly forecast"
                            color: ThemeColors.text
                            font.pixelSize: 16
                            font.weight: Font.DemiBold
                        }

                        Text {
                            width: parent.width

                            text: "Temperature throughout the day"
                            color: ThemeColors.textMuted
                            font.pixelSize: 10
                            elide: Text.ElideRight
                        }
                    }

                    Text {
                        id: hourlyBadge

                        anchors.right: parent.right
                        anchors.top: parent.top

                        text: "24H"
                        color: ThemeColors.accent
                        font.pixelSize: 10
                        font.weight: Font.Bold
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 210
                    radius: 18
                    color: ThemeColors.surface
                    border.width: 1
                    border.color: ThemeColors.border
                    clip: true

                    Canvas {
                        id: hourlyChart

                        anchors.fill: parent
                        anchors.margins: 12

                        function drawChart(ctx) {
                            const data = WeatherService.hourly

                            if (!data || data.length < 2)
                                return

                            const left = 34
                            const right = width - 12
                            const top = 20
                            const bottom = height - 30

                            const chartWidth = right - left
                            const chartHeight = bottom - top

                            let minTemp = Number(data[0].temperature)
                            let maxTemp = minTemp

                            for (let i = 1; i < data.length; i++) {
                                minTemp = Math.min(
                                    minTemp,
                                    Number(data[i].temperature)
                                )

                                maxTemp = Math.max(
                                    maxTemp,
                                    Number(data[i].temperature)
                                )
                            }

                            const padding = Math.max(
                                2,
                                (maxTemp - minTemp) * 0.2
                            )

                            minTemp = Math.floor(minTemp - padding)
                            maxTemp = Math.ceil(maxTemp + padding)

                            if (maxTemp === minTemp)
                                maxTemp = minTemp + 1

                            function pointX(index) {
                                return left
                                    + (index / (data.length - 1)) * chartWidth
                            }

                            function pointY(value) {
                                return bottom
                                    - ((value - minTemp) / (maxTemp - minTemp))
                                        * chartHeight
                            }

                            ctx.clearRect(0, 0, width, height)

                            // GRID
                            ctx.font = "10px sans-serif"
                            ctx.textAlign = "right"
                            ctx.textBaseline = "middle"

                            for (let i = 0; i <= 3; i++) {
                                const value = maxTemp
                                    - (i / 3) * (maxTemp - minTemp)

                                const y = top + (i / 3) * chartHeight

                                ctx.beginPath()
                                ctx.moveTo(left, y)
                                ctx.lineTo(right, y)

                                ctx.strokeStyle = ThemeColors.border
                                ctx.lineWidth = 1
                                ctx.stroke()

                                ctx.fillStyle = ThemeColors.textMuted
                                ctx.fillText(
                                    Math.round(value) + "°",
                                    left - 8,
                                    y
                                )
                            }

                            // TEMPERATURE POINTS
                            const points = []

                            for (let i = 0; i < data.length; i++) {
                                points.push({
                                    x: pointX(i),
                                    y: pointY(Number(data[i].temperature)),
                                    temperature: Math.round(
                                        Number(data[i].temperature)
                                    )
                                })
                            }

                            // AREA FILL
                            const gradient = ctx.createLinearGradient(
                                0, top, 0, bottom
                            )

                            gradient.addColorStop(
                                0,
                                Qt.rgba(
                                    ThemeColors.accent.r,
                                    ThemeColors.accent.g,
                                    ThemeColors.accent.b,
                                    0.30
                                )
                            )

                            gradient.addColorStop(
                                1,
                                Qt.rgba(
                                    ThemeColors.accent.r,
                                    ThemeColors.accent.g,
                                    ThemeColors.accent.b,
                                    0.01
                                )
                            )

                            ctx.beginPath()
                            ctx.moveTo(points[0].x, bottom)
                            ctx.lineTo(points[0].x, points[0].y)

                            for (let i = 1; i < points.length; i++) {
                                const previous = points[i - 1]
                                const current = points[i]

                                const middleX = (previous.x + current.x) / 2

                                ctx.quadraticCurveTo(
                                    previous.x,
                                    previous.y,
                                    middleX,
                                    (previous.y + current.y) / 2
                                )
                            }

                            ctx.lineTo(
                                points[points.length - 1].x,
                                points[points.length - 1].y
                            )

                            ctx.lineTo(
                                points[points.length - 1].x,
                                bottom
                            )

                            ctx.closePath()
                            ctx.fillStyle = gradient
                            ctx.fill()

                            // TEMPERATURE LINE
                            ctx.beginPath()
                            ctx.moveTo(points[0].x, points[0].y)

                            for (let i = 1; i < points.length; i++) {
                                const previous = points[i - 1]
                                const current = points[i]

                                const middleX = (previous.x + current.x) / 2

                                ctx.quadraticCurveTo(
                                    previous.x,
                                    previous.y,
                                    middleX,
                                    (previous.y + current.y) / 2
                                )
                            }

                            const last = points[points.length - 1]

                            ctx.lineTo(last.x, last.y)

                            ctx.strokeStyle = ThemeColors.accent
                            ctx.lineWidth = 2.5
                            ctx.lineCap = "round"
                            ctx.lineJoin = "round"
                            ctx.stroke()

                            // POINTS
                            for (let i = 0; i < points.length; i++) {
                                const point = points[i]

                                ctx.beginPath()
                                ctx.arc(point.x, point.y, 3, 0, Math.PI * 2)

                                ctx.fillStyle = ThemeColors.surface
                                ctx.fill()

                                ctx.beginPath()
                                ctx.arc(point.x, point.y, 2, 0, Math.PI * 2)

                                ctx.fillStyle = ThemeColors.accent
                                ctx.fill()
                            }

                            // TIME LABELS
                            ctx.font = "10px sans-serif"
                            ctx.textAlign = "center"
                            ctx.textBaseline = "top"
                            ctx.fillStyle = ThemeColors.textMuted

                            for (let i = 0; i < data.length; i += 3) {
                                ctx.fillText(
                                    root.hourLabel(data[i].time),
                                    pointX(i),
                                    bottom + 10
                                )
                            }
                        }

                        onPaint: {
                            const ctx = getContext("2d")
                            drawChart(ctx)
                        }

                        Connections {
                            target: WeatherService

                            function onHourlyChanged() {
                                hourlyChart.requestPaint()
                            }
                        }

                        Component.onCompleted: requestPaint()
                    }
                }
            }

            // WEEKLY FORECAST
            Column {
                x: root.sideMargin
                width: root.innerWidth
                spacing: 12

                Column {
                    spacing: 3

                    Text {
                        text: "7-day forecast"
                        color: ThemeColors.text
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: "Temperature outlook"
                        color: ThemeColors.textMuted
                        font.pixelSize: 10
                    }
                }

                Repeater {
                    model: WeatherService.daily

                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        width: parent.width
                        height: 64
                        radius: 13
                        color: index === 0
                            ? Qt.rgba(
                                ThemeColors.accent.r,
                                ThemeColors.accent.g,
                                ThemeColors.accent.b,
                                0.08
                              )
                            : ThemeColors.surface

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 13
                            anchors.rightMargin: 13
                            spacing: 9

                            Text {
                                width: 38
                                anchors.verticalCenter: parent.verticalCenter

                                text: index === 0
                                    ? "Today"
                                    : root.dayLabel(modelData.date)

                                color: index === 0
                                    ? ThemeColors.accent
                                    : ThemeColors.text

                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                            }

                            Text {
                                width: 25
                                anchors.verticalCenter: parent.verticalCenter

                                text: WeatherService.weatherIcon(
                                    modelData.code, 1)

                                color: ThemeColors.accent
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 20
                            }

                            Text {
                                width: 34
                                anchors.verticalCenter: parent.verticalCenter

                                text: root.temperature(modelData.low)
                                color: ThemeColors.textMuted
                                font.pixelSize: 11
                                horizontalAlignment: Text.AlignRight
                            }

                            // TEMPERATURE RANGE
                            Item {
                                width: parent.width - 38 - 25 - 34 - 34 - 36
                                height: 8
                                anchors.verticalCenter: parent.verticalCenter

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 4
                                    color: ThemeColors.border
                                }

                                Rectangle {
                                    height: parent.height
                                    radius: 4

                                    x: root.weekMax === root.weekMin
                                        ? 0
                                        : (modelData.low - root.weekMin)
                                            / (root.weekMax - root.weekMin)
                                            * parent.width

                                    width: root.weekMax === root.weekMin
                                        ? parent.width
                                        : Math.max(
                                            8,
                                            (modelData.high - modelData.low)
                                                / (root.weekMax - root.weekMin)
                                                * parent.width
                                          )

                                    color: ThemeColors.accent
                                }
                            }

                            Text {
                                width: 34
                                anchors.verticalCenter: parent.verticalCenter

                                text: root.temperature(modelData.high)
                                color: ThemeColors.text
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                }
            }

            // EXTRA DETAILS
            Column {
                x: root.sideMargin
                width: root.innerWidth
                spacing: 10

                Text {
                    text: "More details"
                    color: ThemeColors.text
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                }

                Grid {
                    width: parent.width
                    columns: 2
                    columnSpacing: 10
                    rowSpacing: 10

                    Repeater {
                        model: [
                            {
                                title: "Rain chance",
                                value: WeatherService.hourly.length
                                    ? root.percentage(
                                        WeatherService.hourly[0].rainChance)
                                    : "--",
                                icon: "󰖗"
                            },
                            {
                                title: "Precipitation",
                                value: WeatherService.current.precipitation !== undefined
                                    ? WeatherService.current.precipitation + " mm"
                                    : "--",
                                icon: "󰖗"
                            },
                            {
                                title: "Pressure",
                                value: WeatherService.current.pressure_msl !== undefined
                                    ? Math.round(
                                        WeatherService.current.pressure_msl)
                                        + " hPa"
                                    : "--",
                                icon: "󰓅"
                            },
                            {
                                title: "Cloud cover",
                                value: root.percentage(
                                    WeatherService.current.cloud_cover),
                                icon: "󰖐"
                            },
                            {
                                title: "Wind gusts",
                                value: WeatherService.current.wind_gusts_10m !== undefined
                                    ? Math.round(
                                        WeatherService.current.wind_gusts_10m)
                                        + " km/h"
                                    : "--",
                                icon: "󰖝"
                            },
                            {
                                title: "Visibility",
                                value: WeatherService.hourly.length
                                    && WeatherService.hourly[0].visibility !== undefined
                                    ? (WeatherService.hourly[0].visibility / 1000)
                                        .toFixed(1) + " km"
                                    : "--",
                                icon: "󰈈"
                            }
                        ]

                        delegate: Rectangle {
                            required property var modelData

                            width: (parent.width - 10) / 2
                            height: 68
                            radius: 13
                            color: ThemeColors.surface
                            border.width: 1
                            border.color: ThemeColors.border

                            Row {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 10

                                Text {
                                    text: modelData.icon
                                    color: ThemeColors.accent
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 20
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 5

                                    Text {
                                        text: modelData.title
                                        color: ThemeColors.textMuted
                                        font.pixelSize: 10
                                    }

                                    Text {
                                        text: modelData.value
                                        color: ThemeColors.text
                                        font.pixelSize: 13
                                        font.weight: Font.DemiBold
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // LOCATION FOOTER
            Row {
                x: root.sideMargin
                width: root.innerWidth
                height: 40
                spacing: 8

                Text {
                    text: "󰍎"
                    color: ThemeColors.textMuted
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 15
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    width: parent.width - 75
                    text: WeatherService.latitude.toFixed(3)
                        + ", " + WeatherService.longitude.toFixed(3)

                    color: ThemeColors.textMuted
                    font.pixelSize: 10
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: 36
                    height: 32
                    radius: 10
                    color: ThemeColors.surface
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "󰑐"
                        color: ThemeColors.text
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 17
                    }

                    TapHandler {
                        onTapped: WeatherService.refreshLocation()
                    }
                }
            }

            Item {
                width: 1
                height: 8
            }
        }
    }
}