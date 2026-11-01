import QtQuick

Item {
    id: root

    property url source
    property color fallback: "#89b4fa"
    property color extractedColor: fallback
    property bool extracted: false
    property string loadedUrl: ""

    property color dominant: extracted ? extractedColor : fallback

    readonly property real hue: Math.max(0, dominant.hslHue)
    readonly property real sat: dominant.hslSaturation < 0.12 ? 0 : dominant.hslSaturation

    readonly property color background: Qt.hsla(hue, Math.min(sat, 0.55), 0.10, 1)
    readonly property color surface: Qt.hsla(hue, Math.min(sat, 0.5), 0.2, 1)
    readonly property color track: Qt.hsla(hue, Math.min(sat, 0.4), 0.27, 1)
    readonly property color accent: Qt.hsla(hue, sat === 0 ? 0 : Math.max(0.5, Math.min(sat, 0.9)), 0.7, 1)
    readonly property color text: Qt.hsla(hue, Math.min(sat, 0.35), 0.95, 1)
    readonly property color textMuted: Qt.hsla(hue, Math.min(sat, 0.3), 0.72, 1)
    readonly property color onAccent: Qt.hsla(hue, Math.min(sat, 0.6), 0.1, 1)

    function refresh() {
        const url = source.toString();

        if (loadedUrl !== "" && loadedUrl !== url)
            canvas.unloadImage(loadedUrl);

        loadedUrl = url;

        if (url === "") {
            extracted = false;
            return ;
        }

        canvas.loadImage(url);
        if (canvas.isImageLoaded(url))
            canvas.requestPaint();
    }

    function analyze(data) {
        const bins = Array.from({ length: 12 }, () => ({ w: 0, r: 0, g: 0, b: 0 }));

        for (let i = 0; i < data.length; i += 4) {
            if (data[i + 3] < 128)
                continue;

            const r = data[i] / 255;
            const g = data[i + 1] / 255;
            const b = data[i + 2] / 255;
            const max = Math.max(r, g, b);
            const min = Math.min(r, g, b);
            const l = (max + min) / 2;

            if (l < 0.1 || l > 0.93)
                continue;

            const d = max - min;
            const s = d === 0 ? 0 : d / (1 - Math.abs(2 * l - 1));
            let h = 0;
            if (d > 0)
                h = max === r ? ((g - b) / d + 6) % 6 : max === g ? (b - r) / d + 2 : (r - g) / d + 4;

            const bin = bins[Math.min(11, Math.floor(h * 2))];
            const w = 0.02 + s * s * (1 - Math.abs(2 * l - 1) * 0.6);
            bin.w += w;
            bin.r += r * w;
            bin.g += g * w;
            bin.b += b * w;
        }

        const best = bins.reduce((a, c) => c.w > a.w ? c : a);
        if (best.w === 0) {
            extracted = false;
            return ;
        }

        extractedColor = Qt.rgba(best.r / best.w, best.g / best.w, best.b / best.w, 1);
        extracted = true;
    }

    onSourceChanged: refresh()
    Component.onCompleted: refresh()

    Canvas {
        id: canvas

        width: 32
        height: 32
        opacity: 0
        renderTarget: Canvas.Image
        renderStrategy: Canvas.Cooperative
        onImageLoaded: requestPaint()
        onPaint: {
            const url = root.source.toString();
            if (url === "" || !isImageLoaded(url))
                return ;

            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.drawImage(url, 0, 0, width, height);
            root.analyze(ctx.getImageData(0, 0, width, height).data);
        }
    }

    Behavior on dominant {
        ColorAnimation {
            duration: 500
        }
    }
}