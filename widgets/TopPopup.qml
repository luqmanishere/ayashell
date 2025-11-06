pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick.Shapes
import qs.data
import qs.config

PanelWindow {
    id: popup

    property int popupWidth: Appearance.topPopup.popupWidth
    property int popupHeight: Appearance.topPopup.popupHeight
    property bool hovered: false
    property bool shouldShow: false
    property int cornerRadius: 30

    signal mouseEntered
    signal mouseExited

    implicitWidth: popupWidth + (cornerRadius * 2)
    implicitHeight: popupHeight

    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell-top-popup"
    exclusiveZone: 0

    visible: shouldShow

    Rectangle {
        id: mainRect
        anchors.centerIn: parent
        width: popup.popupWidth
        height: popup.popupHeight

        color: MatugenManager.raw_colors.primary_container
        bottomRightRadius: Appearance.rounding.normal
        bottomLeftRadius: Appearance.rounding.normal

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

        // TODO: add content
    }

    Rectangle {
        id: cornersArea
        anchors.fill: parent
        color: "transparent"

        Repeater {
            model: [0, 1]

            Corner {
                required property int modelData
                corner: modelData
                color: MatugenManager.raw_colors.primary_container
            }
        }
    }

    component Corner: WrapperItem {
        id: cornerRoot

        required property int corner
        property real radius: popup.cornerRadius
        required property color color

        Component.onCompleted: {
            switch (corner) {
            case 0:
                anchors.left = cornersArea.left;
                anchors.top = cornersArea.top;
                rotation = 90;
                break;
            case 1:
                anchors.top = cornersArea.top;
                anchors.right = cornersArea.right;
                break;
            }
        }

        Shape {
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeWidth: 0
                fillColor: cornerRoot.color
                startX: cornerRoot.radius

                PathArc {
                    relativeX: -cornerRoot.radius
                    relativeY: cornerRoot.radius
                    radiusX: cornerRoot.radius
                    radiusY: radiusX
                    direction: PathArc.Counterclockwise
                }

                PathLine {
                    relativeX: 0
                    relativeY: -cornerRoot.radius
                }

                PathLine {
                    relativeX: cornerRoot.radius
                    relativeY: 0
                }
            }
        }
    }
}
