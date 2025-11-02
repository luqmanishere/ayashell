import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Widgets
import qs.config
import qs.data

Item {
    id: root
    property var bar

    // Top border
    Rectangle {
        id: topBorder
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: Appearance.border.thickness
        color: MatugenManager.raw_colors.primary_container
    }

    // Right border
    Rectangle {
        id: rightBorder
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: Appearance.border.thickness
        color: MatugenManager.raw_colors.primary_container
    }

    // Bottom border
    Rectangle {
        id: bottomBorder
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: Appearance.border.thickness
        color: MatugenManager.raw_colors.primary_container
    }

    Rectangle {
        id: cornersArea
        implicitHeight: QsWindow.window?.height - (topBorder.height + bottomBorder.height)
        implicitWidth: QsWindow.window?.width - (bar.width + rightBorder.width)
        color: "transparent"
        x: bar.width
        y: topBorder.height

        Repeater {
            model: [0, 1, 2, 3]

            Corner {
                required property int modelData
                corner: modelData
                color: MatugenManager.raw_colors.primary_container
            }
        }
    }

    component Corner: WrapperItem {
        id: root

        property int corner
        property real radius: 20
        property color color

        Component.onCompleted: {
            switch (corner) {
            case 0:
                anchors.left = parent.left;
                anchors.top = parent.top;
                break;
            case 1:
                anchors.top = parent.top;
                anchors.right = parent.right;
                rotation = 90;
                break;
            case 2:
                anchors.right = parent.right;
                anchors.bottom = parent.bottom;
                rotation = 180;
                break;
            case 3:
                anchors.left = parent.left;
                anchors.bottom = parent.bottom;
                rotation = -90;
                break;
            }
        }

        Shape {
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeWidth: 0
                fillColor: root.color
                startX: root.radius

                PathArc {
                    relativeX: -root.radius
                    relativeY: root.radius
                    radiusX: root.radius
                    radiusY: radiusX
                    direction: PathArc.Counterclockwise
                }

                PathLine {
                    relativeX: 0
                    relativeY: -root.radius
                }

                PathLine {
                    relativeX: root.radius
                    relativeY: 0
                }
            }
        }
    }

    // Expose border items for masking
    readonly property Item topBorder: topBorder
    readonly property Item rightBorder: rightBorder
    readonly property Item bottomBorder: bottomBorder
}
