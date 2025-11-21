pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
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
    property int currentTab: 0
    readonly property var tabs: [{
            "title": "System Info",
            "icon": "monitoring"
        }, {
            "title": "Tasks",
            "icon": "checklist"
        }, {
            "title": "Settings",
            "icon": "settings"
        }]

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
        border.width: 0

        ColumnLayout {
            anchors.margins: 5
            anchors.fill: mainRect
            spacing: 5

            RowLayout {
                id: tabsArea
                Layout.fillWidth: true
                Layout.minimumHeight: 42
                spacing: Appearance.spacing.small
                Layout.alignment: Qt.AlignHCenter

                Repeater {
                    id: tabRepeater
                    model: popup.tabs

                    Rectangle {
                        required property var modelData
                        required property int index
                        property bool selected: popup.currentTab === index
                        radius: Appearance.rounding.full
                        implicitHeight: 34
                        implicitWidth: tabRow.implicitWidth + 24
                        color: selected ? MatugenManager.raw_colors.primary : MatugenManager.raw_colors.secondary_container

                        RowLayout {
                            id: tabRow
                            anchors.centerIn: parent
                            spacing: Appearance.spacing.small

                            Text {
                                text: modelData.icon
                                color: selected ? MatugenManager.raw_colors.on_primary : MatugenManager.raw_colors.on_primary_container
                                font.family: Appearance.font.family.material
                                font.pixelSize: Appearance.font.size.normal
                            }

                            Text {
                                id: tabText
                                text: modelData.title
                                color: selected ? MatugenManager.raw_colors.on_primary : MatugenManager.raw_colors.on_primary_container
                                font.family: Appearance.font.family.sans
                                font.pixelSize: Appearance.font.size.normal
                                font.weight: selected ? Font.DemiBold : Font.Medium
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: Appearance.anim.durations.small
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: popup.currentTab = index
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: MatugenManager.raw_colors.outline
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: MatugenManager.raw_colors.primary
                radius: Appearance.rounding.normal

                StackLayout {
                    anchors.fill: parent
                    anchors.margins: Appearance.padding.small
                    currentIndex: popup.currentTab

                    SystemInfoPanel {}

                    Item {
                        Rectangle {
                            anchors.fill: parent
                            radius: Appearance.rounding.normal
                            color: MatugenManager.raw_colors.secondary_container

                            Text {
                                anchors.centerIn: parent
                                text: "Tasks panel coming soon"
                                color: MatugenManager.raw_colors.on_secondary_container
                                font.family: Appearance.font.family.sans
                                font.pixelSize: Appearance.font.size.large
                            }
                        }
                    }

                    Item {
                        Rectangle {
                            anchors.fill: parent
                            radius: Appearance.rounding.normal
                            color: MatugenManager.raw_colors.secondary_container

                            Text {
                                anchors.centerIn: parent
                                text: "Settings panel coming soon"
                                color: MatugenManager.raw_colors.on_secondary_container
                                font.family: Appearance.font.family.sans
                                font.pixelSize: Appearance.font.size.large
                            }
                        }
                    }
                }
            }

        }
    }

    HoverHandler {
        id: popupHoverHandler
        onHoveredChanged: {
            popup.hovered = hovered;
            if (hovered)
                popup.mouseEntered();
            else
                popup.mouseExited();
        }
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
