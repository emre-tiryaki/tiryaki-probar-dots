import "../../services"
import QtQuick
import "."

StatsDetailPage {
    title: "GPU"
    subtitle: SystemStatsService.gpuName
    usage: SystemStatsService.gpuUsage
    temperature: SystemStatsService.gpuTemperature
    countText: SystemStatsService.gpuProcesses.length + " processes"
    processTitle: "GPU Processes"
    processes: SystemStatsService.gpuProcesses
    valueHeader: "VRAM"
    valueWidth: 85
    processName: p => p.process_name || p.command || "Unknown"
    processValue: p => p.used_memory !== undefined ? p.used_memory + " MiB" : "-"
}
