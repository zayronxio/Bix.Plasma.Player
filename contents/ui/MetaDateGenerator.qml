import QtMultimedia
import QtQuick 2.4

Item {
    id: container

    property string globalMetaData: "" // Variable global para almacenar el valor obtenido

    MediaPlayer {
        id: fakePlayer
        audioOutput: AudioOutput {
            id: audioOutput
            volume: 0
        }
    }


    function generetor(file, cod, callback) {
        fakePlayer.source = file;
        fakePlayer.play();

        fakePlayer.onPlaybackStateChanged.connect(function() {
            if (fakePlayer.playbackState === MediaPlayer.PlayingState) {
                var metaData = fakePlayer.metaData;

                if (!metaData.isEmpty()) {
                    var value = metaData.stringValue(cod); // Obtén el valor deseado del metadato
                    callback(value); // Llama al callback con el valor obtenido
                    console.log("Metadato obtenido:", value);
                } else {
                    callback(null); // Si no hay metadatos, devuelve null
                }

                fakePlayer.stop(); // Deten el reproductor después de obtener los metadatos
            }
        });
    }


}
