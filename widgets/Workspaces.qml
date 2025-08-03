import QtQuick
import qs.services
import qs.data

Rectangle {
    id: root

    Column {
        id: workspaceColumn
        property var workspaces: NiriService.workspaces_list

        anchors.horizontalCenter: parent.horizontalCenter

        spacing: 6

        Repeater {
            id: workspaceRepeater
            model: workspaceColumn.workspaces

            Rectangle {
                id: workspacePill

                width: model.workspace.is_focused ? 18 : 16
                height: model.workspace.is_focused ? 36 : 22
                radius: width / 2
                scale: model.workspace.is_focused ? 1.0 : 0.9

                anchors.horizontalCenter: parent.horizontalCenter

                color: {
                    if (model.workspace.is_focused) {
                        return MatugenManager.rawColors.primary;
                    } else if (model.workspace.is_active) {
                        return MatugenManager.rawColors.secondary;
                    } else {
                        return MatugenManager.rawColors.tertiary;
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
