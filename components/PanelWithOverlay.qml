// From Noctalia (Lysec) - d973ed066c3a9471504e4799916364be909b0133
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.data

PanelWindow {
    id: outerPanel
    property bool showOverlay: false
    property int topMargin: 36
    property color overlayColor: showOverlay ? MatugenManager.raw_colors.secondary_container : "transparent"

    function dismiss() {
        visible = false;
    }

    function show() {
        visible = true;
    }

    implicitWidth: screen.width
    implicitHeight: screen.height
    color: visible ? overlayColor : "transparent"
    visible: false
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    screen: (typeof modelData !== 'undefined' ? modelData : null)
    anchors.top: true
    anchors.left: true
    anchors.right: true
    anchors.bottom: true
    margins.top: topMargin

    MouseArea {
        anchors.fill: parent
        onClicked: outerPanel.dismiss()
    }

    Behavior on color {
        ColorAnimation {
            duration: 350
            easing.type: Easing.InOutCubic
        }
    }
}
