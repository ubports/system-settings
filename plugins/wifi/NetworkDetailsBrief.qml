/*
 * This file is part of system-settings
 *
 * Copyright (C) 2014-2016 Canonical Ltd.
 *
 * Contact: Jonas G. Drange <jonas.drange@canonical.com>
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
import QtQuick.Layouts 1.1
import SystemSettings 1.0
import SystemSettings.ListItems 1.0 as SettingsListItems
import Ubuntu.Components 1.3
import Ubuntu.SystemSettings.Wifi 1.0

ItemPage {
    id: root
    property string networkName
    property var accessPoint

    title: networkName
    flickable: networkDetailBriefFlickable

    Flickable {
        id: networkDetailBriefFlickable
        anchors.fill: parent
        contentHeight: contentItem.childrenRect.height
        boundsBehavior: (contentHeight > root.height) ?
                            Flickable.DragAndOvershootBounds :
                            Flickable.StopAtBounds
        /* Set the direction to workaround
           https://bugreports.qt-project.org/browse/QTBUG-31905 otherwise the UI
           might end up in a situation where scrolling doesn't work */
        flickableDirection: Flickable.VerticalFlick

        Column {

            anchors.left: parent.left
            anchors.right: parent.right

            SettingsListItems.SingleControl {
                Button {
                    text : i18n.tr("Forget this network")
                    color: UbuntuColors.red
                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: units.gu(2)
                    }
                    onClicked: {
                        if (DbusHelper.forgetActiveDevice()) {
                            accessPoint.checked = false;
                            accessPoint.checkedChanged(false);
                            pageStack.removePages(root);
                        }
                    }
                }
            }

            SettingsListItems.Standard {
                text: i18n.tr("IP address")
                id: addressItem

                TextField {
                    text: DbusHelper.wifiIp4Address
                    readOnly: true
                    horizontalAlignment: TextInput.AlignRight
                    width: addressItem.width/2
                    persistentSelection: true
                    font.pixelSize: units.dp(16)
                    font.weight: Font.Light
                    font.family: "Ubuntu"
                    color: "#AAAAAA"
                    maximumLength: 20
                    focus: true
                    clip: true
                    opacity: 0.9
                    cursorVisible: false
                    hasClearButton: false
                }
            }
        }
    }
}
