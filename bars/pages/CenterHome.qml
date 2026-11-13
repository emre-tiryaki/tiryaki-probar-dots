import "../../common"
import "../../state"
import QtQuick
import "."

// Home grid; cards come from PageRegistry.center entries that have a title.
Item {
    id: root

    readonly property var cards: PageRegistry.center.filter(p => p.title)
    readonly property int perRow: 4

    signal openPage(string id)

    implicitWidth: rows.implicitWidth + 32
    implicitHeight: rows.implicitHeight + 32

    Column {
        id: rows

        anchors.centerIn: parent
        spacing: 10

        Repeater {
            model: Math.ceil(root.cards.length / root.perRow)

            Row {
                required property int index

                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                Repeater {
                    model: root.cards.slice(index * root.perRow, (index + 1) * root.perRow)

                    CenterModuleCard {
                        required property var modelData

                        title: modelData.title
                        description: modelData.description || ""
                        icon: modelData.icon || ""
                        onClicked: root.openPage(modelData.id)
                    }
                }
            }
        }

        MediaControl {
            width: parent.width
        }

        MediaIdle {
            width: parent.width
        }
    }
}
