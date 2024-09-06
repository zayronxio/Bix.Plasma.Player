import QtMultimedia
import QtQuick 2.4
import QtCore

Item {

    property int countFilesAnalyzed: 0
    property int prevfilesAnalyzed: 0
    property ListModel baseModel: []
    property alias tracksModel: tracks
    property alias tracksUpdateModel: updateTracks
    property bool waitingMetaData: false
    property bool updateList: false
    property int retrysMax: 0
    property bool observer: fakePlayer.mediaStatus === 5

    signal metaDataOfFilesAnd

    Settings {
        id: bixMetadConfg
        category: "BixMetadConfg"
        // property var files: []
    }

    Settings {
        id: bixConf
        category: "BixConf"
        // property var files: []
    }

    ListModel {
        id: tracks
    }

    ListModel {
        id: updateTracks
    }

    MediaPlayer {
        id: fakePlayer
        autoPlay: false
        source: baseModel.get(0).filePath
        audioOutput: AudioOutput {
            id: dynamicaudioOt
            muted: false
        }

        onPlaybackStateChanged: {
            if (!waitingMetaData) {
                if (observer) {
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
        if ((updateList ? updateTracks.count : tracks.count) === countFilesAnalyzed) {
            waitingMetaData = true
            if (fakePlayer.mediaStatus !== 2 && fakePlayer.mediaStatus !== 1 ) {

                console.log("Media status is valid. LoadingMedia	The media is currently being loaded.")

                if (fakePlayer.mediaStatus === MediaPlayer.BufferedMedia) {
                    var metaData = fakePlayer.metaData
                    console.log("Media in BufferedMedia status")
                    if (!metaData.isEmpty()) {

                        var title = metaData.stringValue("0") || "Unknown Title"
                        var album = metaData.stringValue("18") || "Unknown Album"
                        var albumArtist = metaData.stringValue("19")
                        var contributingArtist = metaData.stringValue("20")
                        var finalArtist = albumArtist || contributingArtist || "Unknown Artist"
                        var finalDates = "[" + model.get(countFilesAnalyzed).fileName + "],[" + title + "],[" + album + "],[" + finalArtist +"],["+ model.get(countFilesAnalyzed).filePath +"],["+ "false" + "]"
                        if (updateList) {
                            console.log("verificaciones")
                            updateTracks.append({
                                filePath: model.get(countFilesAnalyzed).filePath,
                                title: title,
                                album: album,
                                artist: finalArtist,
                                fileName: model.get(countFilesAnalyzed).fileName,
                                isFavorite: "false"
                            })
                            bixMetadConfg.setValue(countFilesAnalyzed + prevfilesAnalyzed, finalDates)
                            countFilesAnalyzed += 1
                            console.log("Data was added successfully")
                        } else {
                            tracks.append({
                                filePath: model.get(countFilesAnalyzed).filePath,
                                          title: title,
                                          album: album,
                                          artist: finalArtist,
                                          fileName: model.get(countFilesAnalyzed).fileName,
                                          isFavorite: "false"
                            })
                            bixMetadConfg.setValue(countFilesAnalyzed, finalDates)
                            countFilesAnalyzed += 1
                            console.log("Data was added successfully")

                        }

                        if (fakePlayer.mediaStatus !== 5) {
                            //fakePlayer.stop()
                            processorNextFile.start()
                            console.log("Started processorNextFile", fakePlayer.mediaStatus, fakePlayer.error, fakePlayer.playbackState, fakePlayer.error, fakePlayer.bufferProgress, fakePlayer.activeAudioTrack, fakePlayer.hasAudio, fakePlayer.position, fakePlayer.source, fakePlayer.duration, fakePlayer.seekable, fakePlayer.activeAudioTrack, fakePlayer.metaData,  )
                        } else {
                            console.log("An unknown error occurred")
                            forcedWaitNext.start()
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
            if (fakePlayer.mediaStatus !== 5) {
                //fakePlayer.stop()
                processorNextFile.start()
                console.log("Started processorNextFile", fakePlayer.mediaStatus, fakePlayer.error, fakePlayer.playbackState, fakePlayer.error, fakePlayer.bufferProgress, fakePlayer.activeAudioTrack, fakePlayer.hasAudio, fakePlayer.position, fakePlayer.source, fakePlayer.duration, fakePlayer.seekable, fakePlayer.activeAudioTrack, fakePlayer.metaData,  )
            } else {
                console.log("An unknown error occurred")
                forcedWaitNext.start()
            }
        }
    }
    Timer {
        id:forcedWaitNext
        interval: 20
        running: false
        repeat: false
        onTriggered: {
            if (fakePlayer.mediaStatus !== 5) {
                console.log("stagnation resolved")
                processorNextFile.start()
                retrysMax = 0
            } else {
                retrysMax = retrysMax + 1
                if (retrysMax > 3) {
                    retrysMax = 0
                    console.log("pauses to try to end the stalemate without breaking the player")
                    fakePlayer.pause()
                    processorNextFile.start()
                } else {
                    console.log("waiting for the stalemate to end, code ", fakePlayer.mediaStatus)
                    forcedWaitNext.start()
                }

            }

        }
    }
    Timer {
        id: forcedWait
        interval: 10
        running: false
        repeat: false
        onTriggered: {
            if (!fakePlayer.playing) {
                fakePlayer.play()
            }
            console.log("Metadata extraction function executed")
            generatorTWO(baseModel)
        }
    }

    function detonator() {
        processorNextFile.start()
    }

    Timer {
        id: processorNextFile
        interval: 1
        running: false
        repeat: false
        onTriggered: {
            if (!(fakePlayer.mediaStatus === 5)) {
                if (countFilesAnalyzed < baseModel.count) {
                    waitingMetaData = false
                    processorNextFile.interval = 1
                    console.log("Attempting to add a new file")
                    fakePlayer.source = baseModel.get(countFilesAnalyzed).filePath
                    console.log("File added successfully", baseModel.count)
                    fakePlayer.play()
                    console.log("Play started successfully", fakePlayer.mediaStatus, fakePlayer.error, fakePlayer.playbackState, fakePlayer.error, fakePlayer.bufferProgress, fakePlayer.activeAudioTrack, fakePlayer.hasAudio, fakePlayer.position, fakePlayer.source, fakePlayer.duration, fakePlayer.seekable, fakePlayer.activeAudioTrack, fakePlayer.metaData)
                } else {
                    console.log("All files have been processed")
                    stop()
                    fakePlayer.stop()
                    forcedWait.stop()
                        bixConf.setValue("filesMetadatesLoaded", countFilesAnalyzed + prevfilesAnalyzed)
                        bixConf.setValue("extractedMetadata", true)
                        metaDataOfFilesAnd()
                }
            } else {
                processorNextFile.interval = processorNextFile.interval < 500 ? processorNextFile.interval * 2 : 1000
                console.log("An unknown error occurred, attempting to resolve it")
                fakePlayer.stop()
                processorNextFile.start()
            }
        }
    }
}
