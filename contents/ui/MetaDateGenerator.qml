import QtMultimedia
import QtQuick 2.4

Item {

    property int countFilesAnalyzed: 0
    property ListModel baseModel: []
    property alias tracksModel: tracks
    property bool metaLeaded: false // Currently unused
    property string gr: undefined // Currently unused
    property int timeNotchanges: 0 // Currently unused

    ListModel {
        id: tracks
    }

    MediaPlayer {
        id: fakePlayer
        autoPlay: true
        source: baseModel.get(0).filePath;
        audioOutput: AudioOutput {
            id: dynamicaudioOt
            volume: 1
        }
        onMetaDataChanged: {
            if (fakePlayer.playbackState === MediaPlayer.PlayingState) {
                processNextFile(baseModel);
            }
        }
    }

    function generator(callback) {
        if (!fakePlayer.playbackStateChanged.connected) {
            fakePlayer.onPlaybackStateChanged.connect(function() {
                if (fakePlayer.playbackState === MediaPlayer.PlayingState) {
                    var metaData = fakePlayer.metaData;

                    if (!metaData.isEmpty()) {
                        var title = metaData.stringValue("0") || "Unknown Title";
                        var album = metaData.stringValue("18") || "Unknown Album";
                        var albumArtist = metaData.stringValue("19");
                        var contributingArtist = metaData.stringValue("20");

                        var finalArtist = albumArtist || contributingArtist || "Unknown Artist";

                        callback(title, album, finalArtist);
                        console.log("Metadata obtained:", title, album, finalArtist);
                    } else {
                        callback(null, null, null);
                    }
                }
            });
        } else {
            if (fakePlayer.playbackState === MediaPlayer.PlayingState) {
                var metaData = fakePlayer.metaData;

                if (!metaData.isEmpty()) {
                    var title = metaData.stringValue("0") || "Unknown Title";
                    var album = metaData.stringValue("18") || "Unknown Album";
                    var albumArtist = metaData.stringValue("19");
                    var contributingArtist = metaData.stringValue("20");

                    var finalArtist = albumArtist || contributingArtist || "Unknown Artist";

                    callback(title, album, finalArtist);
                    console.log("Metadata obtained:", title, album, finalArtist);
                } else {
                    callback(null, null, null);
                }
            }
        }
    }

    function processNextFile(model) {
        console.log("There are", model.count, "elements in the model");
        if (tracks.count < model.count && countFilesAnalyzed === tracks.count) {
            console.log("First filter successful. FilesAnalyzed:", countFilesAnalyzed, "model contains", model.count);

            fakePlayer.source = model.get(countFilesAnalyzed).filePath;

            generator(function(titleFile, album, artist) {
                console.log("First value", titleFile, countFilesAnalyzed);

                tracks.append({
                    filePath: model.get(countFilesAnalyzed).filePath,
                              title: titleFile,
                              album: album,
                              artist: artist,
                              fileName: model.get(countFilesAnalyzed).fileName
                });
                countFilesAnalyzed = countFilesAnalyzed + 1;
                trc.start()
            });
        } else {
            trc.stop();
            fakePlayer.autoPlay = false;
            fakePlayer.stop();
            console.log("All files have been processed");
        }
    }



    Timer {
        id: trc
        interval: 400
        running: false
        repeat: false
        onTriggered: {
            if (countFilesAnalyzed < baseModel.count) {
                fakePlayer.source = baseModel.get(countFilesAnalyzed).filePath;
                fakePlayer.play();
            } else {
                stop()
                fakePlayer.stop();
            }
        }
    }
}



