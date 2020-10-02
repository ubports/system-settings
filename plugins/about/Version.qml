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
 * Author: Sergio Schvezov <sergio.schvezov@canonical.com>
 *         Jonas G. Drange <jonas.drange@canonical.com>
 *
 */

import QtQuick 2.4
import Qt.labs.folderlistmodel 1.0
import SystemSettings 1.0
import Ubuntu.Components 1.3
import Ubuntu.SystemSettings.StorageAbout 1.0

ItemPage {
    id: versionPage
    objectName: "versionPage"
    title: i18n.tr("OS Build Details")
    flickable: flickElement

    property string version

    UbuntuStorageAboutPanel {
        id: storedInfo
    }

    Flickable {
        id: flickElement
        anchors.fill: parent

        contentHeight: contentItem.childrenRect.height
        boundsBehavior: (contentHeight > versionPage.height) ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds
        /* Set the direction to workaround https://bugreports.qt-project.org/browse/QTBUG-31905
           otherwise the UI might end up in a situation where scrolling doesn't work */
        flickableDirection: Flickable.VerticalFlick

        Column {
            anchors {
                left: parent.left
                right: parent.right
            }

            SingleValueStacked {
                objectName: "versionBuildNumberItem"
                text: i18n.tr("OS build number")
                value: versionPage.version ? versionPage.version : "Non system image"
            }

            SingleValueStacked {
                objectName: "ubportsVersionBuildNumberItem"
                text: i18n.tr("UBports Image part")
                value: SystemImage.currentUbportsBuildNumber
                visible: SystemImage.currentUbportsBuildNumber
            }

            SingleValueStacked {
                objectName: "ubuntuBuildIDItem"
                visible: storedInfo.ubuntuBuildID
                text: i18n.tr("Ubuntu build description")
                value: storedInfo.ubuntuBuildID
            }

            SingleValueStacked {
                objectName: "deviceVersionBuildNumberItem"
                text: i18n.tr("Device Image part")
                value: SystemImage.currentDeviceBuildNumber
                visible: SystemImage.currentDeviceBuildNumber
            }

            SingleValueStacked {
                objectName: "deviceBuildIDItem"
                text: i18n.tr("Device build description")
                value: storedInfo.deviceBuildDisplayID
                visible: storedInfo.deviceBuildDisplayID
            }

            SingleValueStacked {
                objectName: "customizationBuildNumberItem"
                text: i18n.tr("Customization Image part")
                value: SystemImage.currentCustomBuildNumber
                visible: SystemImage.currentCustomBuildNumber
            }
        }
    }
}
