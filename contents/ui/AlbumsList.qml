import QtQuick
import QtQuick.Effects
import QtQuick.Controls
import org.kde.kirigami as Kirigami

Item {
    anchors.fill: parent

    property ListModel listModel: []

    signal changeOfList(string nameAlbum)

    Flickable {
        id: flickable
        anchors.fill: parent
        contentWidth: wrapper.width
        contentHeight: wrapper.height
        clip: true

        Grid {
            id: wrapper
            width: flickable.width   // importante para que use el ancho del Flickable
            columns: 4
            spacing: 24

            Repeater {
                model: listModel
                delegate: Item {
                    width: (wrapper.width - (wrapper.columns - 1) * wrapper.spacing) / wrapper.columns
                    height: width * 0.6 + album.implicitHeight + artist.implicitHeight + 8

                    Rectangle {
                        id: mask
                        width: parent.width * 0.6
                        height: width
                        color: "red"
                        radius: 12
                    }

                    ShaderEffectSource {
                        id: maskSource
                        sourceItem: mask
                        hideSource: true
                        live: true
                        smooth: true
                        recursive: true
                    }

                    Image {
                        id: coverArt
                        width: parent.width * 0.6
                        height: width
                        visible: false
                        source: model.cover
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Column {
                        anchors.fill: parent
                        spacing: 4

                        MultiEffect {
                            id: maskedImage
                            source: coverArt
                            width: coverArt.width
                            height: coverArt.height
                            visible: false
                            maskEnabled: true
                            maskSource: maskSource
                        }

                        MultiEffect {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: maskedImage.width
                            height: maskedImage.height
                            source: maskedImage
                            shadowEnabled: true
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    changeOfList(model.album)
                                }
                            }
                        }

                        Rectangle {
                            color: "transparent"
                            width: parent.width
                            height: 12
                        }

                        Kirigami.Heading {
                            id: album
                            width: parent.width - Kirigami.Units.largeSpacing * 2
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: model.album
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                            level: 5
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Kirigami.Heading {
                            id: artist
                            width: parent.width - Kirigami.Units.largeSpacing * 2
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: model.artist
                            elide: Text.ElideRight
                            level: 5
                            horizontalAlignment: Text.AlignHCenter

                        }
                    }
                }
            }
        }

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AlwaysOn
        }
    }
}

