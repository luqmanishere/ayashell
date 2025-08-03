import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.data
import qs.services
import qs.config

// target components:
// 1. workspaces
// 2. Window name
// 3. tray
// 4. wifi
// 5. bluetooth
// 6. optional logo

Rectangle {
    id: bar
    property var shell
    property int margin: 3
    property var workspaces: NiriService.workspaces_list

    implicitWidth: Math.max(image.implicitWidth, workspaces.implicitWidth, tray.implicitWidth, clock.implicitWidth)
    height: Screen.height
    color: MatugenManager.rawColors.primary_container

    ClippingRectangle {
        id: image
        implicitWidth: 32
        implicitHeight: 32

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: Appearance.padding.small
        // height: 32
        // width: 32
        radius: width / 2
        color: MatugenManager.rawColors.on_primary_container
        clip: true

        Image {
            anchors.fill: parent
            source: "/home/luqman/Downloads/suisei.jpg"
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
        }
    }

    Workspaces {
        id: workspaces
        anchors.top: image.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: Appearance.padding.smaller
    }

    // TODO: active window

    Tray {
        id: tray

        anchors.bottom: clock.top
        anchors.horizontalCenter: parent.horizontalCenter
        implicitHeight: 32
        implicitWidth: 0.7 * parent.width
    }

    Clock {
        id: clock
        anchors.bottom: placeholder.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: Appearance.spacing.normal
    }

    // TODO: status icons
    Rectangle {
        id: placeholder
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        implicitWidth: 32
        implicitHeight: 32
    }

    // in no particular order
    // TODO: power menu
    // TODO: wifi
    // TODO: bluetooth
    // TODO: battery
    // TODO: tray

    // // anchors.centerIn: parent
    // NiriWorkspaces {
    //     id: workspaces
    //     anchors.horizontalCenter: bar.horizontalCenter
    //     implicitWidth: bar.implicitWidth - (bar.margin * 2)
    // }

}
