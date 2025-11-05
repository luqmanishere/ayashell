// this is taken from caelestia
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.widgets
import qs.config

Scope {
    id: root

    required property ShellScreen screen
    required property LeftBar bar
    required property Borders borders

    ExclusionZone {
        anchors.left: true
        exclusiveZone: root.bar.exclusiveZone
    }

    ExclusionZone {
        anchors.top: true
        exclusiveZone: root.borders.exclusiveZone
    }

    ExclusionZone {
        anchors.right: true
        exclusiveZone: root.borders.exclusiveZone
    }

    ExclusionZone {
        anchors.bottom: true
        exclusiveZone: root.borders.exclusiveZone
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
