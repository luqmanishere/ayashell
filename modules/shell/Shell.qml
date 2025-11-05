pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.widgets
import qs.config

Scope {
    id: scope
    required property var shell
    required property var notificationHistoryWin

    Variants {
        model: Quickshell.screens

        StyledWindow {
            id: win

            required property ShellScreen modelData
            screen: modelData

            implicitWidth: Screen.width
            implicitHeight: Screen.width
            color: "transparent"

            name: "shell"
            // WlrLayershell.exclusionMode: ExclusionMode.Ignore
            exclusionMode: ExclusionMode.Ignore

            anchors.top: true
            anchors.left: true
            anchors.bottom: true
            anchors.right: true

            mask: Region {
                regions: [
                    Region {
                        item: bar
                    },
                    Region {
                        item: borders.topBorder
                    },
                    Region {
                        item: borders.rightBorder
                    },
                    Region {
                        item: borders.bottomBorder
                    },
                    Region {
                        item: topPopupTrigger
                    }
                ]
            }

            Borders {
                id: borders
                anchors.fill: parent
                z: 0
                bar: bar
            }

            // TODO: left bar
            LeftBar {
                id: bar
                shell: scope.shell
                screen: win.screen
                z: 1

                property var notificationHistoryWin: scope.notificationHistoryWin
            }

            TopPopupTrigger {
                id: topPopupTrigger
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter

                triggerWidth: Appearance.topPopup.triggerWidth
                triggerHeight: Appearance.topPopup.triggerHeight
                showDelay: Appearance.topPopup.showDelay

                z: 2

                onShowPopup: topPopup.shouldShow = true
                onHidePopup: topPopup.shouldShow = false
            }

            TopPopup {
                id: topPopup
                screen: win.screen
                anchors.top: true

                popupWidth: Appearance.topPopup.popupWidth
                popupHeight: Appearance.topPopup.popupHeight

                onMouseEntered: topPopupTrigger.cancelHide()
                onMouseExited: topPopupTrigger.scheduleHide()
            }

            Exclusions {
                bar: bar
                screen: win.modelData
                borders: borders
            }
        }
    }
}
