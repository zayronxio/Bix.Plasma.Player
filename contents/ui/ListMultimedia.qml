import QtQuick
import Qt.labs.folderlistmodel 2.15
import QtQuick.Controls
import org.kde.plasma.plasma5support 2.0 as P5Support
import QtCore
import org.kde.plasma.plasmoid 2.0
import QtQuick.LocalStorage as Sql

Item {
    id: rootWrapper

    property var dirs: [] // se  llena con los directorios optenidos
    property bool newFilesExist: false
    property string sourceDirectory: Plasmoid.configuration.musicDirectory
    property string command: "find " + sourceDirectory + " -type d"
    property bool allDirectoriesProcessed: false
    property bool extractedMetadata: false // esta propiedad evita que se reanalizen los archvios una vex que ya conocemos sus metadatos
    property bool verifyNoneExistence: false
    property bool firstRun: true // establece si el primer momento que se cargo la lista existente
    property int filesAnalyzed: 0
    property bool listGeneralLoaded: false
    property string currentTitle: ""
    property string currentArtist: ""
    property bool keyPressed: false
    property alias listGeneral: listGeneral

    signal toggleFavorite(url filePath)

    onToggleFavorite: function (filePath) {
        var index
        for (var p = 0; p < listGeneral.count; p++) {
            if (filePath === listGeneral.get(p).filePath) {
                index = p
                break
            }
        }

        var newFavorite = !listGeneral.get(index).isFavorite  // alternar favorito
        listGeneral.setProperty(index, "isFavorite", newFavorite)
        dbHelper.updateFavorite(filePath, newFavorite)
        console.log("se agrego a favoritos",filePath,newFavorite,listGeneral.get(index).filePath, listGeneral.get(index).isFavorite)
    }

    QtObject {
        id: dbHelper
        property var db: null

        function init() {
            db = Sql.LocalStorage.openDatabaseSync("musicDB", "1.0", "Music Metadata DB", 5000000);
            db.transaction(function(tx) {
                tx.executeSql(`CREATE TABLE IF NOT EXISTS tracks (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    fileName TEXT,
                    title TEXT,
                    artist TEXT,
                    album TEXT,
                    filePath TEXT UNIQUE,
                    isFavorite INTEGER,
                    lists TEXT,
                    md5sum TEXT
                )`);
            });
        }

        function saveTrack(track) {
            var listsJSON = JSON.stringify(track.lists || []);
            db.transaction(function(tx) {
                tx.executeSql(`INSERT OR REPLACE INTO tracks
                (fileName, title, artist, album, filePath, isFavorite, lists, md5sum)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
                              [track.fileName, track.title, track.artist, track.album, track.filePath,
                              track.isFavorite ? 1 : 0, listsJSON, track.md5sum]);
            });
        }

        function loadAllTracks() {
            var results = [];
            db.readTransaction(function(tx) {
                var rs = tx.executeSql("SELECT * FROM tracks");
                for (var i = 0; i < rs.rows.length; i++) {
                    var item = rs.rows.item(i);
                    item.isFavorite = item.isFavorite === 1;
                    item.lists = JSON.parse(item.lists || "[]");
                    results.push(item);
                }
            });
            return results;
        }

        function updateFavorite(filePath, isFavorite) {
            db.transaction(function(tx) {
                tx.executeSql("UPDATE tracks SET isFavorite=? WHERE filePath=?", [isFavorite ? 1 : 0, filePath]);
            });
        }

        function updateLists(filePath, listsArray) {
            var listsJSON = JSON.stringify(listsArray || []);
            db.transaction(function(tx) {
                tx.executeSql("UPDATE tracks SET lists=? WHERE filePath=?", [listsJSON, filePath]);
            });
        }

        function getTrackMd5(filePath) {
            var result = null;
            db.readTransaction(function(tx) {
                var rs = tx.executeSql("SELECT md5sum FROM tracks WHERE filePath=?", [filePath]);
                if (rs.rows.length > 0)
                    result = rs.rows.item(0).md5sum;
            });
            return result;
        }

        // 🚀 NUEVO: eliminar pista por filePath
        function removeTrack(filePath) {
            db.transaction(function(tx) {
                tx.executeSql("DELETE FROM tracks WHERE filePath=?", [filePath]);
            });
        }
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


    property FolderListModel tracks: FolderListModel { //carga todos los directorios con sus repectivos archivos y llena el mp3Model, ademas establece el  valor de allDirectoriesProcessed, establece el valor de loadFullFiles
        id: filesModel
        property real numIndexDirs: 0
        nameFilters: ["*.mp3"] // actualmente solo procesa mp3, esta pendiente establecer una forma de optener los formatos compatibles, pueden variar en cada sistema.
        showDirs: false
        folder: "file://" + dirs[numIndexDirs]
        onStatusChanged: {
            if (filesModel.status === FolderListModel.Ready) {
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
                }
                if (numIndexDirs < dirs.length) {
                    numIndexDirs =  numIndexDirs +1;
                    allDirectoriesProcessed = numIndexDirs === dirs.length ? loadFullFiles : false
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

            }
            disconnectSource(sourceName);
        }
        function exec(cmd) {
            connectSource(cmd);
        }
    }

    function loadTracksFromDb() {
        listGeneral.clear()
        var tracks = dbHelper.loadAllTracks()
        for (var i = 0; i < tracks.length; i++) {
            listGeneral.append({
                fileName: tracks[i].fileName,
                title: tracks[i].title,
                artist: tracks[i].artist,
                album: tracks[i].album,
                filePath: tracks[i].filePath,
                isFavorite: tracks[i].isFavorite,
                lists: tracks[i].lists,
                //md5sum: tracks[i].md5sum
            })
        }
        listGeneralLoaded = true
    }

    Component.onCompleted: {
        dbHelper.init()
        if (dbHelper.loadAllTracks().length > 0) {
            // Ya existen pistas en la base de datos
            loadTracksFromDb()
            extractedMetadata = true
            firstRun = false
        } else {
            // No hay pistas todavía → se hará el primer análisis
            filesAnalyzed = 0
            firstRun = true
        }

        executable.exec(command) // inicia el escaneo de directorios
        metaDateGenerator.metaDataOfFilesAnd.connect(dumpToListGeneral) // cuando se dectectan nuevos archivos desde otra parte del codigo se detona metaDateGenerator, y esta coneccion ayuda a solicitar la regeneracion de la listGeneral donde parten todos los filtros
    }

    onAllDirectoriesProcessedChanged: { // gestiona la sincronización entre los archivos que ya conoces y los que acabas de escanear, y decide si se debe extraer metadatos de los nuevos archivos o limpiar los que ya no existen.
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
                        // Archivo ya no existe → borrar de DB y del modelo
                        var filePathToRemove = listGeneral.get(f).filePath
                        dbHelper.removeTrack(filePathToRemove)
                        listGeneral.remove(f) // remueve tambien de la lista generada actualmente
                        filesAnalyzed -= 1
                        f-- // retrocede índice porque la lista se acortó
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

            var found = false;

            for (var e = 0; e < mp3Model.count; e++) {
                found = false;

                for (var a = 0; a < listGeneral.count; a++) {
                    if (mp3Model.get(e).filePath === listGeneral.get(a).filePath) {
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
                confirmationDialog.open()
            }
        }

    }

    onSourceDirectoryChanged: { // Inicia un nuevo escaneo   de directorios y mp3
        command = "find " + sourceDirectory + " -type d";
        executable.exec(command);
        filteredModel.updateFilter(searchField.text)
    }


    function dumpToListGeneral() {
        if (!firstRun) {
            // Actualización con nuevos archivos
            for (var m = 0; m < metaDateGenerator.tracksUpdateModel.count; m++) {
                var t = metaDateGenerator.tracksUpdateModel.get(m)

                // Guardar en SQLite
                dbHelper.saveTrack({
                    fileName: t.fileName,
                    title: t.title,
                    artist: t.artist,
                    album: t.album,
                    filePath: t.filePath,
                    isFavorite: t.isFavorite || false,
                    lists: [],
                    //md5sum: t.md5sum || ""
                })

                // Agregar al modelo en memoria
                listGeneral.append({
                    fileName: t.fileName,
                    title: t.title,
                    artist: t.artist,
                    album: t.album,
                    filePath: t.filePath,
                    isFavorite: t.isFavorite || false,
                    lists: [],
                    //md5sum: t.md5sum || ""
                })
            }
        } else {
            // Primer análisis completo
            for (var m = 0; m < metaDateGenerator.tracksModel.count; m++) {
                var t = metaDateGenerator.tracksModel.get(m)

                // Guardar en SQLite
                dbHelper.saveTrack({
                    fileName: t.fileName,
                    title: t.title,
                    artist: t.artist,
                    album: t.album,
                    filePath: t.filePath,
                    isFavorite: false,
                    lists: [],
                    md5sum: t.md5sum || ""
                })

                // Agregar al modelo en memoria
                listGeneral.append({
                    fileName: t.fileName,
                    title: t.title,
                    artist: t.artist,
                    album: t.album,
                    filePath: t.filePath,
                    isFavorite: false,
                    lists: [],
                    md5sum: t.md5sum || ""
                })
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
            //console.log("se inicio el detonador")
            metaDateGenerator.detonator()

        }

    }

    MetaDateGenerator {
        id: metaDateGenerator
        baseModel: mp3Model
    }

}
