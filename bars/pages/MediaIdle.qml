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
    property real cardHeight: fallbackHeight

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

    function updateHeight() {
        cardHeight = imageReady && width > 0 ? width * naturalHeight / naturalWidth : fallbackHeight;

        const mode = cardHeight > maxHeight ? Image.PreserveAspectFit : Image.PreserveAspectCrop;
        if (anim.fillMode !== mode)
            anim.fillMode = mode;
    }

    visible: !MediaService.hasPlayer && hasFiles
    implicitHeight: visible ? Math.min(maxHeight, cardHeight) : 0
    height: implicitHeight
    onHasFilesChanged: pick()
    onWidthChanged: updateHeight()
    onNaturalWidthChanged: updateHeight()
    onNaturalHeightChanged: updateHeight()
    Component.onCompleted: {
        updateHeight();
        pick();
    }

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
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
            playing: root.visible && BarState.centerExpanded
            layer.enabled: true

            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: mask
            }

            onStatusChanged: {
                if (status !== Image.Ready || implicitWidth <= 0)
                    return ;

                if (root.naturalWidth !== implicitWidth)
                    root.naturalWidth = implicitWidth;

                if (root.naturalHeight !== implicitHeight)
                    root.naturalHeight = implicitHeight;
            }
        }
    }
}