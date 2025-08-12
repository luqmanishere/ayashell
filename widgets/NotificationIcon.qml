import QtQuick
import Quickshell
import Quickshell.Io
import qs.config
import qs.data
import qs.components

Item {
    id: root
    width: 22
    height: 30
    property bool isSilence: false
    required property var shell

    Process {
        id: rightClickProcess
    }

    // Timer to check when NotificationHistory is loaded
    Timer {
        id: checkHistoryTimer
        interval: 50
        repeat: true
        onTriggered: {
            if (root.shell && root.shell.notificationHistoryWin) {
                root.shell.notificationHistoryWin.visible = true;
                checkHistoryTimer.stop();
            }
        }
    }

    Item {
        id: bell
        implicitHeight: 22
        implicitWidth: 22
        anchors.centerIn: parent
        Text {
            id: bellText
            anchors.centerIn: parent
            text: {
                if (root.shell && root.shell.notificationHistoryWin && root.shell.notificationHistoryWin.hasUnread) {
                    return "notifications_unread";
                } else {
                    return "notifications";
                }
            }
            font.family: mouseAreaBell.containsMouse ? "Material Symbols Rounded" : "Material Symbols Outlined"
            font.pixelSize: Appearance.font.size.large
            font.weight: {
                if (root.shell && root.shell.notificationHistoryWin && root.shell.notificationHistoryWin.hasUnread) {
                    return Font.Bold;
                } else {
                    return Font.Normal;
                }
            }
            color: mouseAreaBell.containsMouse ? MatugenManager.raw_colors.on_primary : (root.shell && root.shell.notificationHistoryWin && root.shell.notificationHistoryWin.hasUnread ? MatugenManager.raw_colors.error : MatugenManager.raw_colors.primary)
        }
        MouseArea {
            id: mouseAreaBell
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: function (mouse) {
                if (mouse.button === Qt.RightButton) {
                    root.isSilence = !root.isSilence;
                    rightClickProcess.running = true;
                    bellText.text = root.isSilence ? "notifications_off" : "notifications";
                }

                if (mouse.button === Qt.LeftButton) {
                    if (root.shell) {
                        console.log("root.shell is init");
                        if (!root.shell.notificationHistoryWin) {
                            console.log("root.shell.notificationHistoryWin is not found");
                            // Use the shell function to load notification history
                            root.shell.loadNotificationHistory();
                            checkHistoryTimer.start();
                        } else {
                            console.log("NotificationHistory visible:", root.shell.notificationHistoryWin.visible);
                            // Already loaded, just toggle visibility
                            root.shell.notificationHistoryWin.visible = !root.shell.notificationHistoryWin.visible;
                        }
                    } else {
                        console.log("root.shell is none");
                    }
                    return;
                }
            }
            onEntered: notificationTooltip.tooltipVisible = true
            onExited: notificationTooltip.tooltipVisible = false
        }
    }

    StyledTooltip {
        id: notificationTooltip
        text: "Notification History"
        positionAbove: true
        tooltipVisible: false
        targetItem: bell
        shift: false
        delay: 200
    }
}
