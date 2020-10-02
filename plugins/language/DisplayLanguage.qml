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
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.SystemSettings.LanguagePlugin 1.0

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
    }

  

    ListView {
        id: languageList
        objectName: "languagesList"
        clip: true

        anchors.top: head.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: divider.top

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

    ListItem.ThinDivider {
        id: divider

        anchors.bottom: buttonRectangle.top
    }

    Item {
        id: buttonRectangle

        height: cancelButton.height + units.gu(2)

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        Button {
            id: cancelButton
            objectName: "cancelChangeLanguage"
            text: initialCancel

            anchors.left: parent.left
            anchors.right: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.topMargin: units.gu(1)
            anchors.leftMargin: units.gu(2)
            anchors.rightMargin: units.gu(1)
            anchors.bottomMargin: units.gu(1)

            onClicked: {
                i18n.language = initialLanguage
                PopupUtils.close(root)
            }
        }

        Button {
            id: confirmButton
            objectName: "confirmChangeLanguage"
            text: i18n.tr("Confirm")
            enabled: languageList.currentIndex != plugin.currentLanguage

            anchors.left: parent.horizontalCenter
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.topMargin: units.gu(1)
            anchors.leftMargin: units.gu(1)
            anchors.rightMargin: units.gu(2)
            anchors.bottomMargin: units.gu(1)

            onClicked: {
                var oldLang = plugin.currentLanguage;
                var newLang = languageList.currentIndex;
                languageChanged(newLang, oldLang);
                plugin.currentLanguage = newLang;
                PopupUtils.close(root);
            }
        }
    }
}
