import "../../common"
import "../../services"
import "../../state"
import Qt.labs.folderlistmodel
import QtQuick
import QtQuick.Effects

Item {
    id: root

    property url current: ""
    property real maxHeight: 400
    property real fallbackHeight: 176
    readonly property bool hasFiles: files.status === FolderListModel.Ready && files.count > 0
    property real naturalWidth: 0
    property real naturalHeight: 0
    readonly property bool imageReady: naturalWidth > 0 && naturalHeight > 0
    // Declarative so it never reads a stale imageReady inside a change handler.
    readonly property real cardHeight: imageReady && width > 0 ? width * naturalHeight / naturalWidth : fallbackHeight

    function pick() {
        if (!hasFiles) {
            current = "";
            return ;
        }

        const urls = [];
        for (let i = 0; i < files.count; i++)
            urls.push(files.get(i, "fileUrl"));

        const pool = urls.length > 1 ? urls.filter(u => u.toString() !== current.toString()) : urls;
        current = pool[Math.floor(Math.random() * pool.length)];
    }

    visible: !MediaService.hasPlayer && hasFiles
    implicitHeight: visible ? Math.min(maxHeight, cardHeight) : 0
    height: implicitHeight
    onHasFilesChanged: pick()
    Component.onCompleted: pick()

    FolderListModel {
        id: files

        folder: Qt.resolvedUrl("../../assets/mediaControlCenterIdleAnimations")
        nameFilters: ["*.webp"]
        caseSensitive: false
        showDirs: false
    }

    Connections {
        target: BarState

        function onCenterExpandedChanged() {
            if (BarState.centerExpanded)
                root.pick();
        }
    }

    Rectangle {
        id: frame

        anchors.fill: parent
        radius: 20
        color: ThemeColors.surface

        Rectangle {
            id: mask

            anchors.fill: parent
            radius: frame.radius
            visible: false
            layer.enabled: true
        }

        AnimatedImage {
            id: anim

            anchors.fill: parent
            source: root.current
            fillMode: root.cardHeight > root.maxHeight ? Image.PreserveAspectFit : Image.PreserveAspectCrop
            asynchronous: true
            cache: false
            playing: root.visible && BarState.centerExpanded
            layer.enabled: true

            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: mask
            }

            // A freshly created page (e.g. returning via back) can reach Ready
            // before the implicit size is known, so track size changes too.
            function syncNaturalSize() {
                if (status !== Image.Ready || implicitWidth <= 0 || implicitHeight <= 0)
                    return ;

                if (root.naturalWidth !== implicitWidth)
                    root.naturalWidth = implicitWidth;

                if (root.naturalHeight !== implicitHeight)
                    root.naturalHeight = implicitHeight;
            }

            onStatusChanged: syncNaturalSize()
            onImplicitWidthChanged: syncNaturalSize()
            onImplicitHeightChanged: syncNaturalSize()
        }
    }

}