/*
 *  SPDX-FileCopyrightText: zayronxio
 *  SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import org.kde.plasma.plasmoid
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami as Kirigami
import "lib" as Lib

Item {
    id: main

    onVisibleChanged: {
        root.visible = !root.visible
    }


    Plasmoid.status: PlasmaCore.Types.PassiveStatus

    PlasmaCore.Dialog {
        id: root

        objectName: "popupWindow"
        flags: Qt.ApplicationModal
        location: PlasmaCore.Types.Floating
        hideOnWindowDeactivate: false


        onHeightChanged: {
            var pos = popupPosition(width, height);
            x = pos.x;
            y = pos.y;
        }

        onWidthChanged: {
            var pos = popupPosition(width, height);
            x = pos.x;
            y = pos.y;
        }

        function toggle() {
            main.visible = !main.visible;
        }

        function popupPosition(width, height) {
            var screenAvail = wrapper.availableScreenRect;
            var screen = wrapper.screenGeometry;
            var panelH = screen.height - screenAvail.height;
            var panelW = screen.width - screenAvail.width;
            var horizMidPoint = screen.x + (screen.width / 2);
            var vertMidPoint = screen.y + (screen.height / 2);
            var appletTopLeft = parent.mapToGlobal(0, 0);

            function calculatePosition(x, y) {
                return Qt.point(x, y);
            }
            x = horizMidPoint - width / 2;
            y = vertMidPoint - height / 2;
            return calculatePosition(x, y);

        }
        function foceFocus() {

        }

        FocusScope {
            id: rootItem
            Layout.minimumWidth:  700
            Layout.maximumWidth:  700
            Layout.minimumHeight: 420
            Layout.maximumHeight: 420
            focus: true

            property ListModel general: listMultimedia.listGeneral
            property var iam: player.currentCover
            property string currentTrackTitle
            property string currentTrackArtist

            property int currentIndex
            property var currentList

            property bool suffleModeActive: panel.suffleMode
            property bool repeatList
            property bool repeatTrack

            Lib.ForzeMpris {
                id: forzeMpris
                qimage: player.currentCover
                onNextMpris: {
                   list.nextTrack()
                }

                onPlayPauseMpris: {
                    player.playPause()
                }
                onPrevMpris: {
                    list.prevTrack()
                }
            }

            Player {
                id: player
                onCoverReady: {
                    forzeMpris.qimage = player.currentCover
                }
                onTrackFinished: {
                    list.nextTrack()
                }
                onIsPlayChanged: {
                    ui.listActive = player.isPlay
                }
            }

            ListMultimedia {
                id: listMultimedia

            }
            AddFavorites {
                id: setFavs
            }

            ListGeneretor {
                id: listGenerator
                onReadylist: {
                    if(backgroundMenu.idList === 3) {
                        albums.listModel = listGenerator.albumsModel // se asigna luego de ser creada la lista
                    } else {
                        list.listModel = null
                        list.listModel = listGenerator.newModel
                    }
                }
            }

            onCurrentIndexChanged: {
                listView.SelectedIndex = currentIndex
            }


            Lib.BackgroundUI {
                id: ui
                width: parent.width
                height: parent.height
                imag: rootItem.iam
                opacity: 0.9
                listActive: false
                visibleArt: !albums.visible

                headerContent: Item {
                    id: header
                    anchors.fill: parent

                    Row {
                        id: actions
                        width: 48 + spacing
                        height: parent.height
                        spacing: Kirigami.Units.smallSpacing
                        Rectangle {
                            width: 24
                            height: 24
                            radius:  12
                            color: "transparent"
                            anchors.verticalCenter: parent.verticalCenter
                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: Kirigami.Theme.backgroundColor
                            }
                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: Kirigami.Theme.textColor
                                opacity: 0.3
                            }
                            Text {
                                anchors.fill: parent
                                text: "x"
                                color: Kirigami.Theme.textColor
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment:  Text.AlignVCenter
                            }
                        }
                        Rectangle {
                            width: 24
                            height: 24
                            radius:  12
                            color: "transparent"
                            anchors.verticalCenter: parent.verticalCenter
                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: Kirigami.Theme.backgroundColor
                            }
                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: Kirigami.Theme.textColor
                                opacity: 0.3
                            }
                            Text {
                                anchors.fill: parent
                                text: "-"
                                color: Kirigami.Theme.textColor
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment:  Text.AlignVCenter
                            }
                        }
                    }
                    Rectangle {
                        id: libraryButton
                        width: 128
                        height: 30
                        radius: height/2
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: actions.right
                        anchors.leftMargin: Kirigami.Units.largeSpacing
                        color: menuActive ? Kirigami.Theme.backgroundColor : Kirigami.Theme.highlightColor

                        Kirigami.Heading {
                            width: parent.width
                            height: parent.height
                            text: "Library"
                            color: menuActive ? Kirigami.Theme.textColorr : Kirigami.Theme.highlightTextColorr
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment:  Text.AlignVCenter
                            font.weight: Font.DemiBold
                            level: 5
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                backgroundMenu.buttonClicked()
                            }
                        }
                        Component.onCompleted:{
                            buttonPosition = libraryButton.mapToGlobal(0, 0)
                            buttonSizes = Qt.size(libraryButton.width, libraryButton.height)
                        }
                    }
                    Rectangle {
                        id: point
                        width: 4
                        height: 4
                        color: Kirigami.Theme.highlightColor
                        radius: 2
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: libraryButton.right
                        anchors.leftMargin: Kirigami.Units.largeSpacing
                    }
                    Kirigami.Heading {
                        id: activeMod
                        height: parent.height
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: point.right
                        anchors.leftMargin: Kirigami.Units.largeSpacing
                        text: listActive
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment:  Text.AlignVCenter
                        level: 5
                    }

                    Lib.SearchEntry {
                        id: searchEntry
                        height: parent.height
                        width: 160
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: activeMod.right
                        anchors.leftMargin: Kirigami.Units.largeSpacing

                        onEntryTextChanged: {
                            listGenerator.origenModel = listMultimedia.listGeneral
                            listGenerator.findText = searchEntry.entryText
                        }
                    }


                }

                // Contenido principal con lista y grid, el menu puede dictar cual de los dos elementos estara visuble, el grid es unicamente para albums
                mainContent: Item {
                    anchors.fill: parent
                    clip: true
                    List {
                        id: list
                        anchors.fill: parent
                        listModel: listMultimedia.listGeneral
                        visible: !albums.visible
                        suffleMode: suffleModeActive
                        listRepeat: panel.repeatList
                        trackRepeat: panel.repeatTrack
                        onChargeTrack: function (filePath, title,  artist, album, isFavorite){
                            player.currentTrack = filePath
                            rootItem.currentTrackTitle = title
                            rootItem.currentTrackArtist = artist
                            panel.currentTrackIsFavorite = isFavorite
                            forzeMpris.newMetadata(title, artist, album, null)
                        }
                    }
                    AlbumsList {
                        id: albums
                        visible: false
                        anchors.fill: parent
                        onChangeOfList: function(nameAlbum) {
                            albums.listModel = null
                            albums.visible = false
                            listGenerator.origenModel = listMultimedia.listGeneral
                            listGenerator.buildAlbumList(nameAlbum)
                            list.listModel = listGenerator.newModel
                        }
                    }
                }

                // Panel con controles tipo reproductor tambien contiene el diseño de la barra inferioir, cualquier modificacion del mismo debe realizarse en Panel.qml
                panelContent: Item {
                    anchors.fill: parent
                    Panel {
                        id: panel
                        nameTitle: rootItem.currentTrackTitle
                        nameArtist: rootItem.currentTrackArtist
                        levelSlider: player.playbackPercent
                        position: player.trackPosition
                        duration: player.trackDuration
                        onNewValueSlider: {
                            player.newPosition = newValue
                        }
                        onPlayPause: {
                            player.playPause()
                        }
                        onTrackForward:{
                            backgroundMenu.close()
                            list.nextTrack()
                        }
                        onTrackBackward: {
                            backgroundMenu.close()
                            var newIndex = rootItem.currentIndex > 0 ? rootItem.currentIndex -1 : listMultimedia.listGeneral.count - 1
                            rootItem.currentIndex = newIndex
                            player.currentTrack = listMultimedia.listGeneral.get(rootItem.currentIndex).filePath
                            rootItem.currentTrackTitle = listMultimedia.listGeneral.get(rootItem.currentIndex).title
                            rootItem.currentTrackArtist = listMultimedia.listGeneral.get(rootItem.currentIndex).artist
                        }
                        onMouseAction: {
                            backgroundMenu.close()
                        }
                        onToggleFavorite: {
                            listMultimedia.toggleFavorite(player.currentTrack)
                        }
                    }
                }
            }

            Lib.Menu {
                id: backgroundMenu
                width: Kirigami.Units.gridUnit * 10
                x: buttonPosition.x - ((width - buttonSizes.width)/2)
                y: buttonPosition.y + buttonSizes.height + 8 // Kirigami.Theme.largeSpacing
            }
            Connections {
                target: backgroundMenu
                onChargeList: {
                    /// < -- esta señal es emitida por el menu que desplega el boton Libarty, y ayuda a generar dinamicamente las listas, al inicio del plasmoid solo se genera un lista con todas las canciones.
                    var listId = backgroundMenu.idList
                    if (listId === 3){
                        albums.visible = true
                        listGenerator.origenModel = listMultimedia.listGeneral
                        listGenerator.buildFullAlbumsList()
                    } else {
                        if (listId === 1) {
                             albums.visible = false
                             list.listModel = listMultimedia.listGeneral
                             list.chargeList()

                        } else {
                            if (listId === 2){
                                albums.visible = false
                                listGenerator.origenModel = listMultimedia.listGeneral
                                list.chargeList()
                                listGenerator.buildFavoritesList()
                                list.listModel = listGenerator.newModel
                            }
                        }
                    }
                }
            }
            Connections {
                target: panel
                onSuffleModeChanged: list.suffleMode = panel.suffleMode
                onRepeatListChanged: list.listRepeat = panel.repeatList
                onRepeatTrackChanged: list.trackRepeat = panel.repeatTrack
            }
       }
    }
}
