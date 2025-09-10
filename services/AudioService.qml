pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    property var pipewire: Pipewire

    PwObjectTracker {
        objects: {
            var objs = [];
            if (root.pipewire.defaultAudioSink)
                objs.push(root.pipewire.defaultAudioSink);
            if (root.pipewire.defaultAudioSource)
                objs.push(root.pipewire.defaultAudioSource);
            return objs;
        }
    }

    // Direct references to PipeWire devices
    readonly property var sink: pipewire.defaultAudioSink
    readonly property var source: pipewire.defaultAudioSource

    // Convenience properties for percentages
    readonly property int sink_volume_percent: sink?.audio ? Math.round(sink.audio.volume * 100) : 0
    readonly property int source_volume_percent: source?.audio ? Math.round(source.audio.volume * 100) : 0

    // Volume control functions
    function set_sink_volume(volume) {
        if (sink?.audio) {
            sink.audio.volume = Math.max(0.0, Math.min(1.0, volume));
        }
    }

    function set_source_volume(volume) {
        if (source?.audio) {
            source.audio.volume = Math.max(0.0, Math.min(1.0, volume));
        }
    }

    function toggle_sink_mute() {
        if (sink?.audio) {
            sink.audio.muted = !sink.audio.muted;
        }
    }

    function toggle_source_mute() {
        if (source?.audio) {
            source.audio.muted = !source.audio.muted;
        }
    }

    function get_volume_icon(volume_percent, is_muted) {
        if (is_muted)
            return "volume_off";
        if (volume_percent > 66)
            return "volume_up";
        if (volume_percent > 33)
            return "volume_down";
        if (volume_percent > 0)
            return "volume_down";
        return "volume_mute";
    }
}
