pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.widgets

Scope {
    id: scope
    required property var shell
    required property var notificationHistoryWin

    Variants {

        model: Quickshell.screens

        StyledWindow {
            id: win

            required property ShellScreen modelData
            screen: modelData

            implicitWidth: Screen.width
            implicitHeight: Screen.width
            color: "transparent"

            name: "shell"
            // WlrLayershell.exclusionMode: ExclusionMode.Ignore
            exclusionMode: ExclusionMode.Ignore

            anchors.top: true
            anchors.left: true
            anchors.bottom: true
            anchors.right: true

            mask: Region {
                item: bar
            }

            // TODO: left bar
            LeftBar {
                id: bar
                shell: scope.shell

                property var notificationHistoryWin: scope.notificationHistoryWin
            }

            Exclusions {
                bar: bar
                screen: win.modelData
            }
        }
    }
}
