pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import QtQuick

import qs.config

MouseArea {
    id: item
    required property SystemTrayItem modelData

    acceptedButtons: Qt.LeftButton | Qt.RightButton

    implicitWidth: Appearance.font.size.small * 2
    implicitHeight: Appearance.font.size.small * 2

    onClicked: event => {
        if (event.button === Qt.LeftButton)
            modelData.activate();
        else if (event.button === Qt.MiddleButton)
            modelData.secondaryActivate();
        else if (event.button === Qt.RightButton)
            menuAnchor.open();
    // simplepopup.opened = true;
    }

    QsMenuOpener {
        id: opener
        menu: item.modelData.menu
    }

    SimplePopup {
        id: simplepopup
        anchor.window: item.QsWindow.window
        anchor.rect.x: 100
        anchor.rect.y: 100
        visible: true
        opened: false

        implicitHeight: 100
        implicitWidth: 100
        content: Column {
            id: col

            Repeater {
                model: opener.children.values

                Text {
                    required property var modelData
                    text: `${modelData.text}`
                }
            }
        }
    }

    // TODO: customise the menu
    QsMenuAnchor {
        id: menuAnchor
        menu: item.modelData.menu

        anchor.window: item.QsWindow.window
        anchor.adjustment: PopupAdjustment.Flip

        anchor.onAnchoring: {
            const window = item.QsWindow.window;
            const widgetRect = window.contentItem.mapFromItem(item, item.height, item.width, item.height);

            menuAnchor.anchor.rect = widgetRect;
        }
    }

    // ToolTip {
    //     relativeItem: item.containsMouse ? item : null

    //     Label {
    //         text: item.item.tooltipTitle || item.item.id
    //     }
    // }

    IconImage {
        anchors.horizontalCenter: parent.horizontalCenter

        source: {
            let icon = item.modelData.icon;
            if (icon.includes("?path=")) {
                const [name, path] = icon.split("?path=");
                icon = `file://${path}/${name.slice(name.lastIndexOf("/") + 1)}`;
            }
            console.log(`Tray icon source: ${icon}`);
            return icon;
        }

        anchors.fill: parent
    }
}
