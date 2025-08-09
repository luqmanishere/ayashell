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

    Shell {
        shell: root
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

            if (notification.hasInlineReply) {
                console.log("[Notification] Notification has inline replies:", notification.appName, "-", notification.summary);
            }

        // TODO: check actions
        }
    }

    NotificationPopup {
        id: notificationPopup
    }

    Component.onCompleted: {
        root.matugen.setService(root.matugen_service);
    }
}
