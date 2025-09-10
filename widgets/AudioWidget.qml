import QtQuick
import QtQuick.Controls
import qs.services
import qs.config
import qs.data
import qs.components

Item {
    id: root

    property var audio_service: AudioService

    width: main_column.implicitWidth
    height: main_column.implicitHeight

    Column {
        id: main_column
        anchors.centerIn: parent
        spacing: Appearance.spacing.small

        // Speaker/Output Volume
        Column {
            id: sink_column
            spacing: Appearance.spacing.small
            anchors.horizontalCenter: parent.horizontalCenter

            // Volume icon
            Text {
                id: sink_icon
                text: root.audio_service.get_volume_icon(root.audio_service.sink_volume_percent, root.audio_service.sink?.audio?.muted || false)
                font.family: sink_mouse_area.containsMouse ? "Material Symbols Rounded" : "Material Symbols Outlined"
                font.pixelSize: Appearance.font.size.large
                color: (root.audio_service.sink?.audio?.muted || false) ? MatugenManager.raw_colors.error : (sink_mouse_area.containsMouse ? MatugenManager.raw_colors.primary : MatugenManager.raw_colors.on_primary_container)
                anchors.horizontalCenter: parent.horizontalCenter

                Behavior on color {
                    ColorAnimation {
                        duration: Appearance.anim.durations.small
                    }
                }

                // Click to mute - MouseArea only covers the icon
                MouseArea {
                    id: sink_mouse_area
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.audio_service.toggle_sink_mute()
                    onEntered: sink_tooltip.tooltipVisible = true
                    onExited: sink_tooltip.tooltipVisible = false
                }
            }

            // Volume percentage
            Text {
                id: sink_text
                text: root.audio_service.sink_volume_percent + "%"
                font.pixelSize: Appearance.font.size.small
                color: MatugenManager.raw_colors.on_primary_container
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        // Microphone/Input Volume
        Column {
            id: source_column
            spacing: Appearance.spacing.small
            anchors.horizontalCenter: parent.horizontalCenter

            // Mic icon
            Text {
                id: source_icon
                text: (root.audio_service.source?.audio?.muted || false) ? "mic_off" : "mic"
                font.family: source_mouse_area.containsMouse ? "Material Symbols Rounded" : "Material Symbols Outlined"
                font.pixelSize: Appearance.font.size.large
                color: (root.audio_service.source?.audio?.muted || false) ? MatugenManager.raw_colors.error : (source_mouse_area.containsMouse ? MatugenManager.raw_colors.primary : MatugenManager.raw_colors.on_primary_container)
                anchors.horizontalCenter: parent.horizontalCenter

                Behavior on color {
                    ColorAnimation {
                        duration: Appearance.anim.durations.small
                    }
                }

                // Click to mute - MouseArea only covers the icon
                MouseArea {
                    id: source_mouse_area
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.audio_service.toggle_source_mute()
                    onEntered: source_tooltip.tooltipVisible = true
                    onExited: source_tooltip.tooltipVisible = false
                }
            }

            // Volume percentage
            Text {
                id: source_text
                text: root.audio_service.source_volume_percent + "%"
                font.pixelSize: Appearance.font.size.small
                color: MatugenManager.raw_colors.on_primary_container
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // Scroll to adjust volume - covers the entire widget
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton // Only accept wheel events, not clicks
        onWheel: function (wheel) {
            const delta = wheel.angleDelta.y / 120 * 0.05; // 5% per scroll step
            if (wheel.modifiers & Qt.ControlModifier) {
                // Ctrl+scroll for microphone
                const new_volume = (root.audio_service.source?.audio?.volume || 0) + delta;
                root.audio_service.set_source_volume(new_volume);
            } else {
                // Regular scroll for speakers
                const new_volume = (root.audio_service.sink?.audio?.volume || 0) + delta;
                root.audio_service.set_sink_volume(new_volume);
            }
        }
    }

    // Tooltips
    StyledTooltip {
        id: sink_tooltip
        text: (root.audio_service.sink?.audio?.muted || false) ? `Output muted (${root.audio_service.sink_volume_percent}%)` : `Output volume: ${root.audio_service.sink_volume_percent}%\nClick to mute, scroll to adjust`
        tooltipVisible: false
        targetItem: sink_icon
        positionAbove: true
        delay: 200
    }

    StyledTooltip {
        id: source_tooltip
        text: (root.audio_service.source?.audio?.muted || false) ? `Input muted (${root.audio_service.source_volume_percent}%)` : `Input volume: ${root.audio_service.source_volume_percent}%\nClick to mute, Ctrl+scroll to adjust`
        tooltipVisible: false
        targetItem: source_icon
        positionAbove: true
        delay: 200
    }
}
