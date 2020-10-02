/*
 * This file is part of system-settings
 *
 * Copyright (C) 2018 Kugi Eusebio
 *
 * Contact: Kugi Eusebio <kugi_igi@yahoo.com>
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
import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import SystemSettings 1.0
import Ubuntu.SystemSettings.LanguagePlugin 1.0

ItemPage {
    id: root
    objectName: "themeValues"
    flickable: scrollWidget
    
    property variant themeModel
    
    GSettings {
        id: settings

        schema.id: "com.canonical.keyboard.maliit"
        
        onChanged: {
            var curIndex = themeModel.findIndex(function(data){return data.value === value})
            if( curIndex != -1)
                themeSelector.selectedIndex = curIndex
        }
        Component.onCompleted: {
            themeSelector.selectedIndex = themeModel.findIndex(function(data){return data.value === settings.theme})
        }
    }

    Flickable {
        id: scrollWidget
        anchors.fill: parent
        contentHeight: contentItem.childrenRect.height
        boundsBehavior: (contentHeight > root.height) ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds

        Column {
            anchors.left: parent.left
            anchors.right: parent.right

            ListItem.ItemSelector {
                id: themeSelector
                objectName: "themeSelector"
                delegate: OptionSelectorDelegate {
                    text: modelData.name
                }
                model: themeModel
                expanded: true
                onDelegateClicked: {
                    settings.theme = themeModel[index].value
                    highlightWhenPressed: false
                }
            }
        }
    }
}
