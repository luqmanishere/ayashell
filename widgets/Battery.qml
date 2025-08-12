import Quickshell
import Quickshell.Services.UPower
import QtQuick

import qs.data
import qs.config

Item {
    id: root
    property UPower upowerService: UPower
    property UPowerDevice displayDevice: UPower.displayDevice
    implicitHeight: text.implicitHeight
    implicitWidth: text.implicitWidth

    // TODO: animate when charging
    // TODO: icon
    // TODO: other data in a popup
    Text {
        id: text
        anchors.horizontalCenter: parent.horizontalCenter
        color: MatugenManager.raw_colors.on_primary_container
        text: `${Math.round((root.displayDevice.energy / root.displayDevice.energyCapacity) * 100)}%`

        font.pixelSize: Appearance.font.size.normal
        // font.weight: Font.Bold
    }

    Component.onCompleted: {
        console.log("UPower display device: " + JSON.stringify(UPower.displayDevice));
        const length = UPower.devices.values.length;
        console.log("UPower devices: " + length);
        for (var i = 0; i < length; i++) {
            console.log(JSON.stringify(UPower.devices.values[i].percentage));
        }
    }
}
