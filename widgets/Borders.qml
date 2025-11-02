import QtQuick
import Quickshell
import qs.config
import qs.data

Item {
    id: root

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

    // Expose border items for masking
    readonly property Item topBorder: topBorder
    readonly property Item rightBorder: rightBorder
    readonly property Item bottomBorder: bottomBorder
}
