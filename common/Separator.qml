import QtQuick

// Horizontal by default; set vertical: true for a 16px vertical divider.
Rectangle {
    property bool vertical: false

    width: vertical ? 1 : (parent ? parent.width : 0)
    height: vertical ? 16 : 1
    color: ThemeColors.border
    opacity: vertical ? 1 : 0.6
}
