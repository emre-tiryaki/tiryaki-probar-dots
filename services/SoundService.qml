pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property var sink:
        Pipewire.defaultAudioSink

    readonly property var source:
        Pipewire.defaultAudioSource

    readonly property bool ready:
        Pipewire.ready &&
        sink !== null &&
        sink.ready

    readonly property bool sourceReady:
        Pipewire.ready &&
        source !== null &&
        source.ready

    // Volume boost: allows raising volumes up to 200%.
    property alias boostEnabled: persist.boostEnabled

    readonly property real maxVolume:
        boostEnabled ? 2 : 1

    PersistentProperties {
        id: persist

        reloadableId: "soundServiceBoost"

        property bool boostEnabled: false
    }

    function setBoostEnabled(enabled) {
        persist.boostEnabled = enabled
        if (enabled)
            return

        // Pull anything above 100% back down when the boost is turned off.
        const nodes = [root.sink, ...root.outputDevices, ...root.applicationStreams]
        for (const node of nodes) {
            if (node && node.ready && node.audio && node.audio.volume > 1)
                node.audio.volume = 1
        }
    }

    function toggleBoost() {
        setBoostEnabled(!boostEnabled)
    }

    readonly property real volume:
        ready ? sink.audio.volume : 0

    readonly property bool muted:
        ready ? sink.audio.muted : false

    readonly property real microphoneVolume:
        sourceReady
            ? source.audio.volume
            : 0

    readonly property bool microphoneMuted:
        sourceReady
            ? source.audio.muted
            : false

    readonly property var outputDevices:
        Pipewire.nodes.values.filter(node =>
            node.audio !== null &&
            !node.isStream &&
            node.isSink
        )

    readonly property var inputDevices:
        Pipewire.nodes.values.filter(node =>
            node.audio !== null &&
            !node.isStream &&
            !node.isSink
        )

    readonly property var applicationStreams:
        Pipewire.nodes.values.filter(node =>
            node.audio !== null &&
            node.isStream &&
            node.isSink
        )

    PwObjectTracker {
        objects: {
            var nodes = []

            if (root.sink)
                nodes.push(root.sink)

            if (root.source)
                nodes.push(root.source)

            for (const node of root.outputDevices)
                nodes.push(node)

            for (const node of root.inputDevices)
                nodes.push(node)

            for (const node of root.applicationStreams)
                nodes.push(node)

            return nodes
        }
    }

    function clamp(value, max) {
        return Math.max(
            0,
            Math.min(max === undefined ? 1 : max, value)
        )
    }

    function setVolume(value) {
        if (!ready)
            return

        sink.audio.volume =
            clamp(value, maxVolume)
    }

    function changeVolume(delta) {
        setVolume(volume + delta)
    }

    function toggleMute() {
        if (!ready)
            return

        sink.audio.muted =
            !sink.audio.muted
    }

    function setMicrophoneVolume(value) {
        if (!sourceReady)
            return

        source.audio.volume =
            clamp(value)
    }

    function changeMicrophoneVolume(delta) {
        setMicrophoneVolume(
            microphoneVolume + delta
        )
    }

    function toggleMicrophoneMute() {
        if (!sourceReady)
            return

        source.audio.muted =
            !source.audio.muted
    }

    function setNodeVolume(node, value) {
        if (
            !node ||
            !node.ready ||
            !node.audio
        )
            return

        node.audio.volume =
            clamp(value, node.isSink ? maxVolume : 1)
    }

    function toggleNodeMute(node) {
        if (
            !node ||
            !node.ready ||
            !node.audio
        )
            return

        node.audio.muted =
            !node.audio.muted
    }

    function setDefaultOutput(node) {
        if (!node)
            return

        Pipewire.preferredDefaultAudioSink =
            node
    }

    function setDefaultInput(node) {
        if (!node)
            return

        Pipewire.preferredDefaultAudioSource =
            node
    }
}