pragma Singleton

import Quickshell
import QtQuick
import Qt.labs.platform

Singleton {
    id: root

    // Notification settings
    readonly property NotificationSettings notifications: NotificationSettings {}

    // Animation settings
    readonly property AnimationSettings animations: AnimationSettings {}

    // Timer settings
    readonly property TimerSettings timers: TimerSettings {}

    // File paths
    readonly property PathSettings paths: PathSettings {}

    component NotificationSettings: QtObject {
        readonly property int maxVisible: 5
        readonly property int maxHistory: 100
        readonly property int dismissTimeout: 8000
        readonly property int historyTimeout: 4000
        readonly property int tooltipDelay: 200
    }

    component AnimationSettings: QtObject {
        readonly property int shortDuration: 150
        readonly property int mediumDuration: 300
        readonly property int longDuration: 600
        readonly property int dismissDuration: 150
        readonly property int appearDuration: 150
    }

    component TimerSettings: QtObject {
        readonly property int colorReloadInterval: 10000
        readonly property int historyCheckInterval: 50
        readonly property int appearDelay: 10
    }

    component PathSettings: QtObject {
        readonly property string configDir: StandardPaths.writableLocation(StandardPaths.ConfigLocation) + "/quickshell"
        readonly property string notificationHistory: configDir + "/notification_history.json"
        readonly property string colorsFile: Qt.resolvedUrl("../colors.qml")
    }
}
