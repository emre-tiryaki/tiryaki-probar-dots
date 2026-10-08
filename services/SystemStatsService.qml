import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    // ------------------------------------------------------------
    // CPU
    // ------------------------------------------------------------
    // ------------------------------------------------------------
    // GPU
    // ------------------------------------------------------------
    // ------------------------------------------------------------
    // RAM
    // ------------------------------------------------------------
    // ------------------------------------------------------------
    // CPU Processes
    // ------------------------------------------------------------
    // ------------------------------------------------------------
    // Storage
    // ------------------------------------------------------------
    // ------------------------------------------------------------
    // Update timer
    // ------------------------------------------------------------

    id: root

    // CPU
    property real cpuUsage: 0
    property real cpuTemperature: 0
    property var cpuCores: []
    property string cpuModel: "CPU"
    // GPU
    property bool gpuAvailable: false
    property real gpuUsage: 0
    property real gpuTemperature: 0
    property var gpuProcesses: []
    property string gpuName: "GPU"
    // Memory
    property real memoryUsed: 0
    property real memoryTotal: 0
    property real memoryUsage: 0
    // Storage
    property var allDisks: []
    property var disks: []
    property var externalMountPoints: []
    property var externalDisks: []
    // Processes
    property var processes: []
    // CPU sampling state
    property var previousCpu: null
    property var previousCores: ({
    })

    function clamp(value, minValue, maxValue) {
        return Math.max(minValue, Math.min(maxValue, value));
    }

    function updateStats() {
        cpuProcess.running = true;
        temperatureProcess.running = true;
        cpuModelProcess.running = true;
        memoryProcess.running = true;
        diskProcess.running = true;
        externalDiskProcess.running = true;
        processListProcess.running = true;
        if (gpuAvailable) {
            gpuInfoProcess.running = true;
            gpuProcessListProcess.running = true;
        } else {
            detectGpuProcess.running = true;
        }
    }

    function parseCpu(data) {
        const lines = data.trim().split("\n");
        if (lines.length === 0)
            return ;

        let totalCpu = null;
        const cores = [];
        for (const line of lines) {
            const parts = line.trim().split(/\s+/);
            if (parts.length < 5)
                continue;

            const name = parts[0];
            if (name !== "cpu" && !/^cpu[0-9]+$/.test(name))
                continue;

            const values = [];
            for (let i = 1; i < parts.length; i++) {
                const value = Number(parts[i]);
                values.push(isNaN(value) ? 0 : value);
            }
            if (values.length < 4)
                continue;

            const user = values[0];
            const nice = values[1];
            const system = values[2];
            const idle = values[3];
            const iowait = values.length > 4 ? values[4] : 0;
            const irq = values.length > 5 ? values[5] : 0;
            const softirq = values.length > 6 ? values[6] : 0;
            const steal = values.length > 7 ? values[7] : 0;
            const total = user + nice + system + idle + iowait + irq + softirq + steal;
            const idleTotal = idle + iowait;
            const current = {
                "total": total,
                "idle": idleTotal
            };
            if (name === "cpu") {
                totalCpu = current;
                if (previousCpu !== null) {
                    const totalDelta = current.total - previousCpu.total;
                    const idleDelta = current.idle - previousCpu.idle;
                    if (totalDelta > 0) {
                        const usage = (1 - idleDelta / totalDelta) * 100;
                        cpuUsage = clamp(usage, 0, 100);
                    }
                }
                previousCpu = current;
            } else {
                const index = Number(name.substring(3));
                const previous = previousCores[index];
                let usage = 0;
                if (previous) {
                    const totalDelta = current.total - previous.total;
                    const idleDelta = current.idle - previous.idle;
                    if (totalDelta > 0)
                        usage = (1 - idleDelta / totalDelta) * 100;

                }
                previousCores[index] = current;
                cores.push({
                    "index": index,
                    "usage": clamp(usage, 0, 100)
                });
            }
        }
        if (totalCpu !== null)
            cpuUsage = clamp(cpuUsage, 0, 100);

        cores.sort(function(a, b) {
            return a.index - b.index;
        });
        cpuCores = cores;
    }

    function parseCpuTemperature(data) {
        const value = Number(data.trim());
        if (!isNaN(value) && value > 0)
            cpuTemperature = value;

    }

    function parseCpuModel(data) {
        const value = data.trim();
        if (value !== "")
            cpuModel = value;

    }

    function parseGpuInfo(data) {
        const line = data.trim();
        if (line === "")
            return ;

        const parts = line.split(",");
        if (parts.length < 3)
            return ;

        gpuName = parts[0].trim();
        gpuUsage = clamp(Number(parts[1]), 0, 100);
        gpuTemperature = Number(parts[2]);
    }

    function parseGpuProcesses(data) {
        const result = [];
        const lines = data.trim().split("\n");
        for (const line of lines) {
            const parts = line.split(",");
            if (parts.length < 3)
                continue;

            const pid = Number(parts[0].trim());
            const name = parts[1].trim();
            const memory = Number(parts[2].trim());
            if (isNaN(pid))
                continue;

            result.push({
                "pid": pid,
                "name": name,
                "memory": isNaN(memory) ? 0 : memory
            });
        }
        gpuProcesses = result;
    }

    function parseMemory(data) {
        const lines = data.trim().split("\n");
        if (lines.length < 2)
            return ;

        const total = Number(lines[0].split(/\s+/)[1]);
        const available = Number(lines[1].split(/\s+/)[1]);
        if (!total)
            return ;

        const used = total - available;
        memoryTotal = total / 1024 / 1024;
        memoryUsed = used / 1024 / 1024;
        memoryUsage = clamp(used / total * 100, 0, 100);
    }

    function parseProcesses(data) {
        const result = [];
        const lines = data.trim().split("\n");
        for (const line of lines) {
            const parts = line.trim().split(/\s+/);
            // pid user cpu memory rss elapsed command args...
            if (parts.length < 8)
                continue;

            const pid = Number(parts[0]);
            const user = parts[1];
            const cpu = Number(parts[2]);
            const memory = Number(parts[3]);
            const rssKb = Number(parts[4]);
            const elapsed = parts[5];
            const command = parts[6];
            const args = parts.slice(7).join(" ");
            if (isNaN(pid))
                continue;

            result.push({
                "pid": pid,
                "user": user,
                "cpu": isNaN(cpu) ? 0 : cpu,
                "memory": isNaN(memory) ? 0 : memory,
                "rssKb": isNaN(rssKb) ? 0 : rssKb,
                "elapsed": elapsed,
                "command": command,
                "args": args
            });
        }
        processes = result;
    }

    function parseDisks(data) {
        const result = [];
        const lines = data.trim().split("\n");
        for (let i = 1; i < lines.length; i++) {
            const line = lines[i].trim();
            if (!line)
                continue;

            const parts = line.split(/\s+/);
            if (parts.length < 6)
                continue;

            const filesystem = parts[0];
            const total = Number(parts[1]);
            const used = Number(parts[2]);
            const mountPoint = parts[5];
            if (!total)
                continue;

            result.push({
                "filesystem": filesystem,
                "mountPoint": mountPoint,
                "total": total,
                "used": used,
                "usage": used / total * 100
            });
        }
        allDisks = result;
        rebuildDiskLists();
    }

    function parseExternalMounts(data) {
        function walk(nodes) {
            if (!nodes)
                return ;

            for (const node of nodes) {
                if (node.RM === "1" && node.MOUNTPOINT && node.MOUNTPOINT !== "")
                    mounts.push(node.MOUNTPOINT);

                if (node.children)
                    walk(node.children);

            }
        }

        const mounts = [];
        try {
            const json = JSON.parse(data);
            walk(json.blockdevices);
        } catch (error) {
            externalMountPoints = [];
            externalDisks = [];
            rebuildDiskLists();
            return ;
        }
        externalMountPoints = mounts;
        rebuildDiskLists();
    }

    function rebuildDiskLists() {
        const internal = [];
        const external = [];
        for (const disk of allDisks) {
            const isExternal = externalMountPoints.indexOf(disk.mountPoint) !== -1;
            if (isExternal)
                external.push(disk);
            else
                internal.push(disk);
        }
        disks = internal;
        externalDisks = external;
    }

    Component.onCompleted: {
        root.updateStats();
    }

    Process {
        id: cpuProcess

        command: ["sh", "-c", "grep -E '^cpu([0-9]+)? ' /proc/stat"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.parseCpu(this.text);
            }
        }

    }

    Process {
        id: cpuModelProcess

        command: ["sh", "-c", "lscpu | sed -n 's/^Model name:[[:space:]]*//p' | head -n 1"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.parseCpuModel(this.text);
            }
        }

    }

    Process {
        id: temperatureProcess

        command: ["sh", "-c", "for f in /sys/class/thermal/thermal_zone*/temp; do " + "[ -f \"$f\" ] || continue; " + "v=$(cat \"$f\" 2>/dev/null); " + "[ \"$v\" -gt 0 ] 2>/dev/null || continue; " + "echo \"$v\"; " + "done | sort -nr | head -n 1 | " + "awk '{printf \"%.1f\\n\", $1/1000}'"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.parseCpuTemperature(this.text);
            }
        }

    }

    Process {
        id: detectGpuProcess

        command: ["sh", "-c", "command -v nvidia-smi >/dev/null 2>&1 && echo NVIDIA"]

        stdout: StdioCollector {
            onStreamFinished: {
                const detected = this.text.trim() === "NVIDIA";
                if (detected) {
                    gpuAvailable = true;
                    gpuInfoProcess.running = true;
                    gpuProcessListProcess.running = true;
                }
            }
        }

    }

    Process {
        id: gpuInfoProcess

        command: ["nvidia-smi", "--query-gpu=name,utilization.gpu,temperature.gpu", "--format=csv,noheader,nounits"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.parseGpuInfo(this.text);
            }
        }

    }

    Process {
        id: gpuProcessListProcess

        command: ["nvidia-smi", "--query-compute-apps=pid,process_name,used_memory", "--format=csv,noheader,nounits"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.parseGpuProcesses(this.text);
            }
        }

    }

    Process {
        id: memoryProcess

        command: ["sh", "-c", "grep '^MemTotal\\|^MemAvailable' /proc/meminfo"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.parseMemory(this.text);
            }
        }

    }

    Process {
        id: processListProcess

        command: ["sh", "-c", "ps -eo " + "pid=,user=,pcpu=,pmem=,rss=,etime=,comm=,args= " + "--sort=-pcpu | head -n 16"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.parseProcesses(this.text);
            }
        }

    }

    Process {
        id: diskProcess

        command: ["sh", "-c", "df -P -B1 " + "-x tmpfs " + "-x devtmpfs " + "-x squashfs"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.parseDisks(this.text);
            }
        }

    }

    Process {
        id: externalDiskProcess

        command: ["lsblk", "-J", "-o", "MOUNTPOINT,RM,TYPE"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.parseExternalMounts(this.text);
            }
        }

    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            root.updateStats();
        }
    }

}
