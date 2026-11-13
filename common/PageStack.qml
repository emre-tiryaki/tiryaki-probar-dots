import QtQuick

// Loads one page at a time from a registry list: [{ id, file }, ...].
// A page can declare `signal backRequested()` and/or `signal openPage(string id)`;
// both are wired automatically. Back on the home page emits exitRequested().
Loader {
    id: root

    property var pages: []
    property url baseUrl
    property string home: pages.length > 0 ? pages[0].id : ""
    property string current: home

    signal exitRequested()

    function entry(id) {
        return pages.find(p => p.id === id);
    }

    function open(id) {
        current = entry(id) ? id : home;
    }

    function back() {
        if (current === home)
            exitRequested();
        else
            current = home;
    }

    source: {
        const page = entry(current);
        return page ? baseUrl + page.file : "";
    }

    Connections {
        target: root.item
        ignoreUnknownSignals: true

        function onBackRequested() {
            root.back();
        }

        function onOpenPage(id) {
            root.open(id);
        }
    }
}
