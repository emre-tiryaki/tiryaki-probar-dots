pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

QtObject {
    id: root

    function colorOr(value, fallback) {
        return typeof value === "string" && value.length > 0 ? value : fallback;
    }

    function numberOr(value, fallback) {
        return typeof value === "number" && !Number.isNaN(value) ? value : fallback;
    }

    property FileView colorsFile: FileView {
        path: Quickshell.env("HOME") + "/.config/probar/common/theme-colors.json"
        watchChanges: true

        onFileChanged: reload()

        ColorsAdapter {}
    }

    component ColorsAdapter: JsonAdapter {
        property string background
        property string surface
        property string surfaceVariant
        property string surfaceHover

        property string primary
        property string secondary
        property string accent

        property string text
        property string textMuted
        property string textDisabled

        property string border

        property string success
        property string warning
        property string error

        property string shadow
        property string pill

        property string workspace
        property string workspaceInactive
        property string workspaceActive

        property string networkActive
        property string networkDisconnected
        property string soundActive
        property string soundMuted
        property string bluetoothActive
        property string bluetoothDisabled
        property string batteryCharging
        property string batteryLow
        property string batteryNormal

        property real surfaceOpacity
        property real borderOpacity
    }

    property color background: colorOr(colorsFile.adapter && colorsFile.adapter.background, "#1e1e2e")
    property color surface: colorOr(colorsFile.adapter && colorsFile.adapter.surface, "#313244")
    property color surfaceVariant: colorOr(colorsFile.adapter && colorsFile.adapter.surfaceVariant, "#45475a")
    property color surfaceHover: colorOr(colorsFile.adapter && colorsFile.adapter.surfaceHover, surfaceVariant)

    property color primary: colorOr(colorsFile.adapter && colorsFile.adapter.primary, "#cba6f7")
    property color secondary: colorOr(colorsFile.adapter && colorsFile.adapter.secondary, "#a6adc8")
    property color accent: colorOr(colorsFile.adapter && colorsFile.adapter.accent, "#cba6f7")

    property color text: colorOr(colorsFile.adapter && colorsFile.adapter.text, "#cdd6f4")
    property color textMuted: colorOr(colorsFile.adapter && colorsFile.adapter.textMuted, "#a6adc8")
    property color textDisabled: colorOr(colorsFile.adapter && colorsFile.adapter.textDisabled, "#6c7086")

    property color border: colorOr(colorsFile.adapter && colorsFile.adapter.border, "#45475a")

    property color success: colorOr(colorsFile.adapter && colorsFile.adapter.success, accent)
    property color warning: colorOr(colorsFile.adapter && colorsFile.adapter.warning, secondary)
    property color error: colorOr(colorsFile.adapter && colorsFile.adapter.error, "#f38ba8")
    property color shadow: colorOr(colorsFile.adapter && colorsFile.adapter.shadow, "#000000")
    property color pill: colorOr(colorsFile.adapter && colorsFile.adapter.pill, background)

    property color workspace: colorOr(colorsFile.adapter && colorsFile.adapter.workspace, textDisabled)
    property color workspaceInactive: colorOr(colorsFile.adapter && colorsFile.adapter.workspaceInactive, workspace)
    property color workspaceActive: colorOr(colorsFile.adapter && colorsFile.adapter.workspaceActive, primary)

    property color networkActive: colorOr(colorsFile.adapter && colorsFile.adapter.networkActive, primary)
    property color networkDisconnected: colorOr(colorsFile.adapter && colorsFile.adapter.networkDisconnected, textDisabled)
    property color soundActive: colorOr(colorsFile.adapter && colorsFile.adapter.soundActive, primary)
    property color soundMuted: colorOr(colorsFile.adapter && colorsFile.adapter.soundMuted, textDisabled)
    property color bluetoothActive: colorOr(colorsFile.adapter && colorsFile.adapter.bluetoothActive, primary)
    property color bluetoothDisabled: colorOr(colorsFile.adapter && colorsFile.adapter.bluetoothDisabled, textDisabled)
    property color batteryCharging: colorOr(colorsFile.adapter && colorsFile.adapter.batteryCharging, accent)
    property color batteryLow: colorOr(colorsFile.adapter && colorsFile.adapter.batteryLow, error)
    property color batteryNormal: colorOr(colorsFile.adapter && colorsFile.adapter.batteryNormal, primary)

    property real surfaceOpacity: numberOr(colorsFile.adapter && colorsFile.adapter.surfaceOpacity, 0.92)
    property real borderOpacity: numberOr(colorsFile.adapter && colorsFile.adapter.borderOpacity, 0.55)
}
