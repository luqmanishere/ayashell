import Quickshell
import QtQuick
import qs.services
import qs.config
import qs.data
import qs.components

Item {
    id: root
    implicitHeight: icon.implicitHeight
    implicitWidth: icon.implicitWidth

    property bool enabled: IdleInhibitService.enabled

    Text {
        id: icon
        anchors.centerIn: parent
        font.family: iconMouseArea.containsMouse ? "Material Symbols Rounded" : "Material Symbols Outlined"
        font.pixelSize: Appearance.font.size.large
        font.weight: Font.Normal
        text: {
            if (root.enabled) {
                return "coffee";
            } else {
                return "coffee";
            }
        }
        color: root.enabled ? MatugenManager.raw_colors.primary : MatugenManager.raw_colors.surface
    }

    MouseArea {
        id: iconMouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        hoverEnabled: true
        onClicked: function (mouse) {
            if (mouse.button === Qt.LeftButton) {
                IdleInhibitService.toggle();
                console.log(IdleInhibitService.enabled);
            }
        }
        onEntered: iconTooltip.tooltipVisible = true
        onExited: iconTooltip.tooltipVisible = false
    }

    StyledTooltip {
        id: iconTooltip
        text: {
            if (root.enabled) {
                return "idle-inhibit enabled";
            } else {
                return "idle-inhibit disabled";
            }
        }
        tooltipVisible: false
        targetItem: icon
        shift: false
        delay: 200
    }
}
