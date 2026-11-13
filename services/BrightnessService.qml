pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Screen and keyboard backlight via brightnessctl.
Singleton {
    id: root

    // Screen backlight
    property string screenDevice: ""
    property int screenRaw: 0
    property int screenMax: 0
    readonly property bool available: screenDevice !== "" && screenMax > 0
    readonly property real brightness: available ? screenRaw / screenMax : 0

    // Keyboard backlight (discrete levels 0..keyboardMax)
    property string keyboardDevice: ""
    property int keyboardLevel: 0
    property int keyboardMax: 0
    readonly property bool keyboardAvailable: keyboardDevice !== "" && keyboardMax > 0
    readonly property real keyboardBrightness: keyboardAvailable ? keyboardLevel / keyboardMax : 0

    // Lowest screen brightness allowed from the slider, so the screen never goes fully dark.
    readonly property real minBrightness: 0.01

    readonly property string icon: brightness < 0.34 ? "󰃞" : brightness < 0.67 ? "󰃟" : "󰃠"

    function parseLine(line) {
        // name,class,current,percent,max
        const parts = line.split(",");
        if (parts.length < 5)
            return null;
        return { name: parts[0], cls: parts[1], current: parseInt(parts[2]), max: parseInt(parts[4]) };
    }

    function refresh() {
        if (!readProcess.running)
            readProcess.running = true;
    }

    function setBrightness(value) {
        if (!available)
            return;
        const v = Math.max(minBrightness, Math.min(1, value));
        screenRaw = Math.round(v * screenMax);
        screenWriter.queue([screenDevice, String(screenRaw)]);
    }

    function changeBrightness(delta) {
        setBrightness(brightness + delta);
    }

    function setKeyboardLevel(level) {
        if (!keyboardAvailable)
            return;
        keyboardLevel = Math.max(0, Math.min(keyboardMax, Math.round(level)));
        keyboardWriter.queue([keyboardDevice, String(keyboardLevel)]);
    }

    function setKeyboardBrightness(value) {
        setKeyboardLevel(value * keyboardMax);
    }

    function cycleKeyboard() {
        setKeyboardLevel(keyboardLevel >= keyboardMax ? 0 : keyboardLevel + 1);
    }

    Process {
        id: readProcess

        command: ["sh", "-c", "brightnessctl -m -c backlight info; brightnessctl -m -d '*kbd_backlight*' info"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                for (const line of text.trim().split("\n")) {
                    const d = root.parseLine(line.trim());
                    if (!d)
                        continue;
                    if (d.cls === "backlight") {
                        root.screenDevice = d.name;
                        root.screenMax = d.max;
                        if (!screenWriter.busy)
                            root.screenRaw = d.current;
                    } else if (d.cls === "leds") {
                        root.keyboardDevice = d.name;
                        root.keyboardMax = d.max;
                        if (!keyboardWriter.busy)
                            root.keyboardLevel = d.current;
                    }
                }
            }
        }
    }

    Timer {
        interval: 2000
        repeat: true
        running: true
        onTriggered: root.refresh()
    }

    // Coalesces rapid writes (e.g. slider drags) into one brightnessctl call at a time.
    component Writer: Process {
        id: writer

        property var pending: null
        readonly property bool busy: running || pending !== null

        function queue(args) {
            pending = args;
            if (!running)
                flush();
        }

        function flush() {
            if (pending === null)
                return;
            command = ["brightnessctl", "-q", "-d", pending[0], "set", pending[1]];
            pending = null;
            running = true;
        }

        onExited: flush()
    }

    Writer {
        id: screenWriter
    }

    Writer {
        id: keyboardWriter
    }
}
