import QtQuick 2.4
import Qt.labs.folderlistmodel 2.15
import org.kde.kirigami as Kirigami
import org.kde.ksvg 1.0 as KSvg
//import QtQml.Models
import QtMultimedia
import org.kde.plasma.plasma5support 2.0 as P5Support
import QtQml.XmlListModel
//import Qt.labs.settings 1.0
import QtCore

Item {

    property string sourceDirectory: Plasmoid.configuration.sourceDirectory
    property string urlFile: ""
    //property string list: "all"

    property bool showFavoritesOnly: false
    //property int mediaMetaData: mediaPlayer.audioTracks.length
    //property string title: mediaPlayer.metaData.stringValue(mediaPlayer.audioTracks[0].Title)

    //MetaDateGenerator {
      //  id: metaDateGenerator
    //}


    Settings {
        id: favorites
        category: "favorites"
        //fileName: "zayronPlasmaPlayer"
        //location: "/home/zaron/.config//music.conf"
        property var files: []
    }

    ListModel {
        id: mp3Model
    }

    ListModel {
        id: currentList
    }
    //property int numDir: 0
    property var dirs: []
    property FolderListModel tracks: FolderListModel {
        id: trackModel
        property real numIndexDirs: 0
        nameFilters: ["*.mp3"]
        showDirs: false
        folder: "file://" + dirs[numIndexDirs]
        onStatusChanged: {
            if (trackModel.status === FolderListModel.Ready) {
                //mp3Model.clear(); // Clear the model before adding new items
                for (var j = 0; j < trackModel.count; j++) {
                    mp3Model.append({
                        fileName: trackModel.get(j, "fileName"),
                                    filePath: trackModel.get(j, "filePath"),
                                    isFavorite: false
                    });
                }
                if (numIndexDirs < dirs.length) {
                    numIndexDirs =  numIndexDirs +1;
                    trackModel.reload()
                }
            }
        }
    }
    P5Support.DataSource {
        id: executable
        engine: "executable"
        onNewData: {
            var stdout = data["stdout"];
            if (stdout) {
                // Divide stdout en líneas (directorio por línea)
                var directories = stdout.trim().split("\n")
                dirs = directories
                mp3Model.clear()
                tracks.reload()
                //updateTracks()
                //tracks.folder = dirs[0]

            }
            disconnectSource(sourceName);
        }
        function exec(cmd) {
            connectSource(cmd);
        }
    }

    Component.onCompleted: {
        executable.exec("find /home/zaron/Música -type d");
    }


    // Player
    MediaPlayer {
        id: mediaPlayer
        audioOutput: AudioOutput { id: audioOutput }
        source: urlFile
        onMetaDataChanged: {
            var metaData = mediaPlayer.metaData
            if (!metaData.isEmpty()) {
                console.log("Metadatos del archivo de audio:")

                // Imprimir todas las claves disponibles
                var keys = metaData.keys()
                for (var i = 0; i < keys.length; ++i) {
                    var key = keys[i]
                    console.log("Key: " + key + " Value: " + metaData.stringValue(key))
                }

                // Utiliza las claves como cadenas de texto
                var title = metaData.stringValue("0")
                var artist = metaData.stringValue("20") ? metaData.stringValue("20") : metaData.stringValue("19")
                var album = metaData.stringValue("18")
                var genre = metaData.stringValue("12")
                fg.source =  metaData.value("24")
                console.log("Title: " + title)
                console.log("Artist: " + artist)
                console.log("Album: " + album)
                console.log("Genre: " + genre)
            } else {
                console.log("No hay metadatos disponibles.")
            }
        }
    }

    Item {
        id: backgroundSidebar
        width: 200
        height: parent.height
        visible: true
        opacity: 0.7
        anchors.left: parent.left
        KSvg.FrameSvgItem {
            imagePath: "dialogs/background"
            clip: true
            width: parent.width
            height: parent.height
        }
    }

    function playPause(){
        if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
            mediaPlayer.pause();
        } else {
            mediaPlayer.play();
        }

    }
    function nextTrack() {
        var nextIndex = listOfRep.currentIndex + 1;
        listOfRep.currentIndex = nextIndex;
        urlFile = mp3Model.get(listOfRep.currentIndex).filePath;
        mediaPlayer.play();
    }

    function prevTrack() {
        var prevIndex = listOfRep.currentIndex - 1;
        listOfRep.currentIndex = prevIndex;
        urlFile = mp3Model.get(listOfRep.currentIndex).filePath;
        mediaPlayer.play();
    }

    function addFavorite() {
        var currentTrack = mp3Model.get(listOfRep.currentIndex).filePath;
        var favoritesList = favorites.value("files") || [];
        var alreadyExists = false;
        //favorites.setValue("files", favoritesList);
        // Verificar si el archivo ya está en la lista de favoritos
        for (var w = 0; w < favoritesList.length; w++) {
            if (favoritesList[w] === currentTrack) {
                alreadyExists = true;
                break;
            }
        }

        // Agregar el archivo a favoritos si no está ya en la lista
        if (!alreadyExists) {
            //favoritesList.push(currentTrack);
            if (!favorites.value("files").toString().isEmpty()) {
                favorites.setValue("files", favorites.value("files") + ", '" + currentTrack + "'")
            } else {
                favorites.setValue("files", "'" + currentTrack + "'")
            }

        }

        // Marcar el archivo actual como favorito en el modelo
        mp3Model.setProperty(listOfRep.currentIndex, "isFavorite", true);

        // Mostrar el estado del archivo actual
        console.log(mp3Model.get(listOfRep.currentIndex).isFavorite);
    }


    Item {
        id: controls
        width: listOfRep.width
        height: 70
        anchors.horizontalCenter: listOfRep.horizontalCenter
        anchors.bottom: parent.bottom

        Rectangle {
            color: "blue"
            width: controls.height*.8
            height: width
            radius: height/6
            anchors.left: controls.left
            anchors.leftMargin: (controls.height-width)/2
            anchors.verticalCenter: controls.verticalCenter
        }
        Row  {
            id: control
            width: parent.width - controls.height*1.1
            height: 24
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right

            Kirigami.Icon {
                id: prev
                width: 24
                height: 24
                source: "media-skip-backward"
                MouseArea {
                    width: parent.width
                    height: parent.height
                    onClicked: {
                        prevTrack()
                    }
                }
            }
            Kirigami.Icon {
                id: playpause
                width: 24
                height: 24
                source: mediaPlayer.playbackState ? "media-playback-pause" : "media-playback-start"
                MouseArea {
                    width: parent.width
                    height: parent.height
                    onClicked: {
                        playPause()
                    }
                }
            }
            Kirigami.Icon {
                id: next
                width: 24
                height: 24
                source: "media-skip-forward"
                MouseArea {
                    width: 24
                    height: 24
                    anchors.centerIn: next
                    onClicked: {
                        nextTrack()
                        console.log(listOfRep.currentItem.filePath)
                    }
                }
            }
        }
    }

    ListView {
        id: listOfRep
        anchors.left: backgroundSidebar.right
        anchors.leftMargin: 15
        anchors.top: parent.top
        width: parent.width - backgroundSidebar.width - 15
        height: 335
        model: mp3Model

        delegate: Item {
            width: parent.width
            height: 50

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: model.fileName
                color: Kirigami.Theme.textColor
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    listOfRep.currentIndex = index;
                    urlFile = model.filePath
                    mediaPlayer.play();
                }
            }
        }
    }
}

