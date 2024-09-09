/*
 *  SPDX-FileCopyrightText: zayronxio
 *  SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.4
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import Qt5Compat.GraphicalEffects
import org.kde.kirigami as Kirigami
import org.kde.ksvg 1.0 as KSvg
//import QtQuick.Controls 2.15
//import QtQuick.Effects

Item {
    id: main
    property int menuPos: 1

    property bool plasmoidFocus: true
    property bool isfocus: false
    property int initialX: 0
    property int initialY: 0
    property int valorx: 0
    property bool minimized: true
    property bool firtDesminimizar: true

    onVisibleChanged: {
        root.visible = !root.visible
    }


    KSvg.FrameSvgItem {
        id : mediaSvg

        visible: false

        imagePath: "icons/media.svg"
    }

    KSvg.FrameSvgItem {
        id : backgroundSvg

        visible: false

        imagePath: "dialogs/background"
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
            Layout.minimumWidth:  630
            Layout.maximumWidth:  minimumWidth
            Layout.minimumHeight: 450
            Layout.maximumHeight: minimumHeight
            focus: true

            Kirigami.Icon {
                id: moveIcon
                source: "transform-move"
                width: 22
                height: 22
                anchors.top: parent.top
                anchors.topMargin: 5
                anchors.right:  parent.right
                anchors.rightMargin: 8
                MouseArea {
                    anchors.fill:  parent
                    hoverEnabled: false
                    //drag.target: parent
                    onPressed: {
                        // Guarda la posición X al momento de presionar
                        initialX = mouseX - root.x
                        initialY = mouseY - root.y

                        console.log("Clic presionado en X:", initialX)
                    }

                    onPositionChanged: {
                        if (pressed) {
                            // Ajusta la posición del rectángulo en base a la posición del mouse mientras se mantiene presionado
                            root.x += mouseX
                            root.y  += mouseY
                            //initialX = root.x
                            //initialY = root.y
                            valorx = mouseX
                            console.log("Posición X mientras se mueve:", parent.x)
                        }
                    }

                }
            }

            Kirigami.Icon {
                source: "window-minimize"
                width: 22
                height: 22
                anchors.verticalCenter: moveIcon.verticalCenter
                anchors.right:  moveIcon.left
                anchors.rightMargin: 8
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("el valor es",root.visible)
                        root.visible = !root.visible
                        minimized = true
                        console.log("el valor es",root.visible)
                    }
                }

            }

            onActiveFocusChanged: {
                isfocus = !isfocus
                //root.dashWindowIsFocus = isfocus
                console.log("focus is", isfocus)
            }


            ListMultimedia {
                id: listMultimedia
                width: parent.width
                height: parent.height
                anchors.centerIn: parent
                //visible: false

            }
       }
    }
}
