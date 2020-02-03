/*
 * Copyright (C) 2013 Canonical Ltd
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 * Ken VanDine <ken.vandine@canonical.com>
 *
*/

import QtQuick 2.4
import SystemSettings 1.0
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem

ItemPage {
    id: preview
    anchors.fill: parent

    property string uri
    signal save

    // whether an image was just imported from e.g. contentHub
    property bool imported: false
    property bool ubuntuArt: false

    states: [
        State {
            name: "saved"
            StateChangeScript {
                script: {
                    save();
                    pageStack.removePages(preview);
                }
            }
        },
        State {
            name: "cancelled"
            StateChangeScript {
                script: {
                    pageStack.removePages(preview);
                }
            }
        },
        State {
            name: "deleted"
            StateChangeScript {
                script: {
                    pageStack.removePages(preview);
                }
            }
        }
    ]
    header: PageHeader {
                id: pageHeader
                anchors.top: preview.top
                title: i18n.tr("Preview")
                StyleHints {
                    //hardcode because specific non-themed picture overlay
                    backgroundColor: "transparent"
                    foregroundColor: "white"
                }
                trailingActionBar { actions: [
                    Action {
                        id: setAction
                        text: i18n.tr("Set")
                        iconName: "tick"
                        onTriggered: {
                            preview.state = "saved"
                        }
                    },
                    Action {
                        id: deleteAction
                        text: i18n.tr("Remove")
                        iconName: "edit-delete"
                        enabled: !preview.ubuntuArt
                        onTriggered: {
                            preview.state = "deleted"
                        }
                    }
                ]}
    }

    Image {
        id: previewImage
        anchors.fill: parent
        source: uri
        sourceSize.height: height
        sourceSize.width: 0
        fillMode: Image.PreserveAspectCrop
    }

    /* Make the header even more darker to ease readability on light backgrounds */
    Rectangle {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        color: "black"
        opacity: 0.6
        height: preview.header.height
    }
}
