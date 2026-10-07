import QtQuick

import "../common"
import "../modules"

Rectangle {
    id: root

    width: 190
    height: 35

    color: ThemeColors.background

    topLeftRadius: 0
    topRightRadius: 0
    bottomLeftRadius: 0
    bottomRightRadius: height / 2

    WorkspaceModule {
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 10
        }
    }
}