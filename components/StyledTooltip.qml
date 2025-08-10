import QtQuick
import QtQuick.Window 2.15
import qs.data
import qs.config

// import qs.Settings

Window {
    id: tooltipWindow
    property string text: ""
    property bool tooltipVisible: false
    property Item targetItem: null
    property int delay: 300
    property bool shift

    property bool positionAbove: true

    flags: Qt.ToolTip | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"
    visible: false

    property var _timerObj: null

    onTooltipVisibleChanged: {
        if (tooltipVisible) {
            if (delay > 0) {
                if (_timerObj) {
                    _timerObj.destroy();
                    _timerObj = null;
                }
                _timerObj = Qt.createQmlObject('import QtQuick 2.0; Timer { interval: ' + delay + '; running: true; repeat: false; onTriggered: tooltipWindow._showNow() }', tooltipWindow);
            } else {
                _showNow();
            }
        } else {
            _hideNow();
        }
    }

    function _showNow() {
        width = Math.max(50 * 1, tooltipText.implicitWidth + 24 * 1);
        height = Math.max(50 * 1, tooltipText.implicitHeight + 16 * 1);

        if (!targetItem)
            return;

        var targetWidth;
        if (shift)
            targetWidth = targetItem.width;
        else
            targetWidth = targetItem.width / 2;

        if (positionAbove) {
            // Position tooltip above the target item
            var pos = targetItem.mapToGlobal(0, 0);
            x = pos.x - width / 2 + targetWidth;
            y = pos.y - height - 12; // 12 px margin above
        } else {
            // Position tooltip below the target item
            var pos = targetItem.mapToGlobal(0, targetItem.height);
            x = pos.x - width / 2 + targetWidth;
            y = pos.y + 12; // 12 px margin below
        }
        visible = true;
    }

    function _hideNow() {
        visible = false;
        if (_timerObj) {
            _timerObj.destroy();
            _timerObj = null;
        }
    }

    Connections {
        target: tooltipWindow.targetItem
        function onXChanged() {
            if (tooltipWindow.visible)
                tooltipWindow._showNow();
        }
        function onYChanged() {
            if (tooltipWindow.visible)
                tooltipWindow._showNow();
        }
        function onWidthChanged() {
            if (tooltipWindow.visible)
                tooltipWindow._showNow();
        }
        function onHeightChanged() {
            if (tooltipWindow.visible)
                tooltipWindow._showNow();
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: MatugenManager.rawColors.secondary_container || "#222"
        border.color: MatugenManager.rawColors.outline || "#444"
        border.width: 1 * 1
        opacity: 0.97
        z: 1
    }

    Text {
        id: tooltipText
        text: tooltipWindow.text
        color: MatugenManager.rawColors.on_tertiary_container
        // font.family: Theme.fontFamil
        font.pixelSize: Appearance.font.size.small * 1
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.Wrap
        padding: 8
        z: 2
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onExited: tooltipWindow.tooltipVisible = false
        cursorShape: Qt.ArrowCursor
    }

    onTextChanged: {
        width = Math.max(minimumWidth * 1, tooltipText.implicitWidth + 24 * 1);
        height = Math.max(minimumHeight * 1, tooltipText.implicitHeight + 16 * 1);
    }
}
