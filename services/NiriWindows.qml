import QtQuick

QtObject {
    property int id
    property string title
    property string app_id
    property int pid
    property int workspace_id
    property bool is_focused
    property bool is_floating
    property bool is_urgent

    function newWindow(oldedn, old) {
    }
}
