/*
 * Copyright (C) 2013-2016 Canonical Ltd
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
 * Sebastien Bacher <sebastien.bacher@canonical.com>
 *
 */

import GSettings 1.0
import QMenuModel 0.1
import Qt.labs.folderlistmodel 2.1
import QtQuick 2.4
import SystemSettings 1.0
import SystemSettings.ListItems 1.0 as SettingsListItems
import Ubuntu.Components 1.3
import Ubuntu.Connectivity 1.0
import Ubuntu.Components.ListItems 1.3 as ListItems
import Ubuntu.SystemSettings.SecurityPrivacy 1.0

ItemPage {
    id: locationPage
    title: i18n.tr("Location")
    flickable: scrollWidget

    property bool useNone: !useLocation
    property bool canLocate: locationActionGroup.enabled.state !== undefined
    property bool useLocation: canLocate && locationActionGroup.enabled.state
    property bool hereInstalled: securityPrivacy.hereLicensePath !== "" && termsModel.count > 0
    property bool useHere: hereInstalled && securityPrivacy.hereEnabled

    onUseLocationChanged: {
        var newIndex;
        if (useLocation) {
            newIndex = useHere ? 1 : 0;
        } else {
            newIndex = detection.model.count - 1;
        }
        detection.selectedIndex = newIndex;
    }

    onCanLocateChanged: {
        optionsModel.createModel();
    }

    onHereInstalledChanged: {
        optionsModel.createModel();
    }

    UbuntuSecurityPrivacyPanel {
        id: securityPrivacy
    }

    FolderListModel {
        id: termsModel
        folder: securityPrivacy.hereLicensePath
        nameFilters: ["*.html"]
        showDirs: false
        showOnlyReadable: true
    }

    QDBusActionGroup {
        id: locationActionGroup
        busType: DBus.SessionBus
        busName: "com.canonical.indicator.location"
        objectPath: "/com/canonical/indicator/location"
        property variant enabled: action("location-detection-enabled")
        Component.onCompleted: start()
    }

    Flickable {
        id: scrollWidget
        anchors.fill: parent
        contentHeight: contentItem.childrenRect.height
        boundsBehavior: (contentHeight > locationPage.height) ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds
        /* Set the direction to workaround https://bugreports.qt-project.org/browse/QTBUG-31905
           otherwise the UI might end up in a situation where scrolling doesn't work */
        flickableDirection: Flickable.VerticalFlick

        Column {
            anchors.left: parent.left
            anchors.right: parent.right

            SettingsItemTitle {
                text: i18n.tr("Let the device detect your location:")
            }

            ListItems.ItemSelector {
                id: detection

                /* Helper that toggles location detection and HERE based on
                what selector element was tapped. */
                function activate (key) {
                    var usingLocation = locationActionGroup.enabled.state;
                    if (key === 'none' && usingLocation) {
                        // turns OFF location detection
                        locationActionGroup.enabled.activate();
                    }
                    if ( (key === 'gps' || key === 'here') && !usingLocation) {
                        // turns ON location detection
                        locationActionGroup.enabled.activate();
                    }
                    if (locationPage.hereInstalled) {
                        // toggles whether HERE is enabled
                        securityPrivacy.hereEnabled = key === 'here';
                    }
                }
                property bool allow: selectedIndex !== (model.count - 1)

                expanded: true
                model: optionsModel
                delegate: optionsDelegate
                selectedIndex: {
                    if (model.count === 0) return 0; // re-creating
                    if (useNone) return model.count - 1;
                    if (useLocation && !useHere) return 0;
                    if (useHere && useLocation) return 1;
                }
                onDelegateClicked: {
                    activate(model.get(index).key);
                }
            }

            Component {
                id: optionsDelegate
                OptionSelectorDelegate {

                    id: dlgt
                    text: " "
                    height: label.height
                    Label {
                        id: label
                        anchors {
                            left: parent.left
                            right: parent.right
                            margins: units.gu(2)
                            rightMargin: units.gu(6)
                        }
                        textFormat: Text.StyledText
                        text: name
                        wrapMode: Text.WordWrap
                        verticalAlignment: Text.AlignVCenter
                        height: contentHeight + units.gu(4)
                        onLinkActivated: {
                            pageStack.addPageToNextColumn(locationPage, Qt.resolvedUrl(link))
                        }
                        onLineLaidOut: {
                            dlgt.height = label.height
                        }
                    }
                }
             }


            ListModel {
                id: optionsModel

                function createModel () {
                    clear();

                    if (canLocate) {
                        optionsModel.append({
                            name: hereInstalled ?
                                i18n.tr("Using GPS only (less accurate)") :
                                i18n.tr("Using GPS"),
                            key: "gps"
                        });
                    }

                    if (hereInstalled) {
                        optionsModel.append({
                            /* TRANSLATORS: %1 is the resource wherein HERE
                            terms and conditions reside (typically a qml file).
                            HERE is a Nokia trademark, so it should probably
                            not be translated. */
                            name: NetworkingStatus.modemAvailable ?
                                i18n.tr("Using GPS, anonymized Wi-Fi and cellular network info.<br>By selecting this option you accept the <a href='%1'>Nokia HERE terms and conditions</a>.").arg("here-terms.qml") :
                                i18n.tr("Using GPS and anonymized Wi-Fi info.<br>By selecting this option you accept the <a href='%1'>Nokia HERE terms and conditions</a>.").arg("here-terms.qml"),
                            key: "here"
                        });
                    }

                    optionsModel.append({
                        name: i18n.tr("Not at all"),
                        key: "none"
                    });
                }

                dynamicRoles: true
                Component.onCompleted: {
                    createModel();
                }
            }

            ListItems.Caption {
                /* TODO: replace by real info from the location service */
                property int locationInfo: 0

                text: {
                    if (locationInfo === 0) /* GPS only */
                        return i18n.tr("Uses GPS to detect your rough location. When off, GPS turns off to save battery.")
                    else if (locationInfo === 1) /* GPS, WiFi on */
                        return i18n.tr("Uses WiFi and GPS to detect your rough location. Turning off location detection saves battery.")
                    else if (locationInfo === 2) /* GPS, WiFi off */
                        return i18n.tr("Uses WiFi (currently off) and GPS to detect your rough location. Turning off location detection saves battery.")
                    else if (locationInfo === 3) /* GPS, WiFi and cellular on */
                        return i18n.tr("Uses WiFi, cell tower locations, and GPS to detect your rough location. Turning off location detection saves battery.")
                    else if (locationInfo === 4) /* GPS, WiFi on, cellular off */
                        return i18n.tr("Uses WiFi, cell tower locations (no current cellular connection), and GPS to detect your rough location. Turning off location detection saves battery.")
                    else if (locationInfo === 5) /* GPS, WiFi off, cellular on */
                        return i18n.tr("Uses WiFi (currently off), cell tower locations, and GPS to detect your rough location. Turning off location detection saves battery.")
                    else if (locationInfo === 6) /* GPS, WiFi and cellular off */
                        return i18n.tr("Uses WiFi (currently off), cell tower locations (no current cellular connection), and GPS to detect your rough location. Turning off location detection saves battery.")
                }

                visible: showAllUI /* hide until the information is real */
            }

            SettingsItemTitle {
                text: i18n.tr("Let apps access this location:")
                enabled: detection.allow
            }

            TrustStoreModel {
                id: trustStoreModel
                serviceName: "UbuntuLocationService"
            }

            Repeater {
                model: trustStoreModel
                SettingsListItems.ProportionalShape {
                    text: model.applicationName
                    iconSource: model.iconName
                    Switch {
                        checked: model.granted
                        onClicked: trustStoreModel.setEnabled(index, !model.granted)
                    }
                    enabled: detection.allow
                }
            }

            SettingsListItems.Standard {
                text: i18n.tr("None requested")
                visible: trustStoreModel.count === 0
                enabled: false
            }
        }
    }
}
