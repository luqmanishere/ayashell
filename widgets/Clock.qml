import QtQuick
import Quickshell
import qs.data

Column {

    spacing: 0

    Text {
        color: MatugenManager.rawColors.on_primary_container
        text: clock.hours.toString().padStart(2, '0')

        font.pixelSize: 18
        // font.weight: Font.Bold
    }

    Text {
        color: MatugenManager.rawColors.on_primary_container
        text: clock.minutes.toString().padStart(2, '0')
        font.pixelSize: 18
        // font.weight: Font.Bold
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
