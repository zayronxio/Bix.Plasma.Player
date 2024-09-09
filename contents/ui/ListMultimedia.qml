import QtQuick 2.4
import Qt.labs.folderlistmodel 2.15
import org.kde.kirigami as Kirigami
import org.kde.ksvg 1.0 as KSvg
import QtMultimedia
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import org.kde.plasma.plasma5support 2.0 as P5Support
import QtCore
import Qt5Compat.GraphicalEffects
import QtQuick.Effects
import org.kde.plasma.plasmoid 2.0

Item {
    id: rootWrapper

    property bool newFilesExist: false
    property string sourceDirectory: plasmoid.configuration.sourceDirectory
    property string command: "find " + sourceDirectory + " -type d"
    property string currentFileUrl: ""
    property bool showFavoritesOnly: false
    property ListModel allTracksLoader: []
    property bool allDirectoriesProcessed: false
    property bool extractedMetadata: false // esta propiedad evita que se reanalizen los archvios una vex que ya conocemos sus metadatos
    property bool trackEnds: mediaPlayer.playbackState === 1 ? mediaPlayer.duration === mediaPlayer.position : false
    property bool isActivePlayList: false
    property bool verifyNoneExistence: false
    property bool firstRun: true
    property int filesAnalyzed: 0
    property bool shuffleMode: false
    property bool listGeneralLoaded: false
    property string listActive: "All Music"
    property string currentTitle: ""
    property string currentArtist: ""
    //property image cover:  []

    P5Support.DataSource {
        id: runCommand
        engine: "executable"
        connectedSources: []

        onNewData: function (source, data) {
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            exited(source, exitCode, exitStatus, stdout, stderr)
            disconnectSource(source) // cmd finished
        }

        function exec(cmd) {
            runCommand.connectSource(cmd)
        }

        signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)
    }

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
        id: mp3Model
    }

    ListModel {
        id: newFiles
    }

    ListModel {
        id: listGeneral
    }

    ListModel {
        id: favModel
    }

    function updateCurrentIndexBasedOnFileUrl(model) {
        for (var i = 0; i < trackListView.count; i++) {
            if (model.get(i).filePath === currentFileUrl) {
                // Se encontró una coincidencia, actualizar el currentIndex
                trackListView.currentIndex = i;
                break;
            }
        }
    }

    ListModel {
        id: filteredModel

        function updateFilter(query) {
            clear(); // Limpia el modelo filtrado
            for (var i = 0; i < listGeneral.count; i++) {
                var item = listGeneral.get(i);
                if (item.title.toLowerCase().indexOf(query.toLowerCase()) !== -1 ||
                    item.artist.toLowerCase().indexOf(query.toLowerCase()) !== -1 ||
                    item.album.toLowerCase().indexOf(query.toLowerCase()) !== -1) {
                    append(item); // Agrega el elemento al modelo filtrado
                    }
            }
            //updateCurrentIndexBasedOnFileUrl(filteredModel, currentFileUrl);
            // console.log(filteredModel.currentIndex)
        }
    }
    function favGenModel() {
        favModel.clear()
        for (var i = 0; i < listGeneral.count; ++i) {
            var item = listGeneral.get(i)
            if ( item.isFavorite === true || item.isFavorite === "true") {
                favModel.append(item)
            }
        }
        //updateCurrentIndexBasedOnFileUrl(filteredModel, currentFileUrl);
        //console.log(favModel.currentIndex)
    }

    property var dirs: []
    property FolderListModel tracks: FolderListModel {
        id: filesModel
        property real numIndexDirs: 0
        nameFilters: ["*.mp3"]
        showDirs: false
        folder: "file://" + dirs[numIndexDirs]
        onStatusChanged: {
            if (filesModel.status === FolderListModel.Ready) {
                //mp3Model.clear(); // Clear the model before adding new items
                if (filesModel.count > 0) {
                    var loadFullFiles = false
                } else {
                    var loadFullFiles = true
                }

                for (var j = 0; j < filesModel.count; j++) {
                    mp3Model.append({
                        fileName: filesModel.get(j, "fileName"),
                        filePath: filesModel.get(j, "filePath"),
                        isFavorite: false
                    });
                    loadFullFiles = true
                    console.log("se cargo la info de el directorio", numIndexDirs)
                }
                if (numIndexDirs < dirs.length) {
                    numIndexDirs =  numIndexDirs +1;
                    //loadFullFiles = false
                    //filesModel.reload()
                    console.log("se ejecuto ", numIndexDirs, loadFullFiles)
                    allDirectoriesProcessed = numIndexDirs === dirs.length ? loadFullFiles : false
                    console.log(allDirectoriesProcessed, loadFullFiles, mp3Model.count)
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


    function extractTextInBrackets(str) {
        var regex = /\[(.*?)\](?=\s*,|\s*$)/g;
        var results = [];
        var match;
        while ((match = regex.exec(str)) !== null) {
            results.push(match[1].trim());
        }
        return results;
    }


    Component.onCompleted: {
        if (bixConf.value("extractedMetadata") === "true") {
            firstRun = false
            filesAnalyzed = parseFloat(bixConf.value("filesMetadatesLoaded"))

            extractedMetadata = true

            for (var i = 0; i < filesAnalyzed; i++) {

                var dataString = bixMetadConfg.value(i)

                var matches = extractTextInBrackets(dataString);

                listGeneral.append({
                    fileName: matches[0],
                    title: matches[1],
                    artist: matches[3],
                    album: matches[2],
                    filePath: matches[4],
                    isFavorite: matches[5]
                });

                if (i === (filesAnalyzed-1)) {
                    listGeneralLoaded = true
                }
                filteredModel.updateFilter(searchField.text)
            }
        } else {
            filesAnalyzed = 0
            firstRun = true
        }
        executable.exec(command);

        metaDateGenerator.metaDataOfFilesAnd.connect(dumpToListGeneral);
        filteredModel.updateFilter(searchField.text)

    }

    onAllDirectoriesProcessedChanged: {
         if (allDirectoriesProcessed) {

             if (!firstRun) {
                 for (var f = 0; f < listGeneral.count; f++) {
                     var fileFound = false

                     for (var z = 0; z < mp3Model.count; z++) {
                         if (mp3Model.get(z).fileName === listGeneral.get(f).fileName) {
                             fileFound = true
                             break
                         }
                     }

                     if (!fileFound) {

                         for (var n = f; n < (listGeneral.count); n++) {

                             if (f === (listGeneral.count - 1)) {
                                 bixMetadConfg.setValue(n, "")

                             } else {
                                 bixMetadConfg.setValue(n, bixMetadConfg.value(n + 1))

                                 if (n === listGeneral.count - 1) {
                                     bixMetadConfg.setValue(n, "")
                                 }
                             }
                         }
                         listGeneral.remove(f)
                         filesAnalyzed -= 1
                         bixConf.setValue("filesMetadatesLoaded", filesAnalyzed)
                         console.log(listGeneral.count)
                     }
                 }

                 if (listGeneral.count < mp3Model.count ) {
                     verifyNoneExistence = true
                 }

             } else {
                 metaDateGenerator.updateList = false
                 metaDateGenerator.baseModel = mp3Model
                 confirmationDialog.open() //rootItem.dialogStart()
                 metaDateGenerator.metaDataOfFilesAnd.connect(dumpToListGeneral);

             }

        }

    }

    onVerifyNoneExistenceChanged: {
        if (listGeneral.count < mp3Model.count) {

            //var newFiles = [];
            var found = false;

            for (var e = 0; e < mp3Model.count; e++) {
                found = false;

                for (var a = 0; a < listGeneral.count; a++) {
                    if (mp3Model.get(e).fileName === listGeneral.get(a).fileName) {
                        found = true;
                        break;
                    }
                }

                if (!found) {
                    // Archivo no encontrado en listGeneral, agregar a newFiles
                    newFiles.append({
                        filePath: mp3Model.get(e).filePath,
                        fileName: mp3Model.get(e).fileName,
                        isFavorite: false
                    });
                }
            }

            if (newFiles.count > 0) {
                // Si hay nuevos archivos, iniciar el análisis
                metaDateGenerator.updateList = true;
                metaDateGenerator.baseModel = newFiles;
                metaDateGenerator.prevfilesAnalyzed = filesAnalyzed;
                confirmationDialog.open() //dialogMetaDataAccept.dialogStart() //rootItem.confirmationDialog.open()
                //metaDateGenerator.detonator();
                console.log("The analysis of the new files has started");
            } else {
                console.log("No new files to analyze");
            }
        }

    }

    onSourceDirectoryChanged: {
        command = "find " + sourceDirectory + " -type d";
        executable.exec(command);
        filteredModel.updateFilter(searchField.text)
    }

    onListActiveChanged: {
        updateCurrentIndexBasedOnFileUrl();
    }


    function dumpToListGeneral() {
        if (!firstRun) {
            for (var m = 0; m < metaDateGenerator.tracksUpdateModel.count; m++) {
                    listGeneral.append({
                        fileName: metaDateGenerator.tracksUpdateModel.get(m).fileName,
                                       title: metaDateGenerator.tracksUpdateModel.get(m).title,
                                       artist: metaDateGenerator.tracksUpdateModel.get(m).artist,
                                       album: metaDateGenerator.tracksUpdateModel.get(m).album,
                                       filePath: metaDateGenerator.tracksUpdateModel.get(m).filePath,
                                       isFavorite: metaDateGenerator.tracksUpdateModel.get(m).isFavorite,
                                       isFavorite: false
                    });
                    filteredModel.updateFilter(searchField.text)
            }
        } else {
            for (var m = 0; m <  metaDateGenerator.tracksModel.count; m++) {
                listGeneral.append({
                    fileName: metaDateGenerator.tracksModel.get(m).fileName,
                                   title: metaDateGenerator.tracksModel.get(m).title,
                                   artist: metaDateGenerator.tracksModel.get(m).artist,
                                   album: metaDateGenerator.tracksModel.get(m).album,
                                   filePath: metaDateGenerator.tracksModel.get(m).filePath,
                                   isFavorite: false
                });
                filteredModel.updateFilter(searchField.text)
            }
        }

    }

    Dialog {
        id: confirmationDialog
        width: 400
        height: 150
        opacity: 1
        //color: "red"
        title: "Continue with metadata extraction?"
        anchors.centerIn: parent
        //text: "¿Estás seguro de que deseas iniciar metaDateGenerator.detonator()?"
        standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: {
            console.log("se inicio el detonador")
            metaDateGenerator.detonator()

        }

    }

    MetaDateGenerator {
        id: metaDateGenerator
        baseModel: mp3Model
    }

    // MediaPlayer instance
    MediaPlayer {
        id: mediaPlayer
        audioOutput: AudioOutput { id: audioOutput
            volume: 1
        }
        source: currentFileUrl
    }

    onTrackEndsChanged: {
        if (trackEnds && isActivePlayList) {
            nextTrack()
        }
    }

    Item {
        id: backgroundSidebar
        width: 170
        height: parent.height
        visible: true
        opacity: 1
        anchors.left: parent.left
        KSvg.FrameSvgItem {
            imagePath: "dialogs/background"
            clip: true
            width: parent.width
            height: parent.height
        }
        Column {
            width: parent.width - 6
            height: 60
            spacing: 16
            anchors.top: parent.top
            anchors.topMargin: 20
            Rectangle {
                color: listActive === "All Music" ? Kirigami.Theme.highlightColor : "transparent"
                width: parent.width - 12
                height: 24
                radius: height/2
                anchors.left: parent.left
                anchors.leftMargin: 6
                Row {
                    width: parent.width - 8
                    height: 22
                    spacing: 8
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    Kirigami.Icon {
                        id: iconList
                        source: "view-media-playlist"
                        width: 22
                        height: 22
                        color: listActive === "All Music" ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        id: allMusic
                        width: parent.width - iconList.width - parent.spacing
                        height: iconList.height
                        text: "All Music"
                        verticalAlignment: Text.AlignVCenter
                        color: listActive === "All Music" ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                        font.bold: true
                        font.pixelSize: 12
                    }

                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        listActive = "All Music"
                        //favGenModel()
                    }
                }
            }

            Rectangle {
                color: listActive === "Favorites" ? Kirigami.Theme.highlightColor : "transparent"
                width: parent.width - 12
                height: 24
                radius: height/2
                anchors.left: parent.left
                anchors.leftMargin: 6
                Row {
                    width: parent.width - 8
                    height: 22
                    spacing: 8
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    Kirigami.Icon {
                        id: iconFav
                        source: "love"
                        width: 22
                        height: 22
                        color: listActive === "Favorites" ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        id: favoritesTracks
                        width: parent.width - iconList.width - parent.spacing
                        height: iconFav.height
                        text: "Favorites"
                        verticalAlignment: Text.AlignVCenter
                        color: listActive === "Favorites" ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                        font.bold: true
                        font.pixelSize: 12
                    }

                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        listActive = "Favorites"
                        favGenModel()
                    }
                }
            }


        }

        Text {
            id: version
            text: "ALfA " + Plasmoid.metaData.version
            color: Kirigami.Theme.textColor
            font.pixelSize: 11
            anchors.bottom: donate.top
            anchors.bottomMargin: 8
            anchors.left: parent.left
            anchors.leftMargin: 16
        }
        Text {
            id: donate
            text: "Donate to me"
            color: Kirigami.Theme.textColor
            font.pixelSize: 11
            font.bold: true
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 16
            anchors.left: parent.left
            anchors.leftMargin: 16
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    executable.exec("xdg-open 'https://www.paypal.com/paypalme/zayronxio'");
                }
            }
        }



    }

    function getRandomNumber(min, max) {
        return Math.floor(Math.random() * (max - min + 1)) + min;
    }

    function asignValues(){
        currentTitle = trackListView.model.get(trackListView.currentIndex).title === "Unknown Title" ? trackListView.model.get(trackListView.currentIndex).fileName.split(".mp3")[0] : trackListView.model.get(trackListView.currentIndex).title
        currentArtist =  trackListView.model.get(trackListView.currentIndex).artist
    }
    function playPause() {
        if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
            mediaPlayer.pause();
        } else {
            mediaPlayer.play();
            asignValues()
        }
    }

    function nextTrack() {
        var nextIndex = shuffleMode ? getRandomNumber(1, trackListView.count) : trackListView.currentIndex + 1;
        trackListView.currentIndex = nextIndex;
        currentFileUrl = trackListView.model.get(trackListView.currentIndex).filePath;
        mediaPlayer.play();
        asignValues()
    }

    function prevTrack() {
        var prevIndex = trackListView.currentIndex - 1;
        trackListView.currentIndex = prevIndex;
        currentFileUrl = trackListView.model.get(trackListView.currentIndex).filePath;
        mediaPlayer.play();
        asignValues()
    }

    function updateIsFavorite(index) {
        // Leer el valor actual
        var dataString = bixMetadConfg.value(index);
        var matches = extractTextInBrackets(dataString);
        var valueBool = matches[5] === "true" ? true : false
        var textBool = valueBool ? "false" : "true"
        // Actualizar el valor de isFavorite (último elemento)
        matches[5] = !valueBool

        // Reconstruir la cadena con el nuevo valor
        var newDataString = matches.map(function(item) {
            return "[" + item + "]";
        }).join(",");

        // Guardar el nuevo valor en el archivo de configuración
        bixMetadConfg.setValue(index, newDataString);

        // Mark the current file as favorite in the model

        if (typeof trackListView.model.get(index).isFavorite === "boolean") {
            trackListView.model.set(index, {isFavorite: !valueBool});
        } else {
            trackListView.model.set(index, {isFavorite: textBool});
        }
        for (var k = 0; k < listGeneral.count; k++) {
           if (trackListView.model.get(index).fileName === listGeneral.get(k).fileName) {
               if (typeof listGeneral.get(k).fileName === "boolean") {
                   listGeneral.set(index, {isFavorite: !valueBool});
                   break;
            } else {
                 listGeneral.set(index, {isFavorite: textBool});
                 break;
            }
        }
        }
        favGenModel()
        // Log the current file's favorite status
        console.log(trackListView.model.get(index).isFavorite);
    }



    Item {
        id: controls
        width: trackListView.width
        height: 70
        anchors.horizontalCenter: trackListView.horizontalCenter
        anchors.bottom: parent.bottom

        Image {
            id: covergeneric
            width: controls.height * 0.7
            height: width
            source: "../images/coverGeneric.jpeg"
            visible: false
        }
        Kirigami.Icon {
            id: imageCover
            width: (controls.height * 0.8) + 10
            height: width
            //anchors.centerIn: cover
            visible: false
            source: mediaPlayer.metaData.value("24") === undefined ? covergeneric.source : mediaPlayer.metaData.value("24");

        }

        MultiEffect {
            id: cover
            source: mediaPlayer.metaData.value("24") === undefined ? covergeneric : imageCover
            width: controls.height * 0.7
            height: width
            blurEnabled: false
            blurMax: 32
            blur: 1.0
            visible: true
            //maskSpreadAtMin: 0.1
            //maskSpreadAtMax: 1.0
            antialiasing: true
            maskEnabled: true
            maskSource: Image {
                height: imageCover
                width: height
                source: "../images/mask.svg"
            }
            anchors.left: backgroundSidebar.right
            anchors.leftMargin: 10
            anchors.verticalCenter: controls.verticalCenter
        }
        Row  {
            id: control
            width: height*3 + 16
            height: 22
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: cover.right
            anchors.leftMargin: 16
            spacing: 8

            Kirigami.Icon {
                id: prev
                width: 22
                height: 22
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
                width: 22
                height: 22
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
                width: 22
                height: 22
                source: "media-skip-forward"
                MouseArea {
                    width: 22
                    height: 22
                    anchors.centerIn: next
                    onClicked: {
                        nextTrack()
                        console.log(trackListView.currentItem.filePath)
                    }
                }
            }
        }
        Text {
            text: currentTitle
            anchors.bottom: progressBarBase.top
            font.pixelSize: 12
            width: progressBarBase.width
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideMiddle
            color: Kirigami.Theme.textColor
            font.bold: true
            anchors.horizontalCenter: progressBarBase.horizontalCenter
        }
        Text {
            text: currentArtist
            anchors.top: progressBarBase.bottom
            width: progressBarBase.width
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideMiddle
            color: Kirigami.Theme.textColor
            font.pixelSize: 11
            anchors.horizontalCenter: progressBarBase.horizontalCenter
        }
        Rectangle {
            id: progressBarBase
            color: Kirigami.Theme.textColor
            opacity: 0.4
            height: 5
            radius: height/2
            width: 208
            anchors.left: control.right
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
        }
        Rectangle {
            id: progressBar
            color: Kirigami.Theme.textColor
            opacity: 1
            height: 5
            radius: height/2
            width: (mediaPlayer.position / mediaPlayer.duration) * progressBarBase.width
            anchors.left: progressBarBase.left
            anchors.verticalCenter: progressBarBase.verticalCenter
        }

        Kirigami.Icon {
            id: favButton
            source: "love"
            width: 22
            height: 22
            opacity: typeof trackListView.model.get(trackListView.currentIndex).isFavorite === "boolean" ? trackListView.model.get(trackListView.currentIndex).isFavorite === true ? 1 : 0.3 : trackListView.model.get(trackListView.currentIndex).isFavorite === "true" ? 1 : 0.3
            anchors.left: progressBarBase.right
            anchors.leftMargin: 16
            anchors.verticalCenter: progressBarBase.verticalCenter
            MouseArea {
                width: 22
                height: 22
                anchors.centerIn: next
                onClicked: {
                    updateIsFavorite(trackListView.currentIndex)
                    console.log(trackListView.model.get(trackListView.currentIndex).isFavorite)
                }
            }
        }
        Kirigami.Icon {
            source: "media-playlist-shuffle"
            width: 22
            height: 22
            opacity: shuffleMode ? 1 : 0.4
            anchors.left: favButton.right
            anchors.leftMargin: 8
            anchors.verticalCenter: progressBarBase.verticalCenter
            MouseArea {
                width: 22
                height: 22
                anchors.centerIn: next
                onClicked: {
                    shuffleMode = !shuffleMode
                }
            }
        }
    }


    Kirigami.SearchField {
        id: searchField
        placeholderText: "Search..."
        anchors.horizontalCenter: trackListView.horizontalCenter
        width: trackListView.width *.5
        height: 35
        opacity: 0.8
        color: Kirigami.Theme.textColor

        background: Rectangle {
            color: Kirigami.Theme.backgroundColor
            radius: 5
            border.color: Kirigami.Theme.textColor
        }

        onTextChanged: {
            listActive = "All Music"
            filteredModel.updateFilter(searchField.text) // Actualiza los resultados de búsqueda
        }
    }
    Text {
        id: headListOne
        text: "Title / Artist"
        height: 20
        width: trackListView.width/2
        font.pixelSize: 14
        anchors.left: trackListView.left
        anchors.top: searchField.bottom
        color: Kirigami.Theme.textColor
        anchors.topMargin: 15
    }
    Text {
        id: headListTwo
        text: "Album"
        height: 20
        width: trackListView.width/2
        color: Kirigami.Theme.textColor
        font.pixelSize: 14
        anchors.left: headListOne.right
        anchors.top: searchField.bottom
        anchors.topMargin: 15
    }
    Rectangle {
        id: separatorList
        width: trackListView.width
        height: 1
        color: Kirigami.Theme.textColor
        anchors.horizontalCenter: trackListView.horizontalCenter
        anchors.top: headListTwo.bottom
        //anchors.topMargin: 10
    }

    ListView {
        id: trackListView
        anchors.left: backgroundSidebar.right
        anchors.leftMargin: 10
        anchors.top: separatorList.bottom
        width: parent.width - backgroundSidebar.width - 15
        height: 310
        clip: true
        snapMode: ListView.SnapToItem
        model: listActive === "All Music" ? filteredModel : favModel

        delegate: Item {
            width: parent.width
            height: 50

            Column {
                anchors.verticalCenter: parent.verticalCenter
                id: titleAndArtist
                height: title.implicitHeight + artist.implicitHeight
                width: (parent.width*.9)/2
                spacing: 0
                Text {
                    id: title
                    height: parent.height/2
                    width: parent.width
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    text: model.title === "Unknown Title" ? model.fileName.split(".mp3")[0] : model.title
                    font.pixelSize: 11
                    color: Kirigami.Theme.textColor
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            trackListView.currentIndex = index;
                            currentFileUrl = model.filePath
                            isActivePlayList = true
                            mediaPlayer.play();
                            asignValues()
                        }
                    }
                }
                Text {
                    id: artist
                    height: parent.height/2
                    verticalAlignment: Text.AlignVCenter
                    width: parent.width
                    elide: Text.ElideRight
                    text: model.artist
                    font.pixelSize: 11
                    opacity: 0.7
                    color: Kirigami.Theme.textColor
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            trackListView.currentIndex = index;
                            currentFileUrl = model.filePath
                            isActivePlayList = true
                            mediaPlayer.play();
                            asignValues()
                        }
                    }
                }

            }
            Text {
                id: album
                text: model.album
                height: 50
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                width:  (parent.width*.9)/2
                color: Kirigami.Theme.textColor
                font.pixelSize: 11
                anchors.left: titleAndArtist.right

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        trackListView.currentIndex = index;
                        currentFileUrl = model.filePath
                        console.log(model.artist)
                        isActivePlayList = true
                        mediaPlayer.play();
                        asignValues()
                    }
                }
            }
            Kirigami.Icon {
                source: "love"
                width: 22
                height: 22
                opacity: typeof model.isFavorite === "boolean" ? model.isFavorite === true ? 1 : 0.3 : model.isFavorite === "true" ? 1 : 0.3
                anchors.left: album.right
                anchors.leftMargin: 16
                anchors.verticalCenter: album.verticalCenter
                MouseArea {
                    width: 22
                    height: 22
                    anchors.centerIn: next
                    onClicked: {
                        updateIsFavorite(index)
                    }
                }

            }
            Rectangle {
                width: parent.width
                height: 4
                color: currentFileUrl === model.filePath ? Kirigami.Theme.highlightColor : "transparent"
                anchors.top: titleAndArtist.bottom
            }

        }
    }
}

