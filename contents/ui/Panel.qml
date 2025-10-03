import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami

Item {
    width:  parent.width
    height: parent.height

    property string nameTitle
    property string nameArtist
    property string nameAlbum

    property string position
    property string duration
    property int sizeIcons: 22
    property var albumCover

    property int levelSlider
    property int newValue

    property bool currentTrackIsFavorite

    property bool suffleMode: true
    property bool repeatList
    property bool repeatTrack

    signal newValueSlider

    signal trackBackward

    signal playPause

    signal trackForward

    signal mouseAction

    signal setFavorites(bool value)

    signal toggleFavorite

    signal toggleSuffleMode

    onRepeatTrackChanged: {
        if (repeatTrack) {
            repeatList = false
        }
    }

    onRepeatListChanged: {
        if (repeatList) {
            repeatTrack = false
        }
    }
    onSuffleModeChanged: {
        if (suffleMode) {
            repeatTrack = false
            repeatList = false
        }
    }
    Row {
        anchors.fill: parent
        spacing: 24

        Item {
            id: titles
            height: parent.height
            width: trackInfo.width
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mouseAction()
                }
            }
            Column {
                id: trackInfo
                height: trackName.implicitHeight + artistName.implicitHeight
                width: trackName.implicitWidth < artistName.implicitWidth ? artistName.implicitWidth : trackName.implicitWidth
                anchors.verticalCenter: parent.verticalCenter
                Kirigami.Heading {
                    id: trackName
                    width: parent.width
                    text: nameTitle
                    level: 5
                }
                Kirigami.Heading {
                    id: artistName
                    width: parent.width
                    text: nameArtist
                    font.weight: Font.DemiBold
                    level: 5
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mouseAction()
                }
            }

        }
        Item {
            id: conteinerControls
            height: parent.height
            width: (sizeIcons*3) + controls.spacing*2
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mouseAction()
                }
            }
            Row {
                id: controls
                spacing: Kirigami.Units.mediumSpacing
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter

                Kirigami.Icon {
                    id: prev
                    width: sizeIcons
                    height: sizeIcons
                    source: "media-skip-backward"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            trackBackward()
                            mouseAction()
                        }
                    }
                }
                Kirigami.Icon {
                    id: playpause // button play and pause
                    width: sizeIcons
                    height: sizeIcons
                    source: "media-playback-start"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            playPause()
                        }
                    }
                }
                Kirigami.Icon {
                    id: next
                    width: sizeIcons
                    height: sizeIcons
                    source: "media-skip-forward"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            trackForward()
                            mouseAction()
                        }
                    }
                }
            }
        }
        Item {
            id: playSlider
            height: parent.height
            width: parent.width - conteinerControls.width - titles.width - conteinerSubControls.width - 24*3
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mouseAction()
                }
            }
            Kirigami.Heading {
                id: timeElapsed
                height: parent.height
                text: position
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment:  Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                level: 5
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        mouseAction()
                    }
                }
            }

            Slider {
                id: slider
                width: parent.width - timeElapsed.implicitWidth - timiMissing.implicitWidth - (Kirigami.Units.smallSpacing*2)
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                from: 0
                to: 100
                value: levelSlider
                onMoved: {
                    newValue = slider.value
                    mouseAction()
                }
                onPressedChanged: {
                    if (!pressed) {
                        newValueSlider()
                        mouseAction()
                    }
                }
            }

            Kirigami.Heading {
                height: parent.height
                anchors.left: slider.right
                anchors.leftMargin: Kirigami.Units.smallSpacing
                id: timiMissing
                text: duration
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment:  Text.AlignVCenter
                level: 5
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        mouseAction()
                    }
                }
            }
        }
        Item {
            id: conteinerSubControls
            height: parent.height
            width: (sizeIcons*3) + subControls.spacing*2
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mouseAction()
                }
            }
            Row {
                id: subControls
                spacing: Kirigami.Units.mediumSpacing
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter

                Kirigami.Icon {
                    width: sizeIcons
                    height: sizeIcons
                    color: suffleMode ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                    source: "media-playlist-shuffle"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            suffleMode = !suffleMode
                            mouseAction()
                        }
                    }
                }
                Kirigami.Icon {
                    width: sizeIcons
                    height: sizeIcons
                    color: repeatList || repeatTrack ? Kirigami.Theme.highlightColor :  Kirigami.Theme.textColor
                    source: repeatTrack ? "media-playlist-repeat-song-symbolic" : "media-playlist-repeat"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if(repeatList) {
                                suffleMode = false
                                repeatTrack = true
                            } else {
                                if (repeatTrack) {
                                    repeatTrack = false
                                    repeatList = false
                                } else {
                                    suffleMode = false
                                    repeatList = true
                                }
                            }
                            mouseAction()
                        }
                    }
                }
                Kirigami.Icon {
                    width: sizeIcons
                    height: sizeIcons
                    source: "view-media-favorite-symbolic"
                    color: currentTrackIsFavorite ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            toggleFavorite()
                            //setFavorites(!currentTrackIsFavorite)
                            currentTrackIsFavorite = !currentTrackIsFavorite
                            mouseAction()
                        }
                    }
                }
            }
        }
    }
}
