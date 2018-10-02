/*
 * This file is part of system-settings
 *
 * Copyright (C) 2016 Canonical Ltd.
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
import Ubuntu.SystemSettings.Notifications 1.0
import SystemSettings 1.0

ItemPage {
    id: appNotificationsPage

    property var entry
    property int entryIndex

    title: entry ? entry.displayName : ""
    flickable: clickAppNotificationsFlickable

    function disableNotificationsWhenAllUnchecked() {
        if (!entry) {
            return
        }

        if (!entry.soundsNotify && !entry.vibrationsNotify && !entry.bubblesNotify && !entry.listNotify) {
            enableNotificationsSwitch.checked = false
            entry.enableNotifications = false
        }
    }

    Component.onDestruction: disableNotificationsWhenAllUnchecked()

    Flickable {
        id: clickAppNotificationsFlickable
        flickableDirection: Flickable.VerticalFlick
        contentHeight: contentItem.childrenRect.height

        anchors.fill: parent

        Column {
            id: notificationsColumn

            anchors.fill: parent

            ListItem {
                height: enableNotificationsLayout.height + (divider.visible ? divider.height : 0)
                ListItemLayout {
                    id: enableNotificationsLayout
                    title.text: i18n.tr("Notifications")
                    Switch {
                        id: enableNotificationsSwitch
                        objectName: "enableNotificationsSwitch"
                        SlotsLayout.position: SlotsLayout.Trailing
                        checked: entry ? entry.enableNotifications : false

                        onCheckedChanged: {
                            ClickApplicationsModel.setNotifyEnabled(ClickApplicationsModel.EnableNotifications,
                                                                    appNotificationsPage.entryIndex,
                                                                    checked)
                        }
                    }
                }
            }

            ListItem {
                visible: entry ? entry.enableNotifications : false
                ListItemLayout {
                    title.text: i18n.tr("Let this app alert me using:")
                    title.color: theme.palette.normal.backgroundSecondaryText
                }
            }

            ListItem {
                height: soundsLayout.height + (divider.visible ? divider.height : 0)
                visible: entry ? entry.enableNotifications : false
                ListItemLayout {
                    id: soundsLayout
                    title.text: i18n.tr("Sounds")
                    CheckBox {
                        id: soundsChecked
                        objectName: "soundsChecked"
                        SlotsLayout.position: SlotsLayout.Leading
                        enabled: entry ? entry.enableNotifications : false
                        checked: entry ? entry.soundsNotify : false

                        onCheckedChanged: {
                            ClickApplicationsModel.setNotifyEnabled(ClickApplicationsModel.SoundsNotify,
                                                                    appNotificationsPage.entryIndex,
                                                                    checked)
                            disableNotificationsWhenAllUnchecked()
                        }
                    }
                }
            }

            ListItem {
                height: vibrationsLayout.height + (divider.visible ? divider.height : 0)
                visible: entry ? entry.enableNotifications : false
                ListItemLayout {
                    id: vibrationsLayout
                    title.text: i18n.tr("Vibrations")
                    CheckBox {
                        id: vibrationsChecked
                        objectName: "vibrationsChecked"
                        SlotsLayout.position: SlotsLayout.Leading
                        enabled: entry ? entry.enableNotifications : false
                        checked: entry ? entry.vibrationsNotify : false

                        onCheckedChanged: {
                            ClickApplicationsModel.setNotifyEnabled(ClickApplicationsModel.VibrationsNotify,
                                                                    appNotificationsPage.entryIndex,
                                                                    checked)
                            disableNotificationsWhenAllUnchecked()
                        }
                    }
                }
            }

            ListItem {
                height: bubblesLayout.height + (divider.visible ? divider.height : 0)
                visible: entry ? entry.enableNotifications : false
                ListItemLayout {
                    id: bubblesLayout
                    title.text: i18n.tr("Notification Bubbles")
                    CheckBox {
                        id: bubblesChecked
                        objectName: "bubblesChecked"
                        SlotsLayout.position: SlotsLayout.Leading
                        enabled: entry ? entry.enableNotifications : false
                        checked: entry ? entry.bubblesNotify : false

                        onCheckedChanged: {
                            ClickApplicationsModel.setNotifyEnabled(ClickApplicationsModel.BubblesNotify,
                                                                    appNotificationsPage.entryIndex,
                                                                    checked)
                            disableNotificationsWhenAllUnchecked()
                        }
                    }
                }
            }

            ListItem {
                height: listLayout.height + (divider.visible ? divider.height : 0)
                visible: entry ? entry.enableNotifications : false
                ListItemLayout {
                    id: listLayout
                    title.text: i18n.tr("Notification List")
                    CheckBox {
                        id: listChecked
                        objectName: "listChecked"
                        SlotsLayout.position: SlotsLayout.Leading
                        enabled: entry ? entry.enableNotifications : false
                        checked: entry ? entry.listNotify : false

                        onCheckedChanged: {
                            ClickApplicationsModel.setNotifyEnabled(ClickApplicationsModel.ListNotify,
                                                                    appNotificationsPage.entryIndex,
                                                                    checked)
                            disableNotificationsWhenAllUnchecked()
                        }
                    }
                }
            }
        }
    }
}
