pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import qs.services

Singleton {
    id: root

    property int cpuPercent: 0
    property int memoryPercent: 0
    property int memoryTotalRawKib: 0
    property int memoryAvailableRawKib: 0
    property int memoryAvailableEffectiveKib: 0
    property int swapPercent: 0
    property string swapUsedText: "--"
    property string swapTotalText: "--"
    property int diskPercent: 0
    property string memoryUsedText: "--"
    property string memoryTotalText: "--"
    property string diskUsedText: "--"
    property string diskTotalText: "--"
    property string uptimeText: "--"
    property string kernelText: "--"
    property string hostnameText: "--"
    property string networkText: "Offline"
    property int batteryPercent: -1
    property bool batteryCharging: false
    property int outputVolumePercent: AudioService.sink_volume_percent
    property int inputVolumePercent: AudioService.source_volume_percent

    property int _lastCpuTotal: -1
    property int _lastCpuIdle: -1
    property string _buffer: ""

    readonly property UPowerDevice displayDevice: UPower.displayDevice

    Process {
        id: infoProcess
        command: [
            "sh",
            "-c",
            "echo __CPU__; head -n1 /proc/stat; " +
            "echo __MEM__; " +
            "awk '/^MemTotal:/{print \"MEMTOTAL=\" $2} /^MemAvailable:/{print \"MEMAVAILABLE=\" $2} /^MemFree:/{print \"MEMFREE=\" $2} /^Buffers:/{print \"BUFFERS=\" $2} /^Cached:/{print \"CACHED=\" $2} /^SReclaimable:/{print \"SRECLAIMABLE=\" $2} /^Shmem:/{print \"SHMEM=\" $2} /^SwapTotal:/{print \"SWAPTOTAL=\" $2} /^SwapFree:/{print \"SWAPFREE=\" $2}' /proc/meminfo; " +
            "echo __DISK__; df -kP / | tail -n1; " +
            "echo __UPTIME__; cat /proc/uptime; " +
            "echo __KERNEL__; uname -sr; " +
            "echo __HOST__; hostname; " +
            "echo __NET__; ip -o -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++){if($i==\"dev\") d=$(i+1); if($i==\"src\") s=$(i+1)}} END{if(d!=\"\") print d\" \"s; else print \"offline\"}'"
        ]

        stdout: SplitParser {
            onRead: data => root._buffer += data
        }

        onStarted: root._buffer = ""
        onExited: root._parseOutput(root._buffer)
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!infoProcess.running)
                infoProcess.running = true;
        }
    }

    function _sectionValue(raw, marker, nextMarker) {
        const start = raw.indexOf(marker);
        if (start < 0)
            return "";
        const from = start + marker.length;
        const end = nextMarker ? raw.indexOf(nextMarker, from) : raw.length;
        const until = end >= 0 ? end : raw.length;
        return raw.slice(from, until).trim();
    }

    function _formatKibToGb(kib) {
        return (kib / (1000 * 1000)).toFixed(1) + " GB";
    }

    function _parseMeminfoValues(memSection) {
        const values = ({
        });
        const lines = memSection.split("\n");
        for (const line of lines) {
            const trimmed = line.trim();
            if (!trimmed)
                continue;

            if (trimmed.indexOf("=") > 0) {
                const pair = trimmed.split("=");
                if (pair.length >= 2)
                    values[pair[0]] = Number(pair[1]);
                continue;
            }

            const colonIdx = trimmed.indexOf(":");
            if (colonIdx > 0) {
                const key = trimmed.slice(0, colonIdx);
                const valuePart = trimmed.slice(colonIdx + 1);
                const numberMatch = valuePart.match(/(\d+)/);
                if (numberMatch)
                    values[key] = Number(numberMatch[1]);
            }
        }
        return values;
    }

    function _formatUptime(seconds) {
        const total = Math.max(0, Math.floor(seconds));
        const days = Math.floor(total / 86400);
        const hours = Math.floor((total % 86400) / 3600);
        const minutes = Math.floor((total % 3600) / 60);

        if (days > 0)
            return days + "d " + hours + "h";
        if (hours > 0)
            return hours + "h " + minutes + "m";
        return minutes + "m";
    }

    function _updateCpu(statLine) {
        const parts = statLine.trim().split(/\s+/);
        if (parts.length < 8 || parts[0] !== "cpu")
            return;

        const user = Number(parts[1]);
        const nice = Number(parts[2]);
        const system = Number(parts[3]);
        const idle = Number(parts[4]);
        const iowait = Number(parts[5]);
        const irq = Number(parts[6]);
        const softirq = Number(parts[7]);
        const steal = parts.length > 8 ? Number(parts[8]) : 0;

        const total = user + nice + system + idle + iowait + irq + softirq + steal;
        const idleTotal = idle + iowait;

        if (root._lastCpuTotal >= 0 && root._lastCpuIdle >= 0) {
            const totalDelta = total - root._lastCpuTotal;
            const idleDelta = idleTotal - root._lastCpuIdle;
            if (totalDelta > 0)
                root.cpuPercent = Math.max(0, Math.min(100, Math.round((1 - idleDelta / totalDelta) * 100)));
        }

        root._lastCpuTotal = total;
        root._lastCpuIdle = idleTotal;
    }

    function _updateMemory(memSection) {
        const mem = _parseMeminfoValues(memSection);
        const total = mem.MEMTOTAL || mem.MemTotal || 0;
        const reportedAvailable = mem.MEMAVAILABLE || mem.MemAvailable || 0;
        let available = reportedAvailable;

        if (available <= 0) {
            const free = mem.MEMFREE || mem.MemFree || 0;
            const buffers = mem.BUFFERS || mem.Buffers || 0;
            const cached = mem.CACHED || mem.Cached || 0;
            const reclaimable = mem.SRECLAIMABLE || mem.SReclaimable || 0;
            const shmem = mem.SHMEM || mem.Shmem || 0;
            available = Math.max(0, free + buffers + cached + reclaimable - shmem);
        }

        if (total <= 0)
            return false;

        root.memoryTotalRawKib = total;
        root.memoryAvailableRawKib = reportedAvailable;
        root.memoryAvailableEffectiveKib = available;

        const used = Math.max(0, total - available);
        root.memoryPercent = Math.round((used / total) * 100);
        root.memoryUsedText = _formatKibToGb(used);
        root.memoryTotalText = _formatKibToGb(total);

        const swapTotal = mem.SWAPTOTAL || mem.SwapTotal || 0;
        const swapFree = mem.SWAPFREE || mem.SwapFree || 0;
        const swapUsed = Math.max(0, swapTotal - swapFree);
        if (swapTotal > 0) {
            root.swapPercent = Math.round((swapUsed / swapTotal) * 100);
            root.swapUsedText = _formatKibToGb(swapUsed);
            root.swapTotalText = _formatKibToGb(swapTotal);
        } else {
            root.swapPercent = 0;
            root.swapUsedText = "0.0 GB";
            root.swapTotalText = "0.0 GB";
        }
        return true;
    }

    function _updateMemoryFromRaw(raw) {
        const totalMatch = raw.match(/MEMTOTAL=(\d+)/);
        if (!totalMatch)
            return false;

        const availableMatch = raw.match(/MEMAVAILABLE=(\d+)/);
        const freeMatch = raw.match(/MEMFREE=(\d+)/);
        const buffersMatch = raw.match(/BUFFERS=(\d+)/);
        const cachedMatch = raw.match(/CACHED=(\d+)/);
        const reclaimableMatch = raw.match(/SRECLAIMABLE=(\d+)/);
        const shmemMatch = raw.match(/SHMEM=(\d+)/);
        const swapTotalMatch = raw.match(/SWAPTOTAL=(\d+)/);
        const swapFreeMatch = raw.match(/SWAPFREE=(\d+)/);

        const total = Number(totalMatch[1]);
        const reportedAvailable = availableMatch ? Number(availableMatch[1]) : 0;

        let available = reportedAvailable;
        if (available <= 0) {
            const free = freeMatch ? Number(freeMatch[1]) : 0;
            const buffers = buffersMatch ? Number(buffersMatch[1]) : 0;
            const cached = cachedMatch ? Number(cachedMatch[1]) : 0;
            const reclaimable = reclaimableMatch ? Number(reclaimableMatch[1]) : 0;
            const shmem = shmemMatch ? Number(shmemMatch[1]) : 0;
            available = Math.max(0, free + buffers + cached + reclaimable - shmem);
        }

        if (total <= 0)
            return false;

        root.memoryTotalRawKib = total;
        root.memoryAvailableRawKib = reportedAvailable;
        root.memoryAvailableEffectiveKib = available;

        const used = Math.max(0, total - available);
        root.memoryPercent = Math.round((used / total) * 100);
        root.memoryUsedText = _formatKibToGb(used);
        root.memoryTotalText = _formatKibToGb(total);

        const swapTotal = swapTotalMatch ? Number(swapTotalMatch[1]) : 0;
        const swapFree = swapFreeMatch ? Number(swapFreeMatch[1]) : 0;
        const swapUsed = Math.max(0, swapTotal - swapFree);
        if (swapTotal > 0) {
            root.swapPercent = Math.round((swapUsed / swapTotal) * 100);
            root.swapUsedText = _formatKibToGb(swapUsed);
            root.swapTotalText = _formatKibToGb(swapTotal);
        } else {
            root.swapPercent = 0;
            root.swapUsedText = "0.0 GB";
            root.swapTotalText = "0.0 GB";
        }
        return true;
    }

    function _updateDisk(diskLine) {
        const parts = diskLine.trim().split(/\s+/);
        if (parts.length < 6)
            return;

        const totalKib = Number(parts[1]);
        const usedKib = Number(parts[2]);
        const percent = Number(parts[4].replace("%", ""));

        if (totalKib > 0) {
            root.diskTotalText = _formatKibToGb(totalKib);
            root.diskUsedText = _formatKibToGb(usedKib);
            root.diskPercent = Math.max(0, Math.min(100, percent));
        }
    }

    function _parseOutput(raw) {
        const cpu = _sectionValue(raw, "__CPU__", "__MEM__");
        const mem = _sectionValue(raw, "__MEM__", "__DISK__");
        const disk = _sectionValue(raw, "__DISK__", "__UPTIME__");
        const uptime = _sectionValue(raw, "__UPTIME__", "__KERNEL__");
        const kernel = _sectionValue(raw, "__KERNEL__", "__HOST__");
        const host = _sectionValue(raw, "__HOST__", "__NET__");
        const net = _sectionValue(raw, "__NET__", null);

        if (cpu)
            _updateCpu(cpu.split("\n")[0]);
        const memoryParsed = _updateMemoryFromRaw(raw);
        if (!memoryParsed && mem)
            _updateMemory(mem);
        if (disk)
            _updateDisk(disk.split("\n")[0]);

        const uptimeSeconds = Number((uptime.split(/\s+/)[0] || "0").trim());
        if (!isNaN(uptimeSeconds))
            root.uptimeText = _formatUptime(uptimeSeconds);

        root.kernelText = kernel || "--";
        root.hostnameText = host || "--";

        const netParts = (net || "").trim().split(/\s+/);
        if (netParts.length >= 2 && netParts[0] !== "offline")
            root.networkText = netParts[0] + " - " + netParts[1];
        else
            root.networkText = "Offline";
    }

    function _updateBattery() {
        if (!displayDevice || displayDevice.energyCapacity <= 0) {
            batteryPercent = -1;
            batteryCharging = false;
            return;
        }

        batteryPercent = Math.round((displayDevice.energy / displayDevice.energyCapacity) * 100);
        const stateText = String(displayDevice.state).toLowerCase();
        batteryCharging = stateText.indexOf("charging") !== -1 || Number(displayDevice.state) === 1;
    }

    onDisplayDeviceChanged: {
        _updateBattery();
    }

    Connections {
        target: displayDevice
        function onEnergyChanged() {
            root._updateBattery();
        }
        function onStateChanged() {
            root._updateBattery();
        }
    }

    Component.onCompleted: _updateBattery()
}
