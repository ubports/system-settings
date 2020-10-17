/*
 * This file is part of system-settings
 *
 * Copyright (C) 2020 UBports Foundation
 *
 * Contact: Alfred Neumayer <dev.beidl@gmail.com>
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
import SystemSettings 1.0
import SystemSettings.ListItems 1.0 as SettingsListItems
import Ubuntu.Components 1.3
import Ubuntu.SystemSettings.Nfc 1.0

ItemPage {
    id: root
    title: i18n.tr("NFC")
    flickable: nfcFlickable

    Flickable {
        id: nfcFlickable
        anchors.fill: parent
        contentHeight: contentItem.childrenRect.height
        boundsBehavior: (contentHeight > root.height) ?
                            Flickable.DragAndOvershootBounds :
                            Flickable.StopAtBounds
        /* Workaround https://bugreports.qt-project.org/browse/QTBUG-31905 */
        flickableDirection: Flickable.VerticalFlick

        Column {
            anchors.left: parent.left
            anchors.right: parent.right

            SettingsListItems.Standard {
                text: i18n.tr("NFC")
                Switch {
                    id: control
                    objectName: "nfcSwitch"
                    SlotsLayout.position: SlotsLayout.Trailing
                    onCheckedChanged: {
                        DbusHelper.setEnabled(checked)
                    }
                    Component.onCompleted: {
                        checked = DbusHelper.enabled()
                    }
                }
            }
        }
    }
}
