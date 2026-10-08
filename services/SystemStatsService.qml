pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ------------------------------------------------------------
    // Public state
    // ------------------------------------------------------------

    property real cpuUsage: 0
    property real cpuTemperature: 0
    property var cpuCores: []
    property string cpuModel: "CPU"

    property bool gpuAvailable: false
    property real gpuUsage: 0
    property real gpuTemperature: 0
    property var gpuProcesses: []
    property string gpuName: "GPU"

    property real memoryUsed: 0
    property real memoryTotal: 0
    property real memoryUsage: 0

    property var allDisks: []
    property var disks: []
    property var externalMountPoints: []
    property var externalDisks: []

    property var processes: []

    // ------------------------------------------------------------
    // CPU state
    // ------------------------------------------------------------

    property var previousCpu: null
    property var previousCores: ({})

    // ------------------------------------------------------------
    // Helpers
    // ------------------------------------------------------------

    function clamp(value, min, max) {
        return Math.max(min, Math.min(max, value))
    }

    function parseNumber(value, fallback) {
        const number = Number(value)

        return Number.isFinite(number)
            ? number
            : fallback
    }

    function parseBytes(value) {
        const number = Number(value)

        return Number.isFinite(number)
            ? number
            : 0
    }

    // ------------------------------------------------------------
    // CPU
    // ------------------------------------------------------------

    Process {
        id: cpuProcess

        command: [
            "sh",
            "-c",
            "cat /proc/stat && echo '__CPU_MODEL__' && lscpu 2>/dev/null | grep '^Model name:' | sed 's/^[^:]*:[[:space:]]*//' | head -n 1 && echo '__CPU_TEMP__' && for f in /sys/class/thermal/thermal_zone*/temp; do if [ -r \"$f\" ]; then cat \"$f\"; fi; done"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.updateCpu(text)
            }
        }
    }

    function updateCpu(output) {
        const lines = output.split("\n")

        let totalLine = null
        const coreLines = []

        let modelStart = -1
        let tempStart = -1

        for (let i = 0; i < lines.length; ++i) {
            const line = lines[i]

            if (line.startsWith("cpu ")) {
                totalLine = line
            } else if (/^cpu[0-9]+ /.test(line)) {
                coreLines.push(line)
            } else if (line === "__CPU_MODEL__") {
                modelStart = i
            } else if (line === "__CPU_TEMP__") {
                tempStart = i
            }
        }

        // CPU model
        if (modelStart >= 0) {
            for (let i = modelStart + 1; i < lines.length; ++i) {
                const value = lines[i].trim()

                if (value !== "" && value !== "__CPU_TEMP__") {
                    root.cpuModel = value
                    break
                }
            }
        }

        // CPU temperature
        if (tempStart >= 0) {
            let temperatures = []

            for (let i = tempStart + 1; i < lines.length; ++i) {
                const value = Number(lines[i].trim())

                if (Number.isFinite(value) && value > 0) {
                    temperatures.push(value / 1000)
                }
            }

            if (temperatures.length > 0) {
                root.cpuTemperature =
                    Math.max.apply(null, temperatures)
            }
        }

        // Total CPU usage
        if (totalLine) {
            const parts = totalLine.trim().split(/\s+/)

            if (parts.length >= 8) {
                const user = Number(parts[1])
                const nice = Number(parts[2])
                const system = Number(parts[3])
                const idle = Number(parts[4])
                const iowait = Number(parts[5])
                const irq = Number(parts[6])
                const softirq = Number(parts[7])
                const steal = parts.length > 8
                    ? Number(parts[8])
                    : 0

                const idleTime =
                    idle + iowait

                const totalTime =
                    user +
                    nice +
                    system +
                    idle +
                    iowait +
                    irq +
                    softirq +
                    steal

                if (root.previousCpu !== null) {
                    const previous =
                        root.previousCpu

                    const deltaTotal =
                        totalTime -
                        previous.total

                    const deltaIdle =
                        idleTime -
                        previous.idle

                    if (deltaTotal > 0) {
                        root.cpuUsage =
                            root.clamp(
                                100 *
                                (
                                    1 -
                                    deltaIdle /
                                    deltaTotal
                                ),
                                0,
                                100
                            )
                    }
                }

                root.previousCpu = {
                    total: totalTime,
                    idle: idleTime
                }
            }
        }

        // Per-core usage
        const newCoreValues = []

        for (const line of coreLines) {
            const parts = line.trim().split(/\s+/)

            if (parts.length < 5)
                continue

            const coreName = parts[0]

            const user = Number(parts[1])
            const nice = Number(parts[2])
            const system = Number(parts[3])
            const idle = Number(parts[4])
            const iowait = parts.length > 5
                ? Number(parts[5])
                : 0
            const irq = parts.length > 6
                ? Number(parts[6])
                : 0
            const softirq = parts.length > 7
                ? Number(parts[7])
                : 0
            const steal = parts.length > 8
                ? Number(parts[8])
                : 0

            const idleTime =
                idle + iowait

            const totalTime =
                user +
                nice +
                system +
                idle +
                iowait +
                irq +
                softirq +
                steal

            const previous =
                root.previousCores[coreName]

            let usage = 0

            if (previous) {
                const deltaTotal =
                    totalTime -
                    previous.total

                const deltaIdle =
                    idleTime -
                    previous.idle

                if (deltaTotal > 0) {
                    usage =
                        100 *
                        (
                            1 -
                            deltaIdle /
                            deltaTotal
                        )
                }
            }

            newCoreValues.push(
                root.clamp(
                    usage,
                    0,
                    100
                )
            )

            root.previousCores[coreName] = {
                total: totalTime,
                idle: idleTime
            }
        }

        root.cpuCores = newCoreValues
    }

    // ------------------------------------------------------------
    // GPU
    // ------------------------------------------------------------

    Process {
        id: gpuProcess

        command: [
            "nvidia-smi"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.updateGpu(text)
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                // NVIDIA may produce stderr output when unavailable.
                // Do not expose it as a UI error.
            }
        }
    }

    function updateGpu(output) {
        if (!output || output.trim() === "") {
            root.gpuAvailable = false
            root.gpuProcesses = []
            return
        }

        root.gpuAvailable = true

        const lines = output.split("\n")

        // --------------------------------------------------------
        // GPU information
        // --------------------------------------------------------

        for (const line of lines) {
            if (!line.includes("NVIDIA GeForce") &&
                !line.includes("NVIDIA RTX") &&
                !line.includes("NVIDIA")) {
                continue
            }

            const match =
                line.match(
                    /\|\s*\d+\s+(.+?)\s{2,}\|\s+[0-9A-Fa-f:]+\s+/
                )

            if (match) {
                root.gpuName =
                    match[1].trim()
                break
            }
        }

        // --------------------------------------------------------
        // Parse temperature / usage / memory
        // --------------------------------------------------------

        for (const line of lines) {
            if (!line.includes("C") ||
                !line.includes("%")) {
                continue
            }

            const gpuMatch =
                line.match(
                    /\|\s*\d+\s+(.+?)\s+\|\s+([0-9A-Fa-f:]+).*?\|\s+.*?\|\s+/
                )

            const usageMatch =
                line.match(
                    /\|\s+(\d+)%\s+/
                )

            const tempMatch =
                line.match(
                    /\|\s+N\/A\s+(\d+)C\s+/
                )

            if (usageMatch) {
                root.gpuUsage =
                    root.clamp(
                        Number(usageMatch[1]),
                        0,
                        100
                    )
            }

            if (tempMatch) {
                root.gpuTemperature =
                    Number(tempMatch[1])
            }

            if (gpuMatch) {
                root.gpuName =
                    gpuMatch[1].trim()
            }
        }

        // --------------------------------------------------------
        // GPU process table
        //
        // We intentionally parse the normal nvidia-smi output
        // instead of --query-compute-apps.
        //
        // This includes both:
        //   G = Graphics
        //   C = Compute
        // --------------------------------------------------------

        const gpuProcesses = []

        let inProcessTable = false

        for (const line of lines) {
            if (line.includes("Processes:")) {
                inProcessTable = true
                continue
            }

            if (!inProcessTable)
                continue

            const processMatch =
                line.match(
                    /^\|\s*\d+\s+\S+\s+\S+\s+(\d+)\s+([GC])\s+(.+?)\s+(\d+)MiB\s*\|/
                )

            if (!processMatch)
                continue

            const pid =
                Number(processMatch[1])

            const type =
                processMatch[2]

            const processName =
                processMatch[3].trim()

            const usedMemory =
                Number(processMatch[4])

            gpuProcesses.push({
                pid: pid,
                type: type,
                process_name: processName,
                used_memory: usedMemory
            })
        }

        root.gpuProcesses =
            gpuProcesses
    }

    // ------------------------------------------------------------
    // Memory
    // ------------------------------------------------------------

    Process {
        id: memoryProcess

        command: [
            "sh",
            "-c",
            "free -b | awk '/^Mem:/ { print $2, $3 }'"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const parts =
                    text.trim().split(/\s+/)

                if (parts.length < 2)
                    return

                root.memoryTotal =
                    root.parseBytes(parts[0])

                root.memoryUsed =
                    root.parseBytes(parts[1])

                if (root.memoryTotal > 0) {
                    root.memoryUsage =
                        root.clamp(
                            root.memoryUsed /
                            root.memoryTotal *
                            100,
                            0,
                            100
                        )
                }
            }
        }
    }

    // ------------------------------------------------------------
    // Internal storage
    // ------------------------------------------------------------

    Process {
        id: diskProcess

        command: [
            "sh",
            "-c",
            "df -B1 -P -x tmpfs -x devtmpfs -x squashfs 2>/dev/null"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.updateDisks(text)
            }
        }
    }

    function updateDisks(output) {
        const lines =
            output.split("\n")

        const result = []

        for (let i = 1; i < lines.length; ++i) {
            const line =
                lines[i].trim()

            if (line === "")
                continue

            const parts =
                line.split(/\s+/)

            if (parts.length < 6)
                continue

            const filesystem =
                parts[0]

            const total =
                root.parseBytes(parts[1])

            const used =
                root.parseBytes(parts[2])

            const usageString =
                parts[4]

            const mountPoint =
                parts.slice(5).join(" ")

            if (!mountPoint.startsWith("/"))
                continue

            const usage =
                Number(
                    usageString.replace("%", "")
                )

            result.push({
                filesystem: filesystem,
                mountPoint: mountPoint,
                used: used,
                total: total,
                usage: root.clamp(
                    usage,
                    0,
                    100
                )
            })
        }

        root.allDisks = result

        // Keep normal Linux filesystem mounts in Storage.
        root.disks =
            result.filter(disk =>
                disk.mountPoint === "/" ||
                disk.mountPoint.startsWith("/home") ||
                disk.mountPoint.startsWith("/var") ||
                disk.mountPoint.startsWith("/opt")
            )
    }

    // ------------------------------------------------------------
    // External storage
    // ------------------------------------------------------------

    Process {
        id: externalProcess

        command: [
            "lsblk",
            "-J",
            "-o",
            "NAME,PATH,SIZE,TYPE,FSTYPE,MOUNTPOINT,RM"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.updateExternalDisks(text)
            }
        }
    }

    function updateExternalDisks(output) {
        try {
            const data =
                JSON.parse(output)

            const result = []
            const mounts = []

            function walk(devices) {
                if (!devices)
                    return

                for (const device of devices) {
                    if (device.mountpoint)
                        mounts.push(device.mountpoint)

                    if (
                        device.type === "part" &&
                        device.mountpoint &&
                        device.rm === true
                    ) {
                        result.push({
                            name:
                                device.name || "External Disk",

                            filesystem:
                                device.fstype || "",

                            mountPoint:
                                device.mountpoint,

                            used: 0,
                            total:
                                root.parseLsblkSize(
                                    device.size
                                ),

                            usage: 0
                        })
                    }

                    if (device.children)
                        walk(device.children)
                }
            }

            walk(data.blockdevices)

            root.externalMountPoints =
                mounts

            root.externalDisks =
                result
        } catch (error) {
            root.externalMountPoints = []
            root.externalDisks = []
        }
    }

    function parseLsblkSize(value) {
        if (!value)
            return 0

        const match =
            String(value).match(
                /^([\d.]+)\s*([KMGTPE]?B)?$/i
            )

        if (!match)
            return 0

        const number =
            Number(match[1])

        const unit =
            (match[2] || "B").toUpperCase()

        const multipliers = {
            B: 1,
            KB: 1024,
            MB: 1024 * 1024,
            GB: 1024 * 1024 * 1024,
            TB: 1024 * 1024 * 1024 * 1024,
            PB: 1024 * 1024 * 1024 * 1024 * 1024,
            EB: 1024 * 1024 * 1024 * 1024 * 1024 * 1024
        }

        return number *
            (multipliers[unit] || 1)
    }

    // ------------------------------------------------------------
    // Top processes
    // ------------------------------------------------------------

    Process {
        id: processesProcess

        command: [
            "sh",
            "-c",
            "ps -eo pid=,user=,pcpu=,pmem=,rss=,etime=,comm=,args= --sort=-pcpu | head -n 16"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.updateProcesses(text)
            }
        }
    }

    function updateProcesses(output) {
        const lines =
            output.split("\n")

        const result = []

        for (const line of lines) {
            if (line.trim() === "")
                continue

            const match =
                line.match(
                    /^\s*(\d+)\s+(\S+)\s+([\d.]+)\s+([\d.]+)\s+(\d+)\s+(\S+)\s+(\S+)\s+(.*)$/
                )

            if (!match)
                continue

            result.push({
                pid:
                    Number(match[1]),

                user:
                    match[2],

                cpu:
                    Number(match[3]),

                memory:
                    Number(match[4]),

                rssKb:
                    Number(match[5]),

                elapsed:
                    match[6],

                command:
                    match[7],

                args:
                    match[8]
            })
        }

        root.processes =
            result
    }

    // ------------------------------------------------------------
    // Refresh loop
    // ------------------------------------------------------------

    Timer {
        id: refreshTimer

        interval: 1000

        running: true
        repeat: true

        onTriggered: {
            cpuProcess.running = true
            gpuProcess.running = true
            memoryProcess.running = true
            diskProcess.running = true
            externalProcess.running = true
            processesProcess.running = true
        }
    }
}