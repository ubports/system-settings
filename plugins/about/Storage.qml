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
import Ubuntu.Components.Popups 1.3
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
                onSizeReady: ready = true
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
                        console.log("Unhandled sort role: "+settingsId.storageSort)
                        return ClickRoles.DisplayNameRole;
                    }
                }
            }

            Flickable {
                id: scrollWidget
                anchors.fill: parent
                contentHeight: columnId.height

                Component.onCompleted: storagePage.flickable = scrollWidget

                PullToRefresh {
                    parent: scrollWidget
                    refreshing: backendInfo.refreshing
                    onRefresh: backendInfo.refreshAsync()
                }

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

                    Binding {
                        target: valueSelect
                        property: 'selectedIndex'
                        value: {
                            switch(backendInfo.sortRole) {
                            case ClickRoles.DisplayNameRole:
                                return 0
                            case ClickRoles.InstalledSizeRole:
                                return 1
                            case ClickRoles.CacheSizeRole:
                                return 2
                            case ClickRoles.ConfigSizeRole:
                                return 3
                            case ClickRoles.DataSizeRole:
                                return 4
                            case ClickRoles.AppTotalSizeRole:
                                return 5
                            }
                        }
                    }

                    ListView {
                        id: listView
                        objectName: "installedAppsListView"
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        height: childrenRect.height
                        /* Deactivate the listview flicking, we want to scroll on the
                         * column */
                        interactive: false
                        model: backendInfo.clickList
                        ViewItems.expansionFlags: ViewItems.CollapseOnOutsidePress
                        delegate: ListItem {
                            id: appListItem
                            objectName: "appItem" + displayName
                            height: h
                            property var h: appItemLayout.height + (divider.visible ? divider.height : 0)
                            expansion.height: h + expansionLoader.height

                            SlotsLayout {
                                id: appItemLayout

                                IconWithFallback {
                                    SlotsLayout.position: SlotsLayout.First
                                    height: units.gu(4)
                                    source: iconPath
                                    fallbackSource: "image://theme/clear"
                                }
                                mainSlot: Column {
                                    spacing: units.gu(1)
                                    RowLayout {
                                        width: parent.width
                                        Label {
                                            text: displayName
                                            Layout.fillWidth: true
                                        }
                                        Label {
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
                                    Item {
                                        height: units.gu(0.5)
                                        width: parent.width
                                        Rectangle {
                                            color: theme.palette.normal.activity
                                            radius: units.dp(2)
                                            height: parent.height
                                            property var arrayBiggestValue: [backendInfo.biggestAppTotalSize, backendInfo.biggestInstallSize, backendInfo.biggestCacheSize, backendInfo.biggestConfigSize, backendInfo.biggestDataSize, backendInfo.biggestAppTotalSize]
                                            property var array: [appTotalSize, installedSize, cacheSize, configSize, dataSize, appTotalSize]
                                            width: array[valueSelect.selectedIndex] / arrayBiggestValue[valueSelect.selectedIndex] * parent.width
                                            Behavior on width { UbuntuNumberAnimation { duration: UbuntuAnimation.BriskDuration } }
                                        }
                                    }
                                }
                            }

                            Loader {
                                id: expansionLoader
                                anchors {
                                    top: appItemLayout.bottom
                                    topMargin: units.gu(1)
                                    horizontalCenter: parent.horizontalCenter
                                }
                                width: parent.width - units.gu(4)
                                sourceComponent: Component {
                                    Column {
                                        spacing: units.gu(1)
                                        bottomPadding: units.gu(2)
                                        GridLayout {
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            columnSpacing: units.gu(2)
                                            rowSpacing: units.gu(1)
                                            rows: 4
                                            flow: GridLayout.TopToBottom
                                            Item {
                                                width: 1; height: 1
                                            }
                                            Repeater {
                                                id: checkboxRepeater
                                                model: 3
                                                CheckBox {
                                                    onCheckedChanged: {
                                                        clearButton.updateText()
                                                        clearButton.updateEnabled(checked)
                                                        uninstallButton.updateText()
                                                    }
                                                }
                                            }
                                            Repeater {
                                                id: mainRepeater
                                                model: [
                                                {text: i18n.tr("Application size"), value: installedSize},
                                                {text: i18n.tr("Config size"), value: configSize},
                                                {text: i18n.tr("Data size"), value: dataSize},
                                                {text: i18n.tr("Cache size"), value: cacheSize}
                                                ]
                                                Column {
                                                    Layout.fillWidth: true
                                                    spacing: units.gu(1)
                                                    Label {
                                                        text: modelData.text
                                                    }
                                                    Item {
                                                        height: units.gu(0.5)
                                                        width: parent.width
                                                        Rectangle {
                                                            color: theme.palette.normal.activity
                                                            radius: units.dp(2)
                                                            height: parent.height
                                                            width: modelData.value / appTotalSize * parent.width
                                                        }
                                                    }
                                                }
                                            }
                                            Repeater {
                                                model: [installedSize, configSize, dataSize, cacheSize]
                                                Label {
                                                    Layout.alignment: Qt.AlignRight
                                                    textSize: Label.Small
                                                    text: Utilities.formatSize(modelData)
                                                }
                                            }
                                        }
                                        Row {
                                            anchors.right: parent.right
                                            spacing: units.gu(1)
                                            Button {
                                                id: uninstallButton
                                                text: i18n.tr("Uninstall")

                                                onClicked: {
                                                    var checkboxesValues = [];
                                                    for (var i = 0; i < 3; i++) {
                                                        checkboxesValues[i] = checkboxRepeater.itemAt(i).checked
                                                    }
                                                    var popup = PopupUtils.open(uninstallDialog, null, {"checkboxesValues": checkboxesValues})
                                                    // TRANSLATORS: %1 is the name of the application
                                                    popup.title = i18n.tr("Uninstall %1").arg(displayName)
                                                    popup.text = i18n.tr("Are you sure you want to uninstall this app?")
                                                    popup.folderSizes = [configSize, dataSize, cacheSize]
                                                    popup.selectedOption = (checkboxRepeater.itemAt(0).checked ||
                                                                            checkboxRepeater.itemAt(1).checked ||
                                                                            checkboxRepeater.itemAt(2).checked)
                                                                            ? 2 : 1
                                                    popup.accepted.connect(function(config, appData, cache) {
                                                        appListItem.expansion.expanded = false
                                                        backendInfo.uninstallApp(appId, version)
                                                        if (config)
                                                            backendInfo.clearAppConfig(appId)

                                                        if (appData)
                                                            backendInfo.clearAppData(appId)

                                                        if (cache)
                                                            backendInfo.clearAppCache(appId)
                                                        backendInfo.refreshAsync();
                                                    })
                                                }
                                                function updateText() {
                                                    text = (checkboxRepeater.itemAt(0).checked ||
                                                            checkboxRepeater.itemAt(1).checked ||
                                                            checkboxRepeater.itemAt(2).checked)
                                                            ? i18n.tr("Uninstall & Clear")
                                                            : i18n.tr("Uninstall")
                                                }
                                            }
                                            Button {
                                                id: clearButton
                                                color: theme.palette.normal.negative
                                                text: i18n.tr("Clear")

                                                enabled: false
                                                onClicked: {
                                                    var checkboxesValues = [];
                                                    for (var i = 0; i < 3; i++) {
                                                        checkboxesValues[i] = checkboxRepeater.itemAt(i).checked
                                                    }
                                                    var popup = PopupUtils.open(uninstallDialog, null, {"checkboxesValues": checkboxesValues})
                                                    popup.uninstall = false
                                                    // TRANSLATORS: %1 is the name of the application
                                                    popup.title = i18n.tr("Clear %1 data").arg(displayName)
                                                    popup.text = i18n.tr("Are you sure you want to clear the following files?")
                                                    popup.folderSizes = [configSize, dataSize, cacheSize]
                                                    popup.accepted.connect(function(config, appData, cache) {
                                                        appListItem.expansion.expanded = false
                                                        if (config)
                                                            backendInfo.clearAppConfig(appId)

                                                        if (appData)
                                                            backendInfo.clearAppData(appId)

                                                        if (cache)
                                                            backendInfo.clearAppCache(appId)
                                                        backendInfo.refreshAsync();
                                                    })
                                                }
                                                function updateText() {
                                                    var selectedSize = 0;
                                                    for (var i = 0; i < 3; i++) {
                                                        if (checkboxRepeater.itemAt(i).checked) {
                                                            selectedSize += mainRepeater.model[i + 1].value
                                                        }
                                                    }
                                                    text = selectedSize == 0 ? i18n.tr("Clear")
                                                                             : i18n.tr("Clear (%1)").arg(Utilities.formatSize(selectedSize))
                                                }
                                                function updateEnabled(checked) {
                                                    if (checked) {
                                                        // at least one checkbox is checked
                                                        enabled = true
                                                    }
                                                    else {
                                                        for (var i = 0; i < 3; i++) {
                                                            if (checkboxRepeater.itemAt(i).checked) {
                                                                enabled = true
                                                                return
                                                            }
                                                        }
                                                        enabled = false
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                active: appListItem.expansion.expanded
                            }

                            onClicked: selectMode ? selected = !selected : expansion.expanded = !expansion.expanded
                        }
                    }
                }
            }

            Component {
                id: uninstallDialog
                Dialog {
                    id: uninstallDialogue
                    signal accepted(var config, var appData, var cache)
                    property bool uninstall: true
                    property var checkboxesValues: []
                    property var folderSizes: []
                    property int selectedOption: 0
                    OptionSelector {
                        id: appDataSelector
                        visible: uninstall
                        expanded: true
                        width: parent.width
                        selectedIndex: selectedOption
                        model: [
                        i18n.tr("Keep app data"),
                        i18n.tr("Delete all app data"),
                        i18n.tr("Choose what to delete")
                        ]
                    }
                    Column {
                        width: parent.width
                        height: visible ? implicitHeight : 0
                        opacity: uninstall ? (appDataSelector.selectedIndex == 2 ? 1 : 0) : 1
                        visible: opacity > 0
                        spacing: units.gu(1)
                        Behavior on height { UbuntuNumberAnimation {} }
                        Behavior on opacity { UbuntuNumberAnimation {} }
                        Repeater {
                            id: popupRepeater
                            model: [
                            // TRANSLATORS: %1 is the size of the config files of the app
                            i18n.tr("Config (%1):"),
                            // TRANSLATORS: %1 is the size of the data files of the app
                            i18n.tr("App data (%1):"),
                            // TRANSLATORS: %1 is the size of the cache files of the app
                            i18n.tr("Cache (%1):")
                            ]
                            RowLayout {
                                spacing: units.gu(1)
                                property alias checked: checkbox.checked
                                visible: uninstall ? true : checked
                                width: parent.width
                                Label {
                                    text: modelData.arg(Utilities.formatSize(folderSizes[index]))
                                    Layout.fillWidth: true
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: checkbox.checked = !checkbox.checked
                                    }
                                }
                                CheckBox {
                                    id: checkbox
                                    checked: uninstallDialogue.checkboxesValues[index]
                                    enabled: uninstall
                                }
                            }
                        }
                    }
                    Button {
                        text: {
                            if (uninstall) {
                                switch(appDataSelector.selectedIndex) {
                                case 0:
                                    return i18n.tr("Uninstall")
                                case 1:
                                    return i18n.tr("Uninstall & Clear all")
                                case 2:
                                    return (popupRepeater.itemAt(0).checked ||
                                            popupRepeater.itemAt(1).checked ||
                                            popupRepeater.itemAt(2).checked)
                                            ? i18n.tr("Uninstall & Clear selected") : i18n.tr("Uninstall")
                                }
                            } else {
                                return i18n.tr("Clear")
                            }
                        }
                        color: theme.palette.normal.negative
                        onClicked:  {
                            PopupUtils.close(uninstallDialogue)
                            if (uninstall) {
                                switch (appDataSelector.selectedIndex) {
                                case 0:
                                    uninstallDialogue.accepted(false, false, false); break;
                                case 1:
                                    uninstallDialogue.accepted(true, true, true); break;
                                case 2:
                                    uninstallDialogue.accepted(popupRepeater.itemAt(0).checked,
                                                               popupRepeater.itemAt(1).checked,
                                                               popupRepeater.itemAt(2).checked)
                                    break;
                                }
                            }
                            else {
                                uninstallDialogue.accepted(popupRepeater.itemAt(0).checked,
                                                           popupRepeater.itemAt(1).checked,
                                                           popupRepeater.itemAt(2).checked)
                            }
                        }
                    }
                    Button {
                        text: i18n.tr("Cancel")
                        onClicked: PopupUtils.close(uninstallDialogue)
                    }
                }
            }
        }
    }
}
