import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.data

PanelWindow {
    id: outerPanel
    property bool showOverlay: true
    property int topMargin: 36
    property color OverlayColor: showOverlay ? MatugenManger.rawColors.secondary_container : "transparent"
}
