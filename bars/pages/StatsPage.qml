import QtQuick

import "../../common"
import "../../services"

Item {
    id: root

    property string page: "overview"

    implicitWidth:
        pageLoader.item
            ? pageLoader.item.implicitWidth
            : 540

    implicitHeight:
        pageLoader.item
            ? pageLoader.item.implicitHeight
            : 470

    Loader {
        id: pageLoader

        sourceComponent: {
            switch (root.page) {
            case "cpu":
                return cpuPage

            case "gpu":
                return gpuPage

            default:
                return overviewPage
            }
        }
    }

    function openCpu() {
        page = "cpu"
    }

    function openGpu() {
        page = "gpu"
    }

    function goBack() {
        page = "overview"
    }

    Component {
        id: overviewPage

        StatsOverview {
            onBackRequested:
                root.goBack()

            onCpuClicked:
                root.openCpu()

            onGpuClicked:
                root.openGpu()
        }
    }

    Component {
        id: cpuPage

        CpuStatsPage {
            onBackRequested:
                root.goBack()
        }
    }

    Component {
        id: gpuPage

        GpuStatsPage {
            onBackRequested:
                root.goBack()
        }
    }
}