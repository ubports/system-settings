/*
 * This file is part of system-settings
 *
 * Copyright (C) 2013-2016 Canonical Ltd.
 *
 * Contact: Alberto Mardegan <alberto.mardegan@canonical.com>
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

//TODO: Go through all different ListItems and replace the deprecated ones

import GSettings 1.0
import QtQuick 2.4
import SystemSettings 1.0
import SystemSettings.ListItems 1.0 as SettingsListItems
import Lomiri.Components.ListItems 1.3 as ListItem
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import Ubuntu.SystemSettings.Reset 1.0

ItemPage {
    id: root

    title: i18n.tr("Reset device")
    objectName: "resetPage"
    flickable: scrollWidget

    // workaround for #1231729
    // delay destroying popup until pageStack has been popped
    property var popup
    function done () {
        popup.opacity = 0;
        pageStack.pop();
        popup.destroy(1000);
    }

    Loader {
        id: buttonActions
        asynchronous: false
    }

    UbuntuResetPanel {
        id: resetBackend
    }

    GSettings {
        id: unitySettings
        schema.id: "com.canonical.Unity.Launcher"
    }

    Flickable {
        id: scrollWidget
        anchors.fill: parent
        contentHeight: contentItem.childrenRect.height
        boundsBehavior: (contentHeight > root.height) ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds

        Column {
            anchors.left: parent.left
            anchors.right: parent.right

            SettingsListItems.StandardProgression {
                showDivider: false
                id: resetLauncherHomeButton
                objectName: "resetLauncherHomeButton"
                text: i18n.tr("Reset Launcher")
                onClicked: {
                    buttonActions.source = "ResetLauncherHome.qml";
                    root.popup = PopupUtils.open(buttonActions.item);
                }
            }

            ListItem.Caption {
                text: i18n.tr("The Launcher will be returned to its original contents.")
            }

             SettingsListItems.StandardProgression {
                 visible: showAllUI
                 showDivider: false
                 id: resetAllSettingsButton
                 objectName: "resetAllSettingsButton"
                 text: i18n.tr("Reset all system settings…")
                 onClicked: {
                     buttonActions.source = "ResetAllSettings.qml";
                     root.popup = PopupUtils.open(buttonActions.item);
                 }
             }

            ListItem.Caption {
                visible: showAllUI
                text: i18n.tr("The contents and layout of the launcher, and the filters in the home screen will be returned to their original settings.")
            }

            SettingsListItems.StandardProgression {
                 showDivider: false
                 id: eraseEverythingButton
                 objectName: "factoryReset"
                 text: i18n.tr("Erase & Reset All")
                    onClicked: {
                        buttonActions.source = "EraseEverything.qml";
                        root.popup = PopupUtils.open(buttonActions.item);
                    }
             }

            ListItem.Caption {
                text: i18n.tr("All documents, saved games, settings, and other items will be permanently deleted from this device.")
            }

        }
    }
}
