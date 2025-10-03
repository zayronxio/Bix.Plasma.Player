/*
 *    SPDX-FileCopyrightText: zayronxio
 *    SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import org.kde.kirigami as Kirigami

Item {
    id: root
    property url imag
    property int realHeight

    Item {
        id: degradBackground
        anchors.fill: parent
        HelperMask {
            id: background
            anchors.fill: parent
            opacity: 1.0
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
            Rectangle {
                width: parent.width
                height: realHeight
                anchors.bottom: parent.bottom
            }
        }
    }
}
