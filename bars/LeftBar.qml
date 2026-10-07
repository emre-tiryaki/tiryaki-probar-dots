import QtQuick

import "../common"
import "../modules"

Rectangle {
    id: root

    width: workspaceMod.width + 28
    height: 35

    color: ThemeColors.background

    topLeftRadius: 0
    topRightRadius: 0
    bottomLeftRadius: 0
    bottomRightRadius: height / 2

    WorkspaceModule {
        id: workspaceMod

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 14
        }
    }
}