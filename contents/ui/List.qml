import QtQuick
import org.kde.kirigami as Kirigami

Item {

    property var listModel
    property int indexSelecction
    property url currentTrack
    property string trackTitle
    property string trackArtist
    property string trackAlbum
    property bool trackIsFavorite
    property bool listRepeat
    property bool trackRepeat

    property bool suffleMode: true
    property var currentList // lista temporal para evitar comportamientos inesperados

    signal chargeTrack(url filePath, string title, string artist, string trackAlbum, bool isFavorite)
    signal nextTrack
    signal prevTrack
    signal playPause
    signal chargeList

    onChargeList: {
        var currentModel = listModel
        listModel = null
        listModel = currentModel
    }

    function getRandomNumber(min, max, omit) {
        let num;
        do {
            num = Math.floor(Math.random() * (max - min + 1)) + min;
        } while (num === omit);
        return num;
    }


    onNextTrack: {
        var continuousPlayback = true
        if (suffleMode) {
            indexSelecction = getRandomNumber(0,(currentList.count -1), indexSelecction) // genera suffle
        } else {
            if (listRepeat) {
               indexSelecction = (indexSelecction + 1) % currentList.count // repite lista,tiene error, cuando inicia de vuelta inicia de 1, debe iniciar de 0
            } else {
                if (!trackRepeat) {
                    if (indexSelecction === currentList.count -1) {
                        continuousPlayback = false
                    } else {
                        indexSelecction = indexSelecction + 1
                    }
                }
            }

        }
        if (continuousPlayback) {
            chargeTrack(currentList.get(indexSelecction).filePath, currentList.get(indexSelecction).title, currentList.get(indexSelecction).artist, currentList.get(indexSelecction).album, currentList.get(indexSelecction).isFavorite )
        }

    }

    onPrevTrack: {
        indexSelecction = (indexSelecction - 1 ) % (currentList.count -1)
        chargeTrack(currentList.get(indexSelecction).filePath, currentList.get(indexSelecction).title, currentList.get(indexSelecction).artist, currentList.get(indexSelecction).album, currentList.get(indexSelecction).isFavorite)
    }

    ListView {
        id: listView
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: 16//Kirigami.Units.smallSpacing*2
        clip: true

        model: listModel //listMultimedia.listGeneral

        delegate: Row {
            width: parent.width
            height: 30

            Item {
                id: trackInfo
                width: parent.width/2
                height: 30
                Kirigami.Heading {
                    id: title
                    text: model.title
                    width: parent.width
                    elide: Text.ElideRight
                    height: 15
                    level: 5
                }
                Kirigami.Heading {
                    anchors.bottom: parent.bottom
                    anchors.topMargin: - 12
                    text: model.album
                    width: parent.width
                    elide: Text.ElideRight
                    level: 5
                    opacity: 0.7
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        indexSelecction = model.index
                        currentTrack = model.filePath
                        trackTitle = model.title
                        trackArtist = model.artist
                        trackAlbum = model.album
                        trackIsFavorite = model.isFavorite
                        currentList  = listModel
                        chargeTrack(currentTrack,trackTitle,trackArtist,trackAlbum,trackIsFavorite)
                    }
                }
            }

            Kirigami.Heading {
                text: model.artist
                width: parent.width
                height: 30
                level: 5
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        indexSelecction = model.index
                        currentTrack = model.filePath
                        trackTitle = model.title
                        trackArtist = model.artist
                        trackAlbum = model.Album
                        trackIsFavorite = model.isFavorite
                        currentList  = listModel
                        chargeTrack(currentTrack,trackTitle,trackArtist,trackAlbum,trackIsFavorite)
                    }
                }
            }
        }
    }
}
