import "../../common"
import "../../state"
import QtQuick

// Nested navigation: overview -> cpu / gpu. Back on the overview leaves the page.
PageStack {
    signal backRequested()

    baseUrl: Qt.resolvedUrl("./")
    pages: PageRegistry.stats
    onExitRequested: backRequested()
}
