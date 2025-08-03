import "modules/shell"
import "data"
import "services"

import Quickshell
import Quickshell.Io
import QtQuick

import Quickshell.Services.Notifications

ShellRoot {
    id: root
    property var matugen: MatugenManager
    property var matugen_service: MatugenService {}
    property var niri_service: NiriService

    Shell {
        shell: root
    }

    Component.onCompleted: {
        root.matugen.setService(root.matugen_service);
    }
}
