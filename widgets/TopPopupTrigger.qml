import QtQuick
import qs.config

Rectangle {
    id: trigger

    property int triggerWidth: 100
    property int triggerHeight: 5
    property int showDelay: 100
    property bool triggerHovered: false

    signal showPopup
    signal hidePopup

    width: triggerWidth
    height: triggerHeight
    color: "transparent"

    Timer {
        id: showTimer
        interval: trigger.showDelay
        onTriggered: trigger.showPopup()
    }

    Timer {
        id: hideTimer
        interval: 200
        onTriggered: trigger.hidePopup()
    }

    function cancelHide() {
        hideTimer.stop()
    }

    function scheduleHide() {
        hideTimer.start()
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onEntered: {
            trigger.triggerHovered = true
            hideTimer.stop()
            showTimer.start()
        }

        onExited: {
            trigger.triggerHovered = false
            showTimer.stop()
            hideTimer.start()
        }
    }
}
