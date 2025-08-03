pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

Item {
    id: root

    property var trayService: SystemTray

    Column {
        spacing: 0
        anchors.horizontalCenter: parent.horizontalCenter

        Repeater {
            model: root.trayService.items

            // TODO: interaction

            IconImage {

                required property SystemTrayItem modelData

                // source: model.icon
                source: {
                    let icon = modelData.icon;
                    if (icon.includes("?path=")) {
                        const [name, path] = icon.split("?path=");
                        icon = `file://${path}/${name.slice(name.lastIndexOf("/") + 1)}`;
                    }
                    console.log(`Tray icon source: ${icon}`);
                    return icon;
                }
                width: root.width
                height: width
            }
        }
    }
}
