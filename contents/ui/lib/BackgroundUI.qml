/*
 *    SPDX-FileCopyrightText: zayronxio
 *    SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick
import QtQuick.Effects
import org.kde.ksvg 1.0 as KSvg
import Qt5Compat.GraphicalEffects
import org.kde.kirigami as Kirigami

Item {
    id: root
    property var imag
    property int sizePanel: Kirigami.Units.gridUnit * 4
    property var margin: degradBackground.marginByMask

    property bool visibleArt: false
    property bool listActive: false
    property var marginLeft: fakeCard.margins.left
    property var marginTop: fakeCard.margins.top
    property var marginRight: fakeCard.margins.right
    property var marginBottom: fakeCard.margins.bottom

    property alias panelContent: bottomContent.children
    property alias mainContent: content.children
    property alias headerContent: header.children
    property alias xValueButtonLibrary: header.buttonPosition


    KSvg.FrameSvgItem {
        id: fakeCard
        imagePath: "dialogs/background"
        clip: true
        visible: false
        width: parent.width
        height: parent.height
    }

    function isColorLight(color) {
        let r = color.r * 255;
        let g = color.g * 255;
        let b = color.b * 255;
        let luminance = 0.299 * r + 0.587 * g + 0.114 * b;
        return luminance > 127.5;
    }

    Rectangle {
        id: guia
        color: "red"
        width: 100
        height: 100
        visible: false
        anchors.left: root.left
    }


    Item {
        //visible: false
        id: degradBackground
        width: root.width + mask.marginLeft + mask.marginRight
        height: root.height + mask.marginTop + mask.marginBottom
        anchors.left: guia.left
        anchors.top: guia.top
        anchors.leftMargin: - mask.marginLeft
        anchors.topMargin: - mask.marginTop

        //visible: false
        property var marginByMask: mask.marginBottom
        property var marginLeft: mask.marginLeft
        property var marginTop: mask.marginTop
        property var marginRight: mask.marginRight
        property var marginBottom: mask.marginBottom
        property bool fullCharge: false

        HelperMask {
            id: mask
            anchors.fill: parent
            opacity: 1.0
            visible: visibleArt ? listActive : false
            onUpdateMargins: {
                if (fullCharge) {
                    degradBackground.width =  degradBackground.width + mask.marginLeft + mask.marginRight
                    degradBackground.height = height + mask.marginTop + mask.marginBottom
                    degradBackground.anchors.left = guia.left
                    degradBackground.anchors.top = guia.top
                    degradBackground.anchors.leftMargi = - mask.marginLeft
                    degradBackground.anchors.topMargin = - mask.marginTop
                }
            }
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: effect
            }
        }
        Rectangle {
            id: effect
            anchors.fill: parent
            color: "transparent"
            visible: false
            Image {
                source: "maskArt.svg"
                width: parent.width*0.5
                height: mask.height * 1.2
                visible: true
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }

        }
        Component.onCompleted: {
            fullCharge = true
        }

    }

    StatusPanel {
        id: panel
        anchors.fill: degradBackground
        realHeight: sizePanel
        opacity: 0
    }
    Item {
        id: coverArt
        anchors.fill: degradBackground
        opacity: 0.8
        Rectangle{
            anchors.fill: parent
            color:  "transparent"
            visible: true
            Kirigami.Icon {
                source: imag
                width: parent.height
                height: width
                visible: true
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: degradBackground
            }

        }
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: panel
            invert: true
        }
    }

    Item {
        id: coverArtPanel
        anchors.fill: degradBackground
        opacity: 0
        Rectangle{
            anchors.fill: parent
            color:  "transparent"
            visible: true
            Kirigami.Icon {
                source: imag
                width: parent.height
                height: width
                visible: true
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: degradBackground
            }

        }


    }


    MultiEffect {
        source: coverArtPanel
        anchors.fill: coverArtPanel
        brightness: 0.1
        saturation: 0.9
        blurEnabled: true
        blurMax: 64
        visible: true
        blur: 0.6
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: panel }
    }

    Item {
        anchors.fill: degradBackground
        Rectangle {
            width: parent.width
            height: sizePanel
            color: "transparent"
            anchors.bottom: parent.bottom
            Rectangle {
                anchors.fill: parent
                color: isColorLight(Kirigami.Theme.backgroundColor) ? Qt.rgba(255, 255, 255, 0.6) : Qt.rgba(0, 0, 0, 0.4)  //Kirigami.Theme.alternateBackgroundColor
            }
            Rectangle {
                width: parent.width
                height: 1
                color: "white"
                opacity: 0.1
                anchors.top: parent.top
            }
        }
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: panel }
    }
    Item {
        id: header
        width: parent.width
        height: 32
        anchors.top: parent.top
        property var buttonPosition
    }
    Rectangle {
        id: separator
        height: 1
        width: parent.width*.8
        anchors.left: parent.left
        anchors.leftMargin: - degradBackground.marginLeft
        anchors.bottom: header.bottom
        anchors.bottomMargin: - degradBackground.marginTop
        gradient: Gradient {
            GradientStop { position: 0.0; color: Kirigami.Theme.highlightColor} // Puedes cambiar los colores
            GradientStop { position: 1.0; color: "transparent" }
            orientation: Gradient.Horizontal
        }
    }
    Item {
        id: content
        width: parent.width
        anchors.top: separator.bottom

        height: parent.height - bottomContent.height - header.height

    }
    Item {
        id: bottomContent
        width: parent.width
        height: sizePanel
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom:  parent.bottom
        anchors.bottomMargin: - degradBackground.marginBottom
    }

}

