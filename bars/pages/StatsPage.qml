import "../../common"
import "../../state"
import QtQuick

// Nested navigation: overview -> cpu / gpu. Back on the overview leaves the page.
PageStack {
    signal backRequested()

    dir: "bars/pages/"
    pages: PageRegistry.stats
    onExitRequested: backRequested()
}
