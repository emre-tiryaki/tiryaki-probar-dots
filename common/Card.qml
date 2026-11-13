import QtQuick

// Rounded surface that reacts to hover and emits clicked().
// Set interactive: false for a static card. Override color / border.color as needed.
Rectangle {
    id: card

    property bool interactive: true
    property real hoverScale: 1.02
    readonly property bool hovered: interactive && hover.hovered
    readonly property bool pressed: interactive && tap.pressed

    signal clicked()

    radius: 16
    color: hovered ? ThemeColors.surfaceHover : ThemeColors.surface
    border.width: 1
    border.color: hovered ? ThemeColors.accent : ThemeColors.border
    scale: pressed ? 0.98 : hovered ? hoverScale : 1

    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }
    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

    HoverHandler {
        id: hover

        enabled: card.interactive
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        id: tap

        enabled: card.interactive
        onTapped: card.clicked()
    }
}
