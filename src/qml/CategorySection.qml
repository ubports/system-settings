/*
 * This file is part of system-settings
 *
 * Copyright (C) 2015-2016 Canonical Ltd.
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
import SystemSettings 1.0
import SystemSettings.ListItems 1.0 as SettingsListItems
import Ubuntu.Components 1.3


Column {
    anchors {
        left: parent.left
        right: parent.right
    }
    spacing: units.gu(1)

    property string category
    property string categoryName

    objectName: "categoryGrid-" + category

    SettingsItemTitle {
        id: header
        text: categoryName
        visible: repeater.count > 0
    }

    AdaptiveContainer {
        id: container
        anchors {
            left: parent.left
            right: parent.right
        }
        layout: apl.columns > 1 ? "column" : "grid"
        gridItemWidth: units.gu(12)
        gridColumnSpacing: units.gu(1)
        gridRowSpacing: units.gu(3)

        Behavior on y { UbuntuNumberAnimation {}}
        Behavior on height { UbuntuNumberAnimation {}}

        Repeater {
            id: repeater

            visible: false // AdaptiveContainer must ignore the Repeater
            model: pluginManager.itemModel(category)

            delegate: Loader {
                id: loader
                property string layout: ""
                sourceComponent: model.item.entryComponent
                visible: model.item.visible
                active: model.item.visible
                Connections {
                    ignoreUnknownSignals: true
                    target: loader.item
                    onClicked: {
                        var pageComponent = model.item.pageComponent
                        if (pageComponent) {
                            Haptics.play();
                            loadPluginByName(model.item.baseName);
                        }
                    }
                }
                Binding {
                    target: loader.item
                    property: "color"
                    value: theme.palette.highlighted.background
                    when: currentPlugin == model.item.baseName && apl.columns > 1
                }
                Binding {
                    target: loader.item
                    property: "color"
                    value: "transparent"
                    when: currentPlugin != model.item.baseName || apl.columns == 1
                }
                Binding {
                    target: loader.item
                    property: "layout"
                    value: loader.layout
                }
            }
        }
    }

    ListItem {
        divider {
            visible: true
            colorFrom: "#EEEEEE"
            colorTo: "#EEEEEE"
        }
        visible: header.visible && container.layout == "grid"
        height: divider.height
    }
}
