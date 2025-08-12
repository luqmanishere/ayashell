import QtQuick
import Quickshell
import qs.services
import qs.data
import qs.config

Rectangle {
    id: root
    required property ShellScreen screen
    property var currentWindowName

    // get current workspace for output, then get the active window
    function findActiveWindowName() {
        if (!screen || !screen.name) {
            currentWindowName = "Desktop";
            return;
        }

        const shellOutputName = screen.name;
        var window_id = null;
        var name = null;

        // Find active workspace for this output
        if (NiriService.workspaces_list) {
            for (var i = 0; i < NiriService.workspaces_list.count; i++) {
                var workspaceItem = NiriService.workspaces_list.get(i);
                if (!workspaceItem || !workspaceItem.workspace)
                    continue;

                var workspace = workspaceItem.workspace;
                if (workspace.output === shellOutputName && workspace.is_active && workspace.is_focused) {
                    window_id = workspace.active_window_id;
                    break;
                }
            }
        }

        // Find window title
        if (window_id && NiriService.windows_list) {
            for (var j = 0; j < NiriService.windows_list.count; j++) {
                var windowItem = NiriService.windows_list.get(j);
                if (!windowItem || !windowItem.window)
                    continue;

                var window = windowItem.window;
                if (window.id === window_id && window.title) {
                    name = window.title;
                    break;
                }
            }
        }

        currentWindowName = name || "Desktop";
    }

    TextMetrics {
        id: metrics

        text: root.currentWindowName ? root.currentWindowName : "Desktop"
        font.pixelSize: Appearance.font.size.large
        elide: Qt.ElideRight
        elideWidth: root.height
    }

    Text {
        id: text
        anchors.centerIn: parent
        color: MatugenManager.raw_colors.on_primary_container
        font.pixelSize: Appearance.font.size.large
        text: metrics.elidedText
        transform: Rotation {
            angle: 90
            origin.x: text.implicitHeight / 2
            origin.y: text.implicitHeight / 2
        }
        width: implicitHeight
        height: implicitWidth
    }

    // my first connection
    Connections {
        target: NiriService
        function onStateChanged() {
            root.findActiveWindowName();
        }
    }
}
