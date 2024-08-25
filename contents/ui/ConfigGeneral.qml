/***************************************************************************
 *   Copyright (C) 2014 by Eike Hein <hein@kde.org>                        *
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

//import QtQuick 2.15
//import QtQuick.Controls 2.15
//import QtQuick.Dialogs 1.2
//import QtQuick.Layouts 1.0
//import org.kde.plasma.core 2.0 as PlasmaCore
//import org.kde.plasma.components 2.0 as PlasmaComponents
//import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons
//import org.kde.draganddrop 2.0 as DragDrop
//import org.kde.kirigami 2.4 as Kirigami

import QtQuick 2.15
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.15
import org.kde.draganddrop 2.0 as DragDrop
import org.kde.kirigami 2.5 as Kirigami
import org.kde.iconthemes as KIconThemes
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami 2.20 as Kirigami
import org.kde.ksvg 1.0 as KSvg
import org.kde.plasma.plasmoid 2.0
import org.kde.kcmutils as KCM



KCM.SimpleKCM {
    id: configGeneral


    property string cfg_icon: plasmoid.configuration.icon
    property bool cfg_useCustomButtonImage: plasmoid.configuration.useCustomButtonImage
    property string cfg_customButtonImage: plasmoid.configuration.customButtonImage
    property alias cfg_sourceDirectory: directory.text
    //property alias cfg_showTrackName: showTrackName.checked


    property alias cfg_labels2lines: labels2lines.checked
    //property alias cfg_displayPosition: displayPosition.currentIndex


    Kirigami.FormLayout {
        anchors.left: parent.left
        anchors.right: parent.right



        Item {
            Kirigami.FormData.isSection: true
        }

        CheckBox {
            id: showTrackName
            visible: false
            Kirigami.FormData.label: i18n("Show Track Name")
        }

        ComboBox {

            Kirigami.FormData.label: i18n("Widget position")
            id: displayPosition
            visible: false
            model: [
                i18n("Default"),
                i18n("Center"),
            ]
            onActivated: cfg_displayPosition = currentIndex
        }


        CheckBox {
            id: labels2lines
            text: i18n("Show labels in two lines")
            visible: false // TODO
        }


        RowLayout{
            Label {
                Layout.minimumWidth: configRoot.width/2
                text: i18n("Music Directory:")
                horizontalAlignment: Label.AlignRight
            }
            TextField {
                id: directory
                width: 180
            }
        }

        RowLayout{

            visible: false
            Button {
                text: i18n("Unhide all hidden applications")
                onClicked: {
                    plasmoid.configuration.hiddenApplications = [""];
                    unhideAllAppsPopup.text = i18n("Unhidden!");
                }
            }
            Label {
                id: unhideAllAppsPopup
            }
        }

    }
}
