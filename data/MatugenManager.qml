pragma Singleton

import QtQuick

QtObject {
    property var service: null

    readonly property var rawColors: service?.colors?.raw || ({})

    function setService(matugenService) {
        service = matugenService;
        console.log("MatugenManager: Service Registered");
    }

    function reloadColors() {
        if (service && service.reloadColors) {
            console.log("MatugenManager: Color reload triggered.");
            service.reloadColors();
            return true;
        } else {
            console.error("MatugenManager: No service is available for reload");
            return false;
        }
    }

    function isAvailable() {
        return service !== null;
    }
}
