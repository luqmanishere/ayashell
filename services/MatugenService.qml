import QtQuick
import Quickshell.Io

Item {
    id: service

    property var shell
    property var colors: ({})
    property bool isLoaded: false
    property int colorVersion: 0

    signal matugenColorsUpdated
    signal matugenColorsLoaded

    FileView {
        id: matugenFile
        path: "/home/luqman/.config/quickshell/colors.qml"
        blockWrites: true
        watchChanges: true

        onLoaded: {
            console.log("MatugenService: Colors file loaded, parsing...");
            service.parseColors(matugenFile.text());
            service.matugenColorsLoaded();
        }

        onFileChanged: {
            console.log("MatugenService: Colors file changed, reloading...");
            service.reloadColors();
        }
    }

    function parseColors(qmlText) {
        if (!qmlText) {
            console.warn("Matugen Service: No QML to process");
        }

        const lines = qmlText.split('\n');
        const parsedColors = {};

        // extract readonly color definitions
        for (const line of lines) {
            const match = line.match(/readonly\s+property\s+color\s+(\w+):\s*"(#[0-9a-fA-F]{6})"/);
            if (match) {
                const colorName = match[1];
                const colorValue = match[2];
                parsedColors[colorName] = colorValue;
            }
        }

        const surfaceColor = parsedColors.surface || "#000000";
        const isLightTheme = getLuminance(surfaceColor) > 0.5;

        console.log(`MatugenService: Detected ${isLightTheme ? 'light' : 'dark'} theme from surface color: ${surfaceColor}]`);

        colors = {
            raw: parsedColors
        };

        isLoaded = true;
        colorVersion++;

        console.log("MatugenService: Colors loaded successfully from QML (version " + colorVersion + ")");
    }

    // Calculate luminance of a hex color
    function getLuminance(hexColor) {
        // Remove # if present
        const hex = hexColor.replace('#', '');

        // Convert to RGB
        const r = parseInt(hex.substr(0, 2), 16) / 255;
        const g = parseInt(hex.substr(2, 2), 16) / 255;
        const b = parseInt(hex.substr(4, 2), 16) / 255;

        // Calculate relative luminance
        const rs = r <= 0.03928 ? r / 12.92 : Math.pow((r + 0.055) / 1.055, 2.4);
        const gs = g <= 0.03928 ? g / 12.92 : Math.pow((g + 0.055) / 1.055, 2.4);
        const bs = b <= 0.03928 ? b / 12.92 : Math.pow((b + 0.055) / 1.055, 2.4);

        return 0.2126 * rs + 0.7152 * gs + 0.0722 * bs;
    }

    // Reload colors from file
    function reloadColors() {
        matugenFile.reload();
        service.matugenColorsUpdated();
    }

    // Get specific color by name
    function getColor(colorName) {
        return colors.raw ? colors.raw[colorName] : null;
    }

    // Check if matugen colors are available
    function isAvailable() {
        return isLoaded && colors.raw && Object.keys(colors.raw).length > 0;
    }

    Timer {
        interval: 10000
        running: true
        repeat: true

        // onTriggered: parent.reloadColors()
    }

    Component.onCompleted: {
        console.log("MatugenService: Initialized, watching quickshell-colors.qml");
    }
}
