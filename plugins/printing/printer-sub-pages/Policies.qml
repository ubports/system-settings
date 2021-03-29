/*
 * Copyright 2017 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by Jonas G. Drange <jonas.drange@canonical.com>
 */

import QtQuick 2.4
import SystemSettings.ListItems 1.0 as SettingsListItems
import Lomiri.Components 1.3
import Lomiri.Components.Extras.Printers 0.1
import Lomiri.Settings.Components 0.1 as LSC

Column {
    SettingsListItems.Standard {
        text: i18n.tr("Enabled")

        CheckBox {
            id: enabledSwitch

            property bool serverChecked: printer.printerEnabled

            LSC.ServerPropertySynchroniser {
                userTarget: enabledSwitch
                userProperty: "checked"
                serverTarget: enabledSwitch
                serverProperty: "serverChecked"

                onSyncTriggered: printer.printerEnabled = enabledSwitch.checked
            }
        }
    }

    SettingsListItems.Standard {
        text: i18n.tr("Default")
        layout.subtitle.text: printer.default ? i18n.tr("This is the default printer.") : ""

        Button {
            text: i18n.tr("Set as Default")
            visible: !printer.default
            onClicked: {
                Printers.defaultPrinterName = printer.name;
                pageStack.removePages(printerPage);
            }
        }
    }

    SettingsListItems.Standard {
        text: i18n.tr("Accepting jobs")

        CheckBox {
            checked: printer.acceptJobs
            onTriggered: printer.acceptJobs = checked
        }
    }

    SettingsListItems.Standard {
        text: i18n.tr("Shared")

        CheckBox {
            checked: printer.shared
            onTriggered: printer.shared = checked
            enabled: !printer.isRemote
        }
    }
}
