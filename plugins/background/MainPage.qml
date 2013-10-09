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
 * Iain Lane <iain.lane@canonical.com>
 *
*/

import QtQuick 2.0
import GSettings 1.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Content 0.1
import SystemSettings 1.0
import Ubuntu.SystemSettings.Background 1.0

import "utilities.js" as Utilities

ItemPage {
    id: mainPage
    title: i18n.tr("Background")

    UbuntuBackgroundPanel {
        id: backgroundPanel

        function maybeUpdateSource() {
            var source = backgroundPanel.backgroundFile
            if (source != "" && source != undefined)
                testWelcomeImage.source = source
            else if (testWelcomeImage.source == "")
                testWelcomeImage.source = testWelcomeImage.fallback
        }

        onBackgroundFileChanged: maybeUpdateSource()
        Component.onCompleted: maybeUpdateSource()
    }

    GSettings {
        id: background
        schema.id: "org.gnome.desktop.background"
        onChanged: {
            if (key == "pictureUri")
                testHomeImage.source = value
        }
    }


    /* TODO: We hide the welcome screen parts for v1 - there's a lot of elements to hide */

    Label {
        id: welcomeLabel

        anchors {
            top: welcomeImage.bottom
            topMargin: units.gu(1)
            horizontalCenter: welcomeImage.horizontalCenter
        }

        text: i18n.tr("Welcome screen")

        visible: showAllUI
    }

    SwappableImage {
        id: welcomeImage

        visible: showAllUI

        anchors {
            top: parent.top
            left: parent.left
         }

        onClicked: startContentTransfer()
        Component.onCompleted: updateImage(testWelcomeImage,
                                           welcomeImage)

        OverlayImage {
            anchors.fill: parent
            source: "welcomeoverlay.svg"
        }
    }

    SwappableImage {
        id: homeImage

        anchors {
            top: parent.top
            right: (showAllUI) ? parent.right : undefined
            horizontalCenter: (showAllUI) ? undefined : parent.horizontalCenter
         }

        onClicked: startContentTransfer()
        Component.onCompleted: updateImage(testHomeImage,
                                           homeImage)

        OverlayImage {
            anchors.fill: parent
            source: "homeoverlay.svg"
        }
    }

    Label {
        id: homeLabel

        anchors {
            top: homeImage.bottom
            topMargin: units.gu(1)
            horizontalCenter: homeImage.horizontalCenter
        }

        text: i18n.tr("Home screen")

        visible: showAllUI
    }

    ListItem.ThinDivider {
        id: topDivider

        anchors {
            topMargin: units.gu(2)
            top: welcomeLabel.bottom
        }

        visible: showAllUI
    }

    Column {

        anchors {
            left: parent.left
            right: parent.right
            top: homeImage.bottom
            horizontalCenter: homeImage.horizontalCenter
        }

        ListItem.SingleControl {
            control: Button {
                text: i18n.tr("Change...")
                width: parent.width / 2
                onClicked: startContentTransfer()
            }
        }
    
        ListItem.SingleControl {
            control: Button {
                text: i18n.tr("Use original background")
                width: parent.width / 2
                onClicked: {
                    background.schema.reset('pictureUri')
                    setUpImages()
                }
            }
        }

    }

    OptionSelector {
        id: optionSelector
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: topDivider.bottom
            topMargin: units.gu(2)
        }
        width: parent.width - units.gu(4)
        expanded: true

        model: [i18n.tr("Same background for both"),
            i18n.tr("Different background for each")]
        onSelectedIndexChanged: {
            systemSettingsSettings.backgroundDuplicate = ( selectedIndex === 0 )
        }

        visible: showAllUI
    }



    /* We don't have a good way of doing this after passing an invalid image to
       SwappableImage, so test the image is valid /before/ showing it and show a
       fallback if it isn't. */
    function updateImage(testImage, targetImage) {
        if (testImage.status == Image.Ready) {
            targetImage.source = testImage.source
        } else if (testImage.status == Image.Error) {
            targetImage.source = testImage.fallback
        }
    }

    Image {
        id: testWelcomeImage
        property string fallback: "darkeningclockwork.jpg"
        visible: false
        onStatusChanged: updateImage(testWelcomeImage,
                                     welcomeImage)
    }

    Image {
        id: testHomeImage
        property string fallback: "aeg.jpg"
        source: background.pictureUri
        visible: false
        onStatusChanged: updateImage(testHomeImage,
                                     homeImage)
    }

    function setUpImages() {
        var mostRecent = (systemSettingsSettings.backgroundSetLast === "home") ?
                    testHomeImage : testWelcomeImage
        var leastRecent = (mostRecent === testHomeImage) ?
                    testWelcomeImage : testHomeImage

        if (systemSettingsSettings.backgroundDuplicate) { //same
            /* save value of least recently changed to restore later */
            systemSettingsSettings.backgroundPreviouslySetValue =
                    leastRecent.source
            /* copy most recently changed to least recently changed */
            leastRecent.source = mostRecent.source
        } else { // different
            /* restore least recently changed to previous value */
            leastRecent.source =
                    systemSettingsSettings.backgroundPreviouslySetValue
        }
    }

    GSettings {
        id: systemSettingsSettings
        schema.id: "com.ubuntu.touch.system-settings"
        onChanged: {
            if (key == "backgroundDuplicate") {
                setUpImages()
            }
        }
    }


    property var activeTransfer

    Connections {
        target: activeTransfer ? activeTransfer : null
        onStateChanged: {
            if (activeTransfer.state === ContentTransfer.Charged) {
                if (activeTransfer.items.length > 0) {
                    var imageUrl = activeTransfer.items[0].url;
                    background.pictureUri = imageUrl;
                    setUpImages();
                }
            }
        }
    }

    function startContentTransfer() {
        var transfer = ContentHub.importContent(ContentType.Pictures,
                                                ContentHub.defaultSourceForType(ContentType.Pictures));
        if (transfer != null)
        {
            transfer.selectionType = ContentTransfer.Single;
            var store = ContentHub.defaultStoreForType(ContentType.Pictures);
            console.log("Store is: " + store.uri);
            transfer.setStore(store);
            activeTransfer = transfer;
            activeTransfer.start();
        }
    }
}
