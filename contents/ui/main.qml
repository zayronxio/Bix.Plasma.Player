/***************************************************************************
 *   Copyright (C) 2014-2015 by Eike Hein <hein@kde.org>                   *
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

import org.kde.plasma.plasmoid

import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.kirigami as Kirigami
import org.kde.ksvg 1.0 as KSvg

PlasmoidItem {

    id: wrapper

    anchors.fill: parent

    signal reset


    preferredRepresentation: compactRepresentation
    compactRepresentation: compactRepresentation
    fullRepresentation: compactRepresentation



    Component {
        id: compactRepresentation
        CompactRepresentation {}
    }


}
