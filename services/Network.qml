pragma Singleton
// Using iwctl
import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property list<AccessPoint> networks: []
    property string deviceName: "wlan0"
    property bool isScanning: false
    property bool wifiEnabled: true

    reloadableId: "network"

    function enableWifi(enabled: bool) {
        const cmd = enabled ? "on" : "off";
    }

    component AccessPoint: QtObject {
        id: accessPoint
        property string ssid
        property string bssid
        property int signalStrength
        property bool isConnected: false
    }
}
