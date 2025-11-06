import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.data
import qs.services
import qs.config

// TODO: seperate panels for exclusion

// target components:
// 1. workspaces
// 2. Window name
// 3. tray
// 4. wifi
// 5. bluetooth
// 6. optional logo

Rectangle {
    id: bar
    required property var shell
    required property ShellScreen screen
    property int margin: 3
    property var workspaces: NiriService.workspaces_list
    readonly property int exclusiveZone: bar.width

    implicitWidth: Math.max(image.implicitWidth, workspaces.implicitWidth, windowName.implicitWidth, tray.implicitWidth, audioWidget.implicitWidth, clock.implicitWidth, battery.implicitWidth) + 4
    height: Screen.height
    color: MatugenManager.raw_colors.primary_container

    Behavior on color {
        ColorAnimation {
            duration: 1000
        }
    }

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
        color: MatugenManager.raw_colors.on_primary_container
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

    WindowName {
        id: windowName
        screen: bar.screen

        anchors.horizontalCenter: parent.horizontalCenter

        anchors.top: workspaces.bottom
        anchors.bottom: tray.top
        anchors.margins: Appearance.spacing.large
    }

    Tray {
        id: tray

        anchors.bottom: audioWidget.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: Appearance.spacing.smaller
    }

    AudioWidget {
        id: audioWidget

        anchors.bottom: idleIcon.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: Appearance.spacing.small
    }

    IdleIcon {
        id: idleIcon

        anchors.bottom: clock.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: Appearance.spacing.small
    }

    Clock {
        id: clock

        anchors.bottom: battery.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: Appearance.spacing.normal
    }

    Battery {
        id: battery

        anchors.bottom: notifIcon.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: Appearance.spacing.small
    }

    NotificationIcon {
        id: notifIcon
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Appearance.spacing.small
        shell: bar.shell
    }

    // TODO: status icons
    // Rectangle {
    //     id: placeholder
    //     anchors.bottom: parent.bottom
    //     anchors.horizontalCenter: parent.horizontalCenter

    //     implicitWidth: 32
    //     implicitHeight: 32

    //     SequentialAnimation on color {
    //         loops: Animation.Infinite
    //         ColorAnimation {
    //             to: "red"
    //             duration: 1000
    //         }
    //         ColorAnimation {
    //             to: "yellow"
    //             duration: 1000
    //         }
    //         ColorAnimation {
    //             to: "blue"
    //             duration: 1000
    //         }
    //     }
    // }

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
