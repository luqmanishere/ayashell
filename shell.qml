//@ pragma UseQApplication
import qs.modules.shell
import qs.data
import qs.services
import qs.widgets

import Quickshell
import Quickshell.Services.Notifications
import QtQuick

ShellRoot {
    id: root
    property var matugen: MatugenManager
    property var matugen_service: MatugenService {}
    property var niri_service: NiriService
    property var notificationHistoryWin: notificationHistoryLoader.active ? notificationHistoryLoader.item : null

    Shell {
        shell: root
        notificationHistoryWin: notificationHistoryLoader.active ? notificationHistoryLoader.item : null
    }

    // Function to load notification history
    function loadNotificationHistory() {
        if (!notificationHistoryLoader.active) {
            notificationHistoryLoader.loading = true;
        }
        return notificationHistoryLoader;
    }

    NotificationServer {
        id: notificationServer
        onNotification: function (notification) {
            console.log("[Notification] Received notification:", notification.appName, "-", notification.summary);
            notification.tracked = true;
            if (notificationPopup.notificationsVisible) {
                // add to popups
                notificationPopup.addNotification(notification);
            }

            // TODO: history
            if (notificationHistoryLoader.active && notificationHistoryLoader.item) {
                notificationHistoryLoader.item.addToHistory({
                    id: notification.id,
                    appName: notification.appName || "Notification",
                    summary: notification.summary || "",
                    body: notification.body || "",
                    urgency: notification.urgency,
                    timestamp: Date.now()
                });
            }

            if (notification.hasInlineReply) {
                console.log("[Notification] Notification has inline replies:", notification.appName, "-", notification.summary);
            }

        // TODO: check actions
        }
    }

    NotificationPopup {
        id: notificationPopup
    }

    LazyLoader {
        id: notificationHistoryLoader
        loading: false
        component: NotificationHistory {}
    }

    Component.onCompleted: {
        root.matugen.setService(root.matugen_service);
    }
}
