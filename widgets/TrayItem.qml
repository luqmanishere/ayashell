pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import QtQuick

import qs.config

MouseArea {
    id: item
    required property SystemTrayItem modelData
    property int popupX
    property int popupY

    acceptedButtons: Qt.LeftButton | Qt.RightButton

    implicitWidth: Appearance.font.size.small * 2
    implicitHeight: Appearance.font.size.small * 2
    hoverEnabled: true

    onClicked: event => {
        if (!modelData)
            return;

        if (event.button === Qt.LeftButton && modelData.activate)
            modelData.activate();
        else if (event.button === Qt.MiddleButton && modelData.secondaryActivate)
            modelData.secondaryActivate();
        else if (event.button === Qt.RightButton && modelData.menu)
            menuAnchor.open();
    }

    onEntered: {
        console.log("area entered");
        var pos = item.mapToItem(item.QsWindow.window.window, item.width, item.height / 2);
        item.popupX = pos.x;
        item.popupY = pos.y - (simplepopup.implicitHeight / 2);
        simplepopup.opened = true;
        console.log(pos);
    }
    onExited: {
        simplepopup.opened = item.containsMouse || popupMouse.containsMouse;
    }

    QsMenuOpener {
        id: opener
        menu: item.modelData.menu
    }

    // PopupWindow {
    //     // anchor.window: item.QsWindow.window
    //     implicitHeight: rect.implicitHeight
    //     implicitWidth: rect.implicitWidth
    //     visible: true
    //     anchor.item: item
    //     anchor.margins.left: 10

    //     Rectangle {
    //         id: rect

    //         implicitHeight: col2.height
    //         implicitWidth: col2.width

    //         color: "white"
    //         Column {
    //             id: col2

    //             Repeater {
    //                 model: opener.children.values

    //                 Text {
    //                     required property var modelData
    //                     text: `${modelData.text}`
    //                 }
    //             }
    //         }
    //     }
    // }

    // // TODO: make this work one day
    // SimplePopup {
    //     id: simplepopup
    //     anchor.window: item.QsWindow.window
    //     anchor.rect.x: item.popupX
    //     anchor.rect.y: item.popupY
    //     visible: true
    //     opened: false

    //     implicitHeight: content.QObject.height
    //     implicitWidth: 100
    //     content: Column {
    //         id: col

    //         Repeater {
    //             model: opener.children.values

    //             Text {
    //                 required property var modelData
    //                 text: `${modelData.text}`
    //             }
    //         }
    //     }
    //     MouseArea {
    //         id: popupMouse
    //         anchors.fill: parent
    //     }
    // }

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
