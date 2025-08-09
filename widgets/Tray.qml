pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

import qs.config

Item {
    id: root

    property var trayService: SystemTray

    implicitHeight: column.implicitHeight
    implicitWidth: column.implicitWidth

    Column {
        id: column
        spacing: Appearance.spacing.small
        anchors.horizontalCenter: parent.horizontalCenter

        Repeater {
            id: repeater
            model: root.trayService.items

            // TODO: interaction

            TrayItem {}
        }
    }
}
