import "../../common"
import "../../services"
import QtQuick
import Quickshell

Item {
    id: root

    property string query: ""
    readonly property var results: {
        const q = query.trim().toLowerCase();
        if (q === "")
            return [];

        const scored = [];
        for (const e of DesktopEntries.applications.values) {
            const name = e.name.toLowerCase();
            const meta = ((e.genericName || "") + " " + (e.comment || "")).toLowerCase();
            let s = 0;
            if (name.startsWith(q))
                s = 3;
            else if (name.includes(q))
                s = 2;
            else if (meta.includes(q))
                s = 1;
            if (s > 0)
                scored.push({
                "entry": e,
                "score": s
            });

        }
        scored.sort((a, b) => {
            return b.score - a.score || a.entry.name.localeCompare(b.entry.name);
        });
        return scored.slice(0, 20).map((x) => {
            return x.entry;
        });
    }

    function launch(entry) {
        entry.execute();
        LauncherService.active = false;
    }

    implicitWidth: 560
    implicitHeight: column.implicitHeight + 24

    Column {
        id: column

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 8

        Item {
            width: parent.width
            height: 32

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: input.text === ""
                text: "Uygulama ara..."
                color: ThemeColors.text
                opacity: 0.5
                font.pixelSize: 15
            }

            TextInput {
                id: input

                anchors.fill: parent
                verticalAlignment: TextInput.AlignVCenter
                color: ThemeColors.text
                font.pixelSize: 15
                focus: true
                onTextChanged: {
                    root.query = text;
                    list.currentIndex = 0;
                }
                Keys.onEscapePressed: LauncherService.active = false
                Keys.onDownPressed: list.incrementCurrentIndex()
                Keys.onUpPressed: list.decrementCurrentIndex()
                Keys.onReturnPressed: {
                    if (root.results.length > 0)
                        root.launch(root.results[list.currentIndex]);

                }
                onVisibleChanged: {
                    if (visible) {
                        forceActiveFocus();
                    }
                }
                Component.onCompleted: Qt.callLater(forceActiveFocus)
            }

        }

        ListView {
            id: list

            width: parent.width
            height: Math.min(count, 6) * 44
            visible: count > 0
            clip: true
            currentIndex: 0

            model: ScriptModel {
                values: root.results
            }

            delegate: Rectangle {
                required property var modelData

                width: list.width
                height: 44
                radius: 10
                color: ListView.isCurrentItem ? ThemeColors.surfaceHover : "transparent"

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    spacing: 10

                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 28
                        height: 28
                        sourceSize: Qt.size(28, 28)
                        source: Quickshell.iconPath(modelData.icon, "application-x-executable")
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.name
                        color: ThemeColors.text
                        font.pixelSize: 13
                    }

                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.launch(modelData)
                }

            }

        }

    }

}
