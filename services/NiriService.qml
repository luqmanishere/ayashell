pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property ListModel workspaces_list: ListModel {}
    property var workspaces_map: ({})

    property ListModel windows_list: ListModel {}
    property var windows_map: ({})

    property ListModel keyboardLayouts: ListModel {}
    property bool overview
    property int currentWorkspace: -1
    property bool isDestroying: false

    signal workspaceChanged(int workspaceId)

    Process {
        id: niriJSONProcess
        command: ["niri", "msg", "-j", "event-stream"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                const lines = data.split('\n');
                for (const line of lines) {
                    if (line.trim()) {
                        parseNiriJSON(line.trim());
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

    function parseNiriJSON(line) {
        const json = JSON.parse(line);

        // the logic is a reimplementation of niri's ipc crate
        if (json.WorkspacesChanged) {
            // when this event is received, this is the complete current state of workspaces
            // just add it directly
            const data = json.WorkspacesChanged.workspaces;
            // console.log(JSON.stringify(data));
            const newWorkspaces = [];
            for (const workspace of data) {
                const new_workspace = {
                    id: workspace.id,
                    idx: workspace.idx,
                    name: workspace.name,
                    output: workspace.output,
                    is_active: workspace.is_active,
                    is_focused: workspace.is_focused,
                    is_urgent: workspace.is_urgent,
                    active_window_id: workspace.active_window_id
                };

                newWorkspaces.push(new_workspace);

                // if (workspace.isFocused) {
                //     root.currentWorkspace = workspace.id;
                // }
            }
            // idk how to sort listmodels
            newWorkspaces.sort((a, b) => a.idx - b.idx);

            clearWorkspaces();
            for (const workspace of newWorkspaces) {
                addWorkspace(workspace.id, workspace);
            }

            // console.log("NIRI: Workspaces changed: " + JSON.stringify(root.workspaces_map));
            console.log("NIRI: Workspaces changed.");
        } else if (json.WorkspaceUrgencyChanged) {
            const data = json.WorkspaceUrgencyChanged;
            forEachWorkspace(function (ws_id, list_ws, map_ws, index) {
                if (ws_id == data.id) {
                    list_ws.is_urgent = data.urgent;
                    map_ws.is_urgent = data.urgent;
                }
            });

            console.log(`NIRI: Urgency changed: Workspace ${data.id} set to ${data.urgent}`);
        } else if (json.WorkspaceActivated) {
            const data = json.WorkspaceActivated;
            const output = root.workspaces_map[data.id].output;

            forEachWorkspace(function (ws_id, list_ws, map_ws, index) {
                const got_activated = ws_id == data.id;
                if (list_ws.output === output && map_ws.output === output) {
                    list_ws.is_active = got_activated;
                    map_ws.is_active = got_activated;
                    if (got_activated) {
                        console.log(`NIRI: Workspace ${list_ws.id} on output ${list_ws.output} activation status: ${got_activated}`);
                    }
                }

                if (data.focused) {
                    map_ws.is_focused = got_activated;
                    list_ws.is_focused = got_activated;
                }
            });
        } else if (json.WorkspaceActiveWindowChanged) {
            const data = json.WorkspaceActiveWindowChanged;
            const workspace_id = data.workspace_id;
            const active_window_id = data.active_window_id;

            var ws = root.workspaces_map[workspace_id];
            ws.active_window_id = active_window_id;
            updateWorkspace(workspace_id, ws);
            console.log(`NIRI: Window ${ws.active_window_id} is active on workspace ${ws.id} `);
        } else

        // windows
        if (json.WindowsChanged) {
            const data = json.WindowsChanged.windows;
            for (const window of data) {
                const new_window = {
                    id: window.id,
                    title: window.title,
                    app_id: window.app_id,
                    pid: window.pid,
                    workspace_id: window.workspace_id,
                    is_focused: window.is_focused,
                    is_floating: window.is_floating,
                    is_urgent: window.is_urgent
                };

                root.windows_map[window.id] = new_window;
            }
            // console.log("NIRI: Windows changed: " + JSON.stringify(root.windows_map));
            console.log("NIRI: Windows changed.");
        } else if (json.WindowOpenedOrChanged) {
            const window = json.WindowOpenedOrChanged.window;
            const new_window = {
                id: window.id,
                title: window.title,
                app_id: window.app_id,
                pid: window.pid,
                workspace_id: window.workspace_id,
                is_focused: window.is_focused,
                is_floating: window.is_floating,
                is_urgent: window.is_urgent
            };

            root.windows_map[window.id] = new_window;

            if (window.is_focused) {
                for (var win in root.windows_map) {
                    if (win.id !== new_window.id) {
                        win.is_focused = false;
                        root.windows_map[win.id] = win;
                    }
                }
            }
            console.log(`NIRI: Window ${new_window.id} changed`);
        } else if (json.WindowClosed) {
            const window_id = json.WindowClosed.id;
            root.workspaces_map[window_id] = null;
            console.log(`NIRI: Window ${window_id} closed`);
        } else if (json.WindowFocusChanged) {
            const window_id = json.WindowFocusChanged.id;
            for (var win in root.windows_map) {
                win.is_focused = window_id === win.id;
                root.windows_map[win.id] = win;
            }
            console.log(`NIRI: Focused window ${window_id}`);
        } else {
            console.warn(`NIRI: Unimplemented event: ${line}`);
        }
    }

    function addWorkspace(workspace_id, workspace) {
        root.workspaces_list.append({
            workspace_id: workspace_id,
            workspace: workspace
        });
        root.workspaces_map[workspace_id] = workspace;
    }

    function removeWorkspace(workspace_id) {
        const list = root.workspaces_list;
        // remove from list model
        for (var i = 0; i < root.workspaces_list.count; ++i) {
            if (list.get(i).workspace_id === workspace_id) {
                list.remove(i);
                break;
            }
        }
        //remove from map
        delete root.workspaces_map[workspace_id];
    }

    function updateWorkspace(workspace_id, workspace) {
        const list = root.workspaces_list;
        for (var i = 0; i < list.count; ++i) {
            if (list.get(i).workspace_id === workspace_id) {
                list.set(i, workspace);
                break;
            }
        }
        root.workspaces_map[workspace_id] = workspace;
    }

    function clearWorkspaces() {
        root.workspaces_list.clear();
        root.workspaces_map = ({});
    }

    function forEachWorkspace(callback) {
        for (var i = 0; i < root.workspaces_list.count; ++i) {
            var item = root.workspaces_list.get(i);
            var key = item.workspace_id;
            var list_value = item.workspace;
            var mapValue = root.workspaces_map[key];

            callback(key, list_value, mapValue, i);
            root.workspaces_list.set(i, {
                workspace_id: key,
                workspace: mapValue
            });
        }
    }
}
