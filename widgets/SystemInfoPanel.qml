import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.data
import qs.config
import qs.services

Item {
    id: root

    SystemClock {
        id: panelClock
        precision: SystemClock.Seconds
    }

    component MetricCard: Rectangle {
        id: card
        required property string title
        required property string icon
        required property string value
        property string subtitle: ""
        property int progress: -1
        property bool hovered: false
        property bool invertProgressSeverity: false
        property bool forcePrimaryProgress: false

        function progressColor() {
            if (card.forcePrimaryProgress)
                return MatugenManager.raw_colors.primary;
            if (card.progress < 0)
                return MatugenManager.raw_colors.primary;
            if (!card.invertProgressSeverity && card.progress > 90)
                return MatugenManager.raw_colors.error;
            if (card.invertProgressSeverity && card.progress < 10)
                return MatugenManager.raw_colors.error;
            return MatugenManager.raw_colors.primary;
        }

        radius: Appearance.rounding.normal
        color: MatugenManager.raw_colors.secondary_container
        border.width: 1
        border.color: hovered ? MatugenManager.raw_colors.primary : MatugenManager.raw_colors.outline
        scale: hovered ? 1.015 : 1.0
        Behavior on color {
            ColorAnimation {
                duration: Appearance.anim.durations.small
            }
        }
        Behavior on border.color {
            ColorAnimation {
                duration: Appearance.anim.durations.small
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: Appearance.anim.durations.small
                easing.bezierCurve: Appearance.anim.curves.standard
            }
        }

        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumWidth: 180

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Appearance.padding.normal
            spacing: Appearance.spacing.small

            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.small

                Text {
                    text: card.icon
                    color: MatugenManager.raw_colors.primary
                    font.family: Appearance.font.family.material
                    font.pixelSize: Appearance.font.size.normal
                }

                Text {
                    text: card.title
                    color: MatugenManager.raw_colors.on_secondary_container
                    font.family: Appearance.font.family.sans
                    font.pixelSize: Appearance.font.size.smaller
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

            }

            Text {
                text: card.value
                color: MatugenManager.raw_colors.on_secondary_container
                font.family: Appearance.font.family.mono
                font.pixelSize: Appearance.font.size.normal
                font.weight: Font.DemiBold
                wrapMode: Text.NoWrap
                maximumLineCount: 1
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: card.subtitle
                visible: text.length > 0
                color: MatugenManager.raw_colors.on_secondary_container
                font.family: Appearance.font.family.sans
                font.pixelSize: Appearance.font.size.small
                wrapMode: Text.Wrap
                maximumLineCount: 1
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Rectangle {
                visible: card.progress >= 0
                Layout.fillWidth: true
                Layout.preferredHeight: 6
                radius: Appearance.rounding.full
                color: MatugenManager.raw_colors.outline
                Layout.topMargin: 2

                Rectangle {
                    width: parent.width * Math.max(0, Math.min(100, card.progress)) / 100
                    height: parent.height
                    radius: parent.radius
                    color: card.progressColor()
                    Behavior on width {
                        NumberAnimation {
                            duration: Appearance.anim.durations.small
                            easing.bezierCurve: Appearance.anim.curves.standard
                        }
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onEntered: card.hovered = true
            onExited: card.hovered = false
        }

    }

    Rectangle {
        anchors.fill: parent
        color: MatugenManager.raw_colors.primary
        radius: Appearance.rounding.normal

        GridLayout {
            id: grid
            anchors.fill: parent
            anchors.margins: Appearance.padding.normal
            rowSpacing: Appearance.spacing.normal
            columnSpacing: Appearance.spacing.normal
            columns: width >= 560 ? 3 : 2

            MetricCard {
                title: "CPU"
                icon: "memory"
                value: `${SystemInfoService.cpuPercent}%`
                subtitle: "Processor usage"
                progress: SystemInfoService.cpuPercent
            }

            MetricCard {
                title: "Memory"
                icon: "developer_board"
                value: `${SystemInfoService.memoryUsedText} / ${SystemInfoService.memoryTotalText}`
                subtitle: `${SystemInfoService.memoryPercent}% used`
                progress: SystemInfoService.memoryPercent
            }

            MetricCard {
                title: "Swap"
                icon: "swap_horiz"
                value: `${SystemInfoService.swapUsedText} / ${SystemInfoService.swapTotalText}`
                subtitle: `${SystemInfoService.swapPercent}% used`
                progress: SystemInfoService.swapPercent
            }

            MetricCard {
                title: "Disk"
                icon: "storage"
                value: `${SystemInfoService.diskUsedText} / ${SystemInfoService.diskTotalText}`
                subtitle: `${SystemInfoService.diskPercent}% used on /`
                progress: SystemInfoService.diskPercent
            }

            MetricCard {
                title: "Network"
                icon: "lan"
                value: SystemInfoService.networkText
                subtitle: "Default route interface"
            }

            MetricCard {
                title: "Battery"
                icon: SystemInfoService.batteryCharging ? "battery_charging_full" : "battery_full"
                value: SystemInfoService.batteryPercent >= 0 ? `${SystemInfoService.batteryPercent}%` : "No battery"
                subtitle: SystemInfoService.batteryCharging ? "Charging" : "Discharging"
                progress: SystemInfoService.batteryPercent
                invertProgressSeverity: true
            }

            MetricCard {
                title: "System"
                icon: "computer"
                value: SystemInfoService.hostnameText
                subtitle: `${SystemInfoService.kernelText} - up ${SystemInfoService.uptimeText}`
            }

            MetricCard {
                title: "Audio Output"
                icon: "volume_up"
                value: `${SystemInfoService.outputVolumePercent}%`
                subtitle: "Default sink"
                progress: SystemInfoService.outputVolumePercent
                forcePrimaryProgress: true
            }

            MetricCard {
                title: "Audio Input"
                icon: "mic"
                value: `${SystemInfoService.inputVolumePercent}%`
                subtitle: "Default source"
                progress: SystemInfoService.inputVolumePercent
                forcePrimaryProgress: true
            }

            MetricCard {
                title: "Update"
                icon: "update"
                value: `Last updated ${panelClock.hours.toString().padStart(2, '0')}:${panelClock.minutes.toString().padStart(2, '0')}:${panelClock.seconds.toString().padStart(2, '0')}`
                subtitle: "Live system snapshot"
                Layout.columnSpan: grid.columns
            }
        }
    }
}
