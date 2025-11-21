import QtQuick
import Quickshell
import qs.services
import qs.data

Rectangle {
    id: root
    required property ShellScreen screen
    implicitHeight: workspaceColumn.implicitHeight
    implicitWidth: workspaceColumn.implicitWidth
    radius: 16
    // TODO: color
    color: "transparent"

    QtObject {
        id: filteredWorkspaces
        property var items: []

        function update() {
            const result = [];
            for (let i = 0; i < NiriService.workspaces_list.count; i++) {
                const item = NiriService.workspaces_list.get(i);
                if (item.workspace.output === root.screen.name) {
                    result.push(item);
                }
            }
            items = result;
        }

        Component.onCompleted: update()
    }

    Connections {
        target: NiriService
        function onStateChanged() {
            filteredWorkspaces.update();
        }
    }

    Column {
        id: workspaceColumn

        // anchors.horizontalCenter: parent.horizontalCenter
        anchors.centerIn: parent

        spacing: 6

        Repeater {
            id: workspaceRepeater
            model: filteredWorkspaces.items

            Rectangle {
                id: workspacePill
                required property var modelData

                width: modelData.workspace.is_focused ? 18 : 16
                height: modelData.workspace.is_focused ? 36 : 22
                radius: width / 2
                scale: modelData.workspace.is_focused ? 1.0 : 0.9

                anchors.horizontalCenter: parent.horizontalCenter

                color: {
                    if (modelData.workspace.is_focused) {
                        return MatugenManager.raw_colors.primary;
                    } else if (modelData.workspace.is_active) {
                        return MatugenManager.raw_colors.secondary;
                    } else {
                        return MatugenManager.raw_colors.tertiary;
                    }
                }

                Behavior on width {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on height {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }
                }
            }
        }
    }
}
