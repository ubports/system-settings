/*
 * This file is part of system-settings
 *
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
import Ubuntu.Components 1.3

Item {
    id: root

    property string layout: "grid"
    property string text: i18n.dtr(model.item.translations, model.displayName)
    property string iconSource: model.icon
    property var color: "transparent"

    signal clicked

    objectName: "entryComponent-" + model.item.baseName
    implicitHeight: layout == "grid" ? gridComponent.implicitHeight : listComponent.implicitHeight

    EntryComponentList {
        id: listComponent
        text: root.text
        iconSource: root.iconSource
        color: root.color
        opacity: root.layout == "column" ? 1 : 0
        onClicked: root.clicked()
        Behavior on opacity { UbuntuNumberAnimation {}}
    }

    EntryComponentGrid {
        id: gridComponent
        anchors { left: parent.left; right: parent.right }
        text: root.text
        iconSource: root.iconSource
        color: root.color
        opacity: root.layout == "grid" ? 1 : 0
        onClicked: root.clicked()
        Behavior on opacity { UbuntuNumberAnimation {}}
    }
}
