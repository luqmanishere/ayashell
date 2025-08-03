pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Shapes
import qs.widgets

Scope {
    id: scope
    property var shell

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

            anchors {
                top: true
                left: true
                bottom: true
                right: true
            }

            mask: Region {
                item: bar
            }

            // TODO: left bar
            LeftBar {
                id: bar
                shell: scope.shell
            }
        }
    }
}
