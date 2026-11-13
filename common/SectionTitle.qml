import QtQuick

Text {
    property bool muted: false

    color: muted ? ThemeColors.textMuted : ThemeColors.text
    font.pixelSize: muted ? 11 : 13
    font.weight: Font.DemiBold
}
