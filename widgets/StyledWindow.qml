// import qs.utils
import qs.config
import Quickshell
import Quickshell.Wayland

PanelWindow {
    required property string name

    WlrLayershell.namespace: `solemnattic-${name}`
    color: "transparent"
}
