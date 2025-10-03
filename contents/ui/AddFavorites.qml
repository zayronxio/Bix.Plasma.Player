import QtQuick
import QtCore

Item {

    Settings {
        id: bixMetadConfg
        category: "BixMetadConfg"
    }

    Settings {
        id: bixConf
        category: "BixConf"
    }

    function extractTextInBrackets(str) {
        var regex = /\[(.*?)\](?=\s*,|\s*$)/g;
        var results = [];
        var match;
        while ((match = regex.exec(str)) !== null) {
            results.push(match[1].trim());
        }
        return results;
    }

    function setFavorite(fileUrl, model, value) {
        // Actualizar modelo
        for (var i = 0; i < model.count; i++) {
            if (model.get(i).filePath === fileUrl.toString()) {
                model.setProperty(i, "isFavorite", value);
                break;
            }
        }

        // Actualizar Settings
        for (var y = 0; y < parseFloat(bixConf.value("filesMetadatesLoaded")); y++) {
            var matches = extractTextInBrackets(bixMetadConfg.value(y));
            if (matches[4] === fileUrl.toString()) {
                matches[5] = value;
                bixMetadConfg.setValue(y, matches.map(m => "[" + m + "]").join(","));
                break;
            }
        }
    }


    function add(fileUrl, model) { setFavorite(fileUrl, model, "true"); }
    function remove(fileUrl, model) { setFavorite(fileUrl, model, "false"); }
}
