import QtQuick 2.15
import Qt5Compat.GraphicalEffects
import org.kde.ksvg 1.0 as KSvg
import QtQuick.Effects
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: root

    anchors.left: parent.left


    property int marginLeft: 0
    property int marginTop: 0
    property int marginRight: 0
    property int marginBottom: 0

    property string theme: PlasmaCore.Theme.themeName
    property bool isFirst: true

    signal updateMargins

    onThemeChanged: {
        if (!isFirst)
        wrapper.sourceComponent = null
        Qt.callLater(function() {
            wrapper.sourceComponent = mask
        })
    }

    Loader {
        id: wrapper
        anchors.fill: parent
        sourceComponent: mask
    }

    Component {
        id: mask
        Item {
            id: itemMask
            width: root.width
            height: parent.height


            KSvg.FrameSvgItem {
                id: card
                imagePath: "dialogs/background"
                clip: true
                anchors.left: guia.left
                anchors.leftMargin: 20// - root.marginLeft
                width: parent.width
                height: parent.height

                Component.onCompleted: {
                    if (isFirst) {
                        console.log("existen los valores 45:",card.margins.left)
                        root.marginLeft = parseFloat(card.margins.left)
                        root.marginTop = parseFloat(card.margins.top)
                        root.marginRight = parseFloat(card.margins.right)
                        root.marginBottom = parseFloat(card.margins.bottom)
                        updateMargins()
                    } else {
                        wait.start()
                    }

                }
            }

            Timer {
                id: wait
                interval: 1000
                running: false
                repeat: false
                onTriggered: {
                    console.log("existen los valores:",card.margins.left)
                    root.marginLeft = parseFloat(card.margins.left)
                    root.marginTop = parseFloat(card.margins.top)
                    root.marginRight = parseFloat(card.margins.right)
                    root.marginBottom = parseFloat(card.margins.bottom)
                    updateMargins()
                }
            }


            ShaderEffectSource {
                id: maskSource
                sourceItem: card
                hideSource: true
                live: true
                smooth: true
                recursive: true
            }

            Item {
                id: bg
                anchors.fill: card
                visible: false
                Rectangle {
                    anchors.fill:  parent
                    color: "black"
                }
            }

            MultiEffect {
                source: bg
                anchors.fill: card
                maskEnabled: true
                maskSource: maskSource
                visible: true
                maskInverted: true
                maskSpreadAtMin: 1.0
                maskThresholdMax: 0.1
            }
        }
    }

    Component.onCompleted: {
        isFirst = false
    }
}
