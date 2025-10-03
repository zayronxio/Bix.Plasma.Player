import QtQuick
import "lib" as Lib
import QtMultimedia
import org.kde.kirigami as Kirigami

Item {
    id: root
    property ListModel origenModel: []
    property var coverTem
    property string albumName
    property string findText
    property alias newModel: resultModel
    property alias albumsModel: resultAlbumsModel
    property string typeModel // ["fullAlbums", "album", "genre", "filter", "userCustom"] // establecer el tipo de lista usando alguno de estos valores
    property string userCustomList: "" // se establece string para filtrar la lista seleccionada por el usuario
    property int index: 0
    property int indexAlbum: 0
    property var coverList: []
    property var listAlbums: []
    property var fullTracksAlbums: []
    property string finalArtist

    ListModel {
        id: resultModel
    }
    ListModel {
        id: resultAlbumsModel
    }

    signal readylist

    function buildAlbumList(album) {
        resultModel.clear()
        for (var h = 0; h < origenModel.count; h++) {
            if (origenModel.get(h).album === album) {
                resultModel.append({
                    artist: origenModel.get(h).artist,
                                   album: origenModel.get(h).album,
                                   title: origenModel.get(h).title,
                                    filePath: origenModel.get(h).filePath,
                                     isFavorite: origenModel.get(h).isFavorite
                })
            }
        }
    }

    function buildFavoritesList(){
        resultModel.clear()
        for (var h = 0; h < origenModel.count; h++) {
            if (origenModel.get(h).isFavorite) {
                resultModel.append({
                    artist: origenModel.get(h).artist,
                                   album: origenModel.get(h).album,
                                   title: origenModel.get(h).title,
                                   filePath: origenModel.get(h).filePath,
                                   isFavorite: origenModel.get(h).isFavorite
                })
            }
        }
    }

    function buildFullAlbumsList() {
        listAlbums = []
        fullTracksAlbums = []
        albumsModel.clear()
        index = 0
        indexAlbum = 0
        for (var i = 0; i < origenModel.count; i++) {
            var file = origenModel.get(i)
            var albumIndex = listAlbums.indexOf(file.album)
            if (albumIndex === -1) {
                listAlbums.push(file.album)
                fullTracksAlbums.push([])
                albumIndex = fullTracksAlbums.length - 1
            }
            fullTracksAlbums[albumIndex].push({
                album: file.album,
                file: file.filePath
            })
        }
        Qt.callLater(function() {
            fakePlayer.source = fullTracksAlbums[indexAlbum][index].file
            fakePlayer.play()
        })
    }

    function filter(string, model) {
        resultModel.clear();
        const search = string.toLowerCase(); // convertimos solo una vez
        for (let i = 0; i < model.count; i++) {
            let item = model.get(i);

            // Verificamos coincidencias en title, album o artist
            if ((item.title && item.title.toLowerCase().includes(search)) ||
                (item.album && item.album.toLowerCase().includes(search)) ||
                (item.artist && item.artist.toLowerCase().includes(search))) {
                resultModel.append(item);
                }
        }
        readylist();
    }


    function next(fileOrList) {
        if (fileOrList === "file") {
            if (index < (fullTracksAlbums[indexAlbum].length -1)) {
                index = index + 1
                fakePlayer.source = fullTracksAlbums[indexAlbum][index].file
                Qt.callLater(function() {
                    fakePlayer.play()
                })

            } else {
                if (indexAlbum < listAlbums.length -1) {
                    index = 0
                    indexAlbum = indexAlbum + 1
                    fakePlayer.source = fullTracksAlbums[indexAlbum][index].file
                    Qt.callLater(function() {
                        fakePlayer.play()
                    })
                } else {
                    //origenModel.clear()
                    typeModel = ""
                    readylist()
                }
            }
        } else {
            if (indexAlbum < (listAlbums.length - 1)) {
                index = 0
                indexAlbum = indexAlbum + 1
                fakePlayer.source = fullTracksAlbums[indexAlbum][index].file
                Qt.callLater(function() {
                    fakePlayer.play()
                })
            } else {
                //origenModel.clear()
                typeModel = ""
                readylist()
            }
        }


    }

    onFindTextChanged: {
        filter(findText,origenModel)
    }

    Lib.ConvertImage {
        id: convertImage //convierte la imagen en un url legible para qtquick image
        createFile: true
        onReadyImage: {
            resultAlbumsModel.append({
                artist: finalArtist,
                album: listAlbums[indexAlbum],
                cover: convertImage.resultImage
            });
            Qt.callLater(function() {
                fakePlayer.stop()
            })
            next("list")
        }
    }

    MediaPlayer {
        id: fakePlayer
        autoPlay: false
        source: ""
        audioOutput: AudioOutput {
            id: dynamicaudioOt
            muted: true
        }

        onMediaStatusChanged: {
            if (fakePlayer.mediaStatus === MediaPlayer.BufferedMedia) {
                var metaData = fakePlayer.metaData
                if (!metaData.isEmpty()){
                    if (metaData.value("24")) {
                        coverTem = metaData.value("24")
                        convertImage.originalImage = metaData.value("24")
                        var albumArtist = metaData.stringValue("19")
                        var contributingArtist = metaData.stringValue("20")
                        finalArtist = albumArtist || contributingArtist || "Unknown Artist"

                        fakePlayer.source = ""
                    } else {
                        Qt.callLater(function() {
                            fakePlayer.stop()
                        })
                        next("file")
                    }

                } else {
                    Qt.callLater(function() {
                        fakePlayer.stop()
                    })
                    next("file")
                }
            } else {
            }
        }
    }
}
