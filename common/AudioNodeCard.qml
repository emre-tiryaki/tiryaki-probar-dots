import "../services"
import QtQuick

// VolumeCard bound to a PipeWire node.
VolumeCard {
    required property var node

    maxValue: node.isSink ? SoundService.maxVolume : 1
    value: node.audio ? node.audio.volume : 0
    muted: node.audio ? node.audio.muted : false
    onMoved: v => SoundService.setNodeVolume(node, v)
}
