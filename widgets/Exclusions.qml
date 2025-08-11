// this is taken from caelestia
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.widgets
import qs.config

Scope {
    id: root

    required property ShellScreen screen
    required property Item bar

    ExclusionZone {
        anchors.left: true
        exclusiveZone: root.bar.exclusiveZone
    }

    ExclusionZone {
        anchors.top: true
    }

    ExclusionZone {
        anchors.right: true
    }

    ExclusionZone {
        anchors.bottom: true
    }

    component ExclusionZone: StyledWindow {
        screen: root.screen
        name: "border-exclusive"
        exclusiveZone: Appearance.padding.normal
        mask: Region {}
        implicitWidth: 1
        implicitHeight: 1
    }
}
