pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    property ListModel workspaces: ListModel {}
    property int currentWorkspace: -1
    property bool isDestroying: false

    signal workspaceChanged(int workspaceId)

    property real masterProgress: 0.0
    property bool effectsActive: false
    property color effectColor: "blue"

    function triggerUnifiedWave() {
        effectColor = "blue";
        masterAnimation.restart();
    }

    SequentialAnimation {
        id: masterAnimation

        PropertyAction {
            target: root
            property: "effectsActive"
            value: true
        }

        NumberAnimation {
            target: root
            property: "masterProgress"
            from: 0.0
            to: 1.0
            duration: 1000
            easing.type: Easing.OutQuint
        }

        PropertyAction {
            target: root
            property: "effectsActive"
            value: false
        }

        PropertyAction {
            target: root
            property: "masterProgress"
            value: 0.0
        }
    }

    color: "black"
    // width: 32
    implicitHeight: workspaceColumn.implicitHeight + 24

    // Smooth height animation
    Behavior on height {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    topRightRadius: width / 2
    bottomRightRadius: width / 2
    topLeftRadius: width / 2
    bottomLeftRadius: width / 2

    Process {
        id: niriProcess
        command: ["niri", "msg", "event-stream"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                const lines = data.split('\n');
                for (const line of lines) {
                    if (line.trim()) {
                        root.parseNiriEvent(line.trim());
                    }
                }
            }
        }

        onExited: function (exitCode) {
            if (exitCode !== 0 && !root.isDestroying) {
                Qt.callLater(() => running = true);
            }
        }
    }

    Process {
        id: niriJSONProcess
        command: ["niri", "msg", "-j", "event-stream"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                const lines = data.split('\n');
                for (const line of lines) {
                    if (line.trim()) {
                        root.parseNiriJSON(line.trim());
                    }
                }
            }
        }

        onExited: {
            if (exitCode !== 0 && !root.isDestroying) {
                Qt.callLater(() => running = true);
            }
        }
    }

    property var workspace_active_window: ({})
    property ListModel workspacesv2: ListModel {}
    property int focused_window: 0

    function parseNiriJSON(line) {
        const json = JSON.parse(line);
        if (json.WindowFocusChanged) {
            const focused_window = json.WindowFocusChanged.id;
            this.focused_window = focused_window;
            console.log("NIRI: Focused window: " + this.focused_window);
        } else if (json.WorkspaceActiveWindowChanged) {
            var workspace_id = json.WorkspaceActiveWindowChanged.workspace_id;
            var active_id = json.WorkspaceActiveWindowChanged.active_window_id;
            this.workspace_active_window[workspace_id] = active_id;
            console.log("NIRI: Active windows in workspaces: " + JSON.stringify(this.workspace_active_window));
        } else if (json.WorkspaceActivated) {
            console.log(line);
        } else if (json.WorkspacesChanged) {
            const data = json.WorkspacesChanged.workspaces;
            console.log(JSON.stringify(data));
            const newWorkspaces = [];
            for (const workspace of data) {
                const new_workspace = {
                    id: workspace.id,
                    idx: workspace.idx,
                    name: workspace.name,
                    output: workspace.output,
                    isActive: workspace.is_active,
                    isFocused: workspace.is_focused,
                    isUrgent: workspace.is_urgent
                };

                newWorkspaces.push(new_workspace);

                // if (workspace.isFocused) {
                //     root.currentWorkspace = workspace.id;
                // }
            }
            newWorkspaces.sort((a, b) => a.idx - b.idx);
            root.workspaces.clear();
            root.workspaces.append(newWorkspaces);
            console.log(JSON.stringify(newWorkspaces));
        } else if (json.WindowsChanged) {} else if (json.OverviewOpenedOrClosed) {} else if (json.KeyboardLayoutsChanged) {} else {
            console.log(line);
        }
    }

    function parseNiriEvent(line) {
        try {
            // workspace focus changes
            if (line.startsWith("Workspace focused: ")) {
                const workspaceId = parseInt(line.replace("Workspace focused: ", ""));
                if (!isNaN(workspaceId)) {
                    const previousWorkspace = root.currentWorkspace;
                    root.currentWorkspace = workspaceId;
                    updateWorkspaceFocus(workspaceId);

                    if (previousWorkspace !== workspaceId && previousWorkspace !== -1) {
                        root.workspaceChanged(workspaceId);
                    }
                }
            } else if (line.startsWith("Workspaces changed: ")) {
                const workspaceData = line.replace("Workspaces changed: ", "");
                parseWorkspaceList(workspaceData);
            }
        } catch (e) {
            console.log("Error parsing niri event: ", e);
        }
    }

    // update workspace focus states
    function updateWorkspaceFocus(focusedWorkspaceId) {
        for (let i = 0; i < root.workspaces.count; i++) {
            const workspace = root.workspaces.get(i);
            const wasFocused = workspace.isFocused;
            const isFocused = workspace.id === focusedWorkspaceId;
            const isActive = workspace.id === focusedWorkspaceId;

            // Only update changed properties to trigger animations
            if (wasFocused !== isFocused) {
                root.workspaces.setProperty(i, "isFocused", isFocused);
                root.workspaces.setProperty(i, "isActive", isActive);
            }
        }
    }

    // Parse workspace data from Niri's Rust-style output format
    function parseWorkspaceList(data) {
        try {
            const workspaceMatches = data.match(/Workspace \{[^}]+\}/g);
            if (!workspaceMatches) {
                return;
            }

            const newWorkspaces = [];

            for (const match of workspaceMatches) {
                const idMatch = match.match(/id: (\d+)/);
                const idxMatch = match.match(/idx: (\d+)/);
                const nameMatch = match.match(/name: Some\("([^"]+)"\)|name: None/);
                const outputMatch = match.match(/output: Some\("([^"]+)"\)/);
                const isActiveMatch = match.match(/is_active: (true|false)/);
                const isFocusedMatch = match.match(/is_focused: (true|false)/);
                const isUrgentMatch = match.match(/is_urgent: (true|false)/);

                if (idMatch && idxMatch && outputMatch) {
                    const workspace = {
                        id: parseInt(idMatch[1]),
                        idx: parseInt(idxMatch[1]),
                        name: nameMatch && nameMatch[1] ? nameMatch[1] : "",
                        output: outputMatch[1],
                        isActive: isActiveMatch ? isActiveMatch[1] === "true" : false,
                        isFocused: isFocusedMatch ? isFocusedMatch[1] === "true" : false,
                        isUrgent: isUrgentMatch ? isUrgentMatch[1] === "true" : false
                    };

                    newWorkspaces.push(workspace);

                    if (workspace.isFocused) {
                        root.currentWorkspace = workspace.id;
                    }
                }
            }

            // Sort by index and update model
            newWorkspaces.sort((a, b) => a.idx - b.idx);
            root.workspaces.clear();
            root.workspaces.append(newWorkspaces);
        } catch (e) {
            console.log("Error parsing workspace list:", e);
        }
    }

    // Vertical workspace indicator pills
    Column {
        id: workspaceColumn
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: root.workspaces

            Rectangle {
                id: workspacePill

                required property var model

                // Dynamic sizing based on focus state
                width: model.isFocused ? 18 : 16
                height: model.isFocused ? 36 : 22
                radius: width / 2
                scale: model.isFocused ? 1.0 : 0.9

                // Material Design 3 inspired colors
                color: {
                    if (model.isFocused) {
                        return "purple";
                    }
                    if (model.isActive) {
                        return Qt.rgba("red", "green", "blue", 0.5);
                    }
                    if (model.isUrgent)
                    // return Data.ThemeManager.error;
                    {}
                    return Qt.rgba("red", "green", "blue", 0.4);
                }

                // Subtle pulse for inactive pills during workspace changes
                Rectangle {
                    id: inactivePillPulse
                    anchors.fill: parent
                    radius: parent.radius
                    color: "red"
                    opacity: {
                        // Only pulse inactive pills during effects
                        if (workspacePill.model.isFocused || !workspacePill.model.effectsActive)
                            return 0;

                        // More subtle pulse that peaks mid-animation
                        if (root.masterProgress < 0.3) {
                            return (root.masterProgress / 0.3) * 0.15;
                        } else if (root.masterProgress < 0.7) {
                            return 0.15;
                        } else {
                            return 0.15 * (1.0 - (root.masterProgress - 0.7) / 0.3);
                        }
                    }
                    z: -0.5  // Behind the pill content but visible
                }

                // Elevation shadow
                Rectangle {
                    anchors.fill: parent
                    anchors.topMargin: workspacePill.model.isFocused ? 1 : 0
                    anchors.leftMargin: workspacePill.model.isFocused ? 0.5 : 0
                    anchors.rightMargin: workspacePill.model.isFocused ? -0.5 : 0
                    anchors.bottomMargin: workspacePill.model.isFocused ? -1 : 0
                    radius: parent.radius
                    color: Qt.rgba(0, 0, 0, workspacePill.model.isFocused ? 0.15 : 0)
                    z: -1
                    visible: workspacePill.model.isFocused

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                }

                // Smooth Material Design transitions
                Behavior on width {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on height {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }
                }

                // Workspace number text
                Text {
                    anchors.centerIn: parent
                    text: workspacePill.model.idx.toString()
                    color: workspacePill.model.isFocused ? "black" : "white"
                    font.pixelSize: workspacePill.model.isFocused ? 10 : 8
                    font.bold: workspacePill.model.isFocused
                    font.family: "Roboto, sans-serif"
                    visible: workspacePill.model.isFocused || workspacePill.model.isActive

                    Behavior on font.pixelSize {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        // Switch workspace via Niri command
                        switchProcess.command = ["niri", "msg", "action", "focus-workspace", model.idx.toString()];
                        switchProcess.running = true;
                    }

                    // Hover feedback
                    onEntered: {
                        if (!model.isFocused) {
                            workspacePill.color = Qt.rgba("red", "green", "blue", 0.6);
                        }
                    }

                    onExited: {
                        // Reset to normal color
                        if (!model.isFocused) {
                            if (model.isActive) {
                                workspacePill.color = Qt.rgba("red", "green", "blue", 0.5);
                            } else if (model.isUrgent)
                            // workspacePill.color = Data.ThemeManager.error;
                            {} else {
                                workspacePill.color = Qt.rgba("red", "green", "blue", 0.4);
                            }
                        }
                    }
                }
            }
        }
    }

    // Workspace switching command process
    Process {
        id: switchProcess
        running: false
        onExited: {
            running = false;
            if (exitCode !== 0) {
                console.log("Failed to switch workspace:", exitCode);
            }
        }
    }

    // // Border integration corners
    // Core.Corners {
    //     id: topLeftCorner
    //     position: "topleft"
    //     size: 1.3
    //     fillColor: Data.ThemeManager.bgColor
    //     offsetX: -41
    //     offsetY: -25
    // }

    // Clean up processes on destruction
    Component.onDestruction: {
        root.isDestroying = true;

        if (niriProcess.running) {
            niriProcess.running = false;
        }
        if (switchProcess.running) {
            switchProcess.running = false;
        }
    }
}
