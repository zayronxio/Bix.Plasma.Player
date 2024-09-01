/***************************************************************************
 *   Copyright (C) 2013-2014 by Eike Hein <hein@kde.org>                   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.0
import QtQuick.Layouts 1.1
//import org.kde.plasma.private.mpris as Mpris
import org.kde.plasma.plasmoid
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami as Kirigami
import Qt5Compat.GraphicalEffects

Item {
    id: root


    Layout.minimumWidth: showTrack ? musicTrack.implicitWidth < musicTrack.width ? bar.implicitWidth +  musicTrack.implicitWidth + 20 : bar.implicitWidth +  musicTrack.width + 20 : isPlaying ? bar.width : 22


    //property bool showTrack: Plasmoid.configuration.showTrackName
    //readonly property int playbackStatus: mpris2Model.currentPlayer?.playbackStatus ?? 0
    //readonly property bool isPlaying: root.playbackStatus === Mpris.PlaybackStatus.Playing
    readonly property var screenGeometry: plasmoid.screenGeometry
    readonly property bool inPanel: (plasmoid.location == PlasmaCore.Types.TopEdge
                                     || plasmoid.location == PlasmaCore.Types.RightEdge
                                     || plasmoid.location == PlasmaCore.Types.BottomEdge
                                     || plasmoid.location == PlasmaCore.Types.LeftEdge)
    readonly property bool vertical: (plasmoid.formFactor == PlasmaCore.Types.Vertical)
    readonly property bool useCustomButtonImage: (Plasmoid.configuration.useCustomButtonImage
                                                  && Plasmoid.configuration.customButtonImage.length != 0)
    property QtObject dashWindow: null

    //Plasmoid.status: dashWindow && dashWindow.visible ? PlasmaCore.Types.RequiresAttentionStatus : PlasmaCore.Types.PassiveStatus


    Kirigami.Icon {
        id: buttonIcon

        anchors.fill: parent
        source: "com.deepin.Music"
        active: mouseArea.containsMouse
        smooth: true
    }

    MouseArea
    {
        id: mouseArea

        anchors.fill: parent

        hoverEnabled: true

        onClicked: {
            if (dashWindow.visible === true) {
               dashWindow.visible = !dashWindow.visible;
            } else {
                if (dashWindow.isfocus !== undefined) {
                    if (!dashWindow.isfocus) {
                        dashWindow.visible = !dashWindow.visible;
                        dashWindow.visible = !dashWindow.visible;
                    } else {
                        dashWindow.visible = !dashWindow.visible;
                    }
                } else {
                    dashWindow.visible = !dashWindow.visible;
                }


            }

        }
    }

    Component.onCompleted: {
        dashWindow = Qt.createQmlObject("Representation {}", root);
        plasmoid.activated.connect(function() {
            dashWindow.visible = !dashWindow.visible;
        });

    }
}
