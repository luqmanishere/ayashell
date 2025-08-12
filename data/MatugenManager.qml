pragma Singleton

import QtQuick

QtObject {
    property var service: null

    readonly property var raw_colors: service?.colors?.raw || fallback_colors

    // Fallback colors for when MatugenService is unavailable
    readonly property var fallback_colors: ({
            "background": "#101417",
            "primary": "#92cef5",
            "primary_container": "#004c6c",
            "on_primary": "#00344c",
            "on_primary_container": "#c7e7ff",
            "secondary": "#b6c9d8",
            "secondary_container": "#374955",
            "on_secondary": "#21323e",
            "on_secondary_container": "#d2e5f5",
            "tertiary": "#ccc1e9",
            "tertiary_container": "#4a4263",
            "on_tertiary_container": "#e8ddff",
            "surface": "#101417",
            "surface_variant": "#41484d",
            "on_surface": "#dfe3e7",
            "outline": "#8b9198",
            "error": "#ffb4ab"
        })

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
