/*
 * This file is part of system-settings
 *
 * Copyright (C) 2013 Canonical Ltd.
 *
 * Contact: William Hua <william.hua@canonical.com>
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
import Lomiri.Components.Popups 1.3
import Lomiri.Components.ListItems 1.3 as ListItem
import Lomiri.SystemSettings.LanguagePlugin 1.0

PopupBase {
    id: root
    objectName: "displayLanguageDialog"

    property string initialLanguage
    property string initialCancel

    signal languageChanged (int newLanguage, int oldLanguage)
    
    Rectangle {
    anchors.fill: root
    color: theme.palette.normal.background
    }
    
    width: parent.width
    height: parent.height
    
    Component.onCompleted: {
        initialLanguage = i18n.language
        initialCancel = i18n.tr("Cancel")
    }
    
    PageHeader {
        id: head
        title: i18n.tr("Display language")
        leadingActionBar.actions: [
            Action {
                iconName: "back"
                text: i18n.tr("Back")
                  onTriggered: {
                      i18n.language = initialLanguage
                      PopupUtils.close(root)
                  }
            }
        ]

        trailingActionBar { actions: [
                    Action {
                        id: setAction
                        text: i18n.tr("Confirm")
                        enabled: languageList.currentIndex != plugin.currentLanguage
                        iconName: "tick"
                        onTriggered: {
                            var oldLang = plugin.currentLanguage;
                            var newLang = languageList.currentIndex;
                            languageChanged(newLang, oldLang);
                            plugin.currentLanguage = newLang;
                            PopupUtils.close(root)
                        }
                    }]               
                }
    }

  

    ListView {
        id: languageList
        objectName: "languagesList"
        clip: true

        anchors.top: head.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        contentHeight: contentItem.childrenRect.height
        boundsBehavior: contentHeight > root.height ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds
        /* Set the direction to workaround https://bugreports.qt-project.org/browse/QTBUG-31905
           otherwise the UI might end up in a situation where scrolling doesn't work */
        flickableDirection: Flickable.VerticalFlick

        currentIndex: plugin.currentLanguage

        model: plugin.languageNames
        delegate: ListItem.Standard {
            objectName: "languageName" + index
            text: modelData
            selected: index == languageList.currentIndex

            onClicked: {
                languageList.currentIndex = index
            }
        }

        onCurrentIndexChanged: {
            i18n.language = plugin.languageCodes[currentIndex]
        }
    }
}
