import QtMultimedia
import QtQuick 2.4

Item {

    property int countFilesAnalyzed: 0
    property ListModel baseModel: []
    property alias tracksModel: tracks
    property bool waitingMetaData: false

    ListModel {
        id: tracks
    }

    MediaPlayer {
        id: fakePlayer
        autoPlay: false
        source: baseModel.get(0).filePath
        audioOutput: AudioOutput {
            id: dynamicaudioOt
            muted: true
        }

        onPlaybackStateChanged: {
            if (!waitingMetaData) {
                if (fakePlayer.mediaStatus === 5) {
                    console.log("An issue occurred while loading the file", "status player Stalled")
                    waitingMetaData = true
                    fakePlayer.stop()
                    forcedWait.start()
                } else {
                    console.log("Metadata extraction function executed")
                    generatorTWO(baseModel)
                }
            }
        }
    }

    function generatorTWO(model) {
        if (tracks.count === countFilesAnalyzed) {
            waitingMetaData = true
            if (fakePlayer.mediaStatus !== MediaPlayer.InvalidMedia &&
                fakePlayer.mediaStatus !== MediaPlayer.LoadingMedia &&
                fakePlayer.mediaStatus !== MediaPlayer.StalledMedia &&
                fakePlayer.mediaStatus !== MediaPlayer.NoMedia) {

                console.log("Media status is valid")

                if (fakePlayer.mediaStatus === MediaPlayer.BufferedMedia) {
                    var metaData = fakePlayer.metaData
                    console.log("Media in BufferedMedia status")
                    if (!metaData.isEmpty()) {

                        var title = metaData.stringValue("0") || "Unknown Title"
                        var album = metaData.stringValue("18") || "Unknown Album"
                        var albumArtist = metaData.stringValue("19")
                        var contributingArtist = metaData.stringValue("20")
                        var finalArtist = albumArtist || contributingArtist || "Unknown Artist"

                        tracks.append({
                            filePath: model.get(countFilesAnalyzed).filePath,
                                      title: title,
                                      album: album,
                                      artist: finalArtist,
                                      fileName: model.get(countFilesAnalyzed).fileName
                        })

                        countFilesAnalyzed += 1
                        console.log("Data was added successfully")

                        if (fakePlayer.error === MediaPlayer.NoError) {
                            processorNextFile.start()
                            console.log("Started processorNextFile")
                        } else {
                            console.log("An unknown error occurred")
                            forcedWait.start()
                        }

                    } else {
                        console.log("Metadata is not loaded yet")
                    }
                } else {
                    console.log("A buffer error occurred")
                    forcedWait.start()
                        console.log("Timer started to retry")
                }
                } else {
                    console.log("Error in media status verification")
                    forcedWait.start()
                        console.log("Timer started to retry")
                }
        } else {
            console.log("This file has already been added")
        }
    }

    Timer {
        id: forcedWait
        interval: 100
        running: false
        repeat: false
        onTriggered: {
            console.log("Metadata extraction function executed")
            generatorTWO(baseModel)
        }
    }

    function detonator() {
        processorNextFile.start()
    }

    Timer {
        id: processorNextFile
        interval: 50
        running: false
        repeat: false
        onTriggered: {
            if (fakePlayer.error === MediaPlayer.NoError) {
                if (countFilesAnalyzed < baseModel.count) {
                    waitingMetaData = false
                    console.log("Attempting to add a new file")
                    fakePlayer.source = baseModel.get(countFilesAnalyzed).filePath
                    console.log("File added successfully")
                    fakePlayer.play()
                    console.log("Play started successfully")
                } else {
                    console.log("All files have been processed")
                    stop()
                    fakePlayer.stop()
                    forcedWait.stop()
                }
            } else {
                console.log("An unknown error occurred, attempting to resolve it")
                fakePlayer.stop()
                processorNextFile.start()
            }
        }
    }
}




