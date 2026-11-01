
pragma Singleton

import QtQuick
import QtQml
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string city: ""
    property string region: ""
    property real latitude: 0
    property real longitude: 0

    property bool loading: false
    property string error: ""

    property var current: ({})
    property var hourly: []
    property var daily: []

    function refreshLocation() {
        loading = true
        error = ""
        locationRequest.running = true
    }

    function refreshWeather() {
        const url = "https://api.open-meteo.com/v1/forecast"
            + "?latitude=" + latitude
            + "&longitude=" + longitude
            + "&timezone=auto"
            + "&forecast_days=7"
            + "&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,rain,showers,snowfall,weather_code,cloud_cover,pressure_msl,surface_pressure,wind_speed_10m,wind_direction_10m,wind_gusts_10m"
            + "&hourly=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation_probability,precipitation,weather_code,wind_speed_10m,wind_gusts_10m,uv_index,visibility,cloud_cover"
            + "&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max,precipitation_probability_max,precipitation_sum,wind_speed_10m_max"

        weatherRequest.command = ["curl", "-fsSL", "--max-time", "15", url]
        weatherRequest.running = true
    }

    function weatherDescription(code) {
        const descriptions = {
            0: "Clear sky",
            1: "Mainly clear",
            2: "Partly cloudy",
            3: "Overcast",
            45: "Fog",
            48: "Rime fog",
            51: "Light drizzle",
            53: "Drizzle",
            55: "Heavy drizzle",
            56: "Freezing drizzle",
            57: "Heavy freezing drizzle",
            61: "Light rain",
            63: "Rain",
            65: "Heavy rain",
            66: "Freezing rain",
            67: "Heavy freezing rain",
            71: "Light snow",
            73: "Snow",
            75: "Heavy snow",
            77: "Snow grains",
            80: "Rain showers",
            81: "Moderate showers",
            82: "Heavy showers",
            85: "Snow showers",
            86: "Heavy snow showers",
            95: "Thunderstorm",
            96: "Thunderstorm with hail",
            99: "Heavy thunderstorm with hail"
        }

        return descriptions[code] ?? "Unknown conditions"
    }

    function weatherIcon(code, isDay) {
        if (code === 0)
            return isDay ? "󰖙" : "󰖔"
        if (code === 1 || code === 2)
            return isDay ? "󰖕" : "󰼱"
        if (code === 3)
            return "󰖐"
        if (code === 45 || code === 48)
            return "󰖑"
        if (code >= 51 && code <= 67)
            return "󰖗"
        if (code >= 71 && code <= 86)
            return "󰖘"
        if (code >= 95)
            return "󰖓"
        return "󰖐"
    }

    Process {
        id: locationRequest
        command: ["curl", "-fsSL", "--max-time", "10", "https://ipapi.co/json/"]

        stdout: StdioCollector {
            id: locationOutput
        }

        onExited: (exitCode) => {
            if (exitCode !== 0) {
                root.loading = false
                root.error = "Could not detect your location"
                return
            }

            try {
                const data = JSON.parse(locationOutput.text)

                if (!data.latitude || !data.longitude)
                    throw new Error("Location unavailable")

                root.city = data.city || "Unknown location"
                root.region = data.region || data.country_name || ""
                root.latitude = Number(data.latitude)
                root.longitude = Number(data.longitude)

                root.refreshWeather()
            } catch (e) {
                root.loading = false
                root.error = "Could not read location data"
            }
        }
    }

    Process {
        id: weatherRequest
        command: ["curl", "-fsSL", "--max-time", "15",
                  "https://api.open-meteo.com/v1/forecast"]

        stdout: StdioCollector {
            id: weatherOutput
        }

        onExited: (exitCode) => {
            root.loading = false

            if (exitCode !== 0) {
                root.error = "Could not load weather forecast"
                return
            }

            try {
                const data = JSON.parse(weatherOutput.text)

                root.current = data.current

                const h = data.hourly
                const now = data.current.time
                let start = h.time.findIndex(t => t >= now)

                if (start < 0)
                    start = 0

                const hours = []

                for (let i = start; i < Math.min(start + 24, h.time.length); i++) {
                    hours.push({
                        time: h.time[i],
                        temperature: h.temperature_2m[i],
                        feelsLike: h.apparent_temperature[i],
                        humidity: h.relative_humidity_2m[i],
                        rainChance: h.precipitation_probability[i],
                        precipitation: h.precipitation[i],
                        code: h.weather_code[i],
                        wind: h.wind_speed_10m[i],
                        gusts: h.wind_gusts_10m[i],
                        uv: h.uv_index[i],
                        visibility: h.visibility[i],
                        clouds: h.cloud_cover[i]
                    })
                }

                root.hourly = hours

                const d = data.daily
                const days = []

                for (let i = 0; i < d.time.length; i++) {
                    days.push({
                        date: d.time[i],
                        code: d.weather_code[i],
                        high: d.temperature_2m_max[i],
                        low: d.temperature_2m_min[i],
                        sunrise: d.sunrise[i],
                        sunset: d.sunset[i],
                        uv: d.uv_index_max[i],
                        rainChance: d.precipitation_probability_max[i],
                        precipitation: d.precipitation_sum[i],
                        wind: d.wind_speed_10m_max[i]
                    })
                }

                root.daily = days
                root.error = ""
            } catch (e) {
                root.error = "Could not parse weather data: " + e
            }
        }
    }

    Timer {
        interval: 900000
        repeat: true
        running: true
        onTriggered: root.refreshLocation()
    }

    Component.onCompleted: root.refreshLocation()
}
