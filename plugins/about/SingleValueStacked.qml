/*
 * This file is part of system-settings
 *
 * Copyright (C) 2014 Canonical Ltd.
 * Copyright (C) 2020 UBports Foundation <developers@ubports.com>
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
 *
 * Author: Jonas G. Drange <jonas.drange@canonical.com>
 */

import QtQuick 2.4
import Ubuntu.Components 1.3

ListItem {

    property alias text: label.text
    property alias value: value.text

    height: col.childrenRect.height + units.gu(2)
    divider.visible: true

    Column {
        anchors {
            fill: parent
            topMargin: units.gu(1)
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
        }
        id: col
        spacing: units.gu(1)
        Label {
            id: label
            anchors {
                left:parent.left
                right:parent.right
            }
            wrapMode: Text.WordWrap
        }
        Label {
            id: value
            anchors {
                left:parent.left
                right:parent.right
            }
            wrapMode: Text.WordWrap
        }
    }
}
