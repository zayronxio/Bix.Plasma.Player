import QtQuick
import QtWebEngine
import org.kde.kirigami as Kirigami

Item {
    id: root

    property bool autoplayEnabled: true //plasmoid.configuration.allowAutoplay

    property var qimage
    property url coverArtUrl
    property string currentTitle
    property string currentArtist
    property string currentAlbum

    signal newMetadata(string title, string artist, string album, string art)

    signal nextMpris
    signal playPauseMpris
    signal stopMpris
    signal prevMpris

    Kirigami.Icon {
        id: art
        width: 512
        height: 512
        source: qimage
        visible: false
    }

    function captureQImageToWeb() {
        art.grabToImage(function(result) {

            if (result) {

                var tmpPath = Qt.resolvedUrl("cover_tmp.png").toString().replace("file://", "")
                result.saveToFile(tmpPath)
                coverArtUrl = "file://" + tmpPath

                console.log("✅ Imagen guardada temporalmente:", coverArtUrl)

                updateMetadata(currentTitle, currentArtist, currentAlbum, coverArtUrl)
            } else {
                console.error("❌ No se pudo capturar la imagen");
            }
        });
    }

    onQimageChanged: {
        if (qimage) {
            console.log("QImage asignada, capturando...")
            Qt.callLater(captureQImageToWeb)
        } else {
            console.log("No hay imagen, se limpiará carátula en HTML.")
            updateMetadata(currentTitle, currentArtist, currentAlbum, "")
        }
    }

    onNewMetadata: {
        // Mandar solo los textos de inmediato
        currentTitle = title
        currentArtist = artist
        currentAlbum = album
        updateMetadata(title, artist, album, "")
    }

    function handleMediaAction(action) {
        console.log("QML recibió la acción:", action);
        switch (action) {
            case "play": playPauseMpris(); break;
            case "pause": playPauseMpris(); break;
            case "nexttrack": nextMpris(); break;
            case "previoustrack": prevMpris(); break;
            default: console.log("QML: Acción no manejada:", action);
        }
    }

    WebEngineView {
        id: webView
        visible: false
        anchors.fill: parent

        url: Qt.resolvedUrl("html/index.html")

        settings.playbackRequiresUserGesture:!autoplayEnabled

        // Captura todos los console.log del HTML
        onJavaScriptConsoleMessage: {
            if (message.startsWith("QML_ACTION:")) {
                var action = message.split(":")[1];
                root.handleMediaAction(action);
            }
        }
    }

    function updateMetadata(title, artist, album, cover) {
        const escapedTitle = JSON.stringify(title)
        const escapedArtist = JSON.stringify(artist)
        const escapedAlbum = JSON.stringify(album)
        const escapedCover = JSON.stringify(cover)

        webView.runJavaScript(
            `updateMediaMetadata(${escapedTitle}, ${escapedArtist}, ${escapedAlbum}, ${escapedCover});`
        )

    }

}


