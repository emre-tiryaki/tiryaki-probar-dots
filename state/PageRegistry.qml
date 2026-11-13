pragma Singleton

import Quickshell

// Single place to register pages. To add a page:
//   1. create bars/pages/MyPage.qml (optionally declare `signal backRequested()`
//      and `signal openPage(string id)`; both are wired automatically)
//   2. add an entry below.
// The first entry of each list is that panel's home page.
// Center entries with a `title` are shown as cards on the center home page.
Singleton {
    readonly property var center: [
        { id: "home",       file: "CenterHome.qml" },
        { id: "power",      file: "PowerPage.qml",     icon: "󰐥", title: "Power",        description: "Shutdown & restart" },
        { id: "stats",      file: "StatsPage.qml",     icon: "󰍛", title: "System Stats", description: "CPU, GPU & memory" },
        { id: "power-mode", file: "PowerModePage.qml", icon: "󰂄", title: "Power Mode",   description: "Performance profiles" },
        { id: "weather",    file: "WeatherPage.qml",   icon: "󰖙", title: "Weather",      description: "Weather forecast" },
        { id: "clock",      file: "ClockPage.qml",     icon: "󰥔", title: "Clock",        description: "Clock & stopwatch" },
        { id: "calendar",   file: "CalendarPage.qml",  icon: "󰃭", title: "Calendar",     description: "View your calendar" },
        { id: "clipboard",  file: "ClipboardPage.qml", icon: "󰅍", title: "Clipboard",    description: "Clipboard history" },
        { id: "launcher",   file: "LauncherPage.qml" }
    ]

    readonly property var right: [
        { id: "control",   file: "ControlCenter.qml" },
        { id: "wifi",      file: "WifiPage.qml" },
        { id: "bluetooth", file: "BluetoothPage.qml" },
        { id: "audio",     file: "AudioPage.qml" },
        { id: "input",      file: "InputPage.qml" },
        { id: "brightness", file: "BrightnessPage.qml" }
    ]

    readonly property var stats: [
        { id: "overview", file: "StatsOverview.qml" },
        { id: "cpu",      file: "CpuStatsPage.qml" },
        { id: "gpu",      file: "GpuStatsPage.qml" }
    ]
}
