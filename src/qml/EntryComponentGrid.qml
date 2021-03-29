/*
 * This file is part of system-settings
 *
 * Copyright (C) 2013 Canonical Ltd.
 * Copyright (C) 2020 Ubports Foundation <developers@ubports.com>
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import Lomiri.Components 1.3
import Ubuntu.Settings.Components 0.1

Item {
    id: root

    property string text: ""
    property string iconSource: ""
    property alias color: lomiriShape.backgroundColor

    signal clicked

    implicitHeight: button.implicitHeight

    AbstractButton {
        id: button
        anchors.left: parent.left
        anchors.right: parent.right
        implicitHeight: col.implicitHeight
        onClicked: root.clicked()

        Column {
            id: col
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: units.gu(1)

            Icon {
                id: icon
                anchors.horizontalCenter: parent.horizontalCenter
                width: height
                height: units.gu(4)
                source: root.iconSource
            }

            Label {
                anchors { left: parent.left; right: parent.right }
                text: root.text
                horizontalAlignment: Text.AlignHCenter
                fontSize: "small"
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }
        }
    }

    LomiriShape {
        id: lomiriShape
        z: -1
        visible: button.pressed
        anchors{
            fill: root
            margins: -units.gu(0.25)
        }
        opacity: 0.15
    }
}
