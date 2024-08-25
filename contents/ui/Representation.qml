/*
 *  SPDX-FileCopyrightText: zayronxio
 *  SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.4
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.private.mpris as Mpris
import Qt5Compat.GraphicalEffects
import org.kde.kirigami as Kirigami
import org.kde.ksvg 1.0 as KSvg
//import QtQuick.Controls 2.15

Item {
    id: main
    property int menuPos: 1

    property bool plasmoidFocus: true

    onVisibleChanged: {
        root.visible = !root.visible
    }

    //InfoMusic {
      //  id: infoMusic
    //}

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

    Mpris.Mpris2Model {
        id: mpris2Model
    }

    function next() {
        mpris2Model.currentPlayer.Next()
    }
    function playPause() {
        mpris2Model.currentPlayer.PlayPause()
    }
    function prev() {
        mpris2Model.currentPlayer.Previous()
    }
    Plasmoid.status: PlasmaCore.Types.PassiveStatus

    PlasmaCore.Dialog {
        id: root

        objectName: "popupWindow"
        flags: Qt.ApplicationModal
        location: PlasmaCore.Types.Floating
        hideOnWindowDeactivate: false



        onVisibleChanged: {
            if (visible) {
                var pos = popupPosition(width, height);
                x = pos.x;
                y = pos.y;
                timer.start(); // Start the timer when the window is shown
                heightAnimation.start(); // Start the animation when the window is shown
            } else {
                timer.stop(); // Stop the timer when the window is hidden
                heightAnimation.stop(); // Stop the animation when the window is hidden
            }
        }


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

            if (menuPos === 0) {
                switch (plasmoid.location) {
                    case PlasmaCore.Types.BottomEdge:
                        var x = appletTopLeft.x < screen.width - width ? appletTopLeft.x : screen.width - width - 8;
                        var y = screen.height - height - panelH - Kirigami.Units.gridUnit / 2;
                        return calculatePosition(x, y);

                    case PlasmaCore.Types.TopEdge:
                        x = appletTopLeft.x < screen.width - width ? appletTopLeft.x + panelW - Kirigami.Units.gridUnit / 3 : screen.width - width;
                        y = panelH + Kirigami.Units.gridUnit / 2;
                        return calculatePosition(x, y);

                    case PlasmaCore.Types.LeftEdge:
                        x = appletTopLeft.x + panelW + Kirigami.Units.gridUnit / 2;
                        y = appletTopLeft.y < screen.height - height ? appletTopLeft.y : appletTopLeft.y - height + iconUser.height / 2;
                        return calculatePosition(x, y);

                    case PlasmaCore.Types.RightEdge:
                        x = appletTopLeft.x - width - Kirigami.Units.gridUnit / 2;
                        y = appletTopLeft.y < screen.height - height ? appletTopLeft.y : screen.height - height - Kirigami.Units.gridUnit / 5;
                        return calculatePosition(x, y);

                    default:
                        return;
                }
            } else if (menuPos === 2) {
                x = screen.width - width / 2;
                y = screen.height - height - panelH - Kirigami.Units.gridUnit / 2;
                return calculatePosition(x, y);
            } else if (menuPos === 1) {
                x = horizMidPoint - width / 2;
                y = vertMidPoint - height / 2;
                return calculatePosition(x, y);
            }
        }

        FocusScope {
            id: rootItem
            Layout.minimumWidth:  630
            Layout.maximumWidth:  minimumWidth
            Layout.minimumHeight: 480
            Layout.maximumHeight: minimumHeight
            focus: false


            ListMultimedia {
                id: listMultimedia
                width: parent.width
                height: parent.height
                anchors.centerIn: parent
            }
       }
    }
}
