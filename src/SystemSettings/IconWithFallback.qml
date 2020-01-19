/*
 * This file is part of system-settings
 *
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
 */

import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
    property alias source: icon.source
    property alias fallbackSource: fallback.source

    width: height

    Image {
        id: icon
        anchors.fill: parent
        visible: false
        asynchronous: true
        smooth: true
        mipmap: true
    }

    UbuntuShape {
        id: shape
        visible: !fallback.visible
        anchors.fill: parent
        source: icon
    }

    Image {
        id: fallback
        visible: icon.status == Image.Null || icon.status == Image.Error
        anchors.fill: parent
        asynchronous: true
        smooth: true
        mipmap: true
    }
}
