/*
 * This file is part of system-settings
 *
 * Copyright (C) 2013 Canonical Ltd.
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

import GSettings 1.0
import QtQuick 2.9
import QtSystemInfo 5.0
import SystemSettings 1.0
import SystemSettings.ListItems 1.0 as SettingsListItems
import Ubuntu.Components 1.3
import Ubuntu.SystemSettings.StorageAbout 1.0
import QtQuick.Layouts 1.3

ItemPage {
    id: storagePage
    objectName: "storagePage"
    title: i18n.tr("Storage")

    Column {
        anchors.centerIn: parent
        visible: progress.running
        spacing: units.gu(2)
        Label {
            anchors {
                left: parent.left
                right: parent.right
            }
            horizontalAlignment: Text.AlignHCenter
            text: i18n.tr("Scanning")
        }
        ActivityIndicator {
            id: progress
            visible: running
            running: !pageLoader.visible
        }
    }

    Loader {
        id: pageLoader
        anchors.fill: parent
        asynchronous: true
        visible: status == Loader.Ready
        sourceComponent: Item {
            anchors.fill: parent
            property var allDrives: {
                var drives = ["/"] // Always consider /
                var paths = [backendInfo.getDevicePath("/")]
                var systemDrives = backendInfo.mountedVolumes
                for (var i = 0; i < systemDrives.length; i++) {
                    var drive = systemDrives[i]
                    var path = backendInfo.getDevicePath(drive)
                    if (paths.indexOf(path) == -1 && // Haven't seen this device before
                        path.charAt(0) === "/") { // Has a real mount point
                        drives.push(drive)
                        paths.push(path)
                    }
                }
                return drives
            }
            property real diskSpace: {
                var space = 0
                for (var i = 0; i < allDrives.length; i++) {
                    space += backendInfo.getTotalSpace(allDrives[i])
                }
                return space
            }
            /* Limit the free space to the user available one (see bug #1374134) */
            property real freediskSpace: {
                return backendInfo.getFreeSpace("/home")
            }

            property real usedByUbuntu: diskSpace -
                                        freediskSpace -
                                        backendInfo.homeSize -
                                        backendInfo.totalClickSize
            property real otherSize: diskSpace -
                                     freediskSpace -
                                     usedByUbuntu -
                                     clickAndAppDataSize -
                                     backendInfo.moviesSize -
                                     backendInfo.audioSize -
                                     backendInfo.picturesSize -
                                     backendInfo.documentsSize -
                                     backendInfo.downloadsSize -
                                     backendInfo.anboxSize -
                                     backendInfo.libertineSize
            property real clickAndAppDataSize: backendInfo.totalClickSize +
                                               backendInfo.appCacheSize +
                                               backendInfo.appConfigSize +
                                               backendInfo.appDataSize -
                                               backendInfo.libertineSize
            //TODO: Let's consider use unified colors in a ¿file?
            property variant spaceColors: [
                UbuntuColors.orange,
                "#a52a00", //System Maroon
                "#006a97", //System Blue
                "#198400", //Dark System Green
                "#9542c4", //from suru colors app
                "#d07810", //from suru colors app
                "#009688", //Anbox greenish
                "#5d5d5d", //Libertine grey hat
                "#f5d412", //System Yellow
                UbuntuColors.lightAubergine]
            property variant spaceLabels: [
                i18n.tr("Used by Ubuntu"),
                i18n.tr("Videos"),
                i18n.tr("Audio"),
                i18n.tr("Pictures"),
                i18n.tr("Documents"),
                i18n.tr("Downloads"),
                i18n.tr("Anbox"),
                i18n.tr("Libertine"),
                i18n.tr("Other files"),
                i18n.tr("Used by apps")]
            property variant spaceValues: [
                usedByUbuntu, // Used by Ubuntu
                backendInfo.moviesSize,
                backendInfo.audioSize,
                backendInfo.picturesSize,
                backendInfo.documentsSize,
                backendInfo.downloadsSize,
                backendInfo.anboxSize,
                backendInfo.libertineSize,
                otherSize, //Other Files
                clickAndAppDataSize]
            property variant spaceObjectNames: [
                "usedByUbuntuItem",
                "moviesItem",
                "audioItem",
                "picturesItem",
                "documentsItem",
                "downloadsItem",
                "anboxItem",
                "libertineItem",
                "otherFilesItem",
                "usedByAppsItem"]

            GSettings {
                id: settingsId
                schema.id: "com.ubuntu.touch.system-settings"
            }

            UbuntuStorageAboutPanel {
                id: backendInfo
                property bool ready: false
                // All of these events come simultaneously
                onMoviesSizeChanged: ready = true
                Component.onCompleted: populateSizes()
                sortRole: {
                    switch(settingsId.storageSort) {
                    case "name":
                        return ClickRoles.DisplayNameRole;
                    case "total-size":
                        return ClickRoles.AppTotalSizeRole;
                    case "installed-size":
                        return ClickRoles.InstalledSizeRole;
                    case "cache-size":
                        return ClickRoles.CacheSizeRole;
                    case "data-size":
                        return ClickRoles.DataSizeRole;
                    case "config-size":
                        return ClickRoles.ConfigSizeRole;
                    default:
                        console.log("Unhandled sort role")
                        return ClickRoles.DisplayNameRole;
                    }
                }
            }

            Flickable {
                id: scrollWidget
                anchors.fill: parent
                contentHeight: columnId.height

                Component.onCompleted: storagePage.flickable = scrollWidget

                Column {
                    id: columnId
                    anchors.left: parent.left
                    anchors.right: parent.right

                    SettingsListItems.SingleValue {
                        id: diskItem
                        objectName: "diskItem"
                        text: i18n.tr("Total storage")
                        value: Utilities.formatSize(diskSpace)
                        showDivider: false
                    }

                    StorageBar {
                        ready: backendInfo.ready
                    }

                    StorageItem {
                        objectName: "storageItem"
                        colorName: theme.palette.normal.foreground
                        label: i18n.tr("Free space")
                        value: freediskSpace
                        ready: backendInfo.ready
                    }

                    Repeater {
                        model: spaceColors

                        StorageItem {
                            objectName: spaceObjectNames[index]
                            colorName: modelData
                            label: spaceLabels[index]
                            value: spaceValues[index]
                            ready: backendInfo.ready
                        }
                    }

                    ListItem {
                        objectName: "installedAppsItemSelector"
                        height: layout.height + (divider.visible ? divider.height : 0)
                        divider.visible: false
                        SlotsLayout {
                            id: layout
                            mainSlot: OptionSelector {
                                id: valueSelect
                                width: parent.width - 2 * (layout.padding.leading + layout.padding.trailing)
                                model: [i18n.tr("By name"), i18n.tr("By installation size"), i18n.tr("By cache size"), i18n.tr("By config size"), i18n.tr("By data size"), i18n.tr("By total size")]
                                onSelectedIndexChanged: {
                                    switch (selectedIndex) {
                                    case 0: default:
                                        settingsId.storageSort = "name"
                                        break
                                    case 1:
                                        settingsId.storageSort = "installed-size"
                                        break
                                    case 2:
                                        settingsId.storageSort = "cache-size"
                                        break
                                    case 3:
                                        settingsId.storageSort = "config-size"
                                        break
                                    case 4:
                                        settingsId.storageSort = "data-size"
                                        break
                                    case 5:
                                        settingsId.storageSort = "total-size"
                                        break
                                    }
                                }
                            }
                        }
                    }

                    ListItem {
                        height: rowL.height + (divider.visible ? divider.height : 0) + units.gu(1)
                        divider.visible: false
                        RowLayout {
                            id: rowL
                            width: parent.width - units.gu(4)
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            spacing: 0
                            Repeater {
                                id: repeater
                                model: [
                                {text: i18n.tr("Installed"), color: "#f89b0f"},
                                {text: i18n.tr("Config"), color: "#0e8cba"},
                                {text: i18n.tr("Data"), color: "#198400"},
                                {text: i18n.tr("Cache"), color: "#ec2259"}
                                ]
                                Label {
                                    Layout.fillWidth: true
                                    text: modelData.text
                                    textSize: Label.Small
                                    color: theme.palette.normal.backgroundSecondaryText
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.preferredHeight: contentHeight + underline.height + units.gu(0.5)
                                    Rectangle {
                                        id: underline
                                        color: modelData.color
                                        width: parent.width
                                        height: units.gu(0.75)
                                        anchors.bottom: parent.bottom
                                    }
                                }
                            }
                        }
                    }

                    Binding {
                        target: valueSelect
                        property: 'selectedIndex'
                        value: {
                            switch(backendInfo.sortRole) {
                            case ClickRoles.DisplayNameRole:
                                return 0;
                            case ClickRoles.InstalledSizeRole:
                                return 1;
                            case ClickRoles.CacheSizeRole:
                                return 2;
                            case ClickRoles.ConfigSizeRole:
                                return 3;
                            case ClickRoles.DataSizeRole:
                                return 4;
                            case ClickRoles.AppTotalSizeRole:
                                return 5;
                            }
                        }
                    }

                    ListView {
                        objectName: "installedAppsListView"
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: childrenRect.height
                        /* Deactivate the listview flicking, we want to scroll on the
                         * column */
                        interactive: false
                        model: backendInfo.clickList
                        delegate: ListItem {
                            objectName: "appItem" + displayName
                            height: appItemLayout.height + appStorageBar.height + (divider.visible ? divider.height : 0)

                            ListItemLayout {
                                id: appItemLayout
                                title.text: displayName
                                height: units.gu(6)

                                IconWithFallback {
                                    SlotsLayout.position: SlotsLayout.First
                                    height: units.gu(4)
                                    source: iconPath
                                    fallbackSource: "image://theme/clear"
                                }
                                Label {
                                    SlotsLayout.position: SlotsLayout.Last
                                    horizontalAlignment: Text.AlignRight
                                    text: {
                                        switch (valueSelect.selectedIndex) {
                                        case 0: case 5: default:
                                            return Utilities.formatSize(appTotalSize)
                                        case 1:
                                            return installedSize ? Utilities.formatSize(installedSize) : i18n.tr("N/A")
                                        case 2:
                                            return Utilities.formatSize(cacheSize)
                                        case 3:
                                            return Utilities.formatSize(configSize)
                                        case 4:
                                            return Utilities.formatSize(dataSize)
                                        }
                                    }

                                }
                            }
                            StorageBar {
                                id: appStorageBar
                                anchors {
                                    top: appItemLayout.bottom
                                }
                                height: units.gu(2)
                                barHeight: units.gu(1)
                                model: ["#f89b0f", "#0e8cba", "#198400", "#ec2259"]
                                segments: [installedSize, configSize, dataSize, cacheSize]
                                totalBar: appTotalSize
                                ready: true
                            }
                        }
                    }
                }
            }
        }
    }
}
