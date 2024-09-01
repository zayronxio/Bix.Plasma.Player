import QtQuick 2.4
import Qt.labs.folderlistmodel 2.15
import org.kde.kirigami as Kirigami
import org.kde.ksvg 1.0 as KSvg
import QtMultimedia
import org.kde.plasma.plasma5support 2.0 as P5Support
import QtCore

Item {

    property string sourceDirectory: plasmoid.configuration.sourceDirectory
    property string command: "find " + sourceDirectory + " -type d"
    property string currentFileUrl: ""
    property bool showFavoritesOnly: false
    property bool allDirectoriesProcessed: false
    property bool trackEnds: mediaPlayer.playbackState === 1 ? mediaPlayer.duration === mediaPlayer.position : false
    property bool isActivePlayList: false

    Settings {
        id: favorites
        category: "favorites"
        property var files: []
    }

    ListModel {
        id: mp3Model
    }

    ListModel {
        id: currentList
    }

    property var directories: []
    property FolderListModel tracks: FolderListModel {
        id: filesModel
        property real numIndexDirs: 0
        nameFilters: ["*.mp3"]
        showDirs: false
        folder: "file://" + dirs[numIndexDirs]
        onStatusChanged: {
            if (filesModel.status === FolderListModel.Ready) {
                //mp3Model.clear(); // Clear the model before adding new items
                var loadFullFiles = false
                for (var j = 0; j < filesModel.count; j++) {
                    mp3Model.append({
                        fileName: filesModel.get(j, "fileName"),
                                    filePath: filesModel.get(j, "filePath"),
                                    isFavorite: false
                    });
                    loadFullFiles = true
                }
                if (numIndexDirs < dirs.length) {
                    numIndexDirs =  numIndexDirs +1;
                    //loadFullFiles = false
                    //filesModel.reload()
                    console.log("se ejecuto ", numIndexDirs, loadFullFiles)
                    allDirectoriesProcessed = numIndexDirs === dirs.length ? loadFullFiles : false
                    console.log(allDirectoriesProcessed)
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
                // Split stdout into lines (one directory per line)
                var directoriesList = stdout.trim().split("\n")
                directories = directoriesList
                mp3Model.clear()
                tracks.reload()
            }
            disconnectSource(sourceName);
        }
        function exec(cmd) {
            connectSource(cmd);
        }
    }

    Component.onCompleted: {
        if (sourceDirectory && sourceDirectory !== "") {
            executable.exec(command);
        } else {
            console.log("sourceDirectory is not configured or is empty");
        }
    }

    onSourceDirectoryChanged: {
        command = "find " + sourceDirectory + " -type d";
        executable.exec(command);
    }

    // MediaPlayer instance
    MediaPlayer {
        id: mediaPlayer
        audioOutput: AudioOutput { id: audioOutput }
        source: currentFileUrl

    }

    onTrackEndsChanged: {
        if (trackEnds && isActivePlayList) {
            trackListView.currentIndex += 1
            currentFileUrl = metaDateGenerator.tracksModel.get(trackListView.currentIndex).filePath
            mediaPlayer.play();
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

    function playPause() {
        if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
            mediaPlayer.pause();
        } else {
            mediaPlayer.play();
        }
    }

    function nextTrack() {
        var nextIndex = trackListView.currentIndex + 1;
        trackListView.currentIndex = nextIndex;
        currentFileUrl = mp3Model.get(trackListView.currentIndex).filePath;
        mediaPlayer.play();
    }

    function prevTrack() {
        var prevIndex = trackListView.currentIndex - 1;
        trackListView.currentIndex = prevIndex;
        currentFileUrl = mp3Model.get(trackListView.currentIndex).filePath;
        mediaPlayer.play();
    }

    function addFavorite() {
        var currentTrack = mp3Model.get(trackListView.currentIndex).filePath;
        var favoritesList = favorites.value("files") || [];
        var alreadyExists = false;

        // Check if the file is already in the favorites list
        for (var w = 0; w < favoritesList.length; w++) {
            if (favoritesList[w] === currentTrack) {
                alreadyExists = true;
                break;
            }
        }

        // Add the file to favorites if it's not already in the list
        if (!alreadyExists) {
            if (!favorites.value("files").toString().isEmpty()) {
                favorites.setValue("files", favorites.value("files") + ", '" + currentTrack + "'")
            } else {
                favorites.setValue("files", "'" + currentTrack + "'")
            }
        }

        // Mark the current file as favorite in the model
        mp3Model.setProperty(trackListView.currentIndex, "isFavorite", true);

        // Log the current file's favorite status
        console.log(mp3Model.get(trackListView.currentIndex).isFavorite);
    }

    Item {
        id: controls
        width: trackListView.width
        height: 70
        anchors.horizontalCenter: trackListView.horizontalCenter
        anchors.bottom: parent.bottom

        Rectangle {
            color: "blue"
            width: controls.height * 0.8
            height: width
            radius: height / 6
            anchors.left: controls.left
            anchors.leftMargin: (controls.height - width) / 2
            anchors.verticalCenter: controls.verticalCenter
        }
        Row  {
            id: control
            width: parent.width - controls.height * 1.1
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
                        console.log(trackListView.currentItem.filePath)
                    }
                }
            }
        }
    }

    ListView {
        id: trackListView
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
                    trackListView.currentIndex = index;
                    currentFileUrl = model.filePath
                    isActivePlayList = true
                    mediaPlayer.play();

                }
            }
        }
    }
}

