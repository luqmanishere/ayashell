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
        const shellOutputName = screen.name;
        var window_id;
        var name;
        for (var i = 0; i < NiriService.workspaces_list.count; i++) {
            var model = NiriService.workspaces_list.get(i).workspace;

            if (model.output === shellOutputName && model.is_active && model.is_focused) {
                window_id = model.active_window_id;
                break;
                console.log("[WindowName]:", i, "-", JSON.stringify(model));
            }
        }
        for (var i = 0; i < NiriService.windows_list.count; i++) {
            var model = NiriService.windows_list.get(i).window;
            // console.log("[WindowName]:", i, "-", JSON.stringify(model));
            if (model.id === window_id) {
                name = model.title;
                break;
            }
        }
        currentWindowName = name;
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
        color: MatugenManager.rawColors.on_primary_container
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
