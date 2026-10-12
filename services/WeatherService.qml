
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string city: "Malatya"
    property real temperature: 0
    property real feelsLike: 0
    property int humidity: 0
    property real windSpeed: 0
    property string condition: "Loading..."
    property string updatedAt: ""
    property var hourly: []
    property string error: ""
    property bool loading: false

    function refresh() {
        loading = true
        error = ""
        request.command = [
            "curl", "-fsSL", "--max-time", "10",
            "https://wttr.in/" + encodeURIComponent(city) + "?format=j1"
        ]
        request.running = true
    }

    Process {
        id: request

        command: ["curl", "-fsSL", "--max-time", "10",
                  "https://wttr.in/Malatya?format=j1"]

        stdout: StdioCollector {
            id: output
        }

        stderr: StdioCollector {}

        onExited: (exitCode) => {
            root.loading = false

            if (exitCode !== 0) {
                root.error = "Could not load weather"
                return
            }

            try {
                const data = JSON.parse(output.text)
                const current = data.current_condition[0]

                root.temperature = Number(current.temp_C)
                root.feelsLike = Number(current.FeelsLikeC)
                root.humidity = Number(current.humidity)
                root.windSpeed = Number(current.windspeedKmph)
                root.condition = current.weatherDesc[0].value
                root.updatedAt = current.localObsDateTime

                const hours = data.weather[0].hourly
                const result = []

                for (let i = 0; i < hours.length; i++) {
                    if (i % 3 !== 0)
                        continue

                    result.push({
                        time: hours[i].time,
                        temperature: Number(hours[i].tempC),
                        condition: hours[i].weatherDesc[0].value
                    })
                }

                root.hourly = result
                root.error = ""
            } catch (e) {
                root.error = "Invalid weather data"
            }
        }
    }

    Timer {
        interval: 900000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: root.refresh()
}
