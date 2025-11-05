import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick.Shapes
import qs.data
import qs.config

PanelWindow {
    id: popup

    property int popupWidth: 400
    property int popupHeight: 300
    property bool hovered: false
    property bool shouldShow: false

    signal mouseEntered
    signal mouseExited

    implicitWidth: popupWidth
    implicitHeight: popupHeight

    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell-top-popup"
    exclusiveZone: 0

    visible: shouldShow

    Rectangle {
        // anchors.horizontalCenter: parent.horizontalCenter
        // anchors.top: parent.top
        anchors.fill: parent
        width: popup.popupWidth
        height: popup.popupHeight

        color: MatugenManager.raw_colors.primary_container
        radius: Appearance.rounding.normal

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onEntered: {
                popup.hovered = true;
                popup.mouseEntered();
            }

            onExited: {
                popup.hovered = false;
                popup.mouseExited();
            }
        }

        // Empty content area for now
        // Content can be added here later
    }
}
