/*
 * This file is part of system-settings
 *
 * Copyright (C) 2013 Canonical Ltd.
 *
 * Contact: Iain Lane <iain.lane@canonical.com>
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

import QtQuick 2.0
import SystemSettings 1.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import MeeGo.QOfono 0.2
import QMenuModel 0.1
import "rdosettings-helpers.js" as RSHelpers

ItemPage {
    id: root
    title: i18n.tr("Cellular")
    objectName: "cellularPage"

    OfonoRadioSettings {
        id: rdoSettings
        modemPath: manager.modems[0]
        onTechnologyPreferenceChanged: RSHelpers.preferenceChanged(preference);
    }

    QDBusActionGroup {
        id: actionGroup
        busType: 1
        busName: "com.canonical.indicator.network"
        objectPath: "/com/canonical/indicator/network"

        property variant actionObject: action("wifi.enable")

        Component.onCompleted: {
            start()
        }
    }

    OfonoManager {
        id: manager
    }

    OfonoSimManager {
        id: sim
        modemPath: manager.modems[0]
    }

    OfonoNetworkRegistration {
        id: netReg
        modemPath: manager.modems[0]
        onStatusChanged: {
            console.warn ("onStatusChanged: " + netReg.status);
        }
    }

    OfonoConnMan {
        id: connMan
        modemPath: manager.modems[0]
        powered: techPrefSelector.selectedIndex !== 0
        onPoweredChanged: RSHelpers.poweredChanged(powered);
    }

    OfonoModem {
        id: modem
        modemPath: manager.modems[0]
    }

    Flickable {
        anchors.fill: parent
        //contentWidth: parent.width
        contentHeight: contentItem.childrenRect.height
        boundsBehavior: (contentHeight > root.height) ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds

        Column {
            anchors.left: parent.left
            anchors.right: parent.right

            ListModel {
                id: techPrefModel
                ListElement { name: "Off"; key: "off" }
                ListElement { name: "2G only (saves battery)"; key: "gsm"; }
                ListElement { name: "2G/3G/4G (faster)"; key: "any"; }
            }

            Component {
                id: techPrefDelegate
                OptionSelectorDelegate { text: i18n.tr(name); }
            }

            ListItem.ItemSelector {
                id: techPrefSelector
                objectName: "technologyPreferenceSelector"
                expanded: true
                delegate: techPrefDelegate
                model: techPrefModel
                text: i18n.tr("Cellular data:")

                // technologyPreference "" is not valid, assume sim locked or data unavailable
                enabled: rdoSettings.technologyPreference !== ""
                selectedIndex: {
                    var pref = rdoSettings.technologyPreference;
                    // make nothing selected if the string from OfonoRadioSettings is empty
                    if (pref === "") {
                        console.warn("Disabling TechnologyPreference item selector due to empty TechnologyPreference");
                        return -1;
                    } else {
                        // normalizeKey turns "lte" and "umts" into "any"
                        return RSHelpers.keyToIndex(RSHelpers.normalizeKey(pref));
                    }
                }
                onDelegateClicked: RSHelpers.delegateClicked(index)
            }

            ListItem.Standard {
                id: dataRoamingItem
                objectName: "dataRoamingSwitch"
                text: i18n.tr("Data roaming")
                // sensitive to data type, and disabled if "Off" is selected
                enabled: techPrefSelector.selectedIndex !== 0
                control: Switch {
                    id: dataRoamingControl
                    checked: connMan.roamingAllowed
                    onClicked: connMan.roamingAllowed = checked
                }
            }

            ListItem.SingleValue {
                text : i18n.tr("Hotspot disabled because Wi-Fi is off.")
                visible: showAllUI && !hotspotItem.visible
            }

            ListItem.SingleValue {
                id: hotspotItem
                text: i18n.tr("Wi-Fi hotspot")
                progression: true
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("Hotspot.qml"))
                }
                visible: showAllUI && (actionGroup.actionObject.valid ? actionGroup.actionObject.state : false)
            }

            ListItem.Standard {
                text: i18n.tr("Data usage statistics")
                progression: true
                visible: showAllUI
            }

            ListItem.SingleValue {
                text: i18n.tr("Carrier")
                objectName: "chooseCarrier"
                value: netReg.name ? netReg.name : i18n.tr("N/A")
                progression: true
                onClicked: {
                    if (enabled)
                        pageStack.push(Qt.resolvedUrl("ChooseCarrier.qml"), {netReg: netReg, connMan: connMan})
                }
            }

        }
    }
}
